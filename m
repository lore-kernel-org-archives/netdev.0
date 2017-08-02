From: Jonas Gorski <jonas.gorski@gmail.com>
Subject: [PATCH 4/8] tty/bcm63xx_uart: allow naming clock in device tree
Date: Wed,  2 Aug 2017 11:34:25 +0200
Message-ID: <20170802093429.12572-5-jonas.gorski@gmail.com>
References: <20170802093429.12572-1-jonas.gorski@gmail.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Ralf Baechle <ralf@linux-mips.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        bcm-kernel-feedback-list@broadcom.com,
        Kevin Cernekee <cernekee@gmail.com>,
        Jiri Slaby <jslaby@suse.com>,
        "David S. Miller" <davem@davemloft.net>,
        Russell King <linux@armlinux.org.uk>
To: linux-mips@linux-mips.org, linux-arm-kernel@lists.infradead.org,
        linux-serial@vger.kernel.org, devicetree@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33814 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752801AbdHBJfO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 05:35:14 -0400
In-Reply-To: <20170802093429.12572-1-jonas.gorski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Codify using a named clock for the refclk of the uart. This makes it
easier if we might need to add a gating clock (like present on the
BCM6345).

Signed-off-by: Jonas Gorski <jonas.gorski@gmail.com>
---
 Documentation/devicetree/bindings/serial/brcm,bcm6345-uart.txt | 6 ++++++
 drivers/tty/serial/bcm63xx_uart.c                              | 6 ++++--
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/Documentation/devicetree/bindings/serial/brcm,bcm6345-uart.txt b/Documentation/devicetree/bindings/serial/brcm,bcm6345-uart.txt
index 5c52e5eef16d..8b2b0460259a 100644
--- a/Documentation/devicetree/bindings/serial/brcm,bcm6345-uart.txt
+++ b/Documentation/devicetree/bindings/serial/brcm,bcm6345-uart.txt
@@ -11,6 +11,11 @@ Required properties:
 - clocks: Clock driving the hardware; used to figure out the baud rate
   divisor.
 
+
+Optional properties:
+
+- clock-names: Should be "refclk".
+
 Example:
 
 	uart0: serial@14e00520 {
@@ -19,6 +24,7 @@ Example:
 		interrupt-parent = <&periph_intc>;
 		interrupts = <2>;
 		clocks = <&periph_clk>;
+		clock-names = "refclk";
 	};
 
 	clocks {
diff --git a/drivers/tty/serial/bcm63xx_uart.c b/drivers/tty/serial/bcm63xx_uart.c
index a2b9376ec861..f227eff28d3a 100644
--- a/drivers/tty/serial/bcm63xx_uart.c
+++ b/drivers/tty/serial/bcm63xx_uart.c
@@ -841,8 +841,10 @@ static int bcm_uart_probe(struct platform_device *pdev)
 	if (!res_irq)
 		return -ENODEV;
 
-	clk = pdev->dev.of_node ? of_clk_get(pdev->dev.of_node, 0) :
-				  clk_get(&pdev->dev, "refclk");
+	clk = clk_get(&pdev->dev, "refclk");
+	if (IS_ERR(clk) && pdev->dev.of_node)
+		clk = of_clk_get(pdev->dev.of_node, 0);
+
 	if (IS_ERR(clk))
 		return -ENODEV;
 
-- 
2.13.2
