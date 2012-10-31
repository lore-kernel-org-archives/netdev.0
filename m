From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH v4 09/10] net/macb: Offset first RX buffer by two bytes
Date: Wed, 31 Oct 2012 17:04:58 +0100
Message-ID: <49a6277a963758b7858a3598935d372e1c2ad1f6.1351690694.git.nicolas.ferre@atmel.com>
References: <cover.1351690694.git.nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <bhutchings@solarflare.com>,
	<linux-arm-kernel@lists.infradead.org>, <plagnioj@jcrosoft.com>,
	<patrice.vilchez@atmel.com>, <linux-kernel@vger.kernel.org>,
	<manabian@gmail.com>, <David.Laight@ACULAB.COM>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<havard@skinnemoen.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1351690694.git.nicolas.ferre@atmel.com>
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
Tested-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/cadence/macb.c | 23 ++++++++++++++++-------
 1 file changed, 16 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index d5b52ff..c1f20b0 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -33,9 +33,6 @@
 #define RX_RING_SIZE		512 /* must be power of 2 */
 #define RX_RING_BYTES		(sizeof(struct macb_dma_desc) * RX_RING_SIZE)
 
-/* Make the IP header word-aligned (the ethernet header is 14 bytes) */
-#define RX_OFFSET		2
-
 #define TX_RING_SIZE		128 /* must be power of 2 */
 #define TX_RING_BYTES		(sizeof(struct macb_dma_desc) * TX_RING_SIZE)
 
@@ -498,7 +495,7 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
 {
 	unsigned int len;
 	unsigned int frag;
-	unsigned int offset = 0;
+	unsigned int offset;
 	struct sk_buff *skb;
 	struct macb_dma_desc *desc;
 
@@ -509,7 +506,16 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
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
@@ -525,7 +531,8 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
 		return 1;
 	}
 
-	skb_reserve(skb, RX_OFFSET);
+	offset = 0;
+	len += NET_IP_ALIGN;
 	skb_checksum_none_assert(skb);
 	skb_put(skb, len);
 
@@ -549,10 +556,11 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
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
@@ -1012,6 +1020,7 @@ static void macb_init_hw(struct macb *bp)
 	__macb_set_hwaddr(bp);
 
 	config = macb_mdc_clk_div(bp);
+	config |= MACB_BF(RBOF, NET_IP_ALIGN);	/* Make eth data aligned */
 	config |= MACB_BIT(PAE);		/* PAuse Enable */
 	config |= MACB_BIT(DRFCS);		/* Discard Rx FCS */
 	config |= MACB_BIT(BIG);		/* Receive oversized frames */
-- 
1.8.0
