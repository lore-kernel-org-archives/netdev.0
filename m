From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Subject: [PATCH net-next v3 3/8] net: stmmac: Allocate and pass
 soc/board specific data to callbacks
Date: Fri, 17 Jan 2014 21:24:42 +0800
Message-ID: <1389965087-21971-4-git-send-email-wens@csie.org>
References: <1389965087-21971-1-git-send-email-wens@csie.org>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
	Srinivas Kandagatla <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-sunxi+bncBCMILY6JWQBBBKW64SLAKGQE3NNHNOY-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <1389965087-21971-1-git-send-email-wens-jdAy2FN1RRM@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

The current .init and .exit callbacks requires access to driver
private data structures. This is not a good seperation and abstraction.

Instead, we add a new .setup callback for allocating private data, and
pass the returned pointer to the other callbacks.

Signed-off-by: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
---
 Documentation/networking/stmmac.txt                   | 12 ++++++++----
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 18 ++++++++++++++----
 include/linux/stmmac.h                                |  6 ++++--
 3 files changed, 26 insertions(+), 10 deletions(-)

diff --git a/Documentation/networking/stmmac.txt b/Documentation/networking/stmmac.txt
index cdd916d..2090895 100644
--- a/Documentation/networking/stmmac.txt
+++ b/Documentation/networking/stmmac.txt
@@ -127,8 +127,9 @@ struct plat_stmmacenet_data {
 	int riwt_off;
 	void (*fix_mac_speed)(void *priv, unsigned int speed);
 	void (*bus_setup)(void __iomem *ioaddr);
-	int (*init)(struct platform_device *pdev);
-	void (*exit)(struct platform_device *pdev);
+	void *(*setup)(struct platform_device *pdev);
+	int (*init)(struct platform_device *pdev, void *priv);
+	void (*exit)(struct platform_device *pdev, void *priv);
 	void *custom_cfg;
 	void *custom_data;
 	void *bsp_priv;
@@ -169,10 +170,13 @@ Where:
  o bus_setup: perform HW setup of the bus. For example, on some ST platforms
 	     this field is used to configure the AMBA  bridge to generate more
 	     efficient STBus traffic.
- o init/exit: callbacks used for calling a custom initialization;
+ o setup/init/exit: callbacks used for calling a custom initialization;
 	     this is sometime necessary on some platforms (e.g. ST boxes)
 	     where the HW needs to have set some PIO lines or system cfg
-	     registers.
+	     registers. setup should return a pointer to private data,
+	     which will be stored in bsp_priv, and then passed to init and
+	     exit callbacks. init/exit callbacks should not use or modify
+	     platform data.
  o custom_cfg/custom_data: this is a custom configuration that can be passed
 			   while initializing the resources.
  o bsp_priv: another private pointer.
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index cc6b89a7..704a5e0 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -144,9 +144,16 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
 		}
 	}
 
+	/* Custom setup (if needed) */
+	if (plat_dat->setup) {
+		plat_dat->bsp_priv = plat_dat->setup(pdev);
+		if (IS_ERR(plat_dat->bsp_priv))
+			return PTR_ERR(plat_dat->bsp_priv);
+	}
+
 	/* Custom initialisation (if needed)*/
 	if (plat_dat->init) {
-		ret = plat_dat->init(pdev);
+		ret = plat_dat->init(pdev, plat_dat->bsp_priv);
 		if (unlikely(ret))
 			return ret;
 	}
@@ -203,7 +210,10 @@ static int stmmac_pltfr_remove(struct platform_device *pdev)
 	int ret = stmmac_dvr_remove(ndev);
 
 	if (priv->plat->exit)
-		priv->plat->exit(pdev);
+		priv->plat->exit(pdev, priv->plat->bsp_priv);
+
+	if (priv->plat->free)
+		priv->plat->free(pdev, priv->plat->bsp_priv);
 
 	return ret;
 }
@@ -218,7 +228,7 @@ static int stmmac_pltfr_suspend(struct device *dev)
 
 	ret = stmmac_suspend(ndev);
 	if (priv->plat->exit)
-		priv->plat->exit(pdev);
+		priv->plat->exit(pdev, priv->plat->bsp_priv);
 
 	return ret;
 }
@@ -230,7 +240,7 @@ static int stmmac_pltfr_resume(struct device *dev)
 	struct platform_device *pdev = to_platform_device(dev);
 
 	if (priv->plat->init)
-		priv->plat->init(pdev);
+		priv->plat->init(pdev, priv->plat->bsp_priv);
 
 	return stmmac_resume(ndev);
 }
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index 33ace71..0a5a7ac 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -113,8 +113,10 @@ struct plat_stmmacenet_data {
 	int max_speed;
 	void (*fix_mac_speed)(void *priv, unsigned int speed);
 	void (*bus_setup)(void __iomem *ioaddr);
-	int (*init)(struct platform_device *pdev);
-	void (*exit)(struct platform_device *pdev);
+	void *(*setup)(struct platform_device *pdev);
+	void (*free)(struct platform_device *pdev, void *priv);
+	int (*init)(struct platform_device *pdev, void *priv);
+	void (*exit)(struct platform_device *pdev, void *priv);
 	void *custom_cfg;
 	void *custom_data;
 	void *bsp_priv;
-- 
1.8.5.2
