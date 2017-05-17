From: Holger Brunck <holger.brunck@keymile.com>
Subject: [PATCH net-next 7/8] net/wan/fsl_ucc_hdlc: add hdlc-bus support
Date: Wed, 17 May 2017 17:24:38 +0200
Message-ID: <20170517152439.8817-7-holger.brunck@keymile.com>
References: <20170517152439.8817-1-holger.brunck@keymile.com>
Cc: Holger Brunck <holger.brunck@keymile.com>,
        Zhao Qiang <qiang.zhao@nxp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-de.keymile.com ([195.8.104.250]:47211 "EHLO
        mail-de.keymile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753587AbdEQPbL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 11:31:11 -0400
In-Reply-To: <20170517152439.8817-1-holger.brunck@keymile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support for hdlc-bus mode to the fsl_ucc_hdlc driver. This can
be enabled with the "fsl,hdlc-bus" property in the DTS node of the
corresponding ucc.

This aligns the configuration of the UPSMR and GUMR registers to what is
done in our ucc_hdlc driver (that only support hdlc-bus mode) and with
the QuickEngine's documentation for hdlc-bus mode.

GUMR/SYNL is set to AUTO for the busmode as in this case the CD signal
is ignored. The brkpt_support is enabled to set the HBM1 bit in the
CMXUCR register to configure an open-drain connected HDLC bus.

Signed-off-by: Holger Brunck <holger.brunck@keymile.com>
Cc: Zhao Qiang <qiang.zhao@nxp.com>
---
 drivers/net/wan/fsl_ucc_hdlc.c | 32 ++++++++++++++++++++++++++++++++
 drivers/net/wan/fsl_ucc_hdlc.h |  1 +
 include/soc/fsl/qe/qe.h        |  5 +++++
 3 files changed, 38 insertions(+)

diff --git a/drivers/net/wan/fsl_ucc_hdlc.c b/drivers/net/wan/fsl_ucc_hdlc.c
index 4c93d561b18a..e9b2d687f150 100644
--- a/drivers/net/wan/fsl_ucc_hdlc.c
+++ b/drivers/net/wan/fsl_ucc_hdlc.c
@@ -98,6 +98,13 @@ static int uhdlc_init(struct ucc_hdlc_private *priv)
 		uf_info->tsa = 1;
 		uf_info->ctsp = 1;
 	}
+
+	/* This sets HPM register in CMXUCR register which configures a
+	 * open drain connected HDLC bus
+	 */
+	if (priv->hdlc_bus)
+		uf_info->brkpt_support = 1;
+
 	uf_info->uccm_mask = ((UCC_HDLC_UCCE_RXB | UCC_HDLC_UCCE_RXF |
 				UCC_HDLC_UCCE_TXB) << 16);
 
@@ -135,6 +142,28 @@ static int uhdlc_init(struct ucc_hdlc_private *priv)
 	/* Set UPSMR normal mode (need fixed)*/
 	iowrite32be(0, &priv->uf_regs->upsmr);
 
+	/* hdlc_bus mode */
+	if (priv->hdlc_bus) {
+		u32 upsmr;
+
+		dev_info(priv->dev, "HDLC bus Mode\n");
+		upsmr = ioread32be(&priv->uf_regs->upsmr);
+
+		/* bus mode and retransmit enable, with collision window
+		 * set to 8 bytes
+		 */
+		upsmr |= UCC_HDLC_UPSMR_RTE | UCC_HDLC_UPSMR_BUS |
+				UCC_HDLC_UPSMR_CW8;
+		iowrite32be(upsmr, &priv->uf_regs->upsmr);
+
+		/* explicitly disable CDS & CTSP */
+		gumr = ioread32be(&priv->uf_regs->gumr);
+		gumr &= ~(UCC_FAST_GUMR_CDS | UCC_FAST_GUMR_CTSP);
+		/* set automatic sync to explicitly ignore CD signal */
+		gumr |= UCC_FAST_GUMR_SYNL_AUTO;
+		iowrite32be(gumr, &priv->uf_regs->gumr);
+	}
+
 	priv->rx_ring_size = RX_BD_RING_LEN;
 	priv->tx_ring_size = TX_BD_RING_LEN;
 	/* Alloc Rx BD */
@@ -1046,6 +1075,9 @@ static int ucc_hdlc_probe(struct platform_device *pdev)
 	if (of_get_property(np, "fsl,ucc-internal-loopback", NULL))
 		uhdlc_priv->loopback = 1;
 
+	if (of_get_property(np, "fsl,hdlc-bus", NULL))
+		uhdlc_priv->hdlc_bus = 1;
+
 	if (uhdlc_priv->tsa == 1) {
 		utdm = kzalloc(sizeof(*utdm), GFP_KERNEL);
 		if (!utdm) {
diff --git a/drivers/net/wan/fsl_ucc_hdlc.h b/drivers/net/wan/fsl_ucc_hdlc.h
index 881ecdeef076..c21134c1f180 100644
--- a/drivers/net/wan/fsl_ucc_hdlc.h
+++ b/drivers/net/wan/fsl_ucc_hdlc.h
@@ -78,6 +78,7 @@ struct ucc_hdlc_private {
 	u16 tsa;
 	bool hdlc_busy;
 	bool loopback;
+	bool hdlc_bus;
 
 	u8 *tx_buffer;
 	u8 *rx_buffer;
diff --git a/include/soc/fsl/qe/qe.h b/include/soc/fsl/qe/qe.h
index 226f915a68c2..b3d1aff5e8ad 100644
--- a/include/soc/fsl/qe/qe.h
+++ b/include/soc/fsl/qe/qe.h
@@ -789,6 +789,11 @@ struct ucc_slow_pram {
 #define UCC_GETH_UPSMR_SMM	0x00000080
 #define UCC_GETH_UPSMR_SGMM	0x00000020
 
+/* UCC Protocol Specific Mode Register (UPSMR), when used for HDLC */
+#define UCC_HDLC_UPSMR_RTE	0x02000000
+#define UCC_HDLC_UPSMR_BUS	0x00200000
+#define UCC_HDLC_UPSMR_CW8	0x00007000
+
 /* UCC Transmit On Demand Register (UTODR) */
 #define UCC_SLOW_TOD	0x8000
 #define UCC_FAST_TOD	0x8000
-- 
2.12.0.rc1
