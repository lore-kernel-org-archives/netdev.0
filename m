From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH net-next 17/35] ixgbevf: Use
	pci_enable_msix_range() instead of pci_enable_msix()
Date: Tue, 18 Feb 2014 11:11:46 +0100
Message-ID: <9ee830cfd4b417f230f77dd37256ca8e4396ecbe.1392717503.git.agordeev@redhat.com>
References: <cover.1392717502.git.agordeev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Alexander Gordeev <agordeev@redhat.com>, linux-pci@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1392717502.git.agordeev@redhat.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

As result of deprecation of MSI-X/MSI enablement functions
pci_enable_msix() and pci_enable_msi_block() all drivers
using these two interfaces need to be updated to use the
new pci_enable_msi_range() and pci_enable_msix_range()
interfaces.

Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>
Cc: e1000-devel@lists.sourceforge.net
Cc: netdev@vger.kernel.org
Cc: linux-pci@vger.kernel.org
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   32 +++++++-------------
 1 files changed, 11 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 9df2898..a6af7b7 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1817,7 +1817,6 @@ void ixgbevf_reset(struct ixgbevf_adapter *adapter)
 static int ixgbevf_acquire_msix_vectors(struct ixgbevf_adapter *adapter,
 					int vectors)
 {
-	int err = 0;
 	int vector_threshold;
 
 	/* We'll want at least 2 (vector_threshold):
@@ -1831,33 +1830,24 @@ static int ixgbevf_acquire_msix_vectors(struct ixgbevf_adapter *adapter,
 	 * Right now, we simply care about how many we'll get; we'll
 	 * set them up later while requesting irq's.
 	 */
-	while (vectors >= vector_threshold) {
-		err = pci_enable_msix(adapter->pdev, adapter->msix_entries,
-				      vectors);
-		if (!err || err < 0) /* Success or a nasty failure. */
-			break;
-		else /* err == number of vectors we should try again with */
-			vectors = err;
-	}
+	vectors = pci_enable_msix_range(adapter->pdev, adapter->msix_entries,
+					vector_threshold, vectors);
 
-	if (vectors < vector_threshold)
-		err = -ENOMEM;
-
-	if (err) {
+	if (vectors < 0) {
 		dev_err(&adapter->pdev->dev,
 			"Unable to allocate MSI-X interrupts\n");
 		kfree(adapter->msix_entries);
 		adapter->msix_entries = NULL;
-	} else {
-		/*
-		 * Adjust for only the vectors we'll use, which is minimum
-		 * of max_msix_q_vectors + NON_Q_VECTORS, or the number of
-		 * vectors we were allocated.
-		 */
-		adapter->num_msix_vectors = vectors;
+		return vectors;
 	}
 
-	return err;
+	/* Adjust for only the vectors we'll use, which is minimum
+	 * of max_msix_q_vectors + NON_Q_VECTORS, or the number of
+	 * vectors we were allocated.
+	 */
+	adapter->num_msix_vectors = vectors;
+
+	return 0;
 }
 
 /**
-- 
1.7.7.6


------------------------------------------------------------------------------
Managing the Performance of Cloud-Based Applications
Take advantage of what the Cloud has to offer - Avoid Common Pitfalls.
Read the Whitepaper.
http://pubads.g.doubleclick.net/gampad/clk?id=121054471&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
