From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] bnx2: bnx2_tx_int() optimizations
Date: Wed, 13 May 2009 08:48:02 +0200
Message-ID: <4A0A6D22.5060007@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw2.cosmosbay.com ([86.64.20.130]:59581 "EHLO gw2.cosmosbay.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751165AbZEMGsL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2009 02:48:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using bnx2 in a high transmit load, bnx2_tx_int() cost is pretty high.

There are two reasons.

One is an expensive call to bnx2_get_hw_tx_cons(bnapi) for each freed skb

One is cpu stalls when accessing skb_is_gso(skb) / skb_shinfo(skb)->nr_frags
because of two cache line misses.
(One to get skb->end/head to compute skb_shinfo(skb),
 one to get is_gso/nr_frags)


This patch :

1) avoids calling bnx2_get_hw_tx_cons(bnapi) too many times.

2) makes bnx2_start_xmit() cache is_gso & nr_frags into sw_tx_bd descriptor.
   This uses a litle bit more ram (256 longs per device on x86), but helps a lot.

3) uses a prefetch(&skb->end) to speedup dev_kfree_skb(), bringing
  cache line that will be needed in skb_release_data()


result is 5 % bandwidth increase in benchmarks, involving UDP or TCP receive
 & transmits, when a cpu is dedicated to ksoftirqd for bnx2.

bnx2_tx_int going from 3.33 % cpu to 0.5 % cpu in oprofile

Note : skb_dma_unmap() still very expensive but this is for another patch, 
not related to bnx2 (2.9 % of cpu, while it does nothing on x86_32)


Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 drivers/net/bnx2.c |   18 +++++++++++-------
 drivers/net/bnx2.h |    2 ++
 2 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index b0cb29d..c37acc1 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2630,14 +2630,15 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 		tx_buf = &txr->tx_buf_ring[sw_ring_cons];
 		skb = tx_buf->skb;
 
+		/* prefetch skb_end_pointer() to speedup skb_shinfo(skb) */
+		prefetch(&skb->end);
+
 		/* partial BD completions possible with TSO packets */
-		if (skb_is_gso(skb)) {
+		if (tx_buf->is_gso) {
 			u16 last_idx, last_ring_idx;
 
-			last_idx = sw_cons +
-				skb_shinfo(skb)->nr_frags + 1;
-			last_ring_idx = sw_ring_cons +
-				skb_shinfo(skb)->nr_frags + 1;
+			last_idx = sw_cons + tx_buf->nr_frags + 1;
+			last_ring_idx = sw_ring_cons + tx_buf->nr_frags + 1;
 			if (unlikely(last_ring_idx >= MAX_TX_DESC_CNT)) {
 				last_idx++;
 			}
@@ -2649,7 +2650,7 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 		skb_dma_unmap(&bp->pdev->dev, skb, DMA_TO_DEVICE);
 
 		tx_buf->skb = NULL;
-		last = skb_shinfo(skb)->nr_frags;
+		last = tx_buf->nr_frags;
 
 		for (i = 0; i < last; i++) {
 			sw_cons = NEXT_TX_BD(sw_cons);
@@ -2662,7 +2663,8 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 		if (tx_pkt == budget)
 			break;
 
-		hw_cons = bnx2_get_hw_tx_cons(bnapi);
+		if (hw_cons == sw_cons)
+			hw_cons = bnx2_get_hw_tx_cons(bnapi);
 	}
 
 	txr->hw_tx_cons = hw_cons;
@@ -6179,6 +6181,8 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	txbd->tx_bd_vlan_tag_flags = vlan_tag_flags | TX_BD_FLAGS_START;
 
 	last_frag = skb_shinfo(skb)->nr_frags;
+	tx_buf->nr_frags = last_frag;
+	tx_buf->is_gso = skb_is_gso(skb);
 
 	for (i = 0; i < last_frag; i++) {
 		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 5b570e1..026ed1c 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6552,6 +6552,8 @@ struct sw_pg {
 
 struct sw_tx_bd {
 	struct sk_buff		*skb;
+	unsigned short		is_gso;
+	unsigned short		nr_frags;
 };
 
 #define SW_RXBD_RING_SIZE (sizeof(struct sw_bd) * RX_DESC_CNT)
