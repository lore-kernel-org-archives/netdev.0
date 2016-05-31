From: Pramod Kumar <pramod.kumar@broadcom.com>
Subject: [PATCH v2 1/7] mdio:mux: Enhanced MDIO mux framework for integrated multiplexers
Date: Tue, 31 May 2016 19:06:35 +0530
Message-ID: <1464701801-17243-2-git-send-email-pramod.kumar@broadcom.com>
References: <1464701801-17243-1-git-send-email-pramod.kumar@broadcom.com>
Cc: devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	bcm-kernel-feedback-list@broadcom.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Pramod Kumar <pramod.kumar@broadcom.com>
To: Rob Herring <robh+dt@kernel.org>, Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Kishon Vijay Abraham I <kishon@ti.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:33199 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754528AbcEaNgV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 09:36:21 -0400
Received: by mail-pf0-f179.google.com with SMTP id b124so74657192pfb.0
        for <netdev@vger.kernel.org>; Tue, 31 May 2016 06:36:20 -0700 (PDT)
In-Reply-To: <1464701801-17243-1-git-send-email-pramod.kumar@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An integrated multiplexer uses same address space for
"muxed bus selection" and "generation of mdio transaction"
hence its good to register parent bus from mux driver.

Hence added a mechanism where mux driver could register a
parent bus and pass it down to framework via mdio_mux_init api.

Below changes are required to make this happen-

1. When mdio-mux parent bus is registered, mdio framework should not
parse for child as it will be muxed bus node not PHYs.

-created a new property "mdio-mux-bus-parent". if this property is present,
of_mdiobus_register will not scan for phys.

2. Passed down parent bus to mdio mux framework via mdio-mux-init api.

Signed-off-by: Pramod Kumar <pramod.kumar@broadcom.com>
---
 drivers/net/phy/mdio-mux-gpio.c    |  2 +-
 drivers/net/phy/mdio-mux-mmioreg.c |  2 +-
 drivers/net/phy/mdio-mux.c         | 28 ++++++++++++++++++----------
 drivers/of/of_mdio.c               |  3 +++
 include/linux/mdio-mux.h           |  4 +++-
 5 files changed, 26 insertions(+), 13 deletions(-)

diff --git a/drivers/net/phy/mdio-mux-gpio.c b/drivers/net/phy/mdio-mux-gpio.c
index 7ddb1ab..9199499 100644
--- a/drivers/net/phy/mdio-mux-gpio.c
+++ b/drivers/net/phy/mdio-mux-gpio.c
@@ -55,7 +55,7 @@ static int mdio_mux_gpio_probe(struct platform_device *pdev)
 		return PTR_ERR(s->gpios);
 
 	r = mdio_mux_init(&pdev->dev,
-			  mdio_mux_gpio_switch_fn, &s->mux_handle, s);
+			  mdio_mux_gpio_switch_fn, &s->mux_handle, s, NULL);
 
 	if (r != 0) {
 		gpiod_put_array(s->gpios);
diff --git a/drivers/net/phy/mdio-mux-mmioreg.c b/drivers/net/phy/mdio-mux-mmioreg.c
index 7fde454..d0bed52 100644
--- a/drivers/net/phy/mdio-mux-mmioreg.c
+++ b/drivers/net/phy/mdio-mux-mmioreg.c
@@ -126,7 +126,7 @@ static int mdio_mux_mmioreg_probe(struct platform_device *pdev)
 	}
 
 	ret = mdio_mux_init(&pdev->dev, mdio_mux_mmioreg_switch_fn,
-			    &s->mux_handle, s);
+			    &s->mux_handle, s, NULL);
 	if (ret) {
 		dev_err(&pdev->dev, "failed to register mdio-mux bus %s\n",
 			np->full_name);
diff --git a/drivers/net/phy/mdio-mux.c b/drivers/net/phy/mdio-mux.c
index 308ade0..521ab90 100644
--- a/drivers/net/phy/mdio-mux.c
+++ b/drivers/net/phy/mdio-mux.c
@@ -95,7 +95,8 @@ static int parent_count;
 int mdio_mux_init(struct device *dev,
 		  int (*switch_fn)(int cur, int desired, void *data),
 		  void **mux_handle,
-		  void *data)
+		  void *data,
+		  struct mii_bus *mux_bus)
 {
 	struct device_node *parent_bus_node;
 	struct device_node *child_bus_node;
@@ -107,10 +108,21 @@ int mdio_mux_init(struct device *dev,
 	if (!dev->of_node)
 		return -ENODEV;
 
-	parent_bus_node = of_parse_phandle(dev->of_node, "mdio-parent-bus", 0);
+	if (!mux_bus) {
+		parent_bus_node = of_parse_phandle(dev->of_node,
+						   "mdio-parent-bus", 0);
 
-	if (!parent_bus_node)
-		return -ENODEV;
+		if (!parent_bus_node)
+			return -ENODEV;
+
+		parent_bus = of_mdio_find_bus(parent_bus_node);
+		if (!parent_bus) {
+			ret_val = -EPROBE_DEFER;
+			goto err_parent_bus;
+		}
+	} else {
+		parent_bus = mux_bus;
+	}
 
 	pb = devm_kzalloc(dev, sizeof(*pb), GFP_KERNEL);
 	if (pb == NULL) {
@@ -118,11 +130,6 @@ int mdio_mux_init(struct device *dev,
 		goto err_parent_bus;
 	}
 
-	parent_bus = of_mdio_find_bus(parent_bus_node);
-	if (parent_bus == NULL) {
-		ret_val = -EPROBE_DEFER;
-		goto err_parent_bus;
-	}
 
 	pb->switch_data = data;
 	pb->switch_fn = switch_fn;
@@ -183,7 +190,8 @@ int mdio_mux_init(struct device *dev,
 	put_device(&pb->mii_bus->dev);
 
 err_parent_bus:
-	of_node_put(parent_bus_node);
+	if (!mux_bus)
+		of_node_put(parent_bus_node);
 	return ret_val;
 }
 EXPORT_SYMBOL_GPL(mdio_mux_init);
diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index 8453f08..cf40e7a 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -225,6 +225,9 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
 	if (rc)
 		return rc;
 
+	if (of_property_read_bool(np, "mdio-integrated-mux"))
+		return 0;
+
 	/* Loop over the child nodes and register a phy_device for each phy */
 	for_each_available_child_of_node(np, child) {
 		addr = of_mdio_parse_addr(&mdio->dev, child);
diff --git a/include/linux/mdio-mux.h b/include/linux/mdio-mux.h
index a243dbb..61f5b21 100644
--- a/include/linux/mdio-mux.h
+++ b/include/linux/mdio-mux.h
@@ -10,11 +10,13 @@
 #ifndef __LINUX_MDIO_MUX_H
 #define __LINUX_MDIO_MUX_H
 #include <linux/device.h>
+#include <linux/phy.h>
 
 int mdio_mux_init(struct device *dev,
 		  int (*switch_fn) (int cur, int desired, void *data),
 		  void **mux_handle,
-		  void *data);
+		  void *data,
+		  struct mii_bus *mux_bus);
 
 void mdio_mux_uninit(void *mux_handle);
 
-- 
1.9.1
