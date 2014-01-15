From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH v5 net-next 2/4] sh_eth: Add support for r7s72100
Date: Wed, 15 Jan 2014 15:12:19 +0900
Message-ID: <1389766341-14001-3-git-send-email-horms+renesas@verge.net.au>
References: <1389766341-14001-1-git-send-email-horms+renesas@verge.net.au>
Cc: linux-arm-kernel@lists.infradead.org,
	Magnus Damm <magnus.damm@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Simon Horman <horms+renesas@verge.net.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:41314 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770AbaAOGMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 01:12:39 -0500
In-Reply-To: <1389766341-14001-1-git-send-email-horms+renesas@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a fast ethernet controller.

Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

---
v5
* As suggested by Sergei Shtylyov
  - Do not use sh_eth_chip_reset_r8a7740 as it accesses non-existent
    RMII registers. Instead use sh_eth_chip_reset.
  - Do not use sh_eth_set_rate_gether as it accesses non-existent registers.
  - Do not use reserved LCHNG bit of ECSR
  - Do not use reserved LCHNGIP bit of ECSIPR
  - Document that R8A779x also needs a 16 bit shift of the RFS bits
  - Do not document that the R7S72100 has GECMR, it does not

v4
* As requested by David Miller
  - Use a boolean for the return value of sh_eth_is_rz_fast_ether()
  - Correct coding style in sh_eth_get_stats()

v3
* No change

v2
* As suggested by Magnus Damm and Sergei Shtylyov
  - r7s72100 ethernet is not gigabit so do not refer to it as such

* As suggested by Magnus Damm
  - As RZ specific register layout rather than using the gigabit layout
    which includes registers that do not exist on this chip.
---
 drivers/net/ethernet/renesas/sh_eth.c | 126 ++++++++++++++++++++++++++++++++--
 drivers/net/ethernet/renesas/sh_eth.h |   3 +-
 2 files changed, 121 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 4f5cfad..a7a0555 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -190,6 +190,64 @@ static const u16 sh_eth_offset_fast_rcar[SH_ETH_MAX_REGISTER_OFFSET] = {
 	[TRIMD]		= 0x027c,
 };
 
+static const u16 sh_eth_offset_fast_rz[SH_ETH_MAX_REGISTER_OFFSET] = {
+	[EDSR]		= 0x0000,
+	[EDMR]		= 0x0400,
+	[EDTRR]		= 0x0408,
+	[EDRRR]		= 0x0410,
+	[EESR]		= 0x0428,
+	[EESIPR]	= 0x0430,
+	[TDLAR]		= 0x0010,
+	[TDFAR]		= 0x0014,
+	[TDFXR]		= 0x0018,
+	[TDFFR]		= 0x001c,
+	[RDLAR]		= 0x0030,
+	[RDFAR]		= 0x0034,
+	[RDFXR]		= 0x0038,
+	[RDFFR]		= 0x003c,
+	[TRSCER]	= 0x0438,
+	[RMFCR]		= 0x0440,
+	[TFTR]		= 0x0448,
+	[FDR]		= 0x0450,
+	[RMCR]		= 0x0458,
+	[RPADIR]	= 0x0460,
+	[FCFTR]		= 0x0468,
+	[CSMR]		= 0x04E4,
+
+	[ECMR]		= 0x0500,
+	[RFLR]		= 0x0508,
+	[ECSR]		= 0x0510,
+	[ECSIPR]	= 0x0518,
+	[PIR]		= 0x0520,
+	[APR]		= 0x0554,
+	[MPR]		= 0x0558,
+	[PFTCR]		= 0x055c,
+	[PFRCR]		= 0x0560,
+	[TPAUSER]	= 0x0564,
+	[MAHR]		= 0x05c0,
+	[MALR]		= 0x05c8,
+	[CEFCR]		= 0x0740,
+	[FRECR]		= 0x0748,
+	[TSFRCR]	= 0x0750,
+	[TLFRCR]	= 0x0758,
+	[RFCR]		= 0x0760,
+	[MAFCR]		= 0x0778,
+
+	[ARSTR]		= 0x0000,
+	[TSU_CTRST]	= 0x0004,
+	[TSU_VTAG0]	= 0x0058,
+	[TSU_ADSBSY]	= 0x0060,
+	[TSU_TEN]	= 0x0064,
+	[TXNLCR0]	= 0x0080,
+	[TXALCR0]	= 0x0084,
+	[RXNLCR0]	= 0x0088,
+	[RXALCR0]	= 0x008C,
+	[TSU_ADRH0]	= 0x0100,
+	[TSU_ADRL0]	= 0x0104,
+	[TSU_ADRH31]	= 0x01f8,
+	[TSU_ADRL31]	= 0x01fc,
+};
+
 static const u16 sh_eth_offset_fast_sh4[SH_ETH_MAX_REGISTER_OFFSET] = {
 	[ECMR]		= 0x0100,
 	[RFLR]		= 0x0108,
@@ -318,6 +376,14 @@ static bool sh_eth_is_gether(struct sh_eth_private *mdp)
 		return false;
 }
 
