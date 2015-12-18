From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] netcp: fix regression in receive processing
Date: Fri, 18 Dec 2015 15:18:08 +0100
Message-ID: <1651314.QiL8XMyoqS@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: w-kwok2@ti.com, netdev@vger.kernel.org, m-karicheri2@ti.com,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

A cleanup patch I did was unfortunately wrong and introduced
multiple serious bugs in the netcp rx processing, as indicated
by these correct gcc warnings:

drivers/net/ethernet/ti/netcp_core.c:776:14: warning: 'buf_ptr' may be used uninitialized in this function [-Wuninitialized]
drivers/net/ethernet/ti/netcp_core.c:687:14: warning: 'ptr' may be used uninitialized in this function [-Wuninitialized]

I have checked the patch once more and found that a call to
get_pkt_info() accidentally got removed in netcp_free_rx_desc_chain,
and netcp_process_one_rx_packet no longer retrieved the correct
buffer length. This patch should fix all the known problems,
but I did not test on real hardware.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 899077791403 ("netcp: try to reduce type confusion in descriptors")

diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index 92d08eb262c2..c61d66d38634 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -582,6 +582,7 @@ static void netcp_free_rx_desc_chain(struct netcp_intf *netcp,
 	unsigned int buf_len, dma_sz = sizeof(*ndesc);
 	void *buf_ptr;
 	u32 pad[2];
+	u32 tmp;
 
 	get_words(&dma_desc, 1, &desc->next_desc);
 
@@ -591,6 +592,7 @@ static void netcp_free_rx_desc_chain(struct netcp_intf *netcp,
 			dev_err(netcp->ndev_dev, "failed to unmap Rx desc\n");
 			break;
 		}
+		get_pkt_info(&dma_buf, &tmp, &dma_desc, ndesc);
 		get_pad_ptr(&buf_ptr, ndesc);
 		dma_unmap_page(netcp->dev, dma_buf, PAGE_SIZE, DMA_FROM_DEVICE);
 		__free_page(buf_ptr);
@@ -637,6 +639,7 @@ static int netcp_process_one_rx_packet(struct netcp_intf *netcp)
 	dma_addr_t dma_desc, dma_buff;
 	struct netcp_packet p_info;
 	struct sk_buff *skb;
+	u32 pad[2];
 	void *org_buf_ptr;
 
 	dma_desc = knav_queue_pop(netcp->rx_queue, &dma_sz);
@@ -650,7 +653,8 @@ static int netcp_process_one_rx_packet(struct netcp_intf *netcp)
 	}
 
 	get_pkt_info(&dma_buff, &buf_len, &dma_desc, desc);
-	get_pad_ptr(&org_buf_ptr, desc);
+	get_pad_info(&pad[0], &pad[1], &org_buf_len, desc);
+	org_buf_ptr = (void *)(uintptr_t)(pad[0] + ((u64)pad[1] << 32));
 
 	if (unlikely(!org_buf_ptr)) {
 		dev_err(netcp->ndev_dev, "NULL bufptr in desc\n");
@@ -684,7 +688,7 @@ static int netcp_process_one_rx_packet(struct netcp_intf *netcp)
 		}
 
 		get_pkt_info(&dma_buff, &buf_len, &dma_desc, ndesc);
-		get_pad_ptr(ptr, ndesc);
+		get_pad_ptr(&ptr, ndesc);
 		page = ptr;
 
 		if (likely(dma_buff && buf_len && page)) {
@@ -773,7 +777,7 @@ static void netcp_free_rx_buf(struct netcp_intf *netcp, int fdq)
 		}
 
 		get_org_pkt_info(&dma, &buf_len, desc);
-		get_pad_ptr(buf_ptr, desc);
+		get_pad_ptr(&buf_ptr, desc);
 
 		if (unlikely(!dma)) {
 			dev_err(netcp->ndev_dev, "NULL orig_buff in desc\n");
