From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH net-next 11/15]bnx2x: Add TPA, Broadcoms HW LRO
Date: Tue, 17 Jun 2008 17:49:26 +0300
Message-ID: <1213714166.5817.181.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Michael Chan" <mchan@broadcom.com>,
	"Vladislav Zolotarov" <vladz@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3673 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758111AbYFQOtn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 10:49:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The TPA stands for Transparent Packet Aggregation. When enabled, the FW
aggregate in-order TCP packets according to the 4-tuple match and sends
1 big packet to the driver. This packet is stored on an SGL in which
each SGE is 1 page. The FW also implements a timeout algorithm and it
honors all TCP flag, including the push flag as a trigger to halt
aggregation.

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |  275 +++++++++++++++------
 drivers/net/bnx2x_main.c |  619 ++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 795 insertions(+), 99 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 4c8988a..8433ebe 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -126,8 +126,8 @@
 #define is_multi(bp)		(bp->num_queues > 1)
 
 
+/* fast path */
 
-#define bnx2x_sp_check(bp, var) ((bp->slowpath) ? (&bp->slowpath->var) : NULL)
 struct sw_rx_bd {
 	struct sk_buff	*skb;
 	DECLARE_PCI_UNMAP_ADDR(mapping)
@@ -138,6 +138,49 @@ struct sw_tx_bd {
 	u16		first_bd;
 };
 
+struct sw_rx_page {
+	struct page	*page;
+	DECLARE_PCI_UNMAP_ADDR(mapping)
+};
+
+
+/* MC hsi */
+#define BCM_PAGE_BITS			12
+#define BCM_PAGE_SIZE			(1 << BCM_PAGE_BITS)
+#define PAGES_PER_SGE_SHIFT		0
+#define PAGES_PER_SGE			(1 << PAGES_PER_SGE_SHIFT)
+
+/* SGE ring related macros */
+#define NUM_RX_SGE_PAGES		2
+#define RX_SGE_CNT		(BCM_PAGE_SIZE / sizeof(struct eth_rx_sge))
+#define MAX_RX_SGE_CNT			(RX_SGE_CNT - 2)
+/* RX_SGE_CNT is promissed to be a power of 2 */
+#define RX_SGE_MASK			(RX_SGE_CNT - 1)
+#define NUM_RX_SGE			(RX_SGE_CNT * NUM_RX_SGE_PAGES)
+#define MAX_RX_SGE			(NUM_RX_SGE - 1)
+#define NEXT_SGE_IDX(x)		((((x) & RX_SGE_MASK) == \
+				  (MAX_RX_SGE_CNT - 1)) ? (x) + 3 : (x) + 1)
+#define RX_SGE(x)			((x) & MAX_RX_SGE)
+
+/* SGE producer mask related macros */
+/* Number of bits in one sge_mask array element */
+#define RX_SGE_MASK_ELEM_SZ		64
+#define RX_SGE_MASK_ELEM_SHIFT		6
+#define RX_SGE_MASK_ELEM_MASK		((u64)RX_SGE_MASK_ELEM_SZ - 1)
+
+/* Creates a bitmask of all ones in less significant bits.
+   idx - index of the most significant bit in the created mask */
+#define RX_SGE_ONES_MASK(idx) \
+		(((u64)0x1 << (((idx) & RX_SGE_MASK_ELEM_MASK) + 1)) - 1)
+#define RX_SGE_MASK_ELEM_ONE_MASK	((u64)(~0))
+
+/* Number of u64 elements in SGE mask array */
+#define RX_SGE_MASK_LEN			((NUM_RX_SGE_PAGES * RX_SGE_CNT) / \
+					 RX_SGE_MASK_ELEM_SZ)
+#define RX_SGE_MASK_LEN_MASK		(RX_SGE_MASK_LEN - 1)
+#define NEXT_SGE_MASK_ELEM(el)		(((el) + 1) & RX_SGE_MASK_LEN_MASK)
+
+
 struct bnx2x_fastpath {
 
 	struct napi_struct	napi;
@@ -153,7 +196,8 @@ struct bnx2x_fastpath {
 	struct eth_tx_bd	*tx_desc_ring;
 	dma_addr_t		tx_desc_mapping;
 
-	struct sw_rx_bd 	*rx_buf_ring;
+	struct sw_rx_bd		*rx_buf_ring;	/* BDs mappings ring */
+	struct sw_rx_page	*rx_page_ring;	/* SGE pages mappings ring */
 
 	struct eth_rx_bd	*rx_desc_ring;
 	dma_addr_t		rx_desc_mapping;
@@ -161,6 +205,12 @@ struct bnx2x_fastpath {
 	union eth_rx_cqe	*rx_comp_ring;
 	dma_addr_t		rx_comp_mapping;
 
+	/* SGE ring */
+	struct eth_rx_sge	*rx_sge_ring;
+	dma_addr_t		rx_sge_mapping;
+
+	u64			sge_mask[RX_SGE_MASK_LEN];
+
 	int			state;
 #define BNX2X_FP_STATE_CLOSED		0
 #define BNX2X_FP_STATE_IRQ		0x80000
@@ -191,27 +241,152 @@ struct bnx2x_fastpath {
 	u16			rx_bd_cons;
 	u16			rx_comp_prod;
 	u16			rx_comp_cons;
+	u16			rx_sge_prod;
+	/* The last maximal completed SGE */
+	u16			last_max_sge;
 	u16			*rx_cons_sb;
+	u16			*rx_bd_cons_sb;
 
 	unsigned long		tx_pkt,
 				rx_pkt,
-				rx_calls;
-
-	struct bnx2x    	*bp; /* parent */
+				rx_calls,
+				rx_alloc_failed;
+	/* TPA related */
+	struct sw_rx_bd		tpa_pool[ETH_MAX_AGGREGATION_QUEUES_E1H];
+	u8			tpa_state[ETH_MAX_AGGREGATION_QUEUES_E1H];
+#define BNX2X_TPA_START			1
+#define BNX2X_TPA_STOP			2
+	u8			disable_tpa;
+
+	struct bnx2x		*bp; /* parent */
+#ifdef BNX2X_STOP_ON_ERROR
+	u64			tpa_queue_used;
+#endif
 };
 
-#define bnx2x_fp(bp, nr, var)   	(bp->fp[nr].var)
+#define bnx2x_fp(bp, nr, var)		(bp->fp[nr].var)
+
+
+/* MC hsi */
+#define MAX_FETCH_BD			13	/* HW max BDs per packet */
+#define RX_COPY_THRESH			92
+
+#define NUM_TX_RINGS			16
+#define TX_DESC_CNT		(BCM_PAGE_SIZE / sizeof(struct eth_tx_bd))
+#define MAX_TX_DESC_CNT			(TX_DESC_CNT - 1)
+#define NUM_TX_BD			(TX_DESC_CNT * NUM_TX_RINGS)
+#define MAX_TX_BD			(NUM_TX_BD - 1)
+#define MAX_TX_AVAIL			(MAX_TX_DESC_CNT * NUM_TX_RINGS - 2)
+#define NEXT_TX_IDX(x)		((((x) & MAX_TX_DESC_CNT) == \
+				  (MAX_TX_DESC_CNT - 1)) ? (x) + 2 : (x) + 1)
+#define TX_BD(x)			((x) & MAX_TX_BD)
+#define TX_BD_POFF(x)			((x) & MAX_TX_DESC_CNT)
+
+/* The RX BD ring is special, each bd is 8 bytes but the last one is 16 */
+#define NUM_RX_RINGS			8
+#define RX_DESC_CNT		(BCM_PAGE_SIZE / sizeof(struct eth_rx_bd))
+#define MAX_RX_DESC_CNT			(RX_DESC_CNT - 2)
+#define RX_DESC_MASK			(RX_DESC_CNT - 1)
+#define NUM_RX_BD			(RX_DESC_CNT * NUM_RX_RINGS)
+#define MAX_RX_BD			(NUM_RX_BD - 1)
+#define MAX_RX_AVAIL			(MAX_RX_DESC_CNT * NUM_RX_RINGS - 2)
+#define NEXT_RX_IDX(x)		((((x) & RX_DESC_MASK) == \
+				  (MAX_RX_DESC_CNT - 1)) ? (x) + 3 : (x) + 1)
+#define RX_BD(x)			((x) & MAX_RX_BD)
+
+/* As long as CQE is 4 times bigger than BD entry we have to allocate
+   4 times more pages for CQ ring in order to keep it balanced with
+   BD ring */
+#define NUM_RCQ_RINGS			(NUM_RX_RINGS * 4)
+#define RCQ_DESC_CNT		(BCM_PAGE_SIZE / sizeof(union eth_rx_cqe))
+#define MAX_RCQ_DESC_CNT		(RCQ_DESC_CNT - 1)
+#define NUM_RCQ_BD			(RCQ_DESC_CNT * NUM_RCQ_RINGS)
+#define MAX_RCQ_BD			(NUM_RCQ_BD - 1)
+#define MAX_RCQ_AVAIL			(MAX_RCQ_DESC_CNT * NUM_RCQ_RINGS - 2)
+#define NEXT_RCQ_IDX(x)		((((x) & MAX_RCQ_DESC_CNT) == \
+				  (MAX_RCQ_DESC_CNT - 1)) ? (x) + 2 : (x) + 1)
+#define RCQ_BD(x)			((x) & MAX_RCQ_BD)
+
+
 /* This is needed for determening of last_max */
 #define SUB_S16(a, b)			(s16)((s16)(a) - (s16)(b))
 
