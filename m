From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCHv3 4/4] net: mvneta: add support for fixed links
Date: Tue, 4 Mar 2014 12:30:38 +0100
Message-ID: <20140304123038.652f933d@skate>
References: <1393930704-24374-1-git-send-email-thomas.petazzoni@free-electrons.com>
	<1393930704-24374-5-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <florian@openwrt.org>,
	Lior Amsalem <alior@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Mark Rutland <mark.rutland@arm.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Christian Gmeiner <christian.gmeiner@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:40335 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757151AbaCDLam (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 06:30:42 -0500
In-Reply-To: <1393930704-24374-5-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,

On Tue,  4 Mar 2014 11:58:24 +0100, Thomas Petazzoni wrote:

>  	phy_node = of_parse_phandle(dn, "phy", 0);
> -	if (!phy_node) {
> -		dev_err(&pdev->dev, "no associated PHY\n");
> -		err = -ENODEV;
> -		goto err_free_irq;
> +	if (of_phy_is_fixed_link(phy_node)) {
> +		err = of_phy_register_fixed_link(phy_node);
> +		if (err < 0) {
> +			dev_err(&pdev->dev, "cannot register fixed PHY\n");
> +			goto err_free_irq;
> +		}
>  	}
>  
>  	phy_mode = of_get_phy_mode(dn);

As noted by Sebastian Hesselbarth (talking with me on IRC), it would be
nicer if network driver didn't had to be modified to ensure that the
fixed PHY the network device is connected to gets registered into the
kernel.

So ideally, the fixed MDIO bus implemented in drivers/net/phy/fixed.c
should scan the Device Tree, and register at boot time the fixed PHYs.
The only problem is how to recognize in the DT which nodes are fixed
PHYs. Looking for the "fixed-link" property is very fragile as other
completely unrelated nodes may use this property for other purposes.
Using a compatible string? A device_type property? Or should we have a
fragment of the DT for the fixed MDIO bus itself?

I've done a quick prototype that is based on using the "fixed-eth-phy"
compatible string as the key to find fixed PHYs in the DT, just to see
how it would work. It works well, and allows to get rid of changes in
the network driver completely. See below for the prototype-level patch
(which applies on top of the proposed patch series, for now).

Suggestions?

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 053a650..8a68a07 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -2805,14 +2805,6 @@ static int mvneta_probe(struct platform_device *pdev)
 	}
 
 	phy_node = of_parse_phandle(dn, "phy", 0);
-	if (of_phy_is_fixed_link(phy_node)) {
-		err = of_phy_register_fixed_link(phy_node);
-		if (err < 0) {
-			dev_err(&pdev->dev, "cannot register fixed PHY\n");
-			goto err_free_irq;
-		}
-	}
-
 	phy_mode = of_get_phy_mode(dn);
 	if (phy_mode < 0) {
 		dev_err(&pdev->dev, "incorrect phy-mode\n");
diff --git a/drivers/net/phy/fixed.c b/drivers/net/phy/fixed.c
index 82095cc..45a7d5a 100644
--- a/drivers/net/phy/fixed.c
+++ b/drivers/net/phy/fixed.c
@@ -22,6 +22,7 @@
 #include <linux/err.h>
 #include <linux/slab.h>
 #include <linux/of.h>
+#include <linux/of_mdio.h>
 
 #define MII_REGS_NUM 29
 
@@ -293,6 +294,8 @@ static int __init fixed_mdio_bus_init(void)
 	if (ret)
 		goto err_mdiobus_alloc;
 
+	of_phy_register_fixed_phys();
+
 	return 0;
 
 err_mdiobus_alloc:
diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index c645fb8..4e75a70 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -277,16 +277,12 @@ struct phy_device *of_phy_attach(struct net_device *dev,
 EXPORT_SYMBOL(of_phy_attach);
 
 #if defined(CONFIG_FIXED_PHY)
-bool of_phy_is_fixed_link(struct device_node *np)
-{
-	return of_property_read_bool(np, "fixed-link");
-}
-EXPORT_SYMBOL(of_phy_is_fixed_link);
-
-int of_phy_register_fixed_link(struct device_node *np)
+static int of_phy_register_fixed_link(struct device_node *np)
 {
 	struct fixed_phy_status status = {};
 
 	status.link = 1;
 	status.duplex = of_property_read_bool(np, "full-duplex");
 	if (of_property_read_u32(np, "speed", &status.speed))
@@ -296,5 +292,14 @@ int of_phy_register_fixed_link(struct device_node *np)
 
 	return fixed_phy_register(PHY_POLL, &status, np);
 }
-EXPORT_SYMBOL(of_phy_register_fixed_link);
+
+void of_phy_register_fixed_phys(void)
+{
+	struct device_node *np;
+
+	for_each_compatible_node(np, NULL, "fixed-eth-phy") {
+		of_phy_register_fixed_link(np);
+	}
+}
+
 #endif
diff --git a/include/linux/of_mdio.h b/include/linux/of_mdio.h
index 77a6e32..c8d080b 100644
--- a/include/linux/of_mdio.h
+++ b/include/linux/of_mdio.h
@@ -68,17 +68,9 @@ static inline struct mii_bus *of_mdio_find_bus(struct device_node *mdio_np)
 #endif /* CONFIG_OF */
 
 #if defined(CONFIG_OF) && defined(CONFIG_FIXED_PHY)
-extern int of_phy_register_fixed_link(struct device_node *np);
-extern bool of_phy_is_fixed_link(struct device_node *np);
+extern void of_phy_register_fixed_phys(void);
 #else
-static inline int of_phy_register_fixed_link(struct device_node *np)
-{
-	return -ENOSYS;
-}
-static inline bool of_phy_is_fixed_link(struct device_node *np)
-{
-	return false;
-}
+static inline void of_phy_register_fixed_phys(void) {};
 #endif
 
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
