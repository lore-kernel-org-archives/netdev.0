From: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Subject: [PATCH 1/2 v2] PS3: changed the way to handle tx skbs
Date: Fri, 31 Aug 2007 22:22:32 +0900
Message-ID: <20070831221800.C323.MOKUNO@sm.sony.co.jp>
References: <20070831220507.C31D.MOKUNO@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Linas Vepstas <linas@austin.ibm.com>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org, geoffrey.levand@am.sony.com,
	Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MGW2.Sony.CO.JP ([137.153.0.14]:48875 "EHLO mgw2.sony.co.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965024AbXHaNWp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 09:22:45 -0400
In-Reply-To: <20070831220507.C31D.MOKUNO@sm.sony.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The PS3 virtual network device requires a vlan tag in the sending packet
to select the destination device, ethernet port or wireless. 
As the vlan tag field is in the middle of the passed data, 
we should insert it into the packet data.
To avoid copying much of the packet data, the driver used two tx descriptors
for one tx skb; one descriptor was for sending a small static 
buffer which contained vlan tag and copied header (two mac addresses),
one was for the residual data after the vlan field.

This patch changes the way to insert the vlan tag.  By changing 
netdev->hard_header_len, we can make the headroom for moving mac address
fields in the skb buffer. Then we can send one tx skb with
one tx descriptor.  This also gives us a tx throughut gain of approx.
20% according to netperf results.

Signed-off-by: Masakazu Mokuno <mokuno@sm.sony.co.jp>
CC: Geoff Levand <geoffrey.levand@am.sony.com>
---
 drivers/net/ps3_gelic_net.c |  140 +++++++++++++++++++-------------------------
 1 file changed, 63 insertions(+), 77 deletions(-)

--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -351,19 +351,13 @@ static int gelic_net_alloc_rx_skbs(struc
 static void gelic_net_release_tx_descr(struct gelic_net_card *card,
 			    struct gelic_net_descr *descr)
 {
-	struct sk_buff *skb;
+	struct sk_buff *skb = descr->skb;
 
+	BUG_ON(!(descr->data_status & (1 << GELIC_NET_TXDESC_TAIL)));
 
-	if (descr->data_status & (1 << GELIC_NET_TXDESC_TAIL)) {
-		/* 2nd descriptor */
-		skb = descr->skb;
-		dma_unmap_single(ctodev(card), descr->buf_addr, skb->len,
-				 DMA_TO_DEVICE);
-		dev_kfree_skb_any(skb);
-	} else {
-		dma_unmap_single(ctodev(card), descr->buf_addr,
-				 descr->buf_size, DMA_TO_DEVICE);
-	}
+	dma_unmap_single(ctodev(card), descr->buf_addr, skb->len,
+			 DMA_TO_DEVICE);
+	dev_kfree_skb_any(skb);
 
 	descr->buf_addr = 0;
 	descr->buf_size = 0;
@@ -426,7 +420,7 @@ static void gelic_net_release_tx_chain(s
 		release ++;
 	}
 out:
-	if (!stop && (2 < release))
+	if (!stop && release)
 		netif_wake_queue(card->netdev);
 }
 
@@ -592,13 +586,10 @@ gelic_net_get_next_tx_descr(struct gelic
 {
 	if (!card->tx_chain.head)
 		return NULL;
-	/*  see if we can two consecutive free descrs */
+	/*  see if the next descriptor is free */
 	if (card->tx_chain.tail != card->tx_chain.head->next &&
 	    gelic_net_get_descr_status(card->tx_chain.head) ==
-	    GELIC_NET_DESCR_NOT_IN_USE &&
-	    card->tx_chain.tail != card->tx_chain.head->next->next &&
-	    gelic_net_get_descr_status(card->tx_chain.head->next) ==
-	     GELIC_NET_DESCR_NOT_IN_USE )
+	    GELIC_NET_DESCR_NOT_IN_USE)
 		return card->tx_chain.head;
 	else
 		return NULL;
@@ -609,44 +600,66 @@ gelic_net_get_next_tx_descr(struct gelic
  * gelic_net_set_txdescr_cmdstat - sets the tx descriptor command field
  * @descr: descriptor structure to fill out
  * @skb: packet to consider
- * @middle: middle of frame
  *
  * fills out the command and status field of the descriptor structure,
  * depending on hardware checksum settings. This function assumes a wmb()
  * has executed before.
  */
 static void gelic_net_set_txdescr_cmdstat(struct gelic_net_descr *descr,
-					  struct sk_buff *skb, int middle)
+					  struct sk_buff *skb)
 {
-	u32 eofr;
-
-	if (middle)
-		eofr = 0;
-	else
-		eofr = GELIC_NET_DMAC_CMDSTAT_END_FRAME;
-
 	if (skb->ip_summed != CHECKSUM_PARTIAL)
-		descr->dmac_cmd_status = GELIC_NET_DMAC_CMDSTAT_NOCS | eofr;
+		descr->dmac_cmd_status = GELIC_NET_DMAC_CMDSTAT_NOCS |
+			GELIC_NET_DMAC_CMDSTAT_END_FRAME;
 	else {
 		/* is packet ip?
 		 * if yes: tcp? udp? */
 		if (skb->protocol == htons(ETH_P_IP)) {
 			if (ip_hdr(skb)->protocol == IPPROTO_TCP)
 				descr->dmac_cmd_status =
-					GELIC_NET_DMAC_CMDSTAT_TCPCS | eofr;
+					GELIC_NET_DMAC_CMDSTAT_TCPCS |
+					GELIC_NET_DMAC_CMDSTAT_END_FRAME;
+
 			else if (ip_hdr(skb)->protocol == IPPROTO_UDP)
 				descr->dmac_cmd_status =
-					GELIC_NET_DMAC_CMDSTAT_UDPCS | eofr;
+					GELIC_NET_DMAC_CMDSTAT_UDPCS |
+					GELIC_NET_DMAC_CMDSTAT_END_FRAME;
 			else	/*
 				 * the stack should checksum non-tcp and non-udp
 				 * packets on his own: NETIF_F_IP_CSUM
 				 */
 				descr->dmac_cmd_status =
-					GELIC_NET_DMAC_CMDSTAT_NOCS | eofr;
+					GELIC_NET_DMAC_CMDSTAT_NOCS |
+					GELIC_NET_DMAC_CMDSTAT_END_FRAME;
 		}
 	}
 }
 
+static inline struct sk_buff *gelic_put_vlan_tag(struct sk_buff *skb,
+						 unsigned short tag)
+{
+	struct vlan_ethhdr *veth;
+	static unsigned int c;
+
+	if (skb_headroom(skb) < VLAN_HLEN) {
+		struct sk_buff *sk_tmp = skb;
+		pr_debug("%s: hd=%d c=%ud\n", __func__, skb_headroom(skb), c);
+		skb = skb_realloc_headroom(sk_tmp, VLAN_HLEN);
+		if (!skb)
+			return NULL;
+		dev_kfree_skb_any(sk_tmp);
+	}
+	veth = (struct vlan_ethhdr *)skb_push(skb, VLAN_HLEN);
+
+	/* Move the mac addresses to the top of buffer */
+	memmove(skb->data, skb->data + VLAN_HLEN, 2 * ETH_ALEN);
+
+	veth->h_vlan_proto = __constant_htons(ETH_P_8021Q);
+	veth->h_vlan_TCI = htons(tag);
+
+	return skb;
+}
+
 /**
  * gelic_net_prepare_tx_descr_v - get dma address of skb_data
  * @card: card structure
@@ -660,65 +673,35 @@ static int gelic_net_prepare_tx_descr_v(
 					struct gelic_net_descr *descr,
 					struct sk_buff *skb)
 {
-	dma_addr_t buf[2];
-	unsigned int vlan_len;
-	struct gelic_net_descr *sec_descr = descr->next;
+	dma_addr_t buf;
 
-	if (skb->len < GELIC_NET_VLAN_POS)
-		return -EINVAL;
-
-	vlan_len = GELIC_NET_VLAN_POS;
-	memcpy(&descr->vlan, skb->data, vlan_len);
 	if (card->vlan_index != -1) {
-		/* internal vlan tag used */
-		descr->vlan.h_vlan_proto = htons(ETH_P_8021Q); /* vlan 0x8100*/
-		descr->vlan.h_vlan_TCI = htons(card->vlan_id[card->vlan_index]);
-		vlan_len += VLAN_HLEN; /* added for above two lines */
+		struct sk_buff *skb_tmp;
+		skb_tmp = gelic_put_vlan_tag(skb,
+					     card->vlan_id[card->vlan_index]);
+		if (!skb_tmp)
+			return -ENOMEM;
+		skb = skb_tmp;
 	}
 
-	/* map data area */
-	buf[0] = dma_map_single(ctodev(card), &descr->vlan,
-			     vlan_len, DMA_TO_DEVICE);
+	buf = dma_map_single(ctodev(card), skb->data, skb->len, DMA_TO_DEVICE);
 
-	if (!buf[0]) {
-		dev_err(ctodev(card),
-			"dma map 1 failed (%p, %i). Dropping packet\n",
-			skb->data, vlan_len);
-		return -ENOMEM;
-	}
-
-	buf[1] = dma_map_single(ctodev(card), skb->data + GELIC_NET_VLAN_POS,
-			     skb->len - GELIC_NET_VLAN_POS,
-			     DMA_TO_DEVICE);
-
-	if (!buf[1]) {
+	if (!buf) {
 		dev_err(ctodev(card),
 			"dma map 2 failed (%p, %i). Dropping packet\n",
-			skb->data + GELIC_NET_VLAN_POS,
-			skb->len - GELIC_NET_VLAN_POS);
-		dma_unmap_single(ctodev(card), buf[0], vlan_len,
-				 DMA_TO_DEVICE);
+			skb->data, skb->len);
 		return -ENOMEM;
 	}
 
-	/* first descr */
-	descr->buf_addr = buf[0];
-	descr->buf_size = vlan_len;
-	descr->skb = NULL; /* not used */
+	descr->buf_addr = buf;
+	descr->buf_size = skb->len;
+	descr->skb = skb;
 	descr->data_status = 0;
-	descr->next_descr_addr = descr->next->bus_addr;
-	gelic_net_set_txdescr_cmdstat(descr, skb, 1); /* not the frame end */
-
-	/* second descr */
-	sec_descr->buf_addr = buf[1];
-	sec_descr->buf_size = skb->len - GELIC_NET_VLAN_POS;
-	sec_descr->skb = skb;
-	sec_descr->data_status = 0;
-	sec_descr->next_descr_addr = 0; /* terminate hw descr */
-	gelic_net_set_txdescr_cmdstat(sec_descr, skb, 0);
+	descr->next_descr_addr = 0; /* terminate hw descr */
+	gelic_net_set_txdescr_cmdstat(descr, skb);
 
 	/* bump free descriptor pointer */
-	card->tx_chain.head = sec_descr->next;
+	card->tx_chain.head = descr->next;
 	return 0;
 }
 
@@ -1422,8 +1405,11 @@ static int gelic_net_setup_netdev(struct
 			dev_dbg(ctodev(card), "vlan_id:%d, %lx\n", i, v1);
 		}
 	}
-	if (card->vlan_id[GELIC_NET_VLAN_WIRED - 1])
+
+	if (card->vlan_id[GELIC_NET_VLAN_WIRED - 1]) {
 		card->vlan_index = GELIC_NET_VLAN_WIRED - 1;
+		netdev->hard_header_len += VLAN_HLEN;
+	}
 
 	status = register_netdev(netdev);
 	if (status) {
-- 
Masakazu MOKUNO

