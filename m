From: Chris Wright <chrisw@osdl.org>
Subject: [PATCH] remove unused ethertap_mc support
Date: Fri, 18 Mar 2005 11:10:53 -0800
Message-ID: <20050318191053.GN5389@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

There is no Kconfig option to enable CONFIG_ETHERTAP_MC, and if you
could the resulting source would not build.  That code uses the obsolete
protinfo union, then further pokes into a privately defined netlink
structure to setup the groups.  Remove this broken code altogether.

Signed-off-by: Chris Wright <chrisw@osdl.org>

 drivers/net/ethertap.c |   84 -------------------------------------------------
 1 files changed, 84 deletions(-)

===== drivers/net/ethertap.c 1.16 vs edited =====
--- 1.16/drivers/net/ethertap.c	2005-02-16 06:40:17 -08:00
+++ edited/drivers/net/ethertap.c	2005-03-18 11:00:38 -08:00
@@ -38,9 +38,6 @@ static int  ethertap_start_xmit(struct s
 static int  ethertap_close(struct net_device *dev);
 static struct net_device_stats *ethertap_get_stats(struct net_device *dev);
 static void ethertap_rx(struct sock *sk, int len);
-#ifdef CONFIG_ETHERTAP_MC
-static void set_multicast_list(struct net_device *dev);
-#endif
 
 static int ethertap_debug;
 
@@ -57,9 +54,6 @@ static struct net_device **tap_map;	/* R
 struct net_local
 {
 	struct sock	*nl;
-#ifdef CONFIG_ETHERTAP_MC
-	__u32		groups;
-#endif
 	struct net_device_stats stats;
 };
 
@@ -96,9 +90,6 @@ static int  __init ethertap_probe(int un
 	dev->hard_start_xmit = ethertap_start_xmit;
 	dev->stop = ethertap_close;
 	dev->get_stats = ethertap_get_stats;
-#ifdef CONFIG_ETHERTAP_MC
-	dev->set_multicast_list = set_multicast_list;
-#endif
 
 	dev->tx_queue_len = 0;
 	dev->flags|=IFF_NOARP;
@@ -134,41 +125,6 @@ static int ethertap_open(struct net_devi
 	return 0;
 }
 
-#ifdef CONFIG_ETHERTAP_MC
-static unsigned ethertap_mc_hash(__u8 *dest)
-{
-	unsigned idx = 0;
-	idx ^= dest[0];
-	idx ^= dest[1];
-	idx ^= dest[2];
-	idx ^= dest[3];
-	idx ^= dest[4];
-	idx ^= dest[5];
-	return 1U << (idx&0x1F);
-}
-
-static void set_multicast_list(struct net_device *dev)
-{
-	unsigned groups = ~0;
-	struct net_local *lp = netdev_priv(dev);
-
-	if (!(dev->flags&(IFF_NOARP|IFF_PROMISC|IFF_ALLMULTI))) {
-		struct dev_mc_list *dmi;
-
-		groups = ethertap_mc_hash(dev->broadcast);
-
-		for (dmi=dev->mc_list; dmi; dmi=dmi->next) {
-			if (dmi->dmi_addrlen != 6)
-				continue;
-			groups |= ethertap_mc_hash(dmi->dmi_addr);
-		}
-	}
-	lp->groups = groups;
-	if (lp->nl)
-		lp->nl->protinfo.af_netlink.groups = groups;
-}
-#endif
-
 /*
  *	We transmit by throwing the packet at netlink. We have to clone
  *	it for 2.0 so that we dev_kfree_skb() the locked original.
@@ -177,9 +133,6 @@ static void set_multicast_list(struct ne
 static int ethertap_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct net_local *lp = netdev_priv(dev);
-#ifdef CONFIG_ETHERTAP_MC
-	struct ethhdr *eth = (struct ethhdr*)skb->data;
-#endif
 
 	if (skb_headroom(skb) < 2) {
 		static int once;
@@ -213,31 +166,13 @@ static int ethertap_start_xmit(struct sk
 	lp->stats.tx_bytes+=skb->len;
 	lp->stats.tx_packets++;
 
-#ifndef CONFIG_ETHERTAP_MC
 	netlink_broadcast(lp->nl, skb, 0, ~0, GFP_ATOMIC);
-#else
-	if (dev->flags&IFF_NOARP) {
-		netlink_broadcast(lp->nl, skb, 0, ~0, GFP_ATOMIC);
-		return 0;
-	}
-
-	if (!(eth->h_dest[0]&1)) {
-		/* Unicast packet */
-		__u32 pid;
-		memcpy(&pid, eth->h_dest+2, 4);
-		netlink_unicast(lp->nl, skb, ntohl(pid), MSG_DONTWAIT);
-	} else
-		netlink_broadcast(lp->nl, skb, 0, ethertap_mc_hash(eth->h_dest), GFP_ATOMIC);
-#endif
 	return 0;
 }
 
 static __inline__ int ethertap_rx_skb(struct sk_buff *skb, struct net_device *dev)
 {
 	struct net_local *lp = netdev_priv(dev);
-#ifdef CONFIG_ETHERTAP_MC
-	struct ethhdr *eth = (struct ethhdr*)(skb->data + 2);
-#endif
 	int len = skb->len;
 
 	if (len < 16) {
@@ -250,25 +185,6 @@ static __inline__ int ethertap_rx_skb(st
 		kfree_skb(skb);
 		return -EPERM;
 	}
-
-#ifdef CONFIG_ETHERTAP_MC
-	if (!(dev->flags&(IFF_NOARP|IFF_PROMISC))) {
-		int drop = 0;
-
-		if (eth->h_dest[0]&1) {
-			if (!(ethertap_mc_hash(eth->h_dest)&lp->groups))
-				drop = 1;
-		} else if (memcmp(eth->h_dest, dev->dev_addr, 6) != 0)
-			drop = 1;
-
-		if (drop) {
-			if (ethertap_debug > 3)
-				printk(KERN_DEBUG "%s : not for us\n", dev->name);
-			kfree_skb(skb);
-			return -EINVAL;
-		}
-	}
-#endif
 
 	if (skb_shared(skb)) {
 	  	struct sk_buff *skb2 = skb;
