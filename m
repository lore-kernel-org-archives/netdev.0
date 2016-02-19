From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH v2 1/3] net: ti: netcp: restore get/set_pad_info() functionality
Date: Fri, 19 Feb 2016 12:58:42 -0500
Message-ID: <1455904724-17952-2-git-send-email-m-karicheri2@ti.com>
References: <1455904724-17952-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455904724-17952-1-git-send-email-m-karicheri2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The commit 899077791403 ("netcp: try to reduce type confusion in
descriptors") introduces a regression in Kernel 4.5-rc1 and it breaks
get/set_pad_info() functionality.

The TI NETCP driver uses pad0 and pad1 fields of knav_dma_desc to
store DMA/MEM buffer pointer and buffer size respectively. And in both
cases for Keystone 2 the pointer type size is 32 bit regardless of
LAPE enabled or not, because CONFIG_ARCH_DMA_ADDR_T_64BIT originally
is not expected to be defined.

Unfortunately, above commit changed buffer's pointers save/restore
code (get/set_pad_info()) and added intermediate conversation to u64
which works incorrectly on 32bit Keystone 2 and causes TI NETCP driver
crash in RX/TX path due to "Unable to handle kernel NULL pointer"
exception. This issue was reported and discussed in [1].

Hence, fix it by partially reverting above commit and restoring
get/set_pad_info() functionality as it was before.

[1] https://www.mail-archive.com/netdev@vger.kernel.org/msg95361.html
Cc: Wingman Kwok <w-kwok2@ti.com>
Cc: Mugunthan V N <mugunthanvnm@ti.com>
CC: David Laight <David.Laight@ACULAB.COM>
CC: Arnd Bergmann <arnd@arndb.de>
Reported-by: Franklin S Cooper Jr <fcooper@ti.com>
Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
---
 drivers/net/ethernet/ti/netcp_core.c | 59 +++++++++++-------------------------
 1 file changed, 18 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index c61d66d..0b26e52 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -117,20 +117,10 @@ static void get_pkt_info(dma_addr_t *buff, u32 *buff_len, dma_addr_t *ndesc,
 	*ndesc = le32_to_cpu(desc->next_desc);
 }
 
-static void get_pad_info(u32 *pad0, u32 *pad1, u32 *pad2, struct knav_dma_desc *desc)
+static void get_pad_info(u32 *pad0, u32 *pad1, struct knav_dma_desc *desc)
 {
 	*pad0 = le32_to_cpu(desc->pad[0]);
 	*pad1 = le32_to_cpu(desc->pad[1]);
-	*pad2 = le32_to_cpu(desc->pad[2]);
-}
-
-static void get_pad_ptr(void **padptr, struct knav_dma_desc *desc)
-{
-	u64 pad64;
-
-	pad64 = le32_to_cpu(desc->pad[0]) +
-		((u64)le32_to_cpu(desc->pad[1]) << 32);
-	*padptr = (void *)(uintptr_t)pad64;
 }
 
 static void get_org_pkt_info(dma_addr_t *buff, u32 *buff_len,
@@ -163,11 +153,10 @@ static void set_desc_info(u32 desc_info, u32 pkt_info,
 	desc->packet_info = cpu_to_le32(pkt_info);
 }
 
-static void set_pad_info(u32 pad0, u32 pad1, u32 pad2, struct knav_dma_desc *desc)
+static void set_pad_info(u32 pad0, u32 pad1, struct knav_dma_desc *desc)
 {
 	desc->pad[0] = cpu_to_le32(pad0);
 	desc->pad[1] = cpu_to_le32(pad1);
-	desc->pad[2] = cpu_to_le32(pad1);
 }
 
 static void set_org_pkt_info(dma_addr_t buff, u32 buff_len,
@@ -581,7 +570,6 @@ static void netcp_free_rx_desc_chain(struct netcp_intf *netcp,
 	dma_addr_t dma_desc, dma_buf;
 	unsigned int buf_len, dma_sz = sizeof(*ndesc);
 	void *buf_ptr;
-	u32 pad[2];
 	u32 tmp;
 
 	get_words(&dma_desc, 1, &desc->next_desc);
@@ -593,14 +581,12 @@ static void netcp_free_rx_desc_chain(struct netcp_intf *netcp,
 			break;
 		}
 		get_pkt_info(&dma_buf, &tmp, &dma_desc, ndesc);
-		get_pad_ptr(&buf_ptr, ndesc);
+		get_pad_info((u32 *)&buf_ptr, &buf_len, ndesc);
 		dma_unmap_page(netcp->dev, dma_buf, PAGE_SIZE, DMA_FROM_DEVICE);
 		__free_page(buf_ptr);
 		knav_pool_desc_put(netcp->rx_pool, desc);
 	}
-
-	get_pad_info(&pad[0], &pad[1], &buf_len, desc);
-	buf_ptr = (void *)(uintptr_t)(pad[0] + ((u64)pad[1] << 32));
+	get_pad_info((u32 *)&buf_ptr, &buf_len, desc);
 
 	if (buf_ptr)
 		netcp_frag_free(buf_len <= PAGE_SIZE, buf_ptr);
@@ -639,8 +625,8 @@ static int netcp_process_one_rx_packet(struct netcp_intf *netcp)
 	dma_addr_t dma_desc, dma_buff;
 	struct netcp_packet p_info;
 	struct sk_buff *skb;
-	u32 pad[2];
 	void *org_buf_ptr;
+	u32 tmp;
 
 	dma_desc = knav_queue_pop(netcp->rx_queue, &dma_sz);
 	if (!dma_desc)
@@ -653,8 +639,7 @@ static int netcp_process_one_rx_packet(struct netcp_intf *netcp)
 	}
 
 	get_pkt_info(&dma_buff, &buf_len, &dma_desc, desc);
-	get_pad_info(&pad[0], &pad[1], &org_buf_len, desc);
-	org_buf_ptr = (void *)(uintptr_t)(pad[0] + ((u64)pad[1] << 32));
+	get_pad_info((u32 *)&org_buf_ptr, &org_buf_len, desc);
 
 	if (unlikely(!org_buf_ptr)) {
 		dev_err(netcp->ndev_dev, "NULL bufptr in desc\n");
@@ -679,7 +664,6 @@ static int netcp_process_one_rx_packet(struct netcp_intf *netcp)
 	/* Fill in the page fragment list */
 	while (dma_desc) {
 		struct page *page;
-		void *ptr;
 
 		ndesc = knav_pool_desc_unmap(netcp->rx_pool, dma_desc, dma_sz);
 		if (unlikely(!ndesc)) {
@@ -688,8 +672,7 @@ static int netcp_process_one_rx_packet(struct netcp_intf *netcp)
 		}
 
 		get_pkt_info(&dma_buff, &buf_len, &dma_desc, ndesc);
-		get_pad_ptr(&ptr, ndesc);
-		page = ptr;
+		get_pad_info((u32 *)&page, &tmp, ndesc);
 
 		if (likely(dma_buff && buf_len && page)) {
 			dma_unmap_page(netcp->dev, dma_buff, PAGE_SIZE,
@@ -767,6 +750,7 @@ static void netcp_free_rx_buf(struct netcp_intf *netcp, int fdq)
 	unsigned int buf_len, dma_sz;
 	dma_addr_t dma;
 	void *buf_ptr;
+	u32 tmp;
 
 	/* Allocate descriptor */
 	while ((dma = knav_queue_pop(netcp->rx_fdq[fdq], &dma_sz))) {
@@ -777,7 +761,7 @@ static void netcp_free_rx_buf(struct netcp_intf *netcp, int fdq)
 		}
 
 		get_org_pkt_info(&dma, &buf_len, desc);
-		get_pad_ptr(&buf_ptr, desc);
+		get_pad_info((u32 *)&buf_ptr, &tmp, desc);
 
 		if (unlikely(!dma)) {
 			dev_err(netcp->ndev_dev, "NULL orig_buff in desc\n");
@@ -829,7 +813,7 @@ static int netcp_allocate_rx_buf(struct netcp_intf *netcp, int fdq)
 	struct page *page;
 	dma_addr_t dma;
 	void *bufptr;
-	u32 pad[3];
+	u32 pad[2];
 
 	/* Allocate descriptor */
 	hwdesc = knav_pool_desc_get(netcp->rx_pool);
@@ -846,7 +830,7 @@ static int netcp_allocate_rx_buf(struct netcp_intf *netcp, int fdq)
 				SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
 
 		bufptr = netdev_alloc_frag(primary_buf_len);
-		pad[2] = primary_buf_len;
+		pad[1] = primary_buf_len;
 
 		if (unlikely(!bufptr)) {
 			dev_warn_ratelimited(netcp->ndev_dev,
@@ -858,9 +842,7 @@ static int netcp_allocate_rx_buf(struct netcp_intf *netcp, int fdq)
 		if (unlikely(dma_mapping_error(netcp->dev, dma)))
 			goto fail;
 
-		pad[0] = lower_32_bits((uintptr_t)bufptr);
-		pad[1] = upper_32_bits((uintptr_t)bufptr);
-
+		pad[0] = (u32)bufptr;
 	} else {
 		/* Allocate a secondary receive queue entry */
 		page = alloc_page(GFP_ATOMIC | GFP_DMA | __GFP_COLD);
@@ -870,9 +852,8 @@ static int netcp_allocate_rx_buf(struct netcp_intf *netcp, int fdq)
 		}
 		buf_len = PAGE_SIZE;
 		dma = dma_map_page(netcp->dev, page, 0, buf_len, DMA_TO_DEVICE);
-		pad[0] = lower_32_bits(dma);
-		pad[1] = upper_32_bits(dma);
-		pad[2] = 0;
+		pad[0] = (u32)page;
+		pad[1] = 0;
 	}
 
 	desc_info =  KNAV_DMA_DESC_PS_INFO_IN_DESC;
@@ -882,7 +863,7 @@ static int netcp_allocate_rx_buf(struct netcp_intf *netcp, int fdq)
 	pkt_info |= (netcp->rx_queue_id & KNAV_DMA_DESC_RETQ_MASK) <<
 		    KNAV_DMA_DESC_RETQ_SHIFT;
 	set_org_pkt_info(dma, buf_len, hwdesc);
-	set_pad_info(pad[0], pad[1], pad[2], hwdesc);
+	set_pad_info(pad[0], pad[1], hwdesc);
 	set_desc_info(desc_info, pkt_info, hwdesc);
 
 	/* Push to FDQs */
@@ -971,11 +952,11 @@ static int netcp_process_tx_compl_packets(struct netcp_intf *netcp,
 					  unsigned int budget)
 {
 	struct knav_dma_desc *desc;
-	void *ptr;
 	struct sk_buff *skb;
 	unsigned int dma_sz;
 	dma_addr_t dma;
 	int pkts = 0;
+	u32 tmp;
 
 	while (budget--) {
 		dma = knav_queue_pop(netcp->tx_compl_q, &dma_sz);
@@ -988,8 +969,7 @@ static int netcp_process_tx_compl_packets(struct netcp_intf *netcp,
 			continue;
 		}
 
-		get_pad_ptr(&ptr, desc);
-		skb = ptr;
+		get_pad_info((u32 *)&skb, &tmp, desc);
 		netcp_free_tx_desc_chain(netcp, desc, dma_sz);
 		if (!skb) {
 			dev_err(netcp->ndev_dev, "No skb in Tx desc\n");
@@ -1194,10 +1174,7 @@ static int netcp_tx_submit_skb(struct netcp_intf *netcp,
 	}
 
 	set_words(&tmp, 1, &desc->packet_info);
-	tmp = lower_32_bits((uintptr_t)&skb);
-	set_words(&tmp, 1, &desc->pad[0]);
-	tmp = upper_32_bits((uintptr_t)&skb);
-	set_words(&tmp, 1, &desc->pad[1]);
+	set_words((u32 *)&skb, 1, &desc->pad[0]);
 
 	if (tx_pipe->flags & SWITCH_TO_PORT_IN_TAGINFO) {
 		tmp = tx_pipe->switch_to_port;
-- 
1.9.1
