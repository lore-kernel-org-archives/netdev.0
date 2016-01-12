From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH net-next 10/10] net: mvneta: Use the new hwbm framework
Date: Tue, 12 Jan 2016 20:10:34 +0100
Message-ID: <1452625834-22166-11-git-send-email-gregory.clement@free-electrons.com>
References: <1452625834-22166-1-git-send-email-gregory.clement@free-electrons.com>
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Marcin Wojtas <mw@semihalf.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Willy Tarreau <w@1wt.eu>, Arnd Bergmann <arnd@arndb.de>
To: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452625834-22166-1-git-send-email-gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that the hardware buffer management framework had been introduced,
let's use it.

Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c    |  44 +++++++---
 drivers/net/ethernet/marvell/mvneta_bm.c | 140 +++++++------------------------
 drivers/net/ethernet/marvell/mvneta_bm.h |  11 +--
 3 files changed, 67 insertions(+), 128 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index d82481cdbfbb..d32291c4e5aa 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -33,6 +33,7 @@
 #include <linux/phy.h>
 #include <linux/clk.h>
 #include <linux/cpu.h>
+#include <net/hwbm.h>
 #include "mvneta_bm.h"
 
 /* Registers */
@@ -1016,11 +1017,12 @@ static int mvneta_bm_port_init(struct platform_device *pdev,
 static void mvneta_bm_update_mtu(struct mvneta_port *pp, int mtu)
 {
 	struct mvneta_bm_pool *bm_pool = pp->pool_long;
+	struct hwbm_pool *hwbm_pool = &bm_pool->hwbm_pool;
 	int num;
 
 	/* Release all buffers from long pool */
 	mvneta_bm_bufs_free(pp->bm_priv, bm_pool, 1 << pp->id);
-	if (bm_pool->buf_num) {
+	if (hwbm_pool->buf_num) {
 		WARN(1, "cannot free all buffers in pool %d\n",
 		     bm_pool->id);
 		goto bm_mtu_err;
@@ -1028,14 +1030,14 @@ static void mvneta_bm_update_mtu(struct mvneta_port *pp, int mtu)
 
 	bm_pool->pkt_size = MVNETA_RX_PKT_SIZE(mtu);
 	bm_pool->buf_size = MVNETA_RX_BUF_SIZE(bm_pool->pkt_size);
-	bm_pool->frag_size = SKB_DATA_ALIGN(sizeof(struct skb_shared_info)) +
+	hwbm_pool->size = SKB_DATA_ALIGN(sizeof(struct skb_shared_info)) +
 			  SKB_DATA_ALIGN(MVNETA_RX_BUF_SIZE(bm_pool->pkt_size));
 
 	/* Fill entire long pool */
-	num = mvneta_bm_bufs_add(pp->bm_priv, bm_pool, bm_pool->size);
-	if (num != bm_pool->size) {
+	num = hwbm_pool_add(hwbm_pool, hwbm_pool->size);
+	if (num != hwbm_pool->size) {
 		WARN(1, "pool %d: %d of %d allocated\n",
-		     bm_pool->id, num, bm_pool->size);
+		     bm_pool->id, num, hwbm_pool->size);
 		goto bm_mtu_err;
 	}
 	mvneta_bm_pool_bufsize_set(pp, bm_pool->buf_size, bm_pool->id);
@@ -1715,6 +1717,14 @@ static void mvneta_txq_done(struct mvneta_port *pp,
 	}
 }
 
+void *mvneta_frag_alloc(unsigned int frag_size)
+{
+	if (likely(frag_size <= PAGE_SIZE))
+		return netdev_alloc_frag(frag_size);
+	else
+		return kmalloc(frag_size, GFP_ATOMIC);
+}
+
 /* Refill processing for SW buffer management */
 static int mvneta_rx_refill(struct mvneta_port *pp,
 			    struct mvneta_rx_desc *rx_desc)
@@ -1770,6 +1780,14 @@ static u32 mvneta_skb_tx_csum(struct mvneta_port *pp, struct sk_buff *skb)
 	return MVNETA_TX_L4_CSUM_NOT;
 }
 
+void mvneta_frag_free(unsigned int frag_size, void *data)
+{
+	if (likely(frag_size <= PAGE_SIZE))
+		skb_free_frag(data);
+	else
+		kfree(data);
+}
+
 /* Drop packets received by the RXQ and free buffers */
 static void mvneta_rxq_drop_pkts(struct mvneta_port *pp,
 				 struct mvneta_rx_queue *rxq)
@@ -1880,7 +1898,7 @@ static int mvneta_rx(struct mvneta_port *pp, int rx_todo,
 		}
 
 		/* Refill processing */
-		err = bm_in_use ? mvneta_bm_pool_refill(pp->bm_priv, bm_pool) :
+		err = bm_in_use ? hwbm_pool_refill(&bm_pool->hwbm_pool) :
 				  mvneta_rx_refill(pp, rx_desc);
 		if (err) {
 			netdev_err(dev, "Linux processing - Can't refill\n");
@@ -1888,7 +1906,8 @@ static int mvneta_rx(struct mvneta_port *pp, int rx_todo,
 			goto err_drop_frame;
 		}
 
-		frag_size = bm_in_use ? bm_pool->frag_size : pp->frag_size;
+		frag_size = bm_in_use ? bm_pool->hwbm_pool.size :
+					pp->frag_size;
 
 		skb = build_skb(data, frag_size > PAGE_SIZE ? 0 : frag_size);
 
@@ -3946,11 +3965,6 @@ static int mvneta_probe(struct platform_device *pdev)
 	dev->priv_flags |= IFF_UNICAST_FLT;
 	dev->gso_max_segs = MVNETA_MAX_TSO_SEGS;
 
-	err = register_netdev(dev);
-	if (err < 0) {
-		dev_err(&pdev->dev, "failed to register\n");
-		goto err_free_stats;
-	}
 
 	pp->id = dev->ifindex;
 
@@ -3965,6 +3979,12 @@ static int mvneta_probe(struct platform_device *pdev)
 		}
 	}
 
+	err = register_netdev(dev);
+	if (err < 0) {
+		dev_err(&pdev->dev, "failed to register\n");
+		goto err_free_stats;
+	}
+
 	err = mvneta_init(&pdev->dev, pp);
 	if (err < 0)
 		goto err_netdev;
diff --git a/drivers/net/ethernet/marvell/mvneta_bm.c b/drivers/net/ethernet/marvell/mvneta_bm.c
index ff7e73c6d31c..66a08910b5bf 100644
--- a/drivers/net/ethernet/marvell/mvneta_bm.c
+++ b/drivers/net/ethernet/marvell/mvneta_bm.c
@@ -10,16 +10,17 @@
  * warranty of any kind, whether express or implied.
  */
 
-#include <linux/kernel.h>
+#include <linux/clk.h>
 #include <linux/genalloc.h>
-#include <linux/platform_device.h>
-#include <linux/netdevice.h>
-#include <linux/skbuff.h>
+#include <linux/io.h>
+#include <linux/kernel.h>
 #include <linux/mbus.h>
 #include <linux/module.h>
-#include <linux/io.h>
+#include <linux/netdevice.h>
 #include <linux/of.h>
-#include <linux/clk.h>
+#include <linux/platform_device.h>
+#include <linux/skbuff.h>
+#include <net/hwbm.h>
 #include "mvneta_bm.h"
 
 #define MVNETA_BM_DRIVER_NAME "mvneta_bm"
@@ -88,35 +89,13 @@ static void mvneta_bm_pool_target_set(struct mvneta_bm *priv, int pool_id,
 	mvneta_bm_write(priv, MVNETA_BM_XBAR_POOL_REG(pool_id), val);
 }
 
-void *mvneta_frag_alloc(unsigned int frag_size)
-{
-	if (likely(frag_size <= PAGE_SIZE))
-		return netdev_alloc_frag(frag_size);
-	else
-		return kmalloc(frag_size, GFP_ATOMIC);
-}
-EXPORT_SYMBOL_GPL(mvneta_frag_alloc);
-
-void mvneta_frag_free(unsigned int frag_size, void *data)
+int mvneta_bm_construct(struct hwbm_pool *hwbm_pool, void *buf)
 {
-	if (likely(frag_size <= PAGE_SIZE))
-		skb_free_frag(data);
-	else
-		kfree(data);
-}
-EXPORT_SYMBOL_GPL(mvneta_frag_free);
-
-/* Allocate skb for BM pool */
-void *mvneta_buf_alloc(struct mvneta_bm *priv, struct mvneta_bm_pool *bm_pool,
-		       dma_addr_t *buf_phys_addr)
-{
-	void *buf;
+	struct mvneta_bm_pool *bm_pool =
+		(struct mvneta_bm_pool *)hwbm_pool->priv;
+	struct mvneta_bm *priv = bm_pool->priv;
 	dma_addr_t phys_addr;
 
-	buf = mvneta_frag_alloc(bm_pool->frag_size);
-	if (!buf)
-		return NULL;
-
 	/* In order to update buf_cookie field of RX descriptor properly,
 	 * BM hardware expects buf virtual address to be placed in the
 	 * first four bytes of mapped buffer.
@@ -124,74 +103,13 @@ void *mvneta_buf_alloc(struct mvneta_bm *priv, struct mvneta_bm_pool *bm_pool,
 	*(u32 *)buf = (u32)buf;
 	phys_addr = dma_map_single(&priv->pdev->dev, buf, bm_pool->buf_size,
 				   DMA_FROM_DEVICE);
-	if (unlikely(dma_mapping_error(&priv->pdev->dev, phys_addr))) {
-		mvneta_frag_free(bm_pool->frag_size, buf);
-		return NULL;
-	}
-	*buf_phys_addr = phys_addr;
-
-	return buf;
-}
-
-/* Refill processing for HW buffer management */
-int mvneta_bm_pool_refill(struct mvneta_bm *priv,
-			  struct mvneta_bm_pool *bm_pool)
-{
-	dma_addr_t buf_phys_addr;
-	void *buf;
-
-	buf = mvneta_buf_alloc(priv, bm_pool, &buf_phys_addr);
-	if (!buf)
+	if (unlikely(dma_mapping_error(&priv->pdev->dev, phys_addr)))
 		return -ENOMEM;
 
-	mvneta_bm_pool_put_bp(priv, bm_pool, buf_phys_addr);
-
+	mvneta_bm_pool_put_bp(priv, bm_pool, phys_addr);
 	return 0;
 }
-EXPORT_SYMBOL_GPL(mvneta_bm_pool_refill);
-
-/* Allocate buffers for the pool */
-int mvneta_bm_bufs_add(struct mvneta_bm *priv, struct mvneta_bm_pool *bm_pool,
-		       int buf_num)
-{
-	int err, i;
-
-	if (bm_pool->buf_num == bm_pool->size) {
-		dev_dbg(&priv->pdev->dev, "pool %d already filled\n",
-			bm_pool->id);
-		return bm_pool->buf_num;
-	}
-
-	if (buf_num < 0 ||
-	    (buf_num + bm_pool->buf_num > bm_pool->size)) {
-		dev_err(&priv->pdev->dev,
-			"cannot allocate %d buffers for pool %d\n",
-			buf_num, bm_pool->id);
-		return 0;
-	}
-
-	for (i = 0; i < buf_num; i++) {
-		err = mvneta_bm_pool_refill(priv, bm_pool);
-		if (err < 0)
-			break;
-	}
-
-	/* Update BM driver with number of buffers added to pool */
-	bm_pool->buf_num += i;
 
-	dev_dbg(&priv->pdev->dev,
-		"%s pool %d: pkt_size=%4d, buf_size=%4d, frag_size=%4d\n",
-		bm_pool->type == MVNETA_BM_SHORT ? "short" : "long",
-		bm_pool->id, bm_pool->pkt_size, bm_pool->buf_size,
-		bm_pool->frag_size);
-
-	dev_dbg(&priv->pdev->dev,
-		"%s pool %d: %d of %d buffers added\n",
-		bm_pool->type == MVNETA_BM_SHORT ? "short" : "long",
-		bm_pool->id, i, buf_num);
-
-	return i;
-}
 
 /* Create pool */
 static int mvneta_bm_pool_create(struct mvneta_bm *priv,
@@ -200,8 +118,7 @@ static int mvneta_bm_pool_create(struct mvneta_bm *priv,
 	struct platform_device *pdev = priv->pdev;
 	u8 target_id, attr;
 	int size_bytes, err;
-
-	size_bytes = sizeof(u32) * bm_pool->size;
+	size_bytes = sizeof(u32) * bm_pool->hwbm_pool.size;
 	bm_pool->virt_addr = dma_alloc_coherent(&pdev->dev, size_bytes,
 						&bm_pool->phys_addr,
 						GFP_KERNEL);
@@ -262,11 +179,16 @@ struct mvneta_bm_pool *mvneta_bm_pool_use(struct mvneta_bm *priv, u8 pool_id,
 
 	/* Allocate buffers in case BM pool hasn't been used yet */
 	if (new_pool->type == MVNETA_BM_FREE) {
+		struct hwbm_pool *hwbm_pool = &new_pool->hwbm_pool;
+
+		new_pool->priv = priv;
 		new_pool->type = type;
 		new_pool->buf_size = MVNETA_RX_BUF_SIZE(new_pool->pkt_size);
-		new_pool->frag_size =
+		hwbm_pool->size =
 			SKB_DATA_ALIGN(MVNETA_RX_BUF_SIZE(new_pool->pkt_size)) +
 			SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+		hwbm_pool->construct = mvneta_bm_construct;
+		hwbm_pool->priv = new_pool;
 
 		/* Create new pool */
 		err = mvneta_bm_pool_create(priv, new_pool);
@@ -277,10 +199,10 @@ struct mvneta_bm_pool *mvneta_bm_pool_use(struct mvneta_bm *priv, u8 pool_id,
 		}
 
 		/* Allocate buffers for this pool */
-		num = mvneta_bm_bufs_add(priv, new_pool, new_pool->size);
-		if (num != new_pool->size) {
+		num = hwbm_pool_add(hwbm_pool, hwbm_pool->size);
+		if (num != hwbm_pool->size) {
 			WARN(1, "pool %d: %d of %d allocated\n",
-			     new_pool->id, num, new_pool->size);
+			     new_pool->id, num, hwbm_pool->size);
 			return NULL;
 		}
 	}
@@ -301,7 +223,7 @@ void mvneta_bm_bufs_free(struct mvneta_bm *priv, struct mvneta_bm_pool *bm_pool,
 
 	mvneta_bm_config_set(priv, MVNETA_BM_EMPTY_LIMIT_MASK);
 
-	for (i = 0; i < bm_pool->buf_num; i++) {
+	for (i = 0; i < bm_pool->hwbm_pool.buf_num; i++) {
 		dma_addr_t buf_phys_addr;
 		u32 *vaddr;
 
@@ -320,19 +242,20 @@ void mvneta_bm_bufs_free(struct mvneta_bm *priv, struct mvneta_bm_pool *bm_pool,
 
 		dma_unmap_single(&priv->pdev->dev, buf_phys_addr,
 				 bm_pool->buf_size, DMA_FROM_DEVICE);
-		mvneta_frag_free(bm_pool->frag_size, vaddr);
+		hwbm_buf_free(&bm_pool->hwbm_pool, vaddr);
 	}
 
 	mvneta_bm_config_clear(priv, MVNETA_BM_EMPTY_LIMIT_MASK);
 
 	/* Update BM driver with number of buffers removed from pool */
-	bm_pool->buf_num -= i;
+	bm_pool->hwbm_pool.buf_num -= i;
 }
 
 /* Cleanup pool */
 void mvneta_bm_pool_destroy(struct mvneta_bm *priv,
 			    struct mvneta_bm_pool *bm_pool, u8 port_map)
 {
+	struct hwbm_pool *hwbm_pool = &bm_pool->hwbm_pool;
 	bm_pool->port_map &= ~port_map;
 	if (bm_pool->port_map)
 		return;
@@ -340,11 +263,12 @@ void mvneta_bm_pool_destroy(struct mvneta_bm *priv,
 	bm_pool->type = MVNETA_BM_FREE;
 
 	mvneta_bm_bufs_free(priv, bm_pool, port_map);
-	if (bm_pool->buf_num)
+	if (hwbm_pool->buf_num)
 		WARN(1, "cannot free all buffers in pool %d\n", bm_pool->id);
 
 	if (bm_pool->virt_addr) {
-		dma_free_coherent(&priv->pdev->dev, sizeof(u32) * bm_pool->size,
+		dma_free_coherent(&priv->pdev->dev,
+				  sizeof(u32) * hwbm_pool->size,
 				  bm_pool->virt_addr, bm_pool->phys_addr);
 		bm_pool->virt_addr = NULL;
 	}
@@ -397,10 +321,10 @@ static void mvneta_bm_pools_init(struct mvneta_bm *priv)
 				 MVNETA_BM_POOL_CAP_ALIGN));
 			size = ALIGN(size, MVNETA_BM_POOL_CAP_ALIGN);
 		}
-		bm_pool->size = size;
+		bm_pool->hwbm_pool.size = size;
 
 		mvneta_bm_write(priv, MVNETA_BM_POOL_SIZE_REG(i),
-				bm_pool->size);
+				bm_pool->hwbm_pool.size);
 
 		/* Obtain custom pkt_size from DT */
 		sprintf(prop, "pool%d,pkt-size", i);
diff --git a/drivers/net/ethernet/marvell/mvneta_bm.h b/drivers/net/ethernet/marvell/mvneta_bm.h
index f2449b843577..ea08736d8cb4 100644
--- a/drivers/net/ethernet/marvell/mvneta_bm.h
+++ b/drivers/net/ethernet/marvell/mvneta_bm.h
@@ -108,20 +108,15 @@ struct mvneta_bm {
 };
 
 struct mvneta_bm_pool {
+	struct hwbm_pool hwbm_pool;
 	/* Pool number in the range 0-3 */
 	u8 id;
 	enum mvneta_bm_type type;
 
-	/* Buffer Pointers Pool External (BPPE) size in number of bytes */
-	int size;
-	/* Number of buffers used by this pool */
-	int buf_num;
-	/* Pool buffer size */
-	int buf_size;
 	/* Packet size */
 	int pkt_size;
-	/* Single frag size */
-	u32 frag_size;
+	/* Size of the buffer acces through DMA*/
+	u32 buf_size;
 
 	/* BPPE virtual base address */
 	u32 *virt_addr;
-- 
2.5.0
