From: Jeff Garzik <jgarzik@pobox.com>
Subject: [RFC,PATCH] fastroute dead code...
Date: Fri, 30 Jul 2004 02:03:48 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040730060348.GA22854@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, hadi@cyberus.ca
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


While investigating what the heck ->accept_fastpath hook does (I had no
specific idea), I found out...  it does nothing at all.  :)

In net/ipv4/route.c and nowhere else, ->accept_fastpath is called.  If
it returns zero, the bit RTCF_FAST is set.  RTCF_FAST is never tested
anywhere AFAICS, so that makes ->accept_fastpath dead code.

I created a test tree and removed all the code that was verifyably dead,
and the following is what I came up with.  The only reason why I did not
remove CONFIG_NET_FASTROUTE completely is because of the lone swatch of
code that remains from my pogrom, in net/core/dev.c (netif_receive_skb):

#ifdef CONFIG_NET_FASTROUTE
        if (skb->pkt_type == PACKET_FASTROUTE) {
                __get_cpu_var(netdev_rx_stat).fastroute_deferred_out++;
                return dev_queue_xmit(skb);
        }
#endif

This actually does something, dependent upon options from the packet
socket, so I left it alone.  The rest was dead code.

If nobody objects I can push to David, but right now this is more
an RFC than a merge request for David.


BK repo:

	bk pull bk://kernel.bkbits.net/jgarzik/net-2.6

This will update the following files:

 arch/ia64/hp/sim/simeth.c       |    9 -----
 drivers/net/bonding/bond_main.c |   10 -----
 drivers/net/dummy.c             |   10 -----
 include/linux/in_route.h        |    1 
 include/linux/netdevice.h       |   12 ------
 net/bridge/br_device.c          |    6 ---
 net/core/dev.c                  |   70 ----------------------------------------
 net/core/sysctl_net_core.c      |   10 -----
 net/ipv4/route.c                |   11 ------
 9 files changed, 139 deletions(-)

through these ChangeSets:

<jgarzik@pobox.com> (04/07/30 1.1914)
   [NET] remove more fastroute-related remnants
   
   Remove more code and data structures that are no longer used, now that
   other fastroute-related code is gone.

<jgarzik@pobox.com> (04/07/30 1.1913)
   [NET] remove net_device ->accept_fastpath hook
   
   Since its only user is gone, and didn't work anyway, we may now remove
   the ->accept_fastpath callback in struct net_device.
   
   This also allows removal of dev_clear_fastroute(), which required
   accept_fastpath presence (but never called it).

<jgarzik@pobox.com> (04/07/30 1.1912)
   [NET] remove unused RTCF_FAST definition, and the code that sets it
   
   In one case that no one cared about, this bit would be set.  But, that
   bit was never used.

diff -Nru a/arch/ia64/hp/sim/simeth.c b/arch/ia64/hp/sim/simeth.c
--- a/arch/ia64/hp/sim/simeth.c	2004-07-30 01:55:49 -04:00
+++ b/arch/ia64/hp/sim/simeth.c	2004-07-30 01:55:49 -04:00
@@ -527,13 +527,4 @@
 	printk(KERN_WARNING "%s: set_multicast_list called\n", dev->name);
 }
 
-#ifdef CONFIG_NET_FASTROUTE
-static int
-simeth_accept_fastpath(struct net_device *dev, struct dst_entry *dst)
-{
-	printk(KERN_WARNING "%s: simeth_accept_fastpath called\n", dev->name);
-	return -1;
-}
-#endif
-
 __initcall(simeth_probe);
diff -Nru a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	2004-07-30 01:55:49 -04:00
+++ b/drivers/net/bonding/bond_main.c	2004-07-30 01:55:49 -04:00
@@ -4214,13 +4214,6 @@
 	return 0;
 }
 
-#ifdef CONFIG_NET_FASTROUTE
-static int bond_accept_fastpath(struct net_device *bond_dev, struct dst_entry *dst)
-{
-	return -1;
-}
-#endif
-
 /*------------------------- Device initialization ---------------------------*/
 
 /*
@@ -4294,9 +4287,6 @@
 	bond_set_mode_ops(bond_dev, bond->params.mode);
 
 	bond_dev->destructor = free_netdev;
-#ifdef CONFIG_NET_FASTROUTE
-	bond_dev->accept_fastpath = bond_accept_fastpath;
-#endif
 
 	/* Initialize the device options */
 	bond_dev->tx_queue_len = 0;
diff -Nru a/drivers/net/dummy.c b/drivers/net/dummy.c
--- a/drivers/net/dummy.c	2004-07-30 01:55:49 -04:00
+++ b/drivers/net/dummy.c	2004-07-30 01:55:49 -04:00
@@ -57,13 +57,6 @@
 {
 }
 
