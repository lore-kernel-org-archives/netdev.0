From: Ding Tianhong <dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 3/6] net: hip04: Solve the problem of the skb memory allocation failure
Date: Wed, 15 Apr 2015 20:30:05 +0800
Message-ID: <1429101008-9464-4-git-send-email-dingtianhong@huawei.com>
References: <1429101008-9464-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
To: <arnd-r2nGTMty4D4@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1429101008-9464-1-git-send-email-dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The driver will alloc some skb buffer for hareware queue, but without
considering the case of memory allocation failure, when memory is low,
the skb may be null and panic the system, so break the loop when skb is
null and try to alloc the memory again to fix this problem.

Signed-off-by: Ding Tianhong <dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Cc: Zhangfei Gao <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Cc: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/ethernet/hisilicon/hip04_eth.c | 68 ++++++++++++++++++++++++------
 1 file changed, 54 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hip04_eth.c b/drivers/net/ethernet/hisilicon/hip04_eth.c
index 6473462..7533858 100644
--- a/drivers/net/ethernet/hisilicon/hip04_eth.c
+++ b/drivers/net/ethernet/hisilicon/hip04_eth.c
@@ -131,6 +131,8 @@
 #define HIP04_MAX_TX_COALESCE_FRAMES	(TX_DESC_NUM - 1)
 #define HIP04_MIN_TX_COALESCE_FRAMES	1
 
+#define HIP04_RX_BUFFER_WRITE		16
+
 struct tx_desc {
 	__be32 send_addr;
 	__be32 send_size;
@@ -180,6 +182,7 @@ struct hip04_priv {
 
 	/* written only by tx cleanup */
 	unsigned int tx_tail ____cacheline_aligned_in_smp;
+	unsigned int rx_tail ____cacheline_aligned_in_smp;
 };
 
 static inline unsigned int tx_count(unsigned int head, unsigned int tail)
@@ -187,6 +190,11 @@ static inline unsigned int tx_count(unsigned int head, unsigned int tail)
 	return (head - tail) % (TX_DESC_NUM - 1);
 }
 
+static inline unsigned int rx_count(unsigned int head, unsigned int tail)
+{
+	return (head - tail) % (RX_DESC_NUM - 1);
+}
+
 static void hip04_config_port(struct net_device *ndev, u32 speed, u32 duplex)
 {
 	struct hip04_priv *priv = netdev_priv(ndev);
@@ -363,6 +371,35 @@ static int hip04_set_mac_address(struct net_device *ndev, void *addr)
 	return 0;
 }
 
+static int hip04_alloc_rx_buffers(struct net_device *ndev, int cleaned_count)
+{
+	struct hip04_priv *priv = netdev_priv(ndev);
+	unsigned char *buf;
+	dma_addr_t phys;
+	int i = priv->rx_tail;
+
+	while (cleaned_count) {
+		buf = netdev_alloc_frag(priv->rx_buf_size);
+		if (!buf)
+			break;
+
+		phys = dma_map_single(&ndev->dev, buf,
+				      RX_BUF_SIZE, DMA_FROM_DEVICE);
+		if (dma_mapping_error(&ndev->dev, phys))
+			break;
+
+		priv->rx_buf[i] = buf;
+		priv->rx_phys[i] = phys;
+		hip04_set_recv_desc(priv, phys);
+		i = RX_NEXT(i);
+		cleaned_count--;
+	}
+
+	priv->rx_tail = i;
+
+	return 0;
+}
+
 static int hip04_tx_reclaim(struct net_device *ndev, bool force)
 {
 	struct hip04_priv *priv = netdev_priv(ndev);
@@ -482,8 +519,7 @@ static int hip04_rx_poll(struct napi_struct *napi, int budget)
 	struct sk_buff *skb;
 	unsigned char *buf;
 	bool last = false;
-	dma_addr_t phys;
-	int rx = 0;
+	int rx = 0, cleaned_count = 0;
 	int tx_remaining;
 	u16 len;
 	u32 err;
@@ -491,8 +527,10 @@ static int hip04_rx_poll(struct napi_struct *napi, int budget)
 	while (cnt && !last) {
 		buf = priv->rx_buf[priv->rx_head];
 		skb = build_skb(buf, priv->rx_buf_size);
-		if (unlikely(!skb))
+		if (unlikely(!skb)) {
 			net_dbg_ratelimited("build_skb failed\n");
+			goto done;
+		}
 
 		dma_unmap_single(&ndev->dev, priv->rx_phys[priv->rx_head],
 				 RX_BUF_SIZE, DMA_FROM_DEVICE);
@@ -519,18 +557,15 @@ static int hip04_rx_poll(struct napi_struct *napi, int budget)
 			rx++;
 		}
 
-		buf = netdev_alloc_frag(priv->rx_buf_size);
-		if (!buf)
-			goto done;
-		phys = dma_map_single(&ndev->dev, buf,
-				      RX_BUF_SIZE, DMA_FROM_DEVICE);
-		if (dma_mapping_error(&ndev->dev, phys))
-			goto done;
-		priv->rx_buf[priv->rx_head] = buf;
-		priv->rx_phys[priv->rx_head] = phys;
-		hip04_set_recv_desc(priv, phys);
-
 		priv->rx_head = RX_NEXT(priv->rx_head);
+
+		cleaned_count = rx_count(priv->rx_head, priv->rx_tail);
+		/* return some buffers to hardware , one at a time is too slow */
+		if (++cleaned_count >= HIP04_RX_BUFFER_WRITE) {
+			hip04_alloc_rx_buffers(ndev, cleaned_count);
+			cleaned_count = 0;
+		}
+
 		if (rx >= budget)
 			goto done;
 
@@ -545,6 +580,10 @@ static int hip04_rx_poll(struct napi_struct *napi, int budget)
 	}
 	napi_complete(napi);
 done:
+	cleaned_count = rx_count(priv->rx_head, priv->rx_tail);
+	if (cleaned_count)
+		hip04_alloc_rx_buffers(ndev, cleaned_count);
+
 	/* clean up tx descriptors and start a new timer if necessary */
 	tx_remaining = hip04_tx_reclaim(ndev, false);
 	if (rx < budget && tx_remaining)
@@ -621,6 +660,7 @@ static int hip04_mac_open(struct net_device *ndev)
 	int i;
 
 	priv->rx_head = 0;
+	priv->rx_tail = 0;
 	priv->tx_head = 0;
 	priv->tx_tail = 0;
 	hip04_reset_ppe(priv);
-- 
1.8.0


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
