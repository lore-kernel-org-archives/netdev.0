From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 05/11] net: stmmac: dwmac-rk: Add internal phy support
Date: Thu, 27 Jul 2017 09:54:01 -0700
Message-ID: <65ae1747-4dff-b1d8-8aa3-684fc8c7809a@gmail.com>
References: <1501160156-30328-1-git-send-email-david.wu@rock-chips.com>
 <1501160540-30662-1-git-send-email-david.wu@rock-chips.com>
 <20170727134834.GD18666@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, heiko@sntech.de, robh+dt@kernel.org,
        mark.rutland@arm.com, catalin.marinas@arm.com, will.deacon@arm.com,
        olof@lixom.net, linux@armlinux.org.uk, arnd@arndb.de,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        huangtao@rock-chips.com, hwg@rock-chips.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-rockchip@lists.infradead.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>, David Wu <david.wu@rock-chips.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170727134834.GD18666@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/27/2017 06:48 AM, Andrew Lunn wrote:
> On Thu, Jul 27, 2017 at 09:02:16PM +0800, David Wu wrote:
>> To make internal phy work, need to configure the phy_clock,
>> phy cru_reset and related registers.
>>
>> Signed-off-by: David Wu <david.wu@rock-chips.com>
>> ---
>> changes in v2:
>>  - Use the standard "phy-mode" property for internal phy. (Florian)
> 
> I think we need to discuss this. This PHY appears to be on an MDIO
> bus, it uses a standard PHY driver, and it appears to be using an RMII
> interface. So it is just an ordinary PHY.

First, the fact that the internal PHY also appears through MDIO is
orthogonal to the fact that it is internal or external. Plenty of
designs have internal PHYs exposed through MDIO because that is
convenient. What matters though is how the data/clock lines are wired
internally, which is what "phy-mode" describes.

> 
> Internal is supposed to be something which is not ordinary, does not
> use one of the standard phy modes, needs something special to make it
> work.
> 
> Florain, it appears to be your suggestion to use internal. What do you
> say?

phy-mode = "internal" really means that it is not a standard MII variant
to connect the data/clock lines between the Ethernet MAC and the PHY,
and this can happen in some designs (although quite unlikely). So from
there we could do several things depending on the requirements:

- if you can have your Ethernet MAC driver perform the necessary
configuration *after* you have been able to bind the PHY device with its
PHY driver, then the PHY driver should have PHY_IS_INTERNAL in its
flags, and you can use phy_is_internal() from PHYLIB to tell you that
and we could imagine using: phy-mode = "rmii" because that would not too
much of a stretch

- if you need knowledge about this PHY connection type prior to binding
the PHY device and its driver (that is, before of_phy_connect()) we
could add a boolean property e.g: "phy-is-internal" that allows us to
know that, or we can have a new phy-mode value, e.g: "internal-rmii"
which describes that, either way would probably be fine, but the former
scales better

Then again, using phy-mode = "internal" even though this is Reduced MII
is not big of a deal IMHO as long as there is no loss of information and
that internal de-facto means internal reduced MII for instance.
-- 
Florian
