From: Jan Kiszka <jan.kiszka@siemens.com>
Subject: [PATCH v3 3/6] stmmac: pci: Make stmmac_pci_find_phy_addr truly generic
Date: Tue, 30 May 2017 09:33:22 +0200
Message-ID: <e8ee3305feccdf303b9d1917b26ccf61f2b924a7.1496129604.git.jan.kiszka@siemens.com>
References: <cover.1496129604.git.jan.kiszka@siemens.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Andy Shevchenko <andy.shevchenko@gmail.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1496129604.git.jan.kiszka@siemens.com>
In-Reply-To: <cover.1496129604.git.jan.kiszka@siemens.com>
References: <cover.1496129604.git.jan.kiszka@siemens.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move the special case for the early Galileo firmware into
quark_default_setup. This allows to use stmmac_pci_find_phy_addr for
non-quark cases.

Signed-off-by: Jan Kiszka <jan.kiszka@siemens.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index d3d74e526e17..f44ae49eb11c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -51,12 +51,8 @@ static int stmmac_pci_find_phy_addr(struct pci_dev *pdev,
 	unsigned int func = PCI_FUNC(pdev->devfn);
 	struct stmmac_pci_dmi_data *dmi;
 
-	/*
-	 * Galileo boards with old firmware don't support DMI. We always return
-	 * 1 here, so at least first found MAC controller would be probed.
-	 */
 	if (!name)
-		return 1;
+		return -ENODEV;
 
 	for (dmi = info->dmi; dmi->name && *dmi->name; dmi++) {
 		if (!strcmp(dmi->name, name) && dmi->func == func) {
@@ -136,8 +132,18 @@ static int quark_default_data(struct pci_dev *pdev,
 	 * does not connect to any PHY interface.
 	 */
 	ret = stmmac_pci_find_phy_addr(pdev, info);
-	if (ret < 0)
-		return ret;
+	if (ret < 0) {
+		/* Return error to the caller on DMI enabled boards. */
+		if (dmi_get_system_info(DMI_BOARD_NAME))
+			return ret;
+
+		/*
+		 * Galileo boards with old firmware don't support DMI. We always
+		 * use 1 here as PHY address, so at least the first found MAC
+		 * controller would be probed.
+		 */
+		ret = 1;
+	}
 
 	plat->bus_id = PCI_DEVID(pdev->bus->number, pdev->devfn);
 	plat->phy_addr = ret;
-- 
2.12.3
