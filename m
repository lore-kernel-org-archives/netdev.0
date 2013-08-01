From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH v2] net/phy: micrel: Add OF configuration support
Date: Thu, 1 Aug 2013 12:24:16 +0200
Message-ID: <20130801102416.GF26614@pengutronix.de>
References: <1375340034-23846-1-git-send-email-xobs@kosagi.com>
 <1375340034-23846-2-git-send-email-xobs@kosagi.com>
 <20130801084728.GE26614@pengutronix.de>
 <3050A7D1D42E4A0CBC48C9620889E749@kosagi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Duan Fugang-B38611 <B38611@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	Steven Rostedt <rostedt@goodmis.org>
To: Sean Cross <xobs@kosagi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:52355 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752842Ab3HAKYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 06:24:22 -0400
Content-Disposition: inline
In-Reply-To: <3050A7D1D42E4A0CBC48C9620889E749@kosagi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 01, 2013 at 05:06:13PM +0800, Sean Cross wrote:
> > Given that this patch adds a devicetree binding which I think we now
> > agree that this introduces an ABI I think this needs more thought. Some
> > questions:
> > 
> > - Does binding this also work for MII controllers external to the MAC?
> > Several Marvell SoCs have this situation. MDIO is a bus. With the
> > binding above you assume that all devices on the bus use the same
> > settings
> 
> I'm not quite sure what you mean here.  The board I'm testing on is
> based on an i.MX6q, which has a gigabit MAC and uses a Micrel PHY
> connected via MDIO.  I assumed (perhaps inaccurately) that phy_write()
> would pick the correct PHY.  The example binding is for a single
> Ethernet device, named "enet".  If a board had two Ethernet devices,
> enet1 and enet2, each could have its own micrel definitions.  For
> example:
> 
> &enet1 {
>     micrel,clk-control-pad-skew = <0xf0f0>;
>     micrel,rx-data-pad-skew = <0x0000>;
>     micrel,tx-data-pad-skew = <0xffff>;
>     status = "okay";
> };
> 
> &enet2 {
>     micrel,clk-control-pad-skew = <0x0000>;
>     micrel,rx-data-pad-skew = <0x0000>;
>     micrel,tx-data-pad-skew = <0x0000>;
>     status = "okay";
> };

Here each enet controller has its own mdio bus, but look for example at
Marvell armada-370-db.dts:

mdio {
	phy0: ethernet-phy@0 {
		reg = <0>;
	};

	phy1: ethernet-phy@1 {
		reg = <1>;
	};
};

ethernet@70000 {
	status = "okay";
	phy = <&phy0>;
	phy-mode = "rgmii-id";
};

ethernet@74000 {
	status = "okay";
	phy = <&phy1>;
	phy-mode = "rgmii-id";
};

Here two ethernet controllers share a single mdio bus. This at least
requires the binding in the phy node, not the ethernet node.

> > - You directly put the register contents into dt. This assumes that all
> > micrel phys have a compatible register layout. This may be the case
> > now, but what's with future phys?
> 
> This is a very valid point.  I assumed that most Micrel PHYs had
> similar register sets, but upon closer inspection it seems as though
> the KSZ9021RN is unique in this regard.  I should come up with a new
> function ksz9021_config_init that does this only for that one PHY, and
> rename the devicetree doc to reflect that.
> > - The pad skew settings are needed for other phys aswell. It might
> > be
> > worth introducing a binding which could work for say Artheros phys
> > aswell.
> 
> I can't comment on other phys, as I'm not familiar with them.  How
> would such a system work?  This certainly seems like the most
> open-ended of the questions.

I think we would need the delay for the different lines in ps, not in
hardware register specific values. This would have the additional
benefit that we don't have to hardcode the exact phy type.

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
