From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH v2 11/11] net: mvpp2: enable building on 64-bit platforms
Date: Tue, 27 Dec 2016 17:54:20 +0100
Message-ID: <1482857660-16092-12-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1482857660-16092-1-git-send-email-thomas.petazzoni@free-electrons.com>
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
Received: from mail.free-electrons.com ([62.4.15.54]:36670 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933086AbcL0Qyf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2016 11:54:35 -0500
In-Reply-To: <1482857660-16092-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mvpp2 is going to be extended to support the Marvell Armada 7K/8K
platform, which is ARM64. As a preparation to this work, this commit
enables building the mvpp2 driver on ARM64, by:

 - Adjusting the Kconfig dependency

 - Fixing the types used in the driver so that they are 32/64-bits
   compliant. We use dma_addr_t for DMA addresses, and unsigned long
   for virtual addresses.

It is worth mentioning that after this commit, the driver is for now
still only used on 32-bits platforms.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/Kconfig |  3 +--
 drivers/net/ethernet/marvell/mvpp2.c | 29 +++++++++++++++++------------
 2 files changed, 18 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/marvell/Kconfig b/drivers/net/ethernet/marvell/Kconfig
index f4b7cf1..d2555e8b 100644
--- a/drivers/net/ethernet/marvell/Kconfig
+++ b/drivers/net/ethernet/marvell/Kconfig
@@ -83,9 +83,8 @@ config MVNETA_BM
 
 config MVPP2
 	tristate "Marvell Armada 375 network interface support"
-	depends on MACH_ARMADA_375 || COMPILE_TEST
+	depends on ARCH_MVEBU || COMPILE_TEST
 	depends on HAS_DMA
-	depends on !64BIT
 	select MVMDIO
 	---help---
 	  This driver supports the network interface units in the
diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 1e08e8f..2268808 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -3388,7 +3388,8 @@ static int mvpp2_bm_pool_create(struct platform_device *pdev,
 	if (!bm_pool->virt_addr)
 		return -ENOMEM;
 
-	if (!IS_ALIGNED((u32)bm_pool->virt_addr, MVPP2_BM_POOL_PTR_ALIGN)) {
+	if (!IS_ALIGNED((unsigned long)bm_pool->virt_addr,
+			MVPP2_BM_POOL_PTR_ALIGN)) {
 		dma_free_coherent(&pdev->dev, size_bytes, bm_pool->virt_addr,
 				  bm_pool->phys_addr);
 		dev_err(&pdev->dev, "BM pool %d is not %d bytes aligned\n",
@@ -3433,7 +3434,7 @@ static void mvpp2_bm_bufs_free(struct device *dev, struct mvpp2 *priv,
 
 	for (i = 0; i < bm_pool->buf_num; i++) {
 		dma_addr_t buf_phys_addr;
-		u32 vaddr;
+		unsigned long vaddr;
 
 		/* Get buffer virtual address (indirect access) */
 		buf_phys_addr = mvpp2_read(priv,
@@ -3596,14 +3597,15 @@ static inline u32 mvpp2_bm_cookie_pool_set(u32 cookie, int pool)
 }
 
 /* Get pool number from a BM cookie */
-static inline int mvpp2_bm_cookie_pool_get(u32 cookie)
+static inline int mvpp2_bm_cookie_pool_get(unsigned long cookie)
 {
 	return (cookie >> MVPP2_BM_COOKIE_POOL_OFFS) & 0xFF;
 }
 
 /* Release buffer to BM */
 static inline void mvpp2_bm_pool_put(struct mvpp2_port *port, int pool,
-				     u32 buf_phys_addr, u32 buf_virt_addr)
+				     dma_addr_t buf_phys_addr,
+				     unsigned long buf_virt_addr)
 {
 	mvpp2_write(port->priv, MVPP2_BM_VIRT_RLS_REG, buf_virt_addr);
 	mvpp2_write(port->priv, MVPP2_BM_PHY_RLS_REG(pool), buf_phys_addr);
@@ -3611,7 +3613,8 @@ static inline void mvpp2_bm_pool_put(struct mvpp2_port *port, int pool,
 
 /* Release multicast buffer */
 static void mvpp2_bm_pool_mc_put(struct mvpp2_port *port, int pool,
-				 u32 buf_phys_addr, u32 buf_virt_addr,
+				 dma_addr_t buf_phys_addr,
+				 unsigned long buf_virt_addr,
 				 int mc_id)
 {
 	u32 val = 0;
@@ -3626,7 +3629,8 @@ static void mvpp2_bm_pool_mc_put(struct mvpp2_port *port, int pool,
 
 /* Refill BM pool */
 static void mvpp2_pool_refill(struct mvpp2_port *port, u32 bm,
-			      u32 phys_addr, u32 cookie)
+			      dma_addr_t phys_addr,
+			      unsigned long cookie)
 {
 	int pool = mvpp2_bm_cookie_pool_get(bm);
 
@@ -3657,7 +3661,8 @@ static int mvpp2_bm_bufs_add(struct mvpp2_port *port,
 		if (!buf)
 			break;
 
-		mvpp2_bm_pool_put(port, bm_pool->id, (u32)phys_addr, (u32)buf);
+		mvpp2_bm_pool_put(port, bm_pool->id, phys_addr,
+				  (unsigned long)buf);
 	}
 
 	/* Update BM driver with number of buffers added to pool */
@@ -5015,7 +5020,7 @@ static int mvpp2_rx_refill(struct mvpp2_port *port,
 	if (!buf)
 		return -ENOMEM;
 
-	mvpp2_pool_refill(port, bm, (u32)phys_addr, (u32)buf);
+	mvpp2_pool_refill(port, bm, phys_addr, (unsigned long)buf);
 
 	return 0;
 }
@@ -5057,10 +5062,10 @@ static void mvpp2_buff_hdr_rx(struct mvpp2_port *port,
 	struct mvpp2_buff_hdr *buff_hdr;
 	struct sk_buff *skb;
 	u32 rx_status = rx_desc->status;
-	u32 buff_phys_addr;
-	u32 buff_virt_addr;
-	u32 buff_phys_addr_next;
-	u32 buff_virt_addr_next;
+	dma_addr_t buff_phys_addr;
+	unsigned long buff_virt_addr;
+	dma_addr_t buff_phys_addr_next;
+	unsigned long buff_virt_addr_next;
 	int mc_id;
 	int pool_id;
 
-- 
2.7.4
