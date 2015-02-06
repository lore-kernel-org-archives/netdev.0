From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 9/9] be2net: avoid unncessary swapping of fields in eth_tx_wrb
Date: Fri, 6 Feb 2015 08:18:43 -0500
Message-ID: <1423228723-10919-10-git-send-email-sathya.perla@emulex.com>
References: <1423228723-10919-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.emulex.com ([138.239.224.100]:28176 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755130AbbBFNPm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 08:15:42 -0500
In-Reply-To: <1423228723-10919-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 32-bit fields of a tx-wrb are little endian. The driver is currently
using be_dws_le_to_cpu() routine to swap (cpu to le) all the fields of
a tx-wrb. So, the rsvd field is also unnecessarily swapped.

This patch fixes this by individually swapping the required fields.
Also, the type of the fields in eth_tx_wrb{} is now changed to __le32
from u32 to avoid sparse warnings.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_hw.h   | 10 ++++-----
 drivers/net/ethernet/emulex/benet/be_main.c | 35 ++++++++++++++++++-----------
 2 files changed, 27 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_hw.h b/drivers/net/ethernet/emulex/benet/be_hw.h
index a8593aa..4884088 100644
--- a/drivers/net/ethernet/emulex/benet/be_hw.h
+++ b/drivers/net/ethernet/emulex/benet/be_hw.h
@@ -193,10 +193,10 @@ struct be_eq_entry {
 /* TX Queue Descriptor */
 #define ETH_WRB_FRAG_LEN_MASK		0xFFFF
 struct be_eth_wrb {
-	u32 frag_pa_hi;		/* dword 0 */
-	u32 frag_pa_lo;		/* dword 1 */
-	u32 rsvd0;		/* dword 2 */
-	u32 frag_len;		/* dword 3: bits 0 - 15 */
+	__le32 frag_pa_hi;		/* dword 0 */
+	__le32 frag_pa_lo;		/* dword 1 */
+	u32 rsvd0;			/* dword 2 */
+	__le32 frag_len;		/* dword 3: bits 0 - 15 */
 } __packed;
 
 /* Pseudo amap definition for eth_hdr_wrb in which each bit of the
@@ -229,7 +229,7 @@ struct amap_eth_hdr_wrb {
 #define TX_HDR_WRB_NUM_MASK		0x1F		/* word 2: bits 13:17 */
 
 struct be_eth_hdr_wrb {
-	u32 dw[4];
+	__le32 dw[4];
 };
 
 /********* Tx Compl Status Encoding *********/
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 5936b24..4abe2ab 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -682,9 +682,20 @@ static u32 skb_wrb_cnt(struct sk_buff *skb)
 
 static inline void wrb_fill(struct be_eth_wrb *wrb, u64 addr, int len)
 {
-	wrb->frag_pa_hi = upper_32_bits(addr);
-	wrb->frag_pa_lo = addr & 0xFFFFFFFF;
-	wrb->frag_len = len & ETH_WRB_FRAG_LEN_MASK;
+	wrb->frag_pa_hi = cpu_to_le32(upper_32_bits(addr));
+	wrb->frag_pa_lo = cpu_to_le32(lower_32_bits(addr));
+	wrb->frag_len = cpu_to_le32(len & ETH_WRB_FRAG_LEN_MASK);
+	wrb->rsvd0 = 0;
+}
+
+/* A dummy wrb is just all zeros. Using a separate routine for dummy-wrb
+ * to avoid the swap and shift/mask operations in wrb_fill().
+ */
+static inline void wrb_fill_dummy(struct be_eth_wrb *wrb)
+{
+	wrb->frag_pa_hi = 0;
+	wrb->frag_pa_lo = 0;
+	wrb->frag_len = 0;
 	wrb->rsvd0 = 0;
 }
 
@@ -765,16 +776,16 @@ static void unmap_tx_frag(struct device *dev, struct be_eth_wrb *wrb,
 			  bool unmap_single)
 {
 	dma_addr_t dma;
+	u32 frag_len = le32_to_cpu(wrb->frag_len);
 
-	be_dws_le_to_cpu(wrb, sizeof(*wrb));
 
-	dma = (u64)wrb->frag_pa_hi << 32 | (u64)wrb->frag_pa_lo;
-	if (wrb->frag_len) {
+	dma = (u64)le32_to_cpu(wrb->frag_pa_hi) << 32 |
+		(u64)le32_to_cpu(wrb->frag_pa_lo);
+	if (frag_len) {
 		if (unmap_single)
-			dma_unmap_single(dev, dma, wrb->frag_len,
-					 DMA_TO_DEVICE);
+			dma_unmap_single(dev, dma, frag_len, DMA_TO_DEVICE);
 		else
-			dma_unmap_page(dev, dma, wrb->frag_len, DMA_TO_DEVICE);
+			dma_unmap_page(dev, dma, frag_len, DMA_TO_DEVICE);
 	}
 }
 
@@ -806,7 +817,6 @@ static u32 be_xmit_enqueue(struct be_adapter *adapter, struct be_tx_obj *txo,
 		map_single = true;
 		wrb = queue_head_node(txq);
 		wrb_fill(wrb, busaddr, len);
-		be_dws_cpu_to_le(wrb, sizeof(*wrb));
 		queue_head_inc(txq);
 		copied += len;
 	}
@@ -820,7 +830,6 @@ static u32 be_xmit_enqueue(struct be_adapter *adapter, struct be_tx_obj *txo,
 			goto dma_err;
 		wrb = queue_head_node(txq);
 		wrb_fill(wrb, busaddr, skb_frag_size(frag));
-		be_dws_cpu_to_le(wrb, sizeof(*wrb));
 		queue_head_inc(txq);
 		copied += skb_frag_size(frag);
 	}
@@ -846,7 +855,7 @@ dma_err:
 		wrb = queue_head_node(txq);
 		unmap_tx_frag(dev, wrb, map_single);
 		map_single = false;
-		copied -= wrb->frag_len;
+		copied -= le32_to_cpu(wrb->frag_len);
 		adapter->drv_stats.dma_map_errors++;
 		queue_head_inc(txq);
 	}
@@ -1037,7 +1046,7 @@ static void be_xmit_flush(struct be_adapter *adapter, struct be_tx_obj *txo)
 
 	/* compose a dummy wrb if there are odd set of wrbs to notify */
 	if (!lancer_chip(adapter) && (txo->pend_wrb_cnt & 1)) {
-		wrb_fill(queue_head_node(txq), 0, 0);
+		wrb_fill_dummy(queue_head_node(txq));
 		queue_head_inc(txq);
 		atomic_inc(&txq->used);
 		txo->pend_wrb_cnt++;
-- 
2.2.0
