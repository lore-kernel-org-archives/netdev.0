From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH v1 3/4] net: netcp: rename {get/set}pad_info to {get/set}_sw_data
Date: Thu, 18 Feb 2016 14:46:16 -0500
Message-ID: <1455824777-15571-3-git-send-email-m-karicheri2@ti.com>
References: <1455824777-15571-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455824777-15571-1-git-send-email-m-karicheri2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rename the helpers to match with the updated dma desc field sw_data.

Cc: Wingman Kwok <w-kwok2@ti.com>
Cc: Mugunthan V N <mugunthanvnm@ti.com>
CC: Arnd Bergmann <arnd@arndb.de>
CC: Grygorii Strashko <grygorii.strashko@ti.com>
CC: David Laight <David.Laight@ACULAB.COM>
Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
---
 v1 - new patch to based on discussion at
	https://patchwork.ozlabs.org/patch/580860/
 drivers/net/ethernet/ti/netcp_core.c | 40 +++++++++++++++++++-----------------
 1 file changed, 21 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index 0b26e52..1d07cca 100644
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
+	set_words((u32 *)&skb, 1, &desc->sw_data[0]);
 
 	if (tx_pipe->flags & SWITCH_TO_PORT_IN_TAGINFO) {
 		tmp = tx_pipe->switch_to_port;
-- 
1.9.1
