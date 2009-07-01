From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: Any implementation of NETPOLL for bonding?
Date: Tue, 30 Jun 2009 21:30:21 -0400
Message-ID: <20090701013021.GJ8515@gospo.rdu.redhat.com>
References: <1245101162.11148.210.camel@psmith-ubeta.netezza.com> <20090615230907.GA8515@gospo.rdu.redhat.com> <1245165201.11148.244.camel@psmith-ubeta.netezza.com> <1245776460.9022.19.camel@psmith-ubeta.netezza.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: Paul Smith <paul@mad-scientist.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:36123 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762055AbZGABfU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jun 2009 21:35:20 -0400
Content-Disposition: inline
In-Reply-To: <1245776460.9022.19.camel@psmith-ubeta.netezza.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 23, 2009 at 01:01:00PM -0400, Paul Smith wrote:
> On Tue, 2009-06-16 at 11:13 -0400, Paul Smith wrote:
> > On Mon, 2009-06-15 at 19:09 -0400, Andy Gospodarek wrote:
> > > On Mon, Jun 15, 2009 at 05:26:02PM -0400, Paul Smith wrote:
> > > > I wanted to attach to my kernel with KGDBOE but failed because the
> > > > bonding driver doesn't support NETPOLL, and the only network access to
> > > > the system is over a bonded interface.
> > > 
> > > I did some work in the not-too-distant past on this and can probably
> > > dig-up the patches and port them to the latest upstream.  Would you be
> > > able to test a patch?
> 
> Hi Andy; did you have any time to dig these out and forward them to me?
> I'm happy to test them for you.
> 
> Thanks!
> 

Paul,

I finally had some time to get this going again.  This is a patch
against a Linus' latest tree.

It's still a little rough around the edges, so you need to make sure you

(1) start netconsole after your bond has all the slaves it's going to have

and

(2) rmmod netconsole before doing any operations on the bond itself
(like taking it down or adding slaves).

I know what needs to be fixed, but I would rather see you get your
debugging going than hold up the patch to fix those quirks.  They
definitely need to be fixed before this is even close to something that
could be acceptable upstream, but at least we can work in parallel a
little bit.

-andy


diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index d927f71..6304720 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -75,6 +75,7 @@
 #include <linux/jiffies.h>
 #include <net/route.h>
 #include <net/net_namespace.h>
+#include <linux/netpoll.h>
 #include "bonding.h"
 #include "bond_3ad.h"
 #include "bond_alb.h"
@@ -415,7 +416,12 @@ int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb,
 	}
 
 	skb->priority = 1;
-	dev_queue_xmit(skb);
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	if (bond->netpoll)
+		netpoll_send_skb(bond->netpoll, skb);
+	else
+#endif
+		dev_queue_xmit(skb);
 
 	return 0;
 }
@@ -1305,6 +1311,44 @@ static void bond_detach_slave(struct bonding *bond, struct slave *slave)
 	bond->slave_cnt--;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static int slaves_support_netpoll(struct net_device *bond_dev)
+{
+	struct bonding *bond = netdev_priv(bond_dev);
+	struct slave *slave;
+	int i;
+
+	bond_for_each_slave(bond, slave, i)
+		if (!slave->dev->netdev_ops->ndo_poll_controller)
+			return 0;
+	return 1;
+}
+
+static void bond_poll_controller(struct net_device *bond_dev)
+{
+	struct bonding *bond = netdev_priv(bond_dev);
+	struct slave *slave;
+	int i;
+
+	if (slaves_support_netpoll(bond_dev))
+		bond_for_each_slave(bond, slave, i)
+			netpoll_poll_dev(slave->dev);
+}
+
+static int bond_netpoll_setup(struct net_device *bond_dev,
+			      struct netpoll_info *npinfo)
+{
+	struct bonding *bond = netdev_priv(bond_dev);
+	struct slave *slave;
+	int i;
+
+	bond_for_each_slave(bond, slave, i)
+		if (slave->dev)
+			slave->dev->npinfo = npinfo;
+	return 0;
+}
+#endif
+
 /*---------------------------------- IOCTL ----------------------------------*/
 
 static int bond_sethwaddr(struct net_device *bond_dev,
@@ -1670,6 +1714,16 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 			bond->primary_slave = new_slave;
 	}
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	if (slaves_support_netpoll(bond_dev))
+		slave_dev->npinfo = bond_dev->npinfo;
+	else {
+		pr_err(DRV_NAME "New slave device %s does not support netpoll.\n",
+		       slave_dev->name);
+		pr_err(DRV_NAME "netpoll disabled for %s.\n", bond_dev->name);
+	}
+#endif
+
 	write_lock_bh(&bond->curr_slave_lock);
 
 	switch (bond->params.mode) {
@@ -1741,6 +1795,10 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 
 /* Undo stages on error */
 err_close:
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	if (slave_dev->npinfo)
+		slave_dev->npinfo = NULL;
+#endif
 	dev_close(slave_dev);
 
 err_unset_master:
@@ -1949,6 +2007,10 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 				   IFF_SLAVE_INACTIVE | IFF_BONDING |
 				   IFF_SLAVE_NEEDARP);
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	if (slave_dev->npinfo)
+		slave_dev->npinfo = NULL;
+#endif
 	kfree(slave);
 
 	return 0;  /* deletion OK */
@@ -4417,6 +4479,20 @@ out:
 	return 0;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+int bond_netpoll_start_xmit(struct netpoll *np, struct sk_buff *skb)