+#define __SGE_MASK_SET_BIT(el, bit) \
+	do { \
+		el = ((el) | ((u64)0x1 << (bit))); \
+	} while (0)
+
+#define __SGE_MASK_CLEAR_BIT(el, bit) \
+	do { \
+		el = ((el) & (~((u64)0x1 << (bit)))); \
+	} while (0)
+
+#define SGE_MASK_SET_BIT(fp, idx) \
+	__SGE_MASK_SET_BIT(fp->sge_mask[(idx) >> RX_SGE_MASK_ELEM_SHIFT], \
+			   ((idx) & RX_SGE_MASK_ELEM_MASK))
+
+#define SGE_MASK_CLEAR_BIT(fp, idx) \
+	__SGE_MASK_CLEAR_BIT(fp->sge_mask[(idx) >> RX_SGE_MASK_ELEM_SHIFT], \
+			     ((idx) & RX_SGE_MASK_ELEM_MASK))
+
+
+/* used on a CID received from the HW */
+#define SW_CID(x)			(le32_to_cpu(x) & \
+					 (COMMON_RAMROD_ETH_RX_CQE_CID >> 7))
+#define CQE_CMD(x)			(le32_to_cpu(x) >> \
+					COMMON_RAMROD_ETH_RX_CQE_CMD_ID_SHIFT)
+
 #define BD_UNMAP_ADDR(bd)		HILO_U64(le32_to_cpu((bd)->addr_hi), \
 						 le32_to_cpu((bd)->addr_lo))
 #define BD_UNMAP_LEN(bd)		(le16_to_cpu((bd)->nbytes))
 
+
+#define DPM_TRIGER_TYPE			0x40
+#define DOORBELL(bp, cid, val) \
+	do { \
+		writel((u32)val, (bp)->doorbells + (BCM_PAGE_SIZE * cid) + \
+		       DPM_TRIGER_TYPE); \
+	} while (0)
+
+
+/* TX CSUM helpers */
+#define SKB_CS_OFF(skb)		(offsetof(struct tcphdr, check) - \
+				 skb->csum_offset)
+#define SKB_CS(skb)		(*(u16 *)(skb_transport_header(skb) + \
+					  skb->csum_offset))
+
+#define pbd_tcp_flags(skb)	(ntohl(tcp_flag_word(tcp_hdr(skb)))>>16 & 0xff)
+
+#define XMIT_PLAIN			0
+#define XMIT_CSUM_V4			0x1
+#define XMIT_CSUM_V6			0x2
+#define XMIT_CSUM_TCP			0x4
+#define XMIT_GSO_V4			0x8
+#define XMIT_GSO_V6			0x10
+
+#define XMIT_CSUM			(XMIT_CSUM_V4 | XMIT_CSUM_V6)
+#define XMIT_GSO			(XMIT_GSO_V4 | XMIT_GSO_V6)
+
+
 /* stuff added to make the code fit 80Col */
 
 #define CQE_TYPE(cqe_fp_flags)	((cqe_fp_flags) & ETH_FAST_PATH_RX_CQE_TYPE)
 
+#define TPA_TYPE_START			ETH_FAST_PATH_RX_CQE_START_FLG
+#define TPA_TYPE_END			ETH_FAST_PATH_RX_CQE_END_FLG
+#define TPA_TYPE(cqe_fp_flags)		((cqe_fp_flags) & \
+					 (TPA_TYPE_START | TPA_TYPE_END))
+
+#define BNX2X_RX_SUM_OK(cqe) \
+			(!(cqe->fast_path_cqe.status_flags & \
+			 (ETH_FAST_PATH_RX_CQE_IP_XSUM_NO_VALIDATION_FLG | \
+			  ETH_FAST_PATH_RX_CQE_L4_XSUM_NO_VALIDATION_FLG)))
+
+#define BNX2X_RX_SUM_FIX(cqe) \
+			((le16_to_cpu(cqe->fast_path_cqe.pars_flags.flags) & \
+			  PARSING_FLAGS_OVER_ETHERNET_PROTOCOL) == \
+			 (1 << PARSING_FLAGS_OVER_ETHERNET_PROTOCOL_SHIFT))
+
 #define ETH_RX_ERROR_FALGS	(ETH_FAST_PATH_RX_CQE_PHY_DECODE_ERR_FLG | \
 				 ETH_FAST_PATH_RX_CQE_IP_BAD_XSUM_FLG | \
 				 ETH_FAST_PATH_RX_CQE_L4_BAD_XSUM_FLG)
