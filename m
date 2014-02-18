From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH net-next 35/35] wil6210: Use pci_enable_msi_range() instead of pci_enable_msi_block()
Date: Tue, 18 Feb 2014 11:12:04 +0100
Message-ID: <2dd74b72b819405a2810664c4fd47f541047b856.1392717503.git.agordeev@redhat.com>
References: <cover.1392717502.git.agordeev@redhat.com>
Cc: Alexander Gordeev <agordeev@redhat.com>,
	Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	wil6210@qca.qualcomm.com, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <cover.1392717502.git.agordeev@redhat.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As result of deprecation of MSI-X/MSI enablement functions
pci_enable_msix() and pci_enable_msi_block() all drivers
using these two interfaces need to be updated to use the
new pci_enable_msi_range() and pci_enable_msix_range()
interfaces.

Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
Cc: Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>
Cc: "John W. Linville" <linville@tuxdriver.com>
Cc: wil6210@qca.qualcomm.com
Cc: netdev@vger.kernel.org
Cc: linux-pci@vger.kernel.org
Acked-by: Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>
---
 drivers/net/wireless/ath/wil6210/pcie_bus.c |   32 ++++++++++++--------------
 1 files changed, 15 insertions(+), 17 deletions(-)

diff --git a/drivers/net/wireless/ath/wil6210/pcie_bus.c b/drivers/net/wireless/ath/wil6210/pcie_bus.c
index eeceab3..e1c8cc4 100644
--- a/drivers/net/wireless/ath/wil6210/pcie_bus.c
+++ b/drivers/net/wireless/ath/wil6210/pcie_bus.c
@@ -41,30 +41,28 @@ static int wil_if_pcie_enable(struct wil6210_priv *wil)
 	switch (use_msi) {
 	case 3:
 	case 1:
+		wil_dbg_misc(wil, "Setup %d MSI interrupts\n", use_msi);
+		break;
 	case 0:
+		wil_dbg_misc(wil, "MSI interrupts disabled, use INTx\n");
 		break;
 	default:
-		wil_err(wil, "Invalid use_msi=%d, default to 1\n",
-			use_msi);
+		wil_err(wil, "Invalid use_msi=%d, default to 1\n", use_msi);
 		use_msi = 1;
 	}
-	wil->n_msi = use_msi;
-	if (wil->n_msi) {
-		wil_dbg_misc(wil, "Setup %d MSI interrupts\n", use_msi);
-		rc = pci_enable_msi_block(pdev, wil->n_msi);
-		if (rc && (wil->n_msi == 3)) {
-			wil_err(wil, "3 MSI mode failed, try 1 MSI\n");
-			wil->n_msi = 1;
-			rc = pci_enable_msi_block(pdev, wil->n_msi);
-		}
-		if (rc) {
-			wil_err(wil, "pci_enable_msi failed, use INTx\n");
-			wil->n_msi = 0;
-		}
-	} else {
-		wil_dbg_misc(wil, "MSI interrupts disabled, use INTx\n");
+
+	if (use_msi == 3 && pci_enable_msi_range(pdev, 3, 3) < 0) {
+		wil_err(wil, "3 MSI mode failed, try 1 MSI\n");
+		use_msi = 1;
+	}
+
+	if (use_msi == 1 && pci_enable_msi(pdev)) {
+		wil_err(wil, "pci_enable_msi failed, use INTx\n");
+		use_msi = 0;
 	}
 
+	wil->n_msi = use_msi;
+
 	rc = wil6210_init_irq(wil, pdev->irq);
 	if (rc)
 		goto stop_master;
-- 
1.7.7.6
