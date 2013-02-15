From: Christian Ruppert <christian.ruppert@abilis.com>
Subject: [PATCH] Prevent interrupt loop with DWMAC MMC RX IPC Counter
Date: Fri, 15 Feb 2013 14:15:23 +0100
Message-ID: <1360934123-30476-1-git-send-email-christian.ruppert@abilis.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	Christian Ruppert <christian.ruppert@abilis.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If the DesignWare MAC is synthesised with MMC RX IPC Counter, an unmanaged
and unacknowledged interrupt is generated after some time of operation. To
my knowledge there is no way to autodetect this configuration.

This patch adds a Kconfig option to tell the driver about the counter which
in turn masks the undesired interrupts.

Signed-off-by: Christian Ruppert <christian.ruppert@abilis.com>
---
 drivers/net/ethernet/stmicro/stmmac/Kconfig    |    8 ++++++++
 drivers/net/ethernet/stmicro/stmmac/mmc_core.c |    3 +++
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index 1164930..60e5130 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -71,5 +71,13 @@ config STMMAC_CHAINED
 
 endchoice
 
+config STMMAC_RX_IPC_CTRS
+	bool "MMC Receive IPC Counters enabled"
+	depends on STMMAC_ETH
+	default n
+	---help---
+	  Select this option in case MMC Receive IPC counters were enabled at
+	  synthesis time of the block. If this option is not set correctly,
+	  system might hang after a certain amount of time.
 
 endif
diff --git a/drivers/net/ethernet/stmicro/stmmac/mmc_core.c b/drivers/net/ethernet/stmicro/stmmac/mmc_core.c
index 0c74a70..ae877ee 100644
--- a/drivers/net/ethernet/stmicro/stmmac/mmc_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/mmc_core.c
@@ -149,6 +149,9 @@ void dwmac_mmc_intr_all_mask(void __iomem *ioaddr)
 {
 	writel(MMC_DEFAULT_MASK, ioaddr + MMC_RX_INTR_MASK);
 	writel(MMC_DEFAULT_MASK, ioaddr + MMC_TX_INTR_MASK);
+#ifdef CONFIG_STMMAC_RX_IPC_CTRS
+	writel(MMC_DEFAULT_MASK, ioaddr + MMC_RX_IPC_INTR_MASK);
+#endif
 }
 
 /* This reads the MAC core counters (if actaully supported).
-- 
1.7.1
