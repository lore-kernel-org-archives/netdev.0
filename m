From: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>
Subject: [PATCH] net: davinci emac: use dma_{map,
	unmap}_single API for cache coherency
Date: Tue,  9 Mar 2010 16:50:37 +0530
Message-ID: <1268133637-23399-1-git-send-email-nsekhar@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: srk-l0cyMroinI0@public.gmane.org, davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <http://linux.davincidsp.com/mailman/options/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=unsubscribe>
List-Archive: <http://linux.davincidsp.com/pipermail/davinci-linux-open-source>
List-Post: <mailto:davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Help: <mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=help>
List-Subscribe: <http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=subscribe>
Sender: davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
Errors-To: davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
List-Id: netdev.vger.kernel.org

The davinci emac driver uses some ARM specific DMA APIs
for cache coherency which have been removed from kernel
with the 2.6.34 merge.

Modify the driver to use the dma_{map, unmap}_single() APIs
defined in dma-mapping.h

Without this fix, the driver fails to compile on Linus's
tree.

Tested on DM365 and OMAP-L138 EVMs.

Signed-off-by: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>
---
Applies to latest of Linus's tree.

 drivers/net/davinci_emac.c |   45 +++++++++++++++++++++++++------------------
 1 files changed, 26 insertions(+), 19 deletions(-)

diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index 1ac9440..ef0dacf 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -29,10 +29,6 @@
  *     PHY layer usage
  */
 
-/** Pending Items in this driver:
- * 1. Use Linux cache infrastcture for DMA'ed memory (dma_xxx functions)
- */
-
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/sched.h>
@@ -504,12 +500,6 @@ static unsigned long mdio_max_freq;
 
 /* Cache macros - Packet buffers would be from skb pool which is cached */
 #define EMAC_VIRT_NOCACHE(addr) (addr)
-#define EMAC_CACHE_INVALIDATE(addr, size) \
-	dma_cache_maint((void *)addr, size, DMA_FROM_DEVICE)
-#define EMAC_CACHE_WRITEBACK(addr, size) \
-	dma_cache_maint((void *)addr, size, DMA_TO_DEVICE)
-#define EMAC_CACHE_WRITEBACK_INVALIDATE(addr, size) \
-	dma_cache_maint((void *)addr, size, DMA_BIDIRECTIONAL)
 
 /* DM644x does not have BD's in cached memory - so no cache functions */
 #define BD_CACHE_INVALIDATE(addr, size)
@@ -1235,6 +1225,10 @@ static void emac_txch_teardown(struct emac_priv *priv, u32 ch)
 	if (1 == txch->queue_active) {
 		curr_bd = txch->active_queue_head;
 		while (curr_bd != NULL) {
+			dma_unmap_single(emac_dev, curr_bd->buff_ptr,
+				curr_bd->off_b_len & EMAC_RX_BD_BUF_SIZE,
+				DMA_TO_DEVICE);
+
 			emac_net_tx_complete(priv, (void __force *)
 					&curr_bd->buf_token, 1, ch);
 			if (curr_bd != txch->active_queue_tail)
@@ -1327,6 +1321,11 @@ static int emac_tx_bdproc(struct emac_priv *priv, u32 ch, u32 budget)
 				txch->queue_active = 0; /* end of queue */
 			}
 		}
+
+		dma_unmap_single(emac_dev, curr_bd->buff_ptr,
+				curr_bd->off_b_len & EMAC_RX_BD_BUF_SIZE,
+				DMA_TO_DEVICE);
+
 		*tx_complete_ptr = (u32) curr_bd->buf_token;
 		++tx_complete_ptr;
 		++tx_complete_cnt;
@@ -1387,8 +1386,8 @@ static int emac_send(struct emac_priv *priv, struct emac_netpktobj *pkt, u32 ch)
 
 	txch->bd_pool_head = curr_bd->next;
 	curr_bd->buf_token = buf_list->buf_token;
-	/* FIXME buff_ptr = dma_map_single(... data_ptr ...) */
-	curr_bd->buff_ptr = virt_to_phys(buf_list->data_ptr);
+	curr_bd->buff_ptr = dma_map_single(&priv->ndev->dev, buf_list->data_ptr,
+			buf_list->length, DMA_TO_DEVICE);
 	curr_bd->off_b_len = buf_list->length;
 	curr_bd->h_next = 0;
 	curr_bd->next = NULL;
