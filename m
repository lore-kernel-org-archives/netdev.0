From: Jamie Lentin <jm@lentin.co.uk>
Subject: [PATCH v0 03/10] arm: orion5x: Add clk support for mv88f5181
Date: Sat, 16 Jul 2016 15:29:01 +0100
Message-ID: <1468679348-10522-4-git-send-email-jm@lentin.co.uk>
References: <1468679348-10522-1-git-send-email-jm@lentin.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, Jamie Lentin <jm@lentin.co.uk>,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 netdev@vger.kernel.org
To: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Imre Kaloz <kaloz@openwrt.org>, Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1468679348-10522-1-git-send-email-jm@lentin.co.uk>
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

Referring to values in the u-boot port, add support for the mv88f5181

Signed-off-by: Jamie Lentin <jm@lentin.co.uk>
---
 .../devicetree/bindings/clock/mvebu-core-clock.txt |  1 +
 drivers/clk/mvebu/orion.c                          | 70 ++++++++++++++++++++++
 2 files changed, 71 insertions(+)

diff --git a/Documentation/devicetree/bindings/clock/mvebu-core-clock.txt b/Documentation/devicetree/bindings/clock/mvebu-core-clock.txt
index 670c2af..eb985a6 100644
--- a/Documentation/devicetree/bindings/clock/mvebu-core-clock.txt
+++ b/Documentation/devicetree/bindings/clock/mvebu-core-clock.txt
@@ -52,6 +52,7 @@ Required properties:
 	"marvell,dove-core-clock" - for Dove SoC core clocks
 	"marvell,kirkwood-core-clock" - for Kirkwood SoC (except mv88f6180)
 	"marvell,mv88f6180-core-clock" - for Kirkwood MV88f6180 SoC
+	"marvell,mv88f5181-core-clock" - for Orion MV88F5181 SoC
 	"marvell,mv88f5182-core-clock" - for Orion MV88F5182 SoC
 	"marvell,mv88f5281-core-clock" - for Orion MV88F5281 SoC
 	"marvell,mv88f6183-core-clock" - for Orion MV88F6183 SoC
diff --git a/drivers/clk/mvebu/orion.c b/drivers/clk/mvebu/orion.c
index fd12956..a6e5bee 100644
--- a/drivers/clk/mvebu/orion.c
+++ b/drivers/clk/mvebu/orion.c
@@ -21,6 +21,76 @@ static const struct coreclk_ratio orion_coreclk_ratios[] __initconst = {
 };
 
 /*
+ * Orion 5181
+ */
+
+#define SAR_MV88F5181_TCLK_FREQ      8
+#define SAR_MV88F5181_TCLK_FREQ_MASK 0x3
+
+static u32 __init mv88f5181_get_tclk_freq(void __iomem *sar)
+{
+	u32 opt = (readl(sar) >> SAR_MV88F5181_TCLK_FREQ) &
+		SAR_MV88F5181_TCLK_FREQ_MASK;
+	if (opt == 0)
+		return 133333333;
+	else if (opt == 1)
+		return 150000000;
+	else if (opt == 2)
+		return 166666667;
+	else
+		return 0;
+}
+
+#define SAR_MV88F5181_CPU_FREQ       4
+#define SAR_MV88F5181_CPU_FREQ_MASK  0xf
+
+static u32 __init mv88f5181_get_cpu_freq(void __iomem *sar)
+{
+	u32 opt = (readl(sar) >> SAR_MV88F5181_CPU_FREQ) &
+		SAR_MV88F5181_CPU_FREQ_MASK;
+	if (opt == 0)
+		return 333333333;
+	else if (opt == 1 || opt == 2)
+		return 400000000;
+	else if (opt == 3)
+		return 500000000;
+	else
+		return 0;
+}
+
+static void __init mv88f5181_get_clk_ratio(void __iomem *sar, int id,
+					   int *mult, int *div)
+{
+	u32 opt = (readl(sar) >> SAR_MV88F5181_CPU_FREQ) &
+		SAR_MV88F5181_CPU_FREQ_MASK;
+	if (opt == 0 || opt == 1) {
+		*mult = 1;
+		*div  = 2;
+	} else if (opt == 2 || opt == 3) {
+		*mult = 1;
+		*div  = 3;
+	} else {
+		*mult = 0;
+		*div  = 1;
+	}
+}
+
+static const struct coreclk_soc_desc mv88f5181_coreclks = {
+	.get_tclk_freq = mv88f5181_get_tclk_freq,
+	.get_cpu_freq = mv88f5181_get_cpu_freq,
+	.get_clk_ratio = mv88f5181_get_clk_ratio,
+	.ratios = orion_coreclk_ratios,
+	.num_ratios = ARRAY_SIZE(orion_coreclk_ratios),
+};
+
+static void __init mv88f5181_clk_init(struct device_node *np)
+{
+	return mvebu_coreclk_setup(np, &mv88f5181_coreclks);
+}
+
+CLK_OF_DECLARE(mv88f5181_clk, "marvell,mv88f5181-core-clock", mv88f5181_clk_init);
+
+/*
  * Orion 5182
  */
 
-- 
2.8.1
