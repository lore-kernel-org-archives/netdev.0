From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 12/15] net: Kill dev_rebuild_header
Date: Mon, 02 Mar 2015 00:11:09 -0600
Message-ID: <878ufg6i9u.fsf_-_@x220.int.ebiederm.org>
References: <87pp8xx6ik.fsf@x220.int.ebiederm.org>
	<20150227.162131.431559184124647735.davem@davemloft.net>
	<87mw3yg8da.fsf@x220.int.ebiederm.org>
	<20150301.230306.2023670900391030920.davem@davemloft.net>
	<871tl8dlxn.fsf@x220.int.ebiederm.org>
	<87lhjg9byo.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>,
	linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <87lhjg9byo.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Sun, 01 Mar 2015 23:59:11 -0600")
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Now that there are no more users kill dev_rebuild_header and all of it's
implementations.

This is long overdue.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/firewire/net.c                    | 13 --------
 drivers/isdn/i4l/isdn_net.c               | 33 -------------------
 drivers/media/dvb-core/dvb_net.c          |  1 -
 drivers/net/arcnet/arcnet.c               | 55 -------------------------------
 drivers/net/ipvlan/ipvlan_main.c          |  1 -
 drivers/net/macvlan.c                     |  1 -
 drivers/net/wireless/hostap/hostap_main.c |  1 -
 include/linux/etherdevice.h               |  1 -
 include/linux/netdevice.h                 | 12 +------
 net/802/fc.c                              | 21 ------------
 net/802/fddi.c                            | 26 ---------------
 net/802/hippi.c                           | 28 ----------------
 net/8021q/vlan_dev.c                      | 35 --------------------
 net/ethernet/eth.c                        | 34 -------------------
 net/netrom/nr_dev.c                       | 31 -----------------
 net/rose/rose_dev.c                       | 14 --------
 16 files changed, 1 insertion(+), 306 deletions(-)

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index 2c68da1ceeee..f4ea80d602f7 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -237,18 +237,6 @@ static int fwnet_header_create(struct sk_buff *skb, struct net_device *net,
 	return -net->hard_header_len;
 }
 
