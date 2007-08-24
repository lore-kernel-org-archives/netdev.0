From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 3/3] net: move hardware header operations out of netdevice
Date: Fri, 24 Aug 2007 13:43:13 -0700
Message-ID: <20070824204533.142248486@linux-foundation.org>
References: <20070824204310.388073598@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:58959 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756256AbXHXUsy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2007 16:48:54 -0400
Content-Disposition: inline; filename=hh_cache.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since hardware header operations are part of the protocol class
not the device instance, make them into a separate object and
save memory.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/drivers/net/loopback.c	2007-08-24 13:41:02.000000000 -0700
+++ b/drivers/net/loopback.c	2007-08-24 13:41:16.000000000 -0700
@@ -208,14 +208,11 @@ struct net_device loopback_dev =3D {
 	.get_stats		=3D &get_stats,
 	.mtu			=3D (16 * 1024) + 20 + 20 + 12,
 	.hard_start_xmit	=3D loopback_xmit,
-	.hard_header		=3D eth_header,
-	.hard_header_cache	=3D eth_header_cache,
-	.header_cache_update	=3D eth_header_cache_update,
-	.hard_header_len	=3D ETH_HLEN,	/* 14	*/
+
 	.addr_len		=3D ETH_ALEN,	/* 6	*/
 	.tx_queue_len		=3D 0,
 	.type			=3D ARPHRD_LOOPBACK,	/* 0x0001*/
-	.rebuild_header		=3D eth_rebuild_header,
+
 	.flags			=3D IFF_LOOPBACK,
 	.features 		=3D NETIF_F_SG | NETIF_F_FRAGLIST
 #ifdef LOOPBACK_TSO
@@ -223,7 +220,9 @@ struct net_device loopback_dev =3D {
 #endif
 				  | NETIF_F_NO_CSUM | NETIF_F_HIGHDMA
 				  | NETIF_F_LLTX,
+
 	.ethtool_ops		=3D &loopback_ethtool_ops,
+	.header_ops		=3D &eth_header_ops,
 };
=20
 /* Setup and register the loopback device. */
--- a/include/linux/etherdevice.h	2007-08-24 13:41:02.000000000 -0700
+++ b/include/linux/etherdevice.h	2007-08-24 13:41:16.000000000 -0700
@@ -29,15 +29,19 @@
 #include <linux/random.h>
=20
 #ifdef __KERNEL__
-extern int		eth_header(struct sk_buff *skb, struct net_device *dev,
-				   unsigned short type, void *daddr,
-				   void *saddr, unsigned len);
-extern int		eth_rebuild_header(struct sk_buff *skb);
 extern __be16		eth_type_trans(struct sk_buff *skb, struct net_device *=
dev);
-extern void		eth_header_cache_update(struct hh_cache *hh, struct net_d=
evice *dev,
-						unsigned char * haddr);
-extern int		eth_header_cache(struct neighbour *neigh,
-					 struct hh_cache *hh);
+extern const struct header_ops eth_header_ops;
+
+extern int eth_header(struct sk_buff *skb, struct net_device *dev,
+		      unsigned short type,
+		      const void *daddr, const void *saddr, unsigned len);
+extern int eth_rebuild_header(struct sk_buff *skb);
+extern int eth_header_parse(const struct sk_buff *skb, unsigned char *=
haddr);
+extern int eth_header_cache(const struct neighbour *neigh, struct hh_c=
ache *hh);
+extern void eth_header_cache_update(struct hh_cache *hh,
+				    const struct net_device *dev,
+				    const unsigned char *haddr);
+
=20
 extern struct net_device *alloc_etherdev_mq(int sizeof_priv, unsigned =
int queue_count);
 #define alloc_etherdev(sizeof_priv) alloc_etherdev_mq(sizeof_priv, 1)
--- a/include/linux/netdevice.h	2007-08-24 13:41:15.000000000 -0700
+++ b/include/linux/netdevice.h	2007-08-24 13:41:16.000000000 -0700
@@ -248,6 +248,19 @@ struct hh_cache
 #define LL_RESERVED_SPACE_EXTRA(dev,extra) \
 	((((dev)->hard_header_len+extra)&~(HH_DATA_MOD - 1)) + HH_DATA_MOD)
=20
+struct header_ops {
+	int	(*create) (struct sk_buff *skb, struct net_device *dev,
+			   unsigned short type, const void *daddr,
+			   const void *saddr, unsigned len);
+	int	(*parse)(const struct sk_buff *skb, unsigned char *haddr);
+	int	(*rebuild)(struct sk_buff *skb);
+#define HAVE_HEADER_CACHE
+	int	(*cache)(const struct neighbour *neigh, struct hh_cache *hh);
+	void	(*cache_update)(struct hh_cache *hh,
+				const struct net_device *dev,
+				const unsigned char *haddr);
+};
+
 /* These flag bits are private to the generic network queueing
  * layer, they may not be explicitly referenced by any other
  * code.
@@ -474,6 +487,9 @@ struct net_device
 #endif
 	const struct ethtool_ops *ethtool_ops;
=20
+	/* Hardware header description */
+	const struct header_ops *header_ops;
+
 	/*
 	 * This marks the end of the "visible" part of the structure. All
 	 * fields hereafter are internal to the system, and may change at
@@ -597,13 +613,6 @@ struct net_device
 	int			(*open)(struct net_device *dev);
 	int			(*stop)(struct net_device *dev);
 #define HAVE_NETDEV_POLL
-	int			(*hard_header) (struct sk_buff *skb,
-						struct net_device *dev,
-						unsigned short type,
-						void *daddr,
-						void *saddr,
-						unsigned len);
-	int			(*rebuild_header)(struct sk_buff *skb);
 #define HAVE_CHANGE_RX_FLAGS
 	void			(*change_rx_flags)(struct net_device *dev,
 						   int flags);
@@ -620,12 +629,6 @@ struct net_device
 #define HAVE_SET_CONFIG
 	int			(*set_config)(struct net_device *dev,
 					      struct ifmap *map);
-#define HAVE_HEADER_CACHE
-	int			(*hard_header_cache)(struct neighbour *neigh,
-						     struct hh_cache *hh);
-	void			(*header_cache_update)(struct hh_cache *hh,
-						       struct net_device *dev,
-						       unsigned char *  haddr);
 #define HAVE_CHANGE_MTU
 	int			(*change_mtu)(struct net_device *dev, int new_mtu);
=20
@@ -639,8 +642,6 @@ struct net_device
 	void			(*vlan_rx_kill_vid)(struct net_device *dev,
 						    unsigned short vid);
=20
-	int			(*hard_header_parse)(const struct sk_buff *skb,
-						     unsigned char *haddr);
 	int			(*neigh_setup)(struct net_device *dev, struct neigh_parms *);
 #ifdef CONFIG_NETPOLL
 	struct netpoll_info	*npinfo;
@@ -780,11 +781,13 @@ extern int		netpoll_trap(void);
=20
 static inline int dev_hard_header(struct sk_buff *skb, struct net_devi=
ce *dev,
 				  unsigned short type,
-				  void *daddr, void *saddr, unsigned len)
+				  const void *daddr, const void *saddr,
+				  unsigned len)
 {
-	if (!dev->hard_header)
+	if (!dev->header_ops)
 		return 0;
-	return dev->hard_header(skb, dev, type, daddr, saddr, len);
+
+	return dev->header_ops->create(skb, dev, type, daddr, saddr, len);
 }
=20
 static inline int dev_parse_header(const struct sk_buff *skb,
@@ -792,9 +795,9 @@ static inline int dev_parse_header(const
 {
 	const struct net_device *dev =3D skb->dev;
=20
-	if (!dev->hard_header_parse)
+	if (!dev->header_ops->parse)
 		return 0;
-	return dev->hard_header_parse(skb, haddr);
+	return dev->header_ops->parse(skb, haddr);
 }
=20
 typedef int gifconf_func_t(struct net_device * dev, char __user * bufp=
tr, int len);
--- a/include/net/pkt_sched.h	2007-08-24 13:41:02.000000000 -0700
+++ b/include/net/pkt_sched.h	2007-08-24 13:41:17.000000000 -0700
@@ -97,10 +97,9 @@ extern int tc_classify(struct sk_buff *s
 /* Calculate maximal size of packet seen by hard_start_xmit
    routine of this device.
  */
-static inline unsigned psched_mtu(struct net_device *dev)
+static inline unsigned psched_mtu(const struct net_device *dev)
 {
-	unsigned mtu =3D dev->mtu;
-	return dev->hard_header ? mtu + dev->hard_header_len : mtu;
+	return dev->mtu + dev->hard_header_len;
 }
=20
 #endif
--- a/net/core/dev.c	2007-08-24 13:41:02.000000000 -0700
+++ b/net/core/dev.c	2007-08-24 13:41:17.000000000 -0700
@@ -919,14 +919,6 @@ void dev_load(const char *name)
 		request_module("%s", name);
 }
=20
-static int default_rebuild_header(struct sk_buff *skb)
-{
-	printk(KERN_DEBUG "%s: default_rebuild_header called -- BUG!\n",
-	       skb->dev ? skb->dev->name : "NULL!!!");
-	kfree_skb(skb);
-	return 1;
-}
-
 /**
  *	dev_open	- prepare an interface for use.
  *	@dev:	device to open
@@ -3460,14 +3452,6 @@ int register_netdevice(struct net_device
 		}
 	}
=20
-	/*
-	 *	nil rebuild_header routine,
-	 *	that should be never called and used as just bug trap.
-	 */
-
-	if (!dev->rebuild_header)
-		dev->rebuild_header =3D default_rebuild_header;
-
 	ret =3D netdev_register_sysfs(dev);
 	if (ret)
 		goto err_uninit;
