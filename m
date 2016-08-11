From: Dongpo Li <lidongpo@hisilicon.com>
Subject: [PATCH 3/4] clk: hix5hd2: change ethernet clock type
Date: Thu, 11 Aug 2016 17:01:54 +0800
Message-ID: <1470906115-155569-4-git-send-email-lidongpo@hisilicon.com>
References: <1470906115-155569-1-git-send-email-lidongpo@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <xuejiancheng@hisilicon.com>, <benjamin.chenhao@hisilicon.com>,
	<howell.yang@hisilicon.com>, <netdev@vger.kernel.org>,
	<devicetree@vger.kernel.org>, <linux-clk@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, Dongpo Li <lidongpo@hisilicon.com>
To: <robh+dt@kernel.org>, <mark.rutland@arm.com>,
	<mturquette@baylibre.com>, <sboyd@codeaurora.org>,
	<linux@armlinux.org.uk>, <zhangfei.gao@linaro.org>,
	<yisen.zhuang@huawei.com>, <salil.mehta@huawei.com>,
	<davem@davemloft.net>, <arnd@arndb.de>, <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470906115-155569-1-git-send-email-lidongpo@hisilicon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Because the clock and reset signals share the same register,
we initialize reset controller when initializing clock controller.
So the ethernet driver will control the reset signal instead of
the clock driver.
All the ethernet clock is changed from complex clock to gate clock.
The original ethernet clock is really a "complex" clock because
it's obscure and hard to understand.

Signed-off-by: Dongpo Li <lidongpo@hisilicon.com>
---
 drivers/clk/hisilicon/clk-hix5hd2.c       | 72 +++++++------------------------
 include/dt-bindings/clock/hix5hd2-clock.h |  6 ++-
 2 files changed, 20 insertions(+), 58 deletions(-)

diff --git a/drivers/clk/hisilicon/clk-hix5hd2.c b/drivers/clk/hisilicon/clk-hix5hd2.c
index 14b05ef..f9689e3 100644
--- a/drivers/clk/hisilicon/clk-hix5hd2.c
+++ b/drivers/clk/hisilicon/clk-hix5hd2.c
@@ -12,6 +12,7 @@
 #include <linux/slab.h>
 #include <linux/delay.h>
 #include "clk.h"
