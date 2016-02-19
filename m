From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH v2 2/3] soc: ti: knav_dma: rename pad in struct knav_dma_desc to sw_data
Date: Fri, 19 Feb 2016 12:58:43 -0500
Message-ID: <1455904724-17952-3-git-send-email-m-karicheri2@ti.com>
References: <1455904724-17952-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:53752 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1428240AbcBSR6t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 12:58:49 -0500
In-Reply-To: <1455904724-17952-1-git-send-email-m-karicheri2@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename the pad to sw_data as per description of this field in the hardware
spec(refer sprugr9 from www.ti.com). Latest version of the document is
at http://www.ti.com/lit/ug/sprugr9h/sprugr9h.pdf and section 3.1
Host Packet Descriptor describes this field.

Define and use a constant for the size of sw_data field similar to
other fields in the struct for desc and document the sw_data field
in the header. As the sw_data is not touched by hw, it's type can be
changed to u32.

Rename the helpers to match with the updated dma desc field sw_data.

Cc: Wingman Kwok <w-kwok2@ti.com>
Cc: Mugunthan V N <mugunthanvnm@ti.com>
CC: Arnd Bergmann <arnd@arndb.de>
CC: Grygorii Strashko <grygorii.strashko@ti.com>
CC: David Laight <David.Laight@ACULAB.COM>
Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
---
 drivers/net/ethernet/ti/netcp_core.c | 40 +++++++++++++++++++-----------------
 include/linux/soc/ti/knav_dma.h      |  4 +++-
 2 files changed, 24 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index 0b26e52..84bab29 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -117,10 +117,11 @@ static void get_pkt_info(dma_addr_t *buff, u32 *buff_len, dma_addr_t *ndesc,
 	*ndesc = le32_to_cpu(desc->next_desc);
 }
 
-static void get_pad_info(u32 *pad0, u32 *pad1, struct knav_dma_desc *desc)
+static void get_sw_data(u32 *data0, u32 *data1, struct knav_dma_desc *desc)
 {
-	*pad0 = le32_to_cpu(desc->pad[0]);
-	*pad1 = le32_to_cpu(desc->pad[1]);
+	/* No Endian conversion needed as this data is untouched by hw */
+	*data0 = desc->sw_data[0];
+	*data1 = desc->sw_data[1];
 }
 
 static void get_org_pkt_info(dma_addr_t *buff, u32 *buff_len,
@@ -153,10 +154,11 @@ static void set_desc_info(u32 desc_info, u32 pkt_info,
 	desc->packet_info = cpu_to_le32(pkt_info);
 }
 
-static void set_pad_info(u32 pad0, u32 pad1, struct knav_dma_desc *desc)
+static void set_sw_data(u32 data0, u32 data1, struct knav_dma_desc *desc)
 {
-	desc->pad[0] = cpu_to_le32(pad0);
-	desc->pad[1] = cpu_to_le32(pad1);
+	/* No Endian conversion needed as this data is untouched by hw */
+	desc->sw_data[0] = data0;
+	desc->sw_data[1] = data1;
 }
 
 static void set_org_pkt_info(dma_addr_t buff, u32 buff_len,
@@ -581,12 +583,12 @@ static void netcp_free_rx_desc_chain(struct netcp_intf *netcp,
 			break;
 		}
 		get_pkt_info(&dma_buf, &tmp, &dma_desc, ndesc);
-		get_pad_info((u32 *)&buf_ptr, &buf_len, ndesc);
+		get_sw_data((u32 *)&buf_ptr, &buf_len, ndesc);
 		dma_unmap_page(netcp->dev, dma_buf, PAGE_SIZE, DMA_FROM_DEVICE);
 		__free_page(buf_ptr);
 		knav_pool_desc_put(netcp->rx_pool, desc);
 	}
-	get_pad_info((u32 *)&buf_ptr, &buf_len, desc);
+	get_sw_data((u32 *)&buf_ptr, &buf_len, desc);
 
 	if (buf_ptr)
 		netcp_frag_free(buf_len <= PAGE_SIZE, buf_ptr);
@@ -639,7 +641,7 @@ static int netcp_process_one_rx_packet(struct netcp_intf *netcp)
 	}
 
 	get_pkt_info(&dma_buff, &buf_len, &dma_desc, desc);
-	get_pad_info((u32 *)&org_buf_ptr, &org_buf_len, desc);
+	get_sw_data((u32 *)&org_buf_ptr, &org_buf_len, desc);
 
 	if (unlikely(!org_buf_ptr)) {
 		dev_err(netcp->ndev_dev, "NULL bufptr in desc\n");
@@ -672,7 +674,7 @@ static int netcp_process_one_rx_packet(struct netcp_intf *netcp)
 		}
 
 		get_pkt_info(&dma_buff, &buf_len, &dma_desc, ndesc);
