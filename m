From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH net-next v2 4/7] net: mvpp2: move from cpu-centric naming to "software thread" naming
Date: Thu,  3 Aug 2017 10:41:58 +0200
Message-ID: <20170803084201.30305-5-thomas.petazzoni@free-electrons.com>
References: <20170803084201.30305-1-thomas.petazzoni@free-electrons.com>
Cc: Nadav Haklai <nadavh@marvell.com>, Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Stefan Chulski <stefanc@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Antoine Tenart <antoine.tenart@free-electrons.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        =?UTF-8?q?Miqu=C3=A8l=20Raynal?= <miquel.raynal@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:46652 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751802AbdHCIm3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 04:42:29 -0400
In-Reply-To: <20170803084201.30305-1-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PPv2.2 IP has a concept of "software thread", with all registers
of the PPv2.2 mapped 8 times, for concurrent accesses by 8 "software
threads". In addition, interrupts on RX queues are associated to such
"software thread".

For most cases, we map a "software thread" to the more conventional
concept of CPU, but we will soon have one exception: we will have a
model where we have one TX interrupt per CPU (each using one software
thread), and all RX events mapped to another software thread
(associated to another interrupt).

In preparation for this change, it makes sense to change the naming
from MVPP2_MAX_CPUS to MVPP2_MAX_THREADS, and plan for 8 software
threads instead of 4 currently.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 25 +++++++++++++------------
 1 file changed, 13 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 84908aa..af38a21 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -685,7 +685,7 @@ enum mvpp2_prs_l3_cast {
 #define MVPP21_ADDR_SPACE_SZ		0
 #define MVPP22_ADDR_SPACE_SZ		SZ_64K
 
-#define MVPP2_MAX_CPUS			4
+#define MVPP2_MAX_THREADS		8
 
 enum mvpp2_bm_type {
 	MVPP2_BM_FREE,
@@ -701,11 +701,12 @@ struct mvpp2 {
 	void __iomem *lms_base;
 	void __iomem *iface_base;
 
-	/* On PPv2.2, each CPU can access the base register through a
-	 * separate address space, each 64 KB apart from each
-	 * other.
+	/* On PPv2.2, each "software thread" can access the base
+	 * register through a separate address space, each 64 KB apart
+	 * from each other. Typically, such address spaces will be
+	 * used per CPU.
 	 */
-	void __iomem *cpu_base[MVPP2_MAX_CPUS];
+	void __iomem *swth_base[MVPP2_MAX_THREADS];
 
 	/* Common clocks */
 	struct clk *pp_clk;
@@ -1071,12 +1072,12 @@ struct mvpp2_bm_pool {
 
 static void mvpp2_write(struct mvpp2 *priv, u32 offset, u32 data)
 {
-	writel(data, priv->cpu_base[0] + offset);
+	writel(data, priv->swth_base[0] + offset);
 }
 
 static u32 mvpp2_read(struct mvpp2 *priv, u32 offset)
 {
-	return readl(priv->cpu_base[0] + offset);
+	return readl(priv->swth_base[0] + offset);
 }
 
 /* These accessors should be used to access:
@@ -1118,13 +1119,13 @@ static u32 mvpp2_read(struct mvpp2 *priv, u32 offset)
 static void mvpp2_percpu_write(struct mvpp2 *priv, int cpu,
 			       u32 offset, u32 data)
 {
-	writel(data, priv->cpu_base[cpu] + offset);
+	writel(data, priv->swth_base[cpu] + offset);
 }
 
 static u32 mvpp2_percpu_read(struct mvpp2 *priv, int cpu,
 			     u32 offset)
 {
-	return readl(priv->cpu_base[cpu] + offset);
+	return readl(priv->swth_base[cpu] + offset);
 }
 
 static dma_addr_t mvpp2_txdesc_dma_addr_get(struct mvpp2_port *port,
@@ -6874,7 +6875,7 @@ static int mvpp2_probe(struct platform_device *pdev)
 	struct mvpp2 *priv;
 	struct resource *res;
 	void __iomem *base;
-	int port_count, cpu;
+	int port_count, i;
 	int err;
 
 	priv = devm_kzalloc(&pdev->dev, sizeof(*priv), GFP_KERNEL);
@@ -6901,12 +6902,12 @@ static int mvpp2_probe(struct platform_device *pdev)
 			return PTR_ERR(priv->iface_base);
 	}
 
-	for_each_present_cpu(cpu) {
+	for (i = 0; i < MVPP2_MAX_THREADS; i++) {
 		u32 addr_space_sz;
 
 		addr_space_sz = (priv->hw_version == MVPP21 ?
 				 MVPP21_ADDR_SPACE_SZ : MVPP22_ADDR_SPACE_SZ);
-		priv->cpu_base[cpu] = base + cpu * addr_space_sz;
+		priv->swth_base[i] = base + i * addr_space_sz;
 	}
 
 	if (priv->hw_version == MVPP21)
-- 
2.9.4
