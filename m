From: Jan Kiszka <jan.kiszka@siemens.com>
Subject: [PATCH v4 6/6] stmmac: pci: Remove setup handler indirection via stmmac_pci_info
Date: Fri,  2 Jun 2017 09:34:54 +0200
Message-ID: <1df4f24d4bb29a37a7b3b45a8ee359658c760878.1496388893.git.jan.kiszka@siemens.com>
References: <cover.1496388893.git.jan.kiszka@siemens.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Andy Shevchenko <andy.shevchenko@gmail.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from thoth.sbs.de ([192.35.17.2]:53079 "EHLO thoth.sbs.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750813AbdFBHfK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Jun 2017 03:35:10 -0400
In-Reply-To: <cover.1496388893.git.jan.kiszka@siemens.com>
In-Reply-To: <cover.1496388893.git.jan.kiszka@siemens.com>
References: <cover.1496388893.git.jan.kiszka@siemens.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By now, stmmac_pci_info only contains a single entry. Register this
directly with the PCI device table, removing one indirection.

Signed-off-by: Jan Kiszka <jan.kiszka@siemens.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 34 +++++++++---------------
 1 file changed, 12 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 2be15a8a9c40..393710815e4b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -40,9 +40,7 @@ struct stmmac_pci_dmi_data {
 	size_t nfuncs;
 };
 
-struct stmmac_pci_info {
-	int (*setup)(struct pci_dev *pdev, struct plat_stmmacenet_data *plat);
-};
+typedef int (*stmmac_setup)(struct pci_dev *, struct plat_stmmacenet_data *);
 
 static int stmmac_pci_find_phy_addr(struct pci_dev *pdev,
 				    const struct dmi_system_id *dmi_list)
@@ -97,8 +95,8 @@ static void common_default_data(struct plat_stmmacenet_data *plat)
 	plat->rx_queues_cfg[0].pkt_route = 0x0;
 }
 
-static int stmmac_default_data(struct pci_dev *pdev,
-			       struct plat_stmmacenet_data *plat)
+static int stmmac_default_setup(struct pci_dev *pdev,
+				struct plat_stmmacenet_data *plat)
 {
 	/* Set common default data first */
 	common_default_data(plat);
@@ -114,10 +112,6 @@ static int stmmac_default_data(struct pci_dev *pdev,
 	return 0;
 }
 
-static const struct stmmac_pci_info stmmac_pci_info = {
-	.setup = stmmac_default_data,
-};
-
 static const struct stmmac_pci_func_data galileo_stmmac_func_data[] = {
 	{
 		.func = 6,
@@ -180,8 +174,8 @@ static const struct dmi_system_id quark_pci_dmi[] = {
 	{}
 };
 
-static int quark_default_data(struct pci_dev *pdev,
-			      struct plat_stmmacenet_data *plat)
+static int quark_default_setup(struct pci_dev *pdev,
+			       struct plat_stmmacenet_data *plat)
 {
 	int ret;
 
@@ -218,10 +212,6 @@ static int quark_default_data(struct pci_dev *pdev,
 	return 0;
 }
 
-static const struct stmmac_pci_info quark_pci_info = {
-	.setup = quark_default_data,
-};
-
 /**
  * stmmac_pci_probe
  *
@@ -237,7 +227,7 @@ static const struct stmmac_pci_info quark_pci_info = {
 static int stmmac_pci_probe(struct pci_dev *pdev,
 			    const struct pci_device_id *id)
 {
-	struct stmmac_pci_info *info = (struct stmmac_pci_info *)id->driver_data;
+	stmmac_setup setup = (stmmac_setup)id->driver_data;
 	struct plat_stmmacenet_data *plat;
 	struct stmmac_resources res;
 	int i;
@@ -278,7 +268,7 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
 
 	pci_set_master(pdev);
 
-	ret = info->setup(pdev, plat);
+	ret = setup(pdev, plat);
 	if (ret)
 		return ret;
 
@@ -312,15 +302,15 @@ static SIMPLE_DEV_PM_OPS(stmmac_pm_ops, stmmac_suspend, stmmac_resume);
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
