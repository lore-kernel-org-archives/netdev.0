From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 1/2] netcp: try to reduce type confusion in descriptors
Date: Tue, 08 Dec 2015 16:32:27 +0100
Message-ID: <1578620.t1ANcREMZ8@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Wingman Kwok <w-kwok2@ti.com>,
	Murali Karicheri <m-karicheri2@ti.com>,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The netcp driver produces tons of warnings when CONFIG_LPAE is enabled
on ARM:

drivers/net/ethernet/ti/netcp_core.c: In function 'netcp_tx_map_skb':
drivers/net/ethernet/ti/netcp_core.c:1084:13: warning: passing argument 1 of 'set_words' from incompatible pointer type [-Wincompatible-pointer-types]

This is the result of trying to pass a pointer to a dma_addr_t to
a function that expects a u32 pointer to copy that into a DMA descriptor.

Looking at that code in more detail to fix the warnings, I see multiple
related problems:

* The conversion functions are not endian-safe, as the DMA descriptors
  are almost certainly fixed-endian, but the CPU is not.

* On 64-bit machines, passing a pointer through a u32 variable is a
  bug, accessing an indirect pointer as a u32 pointer even more so.

* The handling of epib and psdata mixes native-endian and device-endian
  data.

In this patch, I try to sort out the types for most accesses here,
adding le32_to_cpu/cpu_to_le32 where appropriate, and passing pointers
through two 32-bit words in the descriptor padding, to make it plausible
that the driver does the right thing if compiled for big-endian or
64-bit systems.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/ti/netcp_core.c | 123 ++++++++++++++++++++---------------
 include/linux/soc/ti/knav_dma.h      |  22 +++----
 2 files changed, 82 insertions(+), 63 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index e5e20e734f21..eb2585e777e1 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -109,69 +109,80 @@ module_param(netcp_debug_level, int, 0);
 MODULE_PARM_DESC(netcp_debug_level, "Netcp debug level (NETIF_MSG bits) (0=none,...,16=all)");
 
 /* Helper functions - Get/Set */
