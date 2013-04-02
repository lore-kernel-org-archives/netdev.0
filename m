From: Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 4/5] net/freescale/fec: Simplify OF dependencies
Date: Tue,  2 Apr 2013 12:35:10 -0700
Message-ID: <1364931311-30603-5-git-send-email-linux@roeck-us.net>
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

Since of_get_mac_address() is now defined even if CONFIG_OF_NET
is not configured, the ifdef around the code calling it is no longer
necessary and can be removed.

Similar, since of_get_phy_mode() is now defined as dummy function
if OF_NET is not configured, it is no longer necessary to provide
an OF dependent function as front-end. Also, the function depends
on OF_NET, not on OF, so the conditional code was not correct anyway.
Drop the front-end function and call of_get_phy_mode() directly.

Signed-off-by: Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
---
 drivers/net/ethernet/freescale/fec.c |   19 +------------------
 1 file changed, 1 insertion(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 911d025..d374a94 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -868,7 +868,6 @@ static void fec_get_mac(struct net_device *ndev)
 	 */
 	iap = macaddr;
 
-#ifdef CONFIG_OF
 	/*
 	 * 2) from device tree data
 	 */
@@ -880,7 +879,6 @@ static void fec_get_mac(struct net_device *ndev)
 				iap = (unsigned char *) mac;
 		}
 	}
-#endif
 
 	/*
 	 * 3) from flash or fuse (via platform data)
@@ -1666,16 +1664,6 @@ static int fec_enet_init(struct net_device *ndev)
 }
 
 #ifdef CONFIG_OF
-static int fec_get_phy_mode_dt(struct platform_device *pdev)
-{
-	struct device_node *np = pdev->dev.of_node;
-
-	if (np)
-		return of_get_phy_mode(np);
-
-	return -ENODEV;
-}
-
 static void fec_reset_phy(struct platform_device *pdev)
 {
 	int err, phy_reset;
@@ -1704,11 +1692,6 @@ static void fec_reset_phy(struct platform_device *pdev)
 	gpio_set_value(phy_reset, 1);
 }
 #else /* CONFIG_OF */
-static int fec_get_phy_mode_dt(struct platform_device *pdev)
-{
-	return -ENODEV;
-}
-
 static void fec_reset_phy(struct platform_device *pdev)
 {
 	/*
@@ -1773,7 +1756,7 @@ fec_probe(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, ndev);
 
-	ret = fec_get_phy_mode_dt(pdev);
+	ret = of_get_phy_mode(pdev->dev.of_node);
 	if (ret < 0) {
 		pdata = pdev->dev.platform_data;
 		if (pdata)
-- 
1.7.9.7