+{
+	struct bonding *bond = netdev_priv(skb->dev);
+	int ret;
+
+	bond->netpoll = np;
+	ret = bond->dev->netdev_ops->ndo_start_xmit(skb, bond->dev);
+	bond->netpoll = NULL;
+
+	return ret;
+}
+#endif
+
 /*------------------------- Device initialization ---------------------------*/
 
 static void bond_set_xmit_hash_policy(struct bonding *bond)
@@ -4530,6 +4606,9 @@ static const struct net_device_ops bond_netdev_ops = {
 	.ndo_change_mtu		= bond_change_mtu,
 	.ndo_set_mac_address 	= bond_set_mac_address,
 	.ndo_neigh_setup	= bond_neigh_setup,
+	.ndo_netpoll_setup	= bond_netpoll_setup,
+	.ndo_netpoll_start_xmit	= bond_netpoll_start_xmit,
+	.ndo_poll_controller	= bond_poll_controller,
 	.ndo_vlan_rx_register	= bond_vlan_rx_register,
 	.ndo_vlan_rx_add_vid 	= bond_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= bond_vlan_rx_kill_vid,
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 6290a50..563d28c 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -18,6 +18,7 @@
 #include <linux/timer.h>
 #include <linux/proc_fs.h>
 #include <linux/if_bonding.h>
+#include <linux/netpoll.h>
 #include <linux/kobject.h>
 #include <linux/in6.h>
 #include "bond_3ad.h"
@@ -222,6 +223,10 @@ struct bonding {
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	struct   in6_addr master_ipv6;
 #endif
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	struct   netpoll *netpoll;
+#endif
+
 };
 
 /**
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d4a4d98..e1724b2 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -52,6 +52,7 @@
 
 struct vlan_group;
 struct netpoll_info;
+struct netpoll;
 /* 802.11 specific */
 struct wireless_dev;
 					/* source back-compat hooks */
@@ -624,6 +625,10 @@ struct net_device_ops {
 						        unsigned short vid);
 #ifdef CONFIG_NET_POLL_CONTROLLER
 #define HAVE_NETDEV_POLL
+	int                     (*ndo_netpoll_setup)(struct net_device *dev,
+						     struct netpoll_info *npinfo);
+	int			(*ndo_netpoll_start_xmit)(struct netpoll *np,
+							  struct sk_buff *skb);
 	void                    (*ndo_poll_controller)(struct net_device *dev);
 #endif
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index 2524267..39d42e4 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -34,7 +34,9 @@ struct netpoll_info {
 };
 
 void netpoll_poll(struct netpoll *np);
+void netpoll_poll_dev(struct net_device *dev);
 void netpoll_send_udp(struct netpoll *np, const char *msg, int len);
+void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb);
 void netpoll_print_options(struct netpoll *np);
 int netpoll_parse_options(struct netpoll *np, char *opt);
 int netpoll_setup(struct netpoll *np);
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 9675f31..3776b26 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -174,9 +174,8 @@ static void service_arp_queue(struct netpoll_info *npi)
 	}
 }
 
-void netpoll_poll(struct netpoll *np)
+void netpoll_poll_dev(struct net_device *dev)
 {
-	struct net_device *dev = np->dev;
 	const struct net_device_ops *ops;
 
 	if (!dev || !netif_running(dev))
@@ -196,6 +195,11 @@ void netpoll_poll(struct netpoll *np)
 	zap_completion_queue();
 }
 
+void netpoll_poll(struct netpoll *np)
+{
+	netpoll_poll_dev(np->dev);
+}
+
 static void refill_skbs(void)
 {
 	struct sk_buff *skb;
@@ -277,11 +281,11 @@ static int netpoll_owner_active(struct net_device *dev)
 	return 0;
 }
 
-static void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
+void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
 {
 	int status = NETDEV_TX_BUSY;
 	unsigned long tries;
-	struct net_device *dev = np->dev;
+	struct net_device *dev = skb->dev;
 	const struct net_device_ops *ops = dev->netdev_ops;
 	struct netpoll_info *npinfo = np->dev->npinfo;
 
@@ -303,7 +307,10 @@ static void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
 		     tries > 0; --tries) {
 			if (__netif_tx_trylock(txq)) {
 				if (!netif_tx_queue_stopped(txq)) {
-					status = ops->ndo_start_xmit(skb, dev);
+					if (ops->ndo_netpoll_start_xmit)
+						status = ops->ndo_netpoll_start_xmit(np,skb);
+					else
+						status = ops->ndo_start_xmit(skb, dev);
 					if (status == NETDEV_TX_OK)
 						txq_trans_update(txq);
 				}
@@ -789,6 +796,9 @@ int netpoll_setup(struct netpoll *np)
 	/* avoid racing with NAPI reading npinfo */
 	synchronize_rcu();
 
+	if (ndev->netdev_ops->ndo_netpoll_setup)
+		ndev->netdev_ops->ndo_netpoll_setup(ndev, npinfo);
+
 	return 0;
 
  release:
@@ -859,4 +869,6 @@ EXPORT_SYMBOL(netpoll_parse_options);
 EXPORT_SYMBOL(netpoll_setup);
 EXPORT_SYMBOL(netpoll_cleanup);
 EXPORT_SYMBOL(netpoll_send_udp);
+EXPORT_SYMBOL(netpoll_send_skb);
 EXPORT_SYMBOL(netpoll_poll);
+EXPORT_SYMBOL(netpoll_poll_dev);