@@ -241,6 +416,9 @@ struct bnx2x_fastpath {
 #define BNX2X_TX_SB_INDEX \
 	(&fp->status_blk->c_status_block.index_values[C_SB_ETH_TX_CQ_INDEX])
 
+
+/* end of fast path */
+
 /* common */
 
 struct bnx2x_common {
@@ -586,6 +764,7 @@ struct bnx2x {
 #define USING_DAC_FLAG			0x10
 #define USING_MSIX_FLAG			0x20
 #define ASF_ENABLE_FLAG			0x40
+#define TPA_ENABLE_FLAG			0x80
 #define NO_MCP_FLAG			0x100
 #define BP_NOMCP(bp)			(bp->flags & NO_MCP_FLAG)
 
@@ -707,74 +886,6 @@ void bnx2x_write_dmae(struct bnx2x *bp, dma_addr_t dma_addr, u32 dst_addr,
 		      u32 len32);
 int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num, u32 mode);
 
-
-/* MC hsi */
-#define RX_COPY_THRESH  		92
-#define BCM_PAGE_BITS   		12
-#define BCM_PAGE_SIZE   		(1 << BCM_PAGE_BITS)
-
-#define NUM_TX_RINGS    		16
-#define TX_DESC_CNT     	(BCM_PAGE_SIZE / sizeof(struct eth_tx_bd))
-#define MAX_TX_DESC_CNT 		(TX_DESC_CNT - 1)
-#define NUM_TX_BD       		(TX_DESC_CNT * NUM_TX_RINGS)
-#define MAX_TX_BD       		(NUM_TX_BD - 1)
-#define MAX_TX_AVAIL    		(MAX_TX_DESC_CNT * NUM_TX_RINGS - 2)
-#define NEXT_TX_IDX(x)  	((((x) & MAX_TX_DESC_CNT) == \
-				 (MAX_TX_DESC_CNT - 1)) ? (x) + 2 : (x) + 1)
-#define TX_BD(x)			((x) & MAX_TX_BD)
-#define TX_BD_POFF(x)   		((x) & MAX_TX_DESC_CNT)
-
-/* The RX BD ring is special, each bd is 8 bytes but the last one is 16 */
-#define NUM_RX_RINGS    		8
-#define RX_DESC_CNT     	(BCM_PAGE_SIZE / sizeof(struct eth_rx_bd))
-#define MAX_RX_DESC_CNT 		(RX_DESC_CNT - 2)
-#define RX_DESC_MASK    		(RX_DESC_CNT - 1)
-#define NUM_RX_BD       		(RX_DESC_CNT * NUM_RX_RINGS)
-#define MAX_RX_BD       		(NUM_RX_BD - 1)
-#define MAX_RX_AVAIL    		(MAX_RX_DESC_CNT * NUM_RX_RINGS - 2)
-#define NEXT_RX_IDX(x)  	((((x) & RX_DESC_MASK) == \
-				 (MAX_RX_DESC_CNT - 1)) ? (x) + 3 : (x) + 1)
-#define RX_BD(x)			((x) & MAX_RX_BD)
-
-#define NUM_RCQ_RINGS   		(NUM_RX_RINGS * 2)
-#define RCQ_DESC_CNT    	(BCM_PAGE_SIZE / sizeof(union eth_rx_cqe))
-#define MAX_RCQ_DESC_CNT		(RCQ_DESC_CNT - 1)
-#define NUM_RCQ_BD      		(RCQ_DESC_CNT * NUM_RCQ_RINGS)
-#define MAX_RCQ_BD      		(NUM_RCQ_BD - 1)
-#define MAX_RCQ_AVAIL   		(MAX_RCQ_DESC_CNT * NUM_RCQ_RINGS - 2)
-#define NEXT_RCQ_IDX(x) 	((((x) & MAX_RCQ_DESC_CNT) == \
-				 (MAX_RCQ_DESC_CNT - 1)) ? (x) + 2 : (x) + 1)
-#define RCQ_BD(x)       		((x) & MAX_RCQ_BD)
-
-
-/* used on a CID received from the HW */
-#define SW_CID(x)       		(le32_to_cpu(x) & \
-					 (COMMON_RAMROD_ETH_RX_CQE_CID >> 1))
-#define CQE_CMD(x)      		(le32_to_cpu(x) >> \
-					COMMON_RAMROD_ETH_RX_CQE_CMD_ID_SHIFT)
-
-#define STROM_ASSERT_ARRAY_SIZE 	50
-
-
-
-/* must be used on a CID before placing it on a HW ring */
-#define HW_CID(bp, x)		((BP_PORT(bp) << 23) | (BP_E1HVN(bp) << 17) | x)
-
-#define SP_DESC_CNT     	(BCM_PAGE_SIZE / sizeof(struct eth_spe))
-#define MAX_SP_DESC_CNT 		(SP_DESC_CNT - 1)
-
-
-#define BNX2X_BTR       		3
-#define MAX_SPQ_PENDING 		8
-
-
-#define DPM_TRIGER_TYPE 		0x40
-#define DOORBELL(bp, cid, val) \
-	do { \
-		writel((u32)val, (bp)->doorbells + (BCM_PAGE_SIZE * cid) + \
-		       DPM_TRIGER_TYPE); \
-	} while (0)
-
 static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 			   int wait)
 {
@@ -854,14 +965,20 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 #define BNX2X_LOOPBACK_FAILED		(BNX2X_MAC_LOOPBACK_FAILED | \
 					 BNX2X_PHY_LOOPBACK_FAILED)
 
-#define pbd_tcp_flags(skb)  	(ntohl(tcp_flag_word(tcp_hdr(skb)))>>16 & 0xff)
+
+#define STROM_ASSERT_ARRAY_SIZE		50
+
 
 /* must be used on a CID before placing it on a HW ring */
+#define HW_CID(bp, x)		((BP_PORT(bp) << 23) | (BP_E1HVN(bp) << 17) | x)
+
+#define SP_DESC_CNT		(BCM_PAGE_SIZE / sizeof(struct eth_spe))
+#define MAX_SP_DESC_CNT			(SP_DESC_CNT - 1)
+
+
+#define BNX2X_BTR			3
+#define MAX_SPQ_PENDING			8
 
-#define BNX2X_RX_SUM_OK(cqe) \
-			(!(cqe->fast_path_cqe.status_flags & \
-			 (ETH_FAST_PATH_RX_CQE_IP_XSUM_NO_VALIDATION_FLG | \
-			  ETH_FAST_PATH_RX_CQE_L4_XSUM_NO_VALIDATION_FLG)))
 
 /* CMNG constants
    derived from lab experiments, and not from system spec calculations !!! */
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index a382591..34f06a0 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -85,6 +85,7 @@ MODULE_VERSION(DRV_MODULE_VERSION);
 static int use_inta;
 static int poll;
 static int debug;
+static int disable_tpa;
 static int nomcp;
 static int load_count[3]; /* 0 common, 1 port0, 2 port1 */
 static int use_multi;
@@ -92,6 +93,7 @@ static int use_multi;
 module_param(use_inta, int, 0);
 module_param(poll, int, 0);
 module_param(debug, int, 0);
+module_param(disable_tpa, int, 0);
 module_param(nomcp, int, 0);
 MODULE_PARM_DESC(use_inta, "use INT#A instead of MSI-X");
 MODULE_PARM_DESC(poll, "use polling (for debug)");
@@ -441,12 +443,12 @@ static void bnx2x_panic_dump(struct bnx2x *bp)
 			  "  tx_bd_prod(%x)  tx_bd_cons(%x)  *tx_cons_sb(%x)"
 			  "  *rx_cons_sb(%x)  rx_comp_prod(%x)"
 			  "  rx_comp_cons(%x)  fp_c_idx(%x)  fp_u_idx(%x)"