-static int fwnet_header_rebuild(struct sk_buff *skb)
-{
-	struct fwnet_header *h = (struct fwnet_header *)skb->data;
-
-	if (get_unaligned_be16(&h->h_proto) == ETH_P_IP)
-		return arp_find((unsigned char *)&h->h_dest, skb);
-
-	dev_notice(&skb->dev->dev, "unable to resolve type %04x addresses\n",
-		   be16_to_cpu(h->h_proto));
-	return 0;
-}
-
 static int fwnet_header_cache(const struct neighbour *neigh,
 			      struct hh_cache *hh, __be16 type)
 {
@@ -282,7 +270,6 @@ static int fwnet_header_parse(const struct sk_buff *skb, unsigned char *haddr)
 
 static const struct header_ops fwnet_header_ops = {
 	.create         = fwnet_header_create,
-	.rebuild        = fwnet_header_rebuild,
 	.cache		= fwnet_header_cache,
 	.cache_update	= fwnet_header_cache_update,
 	.parse          = fwnet_header_parse,
diff --git a/drivers/isdn/i4l/isdn_net.c b/drivers/isdn/i4l/isdn_net.c
index 94affa5e6f28..546b7e81161d 100644
--- a/drivers/isdn/i4l/isdn_net.c
+++ b/drivers/isdn/i4l/isdn_net.c
@@ -1951,38 +1951,6 @@ static int isdn_net_header(struct sk_buff *skb, struct net_device *dev,
 	return len;
 }
 
-/* We don't need to send arp, because we have point-to-point connections. */
-static int
-isdn_net_rebuild_header(struct sk_buff *skb)
-{
-	struct net_device *dev = skb->dev;
-	isdn_net_local *lp = netdev_priv(dev);
-	int ret = 0;
-
-	if (lp->p_encap == ISDN_NET_ENCAP_ETHER) {
-		struct ethhdr *eth = (struct ethhdr *) skb->data;
-
-		/*
-		 *      Only ARP/IP is currently supported
-		 */
-
-		if (eth->h_proto != htons(ETH_P_IP)) {
-			printk(KERN_WARNING
-			       "isdn_net: %s don't know how to resolve type %d addresses?\n",
-			       dev->name, (int) eth->h_proto);
-			memcpy(eth->h_source, dev->dev_addr, dev->addr_len);
-			return 0;
-		}
-		/*
-		 *      Try to get ARP to resolve the header.
-		 */
-#ifdef CONFIG_INET
-		ret = arp_find(eth->h_dest, skb);
-#endif
-	}
-	return ret;
-}
-
 static int isdn_header_cache(const struct neighbour *neigh, struct hh_cache *hh,
 			     __be16 type)
 {
@@ -2005,7 +1973,6 @@ static void isdn_header_cache_update(struct hh_cache *hh,
 
 static const struct header_ops isdn_header_ops = {
 	.create = isdn_net_header,
-	.rebuild = isdn_net_rebuild_header,
 	.cache = isdn_header_cache,
 	.cache_update = isdn_header_cache_update,
 };
diff --git a/drivers/media/dvb-core/dvb_net.c b/drivers/media/dvb-core/dvb_net.c
index 686d3277dad1..4a77cb02dffc 100644
--- a/drivers/media/dvb-core/dvb_net.c
+++ b/drivers/media/dvb-core/dvb_net.c
@@ -1190,7 +1190,6 @@ static int dvb_net_stop(struct net_device *dev)
 static const struct header_ops dvb_header_ops = {
 	.create		= eth_header,
 	.parse		= eth_header_parse,
-	.rebuild	= eth_rebuild_header,
 };
 
 
diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index 09de683c167e..10f71c732b59 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -104,7 +104,6 @@ EXPORT_SYMBOL(arcnet_timeout);
 static int arcnet_header(struct sk_buff *skb, struct net_device *dev,
 			 unsigned short type, const void *daddr,
 			 const void *saddr, unsigned len);
-static int arcnet_rebuild_header(struct sk_buff *skb);
 static int go_tx(struct net_device *dev);
 
 static int debug = ARCNET_DEBUG;
@@ -312,7 +311,6 @@ static int choose_mtu(void)
 
 static const struct header_ops arcnet_header_ops = {
 	.create = arcnet_header,
-	.rebuild = arcnet_rebuild_header,
 };
 
 static const struct net_device_ops arcnet_netdev_ops = {
@@ -538,59 +536,6 @@ static int arcnet_header(struct sk_buff *skb, struct net_device *dev,
 	return proto->build_header(skb, dev, type, _daddr);
 }
 
-
-/* 
- * Rebuild the ARCnet hard header. This is called after an ARP (or in the
- * future other address resolution) has completed on this sk_buff. We now
- * let ARP fill in the destination field.
- */
-static int arcnet_rebuild_header(struct sk_buff *skb)
-{
-	struct net_device *dev = skb->dev;
-	struct arcnet_local *lp = netdev_priv(dev);
-	int status = 0;		/* default is failure */
-	unsigned short type;
-	uint8_t daddr=0;
-	struct ArcProto *proto;
-	/*
-	 * XXX: Why not use skb->mac_len?
-	 */
-	if (skb->network_header - skb->mac_header != 2) {
-		BUGMSG(D_NORMAL,
-		       "rebuild_header: shouldn't be here! (hdrsize=%d)\n",
-		       (int)(skb->network_header - skb->mac_header));
-		return 0;
-	}
-	type = *(uint16_t *) skb_pull(skb, 2);
-	BUGMSG(D_DURING, "rebuild header for protocol %Xh\n", type);
-
-	if (type == ETH_P_IP) {
-#ifdef CONFIG_INET
-		BUGMSG(D_DURING, "rebuild header for ethernet protocol %Xh\n", type);
-		status = arp_find(&daddr, skb) ? 1 : 0;
-		BUGMSG(D_DURING, " rebuilt: dest is %d; protocol %Xh\n",
-		       daddr, type);
-#endif
-	} else {
-		BUGMSG(D_NORMAL,
-		       "I don't understand ethernet protocol %Xh addresses!\n", type);
-		dev->stats.tx_errors++;
-		dev->stats.tx_aborted_errors++;
-	}
-
-	/* if we couldn't resolve the address... give up. */
-	if (!status)
-		return 0;
-
-	/* add the _real_ header this time! */
-	proto = arc_proto_map[lp->default_proto[daddr]];
-	proto->build_header(skb, dev, type, daddr);
-
-	return 1;		/* success */
-}
-
-
-
 /* Called by the kernel in order to transmit a packet. */
 netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
 				     struct net_device *dev)
diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index 4f4099d5603d..2950c3780230 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -336,7 +336,6 @@ static int ipvlan_hard_header(struct sk_buff *skb, struct net_device *dev,
 
 static const struct header_ops ipvlan_header_ops = {
 	.create  	= ipvlan_hard_header,
-	.rebuild	= eth_rebuild_header,
 	.parse		= eth_header_parse,
 	.cache		= eth_header_cache,
 	.cache_update	= eth_header_cache_update,
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 1df38bdae2ee..b5e3320ca506 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -550,7 +550,6 @@ static int macvlan_hard_header(struct sk_buff *skb, struct net_device *dev,
 
 static const struct header_ops macvlan_hard_header_ops = {
 	.create  	= macvlan_hard_header,
-	.rebuild	= eth_rebuild_header,
 	.parse		= eth_header_parse,
 	.cache		= eth_header_cache,
 	.cache_update	= eth_header_cache_update,
diff --git a/drivers/net/wireless/hostap/hostap_main.c b/drivers/net/wireless/hostap/hostap_main.c
index 52919ad42726..8f9f3e9fbfce 100644
--- a/drivers/net/wireless/hostap/hostap_main.c
+++ b/drivers/net/wireless/hostap/hostap_main.c
@@ -798,7 +798,6 @@ static void prism2_tx_timeout(struct net_device *dev)
 
 const struct header_ops hostap_80211_ops = {
 	.create		= eth_header,
-	.rebuild	= eth_rebuild_header,
 	.cache		= eth_header_cache,
 	.cache_update	= eth_header_cache_update,
 	.parse		= hostap_80211_header_parse,
diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 1d869d185a0d..606563ef8a72 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -35,7 +35,6 @@ extern const struct header_ops eth_header_ops;
 
 int eth_header(struct sk_buff *skb, struct net_device *dev, unsigned short type,
 	       const void *daddr, const void *saddr, unsigned len);
-int eth_rebuild_header(struct sk_buff *skb);
 int eth_header_parse(const struct sk_buff *skb, unsigned char *haddr);
 int eth_header_cache(const struct neighbour *neigh, struct hh_cache *hh,
 		     __be16 type);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5897b4ea5a3f..2007f3b44d05 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -261,7 +261,6 @@ struct header_ops {
 			   unsigned short type, const void *daddr,
 			   const void *saddr, unsigned int len);
 	int	(*parse)(const struct sk_buff *skb, unsigned char *haddr);
-	int	(*rebuild)(struct sk_buff *skb);
 	int	(*cache)(const struct neighbour *neigh, struct hh_cache *hh, __be16 type);
 	void	(*cache_update)(struct hh_cache *hh,
 				const struct net_device *dev,
@@ -1346,7 +1345,7 @@ enum netdev_priv_flags {
  *			if one wants to override the ndo_*() functions
  *	@ethtool_ops:	Management operations
  *	@fwd_ops:	Management operations
- *	@header_ops:	Includes callbacks for creating,parsing,rebuilding,etc
+ *	@header_ops:	Includes callbacks for creating,parsing,caching,etc
  *			of Layer 2 headers.
  *
  *	@flags:		Interface flags (a la BSD)
@@ -2399,15 +2398,6 @@ static inline int dev_parse_header(const struct sk_buff *skb,
 	return dev->header_ops->parse(skb, haddr);
 }
 
-static inline int dev_rebuild_header(struct sk_buff *skb)
-{
-	const struct net_device *dev = skb->dev;
-
-	if (!dev->header_ops || !dev->header_ops->rebuild)
-		return 0;
-	return dev->header_ops->rebuild(skb);
-}
-
 typedef int gifconf_func_t(struct net_device * dev, char __user * bufptr, int len);
 int register_gifconf(unsigned int family, gifconf_func_t *gifconf);
 static inline int unregister_gifconf(unsigned int family)
diff --git a/net/802/fc.c b/net/802/fc.c
index 7c174b6750cd..7b9219022418 100644
--- a/net/802/fc.c
+++ b/net/802/fc.c
@@ -75,29 +75,8 @@ static int fc_header(struct sk_buff *skb, struct net_device *dev,
 	return -hdr_len;
 }
 
-/*
- *	A neighbour discovery of some species (eg arp) has completed. We
- *	can now send the packet.
- */
-
-static int fc_rebuild_header(struct sk_buff *skb)
-{
-#ifdef CONFIG_INET
-	struct fch_hdr *fch=(struct fch_hdr *)skb->data;
-	struct fcllc *fcllc=(struct fcllc *)(skb->data+sizeof(struct fch_hdr));
-	if(fcllc->ethertype != htons(ETH_P_IP)) {
-		printk("fc_rebuild_header: Don't know how to resolve type %04X addresses ?\n", ntohs(fcllc->ethertype));
-		return 0;
-	}
-	return arp_find(fch->daddr, skb);
-#else
-	return 0;
-#endif
-}
-
 static const struct header_ops fc_header_ops = {
 	.create	 = fc_header,
-	.rebuild = fc_rebuild_header,
 };
 
 static void fc_setup(struct net_device *dev)
diff --git a/net/802/fddi.c b/net/802/fddi.c
index 59e7346f1193..7d3a0af954e8 100644
--- a/net/802/fddi.c
+++ b/net/802/fddi.c
@@ -87,31 +87,6 @@ static int fddi_header(struct sk_buff *skb, struct net_device *dev,
 	return -hl;
 }
 
-
-/*
- * Rebuild the FDDI MAC header. This is called after an ARP
- * (or in future other address resolution) has completed on
- * this sk_buff.  We now let ARP fill in the other fields.
- */
-
-static int fddi_rebuild_header(struct sk_buff	*skb)
-{
-	struct fddihdr *fddi = (struct fddihdr *)skb->data;
-
-#ifdef CONFIG_INET
-	if (fddi->hdr.llc_snap.ethertype == htons(ETH_P_IP))
-		/* Try to get ARP to resolve the header and fill destination address */
-		return arp_find(fddi->daddr, skb);
-	else
-#endif
-	{
-		printk("%s: Don't know how to resolve type %04X addresses.\n",
-		       skb->dev->name, ntohs(fddi->hdr.llc_snap.ethertype));
-		return 0;
-	}
-}
-
-
 /*
  * Determine the packet's protocol ID and fill in skb fields.
  * This routine is called before an incoming packet is passed
@@ -177,7 +152,6 @@ EXPORT_SYMBOL(fddi_change_mtu);
 
 static const struct header_ops fddi_header_ops = {
 	.create		= fddi_header,
-	.rebuild	= fddi_rebuild_header,
 };
 
 
diff --git a/net/802/hippi.c b/net/802/hippi.c
index 2e03f8259dd5..ade1a52cdcff 100644
--- a/net/802/hippi.c
+++ b/net/802/hippi.c
@@ -91,33 +91,6 @@ static int hippi_header(struct sk_buff *skb, struct net_device *dev,
 
 
 /*
- * Rebuild the HIPPI MAC header. This is called after an ARP has
- * completed on this sk_buff. We now let ARP fill in the other fields.
- */
-
-static int hippi_rebuild_header(struct sk_buff *skb)
-{
-	struct hippi_hdr *hip = (struct hippi_hdr *)skb->data;
-
-	/*
-	 * Only IP is currently supported
-	 */
-
-	if(hip->snap.ethertype != htons(ETH_P_IP))
-	{
-		printk(KERN_DEBUG "%s: unable to resolve type %X addresses.\n",skb->dev->name,ntohs(hip->snap.ethertype));
-		return 0;
-	}
-
-	/*
-	 * We don't support dynamic ARP on HIPPI, but we use the ARP
-	 * static ARP tables to hold the I-FIELDs.
-	 */
-	return arp_find(hip->le.daddr, skb);
-}
-
-
-/*
  *	Determine the packet's protocol ID.
  */
 
@@ -186,7 +159,6 @@ EXPORT_SYMBOL(hippi_neigh_setup_dev);
 
 static const struct header_ops hippi_header_ops = {
 	.create		= hippi_header,
-	.rebuild	= hippi_rebuild_header,
 };
 
 
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 118956448cf6..1dcfec8b49f3 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -37,39 +37,6 @@
 #include <linux/netpoll.h>
 
 /*
- *	Rebuild the Ethernet MAC header. This is called after an ARP
- *	(or in future other address resolution) has completed on this
- *	sk_buff. We now let ARP fill in the other fields.
- *
- *	This routine CANNOT use cached dst->neigh!
- *	Really, it is used only when dst->neigh is wrong.
- *
- * TODO:  This needs a checkup, I'm ignorant here. --BLG
- */
-static int vlan_dev_rebuild_header(struct sk_buff *skb)
-{
-	struct net_device *dev = skb->dev;
-	struct vlan_ethhdr *veth = (struct vlan_ethhdr *)(skb->data);
-
-	switch (veth->h_vlan_encapsulated_proto) {
-#ifdef CONFIG_INET
-	case htons(ETH_P_IP):
-
-		/* TODO:  Confirm this will work with VLAN headers... */
-		return arp_find(veth->h_dest, skb);
-#endif
-	default:
-		pr_debug("%s: unable to resolve type %X addresses\n",
-			 dev->name, ntohs(veth->h_vlan_encapsulated_proto));
-
-		ether_addr_copy(veth->h_source, dev->dev_addr);
-		break;
-	}
-
-	return 0;
-}
-
-/*
  *	Create the VLAN header for an arbitrary protocol layer
  *
  *	saddr=NULL	means use device source address
@@ -534,7 +501,6 @@ static int vlan_dev_get_lock_subclass(struct net_device *dev)
 
 static const struct header_ops vlan_header_ops = {
 	.create	 = vlan_dev_hard_header,
-	.rebuild = vlan_dev_rebuild_header,
 	.parse	 = eth_header_parse,
 };
 
@@ -554,7 +520,6 @@ static int vlan_passthru_hard_header(struct sk_buff *skb, struct net_device *dev
 
 static const struct header_ops vlan_passthru_header_ops = {
 	.create	 = vlan_passthru_hard_header,
-	.rebuild = dev_rebuild_header,
 	.parse	 = eth_header_parse,
 };
 
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 238f38d21641..8dbdf6c910b7 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -113,39 +113,6 @@ int eth_header(struct sk_buff *skb, struct net_device *dev,
 EXPORT_SYMBOL(eth_header);
 
 /**
- * eth_rebuild_header- rebuild the Ethernet MAC header.
- * @skb: socket buffer to update
- *
- * This is called after an ARP or IPV6 ndisc it's resolution on this
- * sk_buff. We now let protocol (ARP) fill in the other fields.
- *
- * This routine CANNOT use cached dst->neigh!
- * Really, it is used only when dst->neigh is wrong.
- */
-int eth_rebuild_header(struct sk_buff *skb)
-{
-	struct ethhdr *eth = (struct ethhdr *)skb->data;
-	struct net_device *dev = skb->dev;
-
-	switch (eth->h_proto) {
-#ifdef CONFIG_INET
-	case htons(ETH_P_IP):
-		return arp_find(eth->h_dest, skb);
-#endif
-	default:
-		netdev_dbg(dev,
-		       "%s: unable to resolve type %X addresses.\n",
-		       dev->name, ntohs(eth->h_proto));
-
-		memcpy(eth->h_source, dev->dev_addr, ETH_ALEN);
-		break;
-	}
-
-	return 0;
-}
-EXPORT_SYMBOL(eth_rebuild_header);
-
-/**
  * eth_get_headlen - determine the the length of header for an ethernet frame
  * @data: pointer to start of frame
  * @len: total length of frame
@@ -369,7 +336,6 @@ EXPORT_SYMBOL(eth_validate_addr);
 const struct header_ops eth_header_ops ____cacheline_aligned = {
 	.create		= eth_header,
 	.parse		= eth_header_parse,
-	.rebuild	= eth_rebuild_header,
 	.cache		= eth_header_cache,
 	.cache_update	= eth_header_cache_update,
 };
diff --git a/net/netrom/nr_dev.c b/net/netrom/nr_dev.c
index 6ae063cebf7d..988f542481a8 100644
--- a/net/netrom/nr_dev.c
+++ b/net/netrom/nr_dev.c
@@ -65,36 +65,6 @@ int nr_rx_ip(struct sk_buff *skb, struct net_device *dev)
 	return 1;
 }
 
-#ifdef CONFIG_INET
-
-static int nr_rebuild_header(struct sk_buff *skb)
-{
-	unsigned char *bp = skb->data;
-
-	if (arp_find(bp + 7, skb))
-		return 1;
-
-	bp[6] &= ~AX25_CBIT;
-	bp[6] &= ~AX25_EBIT;
-	bp[6] |= AX25_SSSID_SPARE;
-	bp    += AX25_ADDR_LEN;
-
-	bp[6] &= ~AX25_CBIT;
-	bp[6] |= AX25_EBIT;
-	bp[6] |= AX25_SSSID_SPARE;
-
-	return 0;
-}
-
-#else
-
-static int nr_rebuild_header(struct sk_buff *skb)
-{
-	return 1;
-}
-
-#endif
-
 static int nr_header(struct sk_buff *skb, struct net_device *dev,
 		     unsigned short type,
 		     const void *daddr, const void *saddr, unsigned int len)
@@ -188,7 +158,6 @@ static netdev_tx_t nr_xmit(struct sk_buff *skb, struct net_device *dev)
 
 static const struct header_ops nr_header_ops = {
 	.create	= nr_header,
-	.rebuild= nr_rebuild_header,
 };
 
 static const struct net_device_ops nr_netdev_ops = {
diff --git a/net/rose/rose_dev.c b/net/rose/rose_dev.c
index 90209c1fa49b..369ca81a8c5d 100644
--- a/net/rose/rose_dev.c
+++ b/net/rose/rose_dev.c
@@ -56,19 +56,6 @@ static int rose_header(struct sk_buff *skb, struct net_device *dev,
 	return -37;
 }
 
-static int rose_rebuild_header(struct sk_buff *skb)
-{
-#ifdef CONFIG_INET
-	unsigned char *bp = (unsigned char *)skb->data;
-
-	if (arp_find(bp + 7, skb)) {
-		return 1;
-	}
-
-#endif
-	return 0;
-}
-
 static int rose_set_mac_address(struct net_device *dev, void *addr)
 {
 	struct sockaddr *sa = addr;
@@ -133,7 +120,6 @@ static netdev_tx_t rose_xmit(struct sk_buff *skb, struct net_device *dev)
 
 static const struct header_ops rose_header_ops = {
 	.create	= rose_header,
-	.rebuild = rose_rebuild_header,
 };
 
 static const struct net_device_ops rose_netdev_ops = {
-- 
2.2.1

