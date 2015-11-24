From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH v3 3/4] sh_eth: Remove obsolete r8a7740-gether platform_device_id entry
Date: Tue, 24 Nov 2015 15:40:59 +0100
Message-ID: <1448376060-7803-4-git-send-email-geert+renesas@glider.be>
References: <1448376060-7803-1-git-send-email-geert+renesas@glider.be>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	Geert Uytterhoeven <geert+renesas@glider.be>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from andre.telenet-ops.be ([195.130.132.53]:49681 "EHLO
	andre.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754143AbbKXOk5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 09:40:57 -0500
In-Reply-To: <1448376060-7803-1-git-send-email-geert+renesas@glider.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 1fa59bda21c7fa36 ("ARM: shmobile: Remove legacy board code
for Armadillo-800 EVA"), r8a7740 is only supported in generic DT-only
ARM multi-platform builds.  The driver doesn't need to match platform
devices by name anymore, hence remove the corresponding
platform_device_id entry.

Protect r8a7740_data by #ifdef CONFIG_OF as it's now referenced on DT
platforms only. Move it to a more logical position, in front of the
r8a777x support, so we can have a single #ifdef covering all r7s* and
r8a* support soon. This requires moving a few helper functions, too.

Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
Acked-by: Simon Horman <horms+renesas@verge.net.au>
---
v3:
  - Add Acked-by,

v2:
  - New.
---
 drivers/net/ethernet/renesas/sh_eth.c | 125 +++++++++++++++++-----------------
 1 file changed, 62 insertions(+), 63 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 1af07f9de243d613..99618bf513b26184 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -458,6 +458,25 @@ static void sh_eth_chip_reset(struct net_device *ndev)
 	mdelay(1);
 }
 
+static void sh_eth_set_rate_gether(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+
+	switch (mdp->speed) {
+	case 10: /* 10BASE */
+		sh_eth_write(ndev, GECMR_10, GECMR);
+		break;
+	case 100:/* 100BASE */
+		sh_eth_write(ndev, GECMR_100, GECMR);
+		break;
+	case 1000: /* 1000BASE */
+		sh_eth_write(ndev, GECMR_1000, GECMR);
+		break;
+	default:
+		break;
+	}
+}
+
 #ifdef CONFIG_OF
 /* R7S72100 */
 static struct sh_eth_cpu_data r7s72100_data = {
@@ -489,6 +508,49 @@ static struct sh_eth_cpu_data r7s72100_data = {
 	.tsu		= 1,
 	.shift_rd0	= 1,
 };
+
+static void sh_eth_chip_reset_r8a7740(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+
+	/* reset device */
+	sh_eth_tsu_write(mdp, ARSTR_ARSTR, ARSTR);
+	mdelay(1);
+
+	sh_eth_select_mii(ndev);
+}
+
+/* R8A7740 */
+static struct sh_eth_cpu_data r8a7740_data = {
+	.chip_reset	= sh_eth_chip_reset_r8a7740,
+	.set_duplex	= sh_eth_set_duplex,
+	.set_rate	= sh_eth_set_rate_gether,
+
+	.register_type	= SH_ETH_REG_GIGABIT,
+
+	.ecsr_value	= ECSR_ICD | ECSR_MPD,
+	.ecsipr_value	= ECSIPR_LCHNGIP | ECSIPR_ICDIP | ECSIPR_MPDIP,
+	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
+
+	.tx_check	= EESR_TC1 | EESR_FTC,
+	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT |
+			  EESR_RFE | EESR_RDE | EESR_RFRMER | EESR_TFE |
+			  EESR_TDE | EESR_ECI,
+	.fdr_value	= 0x0000070f,
+
+	.apr		= 1,
+	.mpr		= 1,
+	.tpauser	= 1,
+	.bculr		= 1,
+	.hw_swap	= 1,
+	.rpadir		= 1,
+	.rpadir_value   = 2 << 16,
+	.no_trimd	= 1,
+	.no_ade		= 1,
+	.tsu		= 1,
+	.select_mii	= 1,
+	.shift_rd0	= 1,
+};
 #endif /* CONFIG_OF */
 
 /* There is CPU dependent code */
@@ -715,25 +777,6 @@ static struct sh_eth_cpu_data sh7757_data_giga = {
 	.tsu		= 1,
 };
 
-static void sh_eth_set_rate_gether(struct net_device *ndev)
-{
-	struct sh_eth_private *mdp = netdev_priv(ndev);
-
-	switch (mdp->speed) {
-	case 10: /* 10BASE */
-		sh_eth_write(ndev, GECMR_10, GECMR);
-		break;
-	case 100:/* 100BASE */
-		sh_eth_write(ndev, GECMR_100, GECMR);
-		break;
-	case 1000: /* 1000BASE */
-		sh_eth_write(ndev, GECMR_1000, GECMR);
-		break;
-	default:
-		break;
-	}
-}
-
 /* SH7734 */
 static struct sh_eth_cpu_data sh7734_data = {
 	.chip_reset	= sh_eth_chip_reset,
@@ -791,49 +834,6 @@ static struct sh_eth_cpu_data sh7763_data = {
 	.irq_flags	= IRQF_SHARED,
 };
 
-static void sh_eth_chip_reset_r8a7740(struct net_device *ndev)
-{
-	struct sh_eth_private *mdp = netdev_priv(ndev);
-
-	/* reset device */
-	sh_eth_tsu_write(mdp, ARSTR_ARSTR, ARSTR);
-	mdelay(1);
-
-	sh_eth_select_mii(ndev);
-}
-
-/* R8A7740 */
-static struct sh_eth_cpu_data r8a7740_data = {
-	.chip_reset	= sh_eth_chip_reset_r8a7740,
-	.set_duplex	= sh_eth_set_duplex,
-	.set_rate	= sh_eth_set_rate_gether,
-
-	.register_type	= SH_ETH_REG_GIGABIT,
-
-	.ecsr_value	= ECSR_ICD | ECSR_MPD,
-	.ecsipr_value	= ECSIPR_LCHNGIP | ECSIPR_ICDIP | ECSIPR_MPDIP,
-	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
-
-	.tx_check	= EESR_TC1 | EESR_FTC,
-	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT |
-			  EESR_RFE | EESR_RDE | EESR_RFRMER | EESR_TFE |
-			  EESR_TDE | EESR_ECI,
-	.fdr_value	= 0x0000070f,
-
-	.apr		= 1,
-	.mpr		= 1,
-	.tpauser	= 1,
-	.bculr		= 1,
-	.hw_swap	= 1,
-	.rpadir		= 1,
-	.rpadir_value   = 2 << 16,
-	.no_trimd	= 1,
-	.no_ade		= 1,
-	.tsu		= 1,
-	.select_mii	= 1,
-	.shift_rd0	= 1,
-};
-
 static struct sh_eth_cpu_data sh7619_data = {
 	.register_type	= SH_ETH_REG_FAST_SH3_SH2,
 
@@ -3281,7 +3281,6 @@ static struct platform_device_id sh_eth_id_table[] = {
 	{ "sh7757-ether", (kernel_ulong_t)&sh7757_data },
 	{ "sh7757-gether", (kernel_ulong_t)&sh7757_data_giga },
 	{ "sh7763-gether", (kernel_ulong_t)&sh7763_data },
-	{ "r8a7740-gether", (kernel_ulong_t)&r8a7740_data },
 	{ "r8a777x-ether", (kernel_ulong_t)&r8a777x_data },
 	{ }
 };
-- 
1.9.1
