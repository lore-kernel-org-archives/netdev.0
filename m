From: Pantelis Antoniou <pantelis.antoniou@konsulko.com>
Subject: [PATCH 06/10] gpio: sam: Document bindings of SAM FPGA GPIO block
Date: Fri,  7 Oct 2016 18:18:34 +0300
Message-ID: <1475853518-22264-7-git-send-email-pantelis.antoniou@konsulko.com>
References: <1475853518-22264-1-git-send-email-pantelis.antoniou@konsulko.com>
Cc: Linus Walleij <linus.walleij@linaro.org>,
        Alexandre Courbot <gnurou@gmail.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Frank Rowand <frowand.list@gmail.com>,
        Wolfram Sang <wsa@the-dreams.de>,
        David Woodhouse <dwmw2@infradead.org>,
        Brian Norris <computersforpeace@gmail.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Wim Van Sebroeck <wim@iguana.be>,
        Peter Rosin <peda@axentia.se>,
        Debjit Ghosh <dghosh@juniper.net>,
        Georgi Vlaev <gvlaev@juniper.net>,
        Guenter Roeck <linux@roeck-us.net>,
        Maryam Seraj <mseraj@juniper.net>,
        Pantelis Antoniou <pantelis.antoniou@konsulko.com>,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-gpio@vger.kernel.org, linux-i2c@vger.kernel.org,
        linux-mtd@lists.infradead.org, li
To: Lee Jones <lee.jones@linaro.org>
Return-path: <linux-gpio-owner@vger.kernel.org>
In-Reply-To: <1475853518-22264-1-git-send-email-pantelis.antoniou@konsulko.com>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Georgi Vlaev <gvlaev@juniper.net>

Add device tree bindings document for the GPIO driver of
Juniper's SAM FPGA.

Signed-off-by: Georgi Vlaev <gvlaev@juniper.net>
[Ported from Juniper kernel]
Signed-off-by: Pantelis Antoniou <pantelis.antoniou@konsulko.com>
---
 .../devicetree/bindings/gpio/jnx,gpio-sam.txt      | 110 +++++++++++++++++++++
 1 file changed, 110 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/gpio/jnx,gpio-sam.txt

diff --git a/Documentation/devicetree/bindings/gpio/jnx,gpio-sam.txt b/Documentation/devicetree/bindings/gpio/jnx,gpio-sam.txt
new file mode 100644
index 0000000..514c350
--- /dev/null
+++ b/Documentation/devicetree/bindings/gpio/jnx,gpio-sam.txt
@@ -0,0 +1,110 @@
+Juniper SAM FPGA GPIO block
+
+The controller's registers are organized as sets of eight 32-bit
+registers with each set controlling a bank of up to 32 pins.  A single
+interrupt is shared for all of the banks handled by the controller.
+
+Required properties:
+
+- compatible:
+    Must be "jnx,gpio-sam"
+
+- #gpio-cells:
+    Should be <2>.  The first cell is the pin number (within the controller's
+    pin space), and the second is used for the following flags:
+	bit[0]: direction (0 = out, 1 = in)
+	bit[1]: init high
+	bit[2]: active low
+	bit[3]: open drain
+	bit[4]: open drain
+
+- gpio-controller:
+    Specifies that the node is a GPIO controller.
+
+Optional properties:
+
+- reg:
+    This driver is part of the SAM FPGA MFD driver, so the
+    address range is supplied by that driver. However you can
+    override using this property.
+
+- gpio-base:
+    Base of the GPIO pins of this instance. If not present use system allocated.
+
+- gpio-count:
+    Number of GPIO pins of this instance. If not present read the number from
+    the one configured in the FPGA data. Maximum number is 512.
+
+- #interrupt-cells:
+    Should be <2>.  The first cell is the GPIO number, the second should specify
+    flags.  The following subset of flags is supported:
+    - bits[16,4:0] trigger type and level flags
+	bit  0: rising edge interrupt
+	bit  1: falling edge interrupt
+	bit  2: active high interrupt
+	bit  3: active low interrupt
+	bit  4: enable debounce
+	bit 16: signal is active low
+    See also Documentation/devicetree/bindings/interrupt-controller/interrupts.txt
+
+- gpio-interrupts:
+    A number of triples that define the mapping of interrupt groupsb to a range of
+    pins. The first cell defines the interrupt group, the second is the start of
+    the pin range and the third the number of pins in the range.
+
+- gpio-exports:
+    A subnode containing the list of pins that will be exported to user-space.
+    Each subnode contains:
+    Required properties:
+	- pin: The gpio to be exported and the relevant flags.
+    Optional properties:
+        - label: The label to use for export; if not supplied use the node name.
+
+Example:
+
+gpio20: gpio-sam {
+	compatible = "jnx,gpio-sam";
+	gpio-controller;
+	interrupt-controller;
+	/* 1st cell: gpio pin
+	 * 2nd cell: flags (bit mask)
+	 * bit  0: rising edge interrupt
+	 * bit  1: falling edge interrupt
+	 * bit  2: active high interrupt
+	 * bit  3: active low interrupt
+	 * bit  4: enable debounce
+	 * bit 16: signal is active low
+	 */
+	#interrupt-cells = <2>;
+	#gpio-cells = <2>;
+	gpio-count = <340>;
+	/* 1st cell: gpio interrupt status bit
+	 * 2nd cell: 1st pin
+	 * 3rd cell: # of pins
+	 */
+	gpio-interrupts =
+		<0 0 32>,	/* TL / TQ */
+		<1 32 32>,	/* PIC 1 */
+		<2 32 32>,	/* PIC 1 spare */
+		<7 148 32>,	/* PIC 0 */
+		<8 170 32>,	/* PIC 0 spare */
+		<16 318 22>;	/* FPC */
+
+	gpio-exports {
+		/*
+		 * flags:
+		 * GPIOF_DIR_IN			bit 0=1
+		 * GPIOF_DIR_OUT		bit 0=0
+		 * GPIOF_INIT_HIGH		bit 1=1
+		 *   GPIOF_INIT_HIGH is raw, not translated
+		 * GPIOF_ACTIVE_LOW		bit 2=1
+		 * GPIOF_OPEN_DRAIN		bit 3=1
+		 * GPIOF_OPEN_SOURCE		bit 4=1
+		 * GPIOF_EXPORT			bit 5=1
+		 * GPIOF_EXPORT_CHANGEABLE      bit 6=1
+		 */
+		tl0-rst {
+			pin = < 8 0x24 >;
+		};
+	};
+};
-- 
1.9.1

