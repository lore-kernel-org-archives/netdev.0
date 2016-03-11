From: Shrikrishna Khare <skhare@vmware.com>
Subject: [PATCH] Driver: Vmxnet3: Fix regression caused by cec0556
Date: Fri, 11 Mar 2016 13:29:44 -0800
Message-ID: <1457731784-96240-1-git-send-email-skhare@vmware.com>
Cc: Shrikrishna Khare <skhare@vmware.com>,
	Guolin Yang <gyang@vmware.com>
To: pv-drivers@vmware.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

don't pass uninitialized flags to spin_unlock_irqrestore.

Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Shrikrishna Khare <skhare@vmware.com>
Signed-off-by: Guolin Yang <gyang@vmware.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c | 9 ++++-----
 drivers/net/vmxnet3/vmxnet3_int.h | 4 ++--
 2 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index fc895d0..eba9083b 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -1022,14 +1022,16 @@ vmxnet3_tq_xmit(struct sk_buff *skb, struct vmxnet3_tx_queue *tq,
 		if (ctx.mss) {
 			if (unlikely(ctx.eth_ip_hdr_size + ctx.l4_hdr_size >
 				     VMXNET3_MAX_TX_BUF_SIZE)) {
-				goto hdr_too_big;
+				tq->stats.drop_oversized_hdr++;
+				goto drop_pkt;
 			}
 		} else {
 			if (skb->ip_summed == CHECKSUM_PARTIAL) {
 				if (unlikely(ctx.eth_ip_hdr_size +
 					     skb->csum_offset >
 					     VMXNET3_MAX_CSUM_OFFSET)) {
-					goto hdr_too_big;
+					tq->stats.drop_oversized_hdr++;
+					goto drop_pkt;
 				}
 			}
 		}
@@ -1052,7 +1054,6 @@ vmxnet3_tq_xmit(struct sk_buff *skb, struct vmxnet3_tx_queue *tq,
 		return NETDEV_TX_BUSY;
 	}
 
-
 	vmxnet3_copy_hdr(skb, tq, &ctx, adapter);
 
 	/* fill tx descs related to addr & len */
@@ -1123,8 +1124,6 @@ vmxnet3_tq_xmit(struct sk_buff *skb, struct vmxnet3_tx_queue *tq,
 
 	return NETDEV_TX_OK;
 
-hdr_too_big:
-	tq->stats.drop_oversized_hdr++;
 unlock_drop_pkt:
 	spin_unlock_irqrestore(&tq->tx_lock, flags);
 drop_pkt:
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
