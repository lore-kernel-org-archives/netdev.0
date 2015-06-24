From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: [PATCH v2] stmmac: troubleshoot unexpected bits in des0 & des1
Date: Wed, 24 Jun 2015 11:07:26 +0300
Message-ID: <1435133246-15776-1-git-send-email-abrodkin@synopsys.com>
References: <20150624.001840.1867851321247997506.davem@davemloft.net>
Cc: Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	arc-linux-dev@synopsys.com, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org, David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20150624.001840.1867851321247997506.davem@davemloft.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Current implementation of descriptor init procedure only takes
care about setting/clearing ownership flag in "des0"/"des1"
fields while it is perfectly possible to get unexpected bits
set because of the following factors:

 [1] On driver probe underlying memory allocated with
     dma_alloc_coherent() might not be zeroed and so
     it will be filled with garbage.

 [2] During driver operation some bits could be set by SD/MMC
     controller (for example error flags etc).

And unexpected and/or randomly set flags in "des0"/"des1"
fields may lead to unpredictable behavior of GMAC DMA block.

This change addresses both items above with:

 [1] Use of dma_zalloc_coherent() instead of simple
     dma_alloc_coherent() to make sure allocated memory is
     zeroed. That shouldn't affect performance because
     this allocation only happens once on driver probe.

 [2] Do explicit zeroing of both "des0" and "des1" fields
     of all buffer descriptors during initialization of
     DMA transfer.

Signed-off-by: Alexey Brodkin <abrodkin@synopsys.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: arc-linux-dev@synopsys.com
Cc: linux-kernel@vger.kernel.org
Cc: stable@vger.kernel.org
Cc: David Miller <davem@davemloft.net>
---
 drivers/net/ethernet/stmicro/stmmac/descs.h       | 2 ++
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c    | 3 ++-
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c   | 3 ++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 8 ++++----
 4 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/descs.h b/drivers/net/ethernet/stmicro/stmmac/descs.h
index ad39960..799c292 100644
--- a/drivers/net/ethernet/stmicro/stmmac/descs.h
+++ b/drivers/net/ethernet/stmicro/stmmac/descs.h
@@ -158,6 +158,8 @@ struct dma_desc {
 			u32 buffer2_size:13;
 			u32 reserved4:3;
 		} etx;		/* -- enhanced -- */
+
+		u64 all_flags;
 	} des01;
 	unsigned int des2;
 	unsigned int des3;
diff --git a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
index 1e2bcf5..7d94444 100644
--- a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
@@ -240,6 +240,7 @@ static int enh_desc_get_rx_status(void *data, struct stmmac_extra_stats *x,
 static void enh_desc_init_rx_desc(struct dma_desc *p, int disable_rx_ic,
 				  int mode, int end)
 {
+	p->des01.all_flags = 0;
 	p->des01.erx.own = 1;
 	p->des01.erx.buffer1_size = BUF_SIZE_8KiB - 1;
 
@@ -254,7 +255,7 @@ static void enh_desc_init_rx_desc(struct dma_desc *p, int disable_rx_ic,
 
 static void enh_desc_init_tx_desc(struct dma_desc *p, int mode, int end)
 {
-	p->des01.etx.own = 0;
+	p->des01.all_flags = 0;
 	if (mode == STMMAC_CHAIN_MODE)
 		ehn_desc_tx_set_on_chain(p, end);
 	else
diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
index 35ad4f4..48c3456 100644
--- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
@@ -123,6 +123,7 @@ static int ndesc_get_rx_status(void *data, struct stmmac_extra_stats *x,
 static void ndesc_init_rx_desc(struct dma_desc *p, int disable_rx_ic, int mode,
 			       int end)
 {
+	p->des01.all_flags = 0;
 	p->des01.rx.own = 1;
 	p->des01.rx.buffer1_size = BUF_SIZE_2KiB - 1;
 
@@ -137,7 +138,7 @@ static void ndesc_init_rx_desc(struct dma_desc *p, int disable_rx_ic, int mode,
 
 static void ndesc_init_tx_desc(struct dma_desc *p, int mode, int end)
 {
-	p->des01.tx.own = 0;
+	p->des01.all_flags = 0;
 	if (mode == STMMAC_CHAIN_MODE)
 		ndesc_tx_set_on_chain(p, end);
 	else
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 18c46bb..3309b98 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1172,7 +1172,7 @@ static int alloc_dma_desc_resources(struct stmmac_priv *priv)
 		goto err_tx_skbuff;
 
 	if (priv->extend_desc) {
-		priv->dma_erx = dma_alloc_coherent(priv->device, rxsize *
+		priv->dma_erx = dma_zalloc_coherent(priv->device, rxsize *
 						   sizeof(struct
 							  dma_extended_desc),
 						   &priv->dma_rx_phy,
@@ -1180,7 +1180,7 @@ static int alloc_dma_desc_resources(struct stmmac_priv *priv)
 		if (!priv->dma_erx)
 			goto err_dma;
 
-		priv->dma_etx = dma_alloc_coherent(priv->device, txsize *
+		priv->dma_etx = dma_zalloc_coherent(priv->device, txsize *
 						   sizeof(struct
 							  dma_extended_desc),
 						   &priv->dma_tx_phy,
@@ -1192,14 +1192,14 @@ static int alloc_dma_desc_resources(struct stmmac_priv *priv)
 			goto err_dma;
 		}
 	} else {
-		priv->dma_rx = dma_alloc_coherent(priv->device, rxsize *
+		priv->dma_rx = dma_zalloc_coherent(priv->device, rxsize *
 						  sizeof(struct dma_desc),
 						  &priv->dma_rx_phy,
 						  GFP_KERNEL);
 		if (!priv->dma_rx)
 			goto err_dma;
 
-		priv->dma_tx = dma_alloc_coherent(priv->device, txsize *
+		priv->dma_tx = dma_zalloc_coherent(priv->device, txsize *
 						  sizeof(struct dma_desc),
 						  &priv->dma_tx_phy,
 						  GFP_KERNEL);
-- 
2.4.2
