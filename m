From: David Daney <ddaney.cavm@gmail.com>
Subject: [PATCH 1/2] net: thunder: Factor out DT specific code in BGX
Date: Thu,  6 Aug 2015 17:33:09 -0700
Message-ID: <1438907590-29649-2-git-send-email-ddaney.cavm@gmail.com>
References: <1438907590-29649-1-git-send-email-ddaney.cavm@gmail.com>
Cc: linux-mips@linux-mips.org, Robert Richter <rrichter@cavium.com>,
	Tomasz Nowicki <tomasz.nowicki@linaro.org>,
	Sunil Goutham <sgoutham@cavium.com>,
	linux-arm-kernel@lists.infradead.org, linux-acpi@vger.kernel.org,
	David Daney <david.daney@cavium.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1438907590-29649-1-git-send-email-ddaney.cavm@gmail.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robert Richter <rrichter@cavium.com>

Separate DT code in preparation for follow-on ACPI integration.

Based on code from: Tomasz Nowicki <tomasz.nowicki@linaro.org>

Signed-off-by: Robert Richter <rrichter@cavium.com>
Signed-off-by: David Daney <david.daney@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c | 48 +++++++++++++++++------
 1 file changed, 35 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
index b961a89..615b2af 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
@@ -835,18 +835,28 @@ static void bgx_get_qlm_mode(struct bgx *bgx)
 	}
 }
 
-static void bgx_init_of(struct bgx *bgx, struct device_node *np)
+#if IS_ENABLED(CONFIG_OF_MDIO)
+
+static int bgx_init_of_phy(struct bgx *bgx)
 {
+	struct device_node *np;
 	struct device_node *np_child;
 	u8 lmac = 0;
+	char bgx_sel[5];
+	const char *mac;
 
-	for_each_child_of_node(np, np_child) {
-		struct device_node *phy_np;
-		const char *mac;
+	/* Get BGX node from DT */
+	snprintf(bgx_sel, 5, "bgx%d", bgx->bgx_id);
+	np = of_find_node_by_name(NULL, bgx_sel);
+	if (!np)
+		return -ENODEV;
 
-		phy_np = of_parse_phandle(np_child, "phy-handle", 0);
-		if (phy_np)
-			bgx->lmac[lmac].phydev = of_phy_find_device(phy_np);
+	for_each_child_of_node(np, np_child) {
+		struct device_node *phy_np = of_parse_phandle(np_child,
+							      "phy-handle", 0);
+		if (!phy_np)
+			continue;
+		bgx->lmac[lmac].phydev = of_phy_find_device(phy_np);
 
 		mac = of_get_mac_address(np_child);
 		if (mac)
@@ -858,6 +868,21 @@ static void bgx_init_of(struct bgx *bgx, struct device_node *np)
 		if (lmac == MAX_LMAC_PER_BGX)
 			break;
 	}
+	return 0;
+}
+
+#else
+
+static int bgx_init_of_phy(struct bgx *bgx)
+{
+	return -ENODEV;
+}
+
+#endif /* CONFIG_OF_MDIO */
+
+static int bgx_init_phy(struct bgx *bgx)
+{
+	return bgx_init_of_phy(bgx);
 }
 
 static int bgx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
@@ -865,8 +890,6 @@ static int bgx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	int err;
 	struct device *dev = &pdev->dev;
 	struct bgx *bgx = NULL;
-	struct device_node *np;
-	char bgx_sel[5];
 	u8 lmac;
 
 	bgx = devm_kzalloc(dev, sizeof(*bgx), GFP_KERNEL);
@@ -902,10 +925,9 @@ static int bgx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	bgx_vnic[bgx->bgx_id] = bgx;
 	bgx_get_qlm_mode(bgx);
 
-	snprintf(bgx_sel, 5, "bgx%d", bgx->bgx_id);
-	np = of_find_node_by_name(NULL, bgx_sel);
-	if (np)
-		bgx_init_of(bgx, np);
+	err = bgx_init_phy(bgx);
+	if (err)
+		goto err_enable;
 
 	bgx_init_hw(bgx);
 
-- 
1.9.1

