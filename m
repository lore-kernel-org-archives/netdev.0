From: Jan Kiszka <jan.kiszka@siemens.com>
Subject: [PATCH v4 1/6] stmmac: pci: Make stmmac_pci_info structure constant
Date: Fri,  2 Jun 2017 09:34:49 +0200
Message-ID: <da0a934fbdf68d2cfdd92d0e8d0a7e55266e42b0.1496388893.git.jan.kiszka@siemens.com>
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

By removing the PCI device reference from the structure and passing it
as parameters to the interested functions, we can make quark_pci_info
const.

Signed-off-by: Jan Kiszka <jan.kiszka@siemens.com>
Reviewed-by: Andy Shevchenko <andy.shevchenko@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 23 +++++++++++------------
 1 file changed, 11 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 22f910795be4..0efe42659a37 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -38,17 +38,17 @@ struct stmmac_pci_dmi_data {
 };
 
 struct stmmac_pci_info {
-	struct pci_dev *pdev;
-	int (*setup)(struct plat_stmmacenet_data *plat,
-		     struct stmmac_pci_info *info);
+	int (*setup)(struct pci_dev *pdev, struct plat_stmmacenet_data *plat,
+		     const struct stmmac_pci_info *info);
 	struct stmmac_pci_dmi_data *dmi;
 };
 
-static int stmmac_pci_find_phy_addr(struct stmmac_pci_info *info)
+static int stmmac_pci_find_phy_addr(struct pci_dev *pdev,
+				    const struct stmmac_pci_info *info)
 {
 	const char *name = dmi_get_system_info(DMI_BOARD_NAME);
 	const char *asset_tag = dmi_get_system_info(DMI_BOARD_ASSET_TAG);
-	unsigned int func = PCI_FUNC(info->pdev->devfn);
+	unsigned int func = PCI_FUNC(pdev->devfn);
 	struct stmmac_pci_dmi_data *dmi;
 
 	/*
@@ -114,10 +114,10 @@ static void stmmac_default_data(struct plat_stmmacenet_data *plat)
 	/* TODO: AXI */
 }
 
-static int quark_default_data(struct plat_stmmacenet_data *plat,
-			      struct stmmac_pci_info *info)
+static int quark_default_data(struct pci_dev *pdev,
+			      struct plat_stmmacenet_data *plat,
+			      const struct stmmac_pci_info *info)
 {
-	struct pci_dev *pdev = info->pdev;
 	int ret;
 
 	/* Set common default data first */
@@ -127,7 +127,7 @@ static int quark_default_data(struct plat_stmmacenet_data *plat,
 	 * Refuse to load the driver and register net device if MAC controller
 	 * does not connect to any PHY interface.
 	 */
-	ret = stmmac_pci_find_phy_addr(info);
+	ret = stmmac_pci_find_phy_addr(pdev, info);
 	if (ret < 0)
 		return ret;
 
@@ -175,7 +175,7 @@ static struct stmmac_pci_dmi_data quark_pci_dmi_data[] = {
 	{}
 };
 
-static struct stmmac_pci_info quark_pci_info = {
+static const struct stmmac_pci_info quark_pci_info = {
 	.setup = quark_default_data,
 	.dmi = quark_pci_dmi_data,
 };
@@ -237,9 +237,8 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
 	pci_set_master(pdev);
 
 	if (info) {
-		info->pdev = pdev;
 		if (info->setup) {
-			ret = info->setup(plat, info);
+			ret = info->setup(pdev, plat, info);
 			if (ret)
 				return ret;
 		}
-- 
2.12.3
