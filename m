From: Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 3/5] net/cadence/macb: Simplify OF dependencies
Date: Tue,  2 Apr 2013 12:35:09 -0700
Message-ID: <1364931311-30603-4-git-send-email-linux@roeck-us.net>
References: <1364931311-30603-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Daney <david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>, Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
 Nicolas Ferre <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>,
 Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1364931311-30603-1-git-send-email-linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

With of_get_mac_address() and of_get_phy_mode() now defined as dummy
functions if OF_NET is not configured, it is no longer necessary to
provide OF dependent functions as front-end. Also, the two functions
depend on OF_NET, not on OF, so the conditional code was not correct
anyway.

Drop the front-end functions and call of_get_mac_address() and
of_get_phy_mode() directly instead.

Signed-off-by: Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
---
 drivers/net/ethernet/cadence/macb.c |   43 +++++------------------------------
 1 file changed, 6 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 7903943..b2a9d20 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1472,41 +1472,7 @@ static const struct of_device_id macb_dt_ids[] = {
 	{ .compatible = "cdns,gem" },
 	{ /* sentinel */ }
 };
-
 MODULE_DEVICE_TABLE(of, macb_dt_ids);
-
-static int macb_get_phy_mode_dt(struct platform_device *pdev)
-{
-	struct device_node *np = pdev->dev.of_node;
-
-	if (np)
-		return of_get_phy_mode(np);
-
-	return -ENODEV;
-}
-
-static int macb_get_hwaddr_dt(struct macb *bp)
-{
-	struct device_node *np = bp->pdev->dev.of_node;
-	if (np) {
-		const char *mac = of_get_mac_address(np);
-		if (mac) {
-			memcpy(bp->dev->dev_addr, mac, ETH_ALEN);
-			return 0;
-		}
-	}
-
-	return -ENODEV;
-}
-#else
-static int macb_get_phy_mode_dt(struct platform_device *pdev)
-{
-	return -ENODEV;
-}
-static int macb_get_hwaddr_dt(struct macb *bp)
-{
-	return -ENODEV;
-}
 #endif
 
 static int __init macb_probe(struct platform_device *pdev)
@@ -1519,6 +1485,7 @@ static int __init macb_probe(struct platform_device *pdev)
 	u32 config;
 	int err = -ENXIO;
 	struct pinctrl *pinctrl;
+	const char *mac;
 
 	regs = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	if (!regs) {
@@ -1592,11 +1559,13 @@ static int __init macb_probe(struct platform_device *pdev)
 	config |= macb_dbw(bp);
 	macb_writel(bp, NCFGR, config);
 
-	err = macb_get_hwaddr_dt(bp);
-	if (err < 0)
+	mac = of_get_mac_address(pdev->dev.of_node);
+	if (mac)
+		memcpy(bp->dev->dev_addr, mac, ETH_ALEN);
+	else
 		macb_get_hwaddr(bp);
 
-	err = macb_get_phy_mode_dt(pdev);
+	err = of_get_phy_mode(pdev->dev.of_node);
 	if (err < 0) {
 		pdata = pdev->dev.platform_data;
 		if (pdata && pdata->is_rmii)
-- 
1.7.9.7