-			  "  bd data(%x,%x)\n",
+			  "  bd data(%x,%x)  rx_alloc_failed(%lx)\n",
 			  i, fp->tx_pkt_prod, fp->tx_pkt_cons, fp->tx_bd_prod,
 			  fp->tx_bd_cons, *fp->tx_cons_sb, *fp->rx_cons_sb,
 			  fp->rx_comp_prod, fp->rx_comp_cons, fp->fp_c_idx,
 			  fp->fp_u_idx, hw_prods->packets_prod,
-			  hw_prods->bds_prod);
+			  hw_prods->bds_prod, fp->rx_alloc_failed);
 
 		start = TX_BD(le16_to_cpu(*fp->tx_cons_sb) - 10);
 		end = TX_BD(le16_to_cpu(*fp->tx_cons_sb) + 245);
@@ -889,6 +891,62 @@ static void bnx2x_sp_event(struct bnx2x_fastpath *fp,
 	mb(); /* force bnx2x_wait_ramrod() to see the change */
 }
 
+static inline void bnx2x_free_rx_sge(struct bnx2x *bp,
+				     struct bnx2x_fastpath *fp, u16 index)
+{
+	struct sw_rx_page *sw_buf = &fp->rx_page_ring[index];
+	struct page *page = sw_buf->page;
+	struct eth_rx_sge *sge = &fp->rx_sge_ring[index];
+
+	/* Skip "next page" elements */
+	if (!page)
+		return;
+
+	pci_unmap_page(bp->pdev, pci_unmap_addr(sw_buf, mapping),
+		       PAGE_SIZE*PAGES_PER_SGE, PCI_DMA_FROMDEVICE);
+	__free_pages(page, PAGES_PER_SGE_SHIFT);
+
+	sw_buf->page = NULL;
+	sge->addr_hi = 0;
+	sge->addr_lo = 0;
+}
+
+static inline void bnx2x_free_rx_sge_range(struct bnx2x *bp,
+					   struct bnx2x_fastpath *fp, int last)
+{
+	int i;
+
+	for (i = 0; i < last; i++)
+		bnx2x_free_rx_sge(bp, fp, i);
+}
+
+static inline int bnx2x_alloc_rx_sge(struct bnx2x *bp,
+				     struct bnx2x_fastpath *fp, u16 index)
+{
+	struct page *page = alloc_pages(GFP_ATOMIC, PAGES_PER_SGE_SHIFT);
+	struct sw_rx_page *sw_buf = &fp->rx_page_ring[index];
+	struct eth_rx_sge *sge = &fp->rx_sge_ring[index];
+	dma_addr_t mapping;
+
+	if (unlikely(page == NULL))
+		return -ENOMEM;
+
+	mapping = pci_map_page(bp->pdev, page, 0, PAGES_PER_SGE*PAGE_SIZE,
+			       PCI_DMA_FROMDEVICE);
+	if (unlikely(dma_mapping_error(mapping))) {
+		__free_pages(page, PAGES_PER_SGE_SHIFT);
+		return -ENOMEM;
+	}
+
+	sw_buf->page = page;
+	pci_unmap_addr_set(sw_buf, mapping, mapping);
+
+	sge->addr_hi = cpu_to_le32(U64_HI(mapping));
+	sge->addr_lo = cpu_to_le32(U64_LO(mapping));
+
+	return 0;
+}
+
 static inline int bnx2x_alloc_rx_skb(struct bnx2x *bp,
 				     struct bnx2x_fastpath *fp, u16 index)
 {
@@ -942,12 +1000,301 @@ static void bnx2x_reuse_rx_skb(struct bnx2x_fastpath *fp,
 	*prod_bd = *cons_bd;
 }
 
+static inline void bnx2x_update_last_max_sge(struct bnx2x_fastpath *fp,
+					     u16 idx)
+{
+	u16 last_max = fp->last_max_sge;
+
+	if (SUB_S16(idx, last_max) > 0)
+		fp->last_max_sge = idx;
+}
+
+static void bnx2x_clear_sge_mask_next_elems(struct bnx2x_fastpath *fp)
+{
+	int i, j;
+
+	for (i = 1; i <= NUM_RX_SGE_PAGES; i++) {
+		int idx = RX_SGE_CNT * i - 1;
+
+		for (j = 0; j < 2; j++) {
+			SGE_MASK_CLEAR_BIT(fp, idx);
+			idx--;
+		}
+	}
+}
+
+static void bnx2x_update_sge_prod(struct bnx2x_fastpath *fp,
+				  struct eth_fast_path_rx_cqe *fp_cqe)
+{
+	struct bnx2x *bp = fp->bp;
+	u16 sge_len = PAGE_ALIGN(le16_to_cpu(fp_cqe->pkt_len) -
+				 le16_to_cpu(fp_cqe->len_on_bd)) >> PAGE_SHIFT;
+	u16 last_max, last_elem, first_elem;
+	u16 delta = 0;
+	u16 i;
+
+	if (!sge_len)
+		return;
+
+	/* First mark all used pages*/
+	for (i = 0; i < sge_len; i++)
+		SGE_MASK_CLEAR_BIT(fp, RX_SGE(le16_to_cpu(fp_cqe->sgl[i])));
+
+	DP(BNX2X_MSG_FP, "fp_cqe->sgl[%d] = %d\n",
+	   sge_len - 1, le16_to_cpu(fp_cqe->sgl[sge_len - 1]));
+
+	/* Here we assume that the last SGE index is the biggest */
+	prefetch((void *)(fp->sge_mask));
+	bnx2x_update_last_max_sge(fp, le16_to_cpu(fp_cqe->sgl[sge_len - 1]));
+
+	last_max = RX_SGE(fp->last_max_sge);
+	last_elem = last_max >> RX_SGE_MASK_ELEM_SHIFT;
+	first_elem = RX_SGE(fp->rx_sge_prod) >> RX_SGE_MASK_ELEM_SHIFT;
+
+	/* If ring is not full */
+	if (last_elem + 1 != first_elem)
+		last_elem++;
+
+	/* Now update the prod */
+	for (i = first_elem; i != last_elem; i = NEXT_SGE_MASK_ELEM(i)) {
+		if (likely(fp->sge_mask[i]))
+			break;
+
+		fp->sge_mask[i] = RX_SGE_MASK_ELEM_ONE_MASK;
+		delta += RX_SGE_MASK_ELEM_SZ;
+	}
+
+	if (delta > 0) {
+		fp->rx_sge_prod += delta;
+		/* clear page-end entries */
+		bnx2x_clear_sge_mask_next_elems(fp);
+	}
+
+	DP(NETIF_MSG_RX_STATUS,
+	   "fp->last_max_sge = %d  fp->rx_sge_prod = %d\n",
+	   fp->last_max_sge, fp->rx_sge_prod);
+}
+
+static inline void bnx2x_init_sge_ring_bit_mask(struct bnx2x_fastpath *fp)
+{
+	/* Set the mask to all 1-s: it's faster to compare to 0 than to 0xf-s */
+	memset(fp->sge_mask, 0xff,
+	       (NUM_RX_SGE >> RX_SGE_MASK_ELEM_SHIFT)*sizeof(u64));
+
+	/* Clear the two last indeces in the page to 1:
+	   these are the indeces that correspond to the "next" element,
+	   hence will never be indicated and should be removed from
+	   the calculations. */
+	bnx2x_clear_sge_mask_next_elems(fp);
+}
+
+static void bnx2x_tpa_start(struct bnx2x_fastpath *fp, u16 queue,
+			    struct sk_buff *skb, u16 cons, u16 prod)
+{
+	struct bnx2x *bp = fp->bp;
+	struct sw_rx_bd *cons_rx_buf = &fp->rx_buf_ring[cons];
+	struct sw_rx_bd *prod_rx_buf = &fp->rx_buf_ring[prod];
+	struct eth_rx_bd *prod_bd = &fp->rx_desc_ring[prod];
+	dma_addr_t mapping;
+
+	/* move empty skb from pool to prod and map it */
+	prod_rx_buf->skb = fp->tpa_pool[queue].skb;
+	mapping = pci_map_single(bp->pdev, fp->tpa_pool[queue].skb->data,
+				 bp->rx_buf_use_size, PCI_DMA_FROMDEVICE);
+	pci_unmap_addr_set(prod_rx_buf, mapping, mapping);
+
+	/* move partial skb from cons to pool (don't unmap yet) */
+	fp->tpa_pool[queue] = *cons_rx_buf;
+
+	/* mark bin state as start - print error if current state != stop */
+	if (fp->tpa_state[queue] != BNX2X_TPA_STOP)
+		BNX2X_ERR("start of bin not in stop [%d]\n", queue);
+
+	fp->tpa_state[queue] = BNX2X_TPA_START;
+
+	/* point prod_bd to new skb */
+	prod_bd->addr_hi = cpu_to_le32(U64_HI(mapping));
+	prod_bd->addr_lo = cpu_to_le32(U64_LO(mapping));
+
+#ifdef BNX2X_STOP_ON_ERROR
+	fp->tpa_queue_used |= 1<<queue;
+	DP(NETIF_MSG_RX_STATUS, "fp->tpa_queue_used = 0x%llx\n",
+	   fp->tpa_queue_used);
+#endif
+}
+
+static int bnx2x_fill_frag_skb(struct bnx2x *bp, struct bnx2x_fastpath *fp,
+			       struct sk_buff *skb,
+			       struct eth_fast_path_rx_cqe *fp_cqe,
+			       u16 cqe_idx)
+{
+	u32 i, frag_len, frag_size, pages;
+	struct sw_rx_page *rx_pg, old_rx_pg;
+	struct page *sge;
+	int err;
+	int j;
+
+	frag_size = le16_to_cpu(fp_cqe->pkt_len) -
+		    le16_to_cpu(fp_cqe->len_on_bd);
+	pages = PAGE_ALIGN(frag_size) >> PAGE_SHIFT;
+
+#ifdef BNX2X_STOP_ON_ERROR
+	if (pages > 8*PAGES_PER_SGE) {
+		BNX2X_ERR("SGL length is too long: %d. CQE index is %d\n",
+			  pages, cqe_idx);
+		BNX2X_ERR("fp_cqe->pkt_len = %d  fp_cqe->len_on_bd = %d\n",
+			  fp_cqe->pkt_len, fp_cqe->len_on_bd);
+		bnx2x_panic();
+		return -EINVAL;
+	}
+#endif
+
+	/* Run through the SGL and compose the fragmented skb */
+	for (i = 0, j = 0; i < pages; i += PAGES_PER_SGE, j++) {
+		u16 sge_idx = RX_SGE(le16_to_cpu(fp_cqe->sgl[j]));
+
+		/* FW gives the indices of the SGE as if the ring is an array
+		   (meaning that "next" element will consume 2 indices) */
+		frag_len = min(frag_size,
+			       (unsigned int)PAGE_SIZE*PAGES_PER_SGE);
+		rx_pg = &fp->rx_page_ring[sge_idx];
+		sge = rx_pg->page;
+		old_rx_pg = *rx_pg;
+
+		/* If we fail to allocate a substitute page, we simply stop
+		   where we are and drop the whole packet */
+		err = bnx2x_alloc_rx_sge(bp, fp, sge_idx);
+		if (unlikely(err)) {
+			fp->rx_alloc_failed++;
+			return err;
+		}
+
+		/* Unmap the page as we r going to pass it to the stack */
+		pci_unmap_page(bp->pdev, pci_unmap_addr(&old_rx_pg, mapping),
+			       PAGE_SIZE*PAGES_PER_SGE, PCI_DMA_FROMDEVICE);
+
+		/* Add one frag and update the appropriate fields in the skb */
+		skb_fill_page_desc(skb, j, old_rx_pg.page, 0, frag_len);
+
+		skb->data_len += frag_len;
+		skb->truesize += frag_len;
+		skb->len += frag_len;
+
+		frag_size -= frag_len;
+	}
+
+	return 0;
+}
+
+static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
+			   u16 queue, int pad, int len, union eth_rx_cqe *cqe,
+			   u16 cqe_idx)
+{
+	struct sw_rx_bd *rx_buf = &fp->tpa_pool[queue];
+	struct sk_buff *skb = rx_buf->skb;
+	/* alloc new skb */
+	struct sk_buff *new_skb = netdev_alloc_skb(bp->dev, bp->rx_buf_size);
+
+	/* Unmap skb in the pool anyway, as we are going to change
+	   pool entry status to BNX2X_TPA_STOP even if new skb allocation
+	   fails. */
+	pci_unmap_single(bp->pdev, pci_unmap_addr(rx_buf, mapping),
+			 bp->rx_buf_use_size, PCI_DMA_FROMDEVICE);
+
+	/* if alloc failed drop the packet and keep the buffer in the bin */
+	if (likely(new_skb)) {
+
+		prefetch(skb);
+		prefetch(((char *)(skb)) + 128);
+
+		/* else fix ip xsum and give it to the stack */
+		/* (no need to map the new skb) */
+#ifdef BNX2X_STOP_ON_ERROR
+		if (pad + len > bp->rx_buf_size) {
+			BNX2X_ERR("skb_put is about to fail... "
+				  "pad %d  len %d  rx_buf_size %d\n",
+				  pad, len, bp->rx_buf_size);
+			bnx2x_panic();
+			return;
+		}
+#endif
+
+		skb_reserve(skb, pad);
+		skb_put(skb, len);
+
+		skb->protocol = eth_type_trans(skb, bp->dev);
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+
+		{
+			struct iphdr *iph;
+
+			iph = (struct iphdr *)skb->data;
+			iph->check = 0;
+			iph->check = ip_fast_csum((u8 *)iph, iph->ihl);
+		}
+
+		if (!bnx2x_fill_frag_skb(bp, fp, skb,
+					 &cqe->fast_path_cqe, cqe_idx)) {
+#ifdef BCM_VLAN
+			if ((bp->vlgrp != NULL) &&
+			    (le16_to_cpu(cqe->fast_path_cqe.pars_flags.flags) &
+			     PARSING_FLAGS_VLAN))
+				vlan_hwaccel_receive_skb(skb, bp->vlgrp,
+						le16_to_cpu(cqe->fast_path_cqe.
+							    vlan_tag));
+			else
+#endif
+				netif_receive_skb(skb);
+		} else {
+			DP(NETIF_MSG_RX_STATUS, "Failed to allocate new pages"
+			   " - dropping packet!\n");
+			dev_kfree_skb(skb);
+		}
+
+		bp->dev->last_rx = jiffies;
+
+		/* put new skb in bin */
+		fp->tpa_pool[queue].skb = new_skb;
+
+	} else {
+		DP(NETIF_MSG_RX_STATUS,
+		   "Failed to allocate new skb - dropping packet!\n");
+		fp->rx_alloc_failed++;
+	}
+
+	fp->tpa_state[queue] = BNX2X_TPA_STOP;
+}
+
+static inline void bnx2x_update_rx_prod(struct bnx2x *bp,
+					struct bnx2x_fastpath *fp,
+					u16 bd_prod, u16 rx_comp_prod,
+					u16 rx_sge_prod)
+{
+	struct tstorm_eth_rx_producers rx_prods = {0};
+	int i;
+
+	/* Update producers */
+	rx_prods.bd_prod = bd_prod;
+	rx_prods.cqe_prod = rx_comp_prod;
+	rx_prods.sge_prod = rx_sge_prod;
+
+	for (i = 0; i < sizeof(struct tstorm_eth_rx_producers)/4; i++)
+		REG_WR(bp, BAR_TSTRORM_INTMEM +
+		       TSTORM_RX_PRODS_OFFSET(BP_PORT(bp), FP_CL_ID(fp)) + i*4,
+		       ((u32 *)&rx_prods)[i]);
+
+	DP(NETIF_MSG_RX_STATUS,
+	   "Wrote: bd_prod %u  cqe_prod %u  sge_prod %u\n",
+	   bd_prod, rx_comp_prod, rx_sge_prod);
+}
+
 static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 {
 	struct bnx2x *bp = fp->bp;
 	u16 bd_cons, bd_prod, bd_prod_fw, comp_ring_cons;
 	u16 hw_comp_cons, sw_comp_cons, sw_comp_prod;
 	int rx_pkt = 0;
+	u16 queue;
 
 #ifdef BNX2X_STOP_ON_ERROR
 	if (unlikely(bp->panic))
@@ -1007,6 +1354,49 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 			len = le16_to_cpu(cqe->fast_path_cqe.pkt_len);
 			pad = cqe->fast_path_cqe.placement_offset;
 
+			/* If CQE is marked both TPA_START and TPA_END
+			   it is a non-TPA CQE */
+			if ((!fp->disable_tpa) &&
+			    (TPA_TYPE(cqe_fp_flags) !=
+					(TPA_TYPE_START | TPA_TYPE_END))) {
+				queue = cqe->fast_path_cqe.queue_index;
+
+				if (TPA_TYPE(cqe_fp_flags) == TPA_TYPE_START) {
+					DP(NETIF_MSG_RX_STATUS,
+					   "calling tpa_start on queue %d\n",
+					   queue);
+
+					bnx2x_tpa_start(fp, queue, skb,
+							bd_cons, bd_prod);
+					goto next_rx;
+				}
+
+				if (TPA_TYPE(cqe_fp_flags) == TPA_TYPE_END) {
+					DP(NETIF_MSG_RX_STATUS,
+					   "calling tpa_stop on queue %d\n",
+					   queue);
+
+					if (!BNX2X_RX_SUM_FIX(cqe))
+						BNX2X_ERR("STOP on none TCP "
+							  "data\n");
+
+					/* This is a size of the linear data
+					   on this skb */
+					len = le16_to_cpu(cqe->fast_path_cqe.
+								len_on_bd);
+					bnx2x_tpa_stop(bp, fp, queue, pad,
+						    len, cqe, comp_ring_cons);
+				#ifdef BNX2X_STOP_ON_ERROR
+					if (bp->panic)
+						return -EINVAL;
+				#endif
+
+					bnx2x_update_sge_prod(fp,
+							&cqe->fast_path_cqe);
+					goto next_cqe;
+				}
+			}
+
 			pci_dma_sync_single_for_device(bp->pdev,
 					pci_unmap_addr(rx_buf, mapping),
 						       pad + RX_COPY_THRESH,
@@ -1037,7 +1427,7 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 					DP(NETIF_MSG_RX_ERR,
 					   "ERROR  packet dropped "
 					   "because of alloc failure\n");
-					/* TBD count this as a drop? */
+					fp->rx_alloc_failed++;
 					goto reuse_rx;
 				}
 
@@ -1063,6 +1453,7 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 				DP(NETIF_MSG_RX_ERR,
 				   "ERROR  packet dropped because "
 				   "of alloc failure\n");
+				fp->rx_alloc_failed++;
 reuse_rx:
 				bnx2x_reuse_rx_skb(fp, skb, bd_cons, bd_prod);
 				goto next_rx;
@@ -1109,11 +1500,9 @@ next_cqe:
 	fp->rx_comp_cons = sw_comp_cons;
 	fp->rx_comp_prod = sw_comp_prod;
 
-	REG_WR(bp, BAR_TSTRORM_INTMEM +
-		TSTORM_RX_PRODS_OFFSET(BP_PORT(bp), FP_CL_ID(fp)),
-		sw_comp_prod);
-
-
+	/* Update producers */
+	bnx2x_update_rx_prod(bp, fp, bd_prod_fw, sw_comp_prod,
+			     fp->rx_sge_prod);
 	mmiowb(); /* keep prod updates ordered */
 
 	fp->rx_pkt += rx_pkt;
@@ -3517,6 +3906,8 @@ static void bnx2x_init_sb(struct bnx2x *bp, int sb_id,
 	REG_WR(bp, BAR_CSTRORM_INTMEM +
 	       ((CSTORM_SB_HOST_SB_ADDR_OFFSET(port, sb_id)) + 4),
 	       U64_HI(section));
+	REG_WR8(bp, BAR_CSTRORM_INTMEM + FP_CSB_FUNC_OFF +
+		CSTORM_SB_HOST_STATUS_BLOCK_OFFSET(port, sb_id), func);
 
 	for (index = 0; index < HC_CSTORM_SB_NUM_INDICES; index++)
 		REG_WR16(bp, BAR_CSTRORM_INTMEM +
@@ -3708,9 +4099,35 @@ static void bnx2x_update_coalesce(struct bnx2x *bp)
 	}
 }
 
+static inline void bnx2x_free_tpa_pool(struct bnx2x *bp,
+				       struct bnx2x_fastpath *fp, int last)
+{
+	int i;
+
+	for (i = 0; i < last; i++) {
+		struct sw_rx_bd *rx_buf = &(fp->tpa_pool[i]);
+		struct sk_buff *skb = rx_buf->skb;
+
+		if (skb == NULL) {
+			DP(NETIF_MSG_IFDOWN, "tpa bin %d empty on free\n", i);
+			continue;
+		}
+
+		if (fp->tpa_state[i] == BNX2X_TPA_START)
+			pci_unmap_single(bp->pdev,
+					 pci_unmap_addr(rx_buf, mapping),
+					 bp->rx_buf_use_size,
+					 PCI_DMA_FROMDEVICE);
+
+		dev_kfree_skb(skb);
+		rx_buf->skb = NULL;
+	}
+}
+
 static void bnx2x_init_rx_rings(struct bnx2x *bp)
 {
-	u16 ring_prod;
+	int func = BP_FUNC(bp);
+	u16 ring_prod, cqe_ring_prod = 0;
 	int i, j;
 
 	bp->rx_buf_use_size = bp->dev->mtu;
@@ -3718,12 +4135,59 @@ static void bnx2x_init_rx_rings(struct bnx2x *bp)
 	bp->rx_buf_use_size += bp->rx_offset + ETH_OVREHEAD;
 	bp->rx_buf_size = bp->rx_buf_use_size + 64;
 
+	if (bp->flags & TPA_ENABLE_FLAG) {
+		DP(NETIF_MSG_IFUP,
+		   "rx_buf_use_size %d  rx_buf_size %d  effective_mtu %d\n",
+		   bp->rx_buf_use_size, bp->rx_buf_size,
+		   bp->dev->mtu + ETH_OVREHEAD);
+
+		for_each_queue(bp, j) {
+			for (i = 0; i < ETH_MAX_AGGREGATION_QUEUES_E1H; i++) {
+				struct bnx2x_fastpath *fp = &bp->fp[j];
+
+				fp->tpa_pool[i].skb =
+				   netdev_alloc_skb(bp->dev, bp->rx_buf_size);
+				if (!fp->tpa_pool[i].skb) {
+					BNX2X_ERR("Failed to allocate TPA "
+						  "skb pool for queue[%d] - "
+						  "disabling TPA on this "
+						  "queue!\n", j);
+					bnx2x_free_tpa_pool(bp, fp, i);
+					fp->disable_tpa = 1;
+					break;
+				}
+				pci_unmap_addr_set((struct sw_rx_bd *)
+							&bp->fp->tpa_pool[i],
+						   mapping, 0);
+				fp->tpa_state[i] = BNX2X_TPA_STOP;
+			}
+		}
+	}
+
 	for_each_queue(bp, j) {
 		struct bnx2x_fastpath *fp = &bp->fp[j];
 
 		fp->rx_bd_cons = 0;
 		fp->rx_cons_sb = BNX2X_RX_SB_INDEX;
+		fp->rx_bd_cons_sb = BNX2X_RX_SB_BD_INDEX;
+
+		/* "next page" elements initialization */
+		/* SGE ring */
+		for (i = 1; i <= NUM_RX_SGE_PAGES; i++) {
+			struct eth_rx_sge *sge;
+
+			sge = &fp->rx_sge_ring[RX_SGE_CNT * i - 2];
+			sge->addr_hi =
+				cpu_to_le32(U64_HI(fp->rx_sge_mapping +
+					BCM_PAGE_SIZE*(i % NUM_RX_SGE_PAGES)));
+			sge->addr_lo =
+				cpu_to_le32(U64_LO(fp->rx_sge_mapping +
+					BCM_PAGE_SIZE*(i % NUM_RX_SGE_PAGES)));
+		}
+
+		bnx2x_init_sge_ring_bit_mask(fp);
 
+		/* RX BD ring */
 		for (i = 1; i <= NUM_RX_RINGS; i++) {
 			struct eth_rx_bd *rx_bd;
 
@@ -3750,35 +4214,61 @@ static void bnx2x_init_rx_rings(struct bnx2x *bp)
 					   BCM_PAGE_SIZE*(i % NUM_RCQ_RINGS)));
 		}
 
-		/* rx completion queue */
-		fp->rx_comp_cons = ring_prod = 0;
+		/* Allocate SGEs and initialize the ring elements */
+		for (i = 0, ring_prod = 0;
+		     i < MAX_RX_SGE_CNT*NUM_RX_SGE_PAGES; i++) {
 
+			if (bnx2x_alloc_rx_sge(bp, fp, ring_prod) < 0) {
+				BNX2X_ERR("was only able to allocate "
+					  "%d rx sges\n", i);
+				BNX2X_ERR("disabling TPA for queue[%d]\n", j);
+				/* Cleanup already allocated elements */
+				bnx2x_free_rx_sge_range(bp, fp, ring_prod);
+				bnx2x_free_tpa_pool(bp, fp,
+					      ETH_MAX_AGGREGATION_QUEUES_E1H);
+				fp->disable_tpa = 1;
+				ring_prod = 0;
+				break;
+			}
+			ring_prod = NEXT_SGE_IDX(ring_prod);
+		}
+		fp->rx_sge_prod = ring_prod;
+
+		/* Allocate BDs and initialize BD ring */
+		fp->rx_comp_cons = fp->rx_alloc_failed = 0;
+		cqe_ring_prod = ring_prod = 0;
 		for (i = 0; i < bp->rx_ring_size; i++) {
 			if (bnx2x_alloc_rx_skb(bp, fp, ring_prod) < 0) {
 				BNX2X_ERR("was only able to allocate "
 					  "%d rx skbs\n", i);
+				fp->rx_alloc_failed++;
 				break;
 			}
 			ring_prod = NEXT_RX_IDX(ring_prod);
+			cqe_ring_prod = NEXT_RCQ_IDX(cqe_ring_prod);
 			BUG_TRAP(ring_prod > i);
 		}
 
-		fp->rx_bd_prod = fp->rx_comp_prod = ring_prod;
+		fp->rx_bd_prod = ring_prod;
+		/* must not have more available CQEs than BDs */
+		fp->rx_comp_prod = min((u16)(NUM_RCQ_RINGS*RCQ_DESC_CNT),
+				       cqe_ring_prod);
 		fp->rx_pkt = fp->rx_calls = 0;
 
-		/* Warning! this will generate an interrupt (to the TSTORM) */
-		/* must only be done when chip is initialized */
-		REG_WR(bp, BAR_TSTRORM_INTMEM +
-		       TSTORM_RX_PRODS_OFFSET(BP_PORT(bp), FP_CL_ID(fp)),
-			ring_prod);
+		/* Warning!
+		 * this will generate an interrupt (to the TSTORM)
+		 * must only be done after chip is initialized
+		 */
+		bnx2x_update_rx_prod(bp, fp, ring_prod, fp->rx_comp_prod,
+				     fp->rx_sge_prod);
 		if (j != 0)
 			continue;
 
 		REG_WR(bp, BAR_USTRORM_INTMEM +
-		       USTORM_MEM_WORKAROUND_ADDRESS_OFFSET(BP_PORT(bp)),
+		       USTORM_MEM_WORKAROUND_ADDRESS_OFFSET(func),
 		       U64_LO(fp->rx_comp_mapping));
 		REG_WR(bp, BAR_USTRORM_INTMEM +
-		       USTORM_MEM_WORKAROUND_ADDRESS_OFFSET(BP_PORT(bp)) + 4,
+		       USTORM_MEM_WORKAROUND_ADDRESS_OFFSET(func) + 4,
 		       U64_HI(fp->rx_comp_mapping));
 	}
 }
