From: Jan Kiszka <jan.kiszka@siemens.com>
Subject: [PATCH 1/3] stmmac: pci: Overcome stmmac_pci_info structure
Date: Mon, 22 May 2017 13:12:07 +0200
Message-ID: <5d7b7aa99a04e86196ff7eea11f0ede7a95deac1.1495451529.git.jan.kiszka@siemens.com>
References: <cover.1495451529.git.jan.kiszka@siemens.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Andy Shevchenko <andy.shevchenko@gmail.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1495451529.git.jan.kiszka@siemens.com>
In-Reply-To: <cover.1495451529.git.jan.kiszka@siemens.com>
References: <cover.1495451529.git.jan.kiszka@siemens.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

First, pass the PCI device reference as function parameter. Then the
setup function knows which stmmac_pci_dmi_data structure to use.
Finally, we are left with a setup function in stmmac_pci_info and can
convert the structure into a function pointer. By converting
stmmac_default_data to that type, we can make a setup function
mandatory, and probing becomes more regular.

Signed-off-by: Jan Kiszka <jan.kiszka@siemens.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 122 +++++++++++------------
 1 file changed, 59 insertions(+), 63 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 22f910795be4..990a61acd70e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -37,18 +37,46 @@ struct stmmac_pci_dmi_data {
 	int phy_addr;
 };
 
-struct stmmac_pci_info {
-	struct pci_dev *pdev;
-	int (*setup)(struct plat_stmmacenet_data *plat,
-		     struct stmmac_pci_info *info);
-	struct stmmac_pci_dmi_data *dmi;
+typedef int (*stmmac_setup)(struct pci_dev *, struct plat_stmmacenet_data *);
+
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
 };
 
-static int stmmac_pci_find_phy_addr(struct stmmac_pci_info *info)
+static int stmmac_pci_find_phy_addr(struct pci_dev *pdev,
+				    struct stmmac_pci_dmi_data *dmi_data)
 {
 	const char *name = dmi_get_system_info(DMI_BOARD_NAME);
 	const char *asset_tag = dmi_get_system_info(DMI_BOARD_ASSET_TAG);
-	unsigned int func = PCI_FUNC(info->pdev->devfn);
+	unsigned int func = PCI_FUNC(pdev->devfn);
 	struct stmmac_pci_dmi_data *dmi;
 
 	/*
@@ -58,7 +86,7 @@ static int stmmac_pci_find_phy_addr(struct stmmac_pci_info *info)
 	if (!name)
 		return 1;
 
-	for (dmi = info->dmi; dmi->name && *dmi->name; dmi++) {
+	for (dmi = dmi_data; dmi->name && *dmi->name; dmi++) {
 		if (!strcmp(dmi->name, name) && dmi->func == func) {
 			/* If asset tag is provided, match on it as well. */
 			if (dmi->asset_tag && strcmp(dmi->asset_tag, asset_tag))
@@ -100,7 +128,8 @@ static void common_default_data(struct plat_stmmacenet_data *plat)
 	plat->rx_queues_cfg[0].pkt_route = 0x0;
 }
 
-static void stmmac_default_data(struct plat_stmmacenet_data *plat)
+static int stmmac_default_setup(struct pci_dev *pdev,
+				struct plat_stmmacenet_data *plat)
 {
 	/* Set common default data first */
 	common_default_data(plat);
@@ -112,12 +141,13 @@ static void stmmac_default_data(struct plat_stmmacenet_data *plat)
 	plat->dma_cfg->pbl = 32;
 	plat->dma_cfg->pblx8 = true;
 	/* TODO: AXI */
+
+	return 0;
 }
 
-static int quark_default_data(struct plat_stmmacenet_data *plat,
-			      struct stmmac_pci_info *info)
+static int quark_default_setup(struct pci_dev *pdev,
+			       struct plat_stmmacenet_data *plat)
 {
-	struct pci_dev *pdev = info->pdev;
 	int ret;
 
 	/* Set common default data first */
@@ -127,7 +157,7 @@ static int quark_default_data(struct plat_stmmacenet_data *plat,
 	 * Refuse to load the driver and register net device if MAC controller
 	 * does not connect to any PHY interface.
 	 */
-	ret = stmmac_pci_find_phy_addr(info);
+	ret = stmmac_pci_find_phy_addr(pdev, quark_pci_dmi_data);
 	if (ret < 0)
 		return ret;
 
@@ -143,43 +173,6 @@ static int quark_default_data(struct plat_stmmacenet_data *plat,
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
-static struct stmmac_pci_info quark_pci_info = {
-	.setup = quark_default_data,
-	.dmi = quark_pci_dmi_data,
-};
-
 /**
  * stmmac_pci_probe
  *
@@ -195,7 +188,7 @@ static struct stmmac_pci_info quark_pci_info = {
 static int stmmac_pci_probe(struct pci_dev *pdev,
 			    const struct pci_device_id *id)
 {
-	struct stmmac_pci_info *info = (struct stmmac_pci_info *)id->driver_data;
+	stmmac_setup setup = (stmmac_setup)id->driver_data;
 	struct plat_stmmacenet_data *plat;
 	struct stmmac_resources res;
 	int i;
@@ -236,15 +229,9 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
 
 	pci_set_master(pdev);
 
-	if (info) {
-		info->pdev = pdev;
-		if (info->setup) {
-			ret = info->setup(plat, info);
-			if (ret)
-				return ret;
-		}
-	} else
-		stmmac_default_data(plat);
+	ret = setup(pdev, plat);
+	if (ret)
+		return ret;
 
 	pci_enable_msi(pdev);
 
@@ -275,9 +262,18 @@ static SIMPLE_DEV_PM_OPS(stmmac_pm_ops, stmmac_suspend, stmmac_resume);
 #define STMMAC_DEVICE_ID 0x1108
 
 static const struct pci_device_id stmmac_id_table[] = {
-	{PCI_DEVICE(STMMAC_VENDOR_ID, STMMAC_DEVICE_ID)},
-	{PCI_DEVICE(PCI_VENDOR_ID_STMICRO, PCI_DEVICE_ID_STMICRO_MAC)},
-	{PCI_VDEVICE(INTEL, STMMAC_QUARK_ID), (kernel_ulong_t)&quark_pci_info},
+	{
+		PCI_DEVICE(STMMAC_VENDOR_ID, STMMAC_DEVICE_ID),
+		(kernel_ulong_t)&stmmac_default_setup,
+	},
+	{
+		PCI_DEVICE(PCI_VENDOR_ID_STMICRO, PCI_DEVICE_ID_STMICRO_MAC),
+		(kernel_ulong_t)&stmmac_default_setup,
+	},
+	{
+		PCI_VDEVICE(INTEL, STMMAC_QUARK_ID),
+		(kernel_ulong_t)&quark_default_setup,
+	},
 	{}
 };
 
-- 
2.12.0
