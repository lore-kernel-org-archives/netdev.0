From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH net-next 17/27] net: mvpp2: adjust the allocation/free of BM pools for PPv2.2
Date: Wed, 21 Dec 2016 12:16:24 +0100
Message-ID: <1482318994-23488-18-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1482318994-23488-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Nadav Haklai <nadavh@marvell.com>, Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Stefan Chulski <stefanc@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:56108 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750745AbcLULQo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 06:16:44 -0500
In-Reply-To: <1482318994-23488-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit adjusts the allocation and freeing of BM pools to support
PPv2.2. This involves:

 - Checking that the number of buffer pointers is a multiple of 16, as
   required by the hardware.

 - Adjusting the size of the DMA coherent area allocated for buffer
   pointers. Indeed, PPv2.2 needs space for 2 pointers of 64-bits per
   buffer, as opposed to 2 pointers of 32-bits per buffer in
   PPv2.1. The size in bytes is now stored in a new field of the
   mvpp2_bm_pool structure.

 - On PPv2.2, the 32 high order bits of the BM pointer area physical
   address must be programmed in the MVPP2_BM_HIGH_BASE_REG register.

 - On PPv2.2, getting the physical and virtual address of each buffer
   requires reading the MVPP2_BM_ADDR_HIGH_ALLOC to get the high order
   bits of those addresses. A new utility function
   mvpp2_bm_bufs_get_addrs() is introduced to handle this.

 - On PPv2.2, releasing a buffer requires writing the high order 32 bits
   of the physical address to MVPP2_BM_PHY_VIRT_HIGH_RLS_REG. We no
   longer need to write the virtual address to MVPP2_BM_VIRT_RLS_REG.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 97 ++++++++++++++++++++++++++++++------
 1 file changed, 82 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 41d7bed..772c384 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -208,17 +208,28 @@
 #define     MVPP2_BM_BPPE_FULL_MASK		BIT(3)
 #define     MVPP2_BM_AVAILABLE_BP_LOW_MASK	BIT(4)
 #define MVPP2_BM_INTR_MASK_REG(pool)		(0x6280 + ((pool) * 4))
+#define MVPP2_BM_HIGH_BASE_REG			0x6310
+#define     MVPP2_BM_HIGH_BASE_MASK		0xff
 #define MVPP2_BM_PHY_ALLOC_REG(pool)		(0x6400 + ((pool) * 4))
 #define     MVPP2_BM_PHY_ALLOC_GRNTD_MASK	BIT(0)
 #define MVPP2_BM_VIRT_ALLOC_REG			0x6440
+#define MVPP2_BM_ADDR_HIGH_ALLOC		0x6444
+#define     MVPP2_BM_ADDR_HIGH_PHYS_MASK	0xff
+#define     MVPP2_BM_ADDR_HIGH_VIRT_MASK	0xff00
+#define     MVPP2_BM_ADDR_HIGH_VIRT_SHIFT	8
 #define MVPP2_BM_PHY_RLS_REG(pool)		(0x6480 + ((pool) * 4))
 #define     MVPP2_BM_PHY_RLS_MC_BUFF_MASK	BIT(0)
 #define     MVPP2_BM_PHY_RLS_PRIO_EN_MASK	BIT(1)
 #define     MVPP2_BM_PHY_RLS_GRNTD_MASK		BIT(2)
 #define MVPP2_BM_VIRT_RLS_REG			0x64c0
-#define MVPP2_BM_MC_RLS_REG			0x64c4
+#define MVPP21_BM_MC_RLS_REG			0x64c4
 #define     MVPP2_BM_MC_ID_MASK			0xfff
 #define     MVPP2_BM_FORCE_RELEASE_MASK		BIT(12)
+#define MVPP22_BM_ADDR_HIGH_RLS_REG		0x64c4
+#define     MVPP22_BM_ADDR_HIGH_PHYS_RLS_MASK	0xff
+#define	    MVPP22_BM_ADDR_HIGH_VIRT_RLS_MASK	0xff00
+#define     MVPP22_BM_ADDR_HIGH_VIRT_RLS_SHIFT	8
+#define MVPP22_BM_MC_RLS_REG			0x64d4
 
 /* TX Scheduler registers */
 #define MVPP2_TXP_SCHED_PORT_INDEX_REG		0x8000