@@ -3866,6 +4356,18 @@ static void bnx2x_init_context(struct bnx2x *bp)
 						U64_HI(fp->rx_desc_mapping);
 		context->ustorm_st_context.common.bd_page_base_lo =
 						U64_LO(fp->rx_desc_mapping);
+		if (!fp->disable_tpa) {
+			context->ustorm_st_context.common.flags |=
+				(USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_TPA |
+				 USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_SGE_RING);
+			context->ustorm_st_context.common.sge_buff_size =
+						(u16)(PAGES_PER_SGE*PAGE_SIZE);
+			context->ustorm_st_context.common.sge_page_base_hi =
+						U64_HI(fp->rx_sge_mapping);
+			context->ustorm_st_context.common.sge_page_base_lo =
+						U64_LO(fp->rx_sge_mapping);
+		}
+
 		context->cstorm_st_context.sb_index_number =
 						HC_INDEX_C_ETH_TX_CQ_CONS;
 		context->cstorm_st_context.status_block_id = sb_id;
@@ -3916,6 +4418,18 @@ static void bnx2x_set_client_config(struct bnx2x *bp)
 	}
 #endif
 
+	if (bp->flags & TPA_ENABLE_FLAG) {
+		tstorm_client.max_sges_for_packet =
+				PAGE_ALIGN(tstorm_client.mtu) >> PAGE_SHIFT;
+		tstorm_client.max_sges_for_packet =
+				((tstorm_client.max_sges_for_packet +
+				  PAGES_PER_SGE - 1) & (~(PAGES_PER_SGE - 1)))
+				>> PAGES_PER_SGE_SHIFT;
+
+		tstorm_client.config_flags |=
+				TSTORM_ETH_CLIENT_CONFIG_ENABLE_SGE_RING;
+	}
+
 	for_each_queue(bp, i) {
 		REG_WR(bp, BAR_TSTRORM_INTMEM +
 			TSTORM_CLIENT_CONFIG_OFFSET(port, bp->fp[i].cl_id),
@@ -4039,6 +4553,23 @@ static void bnx2x_init_internal(struct bnx2x *bp)
 	for (i = 0; i < USTORM_AGG_DATA_SIZE >> 2; i++)
 		REG_WR(bp, BAR_USTRORM_INTMEM +
 			USTORM_AGG_DATA_OFFSET + 4*i, 0);
+
+	for_each_queue(bp, i) {
+		struct bnx2x_fastpath *fp = &bp->fp[i];
+
+		REG_WR(bp, BAR_USTRORM_INTMEM +
+		       USTORM_CQE_PAGE_BASE_OFFSET(port, FP_CL_ID(fp)),
+		       U64_LO(fp->rx_comp_mapping));
+		REG_WR(bp, BAR_USTRORM_INTMEM +
+		       USTORM_CQE_PAGE_BASE_OFFSET(port, FP_CL_ID(fp)) + 4,
+		       U64_HI(fp->rx_comp_mapping));
+
+		REG_WR16(bp, BAR_USTRORM_INTMEM +
+			 USTORM_MAX_AGG_SIZE_OFFSET(port, FP_CL_ID(fp)),
+			 min((u32)(bp->rx_buf_use_size +
+				   8*PAGES_PER_SGE*PAGE_SIZE),
+			     (u32)0xffff));
+	}
 }
 
 static void bnx2x_nic_init(struct bnx2x *bp)
@@ -4697,6 +5228,17 @@ static int bnx2x_init_common(struct bnx2x *bp)
 	enable_blocks_parity(bp);
 #endif
 
+	if (bp->flags & TPA_ENABLE_FLAG) {
+		struct tstorm_eth_tpa_exist tmp = {0};
+
+		tmp.tpa_exist = 1;
+
+		REG_WR(bp, BAR_TSTRORM_INTMEM + TSTORM_TPA_EXIST_OFFSET,
+		       ((u32 *)&tmp)[0]);
+		REG_WR(bp, BAR_TSTRORM_INTMEM + TSTORM_TPA_EXIST_OFFSET + 4,
+		       ((u32 *)&tmp)[1]);
+	}
+
 	return 0;
 }
 
