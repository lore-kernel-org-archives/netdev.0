From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH 10/10] net/macb: Offset first RX buffer by two bytes
Date: Wed, 5 Sep 2012 11:04:06 +0200
Message-ID: <68a0e4baf2ace47c04874f1918a3bd5f1e5784dc.1346775479.git.nicolas.ferre@atmel.com>
References: <cover.1346775479.git.nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>, <davem@davemloft.net>,
	<havard@skinnemoen.net>, <nicolas.ferre@atmel.com>,
	<plagnioj@jcrosoft.com>, <jamie@jamieiles.com>,
	<linux-kernel@vger.kernel.org>, <patrice.vilchez@atmel.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1346775479.git.nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Havard Skinnemoen <havard@skinnemoen.net>

Make the ethernet frame payload word-aligned, possibly making the
memcpy into the skb a bit faster. This will be even more important
after we eliminate the copy altogether.

Also eliminate the redundant RX_OFFSET constant -- it has the same
definition and purpose as NET_IP_ALIGN.

Signed-off-by: Havard Skinnemoen <havard@skinnemoen.net>
[nicolas.ferre@atmel.com: adapt to newer kernel]
Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
 drivers/net/ethernet/cadence/macb.c |   23 ++++++++++++++++-------
 1 file changed, 16 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index f31c0a7..f7716b6 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -33,9 +33,6 @@
 #define RX_RING_SIZE		512
 #define RX_RING_BYTES		(sizeof(struct macb_dma_desc) * RX_RING_SIZE)
 
-/* Make the IP header word-aligned (the ethernet header is 14 bytes) */
-#define RX_OFFSET		2
-
 #define TX_RING_SIZE		128
 #define TX_RING_BYTES		(sizeof(struct macb_dma_desc) * TX_RING_SIZE)
 
@@ -466,7 +463,7 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
 {
 	unsigned int len;
 	unsigned int frag;
-	unsigned int offset = 0;
+	unsigned int offset;
 	struct sk_buff *skb;
 	struct macb_dma_desc *desc;
 
@@ -477,7 +474,16 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
 		macb_rx_ring_wrap(first_frag),
 		macb_rx_ring_wrap(last_frag), len);
 
-	skb = netdev_alloc_skb(bp->dev, len + RX_OFFSET);
+	/*
+	 * The ethernet header starts NET_IP_ALIGN bytes into the
+	 * first buffer. Since the header is 14 bytes, this makes the
+	 * payload word-aligned.
+	 *
+	 * Instead of calling skb_reserve(NET_IP_ALIGN), we just copy
+	 * the two padding bytes into the skb so that we avoid hitting
+	 * the slowpath in memcpy(), and pull them off afterwards.
+	 */
+	skb = netdev_alloc_skb(bp->dev, len + NET_IP_ALIGN);
 	if (!skb) {
 		bp->stats.rx_dropped++;
 		for (frag = first_frag; ; frag++) {
@@ -493,7 +499,8 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
 		return 1;
 	}
 
-	skb_reserve(skb, RX_OFFSET);
+	offset = 0;
+	len += NET_IP_ALIGN;
 	skb_checksum_none_assert(skb);
 	skb_put(skb, len);
 
@@ -517,10 +524,11 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
 	/* Make descriptor updates visible to hardware */
 	wmb();
 
+	__skb_pull(skb, NET_IP_ALIGN);
 	skb->protocol = eth_type_trans(skb, bp->dev);
 
 	bp->stats.rx_packets++;
-	bp->stats.rx_bytes += len;
+	bp->stats.rx_bytes += skb->len;
 	netdev_vdbg(bp->dev, "received skb of length %u, csum: %08x\n",
 		   skb->len, skb->csum);
 	netif_receive_skb(skb);
@@ -985,6 +993,7 @@ static void macb_init_hw(struct macb *bp)
 	__macb_set_hwaddr(bp);
 
 	config = macb_mdc_clk_div(bp);
+	config |= MACB_BF(RBOF, NET_IP_ALIGN);	/* Make eth data aligned */
 	config |= MACB_BIT(PAE);		/* PAuse Enable */
 	config |= MACB_BIT(DRFCS);		/* Discard Rx FCS */
 	config |= MACB_BIT(BIG);		/* Receive oversized frames */
-- 
1.7.10
