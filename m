From: Amerigo Wang <amwang@redhat.com>
Subject: [v2 Patch 3/3] bonding: make bonding support netpoll
Date: Mon, 5 Apr 2010 05:12:40 -0400
Message-ID: <20100405091628.4890.30541.sendpatchset@localhost.localdomain>
References: <20100405091605.4890.31181.sendpatchset@localhost.localdomain>
Cc: Matt Mackall <mpm@selenic.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org,
	Andy Gospodarek <gospo@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Amerigo Wang <amwang@redhat.com>,
	Jeff Moyer <jmoyer@redhat.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61346 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752380Ab0DEJNP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Apr 2010 05:13:15 -0400
In-Reply-To: <20100405091605.4890.31181.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Based on Andy's work, but I modified a lot.

Similar to the patch for bridge, this patch does:

1) implement the 2 methods to support netpoll for bonding;

2) modify netpoll during forwarding packets via bonding;

3) disable netpoll support of bonding when a netpoll-unabled device
   is added to bonding;

4) enable netpoll support when all underlying devices support netpoll.

Cc: Andy Gospodarek <gospo@redhat.com>
Cc: Jeff Moyer <jmoyer@redhat.com>
Cc: Matt Mackall <mpm@selenic.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: David Miller <davem@davemloft.net>
Signed-off-by: WANG Cong <amwang@redhat.com>

---

Index: linux-2.6/drivers/net/bonding/bond_main.c
===================================================================
--- linux-2.6.orig/drivers/net/bonding/bond_main.c
+++ linux-2.6/drivers/net/bonding/bond_main.c
@@ -59,6 +59,7 @@
 #include <linux/uaccess.h>
 #include <linux/errno.h>
 #include <linux/netdevice.h>
+#include <linux/netpoll.h>
 #include <linux/inetdevice.h>
 #include <linux/igmp.h>
 #include <linux/etherdevice.h>
@@ -430,7 +431,18 @@ int bond_dev_queue_xmit(struct bonding *
 	}
 
 	skb->priority = 1;
-	dev_queue_xmit(skb);
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	if (bond->dev->priv_flags & IFF_IN_NETPOLL) {
+		struct netpoll *np = bond->dev->npinfo->netpoll;
+		slave_dev->npinfo = bond->dev->npinfo;
+		np->real_dev = np->dev = skb->dev;
+		slave_dev->priv_flags |= IFF_IN_NETPOLL;
+		netpoll_send_skb(np, skb);
+		slave_dev->priv_flags &= ~IFF_IN_NETPOLL;
+		np->dev = bond->dev;
+	} else
+#endif
+		dev_queue_xmit(skb);
 
 	return 0;
 }
@@ -1329,6 +1341,60 @@ static void bond_detach_slave(struct bon
 	bond->slave_cnt--;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static bool slaves_support_netpoll(struct net_device *bond_dev)
+{
+	struct bonding *bond = netdev_priv(bond_dev);
+	struct slave *slave;
+	int i = 0;
+	bool ret = true;
+
+	read_lock(&bond->lock);
+	bond_for_each_slave(bond, slave, i) {
+		if ((slave->dev->priv_flags & IFF_DISABLE_NETPOLL)
+				|| !slave->dev->netdev_ops->ndo_poll_controller)
+			ret = false;
+	}
+	read_unlock(&bond->lock);
+	return i != 0 && ret;
+}
+
+static void bond_poll_controller(struct net_device *bond_dev)
+{
+	struct net_device *dev = bond_dev->npinfo->netpoll->real_dev;
+	if (dev != bond_dev)
+		netpoll_poll_dev(dev);
+}
+
+static void bond_netpoll_cleanup(struct net_device *bond_dev)
+{
+	struct bonding *bond = netdev_priv(bond_dev);
+	struct slave *slave;
+	const struct net_device_ops *ops;
+	int i;
+
+	read_lock(&bond->lock);
+	bond_dev->npinfo = NULL;
+	bond_for_each_slave(bond, slave, i) {
+		if (slave->dev) {
+			ops = slave->dev->netdev_ops;
+			if (ops->ndo_netpoll_cleanup)
+				ops->ndo_netpoll_cleanup(slave->dev);
+			else
+				slave->dev->npinfo = NULL;
+		}
+	}
+	read_unlock(&bond->lock);
+}
+
+#else
+
+static void bond_netpoll_cleanup(struct net_device *bond_dev)
+{
+}
+
+#endif
+
 /*---------------------------------- IOCTL ----------------------------------*/
 
 static int bond_sethwaddr(struct net_device *bond_dev,
@@ -1746,6 +1812,18 @@ int bond_enslave(struct net_device *bond
 		new_slave->state == BOND_STATE_ACTIVE ? "n active" : " backup",
 		new_slave->link != BOND_LINK_DOWN ? "n up" : " down");
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	if (slaves_support_netpoll(bond_dev)) {
+		bond_dev->priv_flags &= ~IFF_DISABLE_NETPOLL;
+		if (bond_dev->npinfo)
+			slave_dev->npinfo = bond_dev->npinfo;
+	} else if (!(bond_dev->priv_flags & IFF_DISABLE_NETPOLL)) {
+		bond_dev->priv_flags |= IFF_DISABLE_NETPOLL;
+		pr_info("New slave device %s does not support netpoll\n",
+			slave_dev->name);
+		pr_info("Disabling netpoll support for %s\n", bond_dev->name);
+	}
+#endif
 	/* enslave is successful */
 	return 0;
 
@@ -1929,6 +2007,15 @@ int bond_release(struct net_device *bond
 
 	netdev_set_master(slave_dev, NULL);
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	if (slaves_support_netpoll(bond_dev))
+		bond_dev->priv_flags &= ~IFF_DISABLE_NETPOLL;
+	if (slave_dev->netdev_ops->ndo_netpoll_cleanup)
+		slave_dev->netdev_ops->ndo_netpoll_cleanup(slave_dev);
+	else
+		slave_dev->npinfo = NULL;
+#endif
+
 	/* close slave before restoring its mac address */
 	dev_close(slave_dev);
 
@@ -4448,6 +4535,10 @@ static const struct net_device_ops bond_
 	.ndo_vlan_rx_register	= bond_vlan_rx_register,
 	.ndo_vlan_rx_add_vid 	= bond_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= bond_vlan_rx_kill_vid,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_netpoll_cleanup	= bond_netpoll_cleanup,
+	.ndo_poll_controller	= bond_poll_controller,
+#endif
 };
 
 static void bond_setup(struct net_device *bond_dev)
@@ -4533,6 +4624,8 @@ static void bond_uninit(struct net_devic
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 
+	bond_netpoll_cleanup(bond_dev);
+
 	/* Release the bonded slaves */
 	bond_release_all(bond_dev);
 
