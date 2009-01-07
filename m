From: Timur Tabi <timur@freescale.com>
Subject: [PATCH] ucc_geth: use correct UCCE macros
Date: Wed,  7 Jan 2009 14:12:52 -0600
Message-ID: <1231359172-6119-1-git-send-email-timur@freescale.com>
To: netdev@vger.kernel.org, leoli@freescale.com, davem@davemloft.net,
	galak@kernel.crashing.org, linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:36311 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751665AbZAGUNX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 15:13:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The UCC Event Register (UCCE) already has unambigous macro definitions in qe.h,
so we should not be defining our own in the UCC Ethernet driver.

Removed unused local variable 'dev' from ucc_geth_poll(), which fixes a warning
caused by commit 908a7a16b852ffd618a9127be8d62432182d81b4.

Replaced in_be/out_be pairs with setbits32 or clrbits32, where applicable.

Signed-off-by: Timur Tabi <timur@freescale.com>
---

This patch will break ucc_geth.c if my other patch, "powerpc: add Ethernet
UPSMR definitions to QE library" isn't also applied.  That patch is currently
in Kumar's 'next' branch, so it will make 2.6.29-rc0.  Therefore, it should
be safe to apply this patch to 'net-next' today, with the understanding that
everything will be peachy once Linus pulls everyone's 2.6.29 branches.

 drivers/net/ucc_geth.c |  128 ++++++++++++++++--------------------------------
 drivers/net/ucc_geth.h |  114 +++++++++---------------------------------
 2 files changed, 68 insertions(+), 174 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 7d5a130..1144122 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -442,40 +442,30 @@ static void magic_packet_detection_enable(struct ucc_geth_private *ugeth)
 {
 	struct ucc_fast_private *uccf;
 	struct ucc_geth __iomem *ug_regs;
-	u32 maccfg2, uccm;
 
 	uccf = ugeth->uccf;
 	ug_regs = ugeth->ug_regs;
 
 	/* Enable interrupts for magic packet detection */
-	uccm = in_be32(uccf->p_uccm);
-	uccm |= UCCE_MPD;
-	out_be32(uccf->p_uccm, uccm);
+	setbits32(uccf->p_uccm, UCC_GETH_UCCE_MPD);
 
 	/* Enable magic packet detection */
-	maccfg2 = in_be32(&ug_regs->maccfg2);
-	maccfg2 |= MACCFG2_MPE;
-	out_be32(&ug_regs->maccfg2, maccfg2);
+	setbits32(&ug_regs->maccfg2, MACCFG2_MPE);
 }
 
 static void magic_packet_detection_disable(struct ucc_geth_private *ugeth)
 {
 	struct ucc_fast_private *uccf;
 	struct ucc_geth __iomem *ug_regs;
-	u32 maccfg2, uccm;
 
 	uccf = ugeth->uccf;
 	ug_regs = ugeth->ug_regs;
 
 	/* Disable interrupts for magic packet detection */
-	uccm = in_be32(uccf->p_uccm);
-	uccm &= ~UCCE_MPD;
-	out_be32(uccf->p_uccm, uccm);
+	clrbits32(uccf->p_uccm, UCC_GETH_UCCE_MPD);
 
 	/* Disable magic packet detection */
-	maccfg2 = in_be32(&ug_regs->maccfg2);
-	maccfg2 &= ~MACCFG2_MPE;
-	out_be32(&ug_regs->maccfg2, maccfg2);
+	clrbits32(&ug_regs->maccfg2, MACCFG2_MPE);
 }
 #endif /* MAGIC_PACKET */
 
