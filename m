From: Jan Kiszka <jan.kiszka@siemens.com>
Subject: [PATCH v4 5/6] stmmac: pci: Use dmi_system_id table for retrieving PHY addresses
Date: Fri,  2 Jun 2017 09:34:53 +0200
Message-ID: <33942c3893beaca0f82528386fa3b239a6a02f02.1496388893.git.jan.kiszka@siemens.com>
References: <cover.1496388893.git.jan.kiszka@siemens.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Andy Shevchenko <andy.shevchenko@gmail.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1496388893.git.jan.kiszka@siemens.com>
In-Reply-To: <cover.1496388893.git.jan.kiszka@siemens.com>
References: <cover.1496388893.git.jan.kiszka@siemens.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Avoids reimplementation of DMI matching in stmmac_pci_find_phy_addr.

Signed-off-by: Jan Kiszka <jan.kiszka@siemens.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 99 ++++++++++++++++--------
 1 file changed, 66 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index a6e10d3ced5c..2be15a8a9c40 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -30,36 +30,39 @@
  * negative value of the address means that MAC controller is not connected
  * with PHY.
  */
-struct stmmac_pci_dmi_data {
-	const char *name;
-	const char *asset_tag;
+struct stmmac_pci_func_data {
 	unsigned int func;
 	int phy_addr;
 };
 
+struct stmmac_pci_dmi_data {
+	const struct stmmac_pci_func_data *func;
+	size_t nfuncs;
+};
+
 struct stmmac_pci_info {
 	int (*setup)(struct pci_dev *pdev, struct plat_stmmacenet_data *plat);
 };
 
 static int stmmac_pci_find_phy_addr(struct pci_dev *pdev,
-				    struct stmmac_pci_dmi_data *dmi_data)
+				    const struct dmi_system_id *dmi_list)
 {
-	const char *name = dmi_get_system_info(DMI_BOARD_NAME);
-	const char *asset_tag = dmi_get_system_info(DMI_BOARD_ASSET_TAG);
-	unsigned int func = PCI_FUNC(pdev->devfn);
-	struct stmmac_pci_dmi_data *dmi;
-
-	if (!name)
+	const struct stmmac_pci_func_data *func_data;
+	const struct stmmac_pci_dmi_data *dmi_data;
+	const struct dmi_system_id *dmi_id;
+	int func = PCI_FUNC(pdev->devfn);
+	size_t n;
+
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
+	dmi_data = dmi_id->driver_data;
+	func_data = dmi_data->func;
+
+	for (n = 0; n < dmi_data->nfuncs; n++, func_data++)
+		if (func_data->func == func)
+			return func_data->phy_addr;
 
 	return -ENODEV;
 }
@@ -115,34 +118,64 @@ static const struct stmmac_pci_info stmmac_pci_info = {
 	.setup = stmmac_default_data,
 };
 
-static struct stmmac_pci_dmi_data quark_pci_dmi_data[] = {
+static const struct stmmac_pci_func_data galileo_stmmac_func_data[] = {
 	{
-		.name = "Galileo",
 		.func = 6,
 		.phy_addr = 1,
 	},
+	{ },
+};
+
+static const struct stmmac_pci_dmi_data galileo_stmmac_dmi_data = {
+	.func = galileo_stmmac_func_data,
+	.nfuncs = ARRAY_SIZE(galileo_stmmac_func_data),
+};
+
+static const struct stmmac_pci_func_data iot2040_stmmac_func_data[] = {
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
+	{ },
+};
+
+static const struct stmmac_pci_dmi_data iot2040_stmmac_dmi_data = {
+	.func = iot2040_stmmac_func_data,
+	.nfuncs = ARRAY_SIZE(iot2040_stmmac_func_data),
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
+		.driver_data = (void *)&galileo_stmmac_dmi_data,
 	},
 	{
-		.name = "SIMATIC IOT2000",
-		.asset_tag = "6ES7647-0AA00-1YA2",
-		.func = 7,
-		.phy_addr = 1,
+		.matches = {
+			DMI_EXACT_MATCH(DMI_BOARD_NAME, "GalileoGen2"),
+		},
+		.driver_data = (void *)&galileo_stmmac_dmi_data,
+	},
+	{
+		.matches = {
+			DMI_EXACT_MATCH(DMI_BOARD_NAME, "SIMATIC IOT2000"),
+			DMI_EXACT_MATCH(DMI_BOARD_ASSET_TAG,
+					"6ES7647-0AA00-0YA2"),
+		},
+		.driver_data = (void *)&galileo_stmmac_dmi_data,
+	},
+	{
+		.matches = {
+			DMI_EXACT_MATCH(DMI_BOARD_NAME, "SIMATIC IOT2000"),
+			DMI_EXACT_MATCH(DMI_BOARD_ASSET_TAG,
+					"6ES7647-0AA00-1YA2"),
+		},
+		.driver_data = (void *)&iot2040_stmmac_dmi_data,
 	},
 	{}
 };
@@ -159,7 +192,7 @@ static int quark_default_data(struct pci_dev *pdev,
 	 * Refuse to load the driver and register net device if MAC controller
 	 * does not connect to any PHY interface.
 	 */
-	ret = stmmac_pci_find_phy_addr(pdev, quark_pci_dmi_data);
+	ret = stmmac_pci_find_phy_addr(pdev, quark_pci_dmi);
 	if (ret < 0) {
 		/* Return error to the caller on DMI enabled boards. */
 		if (dmi_get_system_info(DMI_BOARD_NAME))
-- 
2.12.3