-static void get_pkt_info(u32 *buff, u32 *buff_len, u32 *ndesc,
+static void get_pkt_info(dma_addr_t *buff, u32 *buff_len, dma_addr_t *ndesc,
 			 struct knav_dma_desc *desc)
 {
-	*buff_len = desc->buff_len;
-	*buff = desc->buff;
-	*ndesc = desc->next_desc;
+	*buff_len = le32_to_cpu(desc->buff_len);
+	*buff = le32_to_cpu(desc->buff);
+	*ndesc = le32_to_cpu(desc->next_desc);
 }
 
-static void get_pad_info(u32 *pad0, u32 *pad1, struct knav_dma_desc *desc)
+static void get_pad_info(u32 *pad0, u32 *pad1, u32 *pad2, struct knav_dma_desc *desc)
 {
-	*pad0 = desc->pad[0];
-	*pad1 = desc->pad[1];
+	*pad0 = le32_to_cpu(desc->pad[0]);
+	*pad1 = le32_to_cpu(desc->pad[1]);
+	*pad2 = le32_to_cpu(desc->pad[2]);
 }
 
-static void get_org_pkt_info(u32 *buff, u32 *buff_len,
+static void get_pad_ptr(void **padptr, struct knav_dma_desc *desc)
+{
+	u64 pad64;
+
+	pad64 = le32_to_cpu(desc->pad[0]) +
+		((u64)le32_to_cpu(desc->pad[1]) << 32);
+	*padptr = (void *)(uintptr_t)pad64;
+}
+
+static void get_org_pkt_info(dma_addr_t *buff, u32 *buff_len,
 			     struct knav_dma_desc *desc)
 {
-	*buff = desc->orig_buff;
-	*buff_len = desc->orig_len;
+	*buff = le32_to_cpu(desc->orig_buff);
+	*buff_len = le32_to_cpu(desc->orig_len);
 }
 
-static void get_words(u32 *words, int num_words, u32 *desc)
+static void get_words(dma_addr_t *words, int num_words, __le32 *desc)
 {
 	int i;
 
 	for (i = 0; i < num_words; i++)
-		words[i] = desc[i];
+		words[i] = le32_to_cpu(desc[i]);
 }
 
-static void set_pkt_info(u32 buff, u32 buff_len, u32 ndesc,
+static void set_pkt_info(dma_addr_t buff, u32 buff_len, u32 ndesc,
 			 struct knav_dma_desc *desc)
 {
-	desc->buff_len = buff_len;
-	desc->buff = buff;
-	desc->next_desc = ndesc;
+	desc->buff_len = cpu_to_le32(buff_len);
+	desc->buff = cpu_to_le32(buff);
+	desc->next_desc = cpu_to_le32(ndesc);
 }
 
 static void set_desc_info(u32 desc_info, u32 pkt_info,
 			  struct knav_dma_desc *desc)
 {
-	desc->desc_info = desc_info;
-	desc->packet_info = pkt_info;
+	desc->desc_info = cpu_to_le32(desc_info);
+	desc->packet_info = cpu_to_le32(pkt_info);
 }
 
-static void set_pad_info(u32 pad0, u32 pad1, struct knav_dma_desc *desc)
+static void set_pad_info(u32 pad0, u32 pad1, u32 pad2, struct knav_dma_desc *desc)
 {
-	desc->pad[0] = pad0;
-	desc->pad[1] = pad1;
+	desc->pad[0] = cpu_to_le32(pad0);
+	desc->pad[1] = cpu_to_le32(pad1);
+	desc->pad[2] = cpu_to_le32(pad1);
 }
 
-static void set_org_pkt_info(u32 buff, u32 buff_len,
+static void set_org_pkt_info(dma_addr_t buff, u32 buff_len,
 			     struct knav_dma_desc *desc)
 {
-	desc->orig_buff = buff;
-	desc->orig_len = buff_len;
+	desc->orig_buff = cpu_to_le32(buff);
+	desc->orig_len = cpu_to_le32(buff_len);
 }
 
-static void set_words(u32 *words, int num_words, u32 *desc)
+static void set_words(u32 *words, int num_words, __le32 *desc)
 {
 	int i;
 
 	for (i = 0; i < num_words; i++)
-		desc[i] = words[i];
+		desc[i] = cpu_to_le32(words[i]);
 }
 
 /* Read the e-fuse value as 32 bit values to be endian independent */
@@ -570,7 +581,7 @@ static void netcp_free_rx_desc_chain(struct netcp_intf *netcp,
 	dma_addr_t dma_desc, dma_buf;
 	unsigned int buf_len, dma_sz = sizeof(*ndesc);
 	void *buf_ptr;
-	u32 tmp;
+	u32 pad[2];
 
 	get_words(&dma_desc, 1, &desc->next_desc);
 
@@ -580,14 +591,15 @@ static void netcp_free_rx_desc_chain(struct netcp_intf *netcp,
 			dev_err(netcp->ndev_dev, "failed to unmap Rx desc\n");
 			break;
 		}
-		get_pkt_info(&dma_buf, &tmp, &dma_desc, ndesc);
-		get_pad_info((u32 *)&buf_ptr, &tmp, ndesc);
+		get_pad_ptr(&buf_ptr, ndesc);
 		dma_unmap_page(netcp->dev, dma_buf, PAGE_SIZE, DMA_FROM_DEVICE);
 		__free_page(buf_ptr);
 		knav_pool_desc_put(netcp->rx_pool, desc);
 	}
 
-	get_pad_info((u32 *)&buf_ptr, &buf_len, desc);
+	get_pad_info(&pad[0], &pad[1], &buf_len, desc);
+	buf_ptr = (void *)(uintptr_t)(pad[0] + ((u64)pad[1] << 32));
+
 	if (buf_ptr)
 		netcp_frag_free(buf_len <= PAGE_SIZE, buf_ptr);
 	knav_pool_desc_put(netcp->rx_pool, desc);
@@ -626,7 +638,6 @@ static int netcp_process_one_rx_packet(struct netcp_intf *netcp)
 	struct netcp_packet p_info;
 	struct sk_buff *skb;
 	void *org_buf_ptr;
-	u32 tmp;
 
 	dma_desc = knav_queue_pop(netcp->rx_queue, &dma_sz);
 	if (!dma_desc)
@@ -639,7 +650,7 @@ static int netcp_process_one_rx_packet(struct netcp_intf *netcp)
 	}
 
 	get_pkt_info(&dma_buff, &buf_len, &dma_desc, desc);
-	get_pad_info((u32 *)&org_buf_ptr, &org_buf_len, desc);
+	get_pad_ptr(&org_buf_ptr, desc);
 
 	if (unlikely(!org_buf_ptr)) {
 		dev_err(netcp->ndev_dev, "NULL bufptr in desc\n");
@@ -664,6 +675,7 @@ static int netcp_process_one_rx_packet(struct netcp_intf *netcp)
 	/* Fill in the page fragment list */
 	while (dma_desc) {
 		struct page *page;
+		void *ptr;
 
 		ndesc = knav_pool_desc_unmap(netcp->rx_pool, dma_desc, dma_sz);
 		if (unlikely(!ndesc)) {
@@ -672,14 +684,15 @@ static int netcp_process_one_rx_packet(struct netcp_intf *netcp)
 		}
 
 		get_pkt_info(&dma_buff, &buf_len, &dma_desc, ndesc);
-		get_pad_info((u32 *)&page, &tmp, ndesc);
+		get_pad_ptr(ptr, ndesc);
+		page = ptr;
 
 		if (likely(dma_buff && buf_len && page)) {
 			dma_unmap_page(netcp->dev, dma_buff, PAGE_SIZE,
 				       DMA_FROM_DEVICE);
 		} else {
-			dev_err(netcp->ndev_dev, "Bad Rx desc dma_buff(%p), len(%d), page(%p)\n",
-				(void *)dma_buff, buf_len, page);
+			dev_err(netcp->ndev_dev, "Bad Rx desc dma_buff(%pad), len(%d), page(%p)\n",
+				&dma_buff, buf_len, page);
 			goto free_desc;
 		}
 
@@ -750,7 +763,6 @@ static void netcp_free_rx_buf(struct netcp_intf *netcp, int fdq)
 	unsigned int buf_len, dma_sz;
 	dma_addr_t dma;
 	void *buf_ptr;
-	u32 tmp;
 
 	/* Allocate descriptor */
 	while ((dma = knav_queue_pop(netcp->rx_fdq[fdq], &dma_sz))) {
@@ -761,7 +773,7 @@ static void netcp_free_rx_buf(struct netcp_intf *netcp, int fdq)
 		}
 
 		get_org_pkt_info(&dma, &buf_len, desc);
-		get_pad_info((u32 *)&buf_ptr, &tmp, desc);
+		get_pad_ptr(buf_ptr, desc);
 
 		if (unlikely(!dma)) {
 			dev_err(netcp->ndev_dev, "NULL orig_buff in desc\n");
@@ -813,7 +825,7 @@ static int netcp_allocate_rx_buf(struct netcp_intf *netcp, int fdq)
 	struct page *page;
 	dma_addr_t dma;
 	void *bufptr;
-	u32 pad[2];
+	u32 pad[3];
 
 	/* Allocate descriptor */
 	hwdesc = knav_pool_desc_get(netcp->rx_pool);
@@ -830,7 +842,7 @@ static int netcp_allocate_rx_buf(struct netcp_intf *netcp, int fdq)
 				SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
 
 		bufptr = netdev_alloc_frag(primary_buf_len);
-		pad[1] = primary_buf_len;
+		pad[2] = primary_buf_len;
 
 		if (unlikely(!bufptr)) {
 			dev_warn_ratelimited(netcp->ndev_dev,
@@ -842,7 +854,8 @@ static int netcp_allocate_rx_buf(struct netcp_intf *netcp, int fdq)
 		if (unlikely(dma_mapping_error(netcp->dev, dma)))
 			goto fail;
 
-		pad[0] = (u32)bufptr;
+		pad[0] = lower_32_bits((uintptr_t)bufptr);
+		pad[1] = upper_32_bits((uintptr_t)bufptr);
 
 	} else {
 		/* Allocate a secondary receive queue entry */
@@ -853,8 +866,9 @@ static int netcp_allocate_rx_buf(struct netcp_intf *netcp, int fdq)
 		}
 		buf_len = PAGE_SIZE;
 		dma = dma_map_page(netcp->dev, page, 0, buf_len, DMA_TO_DEVICE);
-		pad[0] = (u32)page;
-		pad[1] = 0;
+		pad[0] = lower_32_bits(dma);
+		pad[1] = upper_32_bits(dma);
+		pad[2] = 0;
 	}
 
 	desc_info =  KNAV_DMA_DESC_PS_INFO_IN_DESC;
@@ -864,7 +878,7 @@ static int netcp_allocate_rx_buf(struct netcp_intf *netcp, int fdq)
 	pkt_info |= (netcp->rx_queue_id & KNAV_DMA_DESC_RETQ_MASK) <<
 		    KNAV_DMA_DESC_RETQ_SHIFT;
 	set_org_pkt_info(dma, buf_len, hwdesc);
-	set_pad_info(pad[0], pad[1], hwdesc);
+	set_pad_info(pad[0], pad[1], pad[2], hwdesc);
 	set_desc_info(desc_info, pkt_info, hwdesc);
 
 	/* Push to FDQs */
@@ -935,8 +949,8 @@ static void netcp_free_tx_desc_chain(struct netcp_intf *netcp,
 			dma_unmap_single(netcp->dev, dma_buf, buf_len,
 					 DMA_TO_DEVICE);
 		else
-			dev_warn(netcp->ndev_dev, "bad Tx desc buf(%p), len(%d)\n",
-				 (void *)dma_buf, buf_len);
+			dev_warn(netcp->ndev_dev, "bad Tx desc buf(%pad), len(%d)\n",
+				 &dma_buf, buf_len);
 
 		knav_pool_desc_put(netcp->tx_pool, ndesc);
 		ndesc = NULL;
@@ -953,11 +967,11 @@ static int netcp_process_tx_compl_packets(struct netcp_intf *netcp,
 					  unsigned int budget)
 {
 	struct knav_dma_desc *desc;
+	void *ptr;
 	struct sk_buff *skb;
 	unsigned int dma_sz;
 	dma_addr_t dma;
 	int pkts = 0;
-	u32 tmp;
 
 	while (budget--) {
 		dma = knav_queue_pop(netcp->tx_compl_q, &dma_sz);
@@ -970,7 +984,8 @@ static int netcp_process_tx_compl_packets(struct netcp_intf *netcp,
 			continue;
 		}
 
-		get_pad_info((u32 *)&skb, &tmp, desc);
+		get_pad_ptr(&ptr, desc);
+		skb = ptr;
 		netcp_free_tx_desc_chain(netcp, desc, dma_sz);
 		if (!skb) {
 			dev_err(netcp->ndev_dev, "No skb in Tx desc\n");
@@ -1059,6 +1074,7 @@ netcp_tx_map_skb(struct sk_buff *skb, struct netcp_intf *netcp)
 		u32 page_offset = frag->page_offset;
 		u32 buf_len = skb_frag_size(frag);
 		dma_addr_t desc_dma;
+		u32 desc_dma_32;
 		u32 pkt_info;
 
 		dma_addr = dma_map_page(dev, page, page_offset, buf_len,
@@ -1075,13 +1091,13 @@ netcp_tx_map_skb(struct sk_buff *skb, struct netcp_intf *netcp)
 			goto free_descs;
 		}
 
-		desc_dma = knav_pool_desc_virt_to_dma(netcp->tx_pool,
-						      (void *)ndesc);
+		desc_dma = knav_pool_desc_virt_to_dma(netcp->tx_pool, ndesc);
 		pkt_info =
 			(netcp->tx_compl_qid & KNAV_DMA_DESC_RETQ_MASK) <<
 				KNAV_DMA_DESC_RETQ_SHIFT;
 		set_pkt_info(dma_addr, buf_len, 0, ndesc);
-		set_words(&desc_dma, 1, &pdesc->next_desc);
+		desc_dma_32 = (u32)desc_dma;
+		set_words(&desc_dma_32, 1, &pdesc->next_desc);
 		pkt_len += buf_len;
 		if (pdesc != desc)
 			knav_pool_desc_map(netcp->tx_pool, pdesc,
@@ -1173,11 +1189,14 @@ static int netcp_tx_submit_skb(struct netcp_intf *netcp,
 	}
 
 	set_words(&tmp, 1, &desc->packet_info);
-	set_words((u32 *)&skb, 1, &desc->pad[0]);
+	tmp = lower_32_bits((uintptr_t)&skb);
+	set_words(&tmp, 1, &desc->pad[0]);
+	tmp = upper_32_bits((uintptr_t)&skb);
+	set_words(&tmp, 1, &desc->pad[1]);
 
 	if (tx_pipe->flags & SWITCH_TO_PORT_IN_TAGINFO) {
 		tmp = tx_pipe->switch_to_port;
-		set_words((u32 *)&tmp, 1, &desc->tag_info);
+		set_words(&tmp, 1, &desc->tag_info);
 	}
 
 	/* submit packet descriptor */
diff --git a/include/linux/soc/ti/knav_dma.h b/include/linux/soc/ti/knav_dma.h
index dad035c16d94..343c13ac4f71 100644
--- a/include/linux/soc/ti/knav_dma.h
+++ b/include/linux/soc/ti/knav_dma.h
@@ -144,17 +144,17 @@ struct knav_dma_cfg {
  * @psdata:			Protocol specific
  */
 struct knav_dma_desc {
-	u32	desc_info;
-	u32	tag_info;
-	u32	packet_info;
-	u32	buff_len;
-	u32	buff;
-	u32	next_desc;
-	u32	orig_len;
-	u32	orig_buff;
-	u32	epib[KNAV_DMA_NUM_EPIB_WORDS];
-	u32	psdata[KNAV_DMA_NUM_PS_WORDS];
-	u32	pad[4];
+	__le32	desc_info;
+	__le32	tag_info;
+	__le32	packet_info;
+	__le32	buff_len;
+	__le32	buff;
+	__le32	next_desc;
+	__le32	orig_len;
+	__le32	orig_buff;
+	__le32	epib[KNAV_DMA_NUM_EPIB_WORDS];
+	__le32	psdata[KNAV_DMA_NUM_PS_WORDS];
+	__le32	pad[4];
 } ____cacheline_aligned;
 
 #if IS_ENABLED(CONFIG_KEYSTONE_NAVIGATOR_DMA)
-- 
2.1.0.rc2
