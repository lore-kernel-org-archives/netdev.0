From: Andy King <acking@vmware.com>
Subject: [PATCH] VMXNET3: Check for map error in vmxnet3_set_mc
Date: Tue,  2 Sep 2014 09:30:08 -0700
Message-ID: <1409675408-8440-1-git-send-email-acking@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, penguin-kernel@I-love.SAKURA.ne.jp,
	Andy King <acking@vmware.com>, davem@davemloft.net
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

We should check if the map of the table actually succeeds, and also free
resources accordingly. This fixes the kernel panic reported by Tetsuo
Handa.

Version bumped to 1.2.1.0

Acked-by: Shelley Gong <shelleygong@vmware.com>
Acked-by: Bhavesh Davda <bhavesh@vmware.com>
Signed-off-by: Andy King <acking@vmware.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c |   14 ++++++++------
 drivers/net/vmxnet3/vmxnet3_int.h |    4 ++--
 2 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index d6e90c7..f450010 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -2056,7 +2056,6 @@ vmxnet3_set_mc(struct net_device *netdev)
 		if (!netdev_mc_empty(netdev)) {
 			new_table = vmxnet3_copy_mc(netdev);
 			if (new_table) {
-				new_mode |= VMXNET3_RXM_MCAST;
 				rxConf->mfTableLen = cpu_to_le16(
 					netdev_mc_count(netdev) * ETH_ALEN);
 				new_table_pa = dma_map_single(
@@ -2064,15 +2063,18 @@ vmxnet3_set_mc(struct net_device *netdev)
 							new_table,
 							rxConf->mfTableLen,
 							PCI_DMA_TODEVICE);
+			}
+
+			if (new_table_pa) {
+				new_mode |= VMXNET3_RXM_MCAST;
 				rxConf->mfTablePA = cpu_to_le64(new_table_pa);
 			} else {
-				netdev_info(netdev, "failed to copy mcast list"
-					    ", setting ALL_MULTI\n");
+				netdev_info(netdev,
+					    "failed to copy mcast list, setting ALL_MULTI\n");
 				new_mode |= VMXNET3_RXM_ALL_MULTI;
 			}
 		}
 
-
 	if (!(new_mode & VMXNET3_RXM_MCAST)) {
 		rxConf->mfTableLen = 0;
 		rxConf->mfTablePA = 0;
@@ -2091,11 +2093,11 @@ vmxnet3_set_mc(struct net_device *netdev)
 			       VMXNET3_CMD_UPDATE_MAC_FILTERS);
 	spin_unlock_irqrestore(&adapter->cmd_lock, flags);
 
-	if (new_table) {
+	if (new_table_pa)
 		dma_unmap_single(&adapter->pdev->dev, new_table_pa,
 				 rxConf->mfTableLen, PCI_DMA_TODEVICE);
+	if (new_table)
 		kfree(new_table);
-	}
 }
 
 void
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index 29ee77f2..3759479 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -69,10 +69,10 @@
 /*
  * Version numbers
  */
-#define VMXNET3_DRIVER_VERSION_STRING   "1.2.0.0-k"
+#define VMXNET3_DRIVER_VERSION_STRING   "1.2.1.0-k"
 
 /* a 32-bit int, each byte encode a verion number in VMXNET3_DRIVER_VERSION */
-#define VMXNET3_DRIVER_VERSION_NUM      0x01020000
+#define VMXNET3_DRIVER_VERSION_NUM      0x01020100
 
 #if defined(CONFIG_PCI_MSI)
 	/* RSS only makes sense if MSI-X is supported. */
-- 
1.7.4.1
