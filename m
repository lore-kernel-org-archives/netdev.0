From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 7/8][BNX2]: Enable S/G for jumbo RX.
Date: Wed, 12 Dec 2007 11:00:11 -0800
Message-ID: <1197486011.16386.32.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3286 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752495AbXLLSPi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2007 13:15:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Enable S/G for jumbo RX.

If the MTU requires more than 1 page for the SKB, enable the page ring
and calculate the size of the page ring.  This will guarantee order-0
allocation regardless of the MTU size.

Fixup loopback test packet size so that we don't deal with the pages
during loopback test.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 6c0fc8a..ae081c8 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -4493,15 +4493,32 @@ static u32 bnx2_find_max_ring(u32 ring_size, u32 max_size)
 static void
 bnx2_set_rx_ring_size(struct bnx2 *bp, u32 size)
 {
-	u32 rx_size;
+	u32 rx_size, rx_space, jumbo_size;
 
 	/* 8 for CRC and VLAN */
 	rx_size = bp->dev->mtu + ETH_HLEN + bp->rx_offset + 8;
 
+	rx_space = SKB_DATA_ALIGN(rx_size + BNX2_RX_ALIGN) + NET_SKB_PAD +
+		sizeof(struct skb_shared_info);
+
 	bp->rx_copy_thresh = RX_COPY_THRESH;
 	bp->rx_pg_ring_size = 0;
 	bp->rx_max_pg_ring = 0;
 	bp->rx_max_pg_ring_idx = 0;
+	if (rx_space > PAGE_SIZE) {
+		int pages = PAGE_ALIGN(bp->dev->mtu - 40) >> PAGE_SHIFT;
+
+		jumbo_size = size * pages;
+		if (jumbo_size > MAX_TOTAL_RX_PG_DESC_CNT)
+			jumbo_size = MAX_TOTAL_RX_PG_DESC_CNT;
+
+		bp->rx_pg_ring_size = jumbo_size;
+		bp->rx_max_pg_ring = bnx2_find_max_ring(jumbo_size,
+							MAX_RX_PG_RINGS);
+		bp->rx_max_pg_ring_idx = (bp->rx_max_pg_ring * RX_DESC_CNT) - 1;
+		rx_size = RX_COPY_THRESH + bp->rx_offset;
+		bp->rx_copy_thresh = 0;
+	}
 
 	bp->rx_buf_use_size = rx_size;
 	/* hw alignment */
@@ -4881,7 +4898,7 @@ bnx2_run_loopback(struct bnx2 *bp, int loopback_mode)
 	else
 		return -EINVAL;
 
-	pkt_size = 1514;
+	pkt_size = min(bp->dev->mtu + ETH_HLEN, bp->rx_jumbo_thresh - 4);
 	skb = netdev_alloc_skb(bp->dev, pkt_size);
 	if (!skb)
 		return -ENOMEM;


