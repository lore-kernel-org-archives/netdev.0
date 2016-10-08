From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] vmxnet3: avoid assumption about invalid dma_pa in vmxnet3_set_mc()
Date: Fri,  7 Oct 2016 22:53:43 -0400
Message-ID: <1475895223-3225-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
        "VMware, Inc." <pv-drivers@vmware.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Shrikrishna Khare <skhare@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ispras.ru ([83.149.199.45]:60110 "EHLO mail.ispras.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751882AbcJHCyA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Oct 2016 22:54:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vmxnet3_set_mc() still assumes zero is invalid pa:
  it assumes dma_mapping_error(...,0) returns true if vmxnet3_copy_mc() fails;
  it calls dma_unmap_single() iff new_table_pa is not zero.

The patch adds an explicit variable to track status of new_table_pa.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/vmxnet3/vmxnet3_drv.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index b5554f2ebee4..5ee059eafe9c 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -2279,6 +2279,7 @@ vmxnet3_set_mc(struct net_device *netdev)
 					&adapter->shared->devRead.rxFilterConf;
 	u8 *new_table = NULL;
 	dma_addr_t new_table_pa = 0;
+	int new_table_pa_valid = 0;
 	u32 new_mode = VMXNET3_RXM_UCAST;
 
 	if (netdev->flags & IFF_PROMISC) {
@@ -2307,13 +2308,15 @@ vmxnet3_set_mc(struct net_device *netdev)
 							new_table,
 							sz,
 							PCI_DMA_TODEVICE);
+				if (!dma_mapping_error(&adapter->pdev->dev,
+						       new_table_pa)) {
+					new_mode |= VMXNET3_RXM_MCAST;
+					new_table_pa_valid = 1;
+					rxConf->mfTablePA = cpu_to_le64(
+								new_table_pa);
+				}
 			}
-
-			if (!dma_mapping_error(&adapter->pdev->dev,
-					       new_table_pa)) {
-				new_mode |= VMXNET3_RXM_MCAST;
-				rxConf->mfTablePA = cpu_to_le64(new_table_pa);
-			} else {
+			if (!new_table_pa_valid) {
 				netdev_info(netdev,
 					    "failed to copy mcast list, setting ALL_MULTI\n");
 				new_mode |= VMXNET3_RXM_ALL_MULTI;
@@ -2338,7 +2341,7 @@ vmxnet3_set_mc(struct net_device *netdev)
 			       VMXNET3_CMD_UPDATE_MAC_FILTERS);
 	spin_unlock_irqrestore(&adapter->cmd_lock, flags);
 
-	if (new_table_pa)
+	if (new_table_pa_valid)
 		dma_unmap_single(&adapter->pdev->dev, new_table_pa,
 				 rxConf->mfTableLen, PCI_DMA_TODEVICE);
 	kfree(new_table);
-- 
2.7.4
