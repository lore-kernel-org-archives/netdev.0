From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 2/5] qlge: Get rid of split addresses in hardware control blocks.
Date: Fri,  9 Jan 2009 13:31:50 -0800
Message-ID: <1231536713-24538-2-git-send-email-ron.mercer@qlogic.com>
References: <20090109213045.GD10803@susedev.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:58231 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758020AbZAIVcB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 16:32:01 -0500
In-Reply-To: <20090109213045.GD10803@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |   24 +++++++--------------
 drivers/net/qlge/qlge_dbg.c  |   48 ++++++++++++++----------------------------
 drivers/net/qlge/qlge_main.c |   26 +++++++---------------
 3 files changed, 32 insertions(+), 66 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 4cb3647..9697002 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -961,8 +961,7 @@ struct ib_mac_iocb_rsp {
 #define IB_MAC_IOCB_RSP_DS	0x40	/* data is in small buffer */
 #define IB_MAC_IOCB_RSP_DL	0x80	/* data is in large buffer */
 	__le32 data_len;	/* */
-	__le32 data_addr_lo;	/* */
-	__le32 data_addr_hi;	/* */
+	__le64 data_addr;	/* */
 	__le32 rss;		/* */
 	__le16 vlan_id;		/* 12 bits */
 #define IB_MAC_IOCB_RSP_C	0x1000	/* VLAN CFI bit */
@@ -976,8 +975,7 @@ struct ib_mac_iocb_rsp {
 #define IB_MAC_IOCB_RSP_HS	0x40
 #define IB_MAC_IOCB_RSP_HL	0x80
 	__le32 hdr_len;		/* */
-	__le32 hdr_addr_lo;	/* */
-	__le32 hdr_addr_hi;	/* */
+	__le64 hdr_addr;	/* */
 } __attribute((packed));
 
 struct ib_ae_iocb_rsp {
@@ -1042,10 +1040,8 @@ struct wqicb {
 	__le16 cq_id_rss;
 #define Q_CQ_ID_RSS_RV 0x8000
 	__le16 rid;
-	__le32 addr_lo;
-	__le32 addr_hi;
-	__le32 cnsmr_idx_addr_lo;
-	__le32 cnsmr_idx_addr_hi;
+	__le64 addr;
+	__le64 cnsmr_idx_addr;
 } __attribute((packed));
 
 /*
@@ -1070,18 +1066,14 @@ struct cqicb {
 #define LEN_CPP_64	0x0002
 #define LEN_CPP_128	0x0003
 	__le16 rid;
-	__le32 addr_lo;
-	__le32 addr_hi;
-	__le32 prod_idx_addr_lo;
-	__le32 prod_idx_addr_hi;
+	__le64 addr;
+	__le64 prod_idx_addr;
 	__le16 pkt_delay;
 	__le16 irq_delay;
-	__le32 lbq_addr_lo;
-	__le32 lbq_addr_hi;
+	__le64 lbq_addr;
 	__le16 lbq_buf_size;
 	__le16 lbq_len;		/* entry count */
-	__le32 sbq_addr_lo;
-	__le32 sbq_addr_hi;
+	__le64 sbq_addr;
 	__le16 sbq_buf_size;
 	__le16 sbq_len;		/* entry count */
 } __attribute((packed));
diff --git a/drivers/net/qlge/qlge_dbg.c b/drivers/net/qlge/qlge_dbg.c
index e705ea5..379b895 100644
--- a/drivers/net/qlge/qlge_dbg.c
+++ b/drivers/net/qlge/qlge_dbg.c
@@ -435,14 +435,10 @@ void ql_dump_wqicb(struct wqicb *wqicb)
 	printk(KERN_ERR PFX "wqicb->cq_id_rss = %d.\n",
 	       le16_to_cpu(wqicb->cq_id_rss));
 	printk(KERN_ERR PFX "wqicb->rid = 0x%x.\n", le16_to_cpu(wqicb->rid));
-	printk(KERN_ERR PFX "wqicb->wq_addr_lo = 0x%.08x.\n",
-	       le32_to_cpu(wqicb->addr_lo));
-	printk(KERN_ERR PFX "wqicb->wq_addr_hi = 0x%.08x.\n",
-	       le32_to_cpu(wqicb->addr_hi));
-	printk(KERN_ERR PFX "wqicb->wq_cnsmr_idx_addr_lo = 0x%.08x.\n",
-	       le32_to_cpu(wqicb->cnsmr_idx_addr_lo));
-	printk(KERN_ERR PFX "wqicb->wq_cnsmr_idx_addr_hi = 0x%.08x.\n",
-	       le32_to_cpu(wqicb->cnsmr_idx_addr_hi));
+	printk(KERN_ERR PFX "wqicb->wq_addr = 0x%llx.\n",
+	       (unsigned long long) le64_to_cpu(wqicb->addr));
+	printk(KERN_ERR PFX "wqicb->wq_cnsmr_idx_addr = 0x%llx.\n",
+	       (unsigned long long) le64_to_cpu(wqicb->cnsmr_idx_addr));
 }
 
 void ql_dump_tx_ring(struct tx_ring *tx_ring)
