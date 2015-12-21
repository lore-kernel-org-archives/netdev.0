From: Shaohui Xie <shaohui.xie@nxp.com>
Subject: RE: [PATCH] net: phy: adds backplane driver for Freescale's PCS PHY
Date: Mon, 21 Dec 2015 12:17:03 +0000
Message-ID: <VI1PR04MB166411C52B56AE738706F407E8E40@VI1PR04MB1664.eurprd04.prod.outlook.com>
References: <1450431054-5227-1-git-send-email-shh.xie@gmail.com>
 <20151218120209.GA477@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"Xie Shaohui-B21989" <Shaohui.Xie@freescale.com>,
	Shaohui Xie <shaohui.xie@nxp.com>
To: Andrew Lunn <andrew@lunn.ch>,
	"shh.xie@gmail.com" <shh.xie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0063.outbound.protection.outlook.com ([157.56.112.63]:31436
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751145AbbLUMcs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2015 07:32:48 -0500
In-Reply-To: <20151218120209.GA477@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Fri, Dec 18, 2015 at 05:30:54PM +0800, shh.xie@gmail.com wrote:
> > +static int fsl_backplane_probe(struct phy_device *phydev) {
> > +	struct fsl_xgkr_inst *xgkr_inst;
> > +	struct device_node *child, *parent, *lane_node;
> > +	const char *lane_name;
> > +	int len;
> > +	int ret;
> > +	u32 mode;
> > +	u32 lane[2];
> > +
> > +	child = phydev->dev.of_node;
> > +	parent = of_get_parent(child);
> > +	if (!parent) {
> > +		dev_err(&phydev->dev, "could not get parent node");
> > +		return 0;
> > +	}
> > +
> > +	lane_name = of_get_property(parent, "lane-instance", &len);
> > +	if (!lane_name)
> > +		return 0;
> > +
> > +	if (strstr(lane_name, "1000BASE-KX"))
> > +		mode = BACKPLANE_1G_KX;
> > +	else
> > +		mode = BACKPLANE_10G_KR;
> > +
> > +	lane_node = of_parse_phandle(child, "lane-handle", 0);
> 
> 
> Hi Shaohui
> 
> You are missing the device tree binding Documentation.
> 
> Parent will be the mdio bus device and you want 'lane-instance' and
> 'lane-handle' properties to be in the mdio bus node?
[S.H] Hi Andrew,

Thanks for reviewing the patch!

I did missed the device tree binding documentation.
This driver expected a property "lane-instance" in mdio bus node, and
"lane-handle" and "lane-range" properties in phy node.

The "lane-instance" indicates what the phy should be probed as,
1000BASE-KX or 10GBASE-KR, seems phy node is a better place than mdio bus node
to hold this property, maybe a better name "phy-mode" should be used?

The "lane-handle" pointed to a serdes node which looks like below:
E.g. in arch/powerpc/boot/dts/fsl/t4240si-post.dtsi:

        serdes: serdes@ea000 {
                compatible = "fsl,t4240-serdes";
                reg        = <0xea000 0x4000>;
        };

The "lane-handle" property would be: lane-handle = <&serdes>;

The serdes node has "reg" property for the whole registers space,
for a PCS phy, only some serdes registers (lane control registers)
are related and needed to be configured at runtime, so I used the 
"lane-range" property to hold such information, it would be e.g.:
lane-range = <0x1800 0x40>;
'0x1800' is offset of the lane control registers in serdes, '0x40' is 
size of the space.
Different PCS phy has different offset, but the size is same.

"phy-mode" (if it can be used here) has been documented in: 
Documentation/devicetree/bindings/net/ethernet.txt,
I'm not sure where the serdes lane related properties should go, 
 'fsl-tsec-phy.txt' or a new binding like 'fsl-pcs-phy.txt'?
Please comment.

Thanks!
Shaohui