-		get_pad_info((u32 *)&page, &tmp, ndesc);
+		get_sw_data((u32 *)&page, &tmp, ndesc);
 
 		if (likely(dma_buff && buf_len && page)) {
 			dma_unmap_page(netcp->dev, dma_buff, PAGE_SIZE,
@@ -761,7 +763,7 @@ static void netcp_free_rx_buf(struct netcp_intf *netcp, int fdq)
 		}
 
 		get_org_pkt_info(&dma, &buf_len, desc);
-		get_pad_info((u32 *)&buf_ptr, &tmp, desc);
+		get_sw_data((u32 *)&buf_ptr, &tmp, desc);
 
 		if (unlikely(!dma)) {
 			dev_err(netcp->ndev_dev, "NULL orig_buff in desc\n");
@@ -813,7 +815,7 @@ static int netcp_allocate_rx_buf(struct netcp_intf *netcp, int fdq)
 	struct page *page;
 	dma_addr_t dma;
 	void *bufptr;
-	u32 pad[2];
+	u32 sw_data[2];
 
 	/* Allocate descriptor */
 	hwdesc = knav_pool_desc_get(netcp->rx_pool);
@@ -830,7 +832,7 @@ static int netcp_allocate_rx_buf(struct netcp_intf *netcp, int fdq)
 				SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
 
 		bufptr = netdev_alloc_frag(primary_buf_len);
-		pad[1] = primary_buf_len;
+		sw_data[1] = primary_buf_len;
 
 		if (unlikely(!bufptr)) {
 			dev_warn_ratelimited(netcp->ndev_dev,
@@ -842,7 +844,7 @@ static int netcp_allocate_rx_buf(struct netcp_intf *netcp, int fdq)
 		if (unlikely(dma_mapping_error(netcp->dev, dma)))
 			goto fail;
 
-		pad[0] = (u32)bufptr;
+		sw_data[0] = (u32)bufptr;
 	} else {
 		/* Allocate a secondary receive queue entry */
 		page = alloc_page(GFP_ATOMIC | GFP_DMA | __GFP_COLD);
@@ -852,8 +854,8 @@ static int netcp_allocate_rx_buf(struct netcp_intf *netcp, int fdq)
 		}
 		buf_len = PAGE_SIZE;
 		dma = dma_map_page(netcp->dev, page, 0, buf_len, DMA_TO_DEVICE);
-		pad[0] = (u32)page;
-		pad[1] = 0;
+		sw_data[0] = (u32)page;
+		sw_data[1] = 0;
 	}
 
 	desc_info =  KNAV_DMA_DESC_PS_INFO_IN_DESC;
@@ -863,7 +865,7 @@ static int netcp_allocate_rx_buf(struct netcp_intf *netcp, int fdq)
 	pkt_info |= (netcp->rx_queue_id & KNAV_DMA_DESC_RETQ_MASK) <<
 		    KNAV_DMA_DESC_RETQ_SHIFT;
 	set_org_pkt_info(dma, buf_len, hwdesc);
-	set_pad_info(pad[0], pad[1], hwdesc);
+	set_sw_data(sw_data[0], sw_data[1], hwdesc);
 	set_desc_info(desc_info, pkt_info, hwdesc);
 
 	/* Push to FDQs */
@@ -969,7 +971,7 @@ static int netcp_process_tx_compl_packets(struct netcp_intf *netcp,
 			continue;
 		}
 
-		get_pad_info((u32 *)&skb, &tmp, desc);
+		get_sw_data((u32 *)&skb, &tmp, desc);
 		netcp_free_tx_desc_chain(netcp, desc, dma_sz);
 		if (!skb) {
 			dev_err(netcp->ndev_dev, "No skb in Tx desc\n");
@@ -1174,7 +1176,7 @@ static int netcp_tx_submit_skb(struct netcp_intf *netcp,
 	}
 
 	set_words(&tmp, 1, &desc->packet_info);
-	set_words((u32 *)&skb, 1, &desc->pad[0]);
+	set_sw_data((u32)skb, 0, desc);
 
 	if (tx_pipe->flags & SWITCH_TO_PORT_IN_TAGINFO) {
 		tmp = tx_pipe->switch_to_port;
diff --git a/include/linux/soc/ti/knav_dma.h b/include/linux/soc/ti/knav_dma.h
index 343c13a..35cb926 100644
--- a/include/linux/soc/ti/knav_dma.h
+++ b/include/linux/soc/ti/knav_dma.h
@@ -44,6 +44,7 @@
 
 #define KNAV_DMA_NUM_EPIB_WORDS			4
 #define KNAV_DMA_NUM_PS_WORDS			16
+#define KNAV_DMA_NUM_SW_DATA_WORDS		4
 #define KNAV_DMA_FDQ_PER_CHAN			4
 
 /* Tx channel scheduling priority */
@@ -142,6 +143,7 @@ struct knav_dma_cfg {
  * @orig_buff:			buff pointer since 'buff' can be overwritten
  * @epib:			Extended packet info block
  * @psdata:			Protocol specific
+ * @sw_data:			Software private data not touched by h/w
  */
 struct knav_dma_desc {
 	__le32	desc_info;
@@ -154,7 +156,7 @@ struct knav_dma_desc {
 	__le32	orig_buff;
 	__le32	epib[KNAV_DMA_NUM_EPIB_WORDS];
 	__le32	psdata[KNAV_DMA_NUM_PS_WORDS];
-	__le32	pad[4];
+	u32	sw_data[KNAV_DMA_NUM_SW_DATA_WORDS];
 } ____cacheline_aligned;
 
 #if IS_ENABLED(CONFIG_KEYSTONE_NAVIGATOR_DMA)
-- 
1.9.1
