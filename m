From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH v1 4/4] net: netcp: rework the code for get/set sw_data in dma desc
Date: Thu, 18 Feb 2016 14:46:17 -0500
Message-ID: <1455824777-15571-4-git-send-email-m-karicheri2@ti.com>
References: <1455824777-15571-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455824777-15571-1-git-send-email-m-karicheri2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SW data field in descriptor can be used by software to hold private
data for the driver. As there are 4 words available for this purpose,
use separate macros to place it or retrieve the same to/from
descriptors. Also do type cast of data types accordingly.

Cc: Wingman Kwok <w-kwok2@ti.com>
Cc: Mugunthan V N <mugunthanvnm@ti.com>
CC: Arnd Bergmann <arnd@arndb.de>
CC: Grygorii Strashko <grygorii.strashko@ti.com>
CC: David Laight <David.Laight@ACULAB.COM>
Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
---
 v1 - new patch based on discussion at
      https://patchwork.ozlabs.org/patch/580860/
 drivers/net/ethernet/ti/netcp_core.c | 43 ++++++++++++++++++++++--------------
 1 file changed, 27 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index 1d07cca..8b353e4 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -117,13 +117,18 @@ static void get_pkt_info(dma_addr_t *buff, u32 *buff_len, dma_addr_t *ndesc,
 	*ndesc = le32_to_cpu(desc->next_desc);
 }
 
-static void get_sw_data(u32 *data0, u32 *data1, struct knav_dma_desc *desc)
+static u32 get_sw_data(int index, struct knav_dma_desc *desc)
 {
 	/* No Endian conversion needed as this data is untouched by hw */
-	*data0 = desc->sw_data[0];
-	*data1 = desc->sw_data[1];
+	return desc->sw_data[index];
 }
 
+/* use these macros to get sw data */
+#define GET_SW_DATA0(desc) get_sw_data(0, desc)
+#define GET_SW_DATA1(desc) get_sw_data(1, desc)
+#define GET_SW_DATA2(desc) get_sw_data(2, desc)
+#define GET_SW_DATA3(desc) get_sw_data(3, desc)
+
 static void get_org_pkt_info(dma_addr_t *buff, u32 *buff_len,
 			     struct knav_dma_desc *desc)
 {
@@ -154,13 +159,18 @@ static void set_desc_info(u32 desc_info, u32 pkt_info,
 	desc->packet_info = cpu_to_le32(pkt_info);
 }
 
-static void set_sw_data(u32 data0, u32 data1, struct knav_dma_desc *desc)
+static void set_sw_data(int index, u32 data, struct knav_dma_desc *desc)
 {
 	/* No Endian conversion needed as this data is untouched by hw */
-	desc->sw_data[0] = data0;
-	desc->sw_data[1] = data1;
+	desc->sw_data[index] = data;
 }
 
+/* use these macros to set sw data */
+#define SET_SW_DATA0(data, desc) set_sw_data(0, data, desc)
+#define SET_SW_DATA1(data, desc) set_sw_data(1, data, desc)
+#define SET_SW_DATA2(data, desc) set_sw_data(2, data, desc)
+#define SET_SW_DATA3(data, desc) set_sw_data(3, data, desc)
+
 static void set_org_pkt_info(dma_addr_t buff, u32 buff_len,
 			     struct knav_dma_desc *desc)
 {
@@ -583,12 +593,14 @@ static void netcp_free_rx_desc_chain(struct netcp_intf *netcp,
 			break;
 		}
 		get_pkt_info(&dma_buf, &tmp, &dma_desc, ndesc);
-		get_sw_data((u32 *)&buf_ptr, &buf_len, ndesc);
+		buf_ptr = (void *)GET_SW_DATA0(ndesc);
+		buf_len = (int)GET_SW_DATA1(desc);
 		dma_unmap_page(netcp->dev, dma_buf, PAGE_SIZE, DMA_FROM_DEVICE);
 		__free_page(buf_ptr);
 		knav_pool_desc_put(netcp->rx_pool, desc);
 	}
-	get_sw_data((u32 *)&buf_ptr, &buf_len, desc);
+	buf_ptr = (void *)GET_SW_DATA0(desc);
+	buf_len = (int)GET_SW_DATA1(desc);
 
 	if (buf_ptr)
 		netcp_frag_free(buf_len <= PAGE_SIZE, buf_ptr);
@@ -628,7 +640,6 @@ static int netcp_process_one_rx_packet(struct netcp_intf *netcp)
 	struct netcp_packet p_info;
 	struct sk_buff *skb;
 	void *org_buf_ptr;
-	u32 tmp;
 
 	dma_desc = knav_queue_pop(netcp->rx_queue, &dma_sz);
 	if (!dma_desc)
@@ -641,7 +652,8 @@ static int netcp_process_one_rx_packet(struct netcp_intf *netcp)
 	}
 
 	get_pkt_info(&dma_buff, &buf_len, &dma_desc, desc);
