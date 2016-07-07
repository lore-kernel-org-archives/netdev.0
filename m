From: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Subject: [PATCH v4 04/11] drivers: net: xgene: Fix module unload crash - clkrst sequence
Date: Wed,  6 Jul 2016 17:35:05 -0700
Message-ID: <1467851712-24780-5-git-send-email-isubramanian@apm.com>
References: <1467851712-24780-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, patches-qTEPVZfXA3Y@public.gmane.org,
	matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org,
	Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1467851712-24780-1-git-send-email-isubramanian-qTEPVZfXA3Y@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch fixes clock reset sequence.

- Added clock reset sequence for ACPI
- Removed MII_MGMT_CONFIG programming, since it is not required
- Fixed programming XGENET_CONFIG_REG to enable SGMII mode

Signed-off-by: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Tested-by: Fushen Chen <fchen-qTEPVZfXA3Y@public.gmane.org>
Tested-by: Toan Le <toanle-qTEPVZfXA3Y@public.gmane.org>
Tested-by: Matthias Brugger <mbrugger-IBi9RG/b67k@public.gmane.org>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c    | 24 +++++++++------
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c | 36 +++++++++++++++++++----
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h |  1 +
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c | 15 +++++++++-
 4 files changed, 60 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index 4f98749..d394d1f 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -675,24 +675,30 @@ bool xgene_ring_mgr_init(struct xgene_enet_pdata *p)
 
 static int xgene_enet_reset(struct xgene_enet_pdata *pdata)
 {
-	u32 val;
+	struct device *dev = &pdata->pdev->dev;
 
 	if (!xgene_ring_mgr_init(pdata))
 		return -ENODEV;
 
-	if (!IS_ERR(pdata->clk)) {
+	if (dev->of_node) {
 		clk_prepare_enable(pdata->clk);
 		clk_disable_unprepare(pdata->clk);
 		clk_prepare_enable(pdata->clk);
-		xgene_enet_ecc_init(pdata);
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
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
index cf09e12..7d37a80 100644
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
@@ -432,17 +438,35 @@ static void xgene_sgmac_tx_disable(struct xgene_enet_pdata *p)
 
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
+			clk_disable_unprepare(p->clk);
+			clk_prepare_enable(p->clk);
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
index d0b4419..aecd264 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
@@ -258,13 +258,26 @@ static void xgene_xgmac_tx_disable(struct xgene_enet_pdata *pdata)
 
 static int xgene_enet_reset(struct xgene_enet_pdata *pdata)
 {
+	struct device *dev = &pdata->pdev->dev;
+
 	if (!xgene_ring_mgr_init(pdata))
 		return -ENODEV;
 
-	if (!IS_ERR(pdata->clk)) {
+	if (dev->of_node) {
 		clk_prepare_enable(pdata->clk);
 		clk_disable_unprepare(pdata->clk);
 		clk_prepare_enable(pdata->clk);
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
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
