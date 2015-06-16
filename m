From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: [PATCH] stmmac: explicitly zero des0 & des1 on init
Date: Tue, 16 Jun 2015 20:40:41 +0300
Message-ID: <1434476441-18241-1-git-send-email-abrodkin@synopsys.com>
Cc: Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	arc-linux-dev@synopsys.com, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Current implementtion of descriptor init procedure only takes care about
ownership flag. While it is perfectly possible to have underlying memory
filled with garbage on boot or driver installation.

And randomly set flags in non-zeroed des0 and des1 fields may lead to
unpredictable behavior of the GMAC DMA block.

Solution to this problem is as simple as explicit zeroing of both des0
and des1 fields of all buffer descriptors.

Signed-off-by: Alexey Brodkin <abrodkin@synopsys.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: arc-linux-dev@synopsys.com
Cc: linux-kernel@vger.kernel.org
Cc: stable@vger.kernel.org
---
 drivers/net/ethernet/stmicro/stmmac/descs.h     | 2 ++
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c  | 3 ++-
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c | 3 ++-
 3 files changed, 6 insertions(+), 2 deletions(-)

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
-- 
2.4.2
