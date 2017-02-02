From: Lukasz Majewski <lukma@denx.de>
Subject: Re: [PATCH] net: phy: dp83867: Port mirroring support in the
 DP83867 TI's PHY driver
Date: Thu, 2 Feb 2017 10:17:39 +0100
Message-ID: <20170202101739.67e7e6b3@jawa>
References: <1485960215-5148-1-git-send-email-lukma@denx.de>
        <20170201171610.GC7395@lunn.ch>
        <2f3766f0-42df-6aab-dda1-14022c57fb30@gmail.com>
        <20170201220500.29d478aa@jawa>
        <20170201211440.GG7395@lunn.ch>
        <20170201231323.732dd327@jawa>
        <20170202015416.GG4967@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Karicheri Muralidharan <m-karicheri2@ti.com>,
        linux-kernel@vger.kernel.org, Eric Engestrom <eric@engestrom.ch>,
        netdev@vger.kernel.org, Kishon Vijay Abraham I <kishon@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        devicetree@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170202015416.GG4967@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

> On Wed, Feb 01, 2017 at 11:13:23PM +0100, Lukasz Majewski wrote:
> > Hi Andrew,
> > 
> > > > We would need a tri-state device tree properly:
> > > > 
> > > > 1. Not defined - do nothing
> > > > 2. Defined as 0 -> explicitly disable port mirroring
> > > > 3. Defined as 1 -> explicitly enable port mirriring
> > > > 
> > > > The "net-phy-lane-swap" only fulfills points 1 and 3 above.
> > > > 
> > > > In my use case I do need point 2.
> > > 
> > > Looking at the datasheet, PORT_MIRROR_EN defaults to 0. So it
> > > seems reasonable to unconditionally set it to 0 when the PHY
> > > driver loads. Any device which needs a value of 1 can set
> > > "net-phy-lane-swap"
> > 
> > Unconditionally setting this field to 0 (as we expect the reset
> > default setting) seems to me like a good solution. 
> > 
> > However, I was not sure if such approach is acceptable by the
> > community.
> 
> So the issue here is, are there boards with bootloaders which set this
> "lane swap" bit,

The bootstrapping process in the PHY sets this bit. This is wrong since
the board lane layout is not "swapped"

The bootloader (u-boot) fixes this, since we need to support
networking (tftp, ping).


> and rely on Linux not changing it, 

When we boot Linux everything is OK, until the dp83867 driver comes
into play and performs reset (including register reset).

Then the "bootstrap", initial line swap is setup again (wrongly). So we
need a way in Linux to make things correct again.

> because the
> hardware design has such a swap?
> 
> It seems the bootloader you are using does this. 

The bootloader fixes things, but then in Linux the PHY driver
(dp83867.c) performs "RESET" which breaks networking again.

> But in your case, it
> does it wrongly. 

The bootloader does its job correctly.

> I'm guessing you have a vendor bootloader? And no
> easy access to the sources? 

Mainline u-boot (all vendor code will be upstreamed).

> Otherwise you would of fixed the
> bootloader. So can we assume there are vendor designed boards which
> require the swap? Do they run a mainline kernel? Or only the vendor
> kernel?

All stuff is going to run mainline kernel (LTS - v4.9 ?).

> 
> If we know of mainline boards which are going to break, we should not
> do this.
> 
> If however we do decide to reset it to default value, i think it would
> be good to implement net-phy-lane-swap as well, so giving people an
> easier path towards mainline.

I have thought a bit about that and I think that we should define
complementary "net-phy-lane-no-swap" as suggested by Florian. Then
affected boards could define it and use.

> 
>        Andrew




Best regards,

Lukasz Majewski

--

DENX Software Engineering GmbH,      Managing Director: Wolfgang Denk
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
Phone: (+49)-8142-66989-10 Fax: (+49)-8142-66989-80 Email: wd@denx.de
