From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH net-next 1/2] i40evf: Use
	pci_enable_msix_range() instead of pci_enable_msix()
Date: Fri, 25 Apr 2014 10:06:24 +0200
Message-ID: <110dd7806f49f62272bd960ae8101c9da81a3f01.1398412015.git.agordeev@redhat.com>
References: <cover.1398412015.git.agordeev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux NICS <linux.nics@intel.com>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Alexander Gordeev <agordeev@redhat.com>, linux-pci@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1398412015.git.agordeev@redhat.com>
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
new pci_enable_msi_range()  or pci_enable_msi_exact()
and pci_enable_msix_range() or pci_enable_msix_exact()
interfaces.

Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Cc: Linux NICS <linux.nics@intel.com>
Cc: e1000-devel@lists.sourceforge.net
Cc: netdev@vger.kernel.org
Cc: linux-pci@vger.kernel.org
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c |   31 ++++++++--------------
 1 files changed, 11 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index da6054c..78f1859 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1027,30 +1027,21 @@ i40evf_acquire_msix_vectors(struct i40evf_adapter *adapter, int vectors)
 	 * Right now, we simply care about how many we'll get; we'll
 	 * set them up later while requesting irq's.
 	 */
-	while (vectors >= vector_threshold) {
-		err = pci_enable_msix(adapter->pdev, adapter->msix_entries,
-				      vectors);
-		if (!err) /* Success in acquiring all requested vectors. */
-			break;
-		else if (err < 0)
-			vectors = 0; /* Nasty failure, quit now */
-		else /* err == number of vectors we should try again with */
-			vectors = err;
-	}
-
-	if (vectors < vector_threshold) {
+	err = pci_enable_msix_range(adapter->pdev, adapter->msix_entries,
+				    vector_threshold, vectors);
+	if (err < 0) {
 		dev_err(&adapter->pdev->dev, "Unable to allocate MSI-X interrupts.\n");
 		kfree(adapter->msix_entries);
 		adapter->msix_entries = NULL;
-		err = -EIO;
-	} else {
-		/* Adjust for only the vectors we'll use, which is minimum
-		 * of max_msix_q_vectors + NONQ_VECS, or the number of
-		 * vectors we were allocated.
-		 */
-		adapter->num_msix_vectors = vectors;
+		return err;
 	}
-	return err;
+
+	/* Adjust for only the vectors we'll use, which is minimum
+	 * of max_msix_q_vectors + NONQ_VECS, or the number of
+	 * vectors we were allocated.
+	 */
+	adapter->num_msix_vectors = err;
+	return 0;
 }
 
 /**
-- 
1.7.7.6


------------------------------------------------------------------------------
Start Your Social Network Today - Download eXo Platform
Build your Enterprise Intranet with eXo Platform Software
Java Based Open Source Intranet - Social, Extensible, Cloud Ready
Get Started Now And Turn Your Intranet Into A Collaboration Platform
http://p.sf.net/sfu/ExoPlatform
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
