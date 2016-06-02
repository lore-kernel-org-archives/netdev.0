From: Johannes Thumshirn <jthumshirn@suse.de>
Subject: [PATCH v2 5/6] ethernet/intel: Use pci_(request|release)_mem_regions
Date: Thu,  2 Jun 2016 09:30:33 +0200
Message-ID: <e15aedde3b7d8b301b9ca6197f8d39d4076c9c86.1464795082.git.jthumshirn@suse.de>
References: <cover.1464795082.git.jthumshirn@suse.de>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org,
	Christoph Hellwig <hch@infradead.org>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org
To: Bjorn Helgaas <bhelgaas@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1464795082.git.jthumshirn@suse.de>
In-Reply-To: <cover.1464795082.git.jthumshirn@suse.de>
References: <cover.1464795082.git.jthumshirn@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that we do have pci_request_mem_regions() and pci_release_mem_regions() at
hand, use it in the Intel ethernet drivers.

Suggested-by: Christoph Hellwig <hch@infradead.org>
Signed-off-by: Johannes Thumshirn <jthumshirn@suse.de>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: intel-wired-lan@lists.osuosl.org
---
 drivers/net/ethernet/intel/e1000e/netdev.c    |  6 ++----
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c  | 11 +++--------
 drivers/net/ethernet/intel/i40e/i40e_main.c   |  9 +++------
 drivers/net/ethernet/intel/igb/igb_main.c     | 10 +++-------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  9 +++------
 5 files changed, 14 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 9b4ec13..ecd8d15 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -7284,8 +7284,7 @@ err_flashmap:
 err_ioremap:
 	free_netdev(netdev);
 err_alloc_etherdev:
-	pci_release_selected_regions(pdev,
-				     pci_select_bars(pdev, IORESOURCE_MEM));
+	pci_release_mem_regions(pdev);
 err_pci_reg:
 err_dma:
 	pci_disable_device(pdev);
@@ -7352,8 +7351,7 @@ static void e1000_remove(struct pci_dev *pdev)
 	if ((adapter->hw.flash_address) &&
 	    (adapter->hw.mac.type < e1000_pch_spt))
 		iounmap(adapter->hw.flash_address);
-	pci_release_selected_regions(pdev,
-				     pci_select_bars(pdev, IORESOURCE_MEM));
+	pci_release_mem_regions(pdev);
 
 	free_netdev(netdev);
 
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 4eb7a6f..ad28e87 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -1940,10 +1940,7 @@ static int fm10k_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_dma;
 	}
 
-	err = pci_request_selected_regions(pdev,
-					   pci_select_bars(pdev,
-							   IORESOURCE_MEM),
-					   fm10k_driver_name);
+	err = pci_request_mem_regions(pdev, fm10k_driver_name);
 	if (err) {
 		dev_err(&pdev->dev,
 			"pci_request_selected_regions failed: %d\n", err);
@@ -2034,8 +2031,7 @@ err_sw_init:
 err_ioremap:
 	free_netdev(netdev);
 err_alloc_netdev:
-	pci_release_selected_regions(pdev,
-				     pci_select_bars(pdev, IORESOURCE_MEM));
+	pci_release_mem_regions(pdev);
 err_pci_reg:
 err_dma:
 	pci_disable_device(pdev);
@@ -2086,8 +2082,7 @@ static void fm10k_remove(struct pci_dev *pdev)
 
 	free_netdev(netdev);
 
-	pci_release_selected_regions(pdev,
-				     pci_select_bars(pdev, IORESOURCE_MEM));
+	pci_release_mem_regions(pdev);
 
 	pci_disable_pcie_error_reporting(pdev);
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 3449129..37592b1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -10779,8 +10779,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 
 	/* set up pci connections */
-	err = pci_request_selected_regions(pdev, pci_select_bars(pdev,
-					   IORESOURCE_MEM), i40e_driver_name);
+	err = pci_request_mem_regions(pdev, i40e_driver_name);
 	if (err) {
 		dev_info(&pdev->dev,
 			 "pci_request_selected_regions failed %d\n", err);
@@ -11277,8 +11276,7 @@ err_ioremap:
 	kfree(pf);
 err_pf_alloc:
 	pci_disable_pcie_error_reporting(pdev);
-	pci_release_selected_regions(pdev,
-				     pci_select_bars(pdev, IORESOURCE_MEM));
+	pci_release_mem_regions(pdev);
 err_pci_reg:
 err_dma:
 	pci_disable_device(pdev);
@@ -11387,8 +11385,7 @@ static void i40e_remove(struct pci_dev *pdev)
 
 	iounmap(hw->hw_addr);
 	kfree(pf);
-	pci_release_selected_regions(pdev,
-				     pci_select_bars(pdev, IORESOURCE_MEM));
+	pci_release_mem_regions(pdev);
 
 	pci_disable_pcie_error_reporting(pdev);
 	pci_disable_device(pdev);
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 55a1405c..466087f 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2288,9 +2288,7 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		}
 	}
 
-	err = pci_request_selected_regions(pdev, pci_select_bars(pdev,
-					   IORESOURCE_MEM),
-					   igb_driver_name);
+	err = pci_request_mem_regions(pdev, igb_driver_name);
 	if (err)
 		goto err_pci_reg;
 
@@ -2707,8 +2705,7 @@ err_sw_init:
 err_ioremap:
 	free_netdev(netdev);
 err_alloc_etherdev:
-	pci_release_selected_regions(pdev,
-				     pci_select_bars(pdev, IORESOURCE_MEM));
+	pci_release_mem_regions(pdev);
 err_pci_reg:
 err_dma:
 	pci_disable_device(pdev);
@@ -2873,8 +2870,7 @@ static void igb_remove(struct pci_dev *pdev)
 	pci_iounmap(pdev, adapter->io_addr);
 	if (hw->flash_address)
 		iounmap(hw->flash_address);
-	pci_release_selected_regions(pdev,
-				     pci_select_bars(pdev, IORESOURCE_MEM));
+	pci_release_mem_regions(pdev);
 
 	kfree(adapter->shadow_vfta);
 	free_netdev(netdev);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 7df3fe2..1357dd2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -9084,8 +9084,7 @@ static int ixgbe_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		pci_using_dac = 0;
 	}
 
-	err = pci_request_selected_regions(pdev, pci_select_bars(pdev,
-					   IORESOURCE_MEM), ixgbe_driver_name);
+	err = pci_request_mem_regions(pdev, ixgbe_driver_name);
 	if (err) {
 		dev_err(&pdev->dev,
 			"pci_request_selected_regions failed 0x%x\n", err);
@@ -9460,8 +9459,7 @@ err_ioremap:
 	disable_dev = !test_and_set_bit(__IXGBE_DISABLED, &adapter->state);
 	free_netdev(netdev);
 err_alloc_etherdev:
-	pci_release_selected_regions(pdev,
-				     pci_select_bars(pdev, IORESOURCE_MEM));
+	pci_release_mem_regions(pdev);
 err_pci_reg:
 err_dma:
 	if (!adapter || disable_dev)
@@ -9527,8 +9525,7 @@ static void ixgbe_remove(struct pci_dev *pdev)
 
 #endif
 	iounmap(adapter->io_addr);
-	pci_release_selected_regions(pdev, pci_select_bars(pdev,
-				     IORESOURCE_MEM));
+	pci_release_mem_regions(pdev);
 
 	e_dev_info("complete\n");
 
-- 
1.8.5.6
