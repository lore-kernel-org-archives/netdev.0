From: Sean Cross <xobs@kosagi.com>
Subject: Re: [PATCH v2] net/phy: micrel: Add OF configuration support
Date: Thu, 1 Aug 2013 18:33:14 +0800
Message-ID: <0AB8335463CD4010B90FACE41914CB1C@kosagi.com>
References: <1375340034-23846-1-git-send-email-xobs@kosagi.com>
 <1375340034-23846-2-git-send-email-xobs@kosagi.com>
 <20130801084728.GE26614@pengutronix.de>
 <3050A7D1D42E4A0CBC48C9620889E749@kosagi.com>
 <20130801102416.GF26614@pengutronix.de>
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
Received: from mail1.g1.pair.com ([66.39.3.162]:39209 "EHLO mail1.g1.pair.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752055Ab3HAKdT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Aug 2013 06:33:19 -0400
In-Reply-To: <20130801102416.GF26614@pengutronix.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, August 1, 2013 at 6:24 PM, Sascha Hauer wrote:
> On Thu, Aug 01, 2013 at 05:06:13PM +0800, Sean Cross wrote:
> > > Given that this patch adds a devicetree binding which I think we now
> > > agree that this introduces an ABI I think this needs more thought. Some
> > > questions:
> > > 
> > > - Does binding this also work for MII controllers external to the MAC?
> > > Several Marvell SoCs have this situation. MDIO is a bus. With the
> > > binding above you assume that all devices on the bus use the same
> > > settings
> > 
> > 
> > 
> > I'm not quite sure what you mean here. The board I'm testing on is
> > based on an i.MX6q, which has a gigabit MAC and uses a Micrel PHY
> > connected via MDIO. I assumed (perhaps inaccurately) that phy_write()
> > would pick the correct PHY. The example binding is for a single
> > Ethernet device, named "enet". If a board had two Ethernet devices,
> > enet1 and enet2, each could have its own micrel definitions. For
> > example:
> > 
> > &enet1 {
> > micrel,clk-control-pad-skew = <0xf0f0>;
> > micrel,rx-data-pad-skew = <0x0000>;
> > micrel,tx-data-pad-skew = <0xffff>;
> > status = "okay";
> > };
> > 
> > &enet2 {
> > micrel,clk-control-pad-skew = <0x0000>;
> > micrel,rx-data-pad-skew = <0x0000>;
> > micrel,tx-data-pad-skew = <0x0000>;
> > status = "okay";
> > };
> 
> 
> 
> Here each enet controller has its own mdio bus, but look for example at
> Marvell armada-370-db.dts:
> 
> mdio {
> phy0: ethernet-phy@0 {
> reg = <0>;
> };
> 
> phy1: ethernet-phy@1 {
> reg = <1>;
> };
> };
> 
> ethernet@70000 {
> status = "okay";
> phy = <&phy0>;
> phy-mode = "rgmii-id";
> };
> 
> ethernet@74000 {
> status = "okay";
> phy = <&phy1>;
> phy-mode = "rgmii-id";
> };
> 
> Here two ethernet controllers share a single mdio bus. This at least
> requires the binding in the phy node, not the ethernet node.

The code handles this case.  It will only read from the ethernet node if there is no phy node present:

    struct device_node *of_node = dev->of_node;
    if (!of_node && dev->parent->of_node)

        of_node = dev->parent->of_node;

I can add an example in the Documentation to reflect the fact that if a phy has a device tree node, you should put the skew values there.
> > > - The pad skew settings are needed for other phys aswell. It might
> > > be
> > > worth introducing a binding which could work for say Artheros phys
> > > aswell.
> > 
> > 
> > 
> > I can't comment on other phys, as I'm not familiar with them. How
> > would such a system work? This certainly seems like the most
> > open-ended of the questions.
> 
> 
> 
> I think we would need the delay for the different lines in ps, not in
> hardware register specific values. This would have the additional
> benefit that we don't have to hardcode the exact phy type.

Ah, I see.  Your proposal would be to break micrel,clk-control-pad-skew into four different values, and rename them to something like: 
rxc-pad-skew
rx-ctl-pad-skew
txc-pad-skew
tx-ctl-pad-skew

Then the device tree entries would look something like:

rxc-pad-skew = <3000>; // picoseconds
rx-ctl-pad-skew <0>; // picoseconds
txc-pad-skew = <3000>; // picoseconds
tx-ctl-pad-skew = <0>; // picoseconds



How would this affect the Atheros driver?  Are there other names that should be preferred?
