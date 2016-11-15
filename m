From: Tobias Regnery <tobias.regnery@gmail.com>
Subject: [PATCH net-next V2 2/9] alx: extend data structures for multi queue support
Date: Tue, 15 Nov 2016 12:43:09 +0100
Message-ID: <8c3e0c28b6735ac5e4e6f84f29006206aa08c8a6.1479208628.git.tobias.regnery@gmail.com>
References: <cover.1479208627.git.tobias.regnery@gmail.com>
Cc: davem@davemloft.net, Tobias Regnery <tobias.regnery@gmail.com>
To: netdev@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34213 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751359AbcKOLnc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 06:43:32 -0500
Received: by mail-wm0-f66.google.com with SMTP id g23so24986480wme.1
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 03:43:32 -0800 (PST)
In-Reply-To: <cover.1479208627.git.tobias.regnery@gmail.com>
In-Reply-To: <cover.1479208627.git.tobias.regnery@gmail.com>
References: <cover.1479208627.git.tobias.regnery@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend the driver data structures to be able to handle multiple queues.

Based on the downstream driver at github.com/qca/alx

Signed-off-by: Tobias Regnery <tobias.regnery@gmail.com>
---
 drivers/net/ethernet/atheros/alx/alx.h | 31 +++++++++++++++++++++++++++++++
 1 file changed, 31 insertions(+)

diff --git a/drivers/net/ethernet/atheros/alx/alx.h b/drivers/net/ethernet/atheros/alx/alx.h
index 6cac919272ea..0859053525de 100644
--- a/drivers/net/ethernet/atheros/alx/alx.h
+++ b/drivers/net/ethernet/atheros/alx/alx.h
@@ -50,6 +50,10 @@ struct alx_buffer {
 };
 
 struct alx_rx_queue {
+	struct net_device *netdev;
+	struct device *dev;
+	struct alx_napi *np;
+
 	struct alx_rrd *rrd;
 	dma_addr_t rrd_dma;
 
@@ -58,16 +62,26 @@ struct alx_rx_queue {
 
 	struct alx_buffer *bufs;
 
+	u16 count;
 	u16 write_idx, read_idx;
 	u16 rrd_read_idx;
+	u16 queue_idx;
 };
 #define ALX_RX_ALLOC_THRESH	32
 
 struct alx_tx_queue {
+	struct net_device *netdev;
+	struct device *dev;
+
 	struct alx_txd *tpd;
 	dma_addr_t tpd_dma;
+
 	struct alx_buffer *bufs;
+
+	u16 count;
 	u16 write_idx, read_idx;
+	u16 queue_idx;
+	u16 p_reg, c_reg;
 };
 
 #define ALX_DEFAULT_TX_WORK 128
@@ -76,6 +90,18 @@ enum alx_device_quirks {
 	ALX_DEV_QUIRK_MSI_INTX_DISABLE_BUG = BIT(0),
 };
 
+struct alx_napi {
+	struct napi_struct	napi;
+	struct alx_priv		*alx;
+	struct alx_rx_queue	*rxq;
+	struct alx_tx_queue	*txq;
+	int			vec_idx;
+	u32			vec_mask;
+	char			irq_lbl[IFNAMSIZ + 8];
+};
+
+#define ALX_MAX_NAPIS 8
+
 #define ALX_FLAG_USING_MSIX	BIT(0)
 #define ALX_FLAG_USING_MSI	BIT(1)
 
@@ -96,6 +122,11 @@ struct alx_priv {
 		unsigned int size;
 	} descmem;
 
+	struct alx_napi *qnapi[ALX_MAX_NAPIS];
+	int num_txq;
+	int num_rxq;
+	int num_napi;
+
 	/* protect int_mask updates */
 	spinlock_t irq_lock;
 	u32 int_mask;
-- 
2.7.4