@@ -5074,6 +5616,11 @@ static void bnx2x_free_mem(struct bnx2x *bp)
 			       bnx2x_fp(bp, i, rx_comp_mapping),
 			       sizeof(struct eth_fast_path_rx_cqe) *
 			       NUM_RCQ_BD);
+
+		/* SGE ring */
+		BNX2X_PCI_FREE(bnx2x_fp(bp, i, rx_sge_ring),
+			       bnx2x_fp(bp, i, rx_sge_mapping),
+			       BCM_PAGE_SIZE * NUM_RX_SGE_PAGES);
 	}
 
 	/* end of fastpath */
@@ -5153,6 +5700,12 @@ static int bnx2x_alloc_mem(struct bnx2x *bp)
 				sizeof(struct eth_fast_path_rx_cqe) *
 				NUM_RCQ_BD);
 
+		/* SGE ring */
+		BNX2X_ALLOC(bnx2x_fp(bp, i, rx_page_ring),
+				sizeof(struct sw_rx_page) * NUM_RX_SGE);
+		BNX2X_PCI_ALLOC(bnx2x_fp(bp, i, rx_sge_ring),
+				&bnx2x_fp(bp, i, rx_sge_mapping),
+				BCM_PAGE_SIZE * NUM_RX_SGE_PAGES);
 	}
 	/* end of fastpath */
 
