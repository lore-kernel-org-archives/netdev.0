From: Sean Cross <xobs@kosagi.com>
Subject: Re: [PATCH v5] net/phy: micrel: Add OF configuration support
 for ksz9021
Date: Tue, 20 Aug 2013 16:34:59 +0800
Message-ID: <70ADD478D3594155ABF740001DBCB674@kosagi.com>
References: <1375686248-17995-1-git-send-email-xobs@kosagi.com>
 <1375686248-17995-2-git-send-email-xobs@kosagi.com>
 <20130805075846.GJ26614@pengutronix.de>
 <544FF35DE7D643DEB9E792FE766A6B69@kosagi.com>
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
Received: from mail1.g1.pair.com ([66.39.3.162]:31016 "EHLO mail1.g1.pair.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751422Ab3HTIfG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Aug 2013 04:35:06 -0400
In-Reply-To: <544FF35DE7D643DEB9E792FE766A6B69@kosagi.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




On Monday, August 5, 2013 at 4:12 PM, Sean Cross wrote:

> 
> On Monday, August 5, 2013 at 3:58 PM, Sascha Hauer wrote:
> 
> > On Mon, Aug 05, 2013 at 07:04:08AM +0000, Sean Cross wrote:
> > > Some boards require custom PHY configuration, for example due to trace
> > > length differences. Add the ability to configure these registers in
> > > order to get the PHY to function on boards that need it.
> > > 
> > > Because PHYs are auto-detected based on MDIO device IDs, allow PHY
> > > configuration to be specified in the parent Ethernet device node if no
> > > PHY device node is present.
> > > 
> > > Signed-off-by: Sean Cross <xobs@kosagi.com (mailto:xobs@kosagi.com)>
> > > ---
> > > .../devicetree/bindings/net/micrel-ksz9021.txt | 49 ++++++++++
> > > drivers/net/phy/micrel.c | 101 +++++++++++++++++++-
> > > 2 files changed, 149 insertions(+), 1 deletion(-)
> > > create mode 100644 Documentation/devicetree/bindings/net/micrel-ksz9021.txt
> > > 
> > > diff --git a/Documentation/devicetree/bindings/net/micrel-ksz9021.txt b/Documentation/devicetree/bindings/net/micrel-ksz9021.txt
> > > new file mode 100644
> > > index 0000000..338a7e2
> > > --- /dev/null
> > > +++ b/Documentation/devicetree/bindings/net/micrel-ksz9021.txt
> > > @@ -0,0 +1,49 @@
> > > +Micrel KSZ9021 Gigabit Ethernet PHY
> > > +
> > > +Some boards require special tuning values, particularly when it comes to
> > > +clock delays. You can specify clock delay values by adding
> > > +micrel-specific properties to an Ethernet OF device node.
> > > +
> > > +All skew control options are specified in picoseconds. The minimum
> > > +value is 0, and the maximum value is 3000.
> > > +
> > > +Optional properties:
> > > + - rxc-skew : Skew control of RXC pad
> > > + - rxdv-skew : Skew control of RX CTL pad
> > > + - txc-skew : Skew control of TXC pad
> > > + - txen-skew : Skew control of TX_CTL pad
> > > + - rxd0-skew : Skew control of RX data 0 pad
> > > + - rxd1-skew : Skew control of RX data 1 pad
> > > + - rxd2-skew : Skew control of RX data 2 pad
> > > + - rxd3-skew : Skew control of RX data 3 pad
> > > + - txd0-skew : Skew control of TX data 0 pad
> > > + - txd1-skew : Skew control of TX data 1 pad
> > > + - txd2-skew : Skew control of TX data 2 pad
> > > + - txd3-skew : Skew control of TX data 3 pad
> > > +
> > > +Examples:
> > > +
> > > + /* Attach to an Ethernet device with autodetected PHY */
> > > + &enet {
> > > + rxc-skew = <3000>; // picoseconds
> > > + rxdv-skew = <0>; // picoseconds
> > > + txc-skew = <3000>; // picoseconds
> > > + txen-skew = <0>; // picoseconds
> > > + status = "okay";
> > > + };
> > > +
> > > + /* Attach to an explicitly-specified PHY */
> > > + mdio {
> > > + phy0: ethernet-phy@0 {
> > > + rxc-skew = <3000>; // picoseconds
> > > + rxdv-skew = <0>; // picoseconds
> > > + txc-skew = <3000>; // picoseconds
> > > + txen-skew = <0>; // picoseconds
> > > + reg = <0>;
> > > + };
> > > + };
> > > + ethernet@70000 {
> > > + status = "okay";
> > > + phy = <&phy0>;
> > > + phy-mode = "rgmii-id";
> > > + };
> > > diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
> > > index 2510435..3e60ed0 100644
> > > --- a/drivers/net/phy/micrel.c
> > > +++ b/drivers/net/phy/micrel.c
> > > @@ -25,6 +25,7 @@
> > > #include <linux/module.h>
> > > #include <linux/phy.h>
> > > #include <linux/micrel_phy.h>
> > > +#include <linux/of.h>
> > > 
> > > /* Operation Mode Strap Override */
> > > #define MII_KSZPHY_OMSO 0x16
> > > @@ -53,6 +54,18 @@
> > > #define KS8737_CTRL_INT_ACTIVE_HIGH (1 << 14)
> > > #define KSZ8051_RMII_50MHZ_CLK (1 << 7)
> > > 
> > > +/* Write/read to/from extended registers */
> > > +#define MII_KSZPHY_EXTREG 0x0b
> > > +#define KSZPHY_EXTREG_WRITE 0x8000
> > > +
> > > +#define MII_KSZPHY_EXTREG_WRITE 0x0c
> > > +#define MII_KSZPHY_EXTREG_READ 0x0d
> > > +
> > > +/* Extended registers */
> > > +#define MII_KSZPHY_CLK_CONTROL_PAD_SKEW 0x104
> > > +#define MII_KSZPHY_RX_DATA_PAD_SKEW 0x105
> > > +#define MII_KSZPHY_TX_DATA_PAD_SKEW 0x106
> > > +
> > > static int ksz_config_flags(struct phy_device *phydev)
> > > {
> > > int regval;
> > > @@ -65,6 +78,20 @@ static int ksz_config_flags(struct phy_device *phydev)
> > > return 0;
> > > }
> > > 
> > > +static int kszphy_extended_write(struct phy_device *phydev,
> > > + u32 regnum, u16 val)
> > > +{
> > > + phy_write(phydev, MII_KSZPHY_EXTREG, KSZPHY_EXTREG_WRITE | regnum);
> > > + return phy_write(phydev, MII_KSZPHY_EXTREG_WRITE, val);
> > > +}
> > > +
> > > +static int kszphy_extended_read(struct phy_device *phydev,
> > > + u32 regnum)
> > > +{
> > > + phy_write(phydev, MII_KSZPHY_EXTREG, regnum);
> > > + return phy_read(phydev, MII_KSZPHY_EXTREG_READ);
> > > +}
> > > +
> > > static int kszphy_ack_interrupt(struct phy_device *phydev)
> > > {
> > > /* bit[7..0] int status, which is a read and clear register. */
> > > @@ -141,6 +168,78 @@ static int ks8051_config_init(struct phy_device *phydev)
> > > return rc < 0 ? rc : 0;
> > > }
> > > 
> > > +static int ksz9021_load_values_from_of(struct phy_device *phydev,
> > > + struct device_node *of_node, u16 reg,
> > > + char *field1, char *field2,
> > > + char *field3, char *field4)
> > > +{
> > > + int val1 = -1;
> > > + int val2 = -2;
> > > + int val3 = -3;
> > > + int val4 = -4;
> > > + int newval;
> > > + int matches = 0;
> > > +
> > > + if (!of_property_read_u32(of_node, field1, &val1))
> > > + matches++;
> > > +
> > > + if (!of_property_read_u32(of_node, field2, &val2))
> > > + matches++;
> > > +
> > > + if (!of_property_read_u32(of_node, field3, &val3))
> > > + matches++;
> > > +
> > > + if (!of_property_read_u32(of_node, field4, &val4))
> > > + matches++;
> > > +
> > > + if (!matches)
> > > + return 0;
> > > +
> > > + if (matches < 4)
> > > + newval = kszphy_extended_read(phydev, reg);
> > > + else
> > > + newval = 0;
> > 
> > 
> > 
> > 
> > 
> > Just initialize newval with the reset default of this register. It will
> > make this function easier. Also this two step read from dt and evaluate
> > afterwards seems unnecessary.
> 
> 
> 
> The documentation seems inaccurate here. My datasheet says it defaults to 0x0111, but when I check it for myself it comes out 0x7777. Which value do you think I should take?
> > > +
> > > + if (val1 != -1)
> > > + newval = ((newval & 0xfff0) | ((val1/200)&0xf) << 0);
> > > +
> > > + if (val2 != -1)
> > > + newval = ((newval & 0xff0f) | ((val2/200)&0xf) << 4);
> > > +
> > > + if (val3 != -1)
> > > + newval = ((newval & 0xf0ff) | ((val3/200)&0xf) << 8);
> > > +
> > > + if (val4 != -1)
> > > + newval = ((newval & 0x0fff) | ((val4/200)&0xf) << 12);
> > > +
> > > + return kszphy_extended_write(phydev, reg, newval);
> > > +}
> > > +
> > > +static int ksz9021_config_init(struct phy_device *phydev)
> > > +{
> > > + struct device *dev = &phydev->dev;
> > > + struct device_node *of_node = dev->of_node;
> > > +
> > > + if (!of_node && dev->parent->of_node)
> > > + of_node = dev->parent->of_node;
> > > +
> > > + if (of_node) {
> > > + ksz9021_load_values_from_of(phydev, of_node,
> > > + MII_KSZPHY_CLK_CONTROL_PAD_SKEW,
> > > + "txen-skew", "txc-skew",
> > > + "rxdv-skew", "rxc-skew");
> > > + ksz9021_load_values_from_of(phydev, of_node,
> > > + MII_KSZPHY_RX_DATA_PAD_SKEW,
> > > + "rxd0-skew", "rxd1-skew",
> > > + "rxd2-skew", "rxd3-skew");
> > > + ksz9021_load_values_from_of(phydev, of_node,
> > > + MII_KSZPHY_TX_DATA_PAD_SKEW,
> > > + "txd0-skew", "txd1-skew",
> > > + "txd2-skew", "txd3-skew");
> > 
> > 
> > 
> > 
> > 
> > Are you sure this register exists? It's not mentioned in my datasheet,
> > only the first two are.
> 
> 
> 
> I'm very sure the register exists. There's a hole in the documentation where the TX control register should exist. Furthermore, we measured that changing values in this register adjusted the TX skew on the RG-MII wires, and on our board at least, adjusting these values yields increased performance. 
There hasn't been any response to this patch in two weeks.  Can someone please merge this patch or indicate what's wrong with it? 
