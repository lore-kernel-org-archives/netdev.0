From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/4] Documentation: net: phy: Add blurb about RGMII
Date: Sat, 26 Nov 2016 22:01:32 -0800
Message-ID: <20161127060133.10357-4-f.fainelli@gmail.com>
References: <20161127060133.10357-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, sf84@laposte.net,
        martin.blumenstingl@googlemail.com, mans@mansr.com,
        alexandre.torgue@st.com, peppe.cavallaro@st.com,
        timur@codeaurora.org, jbrunet@baylibre.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:34149 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751314AbcK0GCL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 01:02:11 -0500
Received: by mail-oi0-f67.google.com with SMTP id m75so9706849oig.1
        for <netdev@vger.kernel.org>; Sat, 26 Nov 2016 22:01:49 -0800 (PST)
In-Reply-To: <20161127060133.10357-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RGMII is a recurring source of pain for people with Gigabit Ethernet
hardware since it may require PHY driver and MAC driver level
configuration hints. Document what are the expectations from PHYLIB and
what options exist.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 Documentation/networking/phy.txt | 56 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 56 insertions(+)

diff --git a/Documentation/networking/phy.txt b/Documentation/networking/phy.txt
index 9a42a9414cea..18e9f518b6f9 100644
--- a/Documentation/networking/phy.txt
+++ b/Documentation/networking/phy.txt
@@ -65,6 +65,62 @@ The MDIO bus
  drivers/net/ethernet/freescale/fsl_pq_mdio.c and an associated DTS file
  for one of the users. (e.g. "git grep fsl,.*-mdio arch/powerpc/boot/dts/")
 
+(RG)MII/electrical interface considerations
+
+ The Reduced Gigabit Medium Independent Interface (RGMII) is a 12 pins
+ electrical signal using a synchronous 125Mhz clock signal and several data
+ lines. Due to this design decision, a 1.5ns to 2ns delay must be added between
+ the clock line (RXC or TXC) and the data lines to let the sink (PHY or MAC)
+ have enough setup and hold times to sample the data lines correctly. The PHY
+ library offers different types of PHY_INTERFACE_MODE_RGMII* values to let the
+ PHY driver and optionaly the MAC driver implement the required delay. The
+ values of phy_interface_t must be understood from the perspective of the PHY
+ device itself, leading to the following:
+
+ * PHY_INTERFACE_MODE_RGMII: the PHY is not responsible for inserting any
+   internal delay by itself, it assumes that either the Ethernet MAC (if capable
+   or the PCB traces) insert the correct 1.5-2ns delay
+
+ * PHY_INTERFACE_MODE_RGMII_TXID: the PHY should be inserting a delay for the
+   transmit data lines (TXD[3:0]) processed by the PHY device
+
+ * PHY_INTERFACE_MODE_RGMII_RXID: the PHY should be inserting a delay for the
+   receive data lines (RXD[3:0]) processed by the PHY device
+
+ * PHY_INTERFACE_MODE_RGMII_ID: the PHY should be inserting a delay for both
+   transmit AND receive data lines from/to the PHY device
+
+ Whenever it is possible, it is preferrable to utilize the PHY side RGMII delay
+ for several reasons:
+
+ * PHY devices may offer sub-nanosecond granularity in how they allow a
+   receiver/transmitter side delay (e.g: 0.5, 1.0, 1.5ns) etc.
+
+ * PHY devices are typically qualified for a large range of temperatures, and
+   they provide a constant and reliable delay across
+   temperature/pressure/voltage ranges
+
+ * PHY device drivers in PHYLIB being reusable by nature, being able to
+   configure correctly a specified delay enables more designs with similar delay
+   requirements to be enabled
+
+ For cases where the PHY is not capable of providing this delay, but the
+ Ethernet MAC driver is capable of doing it, the correct phy_interface_t value
+ should be PHY_INTERFACE_MODE_RGMII, and the Ethernet MAC driver should be
+ configured correctly in order to provide the required transmit and/or receive
+ side delay from the perspective of the PHY device.
+
+ In case neither the Ethernet MAC, nor the PHY are capable of providing the
+ required delays, as defined per the RGMII standard, several options may be
+ available:
+
+ * Some SoCs may offer a pin pad/mux/controller capable of configuring a given
+   set of pins's drive strength, delays and voltage, and it may be a suitable
+   option to insert the expected 2ns RGMII delay
+
+ * Modifying the PCB design to include a fixed delay (e.g: using a specifically
+   designed serpentine), which may not require software configuration at all
+
 Connecting to a PHY
 
  Sometime during startup, the network driver needs to establish a connection
-- 
2.9.3
