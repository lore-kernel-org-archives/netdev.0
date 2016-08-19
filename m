From: Shrikrishna Khare <skhare@vmware.com>
Subject: [PATCH net] vmxnet3: fix tx data ring copy for variable size
Date: Fri, 19 Aug 2016 10:33:42 -0700
Message-ID: <1471628022-93931-1-git-send-email-skhare@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shrikrishna Khare <skhare@vmware.com>,
        Guolin Yang <gyang@vmware.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <pv-drivers@vmware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

'Commit 3c8b3efc061a ("vmxnet3: allow variable length transmit data ring
buffer")' changed the size of the buffers in the tx data ring from a
fixed size of 128 bytes to a variable size.

However, while copying data to the data ring, vmxnet3_copy_hdr continues
to carry the old code that assumes fixed buffer size of 128. This patch
fixes it by adding correct offset based on the actual data ring buffer
size.

Signed-off-by: Guolin Yang <gyang@vmware.com>
Signed-off-by: Shrikrishna Khare <skhare@vmware.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c | 4 +++-
 drivers/net/vmxnet3/vmxnet3_int.h | 4 ++--
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index c68fe49..4244b9d 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -914,7 +914,9 @@ vmxnet3_copy_hdr(struct sk_buff *skb, struct vmxnet3_tx_queue *tq,
 {
 	struct Vmxnet3_TxDataDesc *tdd;
 
-	tdd = tq->data_ring.base + tq->tx_ring.next2fill;
+	tdd = (struct Vmxnet3_TxDataDesc *)((u8 *)tq->data_ring.base +
+					    tq->tx_ring.next2fill *
+					    tq->txdata_desc_size);
 
 	memcpy(tdd->data, skb->data, ctx->copy_size);
 	netdev_dbg(adapter->netdev,
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index 74fc030..7dc37a0 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -69,10 +69,10 @@
 /*
  * Version numbers
  */
-#define VMXNET3_DRIVER_VERSION_STRING   "1.4.9.0-k"
+#define VMXNET3_DRIVER_VERSION_STRING   "1.4.a.0-k"
 
 /* a 32-bit int, each byte encode a verion number in VMXNET3_DRIVER_VERSION */
-#define VMXNET3_DRIVER_VERSION_NUM      0x01040900
+#define VMXNET3_DRIVER_VERSION_NUM      0x01040a00
 
 #if defined(CONFIG_PCI_MSI)
 	/* RSS only makes sense if MSI-X is supported. */
-- 
2.8.2
