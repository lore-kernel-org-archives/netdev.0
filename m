From: Srinivas KANDAGATLA <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>
Subject: [PATCH v2 3.7.0-rc4] of/net/mdio-gpio: Fix pdev->id issue when using
 devicetrees.
Date: Fri, 16 Nov 2012 10:33:59 +0000
Message-ID: <1353062039-31336-1-git-send-email-srinivas.kandagatla@st.com>
References: <1352816773-17837-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, srinivas.kandagatla-qxv4g6HH51o@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1352816773-17837-1-git-send-email-srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>
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

From: Srinivas Kandagatla <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>

When the mdio-gpio driver is probed via device trees, the platform
device id is set as -1, However the pdev->id is re-used as bus-id for
while creating mdio gpio bus.
So
For device tree case the mdio-gpio bus name appears as "gpio-ffffffff"
where as
for non-device tree case the bus name appears as "gpio-<bus-num>"

Which means the bus_id is fixed in device tree case, so we can't have
two mdio gpio buses via device trees. Assigning a logical bus number
via device tree solves the problem and the bus name is much consistent
with non-device tree bus name.

Without this patch
1. we can't support two mdio-gpio buses via device trees.
2. we should always pass gpio-ffffffff as bus name to phy_connect, very
different to non-device tree bus name.

So, setting up the bus_id via aliases from device tree is the right
solution and other drivers do similar thing.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>
---
 .../devicetree/bindings/net/mdio-gpio.txt          |    9 ++++++++-
 drivers/net/phy/mdio-gpio.c                        |   11 +++++++----
 2 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/mdio-gpio.txt b/Documentation/devicetree/bindings/net/mdio-gpio.txt
index bc95495..c79bab0 100644
--- a/Documentation/devicetree/bindings/net/mdio-gpio.txt
+++ b/Documentation/devicetree/bindings/net/mdio-gpio.txt
@@ -8,9 +8,16 @@ gpios property as described in section VIII.1 in the following order:
 
 MDC, MDIO.
 
+Note: Each gpio-mdio bus should have an alias correctly numbered in "aliases"
+node.
+
 Example:
 
-mdio {
+aliases {
+	mdio-gpio0 = <&mdio0>;
+};
+
+mdio0: mdio {
 	compatible = "virtual,mdio-gpio";
 	#address-cells = <1>;
 	#size-cells = <0>;
diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index 899274f..2ed1140 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -185,17 +185,20 @@ static int __devinit mdio_gpio_probe(struct platform_device *pdev)
 {
 	struct mdio_gpio_platform_data *pdata;
 	struct mii_bus *new_bus;
-	int ret;
+	int ret, bus_id;
 
-	if (pdev->dev.of_node)
+	if (pdev->dev.of_node) {
 		pdata = mdio_gpio_of_get_data(pdev);
-	else
+		bus_id = of_alias_get_id(pdev->dev.of_node, "mdio-gpio");
+	} else {
 		pdata = pdev->dev.platform_data;
+		bus_id = pdev->id;
+	}
 
 	if (!pdata)
 		return -ENODEV;
 
-	new_bus = mdio_gpio_bus_init(&pdev->dev, pdata, pdev->id);
+	new_bus = mdio_gpio_bus_init(&pdev->dev, pdata, bus_id);
 	if (!new_bus)
 		return -ENODEV;
 
-- 
1.7.0.4
