From: Benjamin Poirier <bpoirier@suse.de>
Subject: [PATCH 1/2] igb: fix rtnl race in PM resume path
Date: Thu,  5 Apr 2012 11:11:03 -0400
Message-ID: <1333638664-17062-1-git-send-email-bpoirier@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Emil Tantilov <emil.s.tantilov@intel.com>,
	e1000-devel@lists.sourceforge.net, Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, John Fastabend <john.r.fastabend@intel.com>,
	John Ronciak <john.ronciak@intel.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Since the caller (PM resume code) is not the one holding rtnl, when taking the
'else' branch rtnl may be released at any moment, thereby defeating the whole
purpose of this code block.

Signed-off-by: Benjamin Poirier <bpoirier@suse.de>
---
 drivers/net/ethernet/intel/igb/igb_main.c |   20 ++++++--------------
 1 files changed, 6 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index f022ff7..4854ab6 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1083,9 +1083,12 @@ msi_only:
 		adapter->flags |= IGB_FLAG_HAS_MSI;
 out:
 	/* Notify the stack of the (possibly) reduced queue counts. */
+	rtnl_lock();
 	netif_set_real_num_tx_queues(adapter->netdev, adapter->num_tx_queues);
-	return netif_set_real_num_rx_queues(adapter->netdev,
-					    adapter->num_rx_queues);
+	err = netif_set_real_num_rx_queues(adapter->netdev,
+		adapter->num_rx_queues);
+	rtnl_unlock();
+	return err;
 }
 
 /**
@@ -6646,18 +6649,7 @@ static int igb_resume(struct device *dev)
 	pci_enable_wake(pdev, PCI_D3hot, 0);
 	pci_enable_wake(pdev, PCI_D3cold, 0);
 
-	if (!rtnl_is_locked()) {
-		/*
-		 * shut up ASSERT_RTNL() warning in
-		 * netif_set_real_num_tx/rx_queues.
-		 */
-		rtnl_lock();
-		err = igb_init_interrupt_scheme(adapter);
-		rtnl_unlock();
-	} else {
-		err = igb_init_interrupt_scheme(adapter);
-	}
-	if (err) {
+	if (igb_init_interrupt_scheme(adapter)) {
 		dev_err(&pdev->dev, "Unable to allocate memory for queues\n");
 		return -ENOMEM;
 	}
-- 
1.7.7


------------------------------------------------------------------------------
Better than sec? Nothing is better than sec when it comes to
monitoring Big Data applications. Try Boundary one-second 
resolution app monitoring today. Free.
http://p.sf.net/sfu/Boundary-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