@@ -5243,6 +5796,9 @@ static void bnx2x_free_rx_skbs(struct bnx2x *bp)
 			rx_buf->skb = NULL;
 			dev_kfree_skb(skb);
 		}
+		if (!fp->disable_tpa)
+			bnx2x_free_tpa_pool(bp, fp,
+					    ETH_MAX_AGGREGATION_QUEUES_E1H);
 	}
 }
 
@@ -5596,6 +6152,10 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	if (bnx2x_alloc_mem(bp))
 		return -ENOMEM;
 
+	for_each_queue(bp, i)
+		bnx2x_fp(bp, i, disable_tpa) =
+					((bp->flags & TPA_ENABLE_FLAG) == 0);
+
 	/* Disable ISR calls until we initialize HW */
 	atomic_set(&bp->intr_sem, 1);
 
@@ -5724,6 +6284,11 @@ load_int_disable:
 	/* Release IRQs */
 	bnx2x_free_irq(bp);
 
+	/* Free SKBs, SGEs, TPA pool and driver internals */
+	bnx2x_free_skbs(bp);
+	for_each_queue(bp, i)
+		bnx2x_free_rx_sge_range(bp, bp->fp + i,
+					RX_SGE_CNT*NUM_RX_SGE_PAGES);
 load_error:
 	bnx2x_free_mem(bp);
 
