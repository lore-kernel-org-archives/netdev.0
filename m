From: Phil Reid <preid@electromag.com.au>
Subject: [PATCH v2 3/5] stmmac: Fix calculations for ptp counters when clock input = 50Mhz.
Date: Mon,  7 Dec 2015 09:38:42 +0800
Message-ID: <1449452324-53858-5-git-send-email-preid@electromag.com.au>
References: <1449452324-53858-1-git-send-email-preid@electromag.com.au>
Cc: Phil Reid <preid@electromag.com.au>
To: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	peppe.cavallaro@st.com, davem@davemloft.net,
	devicetree@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 203-59-230-133.perm.iinet.net.au ([203.59.230.133]:49176 "EHLO
	preid-centos7.electromag.com.au" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754755AbbLGBjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2015 20:39:15 -0500
In-Reply-To: <1449452324-53858-1-git-send-email-preid@electromag.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

stmmac_config_sub_second_increment set the sub second increment to 20ns.
Driver is configured to use the fine adjustment method where the sub second
register is incremented when the acculumator incremented by the addend
register wraps overflows. This accumulator is update on every ptp clk
cycle. If a ptp clk with a period of greater than 20ns was used the
sub second register would not get updated correctly.

Instead set the sub sec increment to twice the period of the ptp clk.
This result in the addend register being set mid range and overflow
the accumlator every 2 clock cycles.

Signed-off-by: Phil Reid <preid@electromag.com.au>
---
 drivers/net/ethernet/stmicro/stmmac/common.h          |  2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c |  8 +++++---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c     | 18 +++++++-----------
 3 files changed, 13 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index f4518bc..1e19c8f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -439,7 +439,7 @@ struct stmmac_ops {
 /* PTP and HW Timer helpers */
 struct stmmac_hwtimestamp {
 	void (*config_hw_tstamping) (void __iomem *ioaddr, u32 data);
-	void (*config_sub_second_increment) (void __iomem *ioaddr);
+	u32 (*config_sub_second_increment) (void __iomem *ioaddr, u32 clk_rate);
 	int (*init_systime) (void __iomem *ioaddr, u32 sec, u32 nsec);
 	int (*config_addend) (void __iomem *ioaddr, u32 addend);
 	int (*adjust_systime) (void __iomem *ioaddr, u32 sec, u32 nsec,
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c
index 76ad214..83fa263 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c
@@ -33,22 +33,24 @@ static void stmmac_config_hw_tstamping(void __iomem *ioaddr, u32 data)
 	writel(data, ioaddr + PTP_TCR);
 }
 
-static void stmmac_config_sub_second_increment(void __iomem *ioaddr)
+static u32 stmmac_config_sub_second_increment(void __iomem *ioaddr, u32 ptp_clock)
 {
 	u32 value = readl(ioaddr + PTP_TCR);
 	unsigned long data;
 
 	/* Convert the ptp_clock to nano second
-	 * formula = (1/ptp_clock) * 1000000000
+	 * formula = (2/ptp_clock) * 1000000000
 	 * where, ptp_clock = 50MHz.
 	 */
-	data = (1000000000ULL / 50000000);
+	data = (2000000000ULL / ptp_clock);
 
 	/* 0.465ns accuracy */
 	if (!(value & PTP_TCR_TSCTRLSSR))
 		data = (data * 1000) / 465;
 
 	writel(data, ioaddr + PTP_SSIR);
+	
+	return data;
 }
 
 static int stmmac_init_systime(void __iomem *ioaddr, u32 sec, u32 nsec)
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 3c6549a..ab8d916 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -53,6 +53,7 @@
 #include "stmmac.h"
 #include <linux/reset.h>
 #include <linux/of_mdio.h>
+#include "dwmac1000.h"
 
 #define STMMAC_ALIGN(x)	L1_CACHE_ALIGN(x)
 
@@ -185,7 +186,7 @@ static void stmmac_clk_csr_set(struct stmmac_priv *priv)
 			priv->clk_csr = STMMAC_CSR_100_150M;
 		else if ((clk_rate >= CSR_F_150M) && (clk_rate < CSR_F_250M))
 			priv->clk_csr = STMMAC_CSR_150_250M;
-		else if ((clk_rate >= CSR_F_250M) && (clk_rate <= CSR_F_300M))
+		else if ((clk_rate >= CSR_F_250M) && (clk_rate < CSR_F_300M))
 			priv->clk_csr = STMMAC_CSR_250_300M;
 	}
 }
@@ -435,6 +436,7 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 	u32 ts_master_en = 0;
 	u32 ts_event_en = 0;
 	u32 value = 0;
+	u32 sec_inc;
 
 	if (!(priv->dma_cap.time_stamp || priv->adv_ts)) {
 		netdev_alert(priv->dev, "No support for HW time stamping\n");
@@ -598,24 +600,18 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 			 tstamp_all | ptp_v2 | ptp_over_ethernet |
 			 ptp_over_ipv6_udp | ptp_over_ipv4_udp | ts_event_en |
 			 ts_master_en | snap_type_sel);
-
 		priv->hw->ptp->config_hw_tstamping(priv->ioaddr, value);
 
 		/* program Sub Second Increment reg */
-		priv->hw->ptp->config_sub_second_increment(priv->ioaddr);
+		sec_inc = priv->hw->ptp->config_sub_second_increment(priv->ioaddr, priv->clk_ptp_rate);
+		temp = div_u64(1000000000ULL, sec_inc);
 
 		/* calculate default added value:
 		 * formula is :
 		 * addend = (2^32)/freq_div_ratio;
-		 * where, freq_div_ratio = clk_ptp_ref_i/50MHz
-		 * hence, addend = ((2^32) * 50MHz)/clk_ptp_ref_i;
-		 * NOTE: clk_ptp_ref_i should be >= 50MHz to
-		 *       achieve 20ns accuracy.
-		 *
-		 * 2^x * y == (y << x), hence
-		 * 2^32 * 50000000 ==> (50000000 << 32)
+		 * where, freq_div_ratio = 1e9ns/sec_inc
 		 */
-		temp = (u64) (50000000ULL << 32);
+		temp = (u64) (temp << 32);
 		priv->default_addend = div_u64(temp, priv->clk_ptp_rate);
 		priv->hw->ptp->config_addend(priv->ioaddr,
 					     priv->default_addend);
-- 
1.8.3.1
