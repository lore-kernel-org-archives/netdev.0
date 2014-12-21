From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH v2] e1000: Add netif_napi_del in the normal path and error path to match netif_napi_add
Date: Sun, 21 Dec 2014 23:15:12 +0800
Message-ID: <1419174912-21900-1-git-send-email-baijiaju1990@163.com>
Cc: todd.fujinaka@intel.com, linux.nics@intel.com,
	Jia-Ju Bai <baijiaju1990@163.com>
To: sergei.shtylyov@cogentembedded.com, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-17.163.com ([220.181.12.17]:47508 "EHLO m12-17.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751090AbaLUPPk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Dec 2014 10:15:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver lacks netif_napi_del in the normal path and error path to match the call of netif_napi_add in e1000_probe.
This patch fixes this problem, and it has been tested in runtime.

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 24f3986..f6def7b 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -1004,7 +1004,7 @@ static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* make ready for any if (hw->...) below */
 	err = e1000_init_hw_struct(adapter, hw);
 	if (err)
-		goto err_sw_init;
+		goto err_dma;
 
 	/* there is a workaround being applied below that limits
 	 * 64-bit DMA addresses to 64-bit hardware.  There are some
@@ -1239,8 +1239,9 @@ err_eeprom:
 		iounmap(hw->flash_address);
 	kfree(adapter->tx_ring);
 	kfree(adapter->rx_ring);
-err_dma:
 err_sw_init:
+	netif_napi_del(&adapter->napi);
+err_dma:
 err_mdio_ioremap:
 	iounmap(hw->ce4100_gbe_mdio_base_virt);
 	iounmap(hw->hw_addr);
@@ -1271,6 +1272,7 @@ static void e1000_remove(struct pci_dev *pdev)
 	e1000_down_and_stop(adapter);
 	e1000_release_manageability(adapter);
 
+	netif_napi_del(&adapter->napi);
 	unregister_netdev(netdev);
 
 	e1000_phy_hw_reset(hw);
-- 
1.7.9.5