@@ -5896,6 +6461,10 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 	for_each_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 
+#ifdef BNX2X_STOP_ON_ERROR
+		DP(NETIF_MSG_IFDOWN, "fp->tpa_queue_used = 0x%llx\n",
+		   fp->tpa_queue_used);
+#endif
 		cnt = 1000;
 		while (bnx2x_has_work(fp)) {
 			msleep(1);
@@ -5995,8 +6564,11 @@ unload_error:
 	if (!BP_NOMCP(bp))
 		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE);
 
-	/* Free SKBs and driver internals */
+	/* Free SKBs, SGEs, TPA pool and driver internals */
 	bnx2x_free_skbs(bp);
+	for_each_queue(bp, i)
+		bnx2x_free_rx_sge_range(bp, bp->fp + i,
+					RX_SGE_CNT*NUM_RX_SGE_PAGES);
 	bnx2x_free_mem(bp);
 
 	bp->state = BNX2X_STATE_CLOSED;
@@ -6672,6 +7244,13 @@ static int bnx2x_init_bp(struct bnx2x *bp)
 		printk(KERN_ERR PFX
 		       "MCP disabled, must load devices in order!\n");
 
+	/* Set TPA flags */
+	if (disable_tpa)
+		bp->flags &= ~TPA_ENABLE_FLAG;
+	else
+		bp->flags |= TPA_ENABLE_FLAG;
+
+
 	bp->tx_ring_size = MAX_TX_AVAIL;
 	bp->rx_ring_size = MAX_RX_AVAIL;
 
-- 
1.5.3.2




