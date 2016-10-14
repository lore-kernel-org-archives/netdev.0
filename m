From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH v2] vmxnet3: avoid assumption about invalid dma_pa in vmxnet3_set_mc()
Date: Sat, 15 Oct 2016 00:01:20 +0300
Message-ID: <1476478880-22607-1-git-send-email-khoroshilov@ispras.ru>
References: <20161013.094323.1769619439752576215.davem@davemloft.net>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
        "VMware, Inc." <pv-drivers@vmware.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: David Miller <davem@davemloft.net>,
        Shrikrishna Khare <skhare@vmware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161013.094323.1769619439752576215.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

vmxnet3_set_mc() checks new_table_pa returned by dma_map_single()
with dma_mapping_error(), but even there it assumes zero is invalid pa
(it assumes dma_mapping_error(...,0) returns true if new_table is NULL).

The patch adds an explicit variable to track status of new_table_pa.

Found by Linux Driver Verification project (linuxtesting.org).

v2: use "bool" and "true"/"false" for boolean variables.
Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/vmxnet3/vmxnet3_drv.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index b5554f2ebee4..ef83ae3b0a44 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -2279,6 +2279,7 @@ vmxnet3_set_mc(struct net_device *netdev)
 					&adapter->shared->devRead.rxFilterConf;
 	u8 *new_table = NULL;
 	dma_addr_t new_table_pa = 0;
+	bool new_table_pa_valid = false;
 	u32 new_mode = VMXNET3_RXM_UCAST;
 
 	if (netdev->flags & IFF_PROMISC) {
@@ -2307,13 +2308,15 @@ vmxnet3_set_mc(struct net_device *netdev)
 							new_table,
 							sz,
 							PCI_DMA_TODEVICE);
+				if (!dma_mapping_error(&adapter->pdev->dev,
+						       new_table_pa)) {
+					new_mode |= VMXNET3_RXM_MCAST;
+					new_table_pa_valid = true;
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