+#include "reset.h"
 
 static struct hisi_fixed_rate_clock hix5hd2_fixed_rate_clks[] __initdata = {
 	{ HIX5HD2_FIXED_1200M, "1200m", NULL, 0, 1200000000, },
@@ -93,8 +94,12 @@ static struct hisi_gate_clock hix5hd2_gate_clks[] __initdata = {
 	/* gsf */
 	{ HIX5HD2_FWD_BUS_CLK, "clk_fwd_bus", NULL, 0, 0xcc, 0, 0, },
 	{ HIX5HD2_FWD_SYS_CLK, "clk_fwd_sys", "clk_fwd_bus", 0, 0xcc, 5, 0, },
-	{ HIX5HD2_MAC0_PHY_CLK, "clk_fephy", "clk_fwd_sys",
-		 CLK_SET_RATE_PARENT, 0x120, 0, 0, },
+	{ HIX5HD2_MAC0_CLK, "clk_mac0", "clk_fwd_sys", 0, 0xcc, 1, 0, },
+	{ HIX5HD2_MAC_IFC0_CLK, "clk_mac_ifc0", "clk_fwd_sys", 0, 0xcc, 3, 0, },
+	{ HIX5HD2_MAC1_CLK, "clk_mac1", "clk_fwd_sys", 0, 0xcc, 2, 0, },
+	{ HIX5HD2_MAC_IFC1_CLK, "clk_mac_ifc1", "clk_fwd_sys", 0, 0xcc, 4, 0, },
+	{ HIX5HD2_MAC0_PHY_CLK, "clk_fephy", NULL,
+		 CLK_SET_RATE_PARENT | CLK_IGNORE_UNUSED, 0x120, 0, 0, },
 	/* wdg0 */
 	{ HIX5HD2_WDG0_CLK, "clk_wdg0", "24m",
 		CLK_SET_RATE_PARENT, 0x178, 0, 0, },
@@ -129,7 +134,6 @@ static struct hisi_gate_clock hix5hd2_gate_clks[] __initdata = {
 
 enum hix5hd2_clk_type {
 	TYPE_COMPLEX,
-	TYPE_ETHER,
 };
 
 struct hix5hd2_complex_clock {
@@ -157,10 +161,6 @@ struct hix5hd2_clk_complex {
 };
 
 static struct hix5hd2_complex_clock hix5hd2_complex_clks[] __initdata = {
-	{"clk_mac0", "clk_fephy", HIX5HD2_MAC0_CLK,
-		0xcc, 0xa, 0x500, 0x120, 0, 0x10, TYPE_ETHER},
-	{"clk_mac1", "clk_fwd_sys", HIX5HD2_MAC1_CLK,
-		0xcc, 0x14, 0xa00, 0x168, 0x2, 0, TYPE_ETHER},
 	{"clk_sata", NULL, HIX5HD2_SATA_CLK,
 		0xa8, 0x1f, 0x300, 0xac, 0x1, 0x0, TYPE_COMPLEX},
 	{"clk_usb", NULL, HIX5HD2_USB_CLK,
@@ -169,50 +169,6 @@ static struct hix5hd2_complex_clock hix5hd2_complex_clks[] __initdata = {
 
 #define to_complex_clk(_hw) container_of(_hw, struct hix5hd2_clk_complex, hw)
 
-static int clk_ether_prepare(struct clk_hw *hw)
-{
-	struct hix5hd2_clk_complex *clk = to_complex_clk(hw);
-	u32 val;
-
-	val = readl_relaxed(clk->ctrl_reg);
-	val |= clk->ctrl_clk_mask | clk->ctrl_rst_mask;
-	writel_relaxed(val, clk->ctrl_reg);
-	val &= ~(clk->ctrl_rst_mask);
-	writel_relaxed(val, clk->ctrl_reg);
-
-	val = readl_relaxed(clk->phy_reg);
-	val |= clk->phy_clk_mask;
-	val &= ~(clk->phy_rst_mask);
-	writel_relaxed(val, clk->phy_reg);
-	mdelay(10);
-
-	val &= ~(clk->phy_clk_mask);
-	val |= clk->phy_rst_mask;
-	writel_relaxed(val, clk->phy_reg);
-	mdelay(10);
-
-	val |= clk->phy_clk_mask;
-	val &= ~(clk->phy_rst_mask);
-	writel_relaxed(val, clk->phy_reg);
-	mdelay(30);
-	return 0;
-}
-
-static void clk_ether_unprepare(struct clk_hw *hw)
-{
-	struct hix5hd2_clk_complex *clk = to_complex_clk(hw);
-	u32 val;
-
-	val = readl_relaxed(clk->ctrl_reg);
-	val &= ~(clk->ctrl_clk_mask);
-	writel_relaxed(val, clk->ctrl_reg);
-}
-
-static struct clk_ops clk_ether_ops = {
-	.prepare = clk_ether_prepare,
-	.unprepare = clk_ether_unprepare,
-};
-
 static int clk_complex_enable(struct clk_hw *hw)
 {
 	struct hix5hd2_clk_complex *clk = to_complex_clk(hw);
@@ -269,10 +225,7 @@ hix5hd2_clk_register_complex(struct hix5hd2_complex_clock *clks, int nums,
 			return;
 
 		init.name = clks[i].name;
-		if (clks[i].type == TYPE_ETHER)
-			init.ops = &clk_ether_ops;
-		else
-			init.ops = &clk_complex_ops;
+		init.ops = &clk_complex_ops;
 
 		init.flags = CLK_IS_BASIC;
 		init.parent_names =
@@ -302,10 +255,17 @@ hix5hd2_clk_register_complex(struct hix5hd2_complex_clock *clks, int nums,
 static void __init hix5hd2_clk_init(struct device_node *np)
 {
 	struct hisi_clock_data *clk_data;
+	struct hisi_reset_controller *rstc;
+
+	rstc = hisi_reset_init(np);
+	if (!rstc)
+		return;
 
 	clk_data = hisi_clk_init(np, HIX5HD2_NR_CLKS);
-	if (!clk_data)
+	if (!clk_data) {
+		hisi_reset_exit(rstc);
 		return;
+	}
 
 	hisi_clk_register_fixed_rate(hix5hd2_fixed_rate_clks,
 				     ARRAY_SIZE(hix5hd2_fixed_rate_clks),
diff --git a/include/dt-bindings/clock/hix5hd2-clock.h b/include/dt-bindings/clock/hix5hd2-clock.h
index fd29c17..90f0731 100644
--- a/include/dt-bindings/clock/hix5hd2-clock.h
+++ b/include/dt-bindings/clock/hix5hd2-clock.h
@@ -74,10 +74,12 @@
 #define HIX5HD2_I2C4_RST		150
 #define HIX5HD2_I2C5_CLK		151
 #define HIX5HD2_I2C5_RST		152
+#define HIX5HD2_MAC0_CLK		153
+#define HIX5HD2_MAC1_CLK		154
+#define HIX5HD2_MAC_IFC0_CLK		155
+#define HIX5HD2_MAC_IFC1_CLK		156
 
 /* complex */
-#define HIX5HD2_MAC0_CLK		192
-#define HIX5HD2_MAC1_CLK		193
 #define HIX5HD2_SATA_CLK		194
 #define HIX5HD2_USB_CLK			195
 
-- 
2.8.2
