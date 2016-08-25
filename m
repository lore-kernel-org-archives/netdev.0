From: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Subject: [RESEND PATCH net 02/10] net: ethernet: mediatek: fix incorrect
 return value of devm_clk_get with EPROBE_DEFER
Date: Thu, 25 Aug 2016 18:44:53 +0800
Message-ID: <1472121901-15629-3-git-send-email-sean.wang@mediatek.com>
References: <1472121901-15629-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>,
 linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1472121901-15629-1-git-send-email-sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

If the return value of devm_clk_get is EPROBE_DEFER, we should
defer probing the driver. The change is verified and works based
on 4.8-rc1 staying with the latest clk-next code for MT7623.

Signed-off-by: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 6e4a6ca..02b048f 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -1851,8 +1851,15 @@ static int mtk_probe(struct platform_device *pdev)
 	eth->clk_gp1 = devm_clk_get(&pdev->dev, "gp1");
 	eth->clk_gp2 = devm_clk_get(&pdev->dev, "gp2");
 	if (IS_ERR(eth->clk_esw) || IS_ERR(eth->clk_gp1) ||
-	    IS_ERR(eth->clk_gp2) || IS_ERR(eth->clk_ethif))
-		return -ENODEV;
+	    IS_ERR(eth->clk_gp2) || IS_ERR(eth->clk_ethif)) {
+		if (PTR_ERR(eth->clk_esw) == -EPROBE_DEFER ||
+		    PTR_ERR(eth->clk_gp1) == -EPROBE_DEFER ||
+		    PTR_ERR(eth->clk_gp1) == -EPROBE_DEFER ||
+		    PTR_ERR(eth->clk_gp2) == -EPROBE_DEFER)
+			return -EPROBE_DEFER;
+		else
+			return -ENODEV;
+	}
 
 	clk_prepare_enable(eth->clk_ethif);
 	clk_prepare_enable(eth->clk_esw);
-- 
1.9.1
