From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v3 05/11] net: stmmac: dwmac-rk: Add internal phy support
Date: Wed, 09 Aug 2017 15:42:05 -0700
Message-ID: <77E3C546-E3A8-4EE5-8505-2C4B2252E08C@gmail.com>
References: <1501654546-17292-1-git-send-email-david.wu@rock-chips.com> <1501654888-19514-1-git-send-email-david.wu@rock-chips.com> <6b1ebf64-6903-6d35-b1fc-92ec47334425@gmail.com> <CAGb2v65Rtw2B3Hcs4L0jTRQ2ApUduJ+Nf1W1XnqXBBmFwMaP-g@mail.gmail.com> <20170809084541.GB7137@Red>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: David Wu <david.wu@rock-chips.com>,
        =?ISO-8859-1?Q?Heiko_St=FCbner?= <heiko@sntech.de>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>,
        Olof Johansson <olof@lixom.net>,
        Russell King <linux@armlinux.org.uk>,
        Arnd Bergmann <arnd@arndb.de>,
        Tao Huang <huangtao@rock-chips.com>, hwg@rock-chips.com,
        alexandre.torgue@st.com, devicetree <devicetree@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        "open list:ARM/Rockchip SoC..." <linux-rockchip@lists.infradead.org>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
        wens@csie.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>, andrew@lunn.ch,
        davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170809084541.GB7137@Red>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On August 9, 2017 1:45:41 AM PDT, Corentin Labbe <clabbe=2Emontjoie@gmail=
=2Ecom> wrote:
>On Thu, Aug 03, 2017 at 07:06:33PM +0800, Chen-Yu Tsai wrote:
>> On Thu, Aug 3, 2017 at 1:38 AM, Florian Fainelli
><f=2Efainelli@gmail=2Ecom> wrote:
>> > On 08/01/2017 11:21 PM, David Wu wrote:
>> >> To make internal phy work, need to configure the phy_clock,
>> >> phy cru_reset and related registers=2E
>> >>
>> >> Signed-off-by: David Wu <david=2Ewu@rock-chips=2Ecom>
>> >> ---
>> >>  =2E=2E=2E/devicetree/bindings/net/rockchip-dwmac=2Etxt     |  6 +-
>> >>  drivers/net/ethernet/stmicro/stmmac/dwmac-rk=2Ec     | 81
>++++++++++++++++++++++
>> >>  2 files changed, 86 insertions(+), 1 deletion(-)
>> >>
>> >> diff --git
>a/Documentation/devicetree/bindings/net/rockchip-dwmac=2Etxt
>b/Documentation/devicetree/bindings/net/rockchip-dwmac=2Etxt
>> >> index 8f42755=2E=2Eec39b31 100644
>> >> --- a/Documentation/devicetree/bindings/net/rockchip-dwmac=2Etxt
>> >> +++ b/Documentation/devicetree/bindings/net/rockchip-dwmac=2Etxt
>> >> @@ -25,7 +25,8 @@ Required properties:
>> >>   - clock-names: One name for each entry in the clocks property=2E
>> >>   - phy-mode: See ethernet=2Etxt file in the same directory=2E
>> >>   - pinctrl-names: Names corresponding to the numbered pinctrl
>states=2E
>> >> - - pinctrl-0: pin-control mode=2E can be <&rgmii_pins> or
><&rmii_pins>=2E
>> >> + - pinctrl-0: pin-control mode=2E can be <&rgmii_pins>,
><&rmii_pins> or led pins
>> >> +   for internal phy mode=2E
>> >>   - clock_in_out: For RGMII, it must be "input", means main
>clock(125MHz)
>> >>     is not sourced from SoC's PLL, but input from PHY; For RMII,
>"input" means
>> >>     PHY provides the reference clock(50MHz), "output" means GMAC
>provides the
>> >> @@ -40,6 +41,9 @@ Optional properties:
>> >>   - tx_delay: Delay value for TXD timing=2E Range value is 0~0x7F,
>0x30 as default=2E
>> >>   - rx_delay: Delay value for RXD timing=2E Range value is 0~0x7F,
>0x10 as default=2E
>> >>   - phy-supply: phandle to a regulator if the PHY needs one
>> >> + - clocks: <&cru MAC_PHY>: Clock selector for internal macphy
>> >> + - phy-is-internal: A boolean property allows us to know that MAC
>will connect to
>> >> +   internal phy=2E
>> >
>> > This is incorrect in two ways:
>> >
>> > - this is a property of the PHY, so it should be documented as such
>in
>> > Documentation/devicetree/bindings/net/phy=2Etxt so other bindings can
>> > re-use it
>> >
>> > - if it was specific to your MAC you would expect a vendor prefix
>to
>> > this property, which is not there
>> >
>> > An alternative way to implement the external/internal logic
>selection
>> > would be mandate that your Ethernet PHY node have a compatible
>string
>> > like this:
>> >
>> > phy@0 {
>> >         compatible =3D "ethernet-phy-id1234=2Ed400",
>"ethernet-phy-802=2E3-c22";
>> > };
>> >
>> > Then you don't need this phy-is-internal property, because you can
>> > locate the PHY node by the phy-handle (see more about that in a
>reply to
>> > patch 10) and you can determine ahead of time whether this PHY is
>> > internal or not based on its compatible string=2E
>>=20
>> This doesn't really work for us (sunxi)=2E The "internal" PHY of the H3
>> is also available in the X-Powers AC200 combo chip, which would be
>> external=2E Same ID=2E So if someone were to be stupid and put the two
>> together, you wouldn't know which one it actually is=2E Generically
>> it doesn't make sense to match against the ID either=2E The PHY is
>> only integrated or inlined into the SoC, meaning it could be moved
>> elsewhere or even be a discreet part=2E

It actually makes a lot of sense to differentiate on the PHY ID because yo=
u are supposed to allocate an unique ID based on how the integration of the=
 PHY is done=2E Not doing that is making a sloppy job at integrating HW blo=
cks, but such is life and there is no shortage of creativity amongst HW eng=
ineers when they are not given feedback from SW people=2E

>>=20
>> The way I see it is more like a reversed pinmux=2E The system should
>> select either the internal set or external set of xMII pins to use=2E
>>=20
>> A phy-is-internal property in the PHY node would work for us=2E We
>> already need a PHY node to describe its clocks and resets=2E
>>=20
>> A side note to this solution is that, since the internal PHY is
>defined
>> at the =2Edtsi level, any external PHYs at the same address would need
>to
>> make sure to delete the property, which is kind of counterintuitive,
>but
>> it is how device tree works=2E One would want to put the internal PHY's
>> address, assuming it is configurable, on something that is rarely
>used=2E
>>=20
>
>Hello David, Florian, Andrew
>
>Could someone ack this ? or nack if you think that the chance for
>having two PHY id both internal and external is too low=2E
>Anyway, we need a choice=2E

Let's move forward with the 'phy-is-integrated' Boolean property ('phy-is-=
internal' is too close from the proprietary "internal" phy-mode IMHO)=2E An=
drew, does that also work for you?

--=20
Florian
