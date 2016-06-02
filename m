From: Johannes Thumshirn <jthumshirn@suse.de>
Subject: [PATCH v2 6/6] alx: Use pci_(request|release)_mem_regions
Date: Thu,  2 Jun 2016 09:30:34 +0200
Message-ID: <d23546e4a87cfd23082fdfbe648bd5269ba89df7.1464795082.git.jthumshirn@suse.de>
References: <cover.1464795082.git.jthumshirn@suse.de>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org,
	Christoph Hellwig <hch@infradead.org>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
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
hand, use it in the ethernet drivers.

Suggested-by: Christoph Hellwig <hch@infradead.org>
Signed-off-by: Johannes Thumshirn <jthumshirn@suse.de>
Cc: Jay Cliburn <jcliburn@gmail.com>
Cc: Chris Snook <chris.snook@gmail.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: intel-wired-lan@lists.osuosl.org
---
 drivers/net/ethernet/atheros/alx/main.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index 55b118e..d2363de 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -1238,7 +1238,7 @@ static int alx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct alx_priv *alx;
 	struct alx_hw *hw;
 	bool phy_configured;
-	int bars, err;
+	int err;
 
 	err = pci_enable_device_mem(pdev);
 	if (err)
@@ -1258,11 +1258,10 @@ static int alx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		}
 	}
 
-	bars = pci_select_bars(pdev, IORESOURCE_MEM);
-	err = pci_request_selected_regions(pdev, bars, alx_drv_name);
+	err = pci_request_mem_regions(pdev, alx_drv_name);
 	if (err) {
 		dev_err(&pdev->dev,
-			"pci_request_selected_regions failed(bars:%d)\n", bars);
+			"pci_request_mem_regions failed\n");
 		goto out_pci_disable;
 	}
 
@@ -1388,7 +1387,7 @@ out_unmap:
 out_free_netdev:
 	free_netdev(netdev);
 out_pci_release:
-	pci_release_selected_regions(pdev, bars);
+	pci_release_mem_regions(pdev);
 out_pci_disable:
 	pci_disable_device(pdev);
 	return err;
@@ -1407,8 +1406,7 @@ static void alx_remove(struct pci_dev *pdev)
 
 	unregister_netdev(alx->dev);
 	iounmap(hw->hw_addr);
-	pci_release_selected_regions(pdev,
-				     pci_select_bars(pdev, IORESOURCE_MEM));
+	pci_release_mem_regions(pdev);
 
 	pci_disable_pcie_error_reporting(pdev);
 	pci_disable_device(pdev);
-- 
1.8.5.6
