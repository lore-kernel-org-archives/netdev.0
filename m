From: Stephen Boyd <sboyd@codeaurora.org>
Subject: Re: [PATCH 2/6] net: ethernet: ti: cpts: add support for ext rftclk
 selection
Date: Thu, 8 Dec 2016 16:47:45 -0800
Message-ID: <20161209004745.GJ5423@codeaurora.org>
References: <20161128230428.6872-1-grygorii.strashko@ti.com>
 <20161128230428.6872-3-grygorii.strashko@ti.com>
 <20161130095632.GC28680@localhost.localdomain>
 <bf207ac4-0f9f-d4a7-14ac-704d93fb7764@ti.com>
 <11994fbc-3713-6ef7-8a44-8a2442106dfc@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Richard Cochran <richardcochran@gmail.com>,
        Murali Karicheri <m-karicheri2@ti.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org,
        linux-omap@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
        devicetree@vger.kernel.org, Wingman Kwok <w-kwok2@ti.com>,
        linux-clk@vger.kernel.org
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <11994fbc-3713-6ef7-8a44-8a2442106dfc@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/06, Grygorii Strashko wrote:
> Subject: [PATCH] cpts refclk sel
> 
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
> ---
>  arch/arm/boot/dts/keystone-k2e-netcp.dtsi | 10 +++++-
>  drivers/net/ethernet/ti/cpts.c            | 52 ++++++++++++++++++++++++++++++-
>  2 files changed, 60 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/arm/boot/dts/keystone-k2e-netcp.dtsi b/arch/arm/boot/dts/keystone-k2e-netcp.dtsi
> index 919e655..b27aa22 100644
> --- a/arch/arm/boot/dts/keystone-k2e-netcp.dtsi
> +++ b/arch/arm/boot/dts/keystone-k2e-netcp.dtsi
> @@ -138,7 +138,7 @@ netcp: netcp@24000000 {
>  	/* NetCP address range */
>  	ranges = <0 0x24000000 0x1000000>;
> 
> -	clocks = <&clkpa>, <&clkcpgmac>, <&chipclk12>;
> +	clocks = <&clkpa>, <&clkcpgmac>, <&cpts_mux>;
>  	clock-names = "pa_clk", "ethss_clk", "cpts";
>  	dma-coherent;
> 
> @@ -162,6 +162,14 @@ netcp: netcp@24000000 {
>  			cpts-ext-ts-inputs = <6>;
>  			cpts-ts-comp-length;
> 
> +			cpts_mux: cpts_refclk_mux {
> +				#clock-cells = <0>;
> +				clocks = <&chipclk12>, <&chipclk13>;
> +				cpts-mux-tbl = <0>, <1>;
> +				assigned-clocks = <&cpts_mux>;
> +				assigned-clock-parents = <&chipclk12>;

Is there a binding update? Why the subnode? Why not have it as
part of the netcp node? Does the cpts-mux-tbl property change?

> +			};
> +
>  			interfaces {
>  				gbe0: interface-0 {
>  					slave-port = <0>;
> diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
> index 938de22..ef94316 100644
> --- a/drivers/net/ethernet/ti/cpts.c
> +++ b/drivers/net/ethernet/ti/cpts.c
> @@ -17,6 +17,7 @@
>   * along with this program; if not, write to the Free Software
>   * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301  USA
>   */
> +#include <linux/clk-provider.h>
>  #include <linux/err.h>
>  #include <linux/if.h>
>  #include <linux/hrtimer.h>
> @@ -672,6 +673,7 @@ int cpts_register(struct cpts *cpts)
>  	cpts->phc_index = ptp_clock_index(cpts->clock);
> 
>  	schedule_delayed_work(&cpts->overflow_work, cpts->ov_check_period);
> +

Maybe in another patch.

>  	return 0;
> 
>  err_ptp:
> @@ -741,6 +743,54 @@ static void cpts_calc_mult_shift(struct cpts *cpts)
>  		 freq, cpts->cc_mult, cpts->cc.shift, (ns - NSEC_PER_SEC));
>  }
> 
> +static int cpts_of_mux_clk_setup(struct cpts *cpts, struct device_node *node)
> +{
> +	unsigned int num_parents;
> +	const char **parent_names;
> +	struct device_node *refclk_np;
> +	void __iomem *reg;
> +	struct clk *clk;
> +	u32 *mux_table;
> +	int ret;
> +
> +	refclk_np = of_get_child_by_name(node, "cpts_refclk_mux");
> +	if (!refclk_np)
> +		return -EINVAL;
> +
> +	num_parents = of_clk_get_parent_count(refclk_np);
> +	if (num_parents < 1) {
> +		dev_err(cpts->dev, "mux-clock %s must have parents\n",
> +			refclk_np->name);
> +		return -EINVAL;
> +	}
> +	parent_names = devm_kzalloc(cpts->dev, (sizeof(char *) * num_parents),
> +				    GFP_KERNEL);
> +	if (!parent_names)
> +		return -ENOMEM;
> +
> +	of_clk_parent_fill(refclk_np, parent_names, num_parents);
> +
> +	mux_table = devm_kzalloc(cpts->dev, sizeof(*mux_table) * (32 + 1),
> +				 GFP_KERNEL);
> +	if (!mux_table)
> +		return -ENOMEM;
> +
> +	ret = of_property_read_variable_u32_array(refclk_np, "cpts-mux-tbl",
> +						  mux_table, 1, 32);
> +	if (ret < 0)
> +		return ret;
> +
> +	reg = &cpts->reg->rftclk_sel;
> +
> +	clk = clk_register_mux_table(cpts->dev, refclk_np->name,
> +				     parent_names, num_parents,
> +				     0, reg, 0, 0x1F, 0, mux_table, NULL);
> +	if (IS_ERR(clk))
> +		return PTR_ERR(clk);
> +
> +	return of_clk_add_provider(refclk_np, of_clk_src_simple_get, clk);

Can you please use the clk_hw APIs instead?


-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
a Linux Foundation Collaborative Project
