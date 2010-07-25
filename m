From: Bhavesh Davda <bhavesh@vmware.com>
Subject: [PATCH 2.6.35-rc1] net-next: Fix an overflow bug in vmxnet3 Tx
 descriptor
Date: Sat, 24 Jul 2010 17:43:29 -0700
Message-ID: <20100725004329.GB6680@bhavesh-lx1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:27816 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751972Ab0GYAna (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Jul 2010 20:43:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
Fix an overflow bug in vmxnet3 Tx descriptor

This patch fixes a bug where a 16K buffer on a Tx descriptor was overflowing
into the 'gen' bit in the descriptor thereby corrupting the descriptor and
stalling the transmit ring.

Signed-off-by: Bhavesh Davda <bhavesh@vmware.com>
Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>
Signed-off-by: Matthew Delco <delcoM@vmware.com>
Signed-off-by: Ronghua Zhang <ronghua@vmware.com>

---
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 9d64186..abe0ff5 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -664,8 +664,13 @@ vmxnet3_map_pkt(struct sk_buff *skb, struct vmxnet3_tx_ctx *ctx,
 	while (len) {
 		u32 buf_size;
 
-		buf_size = len > VMXNET3_MAX_TX_BUF_SIZE ?
-			   VMXNET3_MAX_TX_BUF_SIZE : len;
+		if (len < VMXNET3_MAX_TX_BUF_SIZE) {
+			buf_size = len;
+			dw2 |= len;
+		} else {
+			buf_size = VMXNET3_MAX_TX_BUF_SIZE;
+			/* spec says that for TxDesc.len, 0 == 2^14 */
+		}
 
 		tbi = tq->buf_info + tq->tx_ring.next2fill;
 		tbi->map_type = VMXNET3_MAP_SINGLE;
@@ -673,13 +678,13 @@ vmxnet3_map_pkt(struct sk_buff *skb, struct vmxnet3_tx_ctx *ctx,
 				skb->data + buf_offset, buf_size,
 				PCI_DMA_TODEVICE);
 
-		tbi->len = buf_size; /* this automatically convert 2^14 to 0 */
+		tbi->len = buf_size;
 
 		gdesc = tq->tx_ring.base + tq->tx_ring.next2fill;
 		BUG_ON(gdesc->txd.gen == tq->tx_ring.gen);
 
 		gdesc->txd.addr = cpu_to_le64(tbi->dma_addr);
-		gdesc->dword[2] = cpu_to_le32(dw2 | buf_size);
+		gdesc->dword[2] = cpu_to_le32(dw2);
 		gdesc->dword[3] = 0;
 
 		dev_dbg(&adapter->netdev->dev,
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index 762a6a7..2121c73 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -68,10 +68,10 @@
 /*
  * Version numbers
  */
-#define VMXNET3_DRIVER_VERSION_STRING   "1.0.13.0-k"
+#define VMXNET3_DRIVER_VERSION_STRING   "1.0.14.0-k"
 
 /* a 32-bit int, each byte encode a verion number in VMXNET3_DRIVER_VERSION */
-#define VMXNET3_DRIVER_VERSION_NUM      0x01000B00
+#define VMXNET3_DRIVER_VERSION_NUM      0x01000E00
 
 
 /*
