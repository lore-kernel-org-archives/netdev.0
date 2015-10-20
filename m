From: Hans de Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH resend] net: sun4i-emac: Properly free resources
 on probe failure and remove
Date: Tue, 20 Oct 2015 10:42:24 +0200
Message-ID: <1445330544-6968-2-git-send-email-hdegoede@redhat.com>
References: <1445330544-6968-1-git-send-email-hdegoede@redhat.com>
Reply-To: hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
        Hans de Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-sunxi+bncBDRZXY4CYYORB674S6YQKGQEYW2FVTQ-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <1445330544-6968-1-git-send-email-hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <http://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

Fix sun4i-emac not releasing the following resources:
-iomapped memory not released on probe-failure nor on remove
-clock not getting disabled on probe-failure nor on remove
-sram not being released on remove

And while at it also add error checking to the clk_prepare_enable call
done on probe.

Signed-off-by: Hans de Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 drivers/net/ethernet/allwinner/sun4i-emac.c | 20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/allwinner/sun4i-emac.c b/drivers/net/ethernet/allwinner/sun4i-emac.c
index 48ce83e..8d50314 100644
--- a/drivers/net/ethernet/allwinner/sun4i-emac.c
+++ b/drivers/net/ethernet/allwinner/sun4i-emac.c
@@ -847,21 +847,25 @@ static int emac_probe(struct platform_device *pdev)
 	if (ndev->irq == -ENXIO) {
 		netdev_err(ndev, "No irq resource\n");
 		ret = ndev->irq;
-		goto out;
+		goto out_iounmap;
 	}
 
 	db->clk = devm_clk_get(&pdev->dev, NULL);
 	if (IS_ERR(db->clk)) {
 		ret = PTR_ERR(db->clk);
-		goto out;
+		goto out_iounmap;
 	}
 
-	clk_prepare_enable(db->clk);
+	ret = clk_prepare_enable(db->clk);
+	if (ret) {
+		dev_err(&pdev->dev, "Error couldn't enable clock (%d)\n", ret);
+		goto out_iounmap;
+	}
 
 	ret = sunxi_sram_claim(&pdev->dev);
 	if (ret) {
 		dev_err(&pdev->dev, "Error couldn't map SRAM to device\n");
-		goto out;
+		goto out_clk_disable_unprepare;
 	}
 
 	db->phy_node = of_parse_phandle(np, "phy", 0);
@@ -910,6 +914,10 @@ static int emac_probe(struct platform_device *pdev)
 
 out_release_sram:
 	sunxi_sram_release(&pdev->dev);
+out_clk_disable_unprepare:
+	clk_disable_unprepare(db->clk);
+out_iounmap:
+	iounmap(db->membase);
 out:
 	dev_err(db->dev, "not found (%d).\n", ret);
 
@@ -921,8 +929,12 @@ out:
 static int emac_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct emac_board_info *db = netdev_priv(ndev);
 
 	unregister_netdev(ndev);
+	sunxi_sram_release(&pdev->dev);
+	clk_disable_unprepare(db->clk);
+	iounmap(db->membase);
 	free_netdev(ndev);
 
 	dev_dbg(&pdev->dev, "released and freed device\n");
-- 
2.5.0
