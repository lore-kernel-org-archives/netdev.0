From: Jan Kiszka <jan.kiszka@siemens.com>
Subject: [PATCH 2/3] stmmac: pci: Make stmmac_pci_find_phy_addr truly generic
Date: Mon, 22 May 2017 13:12:08 +0200
Message-ID: <4ae403afc25d23fc5a2366106ba5a47747f75c05.1495451529.git.jan.kiszka@siemens.com>
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

Move the special case for the early Galileo firmware into
quark_default_setup. This allows to use stmmac_pci_find_phy_addr for
non-quark cases.

Signed-off-by: Jan Kiszka <jan.kiszka@siemens.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 990a61acd70e..ffa59b76e884 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -79,12 +79,8 @@ static int stmmac_pci_find_phy_addr(struct pci_dev *pdev,
 	unsigned int func = PCI_FUNC(pdev->devfn);
 	struct stmmac_pci_dmi_data *dmi;
 
-	/*
-	 * Galileo boards with old firmware don't support DMI. We always return
-	 * 1 here, so at least first found MAC controller would be probed.
-	 */
 	if (!name)
-		return 1;
+		return -ENODEV;
 
 	for (dmi = dmi_data; dmi->name && *dmi->name; dmi++) {
 		if (!strcmp(dmi->name, name) && dmi->func == func) {
@@ -158,8 +154,17 @@ static int quark_default_setup(struct pci_dev *pdev,
 	 * does not connect to any PHY interface.
 	 */
 	ret = stmmac_pci_find_phy_addr(pdev, quark_pci_dmi_data);
-	if (ret < 0)
-		return ret;
+	if (ret < 0) {
+		/*
+		 * Galileo boards with old firmware don't support DMI. We always
+		 * use 1 here as PHY address, so at least the first found MAC
+		 * controller would be probed.
+		 */
+		if (!dmi_get_system_info(DMI_BOARD_NAME))
+			ret = 1;
+		else
+			return ret;
+	}
 
 	plat->bus_id = PCI_DEVID(pdev->bus->number, pdev->devfn);
 	plat->phy_addr = ret;
-- 
2.12.0
