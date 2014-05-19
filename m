From: Zhangfei Gao <zhangfei.gao@linaro.org>
Subject: [PATCH 1/3] hix5hd2-clock: add complex clk
Date: Mon, 19 May 2014 20:57:05 +0800
Message-ID: <1400504227-12047-2-git-send-email-zhangfei.gao@linaro.org>
References: <1400504227-12047-1-git-send-email-zhangfei.gao@linaro.org>
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, Zhangfei Gao <zhangfei.gao@linaro.org>,
	Jiancheng Xue <xuejiancheng@huawei.com>
To: davem@davemloft.net, arnd@arndb.de, f.fainelli@gmail.com,
	sergei.shtylyov@cogentembedded.com, mark.rutland@arm.com,
	David.Laight@ACULAB.COM, eric.dumazet@gmail.com,
	haifeng.yan@linaro.org, jchxue@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:42897 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754553AbaESM6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2014 08:58:10 -0400
Received: by mail-pb0-f43.google.com with SMTP id up15so5820372pbc.16
        for <netdev@vger.kernel.org>; Mon, 19 May 2014 05:58:10 -0700 (PDT)
In-Reply-To: <1400504227-12047-1-git-send-email-zhangfei.gao@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiancheng Xue <xuejiancheng@huawei.com>
Signed-off-by: Zhangfei Gao <zhangfei.gao@linaro.org>
---
 drivers/clk/hisilicon/clk-hix5hd2.c       |  182 +++++++++++++++++++++++++++++
 include/dt-bindings/clock/hix5hd2-clock.h |    9 ++
 2 files changed, 191 insertions(+)

diff --git a/drivers/clk/hisilicon/clk-hix5hd2.c b/drivers/clk/hisilicon/clk-hix5hd2.c
index e5fcfb4..1b1347f 100644
--- a/drivers/clk/hisilicon/clk-hix5hd2.c
+++ b/drivers/clk/hisilicon/clk-hix5hd2.c
@@ -9,6 +9,8 @@
 
 #include <linux/of_address.h>
 #include <dt-bindings/clock/hix5hd2-clock.h>
+#include <linux/slab.h>
+#include <linux/delay.h>
 #include "clk.h"
 
 static struct hisi_fixed_rate_clock hix5hd2_fixed_rate_clks[] __initdata = {
@@ -79,8 +81,186 @@ static struct hisi_gate_clock hix5hd2_gate_clks[] __initdata = {
 		CLK_SET_RATE_PARENT, 0xa0, 1, 0, },
 	{ HIX5HD2_MMC_CIU_RST, "rst_mmc_ciu", "clk_mmc_ciu",
 		CLK_SET_RATE_PARENT, 0xa0, 4, CLK_GATE_SET_TO_DISABLE, },
+	/*gsf*/
+	{ HIX5HD2_FWD_BUS_CLK, "clk_fwd_bus", NULL, 0, 0xcc, 0, 0, },
+	{ HIX5HD2_FWD_SYS_CLK, "clk_fwd_sys", "clk_fwd_bus", 0, 0xcc, 5, 0, },
+	{ HIX5HD2_MAC0_PHY_CLK, "clk_fephy", "clk_fwd_sys",
+		 CLK_SET_RATE_PARENT, 0x120, 0, 0, },
 };
 
