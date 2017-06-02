From: Jan Kiszka <jan.kiszka@siemens.com>
Subject: [PATCH v4 4/6] stmmac: pci: Select quark_pci_dmi_data from quark_default_data
Date: Fri,  2 Jun 2017 09:34:52 +0200
Message-ID: <0898128c699a3ea39aa498002b3a963e280c7c96.1496388893.git.jan.kiszka@siemens.com>
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

No need to carry this reference in stmmac_pci_info - the Quark-specific
setup handler knows that it needs to use the Quark-specific DMI table.
This also allows to drop the stmmac_pci_info reference from the setup
handler parameter list.

Signed-off-by: Jan Kiszka <jan.kiszka@siemens.com>
Reviewed-by: Andy Shevchenko <andy.shevchenko@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 83 +++++++++++-------------
 1 file changed, 39 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index f44ae49eb11c..a6e10d3ced5c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -38,13 +38,11 @@ struct stmmac_pci_dmi_data {
 };
 
 struct stmmac_pci_info {
-	int (*setup)(struct pci_dev *pdev, struct plat_stmmacenet_data *plat,
-		     const struct stmmac_pci_info *info);
-	struct stmmac_pci_dmi_data *dmi;
+	int (*setup)(struct pci_dev *pdev, struct plat_stmmacenet_data *plat);
 };
 
 static int stmmac_pci_find_phy_addr(struct pci_dev *pdev,
-				    const struct stmmac_pci_info *info)
+				    struct stmmac_pci_dmi_data *dmi_data)
 {
 	const char *name = dmi_get_system_info(DMI_BOARD_NAME);
 	const char *asset_tag = dmi_get_system_info(DMI_BOARD_ASSET_TAG);
@@ -54,7 +52,7 @@ static int stmmac_pci_find_phy_addr(struct pci_dev *pdev,
 	if (!name)
 		return -ENODEV;
 
-	for (dmi = info->dmi; dmi->name && *dmi->name; dmi++) {
+	for (dmi = dmi_data; dmi->name && *dmi->name; dmi++) {
 		if (!strcmp(dmi->name, name) && dmi->func == func) {
 			/* If asset tag is provided, match on it as well. */
 			if (dmi->asset_tag && strcmp(dmi->asset_tag, asset_tag))
@@ -97,8 +95,7 @@ static void common_default_data(struct plat_stmmacenet_data *plat)
 }
 
 static int stmmac_default_data(struct pci_dev *pdev,
-			       struct plat_stmmacenet_data *plat,
-			       const struct stmmac_pci_info *info)
+			       struct plat_stmmacenet_data *plat)
 {
 	/* Set common default data first */
 	common_default_data(plat);
@@ -118,9 +115,40 @@ static const struct stmmac_pci_info stmmac_pci_info = {
 	.setup = stmmac_default_data,
 };
 
+static struct stmmac_pci_dmi_data quark_pci_dmi_data[] = {
+	{
+		.name = "Galileo",
+		.func = 6,
+		.phy_addr = 1,
+	},
+	{
+		.name = "GalileoGen2",
+		.func = 6,
+		.phy_addr = 1,
+	},
+	{
+		.name = "SIMATIC IOT2000",
+		.asset_tag = "6ES7647-0AA00-0YA2",
+		.func = 6,
+		.phy_addr = 1,
+	},
+	{
+		.name = "SIMATIC IOT2000",
+		.asset_tag = "6ES7647-0AA00-1YA2",
+		.func = 6,
+		.phy_addr = 1,
+	},
+	{
+		.name = "SIMATIC IOT2000",
+		.asset_tag = "6ES7647-0AA00-1YA2",
+		.func = 7,
+		.phy_addr = 1,
+	},
+	{}
+};
+
 static int quark_default_data(struct pci_dev *pdev,
-			      struct plat_stmmacenet_data *plat,
-			      const struct stmmac_pci_info *info)
+			      struct plat_stmmacenet_data *plat)
 {
 	int ret;
 
@@ -131,7 +159,7 @@ static int quark_default_data(struct pci_dev *pdev,
 	 * Refuse to load the driver and register net device if MAC controller
 	 * does not connect to any PHY interface.
 	 */
-	ret = stmmac_pci_find_phy_addr(pdev, info);
+	ret = stmmac_pci_find_phy_addr(pdev, quark_pci_dmi_data);
 	if (ret < 0) {
 		/* Return error to the caller on DMI enabled boards. */
 		if (dmi_get_system_info(DMI_BOARD_NAME))
@@ -157,41 +185,8 @@ static int quark_default_data(struct pci_dev *pdev,
 	return 0;
 }
 
-static struct stmmac_pci_dmi_data quark_pci_dmi_data[] = {
-	{
-		.name = "Galileo",
-		.func = 6,
-		.phy_addr = 1,
-	},
-	{
-		.name = "GalileoGen2",
-		.func = 6,
-		.phy_addr = 1,
-	},
-	{
-		.name = "SIMATIC IOT2000",
-		.asset_tag = "6ES7647-0AA00-0YA2",
-		.func = 6,
-		.phy_addr = 1,
-	},
-	{
-		.name = "SIMATIC IOT2000",
-		.asset_tag = "6ES7647-0AA00-1YA2",
-		.func = 6,
-		.phy_addr = 1,
-	},
-	{
-		.name = "SIMATIC IOT2000",
-		.asset_tag = "6ES7647-0AA00-1YA2",
-		.func = 7,
-		.phy_addr = 1,
-	},
-	{}
-};
-
 static const struct stmmac_pci_info quark_pci_info = {
 	.setup = quark_default_data,
-	.dmi = quark_pci_dmi_data,
 };
 
 /**
@@ -250,7 +245,7 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
 
 	pci_set_master(pdev);
 
-	ret = info->setup(pdev, plat, info);
+	ret = info->setup(pdev, plat);
 	if (ret)
 		return ret;
 
-- 
2.12.3