@@ -957,6 +968,8 @@ struct mvpp2_bm_pool {
 
 	/* Buffer Pointers Pool External (BPPE) size */
 	int size;
+	/* BPPE size in bytes */
+	int size_bytes;
 	/* Number of buffers for this pool */
 	int buf_num;
 	/* Pool buffer size */
@@ -3558,11 +3571,23 @@ static int mvpp2_bm_pool_create(struct platform_device *pdev,
 				struct mvpp2 *priv,
 				struct mvpp2_bm_pool *bm_pool, int size)
 {
-	int size_bytes;
 	u32 val;
 
-	size_bytes = sizeof(u32) * size;
-	bm_pool->virt_addr = dma_alloc_coherent(&pdev->dev, size_bytes,
+	/* Number of buffer pointers must be a multiple of 16, as per
+	 * hardware constraints
+	 */
+	if (!IS_ALIGNED(size, 16))
+		return -EINVAL;
+
+	/* PPv2.1 needs 8 bytes per buffer pointer, PPv2.2 needs 16
+	 * bytes per buffer pointer
+	 */
+	if (priv->ip_version == MVPP21)
+		bm_pool->size_bytes = 2 * sizeof(u32) * size;
+	else
+		bm_pool->size_bytes = 2 * sizeof(u64) * size;
+
+	bm_pool->virt_addr = dma_alloc_coherent(&pdev->dev, bm_pool->size_bytes,
 						&bm_pool->phys_addr,
 						GFP_KERNEL);
 	if (!bm_pool->virt_addr)
@@ -3570,15 +3595,24 @@ static int mvpp2_bm_pool_create(struct platform_device *pdev,
 
 	if (!IS_ALIGNED((unsigned long)bm_pool->virt_addr,
 			MVPP2_BM_POOL_PTR_ALIGN)) {
-		dma_free_coherent(&pdev->dev, size_bytes, bm_pool->virt_addr,
-				  bm_pool->phys_addr);
+		dma_free_coherent(&pdev->dev, bm_pool->size_bytes,
+				  bm_pool->virt_addr, bm_pool->phys_addr);
 		dev_err(&pdev->dev, "BM pool %d is not %d bytes aligned\n",
 			bm_pool->id, MVPP2_BM_POOL_PTR_ALIGN);
 		return -ENOMEM;
 	}
 
 	mvpp2_write(priv, MVPP2_BM_POOL_BASE_REG(bm_pool->id),
-		    bm_pool->phys_addr);
+		    lower_32_bits(bm_pool->phys_addr));
+	/* On PPv2.2, program the high order bits of the base address */
+	if (priv->ip_version == MVPP22) {
+		if (sizeof(dma_addr_t) == 8)
+			val = upper_32_bits(bm_pool->phys_addr) &
+				MVPP2_BM_HIGH_BASE_MASK;
+		else
+			val = 0;
+		mvpp2_write(priv, MVPP2_BM_HIGH_BASE_REG, val);
+	}
 	mvpp2_write(priv, MVPP2_BM_POOL_SIZE_REG(bm_pool->id), size);
 
 	val = mvpp2_read(priv, MVPP2_BM_POOL_CTRL_REG(bm_pool->id));
@@ -3606,6 +3640,27 @@ static void mvpp2_bm_pool_bufsize_set(struct mvpp2 *priv,
 	mvpp2_write(priv, MVPP2_POOL_BUF_SIZE_REG(bm_pool->id), val);
 }
 
+static void mvpp2_bm_bufs_get_addrs(struct device *dev, struct mvpp2 *priv,
+				    struct mvpp2_bm_pool *bm_pool,
+				    dma_addr_t *paddr, unsigned long *vaddr)
+{
+	*paddr = mvpp2_read(priv, MVPP2_BM_PHY_ALLOC_REG(bm_pool->id));
+	*vaddr = mvpp2_read(priv, MVPP2_BM_VIRT_ALLOC_REG);
+
+#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
+	if (priv->ip_version == MVPP22) {
+		u32 val;
+		u32 paddr_highbits;
+
+		val = mvpp2_read(priv, MVPP2_BM_ADDR_HIGH_ALLOC);
+		paddr_highbits = (val & MVPP2_BM_ADDR_HIGH_PHYS_MASK);
+
+		*paddr |= (dma_addr_t)paddr_highbits << 32;
+		*vaddr = (unsigned long)phys_to_virt(dma_to_phys(dev, *paddr));
+	}
+#endif
+}
+
 /* Free all buffers from the pool */
 static void mvpp2_bm_bufs_free(struct device *dev, struct mvpp2 *priv,
 			       struct mvpp2_bm_pool *bm_pool)
@@ -3616,10 +3671,8 @@ static void mvpp2_bm_bufs_free(struct device *dev, struct mvpp2 *priv,
 		dma_addr_t buf_phys_addr;
 		unsigned long vaddr;
 
-		/* Get buffer virtual address (indirect access) */
-		buf_phys_addr = mvpp2_read(priv,
-					   MVPP2_BM_PHY_ALLOC_REG(bm_pool->id));
-		vaddr = mvpp2_read(priv, MVPP2_BM_VIRT_ALLOC_REG);
+		mvpp2_bm_bufs_get_addrs(dev, priv, bm_pool,
+					&buf_phys_addr, &vaddr);
 
 		dma_unmap_single(dev, buf_phys_addr,
 				 bm_pool->buf_size, DMA_FROM_DEVICE);
@@ -3651,7 +3704,7 @@ static int mvpp2_bm_pool_destroy(struct platform_device *pdev,
 	val |= MVPP2_BM_STOP_MASK;
 	mvpp2_write(priv, MVPP2_BM_POOL_CTRL_REG(bm_pool->id), val);
 
-	dma_free_coherent(&pdev->dev, sizeof(u32) * bm_pool->size,
+	dma_free_coherent(&pdev->dev, bm_pool->size_bytes,
 			  bm_pool->virt_addr,
 			  bm_pool->phys_addr);
 	return 0;
@@ -3787,8 +3840,19 @@ static inline void mvpp2_bm_pool_put(struct mvpp2_port *port, int pool,
 				     dma_addr_t buf_phys_addr,
 				     unsigned long buf_virt_addr)
 {
-	mvpp2_write(port->priv, MVPP2_BM_VIRT_RLS_REG, buf_virt_addr);
-	mvpp2_write(port->priv, MVPP2_BM_PHY_RLS_REG(pool), buf_phys_addr);
+#if defined(CONFIG_ARCH_DMA_ADDR_T_64BIT)
+	u32 val;
+
+	val = upper_32_bits(buf_phys_addr) & MVPP22_BM_ADDR_HIGH_PHYS_RLS_MASK;
+	val |= (upper_32_bits(buf_virt_addr) &
+		MVPP22_BM_ADDR_HIGH_VIRT_RLS_MASK)
+		<< MVPP22_BM_ADDR_HIGH_VIRT_RLS_SHIFT;
+	mvpp2_write(port->priv, MVPP22_BM_ADDR_HIGH_RLS_REG, val);
+#endif
+	mvpp2_write(port->priv, MVPP2_BM_VIRT_RLS_REG,
+		    lower_32_bits(buf_virt_addr));
+	mvpp2_write(port->priv, MVPP2_BM_PHY_RLS_REG(pool),
+		    lower_32_bits(buf_phys_addr));
 }
 
 /* Release multicast buffer */
@@ -3800,7 +3864,10 @@ static void mvpp2_bm_pool_mc_put(struct mvpp2_port *port, int pool,
 	u32 val = 0;
 
 	val |= (mc_id & MVPP2_BM_MC_ID_MASK);
-	mvpp2_write(port->priv, MVPP2_BM_MC_RLS_REG, val);
+	if (port->priv->ip_version == MVPP21)
+		mvpp2_write(port->priv, MVPP21_BM_MC_RLS_REG, val);
+	else
+		mvpp2_write(port->priv, MVPP22_BM_MC_RLS_REG, val);
 
 	mvpp2_bm_pool_put(port, pool,
 			  buf_phys_addr | MVPP2_BM_PHY_RLS_MC_BUFF_MASK,
-- 
2.7.4
