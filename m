From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH v3 1/4] sh_eth: Remove obsolete r7s72100-ether platform_device_id entry
Date: Tue, 24 Nov 2015 15:40:57 +0100
Message-ID: <1448376060-7803-2-git-send-email-geert+renesas@glider.be>
References: <1448376060-7803-1-git-send-email-geert+renesas@glider.be>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	Geert Uytterhoeven <geert+renesas@glider.be>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xavier.telenet-ops.be ([195.130.132.52]:51457 "EHLO
	xavier.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754102AbbKXOk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 09:40:56 -0500
In-Reply-To: <1448376060-7803-1-git-send-email-geert+renesas@glider.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 05104c266ae9a167 ("ARM: shmobile: r7s72100: genmai: Remove
legacy board file"), r7s72100 is only supported in generic DT-only ARM
multi-platform builds.  The driver doesn't need to match platform
devices by name anymore, hence remove the corresponding
platform_device_id entry.

Protect r7s72100_data by #ifdef CONFIG_OF as it's now referenced on DT
platforms only. Move it to a more logical position, in front of the
r8a777x support, so we can have a single #ifdef covering all r7s* and
r8a* support soon. This requires moving a helper function, too.

Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
Acked-by: Simon Horman <horms+renesas@verge.net.au>
---
v3:
  - No changes,

v2:
  - Add Acked-by,
  - Protect r7s72100_data by #ifdef CONFIG_OF to silence a compiler
    warning on SH,
  - Move r7s72100_data.
---
 drivers/net/ethernet/renesas/sh_eth.c | 83 ++++++++++++++++++-----------------
 1 file changed, 42 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index e7bab7909ed9e186..fca688fbefc1c49d 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -449,6 +449,48 @@ static void sh_eth_set_duplex(struct net_device *ndev)
 		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) & ~ECMR_DM, ECMR);
 }
 
+static void sh_eth_chip_reset(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+
+	/* reset device */
+	sh_eth_tsu_write(mdp, ARSTR_ARSTR, ARSTR);
+	mdelay(1);
+}
+
+#ifdef CONFIG_OF
+/* R7S72100 */
+static struct sh_eth_cpu_data r7s72100_data = {
+	.chip_reset	= sh_eth_chip_reset,
+	.set_duplex	= sh_eth_set_duplex,
+
+	.register_type	= SH_ETH_REG_FAST_RZ,
+
+	.ecsr_value	= ECSR_ICD,
+	.ecsipr_value	= ECSIPR_ICDIP,
+	.eesipr_value	= 0xff7f009f,
+
+	.tx_check	= EESR_TC1 | EESR_FTC,
+	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT |
+			  EESR_RFE | EESR_RDE | EESR_RFRMER | EESR_TFE |
+			  EESR_TDE | EESR_ECI,
+	.fdr_value	= 0x0000070f,
+
+	.no_psr		= 1,
+	.apr		= 1,
+	.mpr		= 1,
+	.tpauser	= 1,
+	.hw_swap	= 1,
+	.rpadir		= 1,
+	.rpadir_value   = 2 << 16,
+	.no_trimd	= 1,
+	.no_ade		= 1,
+	.hw_crc		= 1,
+	.tsu		= 1,
+	.shift_rd0	= 1,
+};
+#endif /* CONFIG_OF */
+
 /* There is CPU dependent code */
 static void sh_eth_set_rate_r8a777x(struct net_device *ndev)
 {
@@ -671,15 +713,6 @@ static struct sh_eth_cpu_data sh7757_data_giga = {
 	.tsu		= 1,
 };
 
-static void sh_eth_chip_reset(struct net_device *ndev)
-{
-	struct sh_eth_private *mdp = netdev_priv(ndev);
-
-	/* reset device */
-	sh_eth_tsu_write(mdp, ARSTR_ARSTR, ARSTR);
-	mdelay(1);
-}
-
 static void sh_eth_set_rate_gether(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
@@ -799,37 +832,6 @@ static struct sh_eth_cpu_data r8a7740_data = {
 	.shift_rd0	= 1,
 };
 
-/* R7S72100 */
-static struct sh_eth_cpu_data r7s72100_data = {
-	.chip_reset	= sh_eth_chip_reset,
-	.set_duplex	= sh_eth_set_duplex,
-
-	.register_type	= SH_ETH_REG_FAST_RZ,
-
-	.ecsr_value	= ECSR_ICD,
-	.ecsipr_value	= ECSIPR_ICDIP,
-	.eesipr_value	= 0xff7f009f,
-
-	.tx_check	= EESR_TC1 | EESR_FTC,
-	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT |
-			  EESR_RFE | EESR_RDE | EESR_RFRMER | EESR_TFE |
-			  EESR_TDE | EESR_ECI,
-	.fdr_value	= 0x0000070f,
-
-	.no_psr		= 1,
-	.apr		= 1,
-	.mpr		= 1,
-	.tpauser	= 1,
-	.hw_swap	= 1,
-	.rpadir		= 1,
-	.rpadir_value   = 2 << 16,
-	.no_trimd	= 1,
-	.no_ade		= 1,
-	.hw_crc		= 1,
-	.tsu		= 1,
-	.shift_rd0	= 1,
-};
-
 static struct sh_eth_cpu_data sh7619_data = {
 	.register_type	= SH_ETH_REG_FAST_SH3_SH2,
 
@@ -3277,7 +3279,6 @@ static struct platform_device_id sh_eth_id_table[] = {
 	{ "sh7757-ether", (kernel_ulong_t)&sh7757_data },
 	{ "sh7757-gether", (kernel_ulong_t)&sh7757_data_giga },
 	{ "sh7763-gether", (kernel_ulong_t)&sh7763_data },
-	{ "r7s72100-ether", (kernel_ulong_t)&r7s72100_data },
 	{ "r8a7740-gether", (kernel_ulong_t)&r8a7740_data },
 	{ "r8a777x-ether", (kernel_ulong_t)&r8a777x_data },
 	{ "r8a7790-ether", (kernel_ulong_t)&r8a779x_data },
-- 
1.9.1
