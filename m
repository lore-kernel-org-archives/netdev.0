From: Ramesh Shanmugasundaram <ramesh.shanmugasundaram-kTT6dE0pTRh9uiUsa/gSgQ@public.gmane.org>
Subject: [PATCH 1/2] can: rcar_can: Add r8a7795 support
Date: Mon, 29 Feb 2016 09:21:00 +0000
Message-ID: <1456737661-20538-2-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
References: <1456737661-20538-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
Cc: linux-renesas-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, chris.paterson2-zM6kxYcvzFBBDgjK7y7TUQ@public.gmane.org,
	Ramesh Shanmugasundaram <ramesh.shanmugasundaram-kTT6dE0pTRh9uiUsa/gSgQ@public.gmane.org>
To: mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org, horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org,
	magnus.damm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org,
	mark.rutland-5wv7dgnIgG8@public.gmane.org, ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org,
	galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1456737661-20538-1-git-send-email-ramesh.shanmugasundaram-kTT6dE0pTRh9uiUsa/gSgQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Added r8a7795 SoC support.

For smoother bit timing calculation, the rounded clock frequency is used.

Signed-off-by: Ramesh Shanmugasundaram <ramesh.shanmugasundaram-kTT6dE0pTRh9uiUsa/gSgQ@public.gmane.org>
---
 Documentation/devicetree/bindings/net/can/rcar_can.txt | 12 ++++++++++++
 drivers/net/can/Kconfig                                |  2 +-
 drivers/net/can/rcar_can.c                             |  7 ++++++-
 3 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/can/rcar_can.txt b/Documentation/devicetree/bindings/net/can/rcar_can.txt
index 002d844..7f1305f 100644
--- a/Documentation/devicetree/bindings/net/can/rcar_can.txt
+++ b/Documentation/devicetree/bindings/net/can/rcar_can.txt
@@ -6,6 +6,9 @@ Required properties:
 	      "renesas,can-r8a7779" if CAN controller is a part of R8A7779 SoC.
 	      "renesas,can-r8a7790" if CAN controller is a part of R8A7790 SoC.
 	      "renesas,can-r8a7791" if CAN controller is a part of R8A7791 SoC.
+	      "renesas,can-r8a7795" if CAN controller is a part of R8A7795 SoC.
+	      "renesas,rcar-gen3-can" for a generic R-Car Gen3 compatible device.
+
 - reg: physical base address and size of the R-Car CAN register map.
 - interrupts: interrupt specifier for the sole interrupt.
 - clocks: phandles and clock specifiers for 3 CAN clock inputs.
@@ -13,6 +16,15 @@ Required properties:
 - pinctrl-0: pin control group to be used for this controller.
 - pinctrl-names: must be "default".
 
+Required properties for "renesas,can-r8a7795" compatible:
+In R8A7795 SoC, "clkp2" can be CANFD clock. This is a div6 clock and can be
+used by both CAN and CAN FD controller at the same time. It needs to be scaled
+to maximum frequency if any of these controllers use it. This is done using
+the below properties.
+
+- assigned-clocks: phandle of clkp2(CANFD) clock.
+- assigned-clock-rates: maximum frequency of this clock.
+
 Optional properties:
 - renesas,can-clock-select: R-Car CAN Clock Source Select. Valid values are:
 			    <0x0> (default) : Peripheral clock (clkp1)
diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
index 164ccde..0d40aef 100644
--- a/drivers/net/can/Kconfig
+++ b/drivers/net/can/Kconfig
@@ -106,7 +106,7 @@ config CAN_JANZ_ICAN3
 
 config CAN_RCAR
 	tristate "Renesas R-Car CAN controller"
-	depends on ARM
+	depends on ARCH_RENESAS || ARM
 	---help---
 	  Say Y here if you want to use CAN controller found on Renesas R-Car
 	  SoCs.
diff --git a/drivers/net/can/rcar_can.c b/drivers/net/can/rcar_can.c
index bc46be3..55e34de 100644
--- a/drivers/net/can/rcar_can.c
+++ b/drivers/net/can/rcar_can.c
@@ -808,6 +808,10 @@ static int rcar_can_probe(struct platform_device *pdev)
 	priv->regs = addr;
 	priv->clock_select = clock_select;
 	priv->can.clock.freq = clk_get_rate(priv->can_clk);
+
+	/* Use the rounded clock value (nearest kHz) */
+	priv->can.clock.freq = 1000 * DIV_ROUND_UP(priv->can.clock.freq, 1000);
+
 	priv->can.bittiming_const = &rcar_can_bittiming_const;
 	priv->can.do_set_mode = rcar_can_do_set_mode;
 	priv->can.do_get_berr_counter = rcar_can_get_berr_counter;
@@ -904,7 +908,8 @@ static const struct of_device_id rcar_can_of_table[] __maybe_unused = {
 	{ .compatible = "renesas,can-r8a7779" },
 	{ .compatible = "renesas,can-r8a7790" },
 	{ .compatible = "renesas,can-r8a7791" },
-	{ }
+	{ .compatible = "renesas,rcar-gen3-can" },
+	{ },
 };
 MODULE_DEVICE_TABLE(of, rcar_can_of_table);
 
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