+enum {TYPE_COMPLEX, TYPE_ETHER};
+
+struct hix5hd2_complex_clock {
+	unsigned int	id;
+	const char	*name;
+	const char	*parent_name;
+	u32		ctrl_reg;
+	u32		ctrl_clk_mask;
+	u32		ctrl_rst_mask;
+	u32		phy_reg;
+	u32		phy_clk_mask;
+	u32		phy_rst_mask;
+	u32		type;
+};
+
+struct hix5hd2_clk_complex {
+	struct clk_hw	hw;
+	u32		id;
+	void __iomem	*ctrl_reg;
+	u32		ctrl_clk_mask;
+	u32		ctrl_rst_mask;
+	void __iomem	*phy_reg;
+	u32		phy_clk_mask;
+	u32		phy_rst_mask;
+};
+
+static struct hix5hd2_complex_clock hix5hd2_complex_clks[] __initdata = {
+	{HIX5HD2_MAC0_CLK, "clk_mac0", "clk_fephy",
+		0xcc, 0xa, 0x500, 0x120, 0, 0x10, TYPE_ETHER},
+	{HIX5HD2_MAC1_CLK, "clk_mac1", "clk_fwd_sys",
+		0xcc, 0x14, 0xa00, 0x168, 0x2, 0, TYPE_ETHER},
+	{HIX5HD2_SATA_CLK, "clk_sata", NULL,
+		0xa8, 0x1f, 0x300, 0xac, 0x1, 0x0, TYPE_COMPLEX},
+	{HIX5HD2_USB_CLK, "clk_usb", NULL,
+		0xb8, 0xff, 0x3f00, 0xbc, 0x7, 0x3f00, TYPE_COMPLEX},
+};
+
+#define to_complex_clk(_hw) container_of(_hw, struct hix5hd2_clk_complex, hw)
+
+static int clk_ether_enable(struct clk_hw *hw)
+{
+	struct hix5hd2_clk_complex *clk = to_complex_clk(hw);
+	u32 val;
+
+	val = readl(clk->ctrl_reg);
+	val |= clk->ctrl_clk_mask | clk->ctrl_rst_mask;
+	writel(val, clk->ctrl_reg);
+	udelay(50);
+	val &= ~(clk->ctrl_rst_mask);
+	writel(val, clk->ctrl_reg);
+
+	val = readl(clk->phy_reg);
+	val |= clk->phy_clk_mask;
+	val &= ~(clk->phy_rst_mask);
+	writel(val, clk->phy_reg);
+	mdelay(10);
+
+	val &= ~(clk->phy_clk_mask);
+	val |= clk->phy_rst_mask;
+	writel(val, clk->phy_reg);
+	mdelay(10);
+
+	val |= clk->phy_clk_mask;
+	val &= ~(clk->phy_rst_mask);
+	writel(val, clk->phy_reg);
+	mdelay(30);
+	return 0;
+}
+
+static void clk_ether_disable(struct clk_hw *hw)
+{
+	struct hix5hd2_clk_complex *clk = to_complex_clk(hw);
+	u32 val;
+
+	val = readl(clk->ctrl_reg);
+	val &= ~(clk->ctrl_clk_mask);
+	writel(val, clk->ctrl_reg);
+}
+
+static struct clk_ops clk_ether_ops = {
+	.enable = clk_ether_enable,
+	.disable = clk_ether_disable,
+};
+
+static int clk_complex_enable(struct clk_hw *hw)
+{
+	struct hix5hd2_clk_complex *clk = to_complex_clk(hw);
+	u32 val;
+
+	val = readl(clk->ctrl_reg);
+	val |= clk->ctrl_clk_mask;
+	val &= ~(clk->ctrl_rst_mask);
+	writel(val, clk->ctrl_reg);
+
+	val = readl(clk->phy_reg);
+	val |= clk->phy_clk_mask;
+	val &= ~(clk->phy_rst_mask);
+	writel(val, clk->phy_reg);
+
+	return 0;
+}
+
+static void clk_complex_disable(struct clk_hw *hw)
+{
+	struct hix5hd2_clk_complex *clk = to_complex_clk(hw);
+	u32 val;
+
+	val = readl(clk->ctrl_reg);
+	val |= clk->ctrl_rst_mask;
+	val &= ~(clk->ctrl_clk_mask);
+	writel(val, clk->ctrl_reg);
+
+	val = readl(clk->phy_reg);
+	val |= clk->phy_rst_mask;
+	val &= ~(clk->phy_clk_mask);
+	writel(val, clk->phy_reg);
+
+	return;
+}
+
+static struct clk_ops clk_complex_ops = {
+	.enable = clk_complex_enable,
+	.disable = clk_complex_disable,
+};
+
+void __init hix5hd2_clk_register_complex_clk(struct hix5hd2_complex_clock *clks,
+				       int nums, struct hisi_clock_data *data)
+{
+	void __iomem *base = data->base;
+	int i;
+
+	for (i = 0; i < nums; i++) {
+		struct hix5hd2_clk_complex *p_clk;
+		struct clk *clk;
+		struct clk_init_data init;
+
+		p_clk = kzalloc(sizeof(*p_clk), GFP_KERNEL);
+		if (!p_clk) {
+			pr_err("%s: fail to allocate clk\n", __func__);
+			return;
+		}
+
+		init.name = clks[i].name;
+		if (clks[i].type == TYPE_ETHER)
+			init.ops = &clk_ether_ops;
+		else
+			init.ops = &clk_complex_ops;
+
+		init.flags = CLK_IS_BASIC;
+		init.parent_names =
+			(clks[i].parent_name ? &clks[i].parent_name : NULL);
+		init.num_parents = (clks[i].parent_name ? 1 : 0);
+
+		p_clk->ctrl_reg = base + clks[i].ctrl_reg;
+		p_clk->ctrl_clk_mask = clks[i].ctrl_clk_mask;
+		p_clk->ctrl_rst_mask = clks[i].ctrl_rst_mask;
+		p_clk->phy_reg = base + clks[i].phy_reg;
+		p_clk->phy_clk_mask = clks[i].phy_clk_mask;
+		p_clk->phy_rst_mask = clks[i].phy_rst_mask;
+		p_clk->hw.init = &init;
+
+		clk = clk_register(NULL, &p_clk->hw);
+		if (IS_ERR(clk)) {
+			kfree(p_clk);
+			pr_err("%s: failed to register clock %s\n",
+			       __func__, clks[i].name);
+			continue;
+		}
+
+		data->clk_data.clks[clks[i].id] = clk;
+	}
+}
+
 static void __init hix5hd2_clk_init(struct device_node *np)
 {
 	struct hisi_clock_data *clk_data;
@@ -96,6 +276,8 @@ static void __init hix5hd2_clk_init(struct device_node *np)
 					clk_data);
 	hisi_clk_register_gate(hix5hd2_gate_clks,
 			ARRAY_SIZE(hix5hd2_gate_clks), clk_data);