@@ -511,30 +507,22 @@ void ql_dump_cqicb(struct cqicb *cqicb)
 	printk(KERN_ERR PFX "cqicb->msix_vect = %d.\n", cqicb->msix_vect);
 	printk(KERN_ERR PFX "cqicb->flags = %x.\n", cqicb->flags);
 	printk(KERN_ERR PFX "cqicb->len = %d.\n", le16_to_cpu(cqicb->len));
-	printk(KERN_ERR PFX "cqicb->addr_lo = %x.\n",
-	       le32_to_cpu(cqicb->addr_lo));
-	printk(KERN_ERR PFX "cqicb->addr_hi = %x.\n",
-	       le32_to_cpu(cqicb->addr_hi));
-	printk(KERN_ERR PFX "cqicb->prod_idx_addr_lo = %x.\n",
-	       le32_to_cpu(cqicb->prod_idx_addr_lo));
-	printk(KERN_ERR PFX "cqicb->prod_idx_addr_hi = %x.\n",
-	       le32_to_cpu(cqicb->prod_idx_addr_hi));
+	printk(KERN_ERR PFX "cqicb->addr = 0x%llx.\n",
+	       (unsigned long long) le64_to_cpu(cqicb->addr));
+	printk(KERN_ERR PFX "cqicb->prod_idx_addr = 0x%llx.\n",
+	       (unsigned long long) le64_to_cpu(cqicb->prod_idx_addr));
 	printk(KERN_ERR PFX "cqicb->pkt_delay = 0x%.04x.\n",
 	       le16_to_cpu(cqicb->pkt_delay));
 	printk(KERN_ERR PFX "cqicb->irq_delay = 0x%.04x.\n",
 	       le16_to_cpu(cqicb->irq_delay));
-	printk(KERN_ERR PFX "cqicb->lbq_addr_lo = %x.\n",
-	       le32_to_cpu(cqicb->lbq_addr_lo));
-	printk(KERN_ERR PFX "cqicb->lbq_addr_hi = %x.\n",
-	       le32_to_cpu(cqicb->lbq_addr_hi));
+	printk(KERN_ERR PFX "cqicb->lbq_addr = 0x%llx.\n",
+	       (unsigned long long) le64_to_cpu(cqicb->lbq_addr));
 	printk(KERN_ERR PFX "cqicb->lbq_buf_size = 0x%.04x.\n",
 	       le16_to_cpu(cqicb->lbq_buf_size));
 	printk(KERN_ERR PFX "cqicb->lbq_len = 0x%.04x.\n",
 	       le16_to_cpu(cqicb->lbq_len));
-	printk(KERN_ERR PFX "cqicb->sbq_addr_lo = %x.\n",
-	       le32_to_cpu(cqicb->sbq_addr_lo));
-	printk(KERN_ERR PFX "cqicb->sbq_addr_hi = %x.\n",
-	       le32_to_cpu(cqicb->sbq_addr_hi));
+	printk(KERN_ERR PFX "cqicb->sbq_addr = 0x%llx.\n",
+	       (unsigned long long) le64_to_cpu(cqicb->sbq_addr));
 	printk(KERN_ERR PFX "cqicb->sbq_buf_size = 0x%.04x.\n",
 	       le16_to_cpu(cqicb->sbq_buf_size));
 	printk(KERN_ERR PFX "cqicb->sbq_len = 0x%.04x.\n",
@@ -811,10 +799,8 @@ void ql_dump_ib_mac_rsp(struct ib_mac_iocb_rsp *ib_mac_rsp)
 
 	printk(KERN_ERR PFX "data_len	= %d\n",
 	       le32_to_cpu(ib_mac_rsp->data_len));
-	printk(KERN_ERR PFX "data_addr_hi    = 0x%x\n",
-	       le32_to_cpu(ib_mac_rsp->data_addr_hi));
-	printk(KERN_ERR PFX "data_addr_lo    = 0x%x\n",
-	       le32_to_cpu(ib_mac_rsp->data_addr_lo));
+	printk(KERN_ERR PFX "data_addr    = 0x%llx\n",
+	       (unsigned long long) le64_to_cpu(ib_mac_rsp->data_addr));
 	if (ib_mac_rsp->flags3 & IB_MAC_IOCB_RSP_RSS_MASK)
 		printk(KERN_ERR PFX "rss    = %x\n",
 		       le32_to_cpu(ib_mac_rsp->rss));
@@ -830,10 +816,8 @@ void ql_dump_ib_mac_rsp(struct ib_mac_iocb_rsp *ib_mac_rsp)
 	if (ib_mac_rsp->flags4 & IB_MAC_IOCB_RSP_HV) {
 		printk(KERN_ERR PFX "hdr length	= %d.\n",
 		       le32_to_cpu(ib_mac_rsp->hdr_len));
-		printk(KERN_ERR PFX "hdr addr_hi    = 0x%x.\n",
-		       le32_to_cpu(ib_mac_rsp->hdr_addr_hi));
-		printk(KERN_ERR PFX "hdr addr_lo    = 0x%x.\n",
-		       le32_to_cpu(ib_mac_rsp->hdr_addr_lo));
+		printk(KERN_ERR PFX "hdr addr    = 0x%llx.\n",
+		       (unsigned long long) le64_to_cpu(ib_mac_rsp->hdr_addr));
 	}
 }
 #endif
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 983c953..f9db7a8 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -2467,12 +2467,9 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 	bq_len = (rx_ring->cq_len == 65536) ? 0 : (u16) rx_ring->cq_len;
 	cqicb->len = cpu_to_le16(bq_len | LEN_V | LEN_CPP_CONT);
 
