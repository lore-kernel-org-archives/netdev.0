From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 13/34]bnx2x: System cache alignment
Date: Wed, 14 Jan 2009 18:43:21 +0200
Message-ID: <1231951401.11301.134.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2391 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763326AbZANQoI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 11:44:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using the system cache alignment instead of constant value

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    5 +++++
 drivers/net/bnx2x_main.c |    9 +++------
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index c1ba541..0e848fe 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -757,6 +757,11 @@ struct bnx2x {
 #define ETH_MAX_PACKET_SIZE		1500
 #define ETH_MAX_JUMBO_PACKET_SIZE	9600
 
+	/* Max supported alignment is 256 (8 shift) */
+#define BNX2X_RX_ALIGN_SHIFT		((L1_CACHE_SHIFT < 8) ? \
+					 L1_CACHE_SHIFT : 8)
+#define BNX2X_RX_ALIGN			(1 << BNX2X_RX_ALIGN_SHIFT)
+
 	struct host_def_status_block *def_status_blk;
 #define DEF_SB_ID			16
 	u16			def_c_idx;
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index d32b98f..a1d8ca5 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -4287,14 +4287,11 @@ static void bnx2x_init_rx_rings(struct bnx2x *bp)
 	u16 ring_prod, cqe_ring_prod;
 	int i, j;
 
-	bp->rx_buf_size = bp->dev->mtu;
-	bp->rx_buf_size += bp->rx_offset + ETH_OVREHEAD +
-		BCM_RX_ETH_PAYLOAD_ALIGN;
+	bp->rx_buf_size = bp->dev->mtu + ETH_OVREHEAD + BNX2X_RX_ALIGN;
+	DP(NETIF_MSG_IFUP,
+	   "mtu %d  rx_buf_size %d\n", bp->dev->mtu, bp->rx_buf_size);
 
 	if (bp->flags & TPA_ENABLE_FLAG) {
-		DP(NETIF_MSG_IFUP,
-		   "rx_buf_size %d  effective_mtu %d\n",
-		   bp->rx_buf_size, bp->dev->mtu + ETH_OVREHEAD);
 
 		for_each_queue(bp, j) {
 			struct bnx2x_fastpath *fp = &bp->fp[j];
-- 
1.5.4.3




