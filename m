From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH net-next 1/2] net: mdio-mux-mmioreg: Add support for 16bit and 32bit register sizes
Date: Fri,  4 Nov 2016 16:51:22 +0100
Message-ID: <1478274683-1503-2-git-send-email-narmstrong@baylibre.com>
References: <1478274683-1503-1-git-send-email-narmstrong@baylibre.com>
Cc: Neil Armstrong <narmstrong@baylibre.com>, netdev@vger.kernel.org,
        linux-amlogic@lists.infradead.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: f.fainelli@gmail.com, carlo@caione.org, khilman@baylibre.com,
        andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:35749 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755401AbcKDPvb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 11:51:31 -0400
Received: by mail-wm0-f43.google.com with SMTP id a197so59548609wmd.0
        for <netdev@vger.kernel.org>; Fri, 04 Nov 2016 08:51:30 -0700 (PDT)
In-Reply-To: <1478274683-1503-1-git-send-email-narmstrong@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to support PHY switching on Amlogic GXL SoCs, add support for
16bit and 32bit registers sizes.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 .../devicetree/bindings/net/mdio-mux-mmioreg.txt   |  4 +-
 drivers/net/phy/mdio-mux-mmioreg.c                 | 60 +++++++++++++++++-----
 2 files changed, 49 insertions(+), 15 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/mdio-mux-mmioreg.txt b/Documentation/devicetree/bindings/net/mdio-mux-mmioreg.txt
index 8516929..065e8bd 100644
--- a/Documentation/devicetree/bindings/net/mdio-mux-mmioreg.txt
+++ b/Documentation/devicetree/bindings/net/mdio-mux-mmioreg.txt
@@ -3,7 +3,7 @@ Properties for an MDIO bus multiplexer controlled by a memory-mapped device
 This is a special case of a MDIO bus multiplexer.  A memory-mapped device,
 like an FPGA, is used to control which child bus is connected.  The mdio-mux
 node must be a child of the memory-mapped device.  The driver currently only
-supports devices with eight-bit registers.
+supports devices with 8, 16 or 32-bit registers.
 
 Required properties in addition to the generic multiplexer properties:
 
@@ -11,7 +11,7 @@ Required properties in addition to the generic multiplexer properties:
 
 - reg : integer, contains the offset of the register that controls the bus
 	multiplexer.  The size field in the 'reg' property is the size of
-	register, and must therefore be 1.
+	register, and must therefore be 1, 2, or 4.
 
 - mux-mask : integer, contains an eight-bit mask that specifies which
 	bits in the register control the actual bus multiplexer.  The
diff --git a/drivers/net/phy/mdio-mux-mmioreg.c b/drivers/net/phy/mdio-mux-mmioreg.c
index d0bed52..6a33646 100644
--- a/drivers/net/phy/mdio-mux-mmioreg.c
+++ b/drivers/net/phy/mdio-mux-mmioreg.c
@@ -21,7 +21,8 @@
 struct mdio_mux_mmioreg_state {
 	void *mux_handle;
 	phys_addr_t phys;
-	uint8_t mask;
+	unsigned int iosize;
+	unsigned int mask;
 };
 
 /*
@@ -47,17 +48,47 @@ static int mdio_mux_mmioreg_switch_fn(int current_child, int desired_child,
 	struct mdio_mux_mmioreg_state *s = data;
 
 	if (current_child ^ desired_child) {
-		void __iomem *p = ioremap(s->phys, 1);
-		uint8_t x, y;
-
+		void __iomem *p = ioremap(s->phys, s->iosize);
 		if (!p)
 			return -ENOMEM;
 
-		x = ioread8(p);
-		y = (x & ~s->mask) | desired_child;
-		if (x != y) {
-			iowrite8((x & ~s->mask) | desired_child, p);
-			pr_debug("%s: %02x -> %02x\n", __func__, x, y);
+		switch (s->iosize) {
+		case sizeof(uint8_t): {
+			uint8_t x, y;
+
+			x = ioread8(p);
+			y = (x & ~s->mask) | desired_child;
+			if (x != y) {
+				iowrite8((x & ~s->mask) | desired_child, p);
+				pr_debug("%s: %02x -> %02x\n", __func__, x, y);
+			}
+
+			break;
+		}
+		case sizeof(uint16_t): {
+			uint16_t x, y;
+
+			x = ioread16(p);
+			y = (x & ~s->mask) | desired_child;
+			if (x != y) {
+				iowrite16((x & ~s->mask) | desired_child, p);
+				pr_debug("%s: %04x -> %04x\n", __func__, x, y);
+			}
+
+			break;
+		}
+		case sizeof(uint32_t): {
+			uint32_t x, y;
+
+			x = ioread32(p);
+			y = (x & ~s->mask) | desired_child;
+			if (x != y) {
+				iowrite32((x & ~s->mask) | desired_child, p);
+				pr_debug("%s: %08x -> %08x\n", __func__, x, y);
+			}
+
+			break;
+		}
 		}
 
 		iounmap(p);
@@ -88,8 +119,11 @@ static int mdio_mux_mmioreg_probe(struct platform_device *pdev)
 	}
 	s->phys = res.start;
 
-	if (resource_size(&res) != sizeof(uint8_t)) {
-		dev_err(&pdev->dev, "only 8-bit registers are supported\n");
+	s->iosize = resource_size(&res);
+	if (s->iosize != sizeof(uint8_t) &&
+	    s->iosize != sizeof(uint16_t) &&
+	    s->iosize != sizeof(uint32_t)) {
+		dev_err(&pdev->dev, "only 8/16/32-bit registers are supported\n");
 		return -EINVAL;
 	}
 
@@ -98,8 +132,8 @@ static int mdio_mux_mmioreg_probe(struct platform_device *pdev)
 		dev_err(&pdev->dev, "missing or invalid mux-mask property\n");
 		return -ENODEV;
 	}
-	if (be32_to_cpup(iprop) > 255) {
-		dev_err(&pdev->dev, "only 8-bit registers are supported\n");
+	if (be32_to_cpup(iprop) >= BIT(s->iosize * 8)) {
+		dev_err(&pdev->dev, "only 8/16/32-bit registers are supported\n");
 		return -EINVAL;
 	}
 	s->mask = be32_to_cpup(iprop);
-- 
1.9.1
