From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH net-next 13/35] i40e: Use
	pci_enable_msix_range() instead of pci_enable_msix()
Date: Tue, 18 Feb 2014 11:11:42 +0100
Message-ID: <3655fd750c2f1c00c2474900539a305d50fdeb6f.1392717503.git.agordeev@redhat.com>
References: <cover.1392717502.git.agordeev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
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
Cc: e1000-devel@lists.sourceforge.net
Cc: netdev@vger.kernel.org
Cc: linux-pci@vger.kernel.org
---
 drivers/net/ethernet/intel/i40e/i40e_main.c |   33 +++++----------------------
 1 files changed, 6 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 628e917..3116861 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5856,37 +5856,16 @@ err_out:
  **/
 static int i40e_reserve_msix_vectors(struct i40e_pf *pf, int vectors)
 {
-	int err = 0;
-
-	pf->num_msix_entries = 0;
-	while (vectors >= I40E_MIN_MSIX) {
-		err = pci_enable_msix(pf->pdev, pf->msix_entries, vectors);
-		if (err == 0) {
-			/* good to go */
-			pf->num_msix_entries = vectors;
-			break;
-		} else if (err < 0) {
-			/* total failure */
-			dev_info(&pf->pdev->dev,
-				 "MSI-X vector reservation failed: %d\n", err);
-			vectors = 0;
-			break;
-		} else {
-			/* err > 0 is the hint for retry */
-			dev_info(&pf->pdev->dev,
-				 "MSI-X vectors wanted %d, retrying with %d\n",
-				 vectors, err);
-			vectors = err;
-		}
-	}
-
-	if (vectors > 0 && vectors < I40E_MIN_MSIX) {
+	vectors = pci_enable_msix_range(pf->pdev, pf->msix_entries,
+					I40E_MIN_MSIX, vectors);
+	if (vectors < 0) {
 		dev_info(&pf->pdev->dev,
-			 "Couldn't get enough vectors, only %d available\n",
-			 vectors);
+			 "MSI-X vector reservation failed: %d\n", vectors);
 		vectors = 0;
 	}
 
+	pf->num_msix_entries = vectors;
+
 	return vectors;
 }
 
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
