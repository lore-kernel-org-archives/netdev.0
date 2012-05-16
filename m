From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 2/4] atm: remove the coupling to token ring support
Date: Tue, 15 May 2012 20:35:42 -0400
Message-ID: <1337128544-18680-3-git-send-email-paul.gortmaker@windriver.com>
References: <1337128544-18680-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:44435 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967098Ab2EPAgZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2012 20:36:25 -0400
In-Reply-To: <1337128544-18680-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The token ring support is going away, so decouple
the atm support from it in advance.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 include/linux/atmlec.h |    7 ---
 net/atm/lec.c          |  138 +++---------------------------------------------
 net/atm/lec.h          |    1 -
 3 files changed, 8 insertions(+), 138 deletions(-)

diff --git a/include/linux/atmlec.h b/include/linux/atmlec.h
index 39c917f..302791e 100644
--- a/include/linux/atmlec.h
+++ b/include/linux/atmlec.h
@@ -21,13 +21,6 @@
 /* Maximum number of LEC interfaces (tweakable) */
 #define MAX_LEC_ITF 48
 
-/*
- * From the total of MAX_LEC_ITF, last NUM_TR_DEVS are reserved for Token Ring.
- * E.g. if MAX_LEC_ITF = 48 and NUM_TR_DEVS = 8, then lec0-lec39 are for
- * Ethernet ELANs and lec40-lec47 are for Token Ring ELANS.
- */
-#define NUM_TR_DEVS 8
-
 typedef enum {
 	l_set_mac_addr,
 	l_del_mac_addr,
diff --git a/net/atm/lec.c b/net/atm/lec.c
index bb35cb7..a7d1721 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -26,11 +26,6 @@
 #include <linux/spinlock.h>
 #include <linux/seq_file.h>
 
-/* TokenRing if needed */
-#ifdef CONFIG_TR
-#include <linux/trdevice.h>
-#endif
-
 /* And atm device */
 #include <linux/atmdev.h>
 #include <linux/atmlec.h>
@@ -163,50 +158,6 @@ static void lec_handle_bridge(struct sk_buff *skb, struct net_device *dev)
 #endif /* defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE) */
 
 /*
- * Modelled after tr_type_trans
- * All multicast and ARE or STE frames go to BUS.
- * Non source routed frames go by destination address.
- * Last hop source routed frames go by destination address.
- * Not last hop source routed frames go by _next_ route descriptor.
- * Returns pointer to destination MAC address or fills in rdesc
- * and returns NULL.
- */
-#ifdef CONFIG_TR
-static unsigned char *get_tr_dst(unsigned char *packet, unsigned char *rdesc)
-{
-	struct trh_hdr *trh;
-	unsigned int riflen, num_rdsc;
-
-	trh = (struct trh_hdr *)packet;
-	if (trh->daddr[0] & (uint8_t) 0x80)
-		return bus_mac;	/* multicast */
-
-	if (trh->saddr[0] & TR_RII) {
-		riflen = (ntohs(trh->rcf) & TR_RCF_LEN_MASK) >> 8;
-		if ((ntohs(trh->rcf) >> 13) != 0)
-			return bus_mac;	/* ARE or STE */
-	} else
-		return trh->daddr;	/* not source routed */
-
-	if (riflen < 6)
-		return trh->daddr;	/* last hop, source routed */
-
-	/* riflen is 6 or more, packet has more than one route descriptor */
-	num_rdsc = (riflen / 2) - 1;
-	memset(rdesc, 0, ETH_ALEN);
-	/* offset 4 comes from LAN destination field in LE control frames */
-	if (trh->rcf & htons((uint16_t) TR_RCF_DIR_BIT))
-		memcpy(&rdesc[4], &trh->rseg[num_rdsc - 2], sizeof(__be16));
-	else {
-		memcpy(&rdesc[4], &trh->rseg[1], sizeof(__be16));
-		rdesc[5] = ((ntohs(trh->rseg[0]) & 0x000f) | (rdesc[5] & 0xf0));
-	}
-
-	return NULL;
-}
-#endif /* CONFIG_TR */
-
-/*
  * Open/initialize the netdevice. This is called (in the current kernel)
  * sometime after booting when the 'ifconfig' program is run.
  *
@@ -257,9 +208,6 @@ static netdev_tx_t lec_start_xmit(struct sk_buff *skb,
 	struct lec_arp_table *entry;
 	unsigned char *dst;
 	int min_frame_size;
-#ifdef CONFIG_TR
-	unsigned char rdesc[ETH_ALEN];	/* Token Ring route descriptor */
-#endif
 	int is_rdesc;
 
 	pr_debug("called\n");
@@ -290,24 +238,10 @@ static netdev_tx_t lec_start_xmit(struct sk_buff *skb,
 	}
 	skb_push(skb, 2);
 
-	/* Put le header to place, works for TokenRing too */
+	/* Put le header to place */
 	lec_h = (struct lecdatahdr_8023 *)skb->data;
 	lec_h->le_header = htons(priv->lecid);
 
-#ifdef CONFIG_TR
-	/*
-	 * Ugly. Use this to realign Token Ring packets for
-	 * e.g. PCA-200E driver.
-	 */
-	if (priv->is_trdev) {
-		skb2 = skb_realloc_headroom(skb, LEC_HEADER_LEN);
-		kfree_skb(skb);
-		if (skb2 == NULL)
-			return NETDEV_TX_OK;
-		skb = skb2;
-	}
-#endif
-
 #if DUMP_PACKETS >= 2
 #define MAX_DUMP_SKB 99
 #elif DUMP_PACKETS >= 1
@@ -321,12 +255,7 @@ static netdev_tx_t lec_start_xmit(struct sk_buff *skb,
 #endif /* DUMP_PACKETS >= 1 */
 
 	/* Minimum ethernet-frame size */
-#ifdef CONFIG_TR
-	if (priv->is_trdev)
-		min_frame_size = LEC_MINIMUM_8025_SIZE;
-	else
-#endif
-		min_frame_size = LEC_MINIMUM_8023_SIZE;
+	min_frame_size = LEC_MINIMUM_8023_SIZE;
 	if (skb->len < min_frame_size) {
 		if ((skb->len + skb_tailroom(skb)) < min_frame_size) {
 			skb2 = skb_copy_expand(skb, 0,
@@ -345,15 +274,6 @@ static netdev_tx_t lec_start_xmit(struct sk_buff *skb,
 	/* Send to right vcc */
 	is_rdesc = 0;
 	dst = lec_h->h_dest;
-#ifdef CONFIG_TR
-	if (priv->is_trdev) {
-		dst = get_tr_dst(skb->data + 2, rdesc);
-		if (dst == NULL) {
-			dst = rdesc;
-			is_rdesc = 1;
-		}
-	}
-#endif
 	entry = NULL;
 	vcc = lec_arp_resolve(priv, dst, is_rdesc, &entry);
 	pr_debug("%s:vcc:%p vcc_flags:%lx, entry:%p\n",
@@ -710,12 +630,7 @@ static void lec_push(struct atm_vcc *vcc, struct sk_buff *skb)
 			dev_kfree_skb(skb);
 			return;
 		}
-#ifdef CONFIG_TR
-		if (priv->is_trdev)
-			dst = ((struct lecdatahdr_8025 *)skb->data)->h_dest;
-		else
-#endif
-			dst = ((struct lecdatahdr_8023 *)skb->data)->h_dest;
+		dst = ((struct lecdatahdr_8023 *)skb->data)->h_dest;
 
 		/*
 		 * If this is a Data Direct VCC, and the VCC does not match
@@ -723,16 +638,7 @@ static void lec_push(struct atm_vcc *vcc, struct sk_buff *skb)
 		 */
 		spin_lock_irqsave(&priv->lec_arp_lock, flags);
 		if (lec_is_data_direct(vcc)) {
-#ifdef CONFIG_TR
-			if (priv->is_trdev)
-				src =
-				    ((struct lecdatahdr_8025 *)skb->data)->
-				    h_source;
-			else
-#endif
-				src =
-				    ((struct lecdatahdr_8023 *)skb->data)->
-				    h_source;
+			src = ((struct lecdatahdr_8023 *)skb->data)->h_source;
 			entry = lec_arp_find(priv, src);
 			if (entry && entry->vcc != vcc) {
 				lec_arp_remove(priv, entry);
@@ -750,12 +656,7 @@ static void lec_push(struct atm_vcc *vcc, struct sk_buff *skb)
 		if (!hlist_empty(&priv->lec_arp_empty_ones))
 			lec_arp_check_empties(priv, vcc, skb);
 		skb_pull(skb, 2);	/* skip lec_id */
-#ifdef CONFIG_TR
-		if (priv->is_trdev)
-			skb->protocol = tr_type_trans(skb, dev);
-		else
-#endif
-			skb->protocol = eth_type_trans(skb, dev);
+		skb->protocol = eth_type_trans(skb, dev);
 		dev->stats.rx_packets++;
 		dev->stats.rx_bytes += skb->len;
 		memset(ATM_SKB(skb), 0, sizeof(struct atm_skb_data));
@@ -827,27 +728,13 @@ static int lecd_attach(struct atm_vcc *vcc, int arg)
 		i = 0;
 	else
 		i = arg;
-#ifdef CONFIG_TR
 	if (arg >= MAX_LEC_ITF)
 		return -EINVAL;
-#else				/* Reserve the top NUM_TR_DEVS for TR */
-	if (arg >= (MAX_LEC_ITF - NUM_TR_DEVS))
-		return -EINVAL;
-#endif
 	if (!dev_lec[i]) {
-		int is_trdev, size;
-
-		is_trdev = 0;
-		if (i >= (MAX_LEC_ITF - NUM_TR_DEVS))
-			is_trdev = 1;
+		int size;
 
 		size = sizeof(struct lec_priv);
-#ifdef CONFIG_TR
-		if (is_trdev)
-			dev_lec[i] = alloc_trdev(size);
-		else
-#endif
-			dev_lec[i] = alloc_etherdev(size);
+		dev_lec[i] = alloc_etherdev(size);
 		if (!dev_lec[i])
 			return -ENOMEM;
 		dev_lec[i]->netdev_ops = &lec_netdev_ops;
@@ -858,7 +745,6 @@ static int lecd_attach(struct atm_vcc *vcc, int arg)
 		}
 
 		priv = netdev_priv(dev_lec[i]);
-		priv->is_trdev = is_trdev;
 	} else {
 		priv = netdev_priv(dev_lec[i]);
 		if (priv->lecd)
@@ -2372,15 +2258,7 @@ lec_arp_check_empties(struct lec_priv *priv,
 	struct hlist_node *node, *next;
 	struct lec_arp_table *entry, *tmp;
 	struct lecdatahdr_8023 *hdr = (struct lecdatahdr_8023 *)skb->data;
-	unsigned char *src;
-#ifdef CONFIG_TR
-	struct lecdatahdr_8025 *tr_hdr = (struct lecdatahdr_8025 *)skb->data;
-
-	if (priv->is_trdev)
-		src = tr_hdr->h_source;
-	else
-#endif
-		src = hdr->h_source;
+	unsigned char *src = hdr->h_source;
 
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
 	hlist_for_each_entry_safe(entry, node, next,
diff --git a/net/atm/lec.h b/net/atm/lec.h
index dfc0719..c730e57 100644
--- a/net/atm/lec.h
+++ b/net/atm/lec.h
@@ -142,7 +142,6 @@ struct lec_priv {
 	int itfnum;				/* e.g. 2 for lec2, 5 for lec5 */
 	struct lane2_ops *lane2_ops;		/* can be NULL for LANE v1 */
 	int is_proxy;				/* bridge between ATM and Ethernet */
-	int is_trdev;				/* Device type, 0 = Ethernet, 1 = TokenRing */
 };
 
 struct lec_vcc_priv {
-- 
1.7.9.1
