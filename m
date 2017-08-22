From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH v3 3/4] net: stmmac: register parent MDIO node for
 sun8i-h3-emac
Date: Tue, 22 Aug 2017 21:37:13 +0200
Message-ID: <20170822193713.GB11596@Red>
References: <20170820065757.GA6081@Red>
 <20170820142545.GB24150@lunn.ch>
 <CAGb2v67hQXSoCKP7qW+KRUYX+0djQ1Z23cQ67Lyg6G7ozGyfGQ@mail.gmail.com>
 <20170821132015.GB1703@lunn.ch>
 <20170821133104.qvrhvwin2rdg4aqo@flea.lan>
 <20170821142321.GE1703@lunn.ch>
 <CAGb2v64E4T=1ff3POGuXZA=MvjGAnKQ6OF6A3sT_cU-=jh6zNw@mail.gmail.com>
 <bfe784b6-5137-8fcd-dbd0-ad96974f4060@gmail.com>
 <20170822181140.GA11596@Red>
 <352ae66b-78a4-e88b-4544-a8edd9390b0c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chen-Yu Tsai <wens@csie.org>, Andrew Lunn <andrew@lunn.ch>,
        Maxime Ripard <maxime.ripard@free-electrons.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Russell King <linux@armlinux.org.uk>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        devicetree <devicetree@vger.kernel.org>,
        linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <352ae66b-78a4-e88b-4544-a8edd9390b0c@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 22, 2017 at 11:35:01AM -0700, Florian Fainelli wrote:
> On 08/22/2017 11:11 AM, Corentin Labbe wrote:
> > On Tue, Aug 22, 2017 at 09:40:24AM -0700, Florian Fainelli wrote:
> >> On 08/22/2017 08:39 AM, Chen-Yu Tsai wrote:
> >>> On Mon, Aug 21, 2017 at 10:23 PM, Andrew Lunn <andrew@lunn.ch> wrote:
> >>>>> All muxes are mostly always represented the same way afaik, or do you
> >>>>> want to simply introduce a new compatible / property?
> >>>>
> >>>> +         mdio-mux {
> >>>> +               compatible = "allwinner,sun8i-h3-mdio-switch";
> >>>> +               mdio-parent-bus = <&mdio_parent>;
> >>>> +               #address-cells = <1>;
> >>>> +               #size-cells = <0>;
> >>>> +
> >>>> +               internal_mdio: mdio@1 {
> >>>>                         reg = <1>;
> >>>> -                       clocks = <&ccu CLK_BUS_EPHY>;
> >>>> -                       resets = <&ccu RST_BUS_EPHY>;
> >>>> +                       #address-cells = <1>;
> >>>> +                       #size-cells = <0>;
> >>>> +                       int_mii_phy: ethernet-phy@1 {
> >>>> +                               compatible = "ethernet-phy-ieee802.3-c22";
> >>>> +                               reg = <1>;
> >>>> +                               clocks = <&ccu CLK_BUS_EPHY>;
> >>>> +                               resets = <&ccu RST_BUS_EPHY>;
> >>>> +                               phy-is-integrated;
> >>>> +                       };
> >>>> +               };
> >>>> +               mdio: mdio@0 {
> >>>> +                       reg = <0>;
> >>>> +                       #address-cells = <1>;
> >>>> +                       #size-cells = <0>;
> >>>>                 };
> >>>>
> >>>> Hi Maxim
> >>>>
> >>>> Anybody who knows the MDIO-mux code/binding, knows that it is a run
> >>>> time mux. You swap the mux per MDIO transaction. You can access all
> >>>> the PHY and switches on the mux'ed MDIO bus.
> >>>>
> >>>> However here, it is effectively a boot-time MUX. You cannot change it
> >>>> on the fly. What happens when somebody has a phandle to a PHY on the
> >>>> internal and a phandle to a phy on the external? Does the driver at
> >>>> least return -EINVAL, or -EBUSY? Is there a representation which
> >>>> eliminates this possibility?
> >>>
> >>> There is only one controller. Either you use the internal PHY, which
> >>> is then directly coupled (no magnetics needed) to the RJ45 port, or
> >>> you use an external PHY over MII/RMII/RGMII. You could supposedly
> >>> have both on a board, and let the user choose one. But why bother
> >>> with the extra complexity and cost? Either you use the internal PHY
> >>> at 100M, or an external RGMII PHY for gigabit speeds.
> >>
> >> I agree, there is no point in over-engineering any of this. I don't
> >> think there is actually any MDIO mux per-se in that the MDIO clock and
> >> data lines are muxed, however there has to be some kind of built-in port
> >> multiplexer that lets you chose between connecting to the internal PHY
> >> and any external PHY/MAC, but that is not what a "mdio-mux" node represents.
> >>
> >>>
> >>> So I think what you are saying is either impossible or engineering-wise
> >>> a very stupid design, like using an external MAC with a discrete PHY
> >>> connected to the internal MAC's MDIO bus, while using the internal MAC
> >>> with the internal PHY.
> >>>
> >>> Now can we please decide on something? We're a week and a half from
> >>> the 4.13 release. If mdio-mux is wrong, then we could have two mdio
> >>> nodes (internal-mdio & external-mdio).
> >>
> >> I really don't see a need for a mdio-mux in the first place, just have
> >> one MDIO controller (current state) sub-node which describes the
> >> built-in STMMAC MDIO controller and declare the internal PHY as a child
> >> node (along with 'phy-is-integrated'). If a different configuration is
> >> used, then just put the external PHY as a child node there.
> >>
> >> If fixed-link is required, the mdio node becomes unused anyway.
> >>
> >> Works for everyone?
> > 
> > If we put an external PHY with reg=1 as a child of internal MDIO, il will be merged with internal PHY node and get phy-is-integrated.
> 
> Then have the .dtsi file contain just the mdio node, but no internal or
> external PHY and push all the internal and external PHY node definition
> (in its entirety) to the per-board DTS file, does not that work?
> 

It is near what I sent in v2 of this serie. (only one MDIO with internal PHY, but phy-is-integrated is only set per-board DTS)
But at that time Rob said to use a mdio-mux.

> > 
> > Does two MDIO node "internal-mdio" and "mdio" works for you ?
> > (We keep "mdio" for external MDIO for reducing the number of patchs)
> 
> How does that solve the problem and not create a new one where both MDIO
> nodes end-up being registered? Does that mean you force the writer of
> the board-level DTS to systematically disable the internal MDIO node
> when using an external PHY and vice versa? How is that better than not
> being explicit like I suggested earlier?
> 

Only one node is registered.
stmmac register only MDIO called "mdio".
So it is why I have added a patch "register parent MDIO node for sun8i-h3-emac" which for H3 only register the PHY's parent MDIO

But yes back to your solution "only one mdio with internal PHY," and phy-is-integrated only set on board DT which use internal PHY will work.

Regards