-	get_sw_data((u32 *)&org_buf_ptr, &org_buf_len, desc);
+	org_buf_ptr = (void *)GET_SW_DATA0(desc);
+	org_buf_len = (int)GET_SW_DATA1(desc);
 
 	if (unlikely(!org_buf_ptr)) {
 		dev_err(netcp->ndev_dev, "NULL bufptr in desc\n");
@@ -674,7 +686,7 @@ static int netcp_process_one_rx_packet(struct netcp_intf *netcp)
 		}
 
 		get_pkt_info(&dma_buff, &buf_len, &dma_desc, ndesc);
-		get_sw_data((u32 *)&page, &tmp, ndesc);
+		page = (struct page *)GET_SW_DATA0(desc);
 
 		if (likely(dma_buff && buf_len && page)) {
 			dma_unmap_page(netcp->dev, dma_buff, PAGE_SIZE,
@@ -752,7 +764,6 @@ static void netcp_free_rx_buf(struct netcp_intf *netcp, int fdq)
 	unsigned int buf_len, dma_sz;
 	dma_addr_t dma;
 	void *buf_ptr;
-	u32 tmp;
 
 	/* Allocate descriptor */
 	while ((dma = knav_queue_pop(netcp->rx_fdq[fdq], &dma_sz))) {
@@ -763,7 +774,7 @@ static void netcp_free_rx_buf(struct netcp_intf *netcp, int fdq)
 		}
 
 		get_org_pkt_info(&dma, &buf_len, desc);
-		get_sw_data((u32 *)&buf_ptr, &tmp, desc);
+		buf_ptr = (void *)GET_SW_DATA0(desc);
 
 		if (unlikely(!dma)) {
 			dev_err(netcp->ndev_dev, "NULL orig_buff in desc\n");
@@ -865,7 +876,8 @@ static int netcp_allocate_rx_buf(struct netcp_intf *netcp, int fdq)
 	pkt_info |= (netcp->rx_queue_id & KNAV_DMA_DESC_RETQ_MASK) <<
 		    KNAV_DMA_DESC_RETQ_SHIFT;
 	set_org_pkt_info(dma, buf_len, hwdesc);
-	set_sw_data(sw_data[0], sw_data[1], hwdesc);
+	SET_SW_DATA0(sw_data[0], hwdesc);
+	SET_SW_DATA1(sw_data[1], hwdesc);
 	set_desc_info(desc_info, pkt_info, hwdesc);
 
 	/* Push to FDQs */
@@ -958,7 +970,6 @@ static int netcp_process_tx_compl_packets(struct netcp_intf *netcp,
 	unsigned int dma_sz;
 	dma_addr_t dma;
 	int pkts = 0;
-	u32 tmp;
 
 	while (budget--) {
 		dma = knav_queue_pop(netcp->tx_compl_q, &dma_sz);
@@ -971,7 +982,7 @@ static int netcp_process_tx_compl_packets(struct netcp_intf *netcp,
 			continue;
 		}
 
-		get_sw_data((u32 *)&skb, &tmp, desc);
+		skb = (struct sk_buff *)GET_SW_DATA0(desc);
 		netcp_free_tx_desc_chain(netcp, desc, dma_sz);
 		if (!skb) {
 			dev_err(netcp->ndev_dev, "No skb in Tx desc\n");
-- 
1.9.1
