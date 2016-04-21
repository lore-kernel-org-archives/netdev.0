From: Shrikrishna Khare <skhare@vmware.com>
Subject: [PATCH net] Driver: Vmxnet3: set CHECKSUM_UNNECESSARY for IPv6 packets
Date: Wed, 20 Apr 2016 18:12:29 -0700
Message-ID: <1461201149-45583-1-git-send-email-skhare@vmware.com>
Cc: Shrikrishna Khare <skhare@vmware.com>, Jin Heo <heoj@vmware.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pv-drivers@vmware.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For IPv6, if the device indicates that the checksum is correct, set
CHECKSUM_UNNECESSARY.

Reported-by: Subbarao Narahari <snarahari@vmware.com>
Signed-off-by: Shrikrishna Khare <skhare@vmware.com>
Signed-off-by: Jin Heo <heoj@vmware.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c | 12 ++++++++----
 drivers/net/vmxnet3/vmxnet3_int.h |  4 ++--
 2 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index fc895d0..4a67e4f 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -1152,12 +1152,16 @@ vmxnet3_rx_csum(struct vmxnet3_adapter *adapter,
 		union Vmxnet3_GenericDesc *gdesc)
 {
 	if (!gdesc->rcd.cnc && adapter->netdev->features & NETIF_F_RXCSUM) {
-		/* typical case: TCP/UDP over IP and both csums are correct */
-		if ((le32_to_cpu(gdesc->dword[3]) & VMXNET3_RCD_CSUM_OK) ==
-							VMXNET3_RCD_CSUM_OK) {
+		if (gdesc->rcd.v4 &&
+		    (le32_to_cpu(gdesc->dword[3]) &
+		     VMXNET3_RCD_CSUM_OK) == VMXNET3_RCD_CSUM_OK) {
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+			BUG_ON(!(gdesc->rcd.tcp || gdesc->rcd.udp));
+			BUG_ON(gdesc->rcd.frg);
+		} else if (gdesc->rcd.v6 && (le32_to_cpu(gdesc->dword[3]) &
+					     (1 << VMXNET3_RCD_TUC_SHIFT))) {
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 			BUG_ON(!(gdesc->rcd.tcp || gdesc->rcd.udp));
-			BUG_ON(!(gdesc->rcd.v4  || gdesc->rcd.v6));
 			BUG_ON(gdesc->rcd.frg);
 		} else {
 			if (gdesc->rcd.csum) {
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index 729c344..c482539 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -69,10 +69,10 @@
 /*
  * Version numbers
  */
-#define VMXNET3_DRIVER_VERSION_STRING   "1.4.6.0-k"
+#define VMXNET3_DRIVER_VERSION_STRING   "1.4.7.0-k"
 
 /* a 32-bit int, each byte encode a verion number in VMXNET3_DRIVER_VERSION */
-#define VMXNET3_DRIVER_VERSION_NUM      0x01040600
+#define VMXNET3_DRIVER_VERSION_NUM      0x01040700
 
 #if defined(CONFIG_PCI_MSI)
 	/* RSS only makes sense if MSI-X is supported. */
-- 
1.9.1
