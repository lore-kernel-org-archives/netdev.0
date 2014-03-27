From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCHv3] net: mvneta: use devm_ioremap_resource() instead of of_iomap()
Date: Thu, 27 Mar 2014 11:39:29 +0100
Message-ID: <1395916769-20475-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: linux-arm-kernel@lists.infradead.org,
	Lior Amsalem <alior@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:57841 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753873AbaC0Kjd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 06:39:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mvneta driver currently uses of_iomap(), which has two drawbacks:
it doesn't request the resource, and it isn't devm-style so some error
handling is needed.

This commit switches to use devm_ioremap_resource() instead, which
automatically requests the resource (so the I/O registers region shows
up properly in /proc/iomem), and also is devm-style, which allows to
get rid of some error handling to unmap the I/O registers region.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
Changes since v2:

 - Properly take into account the fact that devm_ioremap_resource()
   returns a PTR_ERR type of pointer, so IS_ERR must be used to test
   the return value.

Changes since v1:

 - Remove error handling of platform_get_resource(), since
   devm_ioremap_resource already checks if the resource is NULL, and
   properly returns an error in this case. Reported by Ezequiel Garcia.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index f418f4f..e251ec7 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -22,6 +22,7 @@
 #include <linux/interrupt.h>
 #include <net/ip.h>
 #include <net/ipv6.h>
+#include <linux/io.h>
 #include <linux/of.h>
 #include <linux/of_irq.h>
 #include <linux/of_mdio.h>
@@ -2774,6 +2775,7 @@ static void mvneta_port_power_up(struct mvneta_port *pp, int phy_mode)
 static int mvneta_probe(struct platform_device *pdev)
 {
 	const struct mbus_dram_target_info *dram_target_info;
+	struct resource *res;
 	struct device_node *dn = pdev->dev.of_node;
 	struct device_node *phy_node;
 	u32 phy_addr;
@@ -2838,9 +2840,10 @@ static int mvneta_probe(struct platform_device *pdev)
 
 	clk_prepare_enable(pp->clk);
 
-	pp->base = of_iomap(dn, 0);
-	if (pp->base == NULL) {
-		err = -ENOMEM;
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	pp->base = devm_ioremap_resource(&pdev->dev, res);
+	if (IS_ERR(pp->base)) {
+		err = PTR_ERR(pp->base);
 		goto err_clk;
 	}
 
@@ -2848,7 +2851,7 @@ static int mvneta_probe(struct platform_device *pdev)
 	pp->stats = alloc_percpu(struct mvneta_pcpu_stats);
 	if (!pp->stats) {
 		err = -ENOMEM;
-		goto err_unmap;
+		goto err_clk;
 	}
 
 	for_each_possible_cpu(cpu) {
@@ -2913,8 +2916,6 @@ err_deinit:
 	mvneta_deinit(pp);
 err_free_stats:
 	free_percpu(pp->stats);
-err_unmap:
-	iounmap(pp->base);
 err_clk:
 	clk_disable_unprepare(pp->clk);
 err_free_irq:
@@ -2934,7 +2935,6 @@ static int mvneta_remove(struct platform_device *pdev)
 	mvneta_deinit(pp);
 	clk_disable_unprepare(pp->clk);
 	free_percpu(pp->stats);
-	iounmap(pp->base);
 	irq_dispose_mapping(dev->irq);
 	free_netdev(dev);
 
-- 
1.8.3.2
