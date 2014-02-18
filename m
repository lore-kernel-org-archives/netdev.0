From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH net-next 09/35] cxgb4vf: Use pci_enable_msix_range() instead of pci_enable_msix()
Date: Tue, 18 Feb 2014 11:08:01 +0100
Message-ID: <fe62af829f2021225aaaf8ef2bf43e1bfa143585.1392717503.git.agordeev@redhat.com>
References: <cover.1392717502.git.agordeev@redhat.com>
Cc: Alexander Gordeev <agordeev@redhat.com>,
	Casey Leedom <leedom@chelsio.com>, netdev@vger.kernel.org,
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
Cc: Casey Leedom <leedom@chelsio.com>
Cc: netdev@vger.kernel.org
Cc: linux-pci@vger.kernel.org
---
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |   34 +++++++++----------
 1 files changed, 16 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 509fed9..1d0fe9b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -2444,7 +2444,7 @@ static void reduce_ethqs(struct adapter *adapter, int n)
  */
 static int enable_msix(struct adapter *adapter)
 {
-	int i, err, want, need;
+	int i, want, need, nqsets;
 	struct msix_entry entries[MSIX_ENTRIES];
 	struct sge *s = &adapter->sge;
 
@@ -2460,25 +2460,23 @@ static int enable_msix(struct adapter *adapter)
 	 */
 	want = s->max_ethqsets + MSIX_EXTRAS;
 	need = adapter->params.nports + MSIX_EXTRAS;
-	while ((err = pci_enable_msix(adapter->pdev, entries, want)) >= need)
-		want = err;
 
-	if (err == 0) {
-		int nqsets = want - MSIX_EXTRAS;
-		if (nqsets < s->max_ethqsets) {
-			dev_warn(adapter->pdev_dev, "only enough MSI-X vectors"
-				 " for %d Queue Sets\n", nqsets);
-			s->max_ethqsets = nqsets;
-			if (nqsets < s->ethqsets)
-				reduce_ethqs(adapter, nqsets);
-		}
-		for (i = 0; i < want; ++i)
-			adapter->msix_info[i].vec = entries[i].vector;
-	} else if (err > 0) {
-		dev_info(adapter->pdev_dev, "only %d MSI-X vectors left,"
-			 " not using MSI-X\n", err);
+	want = pci_enable_msix_range(adapter->pdev, entries, need, want);
+	if (want < 0)
+		return want;
+
+	nqsets = want - MSIX_EXTRAS;
+	if (nqsets < s->max_ethqsets) {
+		dev_warn(adapter->pdev_dev, "only enough MSI-X vectors"
+			 " for %d Queue Sets\n", nqsets);
+		s->max_ethqsets = nqsets;
+		if (nqsets < s->ethqsets)
+			reduce_ethqs(adapter, nqsets);
 	}
-	return err;
+	for (i = 0; i < want; ++i)
+		adapter->msix_info[i].vec = entries[i].vector;
+
+	return 0;
 }
 
 static const struct net_device_ops cxgb4vf_netdev_ops	= {
-- 
1.7.7.6
