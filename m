From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH 07/34] cxgb4: Use pci_enable_msix_range()
Date: Fri, 31 Jan 2014 16:08:26 +0100
Message-ID: <f84d46c7894241fc9d164cde3474cb55c710835c.1391172839.git.agordeev@redhat.com>
References: <cover.1391172839.git.agordeev@redhat.com>
Cc: Alexander Gordeev <agordeev@redhat.com>,
	Dimitris Michailidis <dm@chelsio.com>, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1391172839.git.agordeev@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As result of deprecation of MSI-X/MSI enablement functions
pci_enable_msix() and pci_enable_msi_block() all drivers
using these two interfaces need to be updated to use the
new pci_enable_msi_range() and pci_enable_msix_range()
interfaces.

Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   50 +++++++++++------------
 1 files changed, 24 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 43ab35f..bd0321d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -5737,7 +5737,7 @@ static void reduce_ethqs(struct adapter *adap, int n)
 static int enable_msix(struct adapter *adap)
 {
 	int ofld_need = 0;
-	int i, err, want, need;
+	int i, want, need;
 	struct sge *s = &adap->sge;
 	unsigned int nchan = adap->params.nports;
 	struct msix_entry entries[MAX_INGQ + 1];
@@ -5753,32 +5753,30 @@ static int enable_msix(struct adapter *adap)
 	}
 	need = adap->params.nports + EXTRA_VECS + ofld_need;
 
-	while ((err = pci_enable_msix(adap->pdev, entries, want)) >= need)
-		want = err;
+	want = pci_enable_msix_range(adap->pdev, entries, need, want);
+	if (want < 0)
+		return want;
 
-	if (!err) {
-		/*
-		 * Distribute available vectors to the various queue groups.
-		 * Every group gets its minimum requirement and NIC gets top
-		 * priority for leftovers.
-		 */
-		i = want - EXTRA_VECS - ofld_need;
-		if (i < s->max_ethqsets) {
-			s->max_ethqsets = i;
-			if (i < s->ethqsets)
-				reduce_ethqs(adap, i);
-		}
-		if (is_offload(adap)) {
-			i = want - EXTRA_VECS - s->max_ethqsets;
-			i -= ofld_need - nchan;
-			s->ofldqsets = (i / nchan) * nchan;  /* round down */
-		}
-		for (i = 0; i < want; ++i)
-			adap->msix_info[i].vec = entries[i].vector;
-	} else if (err > 0)
-		dev_info(adap->pdev_dev,
-			 "only %d MSI-X vectors left, not using MSI-X\n", err);
-	return err;
+	/*
+	 * Distribute available vectors to the various queue groups.
+	 * Every group gets its minimum requirement and NIC gets top
+	 * priority for leftovers.
+	 */
+	i = want - EXTRA_VECS - ofld_need;
+	if (i < s->max_ethqsets) {
+		s->max_ethqsets = i;
+		if (i < s->ethqsets)
+			reduce_ethqs(adap, i);
+	}
+	if (is_offload(adap)) {
+		i = want - EXTRA_VECS - s->max_ethqsets;
+		i -= ofld_need - nchan;
+		s->ofldqsets = (i / nchan) * nchan;  /* round down */
+	}
+	for (i = 0; i < want; ++i)
+		adap->msix_info[i].vec = entries[i].vector;
+
+	return 0;
 }
 
 #undef EXTRA_VECS
-- 
1.7.7.6