-#ifdef CONFIG_NET_FASTROUTE
-static int dummy_accept_fastpath(struct net_device *dev, struct dst_entry *dst)
-{
-	return -1;
-}
-#endif
-
 static void __init dummy_setup(struct net_device *dev)
 {
 	/* Initialize the device structure. */
@@ -71,9 +64,6 @@
 	dev->hard_start_xmit = dummy_xmit;
 	dev->set_multicast_list = set_multicast_list;
 	dev->set_mac_address = dummy_set_address;
-#ifdef CONFIG_NET_FASTROUTE
-	dev->accept_fastpath = dummy_accept_fastpath;
-#endif
 
 	/* Fill in device structure with ethernet-generic values. */
 	ether_setup(dev);
diff -Nru a/include/linux/in_route.h b/include/linux/in_route.h
--- a/include/linux/in_route.h	2004-07-30 01:55:49 -04:00
+++ b/include/linux/in_route.h	2004-07-30 01:55:49 -04:00
@@ -14,7 +14,6 @@
 #define RTCF_REDIRECTED	0x00040000
 #define RTCF_TPROXY	0x00080000
 
-#define RTCF_FAST	0x00200000
 #define RTCF_MASQ	0x00400000
 #define RTCF_SNAT	0x00800000
 #define RTCF_DOREDIRECT 0x01000000
diff -Nru a/include/linux/netdevice.h b/include/linux/netdevice.h
--- a/include/linux/netdevice.h	2004-07-30 01:55:49 -04:00
+++ b/include/linux/netdevice.h	2004-07-30 01:55:49 -04:00
@@ -461,7 +461,6 @@
 	int			(*hard_header_parse)(struct sk_buff *skb,
 						     unsigned char *haddr);
 	int			(*neigh_setup)(struct net_device *dev, struct neigh_parms *);
-	int			(*accept_fastpath)(struct net_device *, struct dst_entry*);
 #ifdef CONFIG_NETPOLL_RX
 	int			netpoll_rx;
 #endif
@@ -472,12 +471,6 @@
 	/* bridge stuff */
 	struct net_bridge_port	*br_port;
 
-#ifdef CONFIG_NET_FASTROUTE
-#define NETDEV_FASTROUTE_HMASK 0xF
-	/* Semi-private data. Keep it at the end of device struct. */
-	rwlock_t		fastpath_lock;
-	struct dst_entry	*fastpath[NETDEV_FASTROUTE_HMASK+1];
-#endif
 #ifdef CONFIG_NET_DIVERT
 	/* this will get initialized at each interface type init routine */
 	struct divert_blk	*divert;
@@ -947,11 +940,6 @@
 extern atomic_t netdev_dropping;
 extern int		netdev_set_master(struct net_device *dev, struct net_device *master);
 extern int skb_checksum_help(struct sk_buff **pskb, int inward);
-#ifdef CONFIG_NET_FASTROUTE
-extern int		netdev_fastroute;
-extern int		netdev_fastroute_obstacles;
-extern void		dev_clear_fastroute(struct net_device *dev);
-#endif
 
 #ifdef CONFIG_SYSCTL
 extern char *net_sysctl_strdup(const char *s);
diff -Nru a/net/bridge/br_device.c b/net/bridge/br_device.c
--- a/net/bridge/br_device.c	2004-07-30 01:55:49 -04:00
+++ b/net/bridge/br_device.c	2004-07-30 01:55:49 -04:00
@@ -98,11 +98,6 @@
 	return 0;
 }
 
