From: Jan Kiszka <jan.kiszka@siemens.com>
Subject: [PATCH v3 6/6] stmmac: pci: Remove setup handler indirection via stmmac_pci_info
Date: Tue, 30 May 2017 09:33:25 +0200
Message-ID: <650c8ec1c8ed47dbc2645ae2ae89ae1683c4e6c7.1496129604.git.jan.kiszka@siemens.com>
References: <cover.1496129604.git.jan.kiszka@siemens.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Andy Shevchenko <andy.shevchenko@gmail.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from david.siemens.de ([192.35.17.14]:59169 "EHLO david.siemens.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750904AbdE3Hdd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 30 May 2017 03:33:33 -0400
In-Reply-To: <cover.1496129604.git.jan.kiszka@siemens.com>
In-Reply-To: <cover.1496129604.git.jan.kiszka@siemens.com>
References: <cover.1496129604.git.jan.kiszka@siemens.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By now, stmmac_pci_info only contains a single entry. Register this
directly with the PCI device table, removing one indirection.

Signed-off-by: Jan Kiszka <jan.kiszka@siemens.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 34 +++++++++---------------
 1 file changed, 12 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index a3909ab0da05..73b7b5d3a11c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -35,9 +35,7 @@ struct stmmac_pci_dmi_data {
 	int phy_addr;
 };
 
-struct stmmac_pci_info {
-	int (*setup)(struct pci_dev *pdev, struct plat_stmmacenet_data *plat);
-};
+typedef int (*stmmac_setup)(struct pci_dev *, struct plat_stmmacenet_data *);
 
 static int stmmac_pci_find_phy_addr(struct pci_dev *pdev,
 				    const struct dmi_system_id *dmi_list)
@@ -87,8 +85,8 @@ static void common_default_data(struct plat_stmmacenet_data *plat)
 	plat->rx_queues_cfg[0].pkt_route = 0x0;
 }
 
-static int stmmac_default_data(struct pci_dev *pdev,
-			       struct plat_stmmacenet_data *plat)
+static int stmmac_default_setup(struct pci_dev *pdev,
+				struct plat_stmmacenet_data *plat)
 {
 	/* Set common default data first */
 	common_default_data(plat);
@@ -104,10 +102,6 @@ static int stmmac_default_data(struct pci_dev *pdev,
 	return 0;
 }
 
-static const struct stmmac_pci_info stmmac_pci_info = {
-	.setup = stmmac_default_data,
-};
-
 static const struct stmmac_pci_dmi_data galileo_stmmac_dmi_data[] = {
 	{
 		.func = 6,
@@ -160,8 +154,8 @@ static const struct dmi_system_id quark_pci_dmi[] = {
 	{}
 };
 
-static int quark_default_data(struct pci_dev *pdev,
-			      struct plat_stmmacenet_data *plat)
+static int quark_default_setup(struct pci_dev *pdev,
+			       struct plat_stmmacenet_data *plat)
 {
 	int ret;
 
@@ -198,10 +192,6 @@ static int quark_default_data(struct pci_dev *pdev,
 	return 0;
 }
 
-static const struct stmmac_pci_info quark_pci_info = {
-	.setup = quark_default_data,
-};
-
 /**
  * stmmac_pci_probe
  *
@@ -217,7 +207,7 @@ static const struct stmmac_pci_info quark_pci_info = {
 static int stmmac_pci_probe(struct pci_dev *pdev,
 			    const struct pci_device_id *id)
 {
-	struct stmmac_pci_info *info = (struct stmmac_pci_info *)id->driver_data;
+	stmmac_setup setup = (stmmac_setup)id->driver_data;
 	struct plat_stmmacenet_data *plat;
 	struct stmmac_resources res;
 	int i;
@@ -258,7 +248,7 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
 
 	pci_set_master(pdev);
 
-	ret = info->setup(pdev, plat);
+	ret = setup(pdev, plat);
 	if (ret)
 		return ret;
 
@@ -292,15 +282,15 @@ static SIMPLE_DEV_PM_OPS(stmmac_pm_ops, stmmac_suspend, stmmac_resume);
 #define STMMAC_QUARK_ID  0x0937
 #define STMMAC_DEVICE_ID 0x1108
 
-#define STMMAC_DEVICE(vendor_id, dev_id, info)	{	\
+#define STMMAC_DEVICE(vendor_id, dev_id, setup)	{	\
 	PCI_VDEVICE(vendor_id, dev_id),			\
-	.driver_data = (kernel_ulong_t)&info		\
+	.driver_data = (kernel_ulong_t)&setup		\
 	}
 
 static const struct pci_device_id stmmac_id_table[] = {
-	STMMAC_DEVICE(STMMAC, STMMAC_DEVICE_ID, stmmac_pci_info),
-	STMMAC_DEVICE(STMICRO, PCI_DEVICE_ID_STMICRO_MAC, stmmac_pci_info),
-	STMMAC_DEVICE(INTEL, STMMAC_QUARK_ID, quark_pci_info),
+	STMMAC_DEVICE(STMMAC, STMMAC_DEVICE_ID, stmmac_default_setup),
+	STMMAC_DEVICE(STMICRO, PCI_DEVICE_ID_STMICRO_MAC, stmmac_default_setup),
+	STMMAC_DEVICE(INTEL, STMMAC_QUARK_ID, quark_default_setup),
 	{}
 };
 
-- 
2.12.3
