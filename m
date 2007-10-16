From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] br2684: get rid of broken header code.
Date: Tue, 16 Oct 2007 14:38:50 -0700
Message-ID: <20071016143850.5fcd5345@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: chas@cmf.nrl.navy.mil, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:53257 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756715AbXJPVls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 17:41:48 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Recent header_ops change would break the following dead
code in br2684. Maintaining conditonal code in mainline is wrong.

"Do, or do not. There is no 'try.'" 

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/net/atm/br2684.c	2007-10-11 13:16:27.000000000 -0700
+++ b/net/atm/br2684.c	2007-10-12 11:20:32.000000000 -0700
@@ -24,16 +24,6 @@ Author: Marcell GAL, 2000, XDSL Ltd, Hun
 
 #include "common.h"
 
-/*
- * Define this to use a version of the code which interacts with the higher
- * layers in a more intellegent way, by always reserving enough space for
- * our header at the begining of the packet.  However, there may still be
- * some problems with programs like tcpdump.  In 2.5 we'll sort out what
- * we need to do to get this perfect.  For now we just will copy the packet
- * if we need space for the header
- */
-/* #define FASTER_VERSION */
-
 #ifdef SKB_DEBUG
 static void skb_debug(const struct sk_buff *skb)
 {
@@ -69,9 +59,7 @@ struct br2684_vcc {
 #ifdef CONFIG_ATM_BR2684_IPFILTER
 	struct br2684_filter filter;
 #endif /* CONFIG_ATM_BR2684_IPFILTER */
-#ifndef FASTER_VERSION
 	unsigned copies_needed, copies_failed;
-#endif /* FASTER_VERSION */
 };
 
 struct br2684_dev {
@@ -147,13 +135,6 @@ static int br2684_xmit_vcc(struct sk_buf
 	struct br2684_vcc *brvcc)
 {
 	struct atm_vcc *atmvcc;
-#ifdef FASTER_VERSION
-	if (brvcc->encaps == e_llc)
-		memcpy(skb_push(skb, 8), llc_oui_pid_pad, 8);
-	/* last 2 bytes of llc_oui_pid_pad are managed by header routines;
-	   yes, you got it: 8 + 2 = sizeof(llc_oui_pid_pad)
-	 */
-#else
 	int minheadroom = (brvcc->encaps == e_llc) ? 10 : 2;
 	if (skb_headroom(skb) < minheadroom) {
 		struct sk_buff *skb2 = skb_realloc_headroom(skb, minheadroom);
@@ -170,7 +151,6 @@ static int br2684_xmit_vcc(struct sk_buf
 		skb_copy_to_linear_data(skb, llc_oui_pid_pad, 10);
 	else
 		memset(skb->data, 0, 2);
-#endif /* FASTER_VERSION */
 	skb_debug(skb);
 
 	ATM_SKB(skb)->vcc = atmvcc = brvcc->atmvcc;
@@ -237,87 +217,6 @@ static struct net_device_stats *br2684_g
 	return &BRPRIV(dev)->stats;
 }
 
-#ifdef FASTER_VERSION
-/*
- * These mirror eth_header and eth_header_cache.  They are not usually
- * exported for use in modules, so we grab them from net_device
- * after ether_setup() is done with it.  Bit of a hack.
- */
-static int (*my_eth_header)(struct sk_buff *, struct net_device *,
-	unsigned short, void *, void *, unsigned);
-static int (*my_eth_header_cache)(struct neighbour *, struct hh_cache *);
-
-static int
-br2684_header(struct sk_buff *skb, struct net_device *dev,
-	      unsigned short type, void *daddr, void *saddr, unsigned len)
-{
-	u16 *pad_before_eth;
-	int t = my_eth_header(skb, dev, type, daddr, saddr, len);
-	if (t > 0) {
-		pad_before_eth = (u16 *) skb_push(skb, 2);
-		*pad_before_eth = 0;
-		return dev->hard_header_len;	/* or return 16; ? */
-	} else
-		return t;
-}
-
-static int
-br2684_header_cache(struct neighbour *neigh, struct hh_cache *hh)
-{
-/* hh_data is 16 bytes long. if encaps is ether-llc we need 24, so
-xmit will add the additional header part in that case */
-	u16 *pad_before_eth = (u16 *)(hh->hh_data);
-	int t = my_eth_header_cache(neigh, hh);
-	DPRINTK("br2684_header_cache, neigh=%p, hh_cache=%p\n", neigh, hh);
-	if (t < 0)
-		return t;
-	else {
-		*pad_before_eth = 0;
-		hh->hh_len = PADLEN + ETH_HLEN;
-	}
-	return 0;
-}
-
-/*
- * This is similar to eth_type_trans, which cannot be used because of
- * our dev->hard_header_len
- */
-static inline __be16 br_type_trans(struct sk_buff *skb, struct net_device *dev)
-{
-	struct ethhdr *eth;
-	unsigned char *rawp;
-	eth = eth_hdr(skb);
-
-	if (is_multicast_ether_addr(eth->h_dest)) {
-		if (!compare_ether_addr(eth->h_dest, dev->broadcast))
-			skb->pkt_type = PACKET_BROADCAST;
-		else
-			skb->pkt_type = PACKET_MULTICAST;
-	}
-
-	else if (compare_ether_addr(eth->h_dest, dev->dev_addr))
-		skb->pkt_type = PACKET_OTHERHOST;
-
-	if (ntohs(eth->h_proto) >= 1536)
-		return eth->h_proto;
-
-	rawp = skb->data;
-
-	/*
-	 * This is a magic hack to spot IPX packets. Older Novell breaks
-	 * the protocol design and runs IPX over 802.3 without an 802.2 LLC
-	 * layer. We look for FFFF which isn't a used 802.2 SSAP/DSAP. This
-	 * won't work for fault tolerant netware but does for the rest.
-	 */
-	if (*(unsigned short *) rawp == 0xFFFF)
-		return htons(ETH_P_802_3);
-
-	/*
-	 * Real 802.2 LLC
-	 */
-	return htons(ETH_P_802_2);
-}
-#endif /* FASTER_VERSION */
 
 /*
  * We remember when the MAC gets set, so we don't override it later with
@@ -448,17 +347,8 @@ static void br2684_push(struct atm_vcc *
 		return;
 	}
 
-#ifdef FASTER_VERSION
-	/* FIXME: tcpdump shows that pointer to mac header is 2 bytes earlier,
-	   than should be. What else should I set? */
-	skb_pull(skb, plen);
-	skb_set_mac_header(skb, -ETH_HLEN);
-	skb->pkt_type = PACKET_HOST;
-	skb->protocol = br_type_trans(skb, net_dev);
-#else
 	skb_pull(skb, plen - ETH_HLEN);
 	skb->protocol = eth_type_trans(skb, net_dev);
-#endif /* FASTER_VERSION */
 #ifdef CONFIG_ATM_BR2684_IPFILTER
 	if (unlikely(packet_fails_filter(skb->protocol, brvcc, skb))) {
 		brdev->stats.rx_dropped++;
@@ -584,13 +474,6 @@ static void br2684_setup(struct net_devi
 	ether_setup(netdev);
 	brdev->net_dev = netdev;
 
-#ifdef FASTER_VERSION
-	my_eth_header = netdev->hard_header;
-	netdev->hard_header = br2684_header;
-	my_eth_header_cache = netdev->hard_header_cache;
-	netdev->hard_header_cache = br2684_header_cache;
-	netdev->hard_header_len = sizeof(llc_oui_pid_pad) + ETH_HLEN;	/* 10 + 14 */
-#endif
 	my_eth_mac_addr = netdev->set_mac_address;
 	netdev->set_mac_address = br2684_mac_addr;
 	netdev->hard_start_xmit = br2684_start_xmit;
@@ -719,16 +602,12 @@ static int br2684_seq_show(struct seq_fi
 
 	list_for_each_entry(brvcc, &brdev->brvccs, brvccs) {
 		seq_printf(seq, "  vcc %d.%d.%d: encaps=%s"
-#ifndef FASTER_VERSION
 				    ", failed copies %u/%u"
-#endif /* FASTER_VERSION */
 				    "\n", brvcc->atmvcc->dev->number,
 				    brvcc->atmvcc->vpi, brvcc->atmvcc->vci,
 				    (brvcc->encaps == e_llc) ? "LLC" : "VC"
-#ifndef FASTER_VERSION
 				    , brvcc->copies_failed
 				    , brvcc->copies_needed
-#endif /* FASTER_VERSION */
 				    );
 #ifdef CONFIG_ATM_BR2684_IPFILTER
 #define b1(var, byte)	((u8 *) &brvcc->filter.var)[byte]
