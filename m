From: Pramod Kumar <pramod.kumar@broadcom.com>
Subject: [PATCH v3 RESEND 1/7] mdio:mux: Enhanced MDIO mux framework for integrated multiplexers
Date: Fri,  3 Jun 2016 21:33:00 +0530
Message-ID: <1464969786-22742-2-git-send-email-pramod.kumar@broadcom.com>
References: <1464969786-22742-1-git-send-email-pramod.kumar@broadcom.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464969786-22742-1-git-send-email-pramod.kumar@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

An integrated multiplexer uses same address space for
"muxed bus selection" and "generation of mdio transaction"
hence its good to register parent bus from mux driver.

Hence added a mechanism where mux driver could register a
parent bus and pass it down to framework via mdio_mux_init api.

Signed-off-by: Pramod Kumar <pramod.kumar@broadcom.com>
---
 drivers/net/phy/mdio-mux-gpio.c    |  2 +-
 drivers/net/phy/mdio-mux-mmioreg.c |  2 +-
 drivers/net/phy/mdio-mux.c         | 28 ++++++++++++++++++----------
 include/linux/mdio-mux.h           |  4 +++-
 4 files changed, 23 insertions(+), 13 deletions(-)

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
index 5c81d6f..dbd4ecc 100644
--- a/drivers/net/phy/mdio-mux.c
+++ b/drivers/net/phy/mdio-mux.c
@@ -89,7 +89,8 @@ static int parent_count;
 int mdio_mux_init(struct device *dev,
 		  int (*switch_fn)(int cur, int desired, void *data),
 		  void **mux_handle,
-		  void *data)
+		  void *data,
+		  struct mii_bus *mux_bus)
 {
 	struct device_node *parent_bus_node;
 	struct device_node *child_bus_node;
@@ -101,10 +102,21 @@ int mdio_mux_init(struct device *dev,
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
@@ -112,11 +124,6 @@ int mdio_mux_init(struct device *dev,
 		goto err_parent_bus;
 	}
 
-	parent_bus = of_mdio_find_bus(parent_bus_node);
-	if (parent_bus == NULL) {
-		ret_val = -EPROBE_DEFER;
-		goto err_parent_bus;
-	}
 
 	pb->switch_data = data;
 	pb->switch_fn = switch_fn;
@@ -177,7 +184,8 @@ int mdio_mux_init(struct device *dev,
 	put_device(&pb->mii_bus->dev);
 
 err_parent_bus:
-	of_node_put(parent_bus_node);
+	if (!mux_bus)
+		of_node_put(parent_bus_node);
 	return ret_val;
 }
 EXPORT_SYMBOL_GPL(mdio_mux_init);
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
