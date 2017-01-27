From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH v2 net-next 1/2] ravb: Add tx and rx clock internal delays mode of APSR
Date: Fri, 27 Jan 2017 19:35:19 +0100
Message-ID: <1485542120-10205-2-git-send-email-horms+renesas@verge.net.au>
References: <1485542120-10205-1-git-send-email-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: David Miller <davem@davemloft.net>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:37532 "EHLO
        kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750991AbdA0Sfq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 13:35:46 -0500
In-Reply-To: <1485542120-10205-1-git-send-email-horms+renesas@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>

This patch enables tx and rx clock internal delay modes (TDM and RDM).

This is to address a failure in the case of 1Gbps communication using the
by salvator-x board with the KSZ9031RNX phy. This has been reported to
occur with both the r8a7795 (H3) and r8a7796 (M3-W) SoCs.

With this change APSR internal delay modes are enabled for
"rgmii-id", "rgmii-rxid" and "rgmii-txid" phy modes as follows:

phy mode   | ASPR delay mode
-----------+----------------
rgmii-id   | TDM and RDM
rgmii-rxid | RDM
rgmii-txid | TDM

Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

---
v2 [Simon Horman]
* As suggested by Sergei Shtylyov
  - Add a comment to indicate that APSR_DM appears to be undocumented.
  - Move chip_id check outside of ravb_set_delay_mode for consistency
  - Call ravb_modify() once in ravb_set_delay_mode()
* Enhance comment before calls to ravb_set_delay_mode()
* Remove unnecessary break from end of switch statement.

v1 [Simon Horman]
- Combined patches
- Reworded changelog

v0 [Kazuya Mizuguchi]
---
 drivers/net/ethernet/renesas/ravb.h      | 10 ++++++++++
 drivers/net/ethernet/renesas/ravb_main.c | 24 ++++++++++++++++++++++++
 2 files changed, 34 insertions(+)

diff --git a/drivers/net/ethernet/renesas/ravb.h b/drivers/net/ethernet/renesas/ravb.h
index f1109661a533..0525bd696d5d 100644
--- a/drivers/net/ethernet/renesas/ravb.h
+++ b/drivers/net/ethernet/renesas/ravb.h
@@ -76,6 +76,7 @@ enum ravb_reg {
 	CDAR20	= 0x0060,
 	CDAR21	= 0x0064,
 	ESR	= 0x0088,
+	APSR	= 0x008C,	/* R-Car Gen3 only */
 	RCR	= 0x0090,
 	RQC0	= 0x0094,
 	RQC1	= 0x0098,
@@ -248,6 +249,15 @@ enum ESR_BIT {
 	ESR_EIL		= 0x00001000,
 };
 
+/* APSR */
+enum APSR_BIT {
+	APSR_MEMS		= 0x00000002,
+	APSR_CMSW		= 0x00000010,
+	APSR_DM			= 0x00006000,	/* Undocumented? */
+	APSR_DM_RDM		= 0x00002000,
+	APSR_DM_TDM		= 0x00004000,
+};
+
 /* RCR */
 enum RCR_BIT {
 	RCR_EFFS	= 0x00000001,
diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index 89ac1e3f6175..f655c1c23765 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -1904,6 +1904,22 @@ static void ravb_set_config_mode(struct net_device *ndev)
 	}
 }
 
+static void ravb_set_delay_mode(struct net_device *ndev)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+	int set = 0;
+
+	if (priv->phy_interface == PHY_INTERFACE_MODE_RGMII_ID ||
+	    priv->phy_interface == PHY_INTERFACE_MODE_RGMII_RXID)
+		set |= APSR_DM_RDM;
+
+	if (priv->phy_interface == PHY_INTERFACE_MODE_RGMII_ID ||
+	    priv->phy_interface == PHY_INTERFACE_MODE_RGMII_TXID)
+		set |= APSR_DM_TDM;
+
+	ravb_modify(ndev, APSR, APSR_DM, set);
+}
+
 static int ravb_probe(struct platform_device *pdev)
 {
 	struct device_node *np = pdev->dev.of_node;
@@ -2016,6 +2032,10 @@ static int ravb_probe(struct platform_device *pdev)
 	/* Request GTI loading */
 	ravb_modify(ndev, GCCR, GCCR_LTI, GCCR_LTI);
 
+	if (priv->chip_id != RCAR_GEN2)
+		/* Set tx and rx clock internal delay modes */
+		ravb_set_delay_mode(ndev);
+
 	/* Allocate descriptor base address table */
 	priv->desc_bat_size = sizeof(struct ravb_desc) * DBAT_ENTRY_NUM;
 	priv->desc_bat = dma_alloc_coherent(ndev->dev.parent, priv->desc_bat_size,
@@ -2152,6 +2172,10 @@ static int __maybe_unused ravb_resume(struct device *dev)
 	/* Request GTI loading */
 	ravb_modify(ndev, GCCR, GCCR_LTI, GCCR_LTI);
 
+	if (priv->chip_id != RCAR_GEN2)
+		/* Set tx and rx clock internal delay modes */
+		ravb_set_delay_mode(ndev);
+
 	/* Restore descriptor base address table */
 	ravb_write(ndev, priv->desc_bat_dma, DBAT);
 
-- 
2.7.0.rc3.207.g0ac5344
