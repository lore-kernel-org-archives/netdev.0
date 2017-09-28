From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH net] net: mvpp2: Fix clock resource by adding an
 optional bus clock
Date: Thu, 28 Sep 2017 17:46:54 +0200
Message-ID: <20170928174654.630cfefd@windsurf.lan>
References: <20170928153923.29003-1-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        linux-arm-kernel@lists.infradead.org,
        Antoine Tenart <antoine.tenart@free-electrons.com>,
        =?UTF-8?B?TWlxdcOobA==?= Raynal
        <miquel.raynal@free-electrons.com>,
        Nadav Haklai <nadavh@marvell.com>,
        Shadi Ammouri <shadi@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Omri Itach <omrii@marvell.com>,
        Hanna Hawa <hannah@marvell.com>,
        Igal Liberman <igall@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170928153923.29003-1-gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Thu, 28 Sep 2017 17:39:23 +0200, Gregory CLEMENT wrote:

> diff --git a/Documentation/devicetree/bindings/net/marvell-pp2.txt b/Documentation/devicetree/bindings/net/marvell-pp2.txt
> index 7e2dad08a12e..49e1be6bb6ba 100644
> --- a/Documentation/devicetree/bindings/net/marvell-pp2.txt
> +++ b/Documentation/devicetree/bindings/net/marvell-pp2.txt
> @@ -21,8 +21,9 @@ Required properties:
>  	- main controller clock (for both armada-375-pp2 and armada-7k-pp2)
>  	- GOP clock (for both armada-375-pp2 and armada-7k-pp2)
>  	- MG clock (only for armada-7k-pp2)
> -- clock-names: names of used clocks, must be "pp_clk", "gop_clk" and
> -  "mg_clk" (the latter only for armada-7k-pp2).
> +	- AXI clock (only for armada-7k-pp2)
> +- clock-names: names of used clocks, must be "pp_clk", "gop_clk", "mg_clk"
> +  and "axi"(the 2 latter only for armada-7k-pp2).

Should be "axi_clk" not "axi", otherwise your binding documentation
doesn't match the driver and example.

Also, missing space after "axi".

>  
>  The ethernet ports are represented by subnodes. At least one port is
>  required.
> @@ -78,8 +79,9 @@ Example for marvell,armada-7k-pp2:
>  cpm_ethernet: ethernet@0 {
>  	compatible = "marvell,armada-7k-pp22";
>  	reg = <0x0 0x100000>, <0x129000 0xb000>;
> -	clocks = <&cpm_syscon0 1 3>, <&cpm_syscon0 1 9>, <&cpm_syscon0 1 5>;
> -	clock-names = "pp_clk", "gop_clk", "gp_clk";
> +	clocks = <&cpm_syscon0 1 3>, <&cpm_syscon0 1 9>,
> +	<&cpm_syscon0 1 5>, <&cpm_syscon0 1 18>;

Please indent the second line with one more tab.

> +	clock-names = "pp_clk", "gop_clk", "gp_clk", "axi_clk";
>  
>  	eth0: eth0 {
>  		interrupts = <ICU_GRP_NSR 39 IRQ_TYPE_LEVEL_HIGH>,
> diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
> index dd0ee2691c86..33b6791df2bb 100644
> --- a/drivers/net/ethernet/marvell/mvpp2.c
> +++ b/drivers/net/ethernet/marvell/mvpp2.c
> @@ -792,6 +792,7 @@ struct mvpp2 {
>  	struct clk *pp_clk;
>  	struct clk *gop_clk;
>  	struct clk *mg_clk;
> +	struct clk *axi_clk;
>  
>  	/* List of pointers to port structures */
>  	struct mvpp2_port **port_list;
> @@ -7963,6 +7964,16 @@ static int mvpp2_probe(struct platform_device *pdev)
>  		err = clk_prepare_enable(priv->mg_clk);
>  		if (err < 0)
>  			goto err_gop_clk;
> +
> +		priv->axi_clk = devm_clk_get(&pdev->dev, "axi_clk");
> +		if (IS_ERR(priv->axi_clk)) {
> +			err = PTR_ERR(priv->axi_clk);
> +			priv->axi_clk = NULL;

You should handle -EPROBE_DEFER here. Indeed, if we have -EPROBE_DEFER,
we shouldn't treat it as "the clock doesn't exist, so let's skip it and
continue", but rather as "the clock exists, but isn't ready to use yet,
let's try later".

Thanks!

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
