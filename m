From: Sean Cross <xobs@kosagi.com>
Subject: Re: [PATCH v2] net/phy: micrel: Add OF configuration support
Date: Thu, 1 Aug 2013 17:06:13 +0800
Message-ID: <3050A7D1D42E4A0CBC48C9620889E749@kosagi.com>
References: <1375340034-23846-1-git-send-email-xobs@kosagi.com>
 <1375340034-23846-2-git-send-email-xobs@kosagi.com>
 <20130801084728.GE26614@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Duan Fugang-B38611 <B38611@freescale.com>,
	"=?utf-8?Q?netdev=40vger.kernel.org?=" <netdev@vger.kernel.org>,
	"=?utf-8?Q?devicetree=40vger.kernel.org?="
	<devicetree@vger.kernel.org>, David Miller <davem@davemloft.net>,
	"=?utf-8?Q?stephen=40networkplumber.org?="
	<stephen@networkplumber.org>, Steven Rostedt <rostedt@goodmis.org>
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.g1.pair.com ([66.39.3.162]:27764 "EHLO mail1.g1.pair.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751604Ab3HAJGT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Aug 2013 05:06:19 -0400
In-Reply-To: <20130801084728.GE26614@pengutronix.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



-- 
Sean Cross


On Thursday, August 1, 2013 at 4:47 PM, Sascha Hauer wrote:

> On Thu, Aug 01, 2013 at 06:53:54AM +0000, Sean Cross wrote:
> > Some boards require custom PHY configuration, for example due to trace
> > length differences. Add the ability to configure these registers in
> > order to get the PHY to function on boards that need it.
> > 
> > Because PHYs are auto-detected based on MDIO device IDs, allow PHY
> > configuration to be specified in the parent Ethernet device node if no
> > PHY device node is present.
> > 
> > Signed-off-by: Sean Cross <xobs@kosagi.com (mailto:xobs@kosagi.com)>
> > ---
> > .../devicetree/bindings/net/micrel-phy.txt | 20 ++++++++
> > drivers/net/phy/micrel.c | 50 ++++++++++++++++++++
> > 2 files changed, 70 insertions(+)
> > create mode 100644 Documentation/devicetree/bindings/net/micrel-phy.txt
> > 
> > diff --git a/Documentation/devicetree/bindings/net/micrel-phy.txt b/Documentation/devicetree/bindings/net/micrel-phy.txt
> > new file mode 100644
> > index 0000000..97c1ef2
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/micrel-phy.txt
> > @@ -0,0 +1,20 @@
> > +Micrel KS8737, KSZ8041, KSZ8001, KS8721, KSZ8081, KSZ8091, KSZ8061, KSZ9021,
> > +KSZ9031, Ethernet PHYs, and KSZ8873MLL and KSZ886X Ethernet switches.
> > +
> > +Some boards require special tuning values, particularly when it comes to
> > +clock delays. You can specify clock delay values by adding
> > +micrel-specific properties to an Ethernet OF device node.
> > +
> > +Optional properties:
> > +- micrel,clk-control-pad-skew : Timing offset for the MII clock line
> > +- micrel,rx-data-pad-skew : Timing offset for the RX MII pad
> > +- micrel,tx-data-pad-skew : Timing offset for the TX MII pad
> > +
> > +Example:
> > + &enet {
> > + micrel,clk-control-pad-skew = <0xf0f0>;
> > + micrel,rx-data-pad-skew = <0x0000>;
> > + micrel,tx-data-pad-skew = <0xffff>;
> > + status = "okay";
> > + };
> 
> 
> 
> Given that this patch adds a devicetree binding which I think we now
> agree that this introduces an ABI I think this needs more thought. Some
> questions:
> 
> - Does binding this also work for MII controllers external to the MAC?
> Several Marvell SoCs have this situation. MDIO is a bus. With the
> binding above you assume that all devices on the bus use the same
> settings

I'm not quite sure what you mean here.  The board I'm testing on is based on an i.MX6q, which has a gigabit MAC and uses a Micrel PHY connected via MDIO.  I assumed (perhaps inaccurately) that phy_write() would pick the correct PHY.  The example binding is for a single Ethernet device, named "enet".  If a board had two Ethernet devices, enet1 and enet2, each could have its own micrel definitions.  For example:

&enet1 {
    micrel,clk-control-pad-skew = <0xf0f0>;
    micrel,rx-data-pad-skew = <0x0000>;
    micrel,tx-data-pad-skew = <0xffff>;
    status = "okay";
};

&enet2 {
    micrel,clk-control-pad-skew = <0x0000>;
    micrel,rx-data-pad-skew = <0x0000>;
    micrel,tx-data-pad-skew = <0x0000>;
    status = "okay";
};



> - You directly put the register contents into dt. This assumes that all
> micrel phys have a compatible register layout. This may be the case
> now, but what's with future phys?

This is a very valid point.  I assumed that most Micrel PHYs had similar register sets, but upon closer inspection it seems as though the KSZ9021RN is unique in this regard.  I should come up with a new function ksz9021_config_init that does this only for that one PHY, and rename the devicetree doc to reflect that. 
> - The pad skew settings are needed for other phys aswell. It might be
> worth introducing a binding which could work for say Artheros phys
> aswell.

I can't comment on other phys, as I'm not familiar with them.  How would such a system work?  This certainly seems like the most open-ended of the questions. 

I'll limit the scope of the patch to the KSZ9021 family of parts, and submit a v3 patch.
