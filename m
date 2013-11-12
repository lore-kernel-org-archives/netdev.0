From: <srinivas.kandagatla@st.com>
Subject: [PATCH RFC 04/10] drivers: reset: stih415: add softreset controller
Date: Tue, 12 Nov 2013 13:52:39 +0000
Message-ID: <1384264359-7482-1-git-send-email-srinivas.kandagatla@st.com>
References: <1384264311-7308-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rob Herring <rob.herring@calxeda.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Rob Landley <rob@landley.net>,
	Russell King <linux@arm.linux.org.uk>,
	Srinivas Kandagatla <srinivas.kandagatla@st.com>,
	Stuart Menefy <stuart.menefy@st.com>,
	Pavel Machek <pavel@ucw.cz>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Len Brown <len.brown@intel.com>, <stephen.gallimore@st.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Grant Likely <grant.likely@linaro.org>,
	<devicetree@vger.kernel.org>, <linux-doc@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <kernel@stlinux.com>,
	<linux-pm@vger.kernel.org>
To: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:47809 "EHLO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752448Ab3KLNyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 08:54:08 -0500
In-Reply-To: <1384264311-7308-1-git-send-email-srinivas.kandagatla@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

This patch adds softreset controller for STiH415 SOC, soft reset
controller is based on system configuration registers which are mapped
via regmap. This reset controller does not have any feedback or
acknowledgement. With this patch a new device "st,stih415-softreset" is
registered with system configuration registers based reset controller
that controls the softreset state of the hardware such as Ethernet, IRB.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
---
 .../devicetree/bindings/reset/st,sti-softreset.txt |   45 ++++++++++++++++++++
 arch/arm/boot/dts/stih415.dtsi                     |    5 ++
 drivers/reset/sti/reset-stih415.c                  |   22 ++++++++++
 .../dt-bindings/reset-controller/stih415-resets.h  |    4 ++
 4 files changed, 76 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/reset/st,sti-softreset.txt

diff --git a/Documentation/devicetree/bindings/reset/st,sti-softreset.txt b/Documentation/devicetree/bindings/reset/st,sti-softreset.txt
new file mode 100644
index 0000000..b2df262
--- /dev/null
+++ b/Documentation/devicetree/bindings/reset/st,sti-softreset.txt
@@ -0,0 +1,45 @@
+STMicroelectronics STi family Sysconfig Peripheral SoftReset Controller
+=============================================================================
+
+This binding describes a reset controller device that is used to enable and
+disable on-chip peripheral controllers such as USB and SATA, using
+"softreset" control bits found in the STi family SoC system configuration
+registers.
+
+The actual action taken when softreset is asserted is hardware dependent.
+However, when asserted it may not be possible to access the hardware's
+registers and after an assert/deassert sequence the hardware's previous state
+may no longer be valid.
+
+Please refer to reset.txt in this directory for common reset
+controller binding usage.
+
+Required properties:
+- compatible: Should be "st,<chip>-softreset"
+- #reset-cells: 1, see below
+
+example:
+
+	softreset: softreset-controller {
+		#reset-cells = <1>;
+		compatible = "st,stih415-softreset";
+	};
+
+
+Specifying softreset control of devices
+=======================================
+
+Device nodes should specify the reset channel required in their "resets"
+property, containing a phandle to the softreset device node and an
+index specifying which channel to use, as described in reset.txt
+
+example:
+
+	ethernet0{
+		resets			= <&softreset STIH415_ETH0_SOFTRESET>;
+	};
+
+Macro definitions for the supported reset channels can be found in:
+
+include/dt-bindings/reset-controller/stih415-resets.h
+include/dt-bindings/reset-controller/stih416-resets.h
diff --git a/arch/arm/boot/dts/stih415.dtsi b/arch/arm/boot/dts/stih415.dtsi
index 09379a6b..0c0776e 100644
--- a/arch/arm/boot/dts/stih415.dtsi
+++ b/arch/arm/boot/dts/stih415.dtsi
@@ -33,6 +33,11 @@
 			compatible = "st,stih415-powerdown";
 		};
 
