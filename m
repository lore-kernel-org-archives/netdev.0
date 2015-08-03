From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH] e100: Add a check after pci_pool_create to avoid null pointer dereference
Date: Mon,  3 Aug 2015 10:17:08 +0800
Message-ID: <1438568228-13288-1-git-send-email-baijiaju1990@163.com>
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jia-Ju Bai <baijiaju1990@163.com>
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver lacks the check of nic->cbs_pool after pci_pool_create
in e100_probe. When this function is failed, a null pointer dereference 
occurs when pci_pool_alloc uses nic->cbs_pool in e100_alloc_cbs.
This patch adds a check and related error handling code to fix it.

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
---
 drivers/net/ethernet/intel/e100.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index d2657a4..767c161 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -2967,6 +2967,11 @@ static int e100_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			   nic->params.cbs.max * sizeof(struct cb),
 			   sizeof(u32),
 			   0);
+	if (!nic->cbs_pool) {
+		netif_err(nic, probe, nic->netdev, "Cannot create DMA pool, aborting\n");
+		err = -ENOMEM;
+		goto err_out_pool;
+	}
 	netif_info(nic, probe, nic->netdev,
 		   "addr 0x%llx, irq %d, MAC addr %pM\n",
 		   (unsigned long long)pci_resource_start(pdev, use_io ? 1 : 0),
@@ -2974,6 +2979,8 @@ static int e100_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	return 0;
 
+err_out_pool:
+	unregister_netdev(netdev);
 err_out_free:
 	e100_free(nic);
 err_out_iounmap:
-- 
1.7.9.5
