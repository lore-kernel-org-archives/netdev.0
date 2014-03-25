From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH] net: mvneta: use devm_ioremap_resource() instead of of_iomap()
Date: Wed, 26 Mar 2014 00:26:55 +0100
Message-ID: <1395790015-20929-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	linux-arm-kernel@lists.infradead.org
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:50190 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751624AbaCYX04 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 19:26:56 -0400
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
 drivers/net/ethernet/marvell/mvneta.c | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index f418f4f..e21a931 100644
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
@@ -2838,9 +2840,15 @@ static int mvneta_probe(struct platform_device *pdev)
 
 	clk_prepare_enable(pp->clk);
 
-	pp->base = of_iomap(dn, 0);
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!res) {
+		err = -ENODEV;
+		goto err_clk;
+	}
+
+	pp->base = devm_ioremap_resource(&pdev->dev, res);
 	if (pp->base == NULL) {
-		err = -ENOMEM;
+		err = PTR_ERR(pp->base);
 		goto err_clk;
 	}
 
@@ -2848,7 +2856,7 @@ static int mvneta_probe(struct platform_device *pdev)
 	pp->stats = alloc_percpu(struct mvneta_pcpu_stats);
 	if (!pp->stats) {
 		err = -ENOMEM;
-		goto err_unmap;
+		goto err_clk;
 	}
 
 	for_each_possible_cpu(cpu) {
@@ -2913,8 +2921,6 @@ err_deinit:
 	mvneta_deinit(pp);
 err_free_stats:
 	free_percpu(pp->stats);
-err_unmap:
-	iounmap(pp->base);
 err_clk:
 	clk_disable_unprepare(pp->clk);
 err_free_irq:
@@ -2934,7 +2940,6 @@ static int mvneta_remove(struct platform_device *pdev)
 	mvneta_deinit(pp);
 	clk_disable_unprepare(pp->clk);
 	free_percpu(pp->stats);
-	iounmap(pp->base);
 	irq_dispose_mapping(dev->irq);
 	free_netdev(dev);
 
-- 
1.8.3.2
