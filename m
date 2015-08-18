From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/15] e100: Add a check after pci_pool_create to avoid null pointer dereference
Date: Tue, 18 Aug 2015 14:09:14 -0700
Message-ID: <1439932162-1995-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1439932162-1995-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jia-Ju Bai <baijiaju1990@163.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:9866 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752974AbbHRVJ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 17:09:29 -0400
In-Reply-To: <1439932162-1995-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jia-Ju Bai <baijiaju1990@163.com>

The driver lacks the check of nic->cbs_pool after pci_pool_create
in e100_probe. When this function is failed, a null pointer dereference
occurs when pci_pool_alloc uses nic->cbs_pool in e100_alloc_cbs.
This patch adds a check and related error handling code to fix it.

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e100.c | 7 +++++++
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
2.4.3
