From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v6 04/12] drivers: net: xgene: Fix module unload crash - clkrst sequence
Date: Wed, 20 Jul 2016 23:59:22 -0700
Message-ID: <1469084370-16781-5-git-send-email-isubramanian@apm.com>
References: <1469084370-16781-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	linux@armlinux.org.uk, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34072 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbcGUG7J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 02:59:09 -0400
Received: by mail-pa0-f51.google.com with SMTP id fi15so26197337pac.1
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 23:59:09 -0700 (PDT)
In-Reply-To: <1469084370-16781-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes clock reset sequence.

- Added clock reset sequence for ACPI
- Added delay in clock reset sequence to make sure pulse is generated
- Added clk_unprepare_disable() in port shutdown to make sure
  clock increment/decrement counts are matching
- Removed MII_MGMT_CONFIG programming, since it is not required
- Fixed programming XGENET_CONFIG_REG to enable SGMII mode

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Tested-by: Fushen Chen <fchen@apm.com>
Tested-by: Toan Le <toanle@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c    | 34 +++++++++++------
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c | 45 ++++++++++++++++++++---
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h |  1 +
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c | 24 +++++++++++-
 4 files changed, 86 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index 4f98749..91a67a0 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -675,24 +675,33 @@ bool xgene_ring_mgr_init(struct xgene_enet_pdata *p)
 
 static int xgene_enet_reset(struct xgene_enet_pdata *pdata)
 {
-	u32 val;
+	struct device *dev = &pdata->pdev->dev;
 
 	if (!xgene_ring_mgr_init(pdata))
 		return -ENODEV;
 
-	if (!IS_ERR(pdata->clk)) {
+	if (dev->of_node) {
 		clk_prepare_enable(pdata->clk);
+		udelay(5);
 		clk_disable_unprepare(pdata->clk);
+		udelay(5);
 		clk_prepare_enable(pdata->clk);
-		xgene_enet_ecc_init(pdata);
+		udelay(5);
+	} else {
+#ifdef CONFIG_ACPI
+		if (acpi_has_method(ACPI_HANDLE(&pdata->pdev->dev), "_RST")) {
+			acpi_evaluate_object(ACPI_HANDLE(&pdata->pdev->dev),
+					     "_RST", NULL, NULL);
+		} else if (acpi_has_method(ACPI_HANDLE(&pdata->pdev->dev),
+					 "_INI")) {
+			acpi_evaluate_object(ACPI_HANDLE(&pdata->pdev->dev),
+					     "_INI", NULL, NULL);
+		}
+#endif
 	}
-	xgene_enet_config_ring_if_assoc(pdata);
 
-	/* Enable auto-incr for scanning */
-	xgene_enet_rd_mcx_mac(pdata, MII_MGMT_CONFIG_ADDR, &val);
-	val |= SCAN_AUTO_INCR;
-	MGMT_CLOCK_SEL_SET(&val, 1);
-	xgene_enet_wr_mcx_mac(pdata, MII_MGMT_CONFIG_ADDR, val);
+	xgene_enet_ecc_init(pdata);
+	xgene_enet_config_ring_if_assoc(pdata);
 
 	return 0;
 }
@@ -717,6 +726,7 @@ static void xgene_enet_clear(struct xgene_enet_pdata *pdata,
 
 static void xgene_gport_shutdown(struct xgene_enet_pdata *pdata)
 {
+	struct device *dev = &pdata->pdev->dev;
 	struct xgene_enet_desc_ring *ring;
 	u32 pb, val;
 	int i;
@@ -739,8 +749,10 @@ static void xgene_gport_shutdown(struct xgene_enet_pdata *pdata)
 	}
 	xgene_enet_wr_ring_if(pdata, ENET_CFGSSQMIWQRESET_ADDR, pb);
 
-	if (!IS_ERR(pdata->clk))
-		clk_disable_unprepare(pdata->clk);
+	if (dev->of_node) {
+		if (!IS_ERR(pdata->clk))
+			clk_disable_unprepare(pdata->clk);
+	}
 }
 
 static int xgene_enet_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
index f1477d2..03a70c5 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
@@ -28,6 +28,12 @@ static void xgene_enet_wr_csr(struct xgene_enet_pdata *p, u32 offset, u32 val)
 	iowrite32(val, p->eth_csr_addr + offset);
 }
 
