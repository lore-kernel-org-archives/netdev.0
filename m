From: Jamie Iles <jamie@jamieiles.com>
Subject: [PATCHv4 9/9] macb: allow GEM to have configurable receive buffer size
Date: Tue,  8 Nov 2011 14:13:33 +0000
Message-ID: <1320761613-18641-10-git-send-email-jamie@jamieiles.com>
References: <1320761613-18641-1-git-send-email-jamie@jamieiles.com>
Cc: arnd@arndb.de, Jamie Iles <jamie@jamieiles.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63521 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932546Ab1KHOOC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 09:14:02 -0500
Received: by mail-wy0-f174.google.com with SMTP id 15so512103wyh.19
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2011 06:14:02 -0800 (PST)
In-Reply-To: <1320761613-18641-1-git-send-email-jamie@jamieiles.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GEM has configurable receive buffer sizes so requires this to be
programmed up.  Any size < 2048 and a multiple of 64 bytes is permitted.

Signed-off-by: Jamie Iles <jamie@jamieiles.com>
Acked-by: David S. Miller <davem@davemloft.net>
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
 drivers/net/ethernet/cadence/macb.c |   17 +++++++++++++++++
 drivers/net/ethernet/cadence/macb.h |    5 +++++
 2 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 3194af2..c792f59 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -857,6 +857,21 @@ static u32 macb_dbw(struct macb *bp)
 	}
 }
 
+/*
+ * Configure the receive DMA engine to use the correct receive buffer size.
+ * This is a configurable parameter for GEM.
+ */
+static void macb_configure_dma(struct macb *bp)
+{
+	u32 dmacfg;
+
+	if (macb_is_gem(bp)) {
+		dmacfg = gem_readl(bp, DMACFG) & ~GEM_BF(RXBS, -1L);
+		dmacfg |= GEM_BF(RXBS, RX_BUFFER_SIZE / 64);
+		gem_writel(bp, DMACFG, dmacfg);
+	}
+}
+
 static void macb_init_hw(struct macb *bp)
 {
 	u32 config;
@@ -875,6 +890,8 @@ static void macb_init_hw(struct macb *bp)
 	config |= macb_dbw(bp);
 	macb_writel(bp, NCFGR, config);
 
+	macb_configure_dma(bp);
+
 	/* Initialize TX and RX buffers */
 	macb_writel(bp, RBQP, bp->rx_ring_dma);
 	macb_writel(bp, TBQP, bp->tx_ring_dma);
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 71424aa..1931078 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -64,6 +64,7 @@
 /* GEM register offsets. */
 #define GEM_NCFGR				0x0004
 #define GEM_USRIO				0x000c
+#define GEM_DMACFG				0x0010
 #define GEM_HRB					0x0080
 #define GEM_HRT					0x0084
 #define GEM_SA1B				0x0088
@@ -154,6 +155,10 @@
 #define GEM_DBW64				1
 #define GEM_DBW128				2
 
+/* Bitfields in DMACFG. */
+#define GEM_RXBS_OFFSET				16
+#define GEM_RXBS_SIZE				8
+
 /* Bitfields in NSR */
 #define MACB_NSR_LINK_OFFSET			0
 #define MACB_NSR_LINK_SIZE			1
-- 
1.7.4.1
