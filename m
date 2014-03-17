From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH V2 1/7] net: sxgbe: add basic framework for Samsung
 10Gb ethernet driver
Date: Mon, 17 Mar 2014 09:59:52 +0000
Message-ID: <20140317095941.GA8070@e106331-lin.cambridge.arm.com>
References: <005101cf3df6$e37664f0$aa632ed0$%an@samsung.com>
 <20140312151008.GA5035@e106331-lin.cambridge.arm.com>
 <005701cf41a4$eee0ddf0$cca299d0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-samsung-soc@vger.kernel.org"
	<linux-samsung-soc@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"siva.kallam@samsung.com" <siva.kallam@samsung.com>,
	"vipul.pandya@samsung.com" <vipul.pandya@samsung.com>,
	"ks.giri@samsung.com" <ks.giri@samsung.com>,
	"ilho215.lee@samsung.com" <ilho215.lee@samsung.com>
To: Byungho An <bh74.an@samsung.com>, grant.likely@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([217.140.96.50]:36003 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932318AbaCQKAB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 06:00:01 -0400
Content-Disposition: inline
In-Reply-To: <005701cf41a4$eee0ddf0$cca299d0$@samsung.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 17, 2014 at 05:51:21AM +0000, Byungho An wrote:
> Mark Rutland <mark.rutland@arm.com> :
> > On Wed, Mar 12, 2014 at 01:28:00PM +0000, Byungho An wrote:
> > > From: Siva Reddy <siva.kallam@samsung.com>
> > >
> > > This patch adds support for Samsung 10Gb ethernet driver(sxgbe).
> > >
> > > - sxgbe core initialization
> > > - Tx and Rx support
> > > - MDIO support
> > > - ISRs for Tx and Rx
> > > - ifconfig support to driver
> > >
> > > Signed-off-by: Siva Reddy Kallam <siva.kallam@samsung.com>
> > > Signed-off-by: Vipul Pandya <vipul.pandya@samsung.com>
> > > Signed-off-by: Girish K S <ks.giri@samsung.com>
> > > Neatening-by: Joe Perches <joe@perches.com>
> > > Signed-off-by: Byungho An <bh74.an@samsung.com>

[...]

> > > +static int sxgbe_probe_config_dt(struct platform_device *pdev,
> > > +                                struct sxgbe_plat_data *plat,
> > > +                                const char **mac) {
> > > +       struct device_node *np = pdev->dev.of_node;
> > > +       struct sxgbe_dma_cfg *dma_cfg;
> > > +       u32 phy_addr;
> > > +
> > > +       if (!np)
> > > +               return -ENODEV;
> > > +
> > > +       *mac = of_get_mac_address(np);
> >
> > I see that of_get_mac_address returns a *void rather than *char, but it's
> > always a string of hex digits. Would it make sense to change the
> > of_get_mac_address prototype to return a char* ?
> This implementation is of_ specific, our driver only uses it.

Sure, this was a general observation that wasn't specific to this
driver.

> 
> >
> > > +       plat->interface = of_get_phy_mode(np);
> > > +
> > > +       plat->bus_id = of_alias_get_id(np, "ethernet");
> > > +       if (plat->bus_id < 0)
> > > +               plat->bus_id = 0;
> >
> > This wasn't mentioned in the binding.
> It doesn't need to  be in the binding document, because we get the alias id
> by passing the node name. Here ethernet is not a property it is the dt node
> name
> e.g.
>  ethernet@xxxxx {
> 
> };

Huh?

The acquisition of the alias ID is not performed based on the node name,
but rather the node and stem of the entry in the /alias node that points
to it.

Consider this dts fragment:

/ {
	...

	alias {
		ethernet5 = "/bus/arbitrarily_named_sxgbe@deadbeef";
	};

	bus {
		...

		arbtirarily_named_sxgbe@0xdeadbeef {
			compatible = "samsung,sxgbe-v2.0a";
			reg = <0xdeadbeef 0>, ... ;
			...
		};
	};
}

The above call to of_alias_get_id(np, "ethernet") would return 5 for the
sxgbe node, despite the node name being completely arbitrary.  While the
node should probably be named "ethernet", this doesn't matter for the
purpose of alias id handling.

If your binding has a particular form of alias, please document it so DT
authors can be aware of it and make use of it.

That said we probably need better guidance on the use of aliases. The
usage model is undocumented beyond aliases being informational, which is
somewhat vague. Unfortunately the description in ePAPR also glosses over
the expected usage.

Grant, would you be able to elaborate on the expected usage of aliases?

Should alias names always be from a standard set (e.g. "ethernet",
"serial", "pci" per ePAPR), or are binding-specific names (e.g. the
Exynos S-Scalar's "gsc") something we're happy with?

Are aliases allowed to be required, or are they always supposed to be an
optional hint to the OS?

Cheers,
Mark.
