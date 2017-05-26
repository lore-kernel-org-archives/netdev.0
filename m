From: Jan Kiszka <jan.kiszka@siemens.com>
Subject: [PATCH v2 5/6] stmmac: pci: Use dmi_system_id table for retrieving PHY addresses
Date: Fri, 26 May 2017 18:07:52 +0200
Message-ID: <6e12b2e63c7eaab6db937a99fedf79ec806d176f.1495814872.git.jan.kiszka@siemens.com>
References: <cover.1495814872.git.jan.kiszka@siemens.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Andy Shevchenko <andy.shevchenko@gmail.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1495814872.git.jan.kiszka@siemens.com>
In-Reply-To: <cover.1495814872.git.jan.kiszka@siemens.com>
References: <cover.1495814872.git.jan.kiszka@siemens.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Avoids reimplementation of DMI matching in stmmac_pci_find_phy_addr.

Signed-off-by: Jan Kiszka <jan.kiszka@siemens.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 77 ++++++++++++++----------
 1 file changed, 45 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 07af42531fd4..061cb28f642d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -31,9 +31,7 @@
  * with PHY.
  */
 struct stmmac_pci_dmi_data {
-	const char *name;
-	const char *asset_tag;
-	unsigned int func;
+	int func;
 	int phy_addr;
 };
 
@@ -42,24 +40,19 @@ struct stmmac_pci_info {
 };
 
 static int stmmac_pci_find_phy_addr(struct pci_dev *pdev,
-				    struct stmmac_pci_dmi_data *dmi_data)
+				    const struct dmi_system_id *dmi_list)
 {
-	const char *name = dmi_get_system_info(DMI_BOARD_NAME);
-	const char *asset_tag = dmi_get_system_info(DMI_BOARD_ASSET_TAG);
-	unsigned int func = PCI_FUNC(pdev->devfn);
-	struct stmmac_pci_dmi_data *dmi;
+	const struct stmmac_pci_dmi_data *dmi_data;
+	const struct dmi_system_id *dmi_id;
+	int func = PCI_FUNC(pdev->devfn);
 
-	if (!name)
+	dmi_id = dmi_first_match(dmi_list);
+	if (!dmi_id)
 		return -ENODEV;
 
-	for (dmi = dmi_data; dmi->name && *dmi->name; dmi++) {
-		if (!strcmp(dmi->name, name) && dmi->func == func) {
-			/* If asset tag is provided, match on it as well. */
-			if (dmi->asset_tag && strcmp(dmi->asset_tag, asset_tag))
-				continue;
-			return dmi->phy_addr;
-		}
-	}
+	for (dmi_data = dmi_id->driver_data; dmi_data->func >= 0; dmi_data++)
+		if (dmi_data->func == func)
+			return dmi_data->phy_addr;
 
 	return -ENODEV;
 }
@@ -115,34 +108,54 @@ static const struct stmmac_pci_info stmmac_pci_info = {
 	.setup = stmmac_default_data,
 };
 
-static struct stmmac_pci_dmi_data quark_pci_dmi_data[] = {
+static const struct stmmac_pci_dmi_data galileo_stmmac_dmi_data[] = {
 	{
-		.name = "Galileo",
 		.func = 6,
 		.phy_addr = 1,
 	},
+	{-1, -1},
+};
+
+static const struct stmmac_pci_dmi_data iot2040_stmmac_dmi_data[] = {
 	{
-		.name = "GalileoGen2",
 		.func = 6,
 		.phy_addr = 1,
 	},
 	{
-		.name = "SIMATIC IOT2000",
-		.asset_tag = "6ES7647-0AA00-0YA2",
-		.func = 6,
+		.func = 7,
 		.phy_addr = 1,
 	},
+	{-1, -1},
+};
+
+static const struct dmi_system_id quark_pci_dmi[] = {
 	{
-		.name = "SIMATIC IOT2000",
-		.asset_tag = "6ES7647-0AA00-1YA2",
-		.func = 6,
-		.phy_addr = 1,
+		.matches = {
+			DMI_EXACT_MATCH(DMI_BOARD_NAME, "Galileo"),
+		},
+		.driver_data = (void *)galileo_stmmac_dmi_data,
 	},
 	{
-		.name = "SIMATIC IOT2000",
-		.asset_tag = "6ES7647-0AA00-1YA2",
-		.func = 7,
-		.phy_addr = 1,
+		.matches = {
+			DMI_EXACT_MATCH(DMI_BOARD_NAME, "GalileoGen2"),
+		},
+		.driver_data = (void *)galileo_stmmac_dmi_data,
+	},
+	{
+		.matches = {
+			DMI_EXACT_MATCH(DMI_BOARD_NAME, "SIMATIC IOT2000"),
+			DMI_EXACT_MATCH(DMI_BOARD_ASSET_TAG,
+					"6ES7647-0AA00-0YA2"),
+		},
+		.driver_data = (void *)galileo_stmmac_dmi_data,
+	},
+	{
+		.matches = {
+			DMI_EXACT_MATCH(DMI_BOARD_NAME, "SIMATIC IOT2000"),
+			DMI_EXACT_MATCH(DMI_BOARD_ASSET_TAG,
+					"6ES7647-0AA00-1YA2"),
+		},
+		.driver_data = (void *)iot2040_stmmac_dmi_data,
 	},
 	{}
 };
@@ -159,7 +172,7 @@ static int quark_default_data(struct pci_dev *pdev,
 	 * Refuse to load the driver and register net device if MAC controller
 	 * does not connect to any PHY interface.
 	 */
-	ret = stmmac_pci_find_phy_addr(pdev, quark_pci_dmi_data);
+	ret = stmmac_pci_find_phy_addr(pdev, quark_pci_dmi);
 	if (ret < 0) {
 		/*
 		 * Galileo boards with old firmware don't support DMI. We always
-- 
2.12.0
