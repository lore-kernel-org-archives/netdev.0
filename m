From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH 2/3] ARM: sun8i: sunxi-h3-h5: add phy-is-integrated
 property to internal PHY
Date: Fri, 11 Aug 2017 15:25:26 +0200
Message-ID: <20170811132526.GD25147@Red>
References: <20170810085129.20463-1-clabbe.montjoie@gmail.com>
 <20170810085129.20463-3-clabbe.montjoie@gmail.com>
 <CAGb2v64dBZgN6-8kHnnN1qiEXHnbXw_FM9WxGHPU0h-tZDbspA@mail.gmail.com>
 <20170811080543.GA25147@Red>
 <CAGb2v66wCRe8nFucJa5nAT1GhO75LmCyfNWQQbwxzh085Zwk+w@mail.gmail.com>
 <20170811081920.GB25147@Red>
 <CAGb2v66SGAKnFoHNqWR+DqS-mY3KA853NmKpdHqf8huOkisLKg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Russell King <linux@armlinux.org.uk>,
        Maxime Ripard <maxime.ripard@free-electrons.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        alexandre.torgue@st.com, netdev <netdev@vger.kernel.org>,
        devicetree <devicetree@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
        andrew@lunn.ch
To: Chen-Yu Tsai <wens@csie.org>, robh+dt@kernel.org,
        mark.rutland@arm.com, f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAGb2v66SGAKnFoHNqWR+DqS-mY3KA853NmKpdHqf8huOkisLKg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 11, 2017 at 04:22:11PM +0800, Chen-Yu Tsai wrote:
> On Fri, Aug 11, 2017 at 4:19 PM, Corentin Labbe
> <clabbe.montjoie@gmail.com> wrote:
> > On Fri, Aug 11, 2017 at 04:11:13PM +0800, Chen-Yu Tsai wrote:
> >> On Fri, Aug 11, 2017 at 4:05 PM, Corentin Labbe
> >> <clabbe.montjoie@gmail.com> wrote:
> >> > On Fri, Aug 11, 2017 at 10:42:51AM +0800, Chen-Yu Tsai wrote:
> >> >> Hi,
> >> >>
> >> >> On Thu, Aug 10, 2017 at 4:51 PM, Corentin Labbe
> >> >> <clabbe.montjoie@gmail.com> wrote:
> >> >> > This patch add the new phy-is-integrated property to the internal PHY
> >> >> > node.
> >> >> >
> >> >> > Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> >> >> > ---
> >> >> >  arch/arm/boot/dts/sunxi-h3-h5.dtsi | 1 +
> >> >> >  1 file changed, 1 insertion(+)
> >> >> >
> >> >> > diff --git a/arch/arm/boot/dts/sunxi-h3-h5.dtsi b/arch/arm/boot/dts/sunxi-h3-h5.dtsi
> >> >> > index 4b599b5d26f6..54fc24e4c569 100644
> >> >> > --- a/arch/arm/boot/dts/sunxi-h3-h5.dtsi
> >> >> > +++ b/arch/arm/boot/dts/sunxi-h3-h5.dtsi
> >> >> > @@ -425,6 +425,7 @@
> >> >> >                                         reg = <1>;
> >> >> >                                         clocks = <&ccu CLK_BUS_EPHY>;
> >> >> >                                         resets = <&ccu RST_BUS_EPHY>;
> >> >> > +                                       phy-is-integrated;
> >> >>
> >> >> You also need to "delete" this property at the board level for
> >> >> any board that has the external PHY at address <1>. Otherwise
> >> >> they will stop working. This is due to the internal and external
> >> >> PHYs having the same path and node name in the device tree, so
> >> >> they are effectively the same node.
> >> >>
> >> >> ChenYu
> >> >>
> >> >
> >> > They have not the same name, ext_rgmii_phy vs int_mii_phy.
> >>
> >> That is just the label. The label plays no part in device tree merging. The path
> >>
> >>     /soc/ethernet@1c30000/mdio/ethernet-phy@1
> >>
> >> is the same. You can look under
> >>
> >>     /proc/device-tree/soc/ethernet@1c30000/mdio
> >>
> >> on the OrangePI Plus 2E or any other H3 board that uses an
> >> external PHY at address 1.
> >>
> >> ChenYu
> >
> > Since we get the phy node by phy-handle and not by path, I think all should be good.
> 
> You are not getting me. The fact that the two seemingly separate
> nodes are merged together means, whatever properties you put in
> the internal PHY node, also affect the external PHY node. Once
> compiled, they are the SAME node.

Hello Rob, florian, mark

Adding a delete property on all external ethernet-phy@1 is a bit overkill, and I dont like the idea that nodes are merged.
What do you think about other possible solutions:
- Using integrated-phy@1 for the integrated PHY node name
- Using a fake address like 31 (see patch below)

If you have any other solution...

Regards

>From fe39183946f7f4a6e21bce38fd8e4c1413012d68 Mon Sep 17 00:00:00 2001
From: Corentin Labbe <clabbe.montjoie@gmail.com>
Date: Fri, 11 Aug 2017 14:49:54 +0200
Subject: [PATCH] ARM: sun8i: sunxi-h3-h5: Prevent merge of external and
 integrated PHY

Actually, some external and integrated PHY are merged due to same dtnode
name "ethernet-phy@1".

This is problematic when we will want to use the phy-is-integrated
property. (Need to delete it on all external PHY node)

An easy solution is to set integrated PHY nodeaddresss at a fake one
that would never be used.
Since board makers currently only provides PHY at addresses 1 and 7,
we will use 31.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 arch/arm/boot/dts/sunxi-h3-h5.dtsi | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/arch/arm/boot/dts/sunxi-h3-h5.dtsi b/arch/arm/boot/dts/sunxi-h3-h5.dtsi
index 54fc24e4c569..2110b0069e33 100644
--- a/arch/arm/boot/dts/sunxi-h3-h5.dtsi
+++ b/arch/arm/boot/dts/sunxi-h3-h5.dtsi
@@ -420,7 +420,15 @@
 			mdio: mdio {
 				#address-cells = <1>;
 				#size-cells = <0>;
-				int_mii_phy: ethernet-phy@1 {
+				/*
+				 * Using 31 permits to make a separation between
+				 * this integrated PHY and external ones.
+				 * Without it, external "ethernet-phy@1" will be
+				 * merged with it (due to same dtnode name).
+				 * Board makers currently only provides PHY at
+				 * addresses 1 and 7.
+				 */
+				int_mii_phy: ethernet-phy@31 {
 					compatible = "ethernet-phy-ieee802.3-c22";
 					reg = <1>;
 					clocks = <&ccu CLK_BUS_EPHY>;
-- 
2.13.0
