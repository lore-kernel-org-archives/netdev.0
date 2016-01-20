From: Jisheng Zhang <jszhang-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH v3 3/4] net: mvneta: get optional bus clk
Date: Wed, 20 Jan 2016 19:27:24 +0800
Message-ID: <1453289245-2061-4-git-send-email-jszhang@marvell.com>
References: <1453289245-2061-1-git-send-email-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	Jisheng Zhang <jszhang-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
To: <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<mw-nYOzD4b6Jr9Wk0Htik3J/w@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	<mark.rutland-5wv7dgnIgG8@public.gmane.org>, <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	<galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1453289245-2061-1-git-send-email-jszhang-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Some platforms may provide more than one clk for the mvneta IP, for
example Marvell BG4CT provides one clk for the mac core, and one
clk for the AXI bus logic. Obviously this bus clk also need to
be enabled. This patch adds this optional "bus" clk support.

Signed-off-by: Jisheng Zhang <jszhang-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/ethernet/marvell/mvneta.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 736a9ec..8b306d2 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -373,6 +373,8 @@ struct mvneta_port {
 
 	/* Core clock */
 	struct clk *clk;
+	/* AXI clock */
+	struct clk *clk_bus;
 	u8 mcast_count[256];
 	u16 tx_ring_size;
 	u16 rx_ring_size;
@@ -3615,6 +3617,10 @@ static int mvneta_probe(struct platform_device *pdev)
 
 	clk_prepare_enable(pp->clk);
 
+	pp->clk_bus = devm_clk_get(&pdev->dev, "bus");
+	if (!IS_ERR(pp->clk_bus))
+		clk_prepare_enable(pp->clk_bus);
+
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	pp->base = devm_ioremap_resource(&pdev->dev, res);
 	if (IS_ERR(pp->base)) {
@@ -3726,6 +3732,7 @@ err_free_stats:
 err_free_ports:
 	free_percpu(pp->ports);
 err_clk:
+	clk_disable_unprepare(pp->clk_bus);
 	clk_disable_unprepare(pp->clk);
 err_put_phy_node:
 	of_node_put(phy_node);
@@ -3743,6 +3750,7 @@ static int mvneta_remove(struct platform_device *pdev)
 	struct mvneta_port *pp = netdev_priv(dev);
 
 	unregister_netdev(dev);
+	clk_disable_unprepare(pp->clk_bus);
 	clk_disable_unprepare(pp->clk);
 	free_percpu(pp->ports);
 	free_percpu(pp->stats);
-- 
2.7.0.rc3

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
