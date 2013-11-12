From: <srinivas.kandagatla@st.com>
Subject: [PATCH RFC 05/10] drivers: reset: stih416: add softreset controller
Date: Tue, 12 Nov 2013 13:52:45 +0000
Message-ID: <1384264365-7523-1-git-send-email-srinivas.kandagatla@st.com>
References: <1384264311-7308-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, Len Brown <len.brown@intel.com>,
 Russell King <linux@arm.linux.org.uk>, Pavel Machek <pavel@ucw.cz>,
 Pawel Moll <pawel.moll@arm.com>, Ian Campbell <ijc+devicetree@hellion.org.uk>,
 Srinivas Kandagatla <srinivas.kandagatla@st.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-pm@vger.kernel.org,
 Stephen Warren <swarren@wwwdotorg.org>,
 "Rafael J. Wysocki" <rjw@rjwysocki.net>, stephen.gallimore@st.com,
 Rob Herring <rob.herring@calxeda.com>, linux-doc@vger.kernel.org,
 Stuart Menefy <stuart.menefy@st.com>, devicetree@vger.kernel.org,
 Rob Landley <rob@landley.net>, Grant Likely <grant.likely@linaro.org>,
 Giuseppe Cavallaro <peppe.cavallaro@st.com>, linux-kernel@vger.kernel.org,
 kernel@stlinux.com
To: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1384264311-7308-1-git-send-email-srinivas.kandagatla@st.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

This patch adds softreset controller for STiH416 SOC, soft reset
controller is based on system configuration registers which are mapped
via regmap. This reset controller does not have any feedback or
acknowledgement. With this patch a new device "st,stih416-softreset" is
registered with system configuration registers based reset controller
that controls the softreset state of the hardware such as Ethernet, IRB.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
---
 arch/arm/boot/dts/stih416.dtsi                     |    5 ++++
 drivers/reset/sti/reset-stih416.c                  |   22 ++++++++++++++++++++
 .../dt-bindings/reset-controller/stih416-resets.h  |    4 +++
 3 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/arch/arm/boot/dts/stih416.dtsi b/arch/arm/boot/dts/stih416.dtsi
index b8cabbb..a3831a3 100644
--- a/arch/arm/boot/dts/stih416.dtsi
+++ b/arch/arm/boot/dts/stih416.dtsi
@@ -32,6 +32,11 @@
 			compatible = "st,stih416-powerdown";
 		};
 
+		softreset: softreset-controller {
+			#reset-cells = <1>;
+			compatible = "st,stih416-softreset";
+		};
+
 		syscfg_sbc:sbc-syscfg@fe600000{
 			compatible	= "st,stih416-sbc-syscfg", "syscon";
 			reg		= <0xfe600000 0x1000>;
diff --git a/drivers/reset/sti/reset-stih416.c b/drivers/reset/sti/reset-stih416.c
index 0becfc5..685fd3b 100644
--- a/drivers/reset/sti/reset-stih416.c
+++ b/drivers/reset/sti/reset-stih416.c
@@ -37,6 +37,10 @@ static const char stih416_lpm[] = "st,stih416-lpm-syscfg";
 #define SYSCFG_2525	0x834 /* Powerdown request USB/SATA/PCIe */
 #define SYSSTAT_2583	0x91c /* Powerdown status USB/SATA/PCIe */
 
+#define SYSCFG_1539	0x86c /* Softreset Ethernet 0 */
+#define SYSCFG_510	0x7f8 /* Softreset Ethernet 1 */
+#define LPM_SYSCFG_1	0x4 /* Softreset IRB */
+
 static const struct syscfg_reset_channel_data stih416_powerdowns[] = {
 	[STIH416_EMISS_POWERDOWN]	= STIH416_PDN_FRONT(0),
 	[STIH416_NAND_POWERDOWN]	= STIH416_PDN_FRONT(1),
@@ -51,15 +55,33 @@ static const struct syscfg_reset_channel_data stih416_powerdowns[] = {
 	[STIH416_PCIE1_POWERDOWN]	= STIH416_PDN_REAR(5, 8),
 };
 
+static const struct syscfg_reset_channel_data stih416_softresets[] = {
+	[STIH416_ETH0_SOFTRESET] = _SYSCFG_RST_CH_NO_ACK(stih416_front,
+							SYSCFG_1539, 0),
+	[STIH416_ETH1_SOFTRESET] = _SYSCFG_RST_CH_NO_ACK(stih416_sbc,
+							SYSCFG_510, 0),
+	[STIH416_IRB_SOFTRESET]	 = _SYSCFG_RST_CH_NO_ACK(stih416_lpm,
+							LPM_SYSCFG_1, 6),
+};
+
 static struct syscfg_reset_controller_data stih416_powerdown_controller = {
 	.wait_for_ack	= true,
 	.nr_channels	= ARRAY_SIZE(stih416_powerdowns),
 	.channels	= stih416_powerdowns,
 };
 
+static struct syscfg_reset_controller_data stih416_softreset_controller = {
+	.wait_for_ack = false,
+	.active_low = true,
+	.nr_channels = ARRAY_SIZE(stih416_softresets),
+	.channels = stih416_softresets,
+};
+
 static struct of_device_id stih416_reset_match[] = {
 	{ .compatible = "st,stih416-powerdown",
 	  .data = &stih416_powerdown_controller, },
+	{ .compatible = "st,stih416-softreset",
+	  .data = &stih416_softreset_controller, },
 	{},
 };
 
diff --git a/include/dt-bindings/reset-controller/stih416-resets.h b/include/dt-bindings/reset-controller/stih416-resets.h
index d7da55f..ee8ccd0 100644
--- a/include/dt-bindings/reset-controller/stih416-resets.h
+++ b/include/dt-bindings/reset-controller/stih416-resets.h
@@ -18,4 +18,8 @@
 #define STIH416_PCIE0_POWERDOWN		9
 #define STIH416_PCIE1_POWERDOWN		10
 
+#define STIH416_ETH0_SOFTRESET		0
+#define STIH416_ETH1_SOFTRESET		1
+#define STIH416_IRB_SOFTRESET		2
+
 #endif /* _DT_BINDINGS_RESET_CONTROLLER_STIH416 */
-- 
1.7.6.5