+static void xgene_enet_wr_clkrst_csr(struct xgene_enet_pdata *p, u32 offset,
+				     u32 val)
+{
+	iowrite32(val, p->base_addr + offset);
+}
+
 static void xgene_enet_wr_ring_if(struct xgene_enet_pdata *p,
 				  u32 offset, u32 val)
 {
@@ -434,17 +440,38 @@ static void xgene_sgmac_tx_disable(struct xgene_enet_pdata *p)
 
 static int xgene_enet_reset(struct xgene_enet_pdata *p)
 {
+	struct device *dev = &p->pdev->dev;
+
 	if (!xgene_ring_mgr_init(p))
 		return -ENODEV;
 
-	if (!IS_ERR(p->clk)) {
-		clk_prepare_enable(p->clk);
-		clk_disable_unprepare(p->clk);
-		clk_prepare_enable(p->clk);
+	if (p->enet_id == XGENE_ENET2)
+		xgene_enet_wr_clkrst_csr(p, XGENET_CONFIG_REG_ADDR, SGMII_EN);
+
+	if (dev->of_node) {
+		if (!IS_ERR(p->clk)) {
+			clk_prepare_enable(p->clk);
+			udelay(5);
+			clk_disable_unprepare(p->clk);
+			udelay(5);
+			clk_prepare_enable(p->clk);
+			udelay(5);
+		}
+	} else {
+#ifdef CONFIG_ACPI
+		if (acpi_has_method(ACPI_HANDLE(&p->pdev->dev), "_RST"))
+			acpi_evaluate_object(ACPI_HANDLE(&p->pdev->dev),
+					     "_RST", NULL, NULL);
+		else if (acpi_has_method(ACPI_HANDLE(&p->pdev->dev), "_INI"))
+			acpi_evaluate_object(ACPI_HANDLE(&p->pdev->dev),
+					     "_INI", NULL, NULL);
+#endif
 	}
 
-	xgene_enet_ecc_init(p);
-	xgene_enet_config_ring_if_assoc(p);
+	if (!p->port_id) {
+		xgene_enet_ecc_init(p);
+		xgene_enet_config_ring_if_assoc(p);
+	}
 
 	return 0;
 }
@@ -492,6 +519,7 @@ static void xgene_enet_clear(struct xgene_enet_pdata *pdata,
 
 static void xgene_enet_shutdown(struct xgene_enet_pdata *p)
 {
+	struct device *dev = &p->pdev->dev;
 	struct xgene_enet_desc_ring *ring;
 	u32 pb, val;
 	int i;
@@ -513,6 +541,11 @@ static void xgene_enet_shutdown(struct xgene_enet_pdata *p)
 		pb |= BIT(val);
 	}
 	xgene_enet_wr_ring_if(p, ENET_CFGSSQMIWQRESET_ADDR, pb);
+
+	if (dev->of_node) {
+		if (!IS_ERR(p->clk))
+			clk_disable_unprepare(p->clk);
+	}
 }
 
 static void xgene_enet_link_state(struct work_struct *work)
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h
index 32f140a..3d0ba37 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h
@@ -35,6 +35,7 @@
 #define LINK_UP				BIT(15)
 #define MPA_IDLE_WITH_QMI_EMPTY		BIT(12)
 #define SG_RX_DV_GATE_REG_0_ADDR	0x05fc
+#define SGMII_EN			0x1
 
 enum xgene_phy_speed {
 	PHY_SPEED_10,
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
index d0b4419..9c6ad0d 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
@@ -258,13 +258,29 @@ static void xgene_xgmac_tx_disable(struct xgene_enet_pdata *pdata)
 
 static int xgene_enet_reset(struct xgene_enet_pdata *pdata)
 {
+	struct device *dev = &pdata->pdev->dev;
+
 	if (!xgene_ring_mgr_init(pdata))
 		return -ENODEV;
 
-	if (!IS_ERR(pdata->clk)) {
+	if (dev->of_node) {
 		clk_prepare_enable(pdata->clk);
+		udelay(5);
 		clk_disable_unprepare(pdata->clk);
+		udelay(5);
 		clk_prepare_enable(pdata->clk);
+		udelay(5);
+	} else {
+#ifdef CONFIG_ACPI
+		if (acpi_has_method(ACPI_HANDLE(&pdata->pdev->dev), "_RST")) {
+			acpi_evaluate_object(ACPI_HANDLE(&pdata->pdev->dev),
+					     "_RST", NULL, NULL);
+		} else if (acpi_has_method(ACPI_HANDLE(&pdata->pdev->dev),
+					   "_INI")) {
+			acpi_evaluate_object(ACPI_HANDLE(&pdata->pdev->dev),
+					     "_INI", NULL, NULL);
+		}
+#endif
 	}
 
 	xgene_enet_ecc_init(pdata);
@@ -292,6 +308,7 @@ static void xgene_enet_xgcle_bypass(struct xgene_enet_pdata *pdata,
 
 static void xgene_enet_shutdown(struct xgene_enet_pdata *pdata)
 {
+	struct device *dev = &pdata->pdev->dev;
 	struct xgene_enet_desc_ring *ring;
 	u32 pb, val;
 	int i;
@@ -313,6 +330,11 @@ static void xgene_enet_shutdown(struct xgene_enet_pdata *pdata)
 		pb |= BIT(val);
 	}
 	xgene_enet_wr_ring_if(pdata, ENET_CFGSSQMIWQRESET_ADDR, pb);
+
+	if (dev->of_node) {
+		if (!IS_ERR(pdata->clk))
+			clk_disable_unprepare(pdata->clk);
+	}
 }
 
 static void xgene_enet_clear(struct xgene_enet_pdata *pdata,
-- 
1.9.1
