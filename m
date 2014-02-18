From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH net-next 06/35] cxgb3: Use pci_enable_msix_range() instead of pci_enable_msix()
Date: Tue, 18 Feb 2014 11:07:58 +0100
Message-ID: <985df9ebc23ee76c17abfba4e26f91ff03d2d857.1392717503.git.agordeev@redhat.com>
References: <cover.1392717502.git.agordeev@redhat.com>
Cc: Alexander Gordeev <agordeev@redhat.com>,
	Santosh Raspatur <santosh@chelsio.com>, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1392717502.git.agordeev@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As result of deprecation of MSI-X/MSI enablement functions
pci_enable_msix() and pci_enable_msi_block() all drivers
using these two interfaces need to be updated to use the
new pci_enable_msi_range() and pci_enable_msix_range()
interfaces.

Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
Cc: Santosh Raspatur <santosh@chelsio.com>
Cc: netdev@vger.kernel.org
Cc: linux-pci@vger.kernel.org
---
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c |   23 +++++++++--------------
 1 files changed, 9 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
index b72d2ed..07bbb71 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
@@ -3088,27 +3088,22 @@ static int cxgb_enable_msix(struct adapter *adap)
 {
 	struct msix_entry entries[SGE_QSETS + 1];
 	int vectors;
-	int i, err;
+	int i;
 
 	vectors = ARRAY_SIZE(entries);
 	for (i = 0; i < vectors; ++i)
 		entries[i].entry = i;
 
-	while ((err = pci_enable_msix(adap->pdev, entries, vectors)) > 0)
-		vectors = err;
-
-	if (!err && vectors < (adap->params.nports + 1)) {
-		pci_disable_msix(adap->pdev);
-		err = -1;
-	}
+	vectors = pci_enable_msix_range(adap->pdev, entries,
+					adap->params.nports + 1, vectors);
+	if (vectors < 0)
+		return vectors;
 
-	if (!err) {
-		for (i = 0; i < vectors; ++i)
-			adap->msix_info[i].vec = entries[i].vector;
-		adap->msix_nvectors = vectors;
-	}
+	for (i = 0; i < vectors; ++i)
+		adap->msix_info[i].vec = entries[i].vector;
+	adap->msix_nvectors = vectors;
 
-	return err;
+	return 0;
 }
 
 static void print_port_info(struct adapter *adap, const struct adapter_info *ai)
-- 
1.7.7.6
