From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH net-next 03/10] net: netcp: extract eflag from desc for rx_hook handling
Date: Tue, 20 Dec 2016 17:09:46 -0500
Message-ID: <1482271793-7671-4-git-send-email-m-karicheri2@ti.com>
References: <1482271793-7671-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <linux-omap@vger.kernel.org>,
        <grygorii.strashko@ti.com>, <mugunthanvnm@ti.com>,
        <linux-kernel@vger.kernel.org>, <arnd@arndb.de>,
        <davem@davemloft.net>, <devicetree@vger.kernel.org>,
        <mark.rutland@arm.com>, <robh+dt@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx209.ext.ti.com ([198.47.19.16]:44396 "EHLO
        fllnx209.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934309AbcLTWKC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2016 17:10:02 -0500
In-Reply-To: <1482271793-7671-1-git-send-email-m-karicheri2@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extract the eflag bits from the received desc and pass it down
the rx_hook chain to be available for netcp modules. Also the
psdata and epib data has to be inspected by the netcp modules.
So the desc can be freed only after returning from the rx_hook.
So move knav_pool_desc_put() after the rx_hook processing.

Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
---
 drivers/net/ethernet/ti/netcp.h      |  1 +
 drivers/net/ethernet/ti/netcp_core.c | 20 +++++++++++++++++---
 include/linux/soc/ti/knav_dma.h      |  2 ++
 3 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp.h b/drivers/net/ethernet/ti/netcp.h
index 0f58c58..a92abd6 100644
--- a/drivers/net/ethernet/ti/netcp.h
+++ b/drivers/net/ethernet/ti/netcp.h
@@ -115,6 +115,7 @@ struct netcp_packet {
 	struct sk_buff		*skb;
 	__le32			*epib;
 	u32			*psdata;
+	u32			eflags;
 	unsigned int		psdata_len;
 	struct netcp_intf	*netcp;
 	struct netcp_tx_pipe	*tx_pipe;
diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index c243335..a136c56 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -122,6 +122,13 @@ static void get_pkt_info(dma_addr_t *buff, u32 *buff_len, dma_addr_t *ndesc,
 	*ndesc = le32_to_cpu(desc->next_desc);
 }
 
+static void get_desc_info(u32 *desc_info, u32 *pkt_info,
+			  struct knav_dma_desc *desc)
+{
+	*desc_info = le32_to_cpu(desc->desc_info);
+	*pkt_info = le32_to_cpu(desc->packet_info);
+}
+
 static u32 get_sw_data(int index, struct knav_dma_desc *desc)
 {
 	/* No Endian conversion needed as this data is untouched by hw */
@@ -653,6 +660,7 @@ static int netcp_process_one_rx_packet(struct netcp_intf *netcp)
 	struct netcp_packet p_info;
 	struct sk_buff *skb;
 	void *org_buf_ptr;
+	u32 tmp;
 
 	dma_desc = knav_queue_pop(netcp->rx_queue, &dma_sz);
 	if (!dma_desc)
@@ -724,9 +732,6 @@ static int netcp_process_one_rx_packet(struct netcp_intf *netcp)
 		knav_pool_desc_put(netcp->rx_pool, ndesc);
 	}
 
-	/* Free the primary descriptor */
-	knav_pool_desc_put(netcp->rx_pool, desc);
-
 	/* check for packet len and warn */
 	if (unlikely(pkt_sz != accum_sz))
 		dev_dbg(netcp->ndev_dev, "mismatch in packet size(%d) & sum of fragments(%d)\n",
@@ -739,6 +744,11 @@ static int netcp_process_one_rx_packet(struct netcp_intf *netcp)
 	p_info.skb = skb;
 	skb->dev = netcp->ndev;
 	p_info.rxtstamp_complete = false;
+	get_desc_info(&tmp, &p_info.eflags, desc);
+	p_info.epib = desc->epib;
+	p_info.psdata = (u32 __force *)desc->psdata;
+	p_info.eflags = ((p_info.eflags >> KNAV_DMA_DESC_EFLAGS_SHIFT) &
+			 KNAV_DMA_DESC_EFLAGS_MASK);
 	list_for_each_entry(rx_hook, &netcp->rxhook_list_head, list) {
 		int ret;
 
@@ -748,10 +758,14 @@ static int netcp_process_one_rx_packet(struct netcp_intf *netcp)
 			dev_err(netcp->ndev_dev, "RX hook %d failed: %d\n",
 				rx_hook->order, ret);
 			netcp->ndev->stats.rx_errors++;
+			/* Free the primary descriptor */
+			knav_pool_desc_put(netcp->rx_pool, desc);
 			dev_kfree_skb(skb);
 			return 0;
 		}
 	}
+	/* Free the primary descriptor */
+	knav_pool_desc_put(netcp->rx_pool, desc);
 
 	netcp->ndev->stats.rx_packets++;
 	netcp->ndev->stats.rx_bytes += skb->len;
diff --git a/include/linux/soc/ti/knav_dma.h b/include/linux/soc/ti/knav_dma.h
index 35cb926..2b78826 100644
--- a/include/linux/soc/ti/knav_dma.h
+++ b/include/linux/soc/ti/knav_dma.h
@@ -41,6 +41,8 @@
 #define KNAV_DMA_DESC_RETQ_SHIFT		0
 #define KNAV_DMA_DESC_RETQ_MASK			MASK(14)
 #define KNAV_DMA_DESC_BUF_LEN_MASK		MASK(22)
+#define KNAV_DMA_DESC_EFLAGS_MASK		MASK(4)
+#define KNAV_DMA_DESC_EFLAGS_SHIFT		20
 
 #define KNAV_DMA_NUM_EPIB_WORDS			4
 #define KNAV_DMA_NUM_PS_WORDS			16
-- 
1.9.1
