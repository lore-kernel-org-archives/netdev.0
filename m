From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 18/18] igb: update suspend resume
Date: Fri, 27 Jun 2008 11:02:11 -0700
Message-ID: <20080627180208.22428.8436.stgit@localhost.localdomain>
References: <20080627175921.22428.52767.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jeff@garzik.org, davem@davemloft.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080627175921.22428.52767.stgit@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Alexander Duyck <alexander.h.duyck@intel.com>

Updates the suspend and resume to better handle the possibility of MSIX
vector changes.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   46 ++++++++++++++++++++++++++++----------------
 1 files changed, 29 insertions(+), 17 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index c43f287..eb90bf8 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -272,6 +272,17 @@ static int igb_alloc_queues(struct igb_adapter *adapter)
 	return 0;
 }
 
+static void igb_free_queues(struct igb_adapter *adapter)
+{
+	int i;
+
+	for (i = 0; i < adapter->num_rx_queues; i++)
+		netif_napi_del(&adapter->rx_ring[i].napi);
+
+	kfree(adapter->tx_ring);
+	kfree(adapter->rx_ring);
+}
+
 #define IGB_N0_QUEUE -1
 static void igb_assign_vector(struct igb_adapter *adapter, int rx_queue,
 			      int tx_queue, int msix_vector)
@@ -1295,8 +1306,7 @@ err_eeprom:
 		iounmap(hw->flash_address);
 
 	igb_remove_device(hw);
-	kfree(adapter->tx_ring);
-	kfree(adapter->rx_ring);
+	igb_free_queues(adapter);
 err_sw_init:
 err_hw_init:
 	iounmap(hw->hw_addr);
@@ -1354,8 +1364,7 @@ static void __devexit igb_remove(struct pci_dev *pdev)
 	igb_remove_device(&adapter->hw);
 	igb_reset_interrupt_capability(adapter);
 
-	kfree(adapter->tx_ring);
-	kfree(adapter->rx_ring);
+	igb_free_queues(adapter);
 
 	iounmap(adapter->hw.hw_addr);
 	if (adapter->hw.flash_address)
@@ -4299,11 +4308,12 @@ static int igb_suspend(struct pci_dev *pdev, pm_message_t state)
 
 	netif_device_detach(netdev);
 
-	if (netif_running(netdev)) {
-		WARN_ON(test_bit(__IGB_RESETTING, &adapter->state));
-		igb_down(adapter);
-		igb_free_irq(adapter);
-	}
+	if (netif_running(netdev))
+		igb_close(netdev);
+
+	igb_reset_interrupt_capability(adapter);
+
+	igb_free_queues(adapter);
 
 #ifdef CONFIG_PM
 	retval = pci_save_state(pdev);
@@ -4386,10 +4396,11 @@ static int igb_resume(struct pci_dev *pdev)
 	pci_enable_wake(pdev, PCI_D3hot, 0);
 	pci_enable_wake(pdev, PCI_D3cold, 0);
 
-	if (netif_running(netdev)) {
-		err = igb_request_irq(adapter);
-		if (err)
-			return err;
+	igb_set_interrupt_capability(adapter);
+
+	if (igb_alloc_queues(adapter)) {
+		dev_err(&pdev->dev, "Unable to allocate memory for queues\n");
+		return -ENOMEM;
 	}
 
 	/* e1000_power_up_phy(adapter); */
@@ -4397,10 +4408,11 @@ static int igb_resume(struct pci_dev *pdev)
 	igb_reset(adapter);
 	wr32(E1000_WUS, ~0);
 
-	igb_init_manageability(adapter);
-
-	if (netif_running(netdev))
-		igb_up(adapter);
+	if (netif_running(netdev)) {
+		err = igb_open(netdev);
+		if (err)
+			return err;
+	}
 
 	netif_device_attach(netdev);
 


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
