From: Jamie Iles <jamie@jamieiles.com>
Subject: [PATCHv3 9/9] macb: allow GEM to have configurable receive buffer size
Date: Tue,  9 Aug 2011 10:16:51 +0100
Message-ID: <1312881411-2376-10-git-send-email-jamie@jamieiles.com>
References: <1312881411-2376-1-git-send-email-jamie@jamieiles.com>
Cc: plagnioj@jcrosoft.com, Jamie Iles <jamie@jamieiles.com>
To: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40251 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752745Ab1HIJSS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 05:18:18 -0400
Received: by mail-ww0-f44.google.com with SMTP id 5so2433881wwf.1
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2011 02:18:18 -0700 (PDT)
In-Reply-To: <1312881411-2376-1-git-send-email-jamie@jamieiles.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GEM has configurable receive buffer sizes so requires this to be
programmed up.  Any size < 2048 and a multiple of 64 bytes is permitted.

Signed-off-by: Jamie Iles <jamie@jamieiles.com>
Acked-by: David S. Miller <davem@davemloft.net>
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
 drivers/net/macb.c |   17 +++++++++++++++++
 drivers/net/macb.h |    5 +++++
 2 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index a8a9b4b..69c9808 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
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
diff --git a/drivers/net/macb.h b/drivers/net/macb.h
index 71424aa..1931078 100644
--- a/drivers/net/macb.h
+++ b/drivers/net/macb.h
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