@@ -1468,7 +1467,6 @@ static int emac_dev_xmit(struct sk_buff *skb, struct net_device *ndev)
 	tx_buf.length = skb->len;
 	tx_buf.buf_token = (void *)skb;
 	tx_buf.data_ptr = skb->data;
-	EMAC_CACHE_WRITEBACK((unsigned long)skb->data, skb->len);
 	ndev->trans_start = jiffies;
 	ret_code = emac_send(priv, &tx_packet, EMAC_DEF_TX_CH);
 	if (unlikely(ret_code != 0)) {
@@ -1543,7 +1541,6 @@ static void *emac_net_alloc_rx_buf(struct emac_priv *priv, int buf_size,
 	p_skb->dev = ndev;
 	skb_reserve(p_skb, NET_IP_ALIGN);
 	*data_token = (void *) p_skb;
-	EMAC_CACHE_WRITEBACK_INVALIDATE((unsigned long)p_skb->data, buf_size);
 	return p_skb->data;
 }
 
@@ -1612,8 +1609,8 @@ static int emac_init_rxch(struct emac_priv *priv, u32 ch, char *param)
 		/* populate the hardware descriptor */
 		curr_bd->h_next = emac_virt_to_phys(rxch->active_queue_head,
 				priv);
-		/* FIXME buff_ptr = dma_map_single(... data_ptr ...) */
-		curr_bd->buff_ptr = virt_to_phys(curr_bd->data_ptr);
+		curr_bd->buff_ptr = dma_map_single(emac_dev, curr_bd->data_ptr,
+				rxch->buf_size, DMA_FROM_DEVICE);
 		curr_bd->off_b_len = rxch->buf_size;
 		curr_bd->mode = EMAC_CPPI_OWNERSHIP_BIT;
 
@@ -1697,6 +1694,12 @@ static void emac_cleanup_rxch(struct emac_priv *priv, u32 ch)
 		curr_bd = rxch->active_queue_head;
 		while (curr_bd) {
 			if (curr_bd->buf_token) {
+				dma_unmap_single(&priv->ndev->dev,
+					curr_bd->buff_ptr,
+					curr_bd->off_b_len
+						& EMAC_RX_BD_BUF_SIZE,
+					DMA_FROM_DEVICE);
+
 				dev_kfree_skb_any((struct sk_buff *)\
 						  curr_bd->buf_token);
 			}
@@ -1871,8 +1874,8 @@ static void emac_addbd_to_rx_queue(struct emac_priv *priv, u32 ch,
 
 	/* populate the hardware descriptor */
 	curr_bd->h_next = 0;
-	/* FIXME buff_ptr = dma_map_single(... buffer ...) */
-	curr_bd->buff_ptr = virt_to_phys(buffer);
+	curr_bd->buff_ptr = dma_map_single(&priv->ndev->dev, buffer,
+				rxch->buf_size, DMA_FROM_DEVICE);
 	curr_bd->off_b_len = rxch->buf_size;
 	curr_bd->mode = EMAC_CPPI_OWNERSHIP_BIT;
 	curr_bd->next = NULL;
@@ -1927,7 +1930,6 @@ static int emac_net_rx_cb(struct emac_priv *priv,
 	p_skb = (struct sk_buff *)net_pkt_list->pkt_token;
 	/* set length of packet */
 	skb_put(p_skb, net_pkt_list->pkt_length);
-	EMAC_CACHE_INVALIDATE((unsigned long)p_skb->data, p_skb->len);
 	p_skb->protocol = eth_type_trans(p_skb, priv->ndev);
 	netif_receive_skb(p_skb);
 	priv->net_dev_stats.rx_bytes += net_pkt_list->pkt_length;
@@ -1990,6 +1992,11 @@ static int emac_rx_bdproc(struct emac_priv *priv, u32 ch, u32 budget)
 		rx_buf_obj->data_ptr = (char *)curr_bd->data_ptr;
 		rx_buf_obj->length = curr_bd->off_b_len & EMAC_RX_BD_BUF_SIZE;
 		rx_buf_obj->buf_token = curr_bd->buf_token;
+
+		dma_unmap_single(&priv->ndev->dev, curr_bd->buff_ptr,
+				curr_bd->off_b_len & EMAC_RX_BD_BUF_SIZE,
+				DMA_FROM_DEVICE);
+
 		curr_pkt->pkt_token = curr_pkt->buf_list->buf_token;
 		curr_pkt->num_bufs = 1;
 		curr_pkt->pkt_length =
-- 
1.6.2.4