--- a/net/core/neighbour.c	2007-08-24 13:41:14.000000000 -0700
+++ b/net/core/neighbour.c	2007-08-24 13:41:17.000000000 -0700
@@ -895,8 +895,8 @@ out_unlock_bh:
 static void neigh_update_hhs(struct neighbour *neigh)
 {
 	struct hh_cache *hh;
-	void (*update)(struct hh_cache*, struct net_device*, unsigned char *)=
 =3D
-		neigh->dev->header_cache_update;
+	void (*update)(struct hh_cache*, const struct net_device*, const unsi=
gned char *)
+		=3D neigh->dev->header_ops->cache_update;
=20
 	if (update) {
 		for (hh =3D neigh->hh; hh; hh =3D hh->hh_next) {
@@ -1093,7 +1093,8 @@ static void neigh_hh_init(struct neighbo
 		hh->hh_type =3D protocol;
 		atomic_set(&hh->hh_refcnt, 0);
 		hh->hh_next =3D NULL;
-		if (dev->hard_header_cache(n, hh)) {
+
+		if (dev->header_ops->cache(n, hh)) {
 			kfree(hh);
 			hh =3D NULL;
 		} else {
@@ -1125,7 +1126,7 @@ int neigh_compat_output(struct sk_buff *
=20
 	if (dev_hard_header(skb, dev, ntohs(skb->protocol), NULL, NULL,
 			    skb->len) < 0 &&
-	    dev->rebuild_header(skb))
+	    dev->header_ops->rebuild(skb))
 		return 0;
=20
 	return dev_queue_xmit(skb);
@@ -1147,7 +1148,7 @@ int neigh_resolve_output(struct sk_buff=20
 	if (!neigh_event_send(neigh, skb)) {
 		int err;
 		struct net_device *dev =3D neigh->dev;
-		if (dev->hard_header_cache && !dst->hh) {
+		if (dev->header_ops->cache && !dst->hh) {
 			write_lock_bh(&neigh->lock);
 			if (!dst->hh)
 				neigh_hh_init(neigh, dst, dst->ops->protocol);
--- a/net/ethernet/eth.c	2007-08-24 13:41:15.000000000 -0700
+++ b/net/ethernet/eth.c	2007-08-24 13:41:53.000000000 -0700
@@ -75,8 +75,9 @@ __setup("ether=3D", netdev_boot_setup);
  * Set the protocol type. For a packet of type ETH_P_802_3 we put the =
length
  * in here instead. It is up to the 802.2 layer to carry protocol info=
rmation.
  */
-int eth_header(struct sk_buff *skb, struct net_device *dev, unsigned s=
hort type,
-	       void *daddr, void *saddr, unsigned len)
+int eth_header(struct sk_buff *skb, struct net_device *dev,
+	       unsigned short type,
+	       const void *daddr, const void *saddr, unsigned len)
 {
 	struct ethhdr *eth =3D (struct ethhdr *)skb_push(skb, ETH_HLEN);
=20
@@ -109,6 +110,7 @@ int eth_header(struct sk_buff *skb, stru
=20
 	return -ETH_HLEN;
 }
+EXPORT_SYMBOL(eth_header);
=20
 /**
  * eth_rebuild_header- rebuild the Ethernet MAC header.
@@ -141,6 +143,7 @@ int eth_rebuild_header(struct sk_buff *s
=20
 	return 0;
 }
+EXPORT_SYMBOL(eth_rebuild_header);
=20
 /**
  * eth_type_trans - determine the packet's protocol ID.
@@ -207,12 +210,13 @@ EXPORT_SYMBOL(eth_type_trans);
  * @skb: packet to extract header from
  * @haddr: destination buffer
  */
-static int eth_header_parse(const struct sk_buff *skb, unsigned char *=
haddr)
+int eth_header_parse(const struct sk_buff *skb, unsigned char *haddr)
 {
 	const struct ethhdr *eth =3D eth_hdr(skb);
 	memcpy(haddr, eth->h_source, ETH_ALEN);
 	return ETH_ALEN;
 }
+EXPORT_SYMBOL(eth_header_parse);
=20
 /**
  * eth_header_cache - fill cache entry from neighbour
@@ -220,11 +224,11 @@ static int eth_header_parse(const struct
  * @hh: destination cache entry
  * Create an Ethernet header template from the neighbour.
  */
-int eth_header_cache(struct neighbour *neigh, struct hh_cache *hh)
+int eth_header_cache(const struct neighbour *neigh, struct hh_cache *h=
h)
 {
 	__be16 type =3D hh->hh_type;
 	struct ethhdr *eth;
-	struct net_device *dev =3D neigh->dev;
+	const struct net_device *dev =3D neigh->dev;
=20
 	eth =3D (struct ethhdr *)
 	    (((u8 *) hh->hh_data) + (HH_DATA_OFF(sizeof(*eth))));
@@ -238,6 +242,7 @@ int eth_header_cache(struct neighbour *n
 	hh->hh_len =3D ETH_HLEN;
 	return 0;
 }
+EXPORT_SYMBOL(eth_header_cache);
=20
 /**
  * eth_header_cache_update - update cache entry
@@ -247,12 +252,14 @@ int eth_header_cache(struct neighbour *n
  *
  * Called by Address Resolution module to notify changes in address.
  */
-void eth_header_cache_update(struct hh_cache *hh, struct net_device *d=
ev,
-			     unsigned char *haddr)
+void eth_header_cache_update(struct hh_cache *hh,
+			     const struct net_device *dev,
+			     const unsigned char *haddr)
 {
 	memcpy(((u8 *) hh->hh_data) + HH_DATA_OFF(sizeof(struct ethhdr)),
 	       haddr, dev->addr_len);
 }
+EXPORT_SYMBOL(eth_header_cache_update);
=20
 /**
  * eth_mac_addr - set new Ethernet hardware address
@@ -291,6 +298,14 @@ static int eth_change_mtu(struct net_dev
 	return 0;
 }
=20
+const struct header_ops eth_header_ops ____cacheline_aligned =3D {
+	.create		=3D eth_header,
+	.parse		=3D eth_header_parse,
+	.rebuild	=3D eth_rebuild_header,
+	.cache		=3D eth_header_cache,
+	.cache_update	=3D eth_header_cache_update,
+};
+
 /**
  * ether_setup - setup Ethernet network device
  * @dev: network device
@@ -298,13 +313,10 @@ static int eth_change_mtu(struct net_dev
  */
 void ether_setup(struct net_device *dev)
 {
+	dev->header_ops		=3D &eth_header_ops;
+
 	dev->change_mtu		=3D eth_change_mtu;
-	dev->hard_header	=3D eth_header;
-	dev->rebuild_header 	=3D eth_rebuild_header;
 	dev->set_mac_address 	=3D eth_mac_addr;
-	dev->hard_header_cache	=3D eth_header_cache;
-	dev->header_cache_update=3D eth_header_cache_update;
-	dev->hard_header_parse	=3D eth_header_parse;
=20
 	dev->type		=3D ARPHRD_ETHER;
 	dev->hard_header_len 	=3D ETH_HLEN;
--- a/net/ipv4/arp.c	2007-08-24 13:41:14.000000000 -0700
+++ b/net/ipv4/arp.c	2007-08-24 13:41:17.000000000 -0700
@@ -252,7 +252,7 @@ static int arp_constructor(struct neighb
 	neigh->parms =3D neigh_parms_clone(parms);
 	rcu_read_unlock();
=20
-	if (dev->hard_header =3D=3D NULL) {
+	if (!dev->header_ops) {
 		neigh->nud_state =3D NUD_NOARP;
 		neigh->ops =3D &arp_direct_ops;
 		neigh->output =3D neigh->ops->queue_xmit;
@@ -309,10 +309,12 @@ static int arp_constructor(struct neighb
 			neigh->nud_state =3D NUD_NOARP;
 			memcpy(neigh->ha, dev->broadcast, dev->addr_len);
 		}
-		if (dev->hard_header_cache)
+
+		if (dev->header_ops->cache)
 			neigh->ops =3D &arp_hh_ops;
 		else
 			neigh->ops =3D &arp_generic_ops;
+
 		if (neigh->nud_state&NUD_VALID)
 			neigh->output =3D neigh->ops->connected_output;
 		else
--- a/include/linux/if_ether.h	2007-08-24 13:41:02.000000000 -0700
+++ b/include/linux/if_ether.h	2007-08-24 13:41:17.000000000 -0700
@@ -117,6 +117,8 @@ static inline struct ethhdr *eth_hdr(con
 	return (struct ethhdr *)skb_mac_header(skb);
 }
=20
+int eth_header_parse(const struct sk_buff *skb, unsigned char *haddr);
+
 #ifdef CONFIG_SYSCTL
 extern struct ctl_table ether_table[];
 #endif
--- a/net/802/fc.c	2007-08-24 13:41:02.000000000 -0700
+++ b/net/802/fc.c	2007-08-24 13:41:17.000000000 -0700
@@ -35,7 +35,7 @@
=20
 static int fc_header(struct sk_buff *skb, struct net_device *dev,
 		     unsigned short type,
-		     void *daddr, void *saddr, unsigned len)
+		     const void *daddr, const void *saddr, unsigned len)
 {
 	struct fch_hdr *fch;
 	int hdr_len;
@@ -95,11 +95,14 @@ static int fc_rebuild_header(struct sk_b
 #endif
 }
=20
+static const struct header_ops fc_header_ops =3D {
+	.create	 =3D fc_header,
+	.rebuild =3D fc_rebuild_header,
+};
+
 static void fc_setup(struct net_device *dev)
 {
-	dev->hard_header	=3D fc_header;
-	dev->rebuild_header	=3D fc_rebuild_header;
-
+	dev->header_ops		=3D &fc_header_ops;
 	dev->type		=3D ARPHRD_IEEE802;
 	dev->hard_header_len	=3D FC_HLEN;
 	dev->mtu		=3D 2024;
--- a/net/802/fddi.c	2007-08-24 13:41:02.000000000 -0700
+++ b/net/802/fddi.c	2007-08-24 13:41:17.000000000 -0700
@@ -52,7 +52,7 @@
=20
 static int fddi_header(struct sk_buff *skb, struct net_device *dev,
 		       unsigned short type,
-		       void *daddr, void *saddr, unsigned len)
+		       const void *daddr, const void *saddr, unsigned len)
 {
 	int hl =3D FDDI_K_SNAP_HLEN;
 	struct fddihdr *fddi;
@@ -175,11 +175,15 @@ static int fddi_change_mtu(struct net_de
 	return(0);
 }
=20
+static const struct header_ops fddi_header_ops =3D {
+	.create		=3D fddi_header,
+	.rebuild	=3D fddi_rebuild_header,
+};
+
 static void fddi_setup(struct net_device *dev)
 {
 	dev->change_mtu		=3D fddi_change_mtu;
-	dev->hard_header	=3D fddi_header;
-	dev->rebuild_header	=3D fddi_rebuild_header;
+	dev->header_ops		=3D &fddi_header_ops;
=20
 	dev->type		=3D ARPHRD_FDDI;
 	dev->hard_header_len	=3D FDDI_K_SNAP_HLEN+3;	/* Assume 802.2 SNAP hdr=
 len + 3 pad bytes */
--- a/net/802/hippi.c	2007-08-24 13:41:02.000000000 -0700
+++ b/net/802/hippi.c	2007-08-24 13:41:17.000000000 -0700
@@ -45,8 +45,8 @@
  */
=20
 static int hippi_header(struct sk_buff *skb, struct net_device *dev,
-			unsigned short type, void *daddr, void *saddr,
-			unsigned len)
+			unsigned short type,
+			const void *daddr, const void *saddr, unsigned len)
 {
 	struct hippi_hdr *hip =3D (struct hippi_hdr *)skb_push(skb, HIPPI_HLE=
N);
 	struct hippi_cb *hcb =3D (struct hippi_cb *) skb->cb;
@@ -182,16 +182,18 @@ static int hippi_neigh_setup_dev(struct=20
 	return 0;
 }
=20
+static const struct header_ops hippi_header_ops =3D {
+	.create		=3D hippi_header,
+	.rebuild	=3D hippi_rebuild_header,
+};
+
+
 static void hippi_setup(struct net_device *dev)
 {
 	dev->set_multicast_list		=3D NULL;
 	dev->change_mtu			=3D hippi_change_mtu;
-	dev->hard_header		=3D hippi_header;
-	dev->rebuild_header 		=3D hippi_rebuild_header;
+	dev->header_ops			=3D &hippi_header_ops;
 	dev->set_mac_address 		=3D hippi_mac_addr;
-	dev->hard_header_parse		=3D NULL;
-	dev->hard_header_cache		=3D NULL;
-	dev->header_cache_update	=3D NULL;
 	dev->neigh_setup 		=3D hippi_neigh_setup_dev;
=20
 	/*
--- a/net/802/tr.c	2007-08-24 13:41:02.000000000 -0700
+++ b/net/802/tr.c	2007-08-24 13:41:17.000000000 -0700
@@ -99,7 +99,7 @@ static inline unsigned long rif_hash(con
=20
 static int tr_header(struct sk_buff *skb, struct net_device *dev,
 		     unsigned short type,
-		     void *daddr, void *saddr, unsigned len)
+		     const void *daddr, const void *saddr, unsigned len)
 {
 	struct trh_hdr *trh;
 	int hdr_len;
@@ -141,7 +141,7 @@ static int tr_header(struct sk_buff *skb
 	if(daddr)
 	{
 		memcpy(trh->daddr,daddr,dev->addr_len);
-		tr_source_route(skb,trh,dev);
+		tr_source_route(skb, trh, dev);
 		return(hdr_len);
 	}
=20
@@ -246,7 +246,8 @@ __be16 tr_type_trans(struct sk_buff *skb
  *	We try to do source routing...
  */
=20
-void tr_source_route(struct sk_buff *skb,struct trh_hdr *trh,struct ne=
t_device *dev)
+void tr_source_route(struct sk_buff *skb,struct trh_hdr *trh,
+		     struct net_device *dev)
 {
 	int slack;
 	unsigned int hash;
@@ -589,14 +590,18 @@ static const struct file_operations rif_
=20
 #endif
=20
+static const struct header_ops tr_header_ops =3D {
+	.create =3D tr_header,
+	.rebuild=3D tr_rebuild_header,
+};
+
 static void tr_setup(struct net_device *dev)
 {
 	/*
 	 *	Configure and register
 	 */
=20
-	dev->hard_header	=3D tr_header;
-	dev->rebuild_header	=3D tr_rebuild_header;
+	dev->header_ops	=3D &tr_header_ops;
=20
 	dev->type		=3D ARPHRD_IEEE802_TR;
 	dev->hard_header_len	=3D TR_HLEN;
--- a/net/8021q/vlan.c	2007-08-24 13:41:02.000000000 -0700
+++ b/net/8021q/vlan.c	2007-08-24 13:41:17.000000000 -0700
@@ -313,6 +313,12 @@ int unregister_vlan_device(struct net_de
  */
 static struct lock_class_key vlan_netdev_xmit_lock_key;
=20
+static const struct header_ops vlan_header_ops =3D {
+	.create	 =3D vlan_dev_hard_header,
+	.rebuild =3D vlan_dev_rebuild_header,
+	.parse	 =3D eth_header_parse,
+};
+
 static int vlan_dev_init(struct net_device *dev)
 {
 	struct net_device *real_dev =3D VLAN_DEV_INFO(dev)->real_dev;
@@ -330,18 +336,14 @@ static int vlan_dev_init(struct net_devi
 		memcpy(dev->broadcast, real_dev->broadcast, dev->addr_len);
=20
 	if (real_dev->features & NETIF_F_HW_VLAN_TX) {
-		dev->hard_header     =3D real_dev->hard_header;
+		dev->header_ops      =3D real_dev->header_ops;
 		dev->hard_header_len =3D real_dev->hard_header_len;
 		dev->hard_start_xmit =3D vlan_dev_hwaccel_hard_start_xmit;
-		dev->rebuild_header  =3D real_dev->rebuild_header;
 	} else {
-		dev->hard_header     =3D vlan_dev_hard_header;
+		dev->header_ops      =3D &vlan_header_ops;
 		dev->hard_header_len =3D real_dev->hard_header_len + VLAN_HLEN;
 		dev->hard_start_xmit =3D vlan_dev_hard_start_xmit;
-		dev->rebuild_header  =3D vlan_dev_rebuild_header;
 	}
-	dev->hard_header_parse =3D real_dev->hard_header_parse;
-	dev->hard_header_cache =3D NULL;
=20
 	lockdep_set_class(&dev->_xmit_lock, &vlan_netdev_xmit_lock_key);
 	return 0;
--- a/drivers/net/arcnet/arcnet.c	2007-08-24 13:41:02.000000000 -0700
+++ b/drivers/net/arcnet/arcnet.c	2007-08-24 13:41:17.000000000 -0700
@@ -102,8 +102,8 @@ static int arcnet_close(struct net_devic
 static int arcnet_send_packet(struct sk_buff *skb, struct net_device *=
dev);
 static void arcnet_timeout(struct net_device *dev);
 static int arcnet_header(struct sk_buff *skb, struct net_device *dev,
-			 unsigned short type, void *daddr, void *saddr,
-			 unsigned len);
+			 unsigned short type, const void *daddr,
+			 const void *saddr, unsigned len);
 static int arcnet_rebuild_header(struct sk_buff *skb);
 static struct net_device_stats *arcnet_get_stats(struct net_device *de=
v);
 static int go_tx(struct net_device *dev);
@@ -317,11 +317,17 @@ static int choose_mtu(void)
 	return mtu =3D=3D 65535 ? XMTU : mtu;
 }
=20
+static const struct header_ops arcnet_header_ops =3D {
+	.create =3D arcnet_header,
+	.rebuild =3D arcnet_rebuild_header,
+};
+
=20
 /* Setup a struct device for ARCnet. */
 static void arcdev_setup(struct net_device *dev)
 {
 	dev->type =3D ARPHRD_ARCNET;
+	dev->header_ops =3D &arcnet_header_ops;
 	dev->hard_header_len =3D sizeof(struct archdr);
 	dev->mtu =3D choose_mtu();
=20
@@ -342,8 +348,6 @@ static void arcdev_setup(struct net_devi
 	dev->hard_start_xmit =3D arcnet_send_packet;
 	dev->tx_timeout =3D arcnet_timeout;
 	dev->get_stats =3D arcnet_get_stats;
-	dev->hard_header =3D arcnet_header;
-	dev->rebuild_header =3D arcnet_rebuild_header;
 }
=20
 struct net_device *alloc_arcdev(char *name)
@@ -488,10 +492,10 @@ static int arcnet_close(struct net_devic
=20
=20
 static int arcnet_header(struct sk_buff *skb, struct net_device *dev,
-			 unsigned short type, void *daddr, void *saddr,
-			 unsigned len)
+			 unsigned short type, const void *daddr,
+			 const void *saddr, unsigned len)
 {
-	struct arcnet_local *lp =3D dev->priv;
+	const struct arcnet_local *lp =3D netdev_priv(dev);
 	uint8_t _daddr, proto_num;
 	struct ArcProto *proto;
=20
--- a/drivers/net/hamradio/6pack.c	2007-08-24 13:41:02.000000000 -0700
+++ b/drivers/net/hamradio/6pack.c	2007-08-24 13:41:17.000000000 -0700
@@ -3,7 +3,7 @@
  *		devices like TTY. It interfaces between a raw TTY and the
  *		kernel's AX.25 protocol layers.
  *
- * Authors:	Andreas K=F6nsgen <ajk@iehk.rwth-aachen.de>
+ * Authors:	Andreas K=C3=B6nsgen <ajk@iehk.rwth-aachen.de>
  *              Ralf Baechle DL5RB <ralf@linux-mips.org>
  *
  * Quite a lot of stuff "stolen" by Joerg Reuter from slip.c, written =
by
@@ -288,7 +288,8 @@ static int sp_close(struct net_device *d
=20
 /* Return the frame type ID */
 static int sp_header(struct sk_buff *skb, struct net_device *dev,
-	unsigned short type, void *daddr, void *saddr, unsigned len)
+		     unsigned short type, const void *daddr,
+		     const void *saddr, unsigned len)
 {
 #ifdef CONFIG_INET
 	if (type !=3D htons(ETH_P_AX25))
@@ -323,6 +324,11 @@ static int sp_rebuild_header(struct sk_b
 #endif
 }
=20
+static const struct header_ops sp_header_ops =3D {
+	.create		=3D sp_header,
+	.rebuild	=3D sp_rebuild_header,
+};
+
 static void sp_setup(struct net_device *dev)
 {
 	/* Finish setting up the DEVICE info. */
@@ -331,14 +337,15 @@ static void sp_setup(struct net_device *
 	dev->open		=3D sp_open_dev;
 	dev->destructor		=3D free_netdev;
 	dev->stop		=3D sp_close;
-	dev->hard_header	=3D sp_header;
+
 	dev->get_stats	        =3D sp_get_stats;
 	dev->set_mac_address    =3D sp_set_mac_address;
 	dev->hard_header_len	=3D AX25_MAX_HEADER_LEN;
+	dev->header_ops 	=3D &sp_header_ops;
+
 	dev->addr_len		=3D AX25_ADDR_LEN;
 	dev->type		=3D ARPHRD_AX25;
 	dev->tx_queue_len	=3D 10;
-	dev->rebuild_header	=3D sp_rebuild_header;
 	dev->tx_timeout		=3D NULL;
=20
 	/* Only activated in AX.25 mode */
--- a/drivers/net/hamradio/bpqether.c	2007-08-24 13:41:14.000000000 -07=
00
+++ b/drivers/net/hamradio/bpqether.c	2007-08-24 13:41:17.000000000 -07=
00
@@ -488,8 +488,7 @@ static void bpq_setup(struct net_device=20
 	dev->flags      =3D 0;
=20
 #if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
-	dev->hard_header     =3D ax25_hard_header;
-	dev->rebuild_header  =3D ax25_rebuild_header;
+	dev->header_ops      =3D &ax25_header_ops;
 #endif
=20
 	dev->type            =3D ARPHRD_AX25;
--- a/drivers/net/hamradio/dmascc.c	2007-08-24 13:41:02.000000000 -0700
+++ b/drivers/net/hamradio/dmascc.c	2007-08-24 13:41:17.000000000 -0700
@@ -581,8 +581,7 @@ static int __init setup_adapter(int card
 		dev->do_ioctl =3D scc_ioctl;
 		dev->hard_start_xmit =3D scc_send_packet;
 		dev->get_stats =3D scc_get_stats;
-		dev->hard_header =3D ax25_hard_header;
-		dev->rebuild_header =3D ax25_rebuild_header;
+		dev->header_ops =3D &ax25_hard_header_ops
 		dev->set_mac_address =3D scc_set_mac_address;
 	}
 	if (register_netdev(info->dev[0])) {
--- a/drivers/net/hamradio/hdlcdrv.c	2007-08-24 13:41:02.000000000 -070=
0
+++ b/drivers/net/hamradio/hdlcdrv.c	2007-08-24 13:41:17.000000000 -070=
0
@@ -682,8 +682,7 @@ static void hdlcdrv_setup(struct net_dev
=20
 	s->skb =3D NULL;
 =09
-	dev->hard_header =3D ax25_hard_header;
-	dev->rebuild_header =3D ax25_rebuild_header;
+	dev->header_ops =3D &ax25_header_ops;
 	dev->set_mac_address =3D hdlcdrv_set_mac_address;
 =09
 	dev->type =3D ARPHRD_AX25;           /* AF_AX25 device */
--- a/drivers/net/hamradio/mkiss.c	2007-08-24 13:41:02.000000000 -0700
+++ b/drivers/net/hamradio/mkiss.c	2007-08-24 13:41:17.000000000 -0700
@@ -578,8 +578,9 @@ static int ax_open_dev(struct net_device
 #if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
=20
 /* Return the frame type ID */
-static int ax_header(struct sk_buff *skb, struct net_device *dev, unsi=
gned short type,
-	  void *daddr, void *saddr, unsigned len)
+static int ax_header(struct sk_buff *skb, struct net_device *dev,
+		     unsigned short type, const void *daddr,
+		     const void *saddr, unsigned len)
 {
 #ifdef CONFIG_INET
 	if (type !=3D htons(ETH_P_AX25))
@@ -670,6 +671,11 @@ static struct net_device_stats *ax_get_s
 	return &ax->stats;
 }
=20
+static const struct header_ops ax_header_ops =3D {
+	.create    =3D ax_header,
+	.rebuild   =3D ax_rebuild_header,
+};
+
 static void ax_setup(struct net_device *dev)
 {
 	/* Finish setting up the DEVICE info. */
@@ -683,8 +689,8 @@ static void ax_setup(struct net_device *
 	dev->addr_len        =3D 0;
 	dev->type            =3D ARPHRD_AX25;
 	dev->tx_queue_len    =3D 10;
-	dev->hard_header     =3D ax_header;
-	dev->rebuild_header  =3D ax_rebuild_header;
+	dev->header_ops      =3D &ax_header_ops;
+
=20
 	memcpy(dev->broadcast, &ax25_bcast, AX25_ADDR_LEN);
 	memcpy(dev->dev_addr,  &ax25_defaddr,  AX25_ADDR_LEN);
--- a/drivers/net/hamradio/scc.c	2007-08-24 13:41:02.000000000 -0700
+++ b/drivers/net/hamradio/scc.c	2007-08-24 13:41:17.000000000 -0700
@@ -1550,8 +1550,8 @@ static void scc_net_setup(struct net_dev
 	dev->stop	     =3D scc_net_close;
=20
 	dev->hard_start_xmit =3D scc_net_tx;
-	dev->hard_header     =3D ax25_hard_header;
-	dev->rebuild_header  =3D ax25_rebuild_header;
+	dev->header_ops      =3D &ax25_hard_header_ops;
+
 	dev->set_mac_address =3D scc_net_set_mac_address;
 	dev->get_stats       =3D scc_net_get_stats;
 	dev->do_ioctl        =3D scc_net_ioctl;
--- a/drivers/net/hamradio/yam.c	2007-08-24 13:41:02.000000000 -0700
+++ b/drivers/net/hamradio/yam.c	2007-08-24 13:41:17.000000000 -0700
@@ -1096,8 +1096,7 @@ static void yam_setup(struct net_device=20
=20
 	skb_queue_head_init(&yp->send_queue);
=20
-	dev->hard_header =3D ax25_hard_header;
-	dev->rebuild_header =3D ax25_rebuild_header;
+	dev->header_ops =3D &ax25_header_ops;
=20
 	dev->set_mac_address =3D yam_set_mac_address;
=20
--- a/drivers/net/skfp/skfddi.c	2007-08-24 13:41:02.000000000 -0700
+++ b/drivers/net/skfp/skfddi.c	2007-08-24 13:41:17.000000000 -0700
@@ -260,7 +260,6 @@ static int skfp_init_one(struct pci_dev=20
 	dev->set_multicast_list =3D &skfp_ctl_set_multicast_list;
 	dev->set_mac_address =3D &skfp_ctl_set_mac_address;
 	dev->do_ioctl =3D &skfp_ioctl;
-	dev->header_cache_update =3D NULL;	/* not supported */
=20
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
--- a/net/appletalk/dev.c	2007-08-24 13:41:02.000000000 -0700
+++ b/net/appletalk/dev.c	2007-08-24 13:41:17.000000000 -0700
@@ -24,11 +24,7 @@ static void ltalk_setup(struct net_devic
 	/* Fill in the fields of the device structure with localtalk-generic =
values. */
=20
 	dev->change_mtu		=3D ltalk_change_mtu;
-	dev->hard_header	=3D NULL;
-	dev->rebuild_header 	=3D NULL;
 	dev->set_mac_address 	=3D ltalk_mac_addr;
-	dev->hard_header_cache	=3D NULL;
-	dev->header_cache_update=3D NULL;
=20
 	dev->type		=3D ARPHRD_LOCALTLK;
 	dev->hard_header_len 	=3D LTALK_HLEN;
--- a/drivers/ieee1394/eth1394.c	2007-08-24 13:41:15.000000000 -0700
+++ b/drivers/ieee1394/eth1394.c	2007-08-24 13:41:17.000000000 -0700
@@ -159,15 +159,16 @@ MODULE_PARM_DESC(max_partial_datagrams,
=20
=20
 static int ether1394_header(struct sk_buff *skb, struct net_device *de=
v,
-			    unsigned short type, void *daddr, void *saddr,
-			    unsigned len);
+			    unsigned short type, const void *daddr,
+			    const void *saddr, unsigned len);
 static int ether1394_rebuild_header(struct sk_buff *skb);
 static int ether1394_header_parse(const struct sk_buff *skb,
 				  unsigned char *haddr);
-static int ether1394_header_cache(struct neighbour *neigh, struct hh_c=
ache *hh);
+static int ether1394_header_cache(const struct neighbour *neigh,
+				  struct hh_cache *hh);
 static void ether1394_header_cache_update(struct hh_cache *hh,
-					  struct net_device *dev,
-					  unsigned char *haddr);
+					  const struct net_device *dev,
+					  const unsigned char *haddr);
 static int ether1394_tx(struct sk_buff *skb, struct net_device *dev);
 static void ether1394_iso(struct hpsb_iso *iso);
=20
@@ -507,6 +508,14 @@ static void ether1394_reset_priv(struct=20
 	spin_unlock_irqrestore(&priv->lock, flags);
 }
=20
+static const struct header_ops ether1394_header_ops =3D {
+	.create		=3D ether1394_header,
+	.rebuild	=3D ether1394_rebuild_header,
+	.cache  	=3D ether1394_header_cache,
+	.cache_update	=3D ether1394_header_cache_update,
+	.parse		=3D ether1394_header_parse,
+};
+
 static void ether1394_init_dev(struct net_device *dev)
 {
 	dev->open		=3D ether1394_open;
@@ -516,11 +525,7 @@ static void ether1394_init_dev(struct ne
 	dev->tx_timeout		=3D ether1394_tx_timeout;
 	dev->change_mtu		=3D ether1394_change_mtu;
=20
-	dev->hard_header	=3D ether1394_header;
-	dev->rebuild_header	=3D ether1394_rebuild_header;
-	dev->hard_header_cache	=3D ether1394_header_cache;
-	dev->header_cache_update=3D ether1394_header_cache_update;
-	dev->hard_header_parse	=3D ether1394_header_parse;
+	dev->header_ops		=3D &ether1394_header_ops;
=20
 	SET_ETHTOOL_OPS(dev, &ethtool_ops);
=20
@@ -712,8 +717,8 @@ static void ether1394_host_reset(struct=20
  * saddr=3DNULL means use device source address
  * daddr=3DNULL means leave destination address (eg unresolved arp). *=
/
 static int ether1394_header(struct sk_buff *skb, struct net_device *de=
v,
-			    unsigned short type, void *daddr, void *saddr,
-			    unsigned len)
+			    unsigned short type, const void *daddr,
+			    const void *saddr, unsigned len)
 {
 	struct eth1394hdr *eth =3D
 			(struct eth1394hdr *)skb_push(skb, ETH1394_HLEN);
@@ -760,7 +765,8 @@ static int ether1394_header_parse(const=20
 	return ETH1394_ALEN;
 }
=20
-static int ether1394_header_cache(struct neighbour *neigh, struct hh_c=
ache *hh)
+static int ether1394_header_cache(const struct neighbour *neigh,
+				  struct hh_cache *hh)
 {
 	unsigned short type =3D hh->hh_type;
 	struct net_device *dev =3D neigh->dev;
@@ -779,8 +785,8 @@ static int ether1394_header_cache(struct
=20
 /* Called by Address Resolution module to notify changes in address. *=
/
 static void ether1394_header_cache_update(struct hh_cache *hh,
-					  struct net_device *dev,
-					  unsigned char * haddr)
+					  const struct net_device *dev,
+					  const unsigned char * haddr)
 {
 	memcpy((u8 *)hh->hh_data + 16 - ETH1394_HLEN, haddr, dev->addr_len);
 }
@@ -900,8 +906,8 @@ static u16 ether1394_parse_encap(struct=20
 	}
=20
 	/* Now add the ethernet header. */
-	if (dev->hard_header(skb, dev, ntohs(ether_type), &dest_hw, NULL,
-			     skb->len) >=3D 0)
+	if (dev_hard_header(skb, dev, ntohs(ether_type), &dest_hw, NULL,
+			    skb->len) >=3D 0)
 		ret =3D ether1394_type_trans(skb, dev);
=20
 	return ret;
--- a/net/8021q/vlan.h	2007-08-24 13:41:02.000000000 -0700
+++ b/net/8021q/vlan.h	2007-08-24 13:41:17.000000000 -0700
@@ -53,8 +53,8 @@ int vlan_dev_rebuild_header(struct sk_bu
 int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 		  struct packet_type *ptype, struct net_device *orig_dev);
 int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
-			 unsigned short type, void *daddr, void *saddr,
-			 unsigned len);
+			 unsigned short type, const void *daddr,
+			 const void *saddr, unsigned len);
 int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *d=
ev);
 int vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb, struct net_d=
evice *dev);
 int vlan_dev_change_mtu(struct net_device *dev, int new_mtu);
--- a/net/8021q/vlan_dev.c	2007-08-24 13:41:14.000000000 -0700
+++ b/net/8021q/vlan_dev.c	2007-08-24 13:41:17.000000000 -0700
@@ -328,8 +328,8 @@ static inline unsigned short vlan_dev_ge
  *  physical devices.
  */
 int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
-			 unsigned short type, void *daddr, void *saddr,
-			 unsigned len)
+			 unsigned short type,
+			 const void *daddr, const void *saddr, unsigned len)
 {
 	struct vlan_hdr *vhdr;
 	unsigned short veth_TCI =3D 0;
--- a/drivers/net/macvlan.c	2007-08-24 13:41:14.000000000 -0700
+++ b/drivers/net/macvlan.c	2007-08-24 13:41:17.000000000 -0700
@@ -164,8 +164,8 @@ static int macvlan_hard_start_xmit(struc
 }
=20
 static int macvlan_hard_header(struct sk_buff *skb, struct net_device =
*dev,
-			       unsigned short type, void *daddr, void *saddr,
-			       unsigned len)
+			       unsigned short type, const void *daddr,
+			       const void *saddr, unsigned len)
 {
 	const struct macvlan_dev *vlan =3D netdev_priv(dev);
 	struct net_device *lowerdev =3D vlan->lowerdev;
@@ -174,6 +174,15 @@ static int macvlan_hard_header(struct sk
 			       saddr ? : dev->dev_addr, len);
 }
=20
+static const struct header_ops macvlan_hard_header_ops =3D {
+	.create  	=3D macvlan_hard_header,
+	.rebuild	=3D eth_rebuild_header,
+	.parse		=3D eth_header_parse,
+	.rebuild	=3D eth_rebuild_header,
+	.cache		=3D eth_header_cache,
+	.cache_update	=3D eth_header_cache_update,
+};
+
 static int macvlan_open(struct net_device *dev)
 {
 	struct macvlan_dev *vlan =3D netdev_priv(dev);
@@ -299,9 +308,9 @@ static void macvlan_setup(struct net_dev
 	dev->change_mtu		=3D macvlan_change_mtu;
 	dev->change_rx_flags	=3D macvlan_change_rx_flags;
 	dev->set_multicast_list	=3D macvlan_set_multicast_list;
-	dev->hard_header	=3D macvlan_hard_header;
 	dev->hard_start_xmit	=3D macvlan_hard_start_xmit;
 	dev->destructor		=3D free_netdev;
+	dev->header_ops		=3D &macvlan_hard_header_ops,
 	dev->ethtool_ops	=3D &macvlan_ethtool_ops;
 	dev->tx_queue_len	=3D 0;
 }
--- a/include/net/ax25.h	2007-08-24 13:41:02.000000000 -0700
+++ b/include/net/ax25.h	2007-08-24 13:41:17.000000000 -0700
@@ -363,8 +363,11 @@ extern int  ax25_rx_iframe(ax25_cb *, st
 extern int  ax25_kiss_rcv(struct sk_buff *, struct net_device *, struc=
t packet_type *, struct net_device *);
=20
 /* ax25_ip.c */
-extern int  ax25_hard_header(struct sk_buff *, struct net_device *, un=
signed short, void *, void *, unsigned int);
+extern int ax25_hard_header(struct sk_buff *, struct net_device *,
+			    unsigned short, const void *,
+			    const void *, unsigned int);
 extern int  ax25_rebuild_header(struct sk_buff *);
+extern const struct header_ops ax25_header_ops;
=20
 /* ax25_out.c */
 extern ax25_cb *ax25_send_frame(struct sk_buff *, int, ax25_address *,=
 ax25_address *, ax25_digi *, struct net_device *);
--- a/net/ax25/ax25_ip.c	2007-08-24 13:41:02.000000000 -0700
+++ b/net/ax25/ax25_ip.c	2007-08-24 13:41:17.000000000 -0700
@@ -46,7 +46,9 @@
=20
 #ifdef CONFIG_INET
=20
-int ax25_hard_header(struct sk_buff *skb, struct net_device *dev, unsi=
gned short type, void *daddr, void *saddr, unsigned len)
+int ax25_hard_header(struct sk_buff *skb, struct net_device *dev,
+		     unsigned short type, const void *daddr,
+		     const void *saddr, unsigned len)
 {
 	unsigned char *buff;
=20
@@ -215,7 +217,9 @@ put:
=20
 #else	/* INET */
=20
-int ax25_hard_header(struct sk_buff *skb, struct net_device *dev, unsi=
gned short type, void *daddr, void *saddr, unsigned len)
+int ax25_hard_header(struct sk_buff *skb, struct net_device *dev,
+		     unsigned short type, const void *daddr,
+		     const void *saddr, unsigned len)
 {
 	return -AX25_HEADER_LEN;
 }
@@ -227,5 +231,12 @@ int ax25_rebuild_header(struct sk_buff *
=20
 #endif
=20
+const struct header_ops ax25_header_ops =3D {
+	.create =3D ax25_hard_header,
+	.rebuild =3D ax25_rebuild_header,
+};
+
 EXPORT_SYMBOL(ax25_hard_header);
 EXPORT_SYMBOL(ax25_rebuild_header);
+EXPORT_SYMBOL(ax25_header_ops);
+
--- a/drivers/net/shaper.c	2007-08-24 13:41:02.000000000 -0700
+++ b/drivers/net/shaper.c	2007-08-24 13:41:17.000000000 -0700
@@ -336,15 +336,16 @@ static struct net_device_stats *shaper_g
 }
=20
 static int shaper_header(struct sk_buff *skb, struct net_device *dev,
-	unsigned short type, void *daddr, void *saddr, unsigned len)
+			 unsigned short type,
+			 const void *daddr, const void *saddr, unsigned len)
 {
 	struct shaper *sh=3Ddev->priv;
 	int v;
 	if(sh_debug)
 		printk("Shaper header\n");
-	skb->dev=3Dsh->dev;
-	v=3Dsh->hard_header(skb,sh->dev,type,daddr,saddr,len);
-	skb->dev=3Ddev;
+	skb->dev =3D sh->dev;
+	v =3D dev_hard_header(skb, sh->dev, type, daddr, saddr, len);
+	skb->dev =3D dev;
 	return v;
 }
=20
@@ -356,7 +357,7 @@ static int shaper_rebuild_header(struct=20
 	if(sh_debug)
 		printk("Shaper rebuild header\n");
 	skb->dev=3Dsh->dev;
-	v=3Dsh->rebuild_header(skb);
+	v =3D sh->dev->header_ops->rebuild(skb);
 	skb->dev=3Ddev;
 	return v;
 }
@@ -420,51 +421,17 @@ static int shaper_neigh_setup_dev(struct
=20
 #endif
=20
+static const struct header_ops shaper_ops =3D {
+	.create	 =3D shaper_header,
+	.rebuild =3D shaper_rebuild_header,
+};
+
 static int shaper_attach(struct net_device *shdev, struct shaper *sh, =
struct net_device *dev)
 {
 	sh->dev =3D dev;
-	sh->hard_start_xmit=3Ddev->hard_start_xmit;
 	sh->get_stats=3Ddev->get_stats;
-	if(dev->hard_header)
-	{
-		sh->hard_header=3Ddev->hard_header;
-		shdev->hard_header =3D shaper_header;
-	}
-	else
-		shdev->hard_header =3D NULL;
-
-	if(dev->rebuild_header)
-	{
-		sh->rebuild_header	=3D dev->rebuild_header;
-		shdev->rebuild_header	=3D shaper_rebuild_header;
-	}
-	else
-		shdev->rebuild_header	=3D NULL;
-
-#if 0
-	if(dev->hard_header_cache)
-	{
-		sh->hard_header_cache	=3D dev->hard_header_cache;
-		shdev->hard_header_cache=3D shaper_cache;
-	}
-	else
-	{
-		shdev->hard_header_cache=3D NULL;
-	}
=20
-	if(dev->header_cache_update)
-	{
-		sh->header_cache_update	=3D dev->header_cache_update;
-		shdev->header_cache_update =3D shaper_cache_update;
-	}
-	else
-		shdev->header_cache_update=3D NULL;
-#else
-	shdev->header_cache_update =3D NULL;
-	shdev->hard_header_cache =3D NULL;
-#endif
 	shdev->neigh_setup =3D shaper_neigh_setup_dev;
-
 	shdev->hard_header_len=3Ddev->hard_header_len;
 	shdev->type=3Ddev->type;
 	shdev->addr_len=3Ddev->addr_len;
@@ -550,12 +517,6 @@ static void __init shaper_setup(struct n
 	 *	Handlers for when we attach to a device.
 	 */
=20
-	dev->hard_header 	=3D shaper_header;
-	dev->rebuild_header 	=3D shaper_rebuild_header;
-#if 0
-	dev->hard_header_cache	=3D shaper_cache;
-	dev->header_cache_update=3D shaper_cache_update;
-#endif
 	dev->neigh_setup	=3D shaper_neigh_setup_dev;
 	dev->do_ioctl		=3D shaper_ioctl;
 	dev->hard_header_len	=3D 0;
--- a/include/linux/if_shaper.h	2007-08-24 13:41:02.000000000 -0700
+++ b/include/linux/if_shaper.h	2007-08-24 13:41:17.000000000 -0700
@@ -26,17 +26,6 @@ struct shaper
 	spinlock_t lock;
         struct net_device_stats stats;
 	struct net_device *dev;
-	int  (*hard_start_xmit) (struct sk_buff *skb,
-		struct net_device *dev);
-	int  (*hard_header) (struct sk_buff *skb,
-		struct net_device *dev,
-		unsigned short type,
-		void *daddr,
-		void *saddr,
-		unsigned len);
-	int  (*rebuild_header)(struct sk_buff *skb);
-	int (*hard_header_cache)(struct neighbour *neigh, struct hh_cache *hh=
);
-	void (*header_cache_update)(struct hh_cache *hh, struct net_device *d=
ev, unsigned char *  haddr);
 	struct net_device_stats* (*get_stats)(struct net_device *dev);
 	struct timer_list timer;
 };
--- a/net/ipv4/ip_gre.c	2007-08-24 13:41:02.000000000 -0700
+++ b/net/ipv4/ip_gre.c	2007-08-24 13:41:17.000000000 -0700
@@ -684,7 +684,7 @@ static int ipgre_tunnel_xmit(struct sk_b
 		goto tx_error;
 	}
=20
-	if (dev->hard_header) {
+	if (dev->header_ops) {
 		gre_hlen =3D 0;
 		tiph =3D (struct iphdr*)skb->data;
 	} else {
@@ -1063,8 +1063,9 @@ static int ipgre_tunnel_change_mtu(struc
=20
  */
=20
-static int ipgre_header(struct sk_buff *skb, struct net_device *dev, u=
nsigned short type,
-			void *daddr, void *saddr, unsigned len)
+static int ipgre_header(struct sk_buff *skb, struct net_device *dev,
+			unsigned short type,
+			const void *daddr, const void *saddr, unsigned len)
 {
 	struct ip_tunnel *t =3D netdev_priv(dev);
 	struct iphdr *iph =3D (struct iphdr *)skb_push(skb, t->hlen);
@@ -1130,9 +1131,14 @@ static int ipgre_close(struct net_device
=20
 #endif
=20
+static const struct header_ops ipgre_header_ops =3D {
+	.create	=3D ipgre_header,
+};
+
 static void ipgre_tunnel_setup(struct net_device *dev)
 {
 	SET_MODULE_OWNER(dev);
+
 	dev->uninit		=3D ipgre_tunnel_uninit;
 	dev->destructor 	=3D free_netdev;
 	dev->hard_start_xmit	=3D ipgre_tunnel_xmit;
@@ -1188,7 +1194,7 @@ static int ipgre_tunnel_init(struct net_
 			if (!iph->saddr)
 				return -EINVAL;
 			dev->flags =3D IFF_BROADCAST;
-			dev->hard_header =3D ipgre_header;
+			dev->header_ops =3D &ipgre_header_ops;
 			dev->open =3D ipgre_open;
 			dev->stop =3D ipgre_close;
 		}
--- a/net/ipv4/ip_output.c	2007-08-24 13:41:02.000000000 -0700
+++ b/net/ipv4/ip_output.c	2007-08-24 13:41:17.000000000 -0700
@@ -169,7 +169,7 @@ static inline int ip_finish_output2(stru
 		IP_INC_STATS(IPSTATS_MIB_OUTBCASTPKTS);
=20
 	/* Be paranoid, rather than too clever. */
-	if (unlikely(skb_headroom(skb) < hh_len && dev->hard_header)) {
+	if (unlikely(skb_headroom(skb) < hh_len && dev->header_ops)) {
 		struct sk_buff *skb2;
=20
 		skb2 =3D skb_realloc_headroom(skb, LL_RESERVED_SPACE(dev));
--- a/net/ipv6/ndisc.c	2007-08-24 13:41:02.000000000 -0700
+++ b/net/ipv6/ndisc.c	2007-08-24 13:41:17.000000000 -0700
@@ -354,7 +354,7 @@ static int ndisc_constructor(struct neig
 	rcu_read_unlock();
=20
 	neigh->type =3D is_multicast ? RTN_MULTICAST : RTN_UNICAST;
-	if (dev->hard_header =3D=3D NULL) {
+	if (!dev->header_ops) {
 		neigh->nud_state =3D NUD_NOARP;
 		neigh->ops =3D &ndisc_direct_ops;
 		neigh->output =3D neigh->ops->queue_xmit;
@@ -371,7 +371,7 @@ static int ndisc_constructor(struct neig
 			neigh->nud_state =3D NUD_NOARP;
 			memcpy(neigh->ha, dev->broadcast, dev->addr_len);
 		}
-		if (dev->hard_header_cache)
+		if (dev->header_ops->cache)
 			neigh->ops =3D &ndisc_hh_ops;
 		else
 			neigh->ops =3D &ndisc_generic_ops;
@@ -808,7 +808,7 @@ static void ndisc_recv_ns(struct sk_buff
 		neigh_update(neigh, lladdr, NUD_STALE,
 			     NEIGH_UPDATE_F_WEAK_OVERRIDE|
 			     NEIGH_UPDATE_F_OVERRIDE);
-	if (neigh || !dev->hard_header) {
+	if (neigh || !dev->header_ops) {
 		ndisc_send_na(dev, neigh, saddr, &msg->target,
 			      is_router,
 			      1, (ifp !=3D NULL && inc), inc);
--- a/net/mac80211/ieee80211.c	2007-08-24 13:41:15.000000000 -0700
+++ b/net/mac80211/ieee80211.c	2007-08-24 13:41:17.000000000 -0700
@@ -295,16 +295,24 @@ static int ieee80211_change_mtu_apdev(st
 	return 0;
 }
=20
+static const struct header_ops ieee80211_header_ops =3D {
+	.create		=3D eth_header,
+	.parse		=3D header_parse_80211,
+	.rebuild	=3D eth_rebuild_header,
+	.cache		=3D eth_header_cache,
+	.cache_update	=3D eth_header_cache_update,
+};
+
 void ieee80211_if_mgmt_setup(struct net_device *dev)
 {
 	ether_setup(dev);
+	dev->header_ops =3D &ieee80211_header_ops;
 	dev->hard_start_xmit =3D ieee80211_mgmt_start_xmit;
 	dev->change_mtu =3D ieee80211_change_mtu_apdev;
 	dev->get_stats =3D ieee80211_get_stats;
 	dev->open =3D ieee80211_mgmt_open;
 	dev->stop =3D ieee80211_mgmt_stop;
 	dev->type =3D ARPHRD_IEEE80211_PRISM;
-	dev->hard_header_parse =3D header_parse_80211;
 	dev->uninit =3D ieee80211_if_reinit;
 	dev->destructor =3D ieee80211_if_free;
 }
@@ -1290,7 +1298,7 @@ struct ieee80211_hw *ieee80211_alloc_hw(
 	mdev->open =3D ieee80211_master_open;
 	mdev->stop =3D ieee80211_master_stop;
 	mdev->type =3D ARPHRD_IEEE80211;
-	mdev->hard_header_parse =3D header_parse_80211;
+	mdev->header_ops =3D &ieee80211_header_ops;
=20
 	sdata->type =3D IEEE80211_IF_TYPE_AP;
 	sdata->dev =3D mdev;
--- a/net/netrom/nr_dev.c	2007-08-24 13:41:02.000000000 -0700
+++ b/net/netrom/nr_dev.c	2007-08-24 13:41:17.000000000 -0700
@@ -95,8 +95,9 @@ static int nr_rebuild_header(struct sk_b
=20
 #endif
=20
-static int nr_header(struct sk_buff *skb, struct net_device *dev, unsi=
gned short type,
-	void *daddr, void *saddr, unsigned len)
+static int nr_header(struct sk_buff *skb, struct net_device *dev,
+		     unsigned short type,
+		     const void *daddr, const void *saddr, unsigned len)
 {
 	unsigned char *buff =3D skb_push(skb, NR_NETWORK_LEN + NR_TRANSPORT_L=
EN);
=20
@@ -193,6 +194,12 @@ static struct net_device_stats *nr_get_s
 	return &nr->stats;
 }
=20
+static const struct header_ops nr_header_ops =3D {
+	.create	=3D nr_header,
+	.rebuild=3D nr_rebuild_header,
+};
+
+
 void nr_setup(struct net_device *dev)
 {
 	dev->mtu		=3D NR_MAX_PACKET_SIZE;
@@ -200,11 +207,10 @@ void nr_setup(struct net_device *dev)
 	dev->open		=3D nr_open;
 	dev->stop		=3D nr_close;
=20
-	dev->hard_header	=3D nr_header;
+	dev->header_ops		=3D &nr_header_ops;
 	dev->hard_header_len	=3D NR_NETWORK_LEN + NR_TRANSPORT_LEN;
 	dev->addr_len		=3D AX25_ADDR_LEN;
 	dev->type		=3D ARPHRD_NETROM;
-	dev->rebuild_header	=3D nr_rebuild_header;
 	dev->set_mac_address    =3D nr_set_mac_address;
=20
 	/* New-style flags. */
--- a/net/packet/af_packet.c	2007-08-24 13:41:15.000000000 -0700
+++ b/net/packet/af_packet.c	2007-08-24 13:41:17.000000000 -0700
@@ -385,7 +385,7 @@ static int packet_sendmsg_spkt(struct ki
 	skb_reset_network_header(skb);
=20
 	/* Try to align data part correctly */
-	if (dev->hard_header) {
+	if (dev->header_ops) {
 		skb->data -=3D dev->hard_header_len;
 		skb->tail -=3D dev->hard_header_len;
 		if (len < dev->hard_header_len)
@@ -459,7 +459,7 @@ static int packet_rcv(struct sk_buff *sk
=20
 	skb->dev =3D dev;
=20
-	if (dev->hard_header) {
+	if (dev->header_ops) {
 		/* The device has an explicit notion of ll header,
 		   exported to higher levels.
=20
@@ -571,7 +571,7 @@ static int tpacket_rcv(struct sk_buff *s
 	sk =3D pt->af_packet_priv;
 	po =3D pkt_sk(sk);
=20
-	if (dev->hard_header) {
+	if (dev->header_ops) {
 		if (sk->sk_type !=3D SOCK_DGRAM)
 			skb_push(skb, skb->data - skb_mac_header(skb));
 		else if (skb->pkt_type =3D=3D PACKET_OUTGOING) {
--- a/net/rose/rose_dev.c	2007-08-24 13:41:02.000000000 -0700
+++ b/net/rose/rose_dev.c	2007-08-24 13:41:17.000000000 -0700
@@ -35,8 +35,9 @@
 #include <net/ax25.h>
 #include <net/rose.h>
=20
-static int rose_header(struct sk_buff *skb, struct net_device *dev, un=
signed short type,
-	void *daddr, void *saddr, unsigned len)
+static int rose_header(struct sk_buff *skb, struct net_device *dev,
+		       unsigned short type,
+		       const void *daddr, const void *saddr, unsigned len)
 {
 	unsigned char *buff =3D skb_push(skb, ROSE_MIN_LEN + 2);
=20
@@ -148,6 +149,11 @@ static struct net_device_stats *rose_get
 	return netdev_priv(dev);
 }
=20
+static const struct header_ops rose_header_ops =3D {
+	.create	=3D rose_header,
+	.rebuild=3D rose_rebuild_header,
+};
+
 void rose_setup(struct net_device *dev)
 {
 	dev->mtu		=3D ROSE_MAX_PACKET_SIZE - 2;
@@ -155,11 +161,10 @@ void rose_setup(struct net_device *dev)
 	dev->open		=3D rose_open;
 	dev->stop		=3D rose_close;
=20
-	dev->hard_header	=3D rose_header;
+	dev->header_ops		=3D &rose_header_ops;
 	dev->hard_header_len	=3D AX25_BPQ_HEADER_LEN + AX25_MAX_HEADER_LEN + =
ROSE_MIN_LEN;
 	dev->addr_len		=3D ROSE_ADDR_LEN;
 	dev->type		=3D ARPHRD_ROSE;
-	dev->rebuild_header	=3D rose_rebuild_header;
 	dev->set_mac_address    =3D rose_set_mac_address;
=20
 	/* New-style flags. */
--- a/net/sched/sch_teql.c	2007-08-24 13:41:14.000000000 -0700
+++ b/net/sched/sch_teql.c	2007-08-24 13:41:17.000000000 -0700
@@ -249,10 +249,10 @@ __teql_resolve(struct sk_buff *skb, stru
 	return (skb_res =3D=3D NULL) ? -EAGAIN : 1;
 }
=20
-static __inline__ int
-teql_resolve(struct sk_buff *skb, struct sk_buff *skb_res, struct net_=
device *dev)
+static inline int teql_resolve(struct sk_buff *skb,
+			       struct sk_buff *skb_res, struct net_device *dev)
 {
-	if (dev->hard_header =3D=3D NULL ||
+	if (dev->header_ops =3D=3D NULL ||
 	    skb->dst =3D=3D NULL ||
 	    skb->dst->neighbour =3D=3D NULL)
 		return 0;
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c	2007-08-24 13:41:02.000=
000000 -0700
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c	2007-08-24 13:41:17.000=
000000 -0700
@@ -777,7 +777,7 @@ static void ipoib_timeout(struct net_dev
 static int ipoib_hard_header(struct sk_buff *skb,
 			     struct net_device *dev,
 			     unsigned short type,
-			     void *daddr, void *saddr, unsigned len)
+			     const void *daddr, const void *saddr, unsigned len)
 {
 	struct ipoib_header *header;
=20
@@ -937,6 +937,10 @@ void ipoib_dev_cleanup(struct net_device
 	priv->tx_ring =3D NULL;
 }
=20
+static const struct header_ops ipoib_header_ops =3D {
+	.create	=3D ipoib_hard_header,
+};
+
 static void ipoib_setup(struct net_device *dev)
 {
 	struct ipoib_dev_priv *priv =3D netdev_priv(dev);
@@ -947,7 +951,7 @@ static void ipoib_setup(struct net_devic
 	dev->hard_start_xmit 	 =3D ipoib_start_xmit;
 	dev->get_stats 		 =3D ipoib_get_stats;
 	dev->tx_timeout 	 =3D ipoib_timeout;
-	dev->hard_header 	 =3D ipoib_hard_header;
+	dev->header_ops 	 =3D &ipoib_header_ops;
 	dev->set_multicast_list  =3D ipoib_set_mcast_list;
 	dev->neigh_setup         =3D ipoib_neigh_setup_dev;
=20
--- a/drivers/isdn/i4l/isdn_net.c	2007-08-24 13:41:02.000000000 -0700
+++ b/drivers/isdn/i4l/isdn_net.c	2007-08-24 13:41:17.000000000 -0700
@@ -1873,54 +1873,14 @@ isdn_net_rcv_skb(int idx, struct sk_buff
 	return 0;
 }
=20
-static int
-my_eth_header(struct sk_buff *skb, struct net_device *dev, unsigned sh=
ort type,
-	      void *daddr, void *saddr, unsigned len)
-{
-	struct ethhdr *eth =3D (struct ethhdr *) skb_push(skb, ETH_HLEN);
-
-	/*
-	 * Set the protocol type. For a packet of type ETH_P_802_3 we
-	 * put the length here instead. It is up to the 802.2 layer to
-	 * carry protocol information.
-	 */
-
-	if (type !=3D ETH_P_802_3)
-		eth->h_proto =3D htons(type);
-	else
-		eth->h_proto =3D htons(len);
-
-	/*
-	 * Set the source hardware address.
-	 */
-	if (saddr)
-		memcpy(eth->h_source, saddr, dev->addr_len);
-	else
-		memcpy(eth->h_source, dev->dev_addr, dev->addr_len);
-
-	/*
-	 * Anyway, the loopback-device should never use this function...
-	 */
-
-	if (dev->flags & (IFF_LOOPBACK | IFF_NOARP)) {
-		memset(eth->h_dest, 0, dev->addr_len);
-		return ETH_HLEN /*(dev->hard_header_len)*/;
-	}
-	if (daddr) {
-		memcpy(eth->h_dest, daddr, dev->addr_len);
-		return ETH_HLEN /*dev->hard_header_len*/;
-	}
-	return -ETH_HLEN /*dev->hard_header_len*/;
-}
-
 /*
  *  build an header
  *  depends on encaps that is being used.
  */
=20
-static int
-isdn_net_header(struct sk_buff *skb, struct net_device *dev, unsigned =
short type,
-		void *daddr, void *saddr, unsigned plen)
+static int isdn_net_header(struct sk_buff *skb, struct net_device *dev=
,
+			   unsigned short type,
+			   const void *daddr, const void *saddr, unsigned plen)
 {
 	isdn_net_local *lp =3D dev->priv;
 	unsigned char *p;
@@ -1928,7 +1888,7 @@ isdn_net_header(struct sk_buff *skb, str
=20
 	switch (lp->p_encap) {
 		case ISDN_NET_ENCAP_ETHER:
-			len =3D my_eth_header(skb, dev, type, daddr, saddr, plen);
+			len =3D eth_header(skb, dev, type, daddr, saddr, plen);
 			break;
 #ifdef CONFIG_ISDN_PPP
 		case ISDN_NET_ENCAP_SYNCPPP:
@@ -2005,6 +1965,32 @@ isdn_net_rebuild_header(struct sk_buff *
 	return ret;
 }
=20
+static int isdn_header_cache(const struct neighbour *neigh, struct hh_=
cache *hh)
+{
+	const struct net_device *dev =3D neigh->dev;
+	isdn_net_local *lp =3D dev->priv;
+
+	if (lp->p_encap =3D=3D ISDN_NET_ENCAP_ETHER)
+		return eth_header_cache(neigh, hh);
+	return -1;
+}
+
+static void isdn_header_cache_update(struct hh_cache *hh,
+				     const struct net_device *dev,
+				     const unsigned char *haddr)
+{
+	isdn_net_local *lp =3D dev->priv;
+	if (lp->p_encap =3D=3D ISDN_NET_ENCAP_ETHER)
+		return eth_header_cache_update(hh, dev, haddr);
+}
+
+static const struct header_ops isdn_header_ops =3D {
+	.create =3D isdn_net_header,
+	.rebuild =3D isdn_net_rebuild_header,
+	.cache =3D isdn_header_cache,
+	.cache_update =3D isdn_header_cache_update,
+};
+
 /*
  * Interface-setup. (just after registering a new interface)
  */
@@ -2012,18 +1998,12 @@ static int
 isdn_net_init(struct net_device *ndev)
 {
 	ushort max_hlhdr_len =3D 0;
-	isdn_net_local *lp =3D (isdn_net_local *) ndev->priv;
-	int drvidx, i;
+	int drvidx;
=20
 	ether_setup(ndev);
-	lp->org_hhc =3D ndev->hard_header_cache;
-	lp->org_hcu =3D ndev->header_cache_update;
+	ndev->header_ops =3D NULL;
=20
 	/* Setup the generic properties */
-
-	ndev->hard_header =3D NULL;
-	ndev->hard_header_cache =3D NULL;
-	ndev->header_cache_update =3D NULL;
 	ndev->mtu =3D 1500;
 	ndev->flags =3D IFF_NOARP|IFF_POINTOPOINT;
 	ndev->type =3D ARPHRD_ETHER;
@@ -2032,9 +2012,6 @@ isdn_net_init(struct net_device *ndev)
 	/* for clients with MPPP maybe higher values better */
 	ndev->tx_queue_len =3D 30;
=20
-	for (i =3D 0; i < ETH_ALEN; i++)
-		ndev->broadcast[i] =3D 0xff;
-
 	/* The ISDN-specific entries in the device structure. */
 	ndev->open =3D &isdn_net_open;
 	ndev->hard_start_xmit =3D &isdn_net_start_xmit;
@@ -2052,7 +2029,6 @@ isdn_net_init(struct net_device *ndev)
 	ndev->hard_header_len =3D ETH_HLEN + max_hlhdr_len;
 	ndev->stop =3D &isdn_net_close;
 	ndev->get_stats =3D &isdn_net_get_stats;
-	ndev->rebuild_header =3D &isdn_net_rebuild_header;
 	ndev->do_ioctl =3D NULL;
 	return 0;
 }
@@ -2861,21 +2837,14 @@ isdn_net_setcfg(isdn_net_ioctl_cfg * cfg
 		}
 		if (cfg->p_encap !=3D lp->p_encap) {
 			if (cfg->p_encap =3D=3D ISDN_NET_ENCAP_RAWIP) {
-				p->dev.hard_header =3D NULL;
-				p->dev.hard_header_cache =3D NULL;
-				p->dev.header_cache_update =3D NULL;
+				p->dev.header_ops =3D NULL;
 				p->dev.flags =3D IFF_NOARP|IFF_POINTOPOINT;
 			} else {
-				p->dev.hard_header =3D isdn_net_header;
-				if (cfg->p_encap =3D=3D ISDN_NET_ENCAP_ETHER) {
-					p->dev.hard_header_cache =3D lp->org_hhc;
-					p->dev.header_cache_update =3D lp->org_hcu;
+				p->dev.header_ops =3D &isdn_header_ops;
+				if (cfg->p_encap =3D=3D ISDN_NET_ENCAP_ETHER)
 					p->dev.flags =3D IFF_BROADCAST | IFF_MULTICAST;
-				} else {
-					p->dev.hard_header_cache =3D NULL;
-					p->dev.header_cache_update =3D NULL;
+				else
 					p->dev.flags =3D IFF_NOARP|IFF_POINTOPOINT;
-				}
 			}
 		}
 		lp->p_encap =3D cfg->p_encap;
@@ -3127,8 +3096,6 @@ isdn_net_realrm(isdn_net_dev * p, isdn_n
 			((isdn_net_local *) (p->local->master->priv))->slave =3D p->local->=
slave;
 	} else {
 		/* Unregister only if it's a master-device */
-		p->dev.hard_header_cache =3D p->local->org_hhc;
-		p->dev.header_cache_update =3D p->local->org_hcu;
 		unregister_netdev(&p->dev);
 	}
 	/* Unlink device from chain */
--- a/drivers/media/dvb/dvb-core/dvb_net.c	2007-08-24 13:41:02.00000000=
0 -0700
+++ b/drivers/media/dvb/dvb-core/dvb_net.c	2007-08-24 13:41:17.00000000=
0 -0700
@@ -1224,10 +1224,17 @@ static struct net_device_stats * dvb_net
 	return &((struct dvb_net_priv*) dev->priv)->stats;
 }
=20
+static const struct header_ops dvb_header_ops =3D {
+	.create		=3D eth_header,
+	.parse		=3D eth_header_parse,
+	.rebuild	=3D eth_rebuild_header,
+};
+
 static void dvb_net_setup(struct net_device *dev)
 {
 	ether_setup(dev);
=20
+	dev->header_ops		=3D &dvb_header_ops;
 	dev->open		=3D dvb_net_open;
 	dev->stop		=3D dvb_net_stop;
 	dev->hard_start_xmit	=3D dvb_net_tx;
@@ -1236,7 +1243,7 @@ static void dvb_net_setup(struct net_dev
 	dev->set_mac_address    =3D dvb_net_set_mac;
 	dev->mtu		=3D 4096;
 	dev->mc_count           =3D 0;
-	dev->hard_header_cache  =3D NULL;
+
 	dev->flags |=3D IFF_NOARP;
 }
=20
--- a/drivers/net/plip.c	2007-08-24 13:41:02.000000000 -0700
+++ b/drivers/net/plip.c	2007-08-24 13:41:17.000000000 -0700
@@ -148,9 +148,9 @@ static void plip_interrupt(int irq, void
 /* Functions for DEV methods */
 static int plip_tx_packet(struct sk_buff *skb, struct net_device *dev)=
;
 static int plip_hard_header(struct sk_buff *skb, struct net_device *de=
v,
-                            unsigned short type, void *daddr,
-                            void *saddr, unsigned len);
-static int plip_hard_header_cache(struct neighbour *neigh,
+                            unsigned short type, const void *daddr,
+			    const void *saddr, unsigned len);
+static int plip_hard_header_cache(const struct neighbour *neigh,
                                   struct hh_cache *hh);
 static int plip_open(struct net_device *dev);
 static int plip_close(struct net_device *dev);
@@ -221,11 +221,6 @@ struct net_local {
 	int is_deferred;
 	int port_owner;
 	int should_relinquish;
-	int (*orig_hard_header)(struct sk_buff *skb, struct net_device *dev,
-	                        unsigned short type, void *daddr,
-	                        void *saddr, unsigned len);
-	int (*orig_hard_header_cache)(struct neighbour *neigh,
-	                              struct hh_cache *hh);
 	spinlock_t lock;
 	atomic_t kill_timer;
 	struct semaphore killed_timer_sem;
@@ -267,6 +262,11 @@ static inline unsigned char read_status=20
 	return port->ops->read_status (port);
 }
=20
+static const struct header_ops plip_header_ops =3D {
+	.create	=3D plip_hard_header,
+	.cache  =3D plip_hard_header_cache,
+};
+
 /* Entry point of PLIP driver.
    Probe the hardware, and register/initialize the driver.
=20
@@ -287,17 +287,12 @@ plip_init_netdev(struct net_device *dev)
 	dev->stop		 =3D plip_close;
 	dev->get_stats 		 =3D plip_get_stats;
 	dev->do_ioctl		 =3D plip_ioctl;
-	dev->header_cache_update =3D NULL;
+
 	dev->tx_queue_len 	 =3D 10;
 	dev->flags	         =3D IFF_POINTOPOINT|IFF_NOARP;
 	memset(dev->dev_addr, 0xfc, ETH_ALEN);
=20
-	/* Set the private structure */
-	nl->orig_hard_header    =3D dev->hard_header;
-	dev->hard_header        =3D plip_hard_header;
-
-	nl->orig_hard_header_cache =3D dev->hard_header_cache;
-	dev->hard_header_cache     =3D plip_hard_header_cache;
+	dev->header_ops          =3D &plip_header_ops;
=20
=20
 	nl->port_owner =3D 0;
@@ -996,14 +991,14 @@ plip_tx_packet(struct sk_buff *skb, stru
 }
=20
 static void
-plip_rewrite_address(struct net_device *dev, struct ethhdr *eth)
+plip_rewrite_address(const struct net_device *dev, struct ethhdr *eth)
 {
-	struct in_device *in_dev;
+	const struct in_device *in_dev =3D dev->ip_ptr;
=20
-	if ((in_dev=3Ddev->ip_ptr) !=3D NULL) {
+	if (in_dev) {
 		/* Any address will do - we take the first */
-		struct in_ifaddr *ifa=3Din_dev->ifa_list;
-		if (ifa !=3D NULL) {
+		const struct in_ifaddr *ifa =3D in_dev->ifa_list;
+		if (ifa) {
 			memcpy(eth->h_source, dev->dev_addr, 6);
 			memset(eth->h_dest, 0xfc, 2);
 			memcpy(eth->h_dest+2, &ifa->ifa_address, 4);
@@ -1013,26 +1008,25 @@ plip_rewrite_address(struct net_device *
=20
 static int
 plip_hard_header(struct sk_buff *skb, struct net_device *dev,
-                 unsigned short type, void *daddr,
-	         void *saddr, unsigned len)
+		 unsigned short type, const void *daddr,
+		 const void *saddr, unsigned len)
 {
-	struct net_local *nl =3D netdev_priv(dev);
 	int ret;
=20
-	if ((ret =3D nl->orig_hard_header(skb, dev, type, daddr, saddr, len))=
 >=3D 0)
+	ret =3D eth_header(skb, dev, type, daddr, saddr, len);
+	if (ret >=3D 0)
 		plip_rewrite_address (dev, (struct ethhdr *)skb->data);
=20
 	return ret;
 }
=20
-int plip_hard_header_cache(struct neighbour *neigh,
+int plip_hard_header_cache(const struct neighbour *neigh,
                            struct hh_cache *hh)
 {
-	struct net_local *nl =3D neigh->dev->priv;
 	int ret;
=20
-	if ((ret =3D nl->orig_hard_header_cache(neigh, hh)) =3D=3D 0)
-	{
+	ret =3D eth_header_cache(neigh, hh);
+	if (ret =3D=3D 0) {
 		struct ethhdr *eth;
=20
 		eth =3D (struct ethhdr*)(((u8*)hh->hh_data) +
--- a/drivers/net/wireless/airo.c	2007-08-24 13:41:15.000000000 -0700
+++ b/drivers/net/wireless/airo.c	2007-08-24 13:41:17.000000000 -0700
@@ -2696,9 +2696,13 @@ static int mpi_map_card(struct airo_info
 	return rc;
 }
=20
+static const struct header_ops airo_header_ops =3D {
+	.parse =3D wll_header_parse,
+};
+
 static void wifi_setup(struct net_device *dev)
 {
-	dev->hard_header_parse  =3D wll_header_parse;
+	dev->header_ops =3D &airo_header_ops;
 	dev->hard_start_xmit =3D &airo_start_xmit11;
 	dev->get_stats =3D &airo_get_stats;
 	dev->set_mac_address =3D &airo_set_mac_address;
--- a/drivers/net/wireless/hostap/hostap.h	2007-08-24 13:41:02.00000000=
0 -0700
+++ b/drivers/net/wireless/hostap/hostap.h	2007-08-24 13:41:17.00000000=
0 -0700
@@ -30,8 +30,7 @@ void hostap_dump_rx_header(const char *n
 			   const struct hfa384x_rx_frame *rx);
 void hostap_dump_tx_header(const char *name,
 			   const struct hfa384x_tx_frame *tx);
-int hostap_80211_header_parse(struct sk_buff *skb, unsigned char *hadd=
r);
-int hostap_80211_prism_header_parse(struct sk_buff *skb, unsigned char=
 *haddr);
+extern const struct header_ops hostap_80211_ops;
 int hostap_80211_get_hdrlen(u16 fc);
 struct net_device_stats *hostap_get_stats(struct net_device *dev);
 void hostap_setup_dev(struct net_device *dev, local_info_t *local,
--- a/drivers/net/wireless/hostap/hostap_hw.c	2007-08-24 13:41:02.00000=
0000 -0700
+++ b/drivers/net/wireless/hostap/hostap_hw.c	2007-08-24 13:41:17.00000=
0000 -0700
@@ -3255,11 +3255,10 @@ while (0)
 	INIT_LIST_HEAD(&local->bss_list);
=20
 	hostap_setup_dev(dev, local, 1);
-	local->saved_eth_header_parse =3D dev->hard_header_parse;
=20
 	dev->hard_start_xmit =3D hostap_master_start_xmit;
 	dev->type =3D ARPHRD_IEEE80211;
-	dev->hard_header_parse =3D hostap_80211_header_parse;
+	dev->header_ops =3D &hostap_80211_ops;
=20
 	rtnl_lock();
 	ret =3D dev_alloc_name(dev, "wifi%d");
--- a/drivers/net/wireless/hostap/hostap_ioctl.c	2007-08-24 13:41:02.00=
0000000 -0700
+++ b/drivers/net/wireless/hostap/hostap_ioctl.c	2007-08-24 13:41:17.00=
0000000 -0700
@@ -896,11 +896,8 @@ static void hostap_monitor_set_type(loca
 	if (local->monitor_type =3D=3D PRISM2_MONITOR_PRISM ||
 	    local->monitor_type =3D=3D PRISM2_MONITOR_CAPHDR) {
 		dev->type =3D ARPHRD_IEEE80211_PRISM;
-		dev->hard_header_parse =3D
-			hostap_80211_prism_header_parse;
 	} else {
 		dev->type =3D ARPHRD_IEEE80211;
-		dev->hard_header_parse =3D hostap_80211_header_parse;
 	}
 }
=20
@@ -1140,7 +1137,7 @@ static int hostap_monitor_mode_disable(l
=20
 	printk(KERN_DEBUG "%s: Disabling monitor mode\n", dev->name);
 	dev->type =3D ARPHRD_ETHER;
-	dev->hard_header_parse =3D local->saved_eth_header_parse;
+
 	if (local->func->cmd(dev, HFA384X_CMDCODE_TEST |
 			     (HFA384X_TEST_STOP << 8),
 			     0, NULL, NULL))
--- a/drivers/net/wireless/hostap/hostap_main.c	2007-08-24 13:41:02.000=
000000 -0700
+++ b/drivers/net/wireless/hostap/hostap_main.c	2007-08-24 13:41:17.000=
000000 -0700
@@ -587,24 +587,27 @@ void hostap_dump_tx_header(const char *n
 }
=20
=20
-int hostap_80211_header_parse(struct sk_buff *skb, unsigned char *hadd=
r)
+int hostap_80211_header_parse(const struct sk_buff *skb, unsigned char=
 *haddr)
 {
-	memcpy(haddr, skb_mac_header(skb) + 10, ETH_ALEN); /* addr2 */
-	return ETH_ALEN;
-}
+	struct hostap_interface *iface =3D netdev_priv(skb->dev);
+	local_info_t *local =3D iface->local;
=20
+	if (local->monitor_type =3D=3D PRISM2_MONITOR_PRISM ||
+	    local->monitor_type =3D=3D PRISM2_MONITOR_CAPHDR) {
+		const unsigned char *mac =3D skb_mac_header(skb);
+
+		if (*(u32 *)mac =3D=3D LWNG_CAP_DID_BASE) {
+			memcpy(haddr,
+			       mac + sizeof(struct linux_wlan_ng_prism_hdr) + 10,
+			       ETH_ALEN); /* addr2 */
+		} else { /* (*(u32 *)mac =3D=3D htonl(LWNG_CAPHDR_VERSION)) */
+			memcpy(haddr,
+			       mac + sizeof(struct linux_wlan_ng_cap_hdr) + 10,
+			       ETH_ALEN); /* addr2 */
+		}
+	} else
+		memcpy(haddr, skb_mac_header(skb) + 10, ETH_ALEN); /* addr2 */
=20
-int hostap_80211_prism_header_parse(struct sk_buff *skb, unsigned char=
 *haddr)
-{
-	const unsigned char *mac =3D skb_mac_header(skb);
-
-	if (*(u32 *)mac =3D=3D LWNG_CAP_DID_BASE) {
-		memcpy(haddr, mac + sizeof(struct linux_wlan_ng_prism_hdr) + 10,
-		       ETH_ALEN); /* addr2 */
-	} else { /* (*(u32 *)mac =3D=3D htonl(LWNG_CAPHDR_VERSION)) */
-		memcpy(haddr, mac + sizeof(struct linux_wlan_ng_cap_hdr) + 10,
-		       ETH_ALEN); /* addr2 */
-	}
 	return ETH_ALEN;
 }
=20
@@ -836,6 +839,15 @@ static void prism2_tx_timeout(struct net
 	local->func->schedule_reset(local);
 }
=20
+const struct header_ops hostap_80211_ops =3D {
+	.create		=3D eth_header,
+	.rebuild	=3D eth_rebuild_header,
+	.cache		=3D eth_header_cache,
+	.cache_update	=3D eth_header_cache_update,
+
+	.parse		=3D hostap_80211_header_parse,
+};
+EXPORT_SYMBOL(hostap_80211_ops);
=20
 void hostap_setup_dev(struct net_device *dev, local_info_t *local,
 		      int main_dev)
@@ -876,7 +888,6 @@ void hostap_setup_dev(struct net_device=20
 	netif_stop_queue(dev);
 }
=20
-
 static int hostap_enable_hostapd(local_info_t *local, int rtnl_locked)
 {
 	struct net_device *dev =3D local->dev;
@@ -894,7 +905,7 @@ static int hostap_enable_hostapd(local_i
=20
 	local->apdev->hard_start_xmit =3D hostap_mgmt_start_xmit;
 	local->apdev->type =3D ARPHRD_IEEE80211;
-	local->apdev->hard_header_parse =3D hostap_80211_header_parse;
+	local->apdev->header_ops =3D &hostap_80211_ops;
=20
 	return 0;
 }
--- a/drivers/net/wireless/hostap/hostap_wlan.h	2007-08-24 13:41:02.000=
000000 -0700
+++ b/drivers/net/wireless/hostap/hostap_wlan.h	2007-08-24 13:41:17.000=
000000 -0700
@@ -735,8 +735,6 @@ struct local_info {
 		PRISM2_MONITOR_80211 =3D 0, PRISM2_MONITOR_PRISM =3D 1,
 		PRISM2_MONITOR_CAPHDR =3D 2
 	} monitor_type;
-	int (*saved_eth_header_parse)(struct sk_buff *skb,
-				      unsigned char *haddr);
 	int monitor_allow_fcserr;
=20
 	int hostapd; /* whether user space daemon, hostapd, is used for AP
--- a/include/linux/isdn.h	2007-08-24 13:41:02.000000000 -0700
+++ b/include/linux/isdn.h	2007-08-24 13:41:17.000000000 -0700
@@ -353,13 +353,6 @@ typedef struct isdn_net_local_s {
                                        /* a particular channel (includ=
ing  */
                                        /* the frame_cnt               =
     */
=20
-  int                    (*org_hhc)(
-				    struct neighbour *neigh,
-				    struct hh_cache *hh);
-                                       /* Ptr to orig. header_cache_up=
date */
-  void                   (*org_hcu)(struct hh_cache *,
-				    struct net_device *,
-                                    unsigned char *);
   int  pppbind;                        /* ippp device for bindings    =
     */
   int					dialtimeout;	/* How long shall we try on dialing? (jiffies) =
*/
   int					dialwait;		/* How long shall we wait after failed attempt? (=
jiffies) */
--- a/drivers/s390/net/qeth.h	2007-08-24 13:41:02.000000000 -0700
+++ b/drivers/s390/net/qeth.h	2007-08-24 13:41:17.000000000 -0700
@@ -833,8 +833,7 @@ struct qeth_card {
 	struct qeth_qdio_info qdio;
 	struct qeth_perf_stats perf_stats;
 	int use_hard_stop;
-	int (*orig_hard_header)(struct sk_buff *,struct net_device *,
-				unsigned short,void *,void *,unsigned);
+	const struct header_ops *orig_header_ops;
 	struct qeth_osn_info osn_info;
 	atomic_t force_alloc_skb;
 };
--- a/drivers/s390/net/qeth_main.c	2007-08-24 13:41:15.000000000 -0700
+++ b/drivers/s390/net/qeth_main.c	2007-08-24 13:41:17.000000000 -0700
@@ -160,6 +160,9 @@ qeth_set_multicast_list(struct net_devic
 static void
 qeth_setadp_promisc_mode(struct qeth_card *);
=20
+static int
+qeth_hard_header_parse(const struct sk_buff *skb, unsigned char *haddr=
);
+
 static void
 qeth_notify_processes(void)
 {
@@ -3769,8 +3772,8 @@ qeth_get_netdevice(enum qeth_card_types=20
 /*hard_header fake function; used in case fake_ll is set */
 static int
 qeth_fake_header(struct sk_buff *skb, struct net_device *dev,
-		     unsigned short type, void *daddr, void *saddr,
-		     unsigned len)
+		 unsigned short type, const void *daddr, const void *saddr,
+		 unsigned len)
 {
 	if(dev->type =3D=3D ARPHRD_IEEE802_TR){
 		struct trh_hdr *hdr;
@@ -3793,6 +3796,11 @@ qeth_fake_header(struct sk_buff *skb, st
 	}
 }
=20
+static const struct header_ops qeth_fake_ops =3D {
+	.create	=3D qeth_fake_header,
+	.parse  =3D qeth_hard_header_parse,
+};
+
 static int
 qeth_send_packet(struct qeth_card *, struct sk_buff *);
=20
@@ -4584,7 +4592,7 @@ qeth_send_packet(struct qeth_card *card,
 		[qeth_get_priority_queue(card, skb, ipv, cast_type)];
 	if (!card->options.layer2) {
 		ipv =3D qeth_get_ip_version(skb);
-		if ((card->dev->hard_header =3D=3D qeth_fake_header) && ipv) {
+		if ((card->dev->header_ops =3D=3D &qeth_fake_ops) && ipv) {
 			new_skb =3D qeth_pskb_unshare(skb, GFP_ATOMIC);
 			if (!new_skb)
 				return -ENOMEM;
@@ -6493,6 +6501,9 @@ qeth_hard_header_parse(const struct sk_b
 	const struct qeth_card *card;
 	const struct ethhdr *eth;
=20
+	if (dev->type !=3D ARPHRD_IEEE802_TR)
+		return 0;
+
 	card =3D qeth_get_card_from_dev(skb->dev);
 	if (card->options.layer2)
 		goto haveheader;
@@ -6523,6 +6534,10 @@ haveheader:
 	return ETH_ALEN;
 }
=20
+static const struct header_ops qeth_null_ops =3D {
+	.parse =3D qeth_hard_header_parse,
+};
+
 static int
 qeth_netdev_init(struct net_device *dev)
 {
@@ -6547,12 +6562,8 @@ qeth_netdev_init(struct net_device *dev)
 	dev->vlan_rx_kill_vid =3D qeth_vlan_rx_kill_vid;
 	dev->vlan_rx_add_vid =3D qeth_vlan_rx_add_vid;
 #endif
-	if (qeth_get_netdev_flags(card) & IFF_NOARP) {
-		dev->rebuild_header =3D NULL;
-		dev->hard_header =3D NULL;
-		dev->header_cache_update =3D NULL;
-		dev->hard_header_cache =3D NULL;
-	}
+	dev->header_ops =3D &qeth_null_ops;
+
 #ifdef CONFIG_QETH_IPV6
 	/*IPv6 address autoconfiguration stuff*/
 	if (!(card->info.unique_id & UNIQUE_ID_NOT_BY_CARD))
@@ -6560,11 +6571,8 @@ qeth_netdev_init(struct net_device *dev)
 #endif
 	if (card->options.fake_ll &&
 		(qeth_get_netdev_flags(card) & IFF_NOARP))
-			dev->hard_header =3D qeth_fake_header;
-	if (dev->type =3D=3D ARPHRD_IEEE802_TR)
-		dev->hard_header_parse =3D NULL;
-	else
-		dev->hard_header_parse =3D qeth_hard_header_parse;
+			dev->header_ops =3D &qeth_fake_ops;
+
 	dev->set_mac_address =3D qeth_layer2_set_mac_address;
 	dev->flags |=3D qeth_get_netdev_flags(card);
 	if ((card->options.fake_broadcast) ||
@@ -6668,10 +6676,10 @@ retry:
 	}
 	/*network device will be recovered*/
 	if (card->dev) {
-		card->dev->hard_header =3D card->orig_hard_header;
+		card->dev->header_ops =3D card->orig_header_ops;
 		if (card->options.fake_ll &&
 		    (qeth_get_netdev_flags(card) & IFF_NOARP))
-			card->dev->hard_header =3D qeth_fake_header;
+			card->dev->header_ops =3D &qeth_fake_ops;
 		return 0;
 	}
 	/* at first set_online allocate netdev */
@@ -6685,7 +6693,7 @@ retry:
 		goto out;
 	}
 	card->dev->priv =3D card;
-	card->orig_hard_header =3D card->dev->hard_header;
+	card->orig_header_ops =3D card->dev->header_ops;
 	card->dev->type =3D qeth_get_arphdr_type(card->info.type,
 					       card->info.link_type);
 	card->dev->init =3D qeth_netdev_init;
@@ -8231,7 +8239,7 @@ qeth_arp_constructor(struct neighbour *n
 	if (card =3D=3D NULL)
 		goto out;
 	if((card->options.layer2) ||
-	   (card->dev->hard_header =3D=3D qeth_fake_header))
+	   (card->dev->header_ops =3D=3D &qeth_fake_ops))
 		goto out;
=20
 	rcu_read_lock();
--- a/drivers/net/appletalk/cops.c	2007-08-24 13:41:02.000000000 -0700
+++ b/drivers/net/appletalk/cops.c	2007-08-24 13:41:17.000000000 -0700
@@ -194,10 +194,6 @@ static void cops_timeout(struct net_devi
 static void cops_rx (struct net_device *dev);
 static int  cops_send_packet (struct sk_buff *skb, struct net_device *=
dev);
 static void set_multicast_list (struct net_device *dev);
-static int  cops_hard_header (struct sk_buff *skb, struct net_device *=
dev,
-			      unsigned short type, void *daddr, void *saddr,=20
-			      unsigned len);
-
 static int  cops_ioctl (struct net_device *dev, struct ifreq *rq, int =
cmd);
 static int  cops_close (struct net_device *dev);
 static struct net_device_stats *cops_get_stats (struct net_device *dev=
);
@@ -333,7 +329,6 @@ static int __init cops_probe1(struct net
 	dev->base_addr =3D ioaddr;
=20
         lp =3D netdev_priv(dev);
-        memset(lp, 0, sizeof(struct cops_local));
         spin_lock_init(&lp->lock);
=20
 	/* Copy local board variable to lp struct. */
@@ -342,7 +337,7 @@ static int __init cops_probe1(struct net
 	dev->hard_start_xmit    =3D cops_send_packet;
 	dev->tx_timeout		=3D cops_timeout;
 	dev->watchdog_timeo	=3D HZ * 2;
-	dev->hard_header	=3D cops_hard_header;
+
         dev->get_stats          =3D cops_get_stats;
 	dev->open               =3D cops_open;
         dev->stop               =3D cops_close;
@@ -947,19 +942,6 @@ static void set_multicast_list(struct ne
 }
=20
 /*
- *      Another Dummy function to keep the Appletalk layer happy.
- */
-=20
-static int cops_hard_header(struct sk_buff *skb, struct net_device *de=
v,
-			    unsigned short type, void *daddr, void *saddr,=20
-			    unsigned len)
-{
-        if(cops_debug >=3D 3)
-                printk("%s: cops_hard_header executed. Wow!\n", dev->n=
ame);
-        return 0;
-}
-
-/*
  *      System ioctls for the COPS LocalTalk card.
  */
 =20
--- a/drivers/net/appletalk/ltpc.c	2007-08-24 13:41:02.000000000 -0700
+++ b/drivers/net/appletalk/ltpc.c	2007-08-24 13:41:17.000000000 -0700
@@ -870,15 +870,6 @@ static void set_multicast_list(struct ne
 	/* Actually netatalk needs fixing! */
 }
=20
-static int ltpc_hard_header (struct sk_buff *skb, struct net_device *d=
ev,=20
-	unsigned short type, void *daddr, void *saddr, unsigned len)
-{
-	if(debug & DEBUG_VERBOSE)
-		printk("ltpc_hard_header called for device %s\n",
-			dev->name);
-	return 0;
-}
-
 static int ltpc_poll_counter;
=20
 static void ltpc_poll(unsigned long l)
@@ -1143,7 +1134,6 @@ struct net_device * __init ltpc_probe(vo
=20
 	/* Fill in the fields of the device structure with ethernet-generic v=
alues. */
 	dev->hard_start_xmit =3D ltpc_xmit;
-	dev->hard_header =3D ltpc_hard_header;
 	dev->get_stats =3D ltpc_get_stats;
=20
 	/* add the ltpc-specific things */
--- a/drivers/net/wan/cycx_x25.c	2007-08-24 13:41:02.000000000 -0700
+++ b/drivers/net/wan/cycx_x25.c	2007-08-24 13:41:17.000000000 -0700
@@ -131,14 +131,15 @@ static int cycx_wan_update(struct wan_de
 	   cycx_wan_del_if(struct wan_device *wandev, struct net_device *dev)=
;
=20
 /* Network device interface */
-static int cycx_netdevice_init(struct net_device *dev),
-	   cycx_netdevice_open(struct net_device *dev),
-	   cycx_netdevice_stop(struct net_device *dev),
-	   cycx_netdevice_hard_header(struct sk_buff *skb,
-				     struct net_device *dev, u16 type,
-				     void *daddr, void *saddr, unsigned len),
-	   cycx_netdevice_rebuild_header(struct sk_buff *skb),
-	   cycx_netdevice_hard_start_xmit(struct sk_buff *skb,
+static int cycx_netdevice_init(struct net_device *dev);
+static int cycx_netdevice_open(struct net_device *dev);
+static int cycx_netdevice_stop(struct net_device *dev);
+static int cycx_netdevice_hard_header(struct sk_buff *skb,
+				      struct net_device *dev, u16 type,
+				      const void *daddr, const void *saddr,
+				      unsigned len);
+static int cycx_netdevice_rebuild_header(struct sk_buff *skb);
+static int cycx_netdevice_hard_start_xmit(struct sk_buff *skb,
 					  struct net_device *dev);
=20
 static struct net_device_stats *
@@ -468,7 +469,14 @@ static int cycx_wan_del_if(struct wan_de
 	return 0;
 }
=20
+
 /* Network Device Interface */
+
+static const struct header_ops cycx_header_ops =3D {
+	.create =3D cycx_netdevice_hard_header,
+	.rebuild =3D cycx_netdevice_rebuild_header,
+};
+
 /* Initialize Linux network interface.
  *
  * This routine is called only once for each interface, during Linux n=
etwork
@@ -483,8 +491,8 @@ static int cycx_netdevice_init(struct ne
 	/* Initialize device driver entry points */
 	dev->open		=3D cycx_netdevice_open;
 	dev->stop		=3D cycx_netdevice_stop;
-	dev->hard_header	=3D cycx_netdevice_hard_header;
-	dev->rebuild_header	=3D cycx_netdevice_rebuild_header;
+	dev->header_ops		=3D &cycx_header_ops;
+
 	dev->hard_start_xmit	=3D cycx_netdevice_hard_start_xmit;
 	dev->get_stats		=3D cycx_netdevice_get_stats;
=20
@@ -555,7 +563,8 @@ static int cycx_netdevice_stop(struct ne
  * Return:	media header length. */
 static int cycx_netdevice_hard_header(struct sk_buff *skb,
 				      struct net_device *dev, u16 type,
-				      void *daddr, void *saddr, unsigned len)
+				      const void *daddr, const void *saddr,
+				      unsigned len)
 {
 	skb->protocol =3D type;
=20
--- a/drivers/net/wan/dlci.c	2007-08-24 13:41:02.000000000 -0700
+++ b/drivers/net/wan/dlci.c	2007-08-24 13:41:17.000000000 -0700
@@ -66,8 +66,8 @@ static void dlci_setup(struct net_device
  */
=20
 static int dlci_header(struct sk_buff *skb, struct net_device *dev,=20
-                           unsigned short type, void *daddr, void *sad=
dr,=20
-                           unsigned len)
+		       unsigned short type, const void *daddr,
+		       const void *saddr, unsigned len)
 {
 	struct frhdr		hdr;
 	struct dlci_local	*dlp;
@@ -485,6 +485,10 @@ static int dlci_ioctl(unsigned int cmd,=20
 	return(err);
 }
=20
+static const struct header_ops dlci_header_ops =3D {
+	.create	=3D dlci_header,
+};
+
 static void dlci_setup(struct net_device *dev)
 {
 	struct dlci_local *dlp =3D dev->priv;
@@ -494,7 +498,7 @@ static void dlci_setup(struct net_device
 	dev->stop		=3D dlci_close;
 	dev->do_ioctl		=3D dlci_dev_ioctl;
 	dev->hard_start_xmit	=3D dlci_transmit;
-	dev->hard_header	=3D dlci_header;
+	dev->header_ops		=3D &dlci_header_ops;
 	dev->get_stats		=3D dlci_get_stats;
 	dev->change_mtu		=3D dlci_change_mtu;
 	dev->destructor		=3D free_netdev;
--- a/drivers/net/wan/hdlc.c	2007-08-24 13:41:02.000000000 -0700
+++ b/drivers/net/wan/hdlc.c	2007-08-24 13:41:17.000000000 -0700
@@ -222,6 +222,8 @@ int hdlc_ioctl(struct net_device *dev, s
 	return -EINVAL;
 }
=20
+static const struct header_ops hdlc_null_ops;
+
 static void hdlc_setup_dev(struct net_device *dev)
 {
 	/* Re-init all variables changed by HDLC protocol drivers,
@@ -233,13 +235,9 @@ static void hdlc_setup_dev(struct net_de
 	dev->type		 =3D ARPHRD_RAWHDLC;
 	dev->hard_header_len	 =3D 16;
 	dev->addr_len		 =3D 0;
-	dev->hard_header	 =3D NULL;
-	dev->rebuild_header	 =3D NULL;
-	dev->set_mac_address	 =3D NULL;
-	dev->hard_header_cache	 =3D NULL;
-	dev->header_cache_update =3D NULL;
+	dev->header_ops		 =3D &hdlc_null_ops;
+
 	dev->change_mtu		 =3D hdlc_change_mtu;
-	dev->hard_header_parse	 =3D NULL;
 }
=20
 static void hdlc_setup(struct net_device *dev)
--- a/drivers/net/wan/hdlc_cisco.c	2007-08-24 13:41:02.000000000 -0700
+++ b/drivers/net/wan/hdlc_cisco.c	2007-08-24 13:41:17.000000000 -0700
@@ -74,7 +74,7 @@ static inline struct cisco_state * state
=20
=20
 static int cisco_hard_header(struct sk_buff *skb, struct net_device *d=
ev,
-			     u16 type, void *daddr, void *saddr,
+			     u16 type, const void *daddr, const void *saddr,
 			     unsigned int len)
 {
 	struct hdlc_header *data;
@@ -309,7 +309,6 @@ static void cisco_stop(struct net_device
 }
=20
=20
-
 static struct hdlc_proto proto =3D {
 	.start		=3D cisco_start,
 	.stop		=3D cisco_stop,
@@ -317,7 +316,10 @@ static struct hdlc_proto proto =3D {
 	.ioctl		=3D cisco_ioctl,
 	.module		=3D THIS_MODULE,
 };
-=20
+
+static const struct header_ops cisco_header_ops =3D {
+	.create =3D cisco_hard_header,
+};
 =20
 static int cisco_ioctl(struct net_device *dev, struct ifreq *ifr)
 {
@@ -365,7 +367,7 @@ static int cisco_ioctl(struct net_device
=20
 		memcpy(&state(hdlc)->settings, &new_settings, size);
 		dev->hard_start_xmit =3D hdlc->xmit;
-		dev->hard_header =3D cisco_hard_header;
+		dev->header_ops =3D &cisco_header_ops;
 		dev->type =3D ARPHRD_CISCO;
 		netif_dormant_on(dev);
 		return 0;
--- a/drivers/net/wan/hdlc_ppp.c	2007-08-24 13:41:02.000000000 -0700
+++ b/drivers/net/wan/hdlc_ppp.c	2007-08-24 13:41:17.000000000 -0700
@@ -73,7 +73,7 @@ static void ppp_close(struct net_device=20
=20
 	sppp_close(dev);
 	sppp_detach(dev);
-	dev->rebuild_header =3D NULL;
+
 	dev->change_mtu =3D state(hdlc)->old_change_mtu;
 	dev->mtu =3D HDLC_MAX_MTU;
 	dev->hard_header_len =3D 16;
--- a/drivers/net/wan/lmc/lmc_proto.c	2007-08-24 13:41:02.000000000 -07=
00
+++ b/drivers/net/wan/lmc/lmc_proto.c	2007-08-24 13:41:17.000000000 -07=
00
@@ -111,7 +111,7 @@ void lmc_proto_attach(lmc_softc_t *sc) /
              * They set a few basics because they don't use sync_ppp
              */
             dev->flags |=3D IFF_POINTOPOINT;
-            dev->hard_header =3D NULL;
+
             dev->hard_header_len =3D 0;
             dev->addr_len =3D 0;
         }
--- a/drivers/net/wan/syncppp.c	2007-08-24 13:41:02.000000000 -0700
+++ b/drivers/net/wan/syncppp.c	2007-08-24 13:41:17.000000000 -0700
@@ -358,8 +358,10 @@ done:
  *	Handle transmit packets.
  */
 =20
-static int sppp_hard_header(struct sk_buff *skb, struct net_device *de=
v, __u16 type,
-		void *daddr, void *saddr, unsigned int len)
+static int sppp_hard_header(struct sk_buff *skb,
+			    struct net_device *dev, __u16 type,
+			    const void *daddr, const void *saddr,
+			    unsigned int len)
 {
 	struct sppp *sp =3D (struct sppp *)sppp_of(dev);
 	struct ppp_header *h;
@@ -391,10 +393,9 @@ static int sppp_hard_header(struct sk_bu
 	return sizeof(struct ppp_header);
 }
=20
-static int sppp_rebuild_header(struct sk_buff *skb)
-{
-	return 0;
-}
+static const struct header_ops sppp_header_ops =3D {
+	.create =3D sppp_hard_header,
+};
=20
 /*
  * Send keepalive packets, every 10 seconds.
@@ -1097,8 +1098,8 @@ void sppp_attach(struct ppp_device *pd)
 	 *	hard_start_xmit.
 	 */
 	=20
-	dev->hard_header =3D sppp_hard_header;
-	dev->rebuild_header =3D sppp_rebuild_header;
+	dev->header_ops =3D &sppp_header_ops;
+
 	dev->tx_queue_len =3D 10;
 	dev->type =3D ARPHRD_HDLC;
 	dev->addr_len =3D 0;
@@ -1114,8 +1115,6 @@ void sppp_attach(struct ppp_device *pd)
 	dev->stop =3D sppp_close;
 #endif=09
 	dev->change_mtu =3D sppp_change_mtu;
-	dev->hard_header_cache =3D NULL;
-	dev->header_cache_update =3D NULL;
 	dev->flags =3D IFF_MULTICAST|IFF_POINTOPOINT|IFF_NOARP;
 }
=20
--- a/drivers/net/wireless/strip.c	2007-08-24 13:41:02.000000000 -0700
+++ b/drivers/net/wireless/strip.c	2007-08-24 13:41:17.000000000 -0700
@@ -1630,8 +1630,8 @@ static void strip_IdleTask(unsigned long
  */
=20
 static int strip_header(struct sk_buff *skb, struct net_device *dev,
-			unsigned short type, void *daddr, void *saddr,
-			unsigned len)
+			unsigned short type, const void *daddr,
+			const void *saddr, unsigned len)
 {
 	struct strip *strip_info =3D netdev_priv(dev);
 	STRIP_Header *header =3D (STRIP_Header *) skb_push(skb, sizeof(STRIP_=
Header));
@@ -2496,6 +2496,11 @@ static int strip_close_low(struct net_de
 	return 0;
 }
=20
+static const struct header_ops strip_header_ops =3D {
+	.create =3D strip_header,
+	.rebuild =3D strip_rebuild_header,
+};
+
 /*
  * This routine is called by DDI when the
  * (dynamically assigned) device is registered
@@ -2532,8 +2537,8 @@ static void strip_dev_setup(struct net_d
 	dev->open =3D strip_open_low;
 	dev->stop =3D strip_close_low;
 	dev->hard_start_xmit =3D strip_xmit;
-	dev->hard_header =3D strip_header;
-	dev->rebuild_header =3D strip_rebuild_header;
+	dev->header_ops =3D &strip_header_ops;
+
 	dev->set_mac_address =3D strip_set_mac_address;
 	dev->get_stats =3D strip_get_stats;
 	dev->change_mtu =3D strip_change_mtu;
--- a/drivers/net/myri_sbus.c	2007-08-24 13:41:02.000000000 -0700
+++ b/drivers/net/myri_sbus.c	2007-08-24 13:41:17.000000000 -0700
@@ -682,8 +682,9 @@ static int myri_start_xmit(struct sk_buf
  * saddr=3DNULL	means use device source address
  * daddr=3DNULL	means leave destination address (eg unresolved arp)
  */
-static int myri_header(struct sk_buff *skb, struct net_device *dev, un=
signed short type,
-		       void *daddr, void *saddr, unsigned len)
+static int myri_header(struct sk_buff *skb, struct net_device *dev,
+		       unsigned short type, const void *daddr,
+		       const void *saddr, unsigned len)
 {
 	struct ethhdr *eth =3D (struct ethhdr *) skb_push(skb, ETH_HLEN);
 	unsigned char *pad =3D (unsigned char *) skb_push(skb, MYRI_PAD_LEN);
@@ -765,18 +766,18 @@ static int myri_rebuild_header(struct sk
 	return 0;
 }
=20
-int myri_header_cache(struct neighbour *neigh, struct hh_cache *hh)
+static int myri_header_cache(const struct neighbour *neigh, struct hh_=
cache *hh)
 {
 	unsigned short type =3D hh->hh_type;
 	unsigned char *pad;
 	struct ethhdr *eth;
-	struct net_device *dev =3D neigh->dev;
+	const struct net_device *dev =3D neigh->dev;
=20
 	pad =3D ((unsigned char *) hh->hh_data) +
 		HH_DATA_OFF(sizeof(*eth) + MYRI_PAD_LEN);
 	eth =3D (struct ethhdr *) (pad + MYRI_PAD_LEN);
=20
-	if (type =3D=3D __constant_htons(ETH_P_802_3))
+	if (type =3D=3D htons(ETH_P_802_3))
 		return -1;
=20
 	/* Refill MyriNet padding identifiers, this is just being anal. */
@@ -792,7 +793,9 @@ int myri_header_cache(struct neighbour *
=20
=20
 /* Called by Address Resolution module to notify changes in address. *=
/
-void myri_header_cache_update(struct hh_cache *hh, struct net_device *=
dev, unsigned char * haddr)
+void myri_header_cache_update(struct hh_cache *hh,
+			      const struct net_device *dev,
+			      const unsigned char * haddr)
 {
 	memcpy(((u8*)hh->hh_data) + HH_DATA_OFF(sizeof(struct ethhdr)),
 	       haddr, dev->addr_len);
@@ -890,6 +893,13 @@ static void dump_eeprom(struct myri_eth=20
 }
 #endif
=20
+static const struct header_ops myri_header_ops =3D {
+	.create		=3D myri_header,
+	.rebuild	=3D myri_rebuild_header,
+	.cache	 	=3D myri_header_cache,
+	.cache_update	=3D myri_header_cache_update,
+};
+
 static int __devinit myri_ether_init(struct sbus_dev *sdev)
 {
 	static int num;
@@ -1075,11 +1085,9 @@ static int __devinit myri_ether_init(str
=20
 	dev->mtu		=3D MYRINET_MTU;
 	dev->change_mtu		=3D myri_change_mtu;
-	dev->hard_header	=3D myri_header;
-	dev->rebuild_header	=3D myri_rebuild_header;
+	dev->header_ops		=3D &myri_header_ops;
+
 	dev->hard_header_len	=3D (ETH_HLEN + MYRI_PAD_LEN);
-	dev->hard_header_cache 	=3D myri_header_cache;
-	dev->header_cache_update=3D myri_header_cache_update;
=20
 	/* Load code onto the LANai. */
 	DET(("Loading LANAI firmware\n"));

--=20
Stephen Hemminger <shemminger@linux-foundation.org>

