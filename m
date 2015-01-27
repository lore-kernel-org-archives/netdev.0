From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v3 2/3] stmmac: pci: introduce Intel Quark X1000 runtime detection
Date: Tue, 27 Jan 2015 21:44:48 +0200
Message-ID: <1422387889-21559-3-git-send-email-andriy.shevchenko@linux.intel.com>
References: <1422387889-21559-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	"Kweh, Hock Leong" <hock.leong.kweh@intel.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:16553 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753524AbbA0Tq6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2015 14:46:58 -0500
In-Reply-To: <1422387889-21559-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces run-time board detection through DMI and MAC-PHY
configuration function used by quark_default_data() during initialization. It
fills up the phy_addr for Galileo and Galileo Gen2 boards to indicate that the
Ethernet MAC controller is or is not connected to any PHY.

The implementation takes into consideration for future expansion in Quark
series boards that may have different PHY address that is linked to its MAC
controllers.

This piece of work is derived from Bryan O'Donoghue's initial work for Quark
X1000 enabling.

Signed-off-by: Kweh, Hock Leong <hock.leong.kweh@intel.com>
Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 62 +++++++++++++++++++++++-
 1 file changed, 61 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index a316187..50f3c50 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -24,14 +24,50 @@
 *******************************************************************************/
 
 #include <linux/pci.h>
+#include <linux/dmi.h>
+
 #include "stmmac.h"
 
+/*
+ * This struct is used to associate PCI Function of MAC controller on a board,
+ * discovered via DMI, with the address of PHY connected to the MAC. The
+ * negative value of the address means that MAC controller is not connected
+ * with PHY.
+ */
+struct stmmac_pci_dmi_data {
+	const char *name;
+	unsigned int func;
+	int phy_addr;
+};
+
 struct stmmac_pci_info {
 	struct pci_dev *pdev;
 	int (*setup)(struct plat_stmmacenet_data *plat,
 		     struct stmmac_pci_info *info);
+	struct stmmac_pci_dmi_data *dmi;
 };
 
+static int stmmac_pci_find_phy_addr(struct stmmac_pci_info *info)
+{
+	const char *name = dmi_get_system_info(DMI_BOARD_NAME);
+	unsigned int func = PCI_FUNC(info->pdev->devfn);
+	struct stmmac_pci_dmi_data *dmi;
+
+	/*
+	 * Galileo boards with old firmware don't support DMI. We always return
+	 * 1 here, so at least first found MAC controller would be probed.
+	 */
+	if (!name)
+		return 1;
+
+	for (dmi = info->dmi; dmi->name && *dmi->name; dmi++) {
+		if (!strcmp(dmi->name, name) && dmi->func == func)
+			return dmi->phy_addr;
+	}
+
+	return -ENODEV;
+}
+
 static void stmmac_default_data(struct plat_stmmacenet_data *plat)
 {
 	plat->bus_id = 1;
@@ -58,9 +94,18 @@ static int quark_default_data(struct plat_stmmacenet_data *plat,
 			      struct stmmac_pci_info *info)
 {
 	struct pci_dev *pdev = info->pdev;
+	int ret;
+
+	/*
+	 * Refuse to load the driver and register net device if MAC controller
+	 * does not connect to any PHY interface.
+	 */
+	ret = stmmac_pci_find_phy_addr(info);
+	if (ret < 0)
+		return ret;
 
 	plat->bus_id = PCI_DEVID(pdev->bus->number, pdev->devfn);
-	plat->phy_addr = 1;
+	plat->phy_addr = ret;
 	plat->interface = PHY_INTERFACE_MODE_RMII;
 	plat->clk_csr = 2;
 	plat->has_gmac = 1;
@@ -82,8 +127,23 @@ static int quark_default_data(struct plat_stmmacenet_data *plat,
 	return 0;
 }
 
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
+	{}
+};
+
 static struct stmmac_pci_info quark_pci_info = {
 	.setup = quark_default_data,
+	.dmi = quark_pci_dmi_data,
 };
 
 /**
-- 
2.1.4
