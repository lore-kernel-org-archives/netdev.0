From: Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>
Subject: Re: [PATCH] [v2] netdev/phy: add MDIO bus multiplexer driven by a
 memory-mapped device
Date: Thu, 23 Aug 2012 16:54:53 -0600
Message-ID: <5036B4BD.70208@wwwdotorg.org>
References: <1345751071-23128-1-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 Andy Fleming <afleming-KZfg59tc24xl57MIdRCFDg@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Timur Tabi <timur-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1345751071-23128-1-git-send-email-timur-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 08/23/2012 01:44 PM, Timur Tabi wrote:
> Add support for an MDIO bus multiplexer controlled by a simple memory-mapped
> device, like an FPGA.  The device must be memory-mapped and contain only
> 8-bit registers (which keeps things simple).

> +++ b/Documentation/devicetree/bindings/net/mdio-mux-mmioreg.txt

> +	/* The FPGA node */
> +	fpga: board-control@3,0 {
> +		compatible = "fsl,p5020ds-fpga", "fsl,fpga-ngpixis";
> +		reg = <3 0 0x30>;

Why not add the following here:

	#address-cells = <1>:
	#size-cells = <1>;
	ranges = <...>;

> +
> +		mdio-mux-emi2 {
> +			compatible = "mdio-mux-mmioreg", "mdio-mux";
> +			mdio-parent-bus = <&xmdio0>;
> +			#address-cells = <1>;
> +			#size-cells = <0>;
> +			reg = <9>; // BRDCFG1

Then, that'd have to be <9 1>;

That way, ...

> diff --git a/drivers/net/phy/mdio-mux-mmioreg.c b/drivers/net/phy/mdio-mux-mmioreg.c

> +static int __devinit mdio_mux_mmioreg_probe(struct platform_device *pdev)

> +	/* The MMIO device is the parent of this device */
> +	np2 = of_get_parent(np);
> +	if (!np2) {
> +		dev_err(&pdev->dev, "could not find parent MMIO device\n");
> +		return -ENODEV;
> +	}
> +
> +	ret = of_address_to_resource(np2, 0, &res);
> +	if (ret) {
> +		dev_err(&pdev->dev, "could not obtain memory map for node %s\n",
> +			np2->full_name);
> +		return ret;
> +	}
> +	s->phys = res.start;

You could simplify all that into just "of_iomap(np, 0)", and all the
address translation etc. happens entirely automatically, in the standard
fashion for DT.

The advantage here is that it completely decouples the mdio-mux-mmioreg
driver from any knowledge of its parent; you could just as easily use
this driver/binding as a device directly on some SoC bus, rather than
requiring there to be a parent device above it. After all, the mux
register might be some random standalone on-SoC register (although I
wonder if that case might not be better covered by a mdio-mux-pinctrl
driver instead; I guess it depends on how special-purpose the mux
register is).