+static bool sh_eth_is_rz_fast_ether(struct sh_eth_private *mdp)
+{
+	if (mdp->reg_offset == sh_eth_offset_fast_rz)
+		return true;
+	else
+		return false;
+}
+
 static void sh_eth_select_mii(struct net_device *ndev)
 {
 	u32 value = 0x0;
@@ -701,6 +767,38 @@ static struct sh_eth_cpu_data r8a7740_data = {
 	.shift_rd0	= 1,
 };
 
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
+	.rmcr_value	= RMCR_RNC,
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
+
 static struct sh_eth_cpu_data sh7619_data = {
 	.register_type	= SH_ETH_REG_FAST_SH3_SH2,
 
@@ -767,7 +865,7 @@ static int sh_eth_reset(struct net_device *ndev)
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	int ret = 0;
 
-	if (sh_eth_is_gether(mdp)) {
+	if (sh_eth_is_gether(mdp) || sh_eth_is_rz_fast_ether(mdp)) {
 		sh_eth_write(ndev, EDSR_ENALL, EDSR);
 		sh_eth_write(ndev, sh_eth_read(ndev, EDMR) | EDMR_SRST_GETHER,
 			     EDMR);
@@ -878,7 +976,7 @@ static void read_mac_address(struct net_device *ndev, unsigned char *mac)
 
 static unsigned long sh_eth_get_edtrr_trns(struct sh_eth_private *mdp)
 {
-	if (sh_eth_is_gether(mdp))
+	if (sh_eth_is_gether(mdp) || sh_eth_is_rz_fast_ether(mdp))
 		return EDTRR_TRNS_GETHER;
 	else
 		return EDTRR_TRNS_ETHER;
@@ -1041,7 +1139,8 @@ static void sh_eth_ring_format(struct net_device *ndev)
 		/* Rx descriptor address set */
 		if (i == 0) {
 			sh_eth_write(ndev, mdp->rx_desc_dma, RDLAR);
-			if (sh_eth_is_gether(mdp))
+			if (sh_eth_is_gether(mdp) ||
+			    sh_eth_is_rz_fast_ether(mdp))
 				sh_eth_write(ndev, mdp->rx_desc_dma, RDFAR);
 		}
 	}
@@ -1062,7 +1161,8 @@ static void sh_eth_ring_format(struct net_device *ndev)
 		if (i == 0) {
 			/* Tx descriptor address set */
 			sh_eth_write(ndev, mdp->tx_desc_dma, TDLAR);
-			if (sh_eth_is_gether(mdp))
+			if (sh_eth_is_gether(mdp) ||
+			    sh_eth_is_rz_fast_ether(mdp))
 				sh_eth_write(ndev, mdp->tx_desc_dma, TDFAR);
 		}
 	}
@@ -1309,9 +1409,9 @@ static int sh_eth_rx(struct net_device *ndev, u32 intr_status, int *quota)
 
 		/* In case of almost all GETHER/ETHERs, the Receive Frame State
 		 * (RFS) bits in the Receive Descriptor 0 are from bit 9 to
-		 * bit 0. However, in case of the R8A7740's GETHER, the RFS
-		 * bits are from bit 25 to bit 16. So, the driver needs right
-		 * shifting by 16.
+		 * bit 0. However, in case of the R8A7740, R8A779x and
+		 * R7S72100 the RFS bits are from bit 25 to bit 16. So, the
+		 * driver needs right shifting by 16.
 		 */
 		if (mdp->cd->shift_rd0)
 			desc_status >>= 16;
@@ -2061,6 +2161,9 @@ static struct net_device_stats *sh_eth_get_stats(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 
+	if (sh_eth_is_rz_fast_ether(mdp))
+		return &ndev->stats;
+
 	pm_runtime_get_sync(&mdp->pdev->dev);
 
 	ndev->stats.tx_dropped += sh_eth_read(ndev, TROCR);
@@ -2442,6 +2545,11 @@ static int sh_eth_vlan_rx_kill_vid(struct net_device *ndev,
 /* SuperH's TSU register init function */
 static void sh_eth_tsu_init(struct sh_eth_private *mdp)
 {
+	if (sh_eth_is_rz_fast_ether(mdp)) {
+		sh_eth_tsu_write(mdp, 0, TSU_TEN); /* Disable all CAM entry */
+		return;
+	}
+
 	sh_eth_tsu_write(mdp, 0, TSU_FWEN0);	/* Disable forward(0->1) */
 	sh_eth_tsu_write(mdp, 0, TSU_FWEN1);	/* Disable forward(1->0) */
 	sh_eth_tsu_write(mdp, 0, TSU_FCM);	/* forward fifo 3k-3k */
@@ -2561,6 +2669,9 @@ static const u16 *sh_eth_get_register_offset(int register_type)
 	case SH_ETH_REG_GIGABIT:
 		reg_offset = sh_eth_offset_gigabit;
 		break;
+	case SH_ETH_REG_FAST_RZ:
+		reg_offset = sh_eth_offset_fast_rz;
+		break;
 	case SH_ETH_REG_FAST_RCAR:
 		reg_offset = sh_eth_offset_fast_rcar;
 		break;
@@ -2799,6 +2910,7 @@ static struct platform_device_id sh_eth_id_table[] = {
 	{ "sh7757-ether", (kernel_ulong_t)&sh7757_data },
 	{ "sh7757-gether", (kernel_ulong_t)&sh7757_data_giga },
 	{ "sh7763-gether", (kernel_ulong_t)&sh7763_data },
+	{ "r7s72100-ether", (kernel_ulong_t)&r7s72100_data },
 	{ "r8a7740-gether", (kernel_ulong_t)&r8a7740_data },
 	{ "r8a777x-ether", (kernel_ulong_t)&r8a777x_data },
 	{ "r8a7790-ether", (kernel_ulong_t)&r8a779x_data },
diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
index 0fe35b7..6075915 100644
--- a/drivers/net/ethernet/renesas/sh_eth.h
+++ b/drivers/net/ethernet/renesas/sh_eth.h
@@ -155,6 +155,7 @@ enum {
 
 enum {
 	SH_ETH_REG_GIGABIT,
+	SH_ETH_REG_FAST_RZ,
 	SH_ETH_REG_FAST_RCAR,
 	SH_ETH_REG_FAST_SH4,
 	SH_ETH_REG_FAST_SH3_SH2
@@ -169,7 +170,7 @@ enum {
 
 /* Register's bits
  */
-/* EDSR : sh7734, sh7757, sh7763, and r8a7740 only */
+/* EDSR : sh7734, sh7757, sh7763, r8a7740, and r7s72100 only */
 enum EDSR_BIT {
 	EDSR_ENT = 0x01, EDSR_ENR = 0x02,
 };
-- 
1.8.4