+	hix5hd2_clk_register_complex_clk(hix5hd2_complex_clks,
+			ARRAY_SIZE(hix5hd2_complex_clks), clk_data);
 }
 
 CLK_OF_DECLARE(hix5hd2_clk, "hisilicon,hix5hd2-clock", hix5hd2_clk_init);
diff --git a/include/dt-bindings/clock/hix5hd2-clock.h b/include/dt-bindings/clock/hix5hd2-clock.h
index aad579a..e328669 100644
--- a/include/dt-bindings/clock/hix5hd2-clock.h
+++ b/include/dt-bindings/clock/hix5hd2-clock.h
@@ -53,6 +53,15 @@
 #define HIX5HD2_MMC_CIU_CLK		130
 #define HIX5HD2_MMC_BIU_CLK		131
 #define HIX5HD2_MMC_CIU_RST		132
+#define HIX5HD2_FWD_BUS_CLK		133
+#define HIX5HD2_FWD_SYS_CLK		134
+#define HIX5HD2_MAC0_PHY_CLK		135
+
+/* complex */
+#define HIX5HD2_MAC0_CLK		192
+#define HIX5HD2_MAC1_CLK		193
+#define HIX5HD2_SATA_CLK		194
+#define HIX5HD2_USB_CLK			195
 
 #define HIX5HD2_NR_CLKS			256
 #endif	/* __DTS_HIX5HD2_CLOCK_H */
-- 
1.7.9.5
