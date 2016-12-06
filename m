From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH 2/6] net: ethernet: ti: cpts: add support for ext rftclk
 selection
Date: Tue, 6 Dec 2016 13:39:40 -0600
Message-ID: <11994fbc-3713-6ef7-8a44-8a2442106dfc@ti.com>
References: <20161128230428.6872-1-grygorii.strashko@ti.com>
 <20161128230428.6872-3-grygorii.strashko@ti.com>
 <20161130095632.GC28680@localhost.localdomain>
 <bf207ac4-0f9f-d4a7-14ac-704d93fb7764@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, Rob Herring <robh+dt@kernel.org>,
        <devicetree@vger.kernel.org>, Wingman Kwok <w-kwok2@ti.com>,
        <linux-clk@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>,
        Murali Karicheri <m-karicheri2@ti.com>
Return-path: <linux-clk-owner@vger.kernel.org>
In-Reply-To: <bf207ac4-0f9f-d4a7-14ac-704d93fb7764@ti.com>
Sender: linux-clk-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 11/30/2016 11:35 AM, Grygorii Strashko wrote:
>
>
> On 11/30/2016 03:56 AM, Richard Cochran wrote:
>> On Mon, Nov 28, 2016 at 05:04:24PM -0600, Grygorii Strashko wrote:
>>> Some CPTS instances, which can be found on KeyStone 2 1/10G Ethernet
>>> Switch Subsystems, can control an external multiplexer that selects
>>> one of up to 32 clocks for time sync reference (RFTCLK). This feature
>>> can be configured through CPTS_RFTCLK_SEL register (offset: x08).
>>>
>>> Hence, introduce optional DT cpts_rftclk_sel poperty wich, if present,
>>> will specify CPTS reference clock. The cpts_rftclk_sel should be
>>> omitted in DT if HW doesn't support this feature. The external fixed
>>> rate clocks can be defined in board files as "fixed-clock".
>>
>> Can't you implement this using the clock tree, rather than an ad-hoc
>> DT property?
>>
>
> I've thought about this, but decided to move forward with this impl
>  which is pretty simple. I will try.
>
>

I come with below RFC patch. if no objection I'll move forward with it.

According to Keystone 2 66AK2e DM there are 7 possible ref clocks:
0000 = SYSCLK2
0001 = SYSCLK3
0010 = TIMI0
0011 = TIMI1
0100 = TSIPCLKA
1000 = TSREFCLK
1100 = TSIPCLKB
Others = Reserved

2 from above clocks are internal SYSCLK2 and SYSCLK3 - other external
(board specific). So default definition of cpts_mux will have only two parents.
If ext clock is going to be use as cpts rftclk then it should be
defined in board file and  cpts_refclk_mux definition updated to support 
this ext clock:

timi1clk: timi1clk {
	#clock-cells = <0>;
	compatible = "fixed-clock";
	clock-frequency = <xxxxxxxxxx>;
	clock-output-names = "timi1";
};

&cpts_mux {
	clocks = <&chipclk12>, <&chipclk13>, <timi1clk>;
	cpts-mux-tbl = <0>, <1>, <3>;
	assigned-clocks = <&cpts_mux>;
	assigned-clock-parents = <&timi1clk>;
};



>From ec5c7bed0e021c2ca7e9392173bf67bb9a45d0f4 Mon Sep 17 00:00:00 2001
From: Grygorii Strashko <grygorii.strashko@ti.com>
Date: Mon, 5 Dec 2016 12:34:45 -0600
Subject: [PATCH] cpts refclk sel

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 arch/arm/boot/dts/keystone-k2e-netcp.dtsi | 10 +++++-
 drivers/net/ethernet/ti/cpts.c            | 52 ++++++++++++++++++++++++++++++-
 2 files changed, 60 insertions(+), 2 deletions(-)

