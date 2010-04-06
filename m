From: Cong Wang <amwang@redhat.com>
Subject: Re: [v2 Patch 3/3] bonding: make bonding support netpoll
Date: Tue, 06 Apr 2010 12:38:16 +0800
Message-ID: <4BBABAB8.4010401@redhat.com>
References: <20100405091605.4890.31181.sendpatchset@localhost.localdomain> <20100405091628.4890.30541.sendpatchset@localhost.localdomain> <20100405194356.GA10488@gospo.rdu.redhat.com> <4BBA9FDB.4040909@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080408090506020501050800"
Cc: linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Andy Gospodarek <gospo@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jeff Moyer <jmoyer@redhat.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11092 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751068Ab0DFEgC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Apr 2010 00:36:02 -0400
In-Reply-To: <4BBA9FDB.4040909@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080408090506020501050800
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Cong Wang wrote:
> Before I try to reproduce it, could you please try to replace the 
> 'read_lock()'
> in slaves_support_netpoll() with 'read_lock_bh()'? (read_unlock() too) 
> Try if this helps.
> 

Confirmed. Please use the attached patch instead, for your testing.

Thanks!


--------------080408090506020501050800
Content-Type: text/x-patch;
 name="bonding-support-netpoll.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="bonding-support-netpoll.diff"

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
@@ -1329,6 +1341,61 @@ static void bond_detach_slave(struct bon
 	bond->slave_cnt--;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/*
+ * You must hold read lock of bond->lock before calling this.
+ */
+static bool slaves_support_netpoll(struct net_device *bond_dev)
+{
+	struct bonding *bond = netdev_priv(bond_dev);
+	struct slave *slave;
+	int i = 0;
+	bool ret = true;
+
+	bond_for_each_slave(bond, slave, i) {
+		if ((slave->dev->priv_flags & IFF_DISABLE_NETPOLL)
+				|| !slave->dev->netdev_ops->ndo_poll_controller)
+			ret = false;
+	}
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
@@ -1735,6 +1802,18 @@ int bond_enslave(struct net_device *bond
 
 	bond_set_carrier(bond);
 
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
 	read_unlock(&bond->lock);
 
 	res = bond_create_slave_symlinks(bond_dev, slave_dev);
@@ -1929,6 +2008,17 @@ int bond_release(struct net_device *bond
 
 	netdev_set_master(slave_dev, NULL);
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	read_lock_bh(&bond->lock);
+	if (slaves_support_netpoll(bond_dev))
+		bond_dev->priv_flags &= ~IFF_DISABLE_NETPOLL;
+	read_unlock_bh(&bond->lock);
+	if (slave_dev->netdev_ops->ndo_netpoll_cleanup)
+		slave_dev->netdev_ops->ndo_netpoll_cleanup(slave_dev);
+	else
+		slave_dev->npinfo = NULL;
+#endif
+
 	/* close slave before restoring its mac address */
 	dev_close(slave_dev);
 
@@ -4448,6 +4538,10 @@ static const struct net_device_ops bond_
 	.ndo_vlan_rx_register	= bond_vlan_rx_register,
 	.ndo_vlan_rx_add_vid 	= bond_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= bond_vlan_rx_kill_vid,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_netpoll_cleanup	= bond_netpoll_cleanup,
+	.ndo_poll_controller	= bond_poll_controller,
+#endif
 };
 
 static void bond_setup(struct net_device *bond_dev)
@@ -4533,6 +4627,8 @@ static void bond_uninit(struct net_devic
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 
+	bond_netpoll_cleanup(bond_dev);
+
 	/* Release the bonded slaves */
 	bond_release_all(bond_dev);
 

--------------080408090506020501050800--