-	cqicb->addr_lo = cpu_to_le32(rx_ring->cq_base_dma);
-	cqicb->addr_hi = cpu_to_le32((u64) rx_ring->cq_base_dma >> 32);
+	cqicb->addr = cpu_to_le64(rx_ring->cq_base_dma);
 
-	cqicb->prod_idx_addr_lo = cpu_to_le32(rx_ring->prod_idx_sh_reg_dma);
-	cqicb->prod_idx_addr_hi =
-	    cpu_to_le32((u64) rx_ring->prod_idx_sh_reg_dma >> 32);
+	cqicb->prod_idx_addr = cpu_to_le64(rx_ring->prod_idx_sh_reg_dma);
 
 	/*
 	 * Set up the control block load flags.
@@ -2483,10 +2480,8 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 	if (rx_ring->lbq_len) {
 		cqicb->flags |= FLAGS_LL;	/* Load lbq values */
 		*((u64 *) rx_ring->lbq_base_indirect) = rx_ring->lbq_base_dma;
-		cqicb->lbq_addr_lo =
-		    cpu_to_le32(rx_ring->lbq_base_indirect_dma);
-		cqicb->lbq_addr_hi =
-		    cpu_to_le32((u64) rx_ring->lbq_base_indirect_dma >> 32);
+		cqicb->lbq_addr =
+		    cpu_to_le64(rx_ring->lbq_base_indirect_dma);
 		bq_len = (rx_ring->lbq_buf_size == 65536) ? 0 :
 			(u16) rx_ring->lbq_buf_size;
 		cqicb->lbq_buf_size = cpu_to_le16(bq_len);
@@ -2501,10 +2496,8 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 	if (rx_ring->sbq_len) {
 		cqicb->flags |= FLAGS_LS;	/* Load sbq values */
 		*((u64 *) rx_ring->sbq_base_indirect) = rx_ring->sbq_base_dma;
-		cqicb->sbq_addr_lo =
-		    cpu_to_le32(rx_ring->sbq_base_indirect_dma);
-		cqicb->sbq_addr_hi =
-		    cpu_to_le32((u64) rx_ring->sbq_base_indirect_dma >> 32);
+		cqicb->sbq_addr =
+		    cpu_to_le64(rx_ring->sbq_base_indirect_dma);
 		cqicb->sbq_buf_size =
 		    cpu_to_le16(((rx_ring->sbq_buf_size / 2) + 8) & 0xfffffff8);
 		bq_len = (rx_ring->sbq_len == 65536) ? 0 :
@@ -2611,12 +2604,9 @@ static int ql_start_tx_ring(struct ql_adapter *qdev, struct tx_ring *tx_ring)
 				   Q_FLAGS_LB | Q_FLAGS_LI | Q_FLAGS_LO);
 	wqicb->cq_id_rss = cpu_to_le16(tx_ring->cq_id);
 	wqicb->rid = 0;
-	wqicb->addr_lo = cpu_to_le32(tx_ring->wq_base_dma);
-	wqicb->addr_hi = cpu_to_le32((u64) tx_ring->wq_base_dma >> 32);
+	wqicb->addr = cpu_to_le64(tx_ring->wq_base_dma);
 
-	wqicb->cnsmr_idx_addr_lo = cpu_to_le32(tx_ring->cnsmr_idx_sh_reg_dma);
-	wqicb->cnsmr_idx_addr_hi =
-	    cpu_to_le32((u64) tx_ring->cnsmr_idx_sh_reg_dma >> 32);
+	wqicb->cnsmr_idx_addr = cpu_to_le64(tx_ring->cnsmr_idx_sh_reg_dma);
 
 	ql_init_tx_ring(qdev, tx_ring);
 
-- 
1.6.0