+		softreset: softreset-controller {
+			#reset-cells = <1>;
+			compatible = "st,stih415-softreset";
+		};
+
 		syscfg_sbc: sbc-syscfg@fe600000{
 			compatible      = "st,stih415-sbc-syscfg", "syscon";
 			reg		= <0xfe600000 0xb4>;
diff --git a/drivers/reset/sti/reset-stih415.c b/drivers/reset/sti/reset-stih415.c
index 56c2146..fce5153 100644
--- a/drivers/reset/sti/reset-stih415.c
+++ b/drivers/reset/sti/reset-stih415.c
@@ -37,6 +37,10 @@ static const char stih415_lpm[] = "st,stih415-lpm-syscfg";
 #define SYSCFG_336	0x90 /* Powerdown request USB/SATA/PCIe */
 #define SYSSTAT_384	0x150 /* Powerdown status USB/SATA/PCIe */
 
+#define SYSCFG_166	0x108 /* Softreset Ethernet 0 */
+#define SYSCFG_31	0x7c /* Softreset Ethernet 1 */
+#define LPM_SYSCFG_1	0x4 /* Softreset IRB */
+
 static const struct syscfg_reset_channel_data stih415_powerdowns[] = {
 	[STIH415_EMISS_POWERDOWN]	= STIH415_PDN_FRONT(0),
 	[STIH415_NAND_POWERDOWN]	= STIH415_PDN_FRONT(1),
@@ -49,15 +53,33 @@ static const struct syscfg_reset_channel_data stih415_powerdowns[] = {
 	[STIH415_PCIE_POWERDOWN]	= STIH415_PDN_REAR(5, 8),
 };
 
+static const struct syscfg_reset_channel_data stih415_softresets[] = {
+	[STIH415_ETH0_SOFTRESET] = _SYSCFG_RST_CH_NO_ACK(stih415_front,
+							SYSCFG_166, 0),
+	[STIH415_ETH1_SOFTRESET] = _SYSCFG_RST_CH_NO_ACK(stih415_sbc,
+							SYSCFG_31, 0),
+	[STIH415_IRB_SOFTRESET]	 = _SYSCFG_RST_CH_NO_ACK(stih415_lpm,
+							LPM_SYSCFG_1, 6),
+};
+
 static struct syscfg_reset_controller_data stih415_powerdown_controller = {
 	.wait_for_ack = true,
 	.nr_channels = ARRAY_SIZE(stih415_powerdowns),
 	.channels = stih415_powerdowns,
 };
 
+static struct syscfg_reset_controller_data stih415_softreset_controller = {
+	.wait_for_ack = false,
+	.active_low = true,
+	.nr_channels = ARRAY_SIZE(stih415_softresets),
+	.channels = stih415_softresets,
+};
+
 static struct of_device_id stih415_reset_match[] = {
 	{ .compatible = "st,stih415-powerdown",
 	  .data = &stih415_powerdown_controller, },
+	{ .compatible = "st,stih415-softreset",
+	  .data = &stih415_softreset_controller, },
 	{},
 };
 
diff --git a/include/dt-bindings/reset-controller/stih415-resets.h b/include/dt-bindings/reset-controller/stih415-resets.h
index 2d54e68..825ed41 100644
--- a/include/dt-bindings/reset-controller/stih415-resets.h
+++ b/include/dt-bindings/reset-controller/stih415-resets.h
@@ -16,4 +16,8 @@
 #define STIH415_SATA1_POWERDOWN		7
 #define STIH415_PCIE_POWERDOWN		8
 
+#define STIH415_ETH0_SOFTRESET		0
+#define STIH415_ETH1_SOFTRESET		1
+#define STIH415_IRB_SOFTRESET		2
+
 #endif /* _DT_BINDINGS_RESET_CONTROLLER_STIH415 */
-- 
1.7.6.5