diff --git a/arch/arm/boot/dts/keystone-k2e-netcp.dtsi b/arch/arm/boot/dts/keystone-k2e-netcp.dtsi
index 919e655..b27aa22 100644
--- a/arch/arm/boot/dts/keystone-k2e-netcp.dtsi
+++ b/arch/arm/boot/dts/keystone-k2e-netcp.dtsi
@@ -138,7 +138,7 @@ netcp: netcp@24000000 {
 	/* NetCP address range */
 	ranges = <0 0x24000000 0x1000000>;

-	clocks = <&clkpa>, <&clkcpgmac>, <&chipclk12>;
+	clocks = <&clkpa>, <&clkcpgmac>, <&cpts_mux>;
 	clock-names = "pa_clk", "ethss_clk", "cpts";
 	dma-coherent;

@@ -162,6 +162,14 @@ netcp: netcp@24000000 {
 			cpts-ext-ts-inputs = <6>;
 			cpts-ts-comp-length;

+			cpts_mux: cpts_refclk_mux {
+				#clock-cells = <0>;
+				clocks = <&chipclk12>, <&chipclk13>;
+				cpts-mux-tbl = <0>, <1>;
+				assigned-clocks = <&cpts_mux>;
+				assigned-clock-parents = <&chipclk12>;
+			};
+
 			interfaces {
 				gbe0: interface-0 {
 					slave-port = <0>;
diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index 938de22..ef94316 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -17,6 +17,7 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301  USA
  */
+#include <linux/clk-provider.h>
 #include <linux/err.h>
 #include <linux/if.h>
 #include <linux/hrtimer.h>
@@ -672,6 +673,7 @@ int cpts_register(struct cpts *cpts)
 	cpts->phc_index = ptp_clock_index(cpts->clock);

 	schedule_delayed_work(&cpts->overflow_work, cpts->ov_check_period);
+
 	return 0;

 err_ptp:
@@ -741,6 +743,54 @@ static void cpts_calc_mult_shift(struct cpts *cpts)
 		 freq, cpts->cc_mult, cpts->cc.shift, (ns - NSEC_PER_SEC));
 }

+static int cpts_of_mux_clk_setup(struct cpts *cpts, struct device_node *node)
+{
+	unsigned int num_parents;
+	const char **parent_names;
+	struct device_node *refclk_np;
+	void __iomem *reg;
+	struct clk *clk;
+	u32 *mux_table;
+	int ret;
+
+	refclk_np = of_get_child_by_name(node, "cpts_refclk_mux");
+	if (!refclk_np)
+		return -EINVAL;
+
+	num_parents = of_clk_get_parent_count(refclk_np);
+	if (num_parents < 1) {
+		dev_err(cpts->dev, "mux-clock %s must have parents\n",
+			refclk_np->name);
+		return -EINVAL;
+	}
+	parent_names = devm_kzalloc(cpts->dev, (sizeof(char *) * num_parents),
+				    GFP_KERNEL);
+	if (!parent_names)
+		return -ENOMEM;
+
+	of_clk_parent_fill(refclk_np, parent_names, num_parents);
+
+	mux_table = devm_kzalloc(cpts->dev, sizeof(*mux_table) * (32 + 1),
+				 GFP_KERNEL);
+	if (!mux_table)
+		return -ENOMEM;
+
+	ret = of_property_read_variable_u32_array(refclk_np, "cpts-mux-tbl",
+						  mux_table, 1, 32);
+	if (ret < 0)
+		return ret;
+
+	reg = &cpts->reg->rftclk_sel;
+
+	clk = clk_register_mux_table(cpts->dev, refclk_np->name,
+				     parent_names, num_parents,
+				     0, reg, 0, 0x1F, 0, mux_table, NULL);
+	if (IS_ERR(clk))
+		return PTR_ERR(clk);
+
+	return of_clk_add_provider(refclk_np, of_clk_src_simple_get, clk);
+}
+
 static int cpts_of_parse(struct cpts *cpts, struct device_node *node)
 {
 	int ret = -EINVAL;
@@ -787,7 +837,7 @@ static int cpts_of_parse(struct cpts *cpts, struct device_node *node)
 	if (!of_property_read_u32(node, "cpts-ext-ts-inputs", &prop))
 		cpts->ext_ts_inputs = prop;

-	return 0;
+	return cpts_of_mux_clk_setup(cpts, node);

 of_error:
 	dev_err(cpts->dev, "CPTS: Missing property in the DT.\n");
-- 
2.10.1



-- 
regards,
-grygorii