@@ -585,7 +575,8 @@ static void get_statistics(struct ucc_geth_private *ugeth,
 
 	/* Hardware only if user handed pointer and driver actually
 	gathers hardware statistics */
-	if (hardware_statistics && (in_be32(&uf_regs->upsmr) & UPSMR_HSE)) {
+	if (hardware_statistics &&
+	    (in_be32(&uf_regs->upsmr) & UCC_GETH_UPSMR_HSE)) {
 		hardware_statistics->tx64 = in_be32(&ug_regs->tx64);
 		hardware_statistics->tx127 = in_be32(&ug_regs->tx127);
 		hardware_statistics->tx255 = in_be32(&ug_regs->tx255);
@@ -1181,9 +1172,7 @@ int init_flow_control_params(u32 automatic_flow_control_mode,
 	out_be32(uempr_register, value);
 
 	/* Set UPSMR register */
-	value = in_be32(upsmr_register);
-	value |= automatic_flow_control_mode;
-	out_be32(upsmr_register, value);
+	setbits32(upsmr_register, automatic_flow_control_mode);
 
 	value = in_be32(maccfg1_register);
 	if (rx_flow_control_enable)
@@ -1200,14 +1189,11 @@ static int init_hw_statistics_gathering_mode(int enable_hardware_statistics,
 					     u32 __iomem *upsmr_register,
 					     u16 __iomem *uescr_register)
 {
-	u32 upsmr_value = 0;
 	u16 uescr_value = 0;
+
 	/* Enable hardware statistics gathering if requested */
-	if (enable_hardware_statistics) {
-		upsmr_value = in_be32(upsmr_register);
-		upsmr_value |= UPSMR_HSE;
-		out_be32(upsmr_register, upsmr_value);
-	}
+	if (enable_hardware_statistics)
+		setbits32(upsmr_register, UCC_GETH_UPSMR_HSE);
 
 	/* Clear hardware statistics counters */
 	uescr_value = in_be16(uescr_register);
@@ -1233,23 +1219,17 @@ static int init_firmware_statistics_gathering_mode(int
 {
 	/* Note: this function does not check if */
 	/* the parameters it receives are NULL   */
-	u16 temoder_value;
-	u32 remoder_value;
 
 	if (enable_tx_firmware_statistics) {
 		out_be32(tx_rmon_base_ptr,
 			 tx_firmware_statistics_structure_address);
-		temoder_value = in_be16(temoder_register);
-		temoder_value |= TEMODER_TX_RMON_STATISTICS_ENABLE;
-		out_be16(temoder_register, temoder_value);
+		setbits16(temoder_register, TEMODER_TX_RMON_STATISTICS_ENABLE);
 	}
 
 	if (enable_rx_firmware_statistics) {
 		out_be32(rx_rmon_base_ptr,
 			 rx_firmware_statistics_structure_address);
-		remoder_value = in_be32(remoder_register);
-		remoder_value |= REMODER_RX_RMON_STATISTICS_ENABLE;
-		out_be32(remoder_register, remoder_value);
+		setbits32(remoder_register, REMODER_RX_RMON_STATISTICS_ENABLE);
 	}
 
 	return 0;
@@ -1316,15 +1296,12 @@ static int init_check_frame_length_mode(int length_check,
 static int init_preamble_length(u8 preamble_length,
 				u32 __iomem *maccfg2_register)
 {
-	u32 value = 0;
-
 	if ((preamble_length < 3) || (preamble_length > 7))
 		return -EINVAL;
 
-	value = in_be32(maccfg2_register);
-	value &= ~MACCFG2_PREL_MASK;
-	value |= (preamble_length << MACCFG2_PREL_SHIFT);
-	out_be32(maccfg2_register, value);
+	clrsetbits_be32(maccfg2_register, MACCFG2_PREL_MASK,
+			preamble_length << MACCFG2_PREL_SHIFT);
+
 	return 0;
 }
 
@@ -1337,19 +1314,19 @@ static int init_rx_parameters(int reject_broadcast,
 	value = in_be32(upsmr_register);
 
 	if (reject_broadcast)
-		value |= UPSMR_BRO;
+		value |= UCC_GETH_UPSMR_BRO;
 	else
-		value &= ~UPSMR_BRO;
+		value &= ~UCC_GETH_UPSMR_BRO;
 
 	if (receive_short_frames)
-		value |= UPSMR_RSH;
+		value |= UCC_GETH_UPSMR_RSH;
 	else
-		value &= ~UPSMR_RSH;
+		value &= ~UCC_GETH_UPSMR_RSH;
 
 	if (promiscuous)
-		value |= UPSMR_PRO;
+		value |= UCC_GETH_UPSMR_PRO;
 	else
-		value &= ~UPSMR_PRO;
+		value &= ~UCC_GETH_UPSMR_PRO;
 
 	out_be32(upsmr_register, value);
 
@@ -1410,26 +1387,27 @@ static int adjust_enet_interface(struct ucc_geth_private *ugeth)
 
 	/*                    Set UPSMR                      */
 	upsmr = in_be32(&uf_regs->upsmr);
-	upsmr &= ~(UPSMR_RPM | UPSMR_R10M | UPSMR_TBIM | UPSMR_RMM);
+	upsmr &= ~(UCC_GETH_UPSMR_RPM | UCC_GETH_UPSMR_R10M |
+		   UCC_GETH_UPSMR_TBIM | UCC_GETH_UPSMR_RMM);
 	if ((ugeth->phy_interface == PHY_INTERFACE_MODE_RMII) ||
 	    (ugeth->phy_interface == PHY_INTERFACE_MODE_RGMII) ||
 	    (ugeth->phy_interface == PHY_INTERFACE_MODE_RGMII_ID) ||
 	    (ugeth->phy_interface == PHY_INTERFACE_MODE_RGMII_RXID) ||
 	    (ugeth->phy_interface == PHY_INTERFACE_MODE_RGMII_TXID) ||
 	    (ugeth->phy_interface == PHY_INTERFACE_MODE_RTBI)) {
-		upsmr |= UPSMR_RPM;
+		upsmr |= UCC_GETH_UPSMR_RPM;
 		switch (ugeth->max_speed) {
 		case SPEED_10:
-			upsmr |= UPSMR_R10M;
+			upsmr |= UCC_GETH_UPSMR_R10M;
 			/* FALLTHROUGH */
 		case SPEED_100:
 			if (ugeth->phy_interface != PHY_INTERFACE_MODE_RTBI)
-				upsmr |= UPSMR_RMM;
+				upsmr |= UCC_GETH_UPSMR_RMM;
 		}
 	}
 	if ((ugeth->phy_interface == PHY_INTERFACE_MODE_TBI) ||
 	    (ugeth->phy_interface == PHY_INTERFACE_MODE_RTBI)) {
-		upsmr |= UPSMR_TBIM;
+		upsmr |= UCC_GETH_UPSMR_TBIM;
 	}
 	out_be32(&uf_regs->upsmr, upsmr);
 
@@ -1517,9 +1495,9 @@ static void adjust_link(struct net_device *dev)
 				    (ugeth->phy_interface == PHY_INTERFACE_MODE_RGMII_TXID) ||
 				    (ugeth->phy_interface == PHY_INTERFACE_MODE_RTBI)) {
 					if (phydev->speed == SPEED_10)
-						upsmr |= UPSMR_R10M;
+						upsmr |= UCC_GETH_UPSMR_R10M;
 					else
-						upsmr &= ~(UPSMR_R10M);
+						upsmr &= ~UCC_GETH_UPSMR_R10M;
 				}
 				break;
 			default:
@@ -1602,10 +1580,8 @@ static int ugeth_graceful_stop_tx(struct ucc_geth_private *ugeth)
 	uccf = ugeth->uccf;
 
 	/* Mask GRACEFUL STOP TX interrupt bit and clear it */
-	temp = in_be32(uccf->p_uccm);
-	temp &= ~UCCE_GRA;
-	out_be32(uccf->p_uccm, temp);
-	out_be32(uccf->p_ucce, UCCE_GRA);	/* clear by writing 1 */
+	clrbits32(uccf->p_uccm, UCC_GETH_UCCE_GRA);
+	out_be32(uccf->p_ucce, UCC_GETH_UCCE_GRA);  /* clear by writing 1 */
 
 	/* Issue host command */
 	cecr_subblock =
@@ -1617,7 +1593,7 @@ static int ugeth_graceful_stop_tx(struct ucc_geth_private *ugeth)
 	do {
 		msleep(10);
 		temp = in_be32(uccf->p_ucce);
-	} while (!(temp & UCCE_GRA) && --i);
+	} while (!(temp & UCC_GETH_UCCE_GRA) && --i);
 
 	uccf->stopped_tx = 1;
 
@@ -1975,12 +1951,9 @@ static void ucc_geth_set_multi(struct net_device *dev)
 	uf_regs = ugeth->uccf->uf_regs;
 
 	if (dev->flags & IFF_PROMISC) {
-
-		out_be32(&uf_regs->upsmr, in_be32(&uf_regs->upsmr) | UPSMR_PRO);
-
+		setbits32(&uf_regs->upsmr, UCC_GETH_UPSMR_PRO);
 	} else {
-
-		out_be32(&uf_regs->upsmr, in_be32(&uf_regs->upsmr)&~UPSMR_PRO);
+		clrbits32(&uf_regs->upsmr, UCC_GETH_UPSMR_PRO);
 
 		p_82xx_addr_filt =
 		    (struct ucc_geth_82xx_address_filtering_pram __iomem *) ugeth->
@@ -2020,7 +1993,6 @@ static void ucc_geth_stop(struct ucc_geth_private *ugeth)
 {
 	struct ucc_geth __iomem *ug_regs = ugeth->ug_regs;
 	struct phy_device *phydev = ugeth->phydev;
-	u32 tempval;
 
 	ugeth_vdbg("%s: IN", __func__);
 
@@ -2037,9 +2009,7 @@ static void ucc_geth_stop(struct ucc_geth_private *ugeth)
 	out_be32(ugeth->uccf->p_ucce, 0xffffffff);
 
 	/* Disable Rx and Tx */
-	tempval = in_be32(&ug_regs->maccfg1);
-	tempval &= ~(MACCFG1_ENABLE_RX | MACCFG1_ENABLE_TX);
-	out_be32(&ug_regs->maccfg1, tempval);
+	clrbits32(&ug_regs->maccfg1, MACCFG1_ENABLE_RX | MACCFG1_ENABLE_TX);
 
 	ucc_geth_memclean(ugeth);
 }
@@ -2153,10 +2123,10 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 	/* Generate uccm_mask for receive */
 	uf_info->uccm_mask = ug_info->eventRegMask & UCCE_OTHER;/* Errors */
 	for (i = 0; i < ug_info->numQueuesRx; i++)
-		uf_info->uccm_mask |= (UCCE_RXBF_SINGLE_MASK << i);
+		uf_info->uccm_mask |= (UCC_GETH_UCCE_RXF0 << i);
 
 	for (i = 0; i < ug_info->numQueuesTx; i++)
-		uf_info->uccm_mask |= (UCCE_TXBF_SINGLE_MASK << i);
+		uf_info->uccm_mask |= (UCC_GETH_UCCE_TXB0 << i);
 	/* Initialize the general fast UCC block. */
 	if (ucc_fast_init(uf_info, &ugeth->uccf)) {
 		if (netif_msg_probe(ugeth))
@@ -2185,7 +2155,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	struct ucc_geth __iomem *ug_regs;
 	int ret_val = -EINVAL;
 	u32 remoder = UCC_GETH_REMODER_INIT;
-	u32 init_enet_pram_offset, cecr_subblock, command, maccfg1;
+	u32 init_enet_pram_offset, cecr_subblock, command;
 	u32 ifstat, i, j, size, l2qt, l3qt, length;
 	u16 temoder = UCC_GETH_TEMODER_INIT;
 	u16 test;
@@ -2281,10 +2251,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 				 &uf_regs->upsmr,
 				 &ug_regs->uempr, &ug_regs->maccfg1);
 
-	maccfg1 = in_be32(&ug_regs->maccfg1);
-	maccfg1 |= MACCFG1_ENABLE_RX;
-	maccfg1 |= MACCFG1_ENABLE_TX;
-	out_be32(&ug_regs->maccfg1, maccfg1);
+	setbits32(&ug_regs->maccfg1, MACCFG1_ENABLE_RX | MACCFG1_ENABLE_TX);
 
 	/*                    Set IPGIFG                     */
 	/* For more details see the hardware spec.           */
@@ -3274,7 +3241,6 @@ static int ucc_geth_tx(struct net_device *dev, u8 txQ)
 static int ucc_geth_poll(struct napi_struct *napi, int budget)
 {
 	struct ucc_geth_private *ugeth = container_of(napi, struct ucc_geth_private, napi);
-	struct net_device *dev = ugeth->dev;
 	struct ucc_geth_info *ug_info;
 	int howmany, i;
 
@@ -3285,14 +3251,8 @@ static int ucc_geth_poll(struct napi_struct *napi, int budget)
 		howmany += ucc_geth_rx(ugeth, i, budget - howmany);
 
 	if (howmany < budget) {
-		struct ucc_fast_private *uccf;
-		u32 uccm;
-
 		netif_rx_complete(napi);
-		uccf = ugeth->uccf;
-		uccm = in_be32(uccf->p_uccm);
-		uccm |= UCCE_RX_EVENTS;
-		out_be32(uccf->p_uccm, uccm);
+		setbits32(ugeth->uccf->p_uccm, UCCE_RX_EVENTS);
 	}
 
 	return howmany;
@@ -3332,7 +3292,7 @@ static irqreturn_t ucc_geth_irq_handler(int irq, void *info)
 	/* Tx event processing */
 	if (ucce & UCCE_TX_EVENTS) {
 		spin_lock(&ugeth->lock);
-		tx_mask = UCCE_TXBF_SINGLE_MASK;
+		tx_mask = UCC_GETH_UCCE_TXB0;
 		for (i = 0; i < ug_info->numQueuesTx; i++) {
 			if (ucce & tx_mask)
 				ucc_geth_tx(dev, i);
@@ -3344,12 +3304,10 @@ static irqreturn_t ucc_geth_irq_handler(int irq, void *info)
 
 	/* Errors and other events */
 	if (ucce & UCCE_OTHER) {
-		if (ucce & UCCE_BSY) {
+		if (ucce & UCC_GETH_UCCE_BSY)
 			dev->stats.rx_errors++;
-		}
-		if (ucce & UCCE_TXE) {
+		if (ucce & UCC_GETH_UCCE_TXE)
 			dev->stats.tx_errors++;
-		}
 	}
 
 	return IRQ_HANDLED;
diff --git a/drivers/net/ucc_geth.h b/drivers/net/ucc_geth.h
index d74d2f7..8f699cb 100644
--- a/drivers/net/ucc_geth.h
+++ b/drivers/net/ucc_geth.h
@@ -162,92 +162,27 @@ struct ucc_geth {
 								   boundary */
 
 /* UCC GETH Event Register */
-#define UCCE_MPD                                0x80000000	/* Magic packet
-								   detection */
-#define UCCE_SCAR                               0x40000000
-#define UCCE_GRA                                0x20000000	/* Tx graceful
-								   stop
-								   complete */
-#define UCCE_CBPR                               0x10000000
-#define UCCE_BSY                                0x08000000
-#define UCCE_RXC                                0x04000000
-#define UCCE_TXC                                0x02000000
-#define UCCE_TXE                                0x01000000
-#define UCCE_TXB7                               0x00800000
-#define UCCE_TXB6                               0x00400000
-#define UCCE_TXB5                               0x00200000
-#define UCCE_TXB4                               0x00100000
-#define UCCE_TXB3                               0x00080000
-#define UCCE_TXB2                               0x00040000
-#define UCCE_TXB1                               0x00020000
-#define UCCE_TXB0                               0x00010000
-#define UCCE_RXB7                               0x00008000
-#define UCCE_RXB6                               0x00004000
-#define UCCE_RXB5                               0x00002000
-#define UCCE_RXB4                               0x00001000
-#define UCCE_RXB3                               0x00000800
-#define UCCE_RXB2                               0x00000400
-#define UCCE_RXB1                               0x00000200
-#define UCCE_RXB0                               0x00000100
-#define UCCE_RXF7                               0x00000080
-#define UCCE_RXF6                               0x00000040
-#define UCCE_RXF5                               0x00000020
-#define UCCE_RXF4                               0x00000010
-#define UCCE_RXF3                               0x00000008
-#define UCCE_RXF2                               0x00000004
-#define UCCE_RXF1                               0x00000002
-#define UCCE_RXF0                               0x00000001
-
-#define UCCE_RXBF_SINGLE_MASK                   (UCCE_RXF0)
-#define UCCE_TXBF_SINGLE_MASK                   (UCCE_TXB0)
-
-#define UCCE_TXB         (UCCE_TXB7 | UCCE_TXB6 | UCCE_TXB5 | UCCE_TXB4 |\
-			UCCE_TXB3 | UCCE_TXB2 | UCCE_TXB1 | UCCE_TXB0)
-#define UCCE_RXB         (UCCE_RXB7 | UCCE_RXB6 | UCCE_RXB5 | UCCE_RXB4 |\
-			UCCE_RXB3 | UCCE_RXB2 | UCCE_RXB1 | UCCE_RXB0)
-#define UCCE_RXF         (UCCE_RXF7 | UCCE_RXF6 | UCCE_RXF5 | UCCE_RXF4 |\
-			UCCE_RXF3 | UCCE_RXF2 | UCCE_RXF1 | UCCE_RXF0)
-#define UCCE_OTHER       (UCCE_SCAR | UCCE_GRA  | UCCE_CBPR | UCCE_BSY  |\
-			UCCE_RXC  | UCCE_TXC  | UCCE_TXE)
-
-#define UCCE_RX_EVENTS							(UCCE_RXF | UCCE_BSY)
-#define UCCE_TX_EVENTS							(UCCE_TXB | UCCE_TXE)
-
-/* UCC GETH UPSMR (Protocol Specific Mode Register) */
-#define UPSMR_ECM                               0x04000000	/* Enable CAM
-								   Miss or
-								   Enable
-								   Filtering
-								   Miss */
-#define UPSMR_HSE                               0x02000000	/* Hardware
-								   Statistics
-								   Enable */
-#define UPSMR_PRO                               0x00400000	/* Promiscuous*/
-#define UPSMR_CAP                               0x00200000	/* CAM polarity
-								 */
-#define UPSMR_RSH                               0x00100000	/* Receive
-								   Short Frames
-								 */
-#define UPSMR_RPM                               0x00080000	/* Reduced Pin
-								   Mode
-								   interfaces */
-#define UPSMR_R10M                              0x00040000	/* RGMII/RMII
-								   10 Mode */
-#define UPSMR_RLPB                              0x00020000	/* RMII
-								   Loopback
-								   Mode */
-#define UPSMR_TBIM                              0x00010000	/* Ten-bit
-								   Interface
-								   Mode */
-#define UPSMR_RMM                               0x00001000	/* RMII/RGMII
-								   Mode */
-#define UPSMR_CAM                               0x00000400	/* CAM Address
-								   Matching */
-#define UPSMR_BRO                               0x00000200	/* Broadcast
-								   Address */
-#define UPSMR_RES1                              0x00002000	/* Reserved
-								   feild - must
-								   be 1 */
+#define UCCE_TXB   (UCC_GETH_UCCE_TXB7 | UCC_GETH_UCCE_TXB6 | \
+		    UCC_GETH_UCCE_TXB5 | UCC_GETH_UCCE_TXB4 | \
+		    UCC_GETH_UCCE_TXB3 | UCC_GETH_UCCE_TXB2 | \
+		    UCC_GETH_UCCE_TXB1 | UCC_GETH_UCCE_TXB0)
+
+#define UCCE_RXB   (UCC_GETH_UCCE_RXB7 | UCC_GETH_UCCE_RXB6 | \
+		    UCC_GETH_UCCE_RXB5 | UCC_GETH_UCCE_RXB4 | \
+		    UCC_GETH_UCCE_RXB3 | UCC_GETH_UCCE_RXB2 | \
+		    UCC_GETH_UCCE_RXB1 | UCC_GETH_UCCE_RXB0)
+
+#define UCCE_RXF   (UCC_GETH_UCCE_RXF7 | UCC_GETH_UCCE_RXF6 | \
+		    UCC_GETH_UCCE_RXF5 | UCC_GETH_UCCE_RXF4 | \
+		    UCC_GETH_UCCE_RXF3 | UCC_GETH_UCCE_RXF2 | \
+		    UCC_GETH_UCCE_RXF1 | UCC_GETH_UCCE_RXF0)
+
+#define UCCE_OTHER (UCC_GETH_UCCE_SCAR | UCC_GETH_UCCE_GRA | \
+		    UCC_GETH_UCCE_CBPR | UCC_GETH_UCCE_BSY | \
+		    UCC_GETH_UCCE_RXC  | UCC_GETH_UCCE_TXC | UCC_GETH_UCCE_TXE)
+
+#define UCCE_RX_EVENTS  (UCCE_RXF | UCC_GETH_UCCE_BSY)
+#define UCCE_TX_EVENTS	(UCCE_TXB | UCC_GETH_UCCE_TXE)
 
 /* UCC GETH MACCFG1 (MAC Configuration 1 Register) */
 #define MACCFG1_FLOW_RX                         0x00000020	/* Flow Control
@@ -945,9 +880,10 @@ struct ucc_geth_hardware_statistics {
 #define UCC_GETH_REMODER_INIT                   0	/* bits that must be
 							   set */
 #define UCC_GETH_TEMODER_INIT                   0xC000	/* bits that must */
-#define UCC_GETH_UPSMR_INIT                     (UPSMR_RES1)	/* Start value
-								   for this
-								   register */
+
+/* Initial value for UPSMR */
+#define UCC_GETH_UPSMR_INIT                     UCC_GETH_UPSMR_RES1
+
 #define UCC_GETH_MACCFG1_INIT                   0
 #define UCC_GETH_MACCFG2_INIT                   (MACCFG2_RESERVED_1)
 
-- 
1.5.5

