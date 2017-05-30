From: Jan Kiszka <jan.kiszka@siemens.com>
Subject: [PATCH v3 2/6] stmmac: pci: Use stmmac_pci_info for all devices
Date: Tue, 30 May 2017 09:33:21 +0200
Message-ID: <91c1dbfa58e70c21508762573b5219940f12815b.1496129604.git.jan.kiszka@siemens.com>
References: <cover.1496129604.git.jan.kiszka@siemens.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Andy Shevchenko <andy.shevchenko@gmail.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from goliath.siemens.de ([192.35.17.28]:43371 "EHLO
        goliath.siemens.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750720AbdE3Hdc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 03:33:32 -0400
In-Reply-To: <cover.1496129604.git.jan.kiszka@siemens.com>
In-Reply-To: <cover.1496129604.git.jan.kiszka@siemens.com>
References: <cover.1496129604.git.jan.kiszka@siemens.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make stmmac_default_data compatible with stmmac_pci_info.setup and use
an info structure for all devices. This allows to make the probing more
regular.

Signed-off-by: Jan Kiszka <jan.kiszka@siemens.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 36 +++++++++++++++---------
 1 file changed, 23 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 0efe42659a37..d3d74e526e17 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -100,7 +100,9 @@ static void common_default_data(struct plat_stmmacenet_data *plat)
 	plat->rx_queues_cfg[0].pkt_route = 0x0;
 }
 
-static void stmmac_default_data(struct plat_stmmacenet_data *plat)
+static int stmmac_default_data(struct pci_dev *pdev,
+			       struct plat_stmmacenet_data *plat,
+			       const struct stmmac_pci_info *info)
 {
 	/* Set common default data first */
 	common_default_data(plat);
@@ -112,8 +114,14 @@ static void stmmac_default_data(struct plat_stmmacenet_data *plat)
 	plat->dma_cfg->pbl = 32;
 	plat->dma_cfg->pblx8 = true;
 	/* TODO: AXI */
+
+	return 0;
 }
 
+static const struct stmmac_pci_info stmmac_pci_info = {
+	.setup = stmmac_default_data,
+};
+
 static int quark_default_data(struct pci_dev *pdev,
 			      struct plat_stmmacenet_data *plat,
 			      const struct stmmac_pci_info *info)
@@ -236,14 +244,9 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
 
 	pci_set_master(pdev);
 
-	if (info) {
-		if (info->setup) {
-			ret = info->setup(pdev, plat, info);
-			if (ret)
-				return ret;
-		}
-	} else
-		stmmac_default_data(plat);
+	ret = info->setup(pdev, plat, info);
+	if (ret)
+		return ret;
 
 	pci_enable_msi(pdev);
 
@@ -269,14 +272,21 @@ static void stmmac_pci_remove(struct pci_dev *pdev)
 
 static SIMPLE_DEV_PM_OPS(stmmac_pm_ops, stmmac_suspend, stmmac_resume);
 
-#define STMMAC_VENDOR_ID 0x700
+/* synthetic ID, no official vendor */
+#define PCI_VENDOR_ID_STMMAC 0x700
+
 #define STMMAC_QUARK_ID  0x0937
 #define STMMAC_DEVICE_ID 0x1108
 
+#define STMMAC_DEVICE(vendor_id, dev_id, info)	{	\
+	PCI_VDEVICE(vendor_id, dev_id),			\
+	.driver_data = (kernel_ulong_t)&info		\
+	}
+
 static const struct pci_device_id stmmac_id_table[] = {
-	{PCI_DEVICE(STMMAC_VENDOR_ID, STMMAC_DEVICE_ID)},
-	{PCI_DEVICE(PCI_VENDOR_ID_STMICRO, PCI_DEVICE_ID_STMICRO_MAC)},
-	{PCI_VDEVICE(INTEL, STMMAC_QUARK_ID), (kernel_ulong_t)&quark_pci_info},
+	STMMAC_DEVICE(STMMAC, STMMAC_DEVICE_ID, stmmac_pci_info),
+	STMMAC_DEVICE(STMICRO, PCI_DEVICE_ID_STMICRO_MAC, stmmac_pci_info),
+	STMMAC_DEVICE(INTEL, STMMAC_QUARK_ID, quark_pci_info),
 	{}
 };
 
-- 
2.12.3