-static int br_dev_accept_fastpath(struct net_device *dev, struct dst_entry *dst)
-{
-	return -1;
-}
-
 void br_dev_setup(struct net_device *dev)
 {
 	memset(dev->dev_addr, 0, ETH_ALEN);
@@ -118,7 +113,6 @@
 	dev->destructor = free_netdev;
 	SET_MODULE_OWNER(dev);
 	dev->stop = br_dev_stop;
-	dev->accept_fastpath = br_dev_accept_fastpath;
 	dev->tx_queue_len = 0;
 	dev->set_mac_address = NULL;
 	dev->priv_flags = IFF_EBRIDGE;
diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	2004-07-30 01:55:49 -04:00
+++ b/net/core/dev.c	2004-07-30 01:55:49 -04:00
@@ -216,11 +216,6 @@
  */
 DEFINE_PER_CPU(struct softnet_data, softnet_data) = { 0, };
 
-#ifdef CONFIG_NET_FASTROUTE
-int netdev_fastroute;
-int netdev_fastroute_obstacles;
-#endif
-
 #ifdef CONFIG_SYSFS
 extern int netdev_sysfs_init(void);
 extern int netdev_register_sysfs(struct net_device *);
@@ -278,12 +273,6 @@
 	int hash;
 
 	spin_lock_bh(&ptype_lock);
-#ifdef CONFIG_NET_FASTROUTE
-	if (pt->af_packet_priv) {
-		netdev_fastroute_obstacles++;
-		dev_clear_fastroute(pt->dev);
-	}
-#endif
 	if (pt->type == htons(ETH_P_ALL)) {
 		netdev_nit++;
 		list_add_rcu(&pt->list, &ptype_all);
@@ -326,10 +315,6 @@
 
 	list_for_each_entry(pt1, head, list) {
 		if (pt == pt1) {
-#ifdef CONFIG_NET_FASTROUTE
-			if (pt->af_packet_priv)
-				netdev_fastroute_obstacles--;
-#endif
 			list_del_rcu(&pt->list);
 			goto out;
 		}
@@ -971,39 +956,6 @@
 	return ret;
 }
 
-#ifdef CONFIG_NET_FASTROUTE
-
-static void dev_do_clear_fastroute(struct net_device *dev)
-{
-	if (dev->accept_fastpath) {
-		int i;
-
-		for (i = 0; i <= NETDEV_FASTROUTE_HMASK; i++) {
-			struct dst_entry *dst;
-
-			write_lock_irq(&dev->fastpath_lock);
-			dst = dev->fastpath[i];
-			dev->fastpath[i] = NULL;
-			write_unlock_irq(&dev->fastpath_lock);
-
-			dst_release(dst);
-		}
-	}
-}
-
-void dev_clear_fastroute(struct net_device *dev)
-{
-	if (dev) {
-		dev_do_clear_fastroute(dev);
-	} else {
-		read_lock(&dev_base_lock);
-		for (dev = dev_base; dev; dev = dev->next)
-			dev_do_clear_fastroute(dev);
-		read_unlock(&dev_base_lock);
-	}
-}
-#endif
-
 /**
  *	dev_close - shutdown an interface.
  *	@dev: device to shutdown
@@ -1056,9 +1008,6 @@
 	 */
 
 	dev->flags &= ~IFF_UP;
-#ifdef CONFIG_NET_FASTROUTE
-	dev_clear_fastroute(dev);
-#endif
 
 	/*
 	 * Tell people we are down
@@ -2366,13 +2315,6 @@
 	if ((dev->promiscuity += inc) == 0)
 		dev->flags &= ~IFF_PROMISC;
 	if (dev->flags ^ old_flags) {
-#ifdef CONFIG_NET_FASTROUTE
-		if (dev->flags & IFF_PROMISC) {
-			netdev_fastroute_obstacles++;
-			dev_clear_fastroute(dev);
-		} else
-			netdev_fastroute_obstacles--;
-#endif
 		dev_mc_upload(dev);
 		printk(KERN_INFO "device %s %s promiscuous mode\n",
 		       dev->name, (dev->flags & IFF_PROMISC) ? "entered" :
@@ -2925,10 +2867,6 @@
 	spin_lock_init(&dev->ingress_lock);
 #endif
 
-#ifdef CONFIG_NET_FASTROUTE
-	dev->fastpath_lock = RW_LOCK_UNLOCKED;
-#endif
-
 	ret = alloc_divert_blk(dev);
 	if (ret)
 		goto out;
@@ -3249,10 +3187,6 @@
 
 	synchronize_net();
 
-#ifdef CONFIG_NET_FASTROUTE
-	dev_clear_fastroute(dev);
-#endif
-
 	/* Shutdown queueing discipline. */
 	dev_shutdown(dev);
 
@@ -3455,10 +3389,6 @@
 EXPORT_SYMBOL(netdev_fc_xoff);
 EXPORT_SYMBOL(netdev_register_fc);
 EXPORT_SYMBOL(netdev_unregister_fc);
-#endif
-#ifdef CONFIG_NET_FASTROUTE
-EXPORT_SYMBOL(netdev_fastroute);
-EXPORT_SYMBOL(netdev_fastroute_obstacles);
 #endif
 
 #ifdef CONFIG_NET_CLS_ACT
diff -Nru a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
--- a/net/core/sysctl_net_core.c	2004-07-30 01:55:49 -04:00
+++ b/net/core/sysctl_net_core.c	2004-07-30 01:55:49 -04:00
@@ -130,16 +130,6 @@
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec
 	},
-#ifdef CONFIG_NET_FASTROUTE
-	{
-		.ctl_name	= NET_CORE_FASTROUTE,
-		.procname	= "netdev_fastroute",
-		.data		= &netdev_fastroute,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
-	},
-#endif
 	{
 		.ctl_name	= NET_CORE_MSG_COST,
 		.procname	= "message_cost",
diff -Nru a/net/ipv4/route.c b/net/ipv4/route.c
--- a/net/ipv4/route.c	2004-07-30 01:55:49 -04:00
+++ b/net/ipv4/route.c	2004-07-30 01:55:49 -04:00
@@ -1729,17 +1729,6 @@
 
 	rth->rt_flags = flags;
 
-#ifdef CONFIG_NET_FASTROUTE
-	if (netdev_fastroute && !(flags&(RTCF_NAT|RTCF_MASQ|RTCF_DOREDIRECT))) {
-		struct net_device *odev = rth->u.dst.dev;
-		if (odev != dev &&
-		    dev->accept_fastpath &&
-		    odev->mtu >= dev->mtu &&
-		    dev->accept_fastpath(dev, &rth->u.dst) == 0)
-			rth->rt_flags |= RTCF_FAST;
-	}
-#endif
-
 intern:
 	err = rt_intern_hash(hash, rth, (struct rtable**)&skb->dst);
 done:
