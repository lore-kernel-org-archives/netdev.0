From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 4/6] of: add API for changing parameters of fixed link
Date: Fri, 27 Mar 2015 09:21:39 -0700
Message-ID: <CAGVrzcaLfQcTAx8OR=sE=7FLrp0gGvfX8_YfxK_CU+x26JHymw@mail.gmail.com>
References: <55155AFC.4050800@list.ru> <55155D35.1070703@list.ru>
 <CAGVrzcau0mUne8uXsTs_9=e4JtQt5w5L+hwtLmKo+UfjSEwC+w@mail.gmail.com> <5515803F.3020600@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Linux kernel <linux-kernel@vger.kernel.org>,
	Stas Sergeev <stsp@users.sourceforge.net>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Stas Sergeev <stsp@list.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5515803F.3020600@list.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2015-03-27 9:07 GMT-07:00 Stas Sergeev <stsp@list.ru>:
> 27.03.2015 18:41, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>> 2015-03-27 6:37 GMT-07:00 Stas Sergeev <stsp@list.ru>:
>>>
>>> The following API is added:
>>> - of_phy_fixed_link_set_link() allows to set link state (up/down)
>>> - of_phy_fixed_link_set_speed() allows to set link speed
>>> - of_phy_fixed_link_set_duplex() allows to enable/disable duplex
>>>
>>> This API is needed when the MDIO-less link have some other means
>>> of a status passing to MAC, for example with in-band data (SGMII).
>>> MAC driver can then use that API to update the PHY status.
>>
>> I do not think any of these changes are required, if you look at
>> drivers/net/dsa/bcm_sf2.c, there is a fixed_link_update callback to
>> re-act to link up/down interrupts (but this could easily be extended
>> to speed/duplex as well), by directly modifying a fixed_phy_status
>> structure.
>>
>> Can you try that approach in mvneta?
> Just to make sure I properly understand what you want.
> drivers/net/dsa/bcm_sf2.c registers the .fixed_link_update callback
> of struct dsa_switch_driver, which is later called from net/dsa/slave=
=2Ec's
> dsa_slave_fixed_link_update().

Right, that's because there is a two layer model, first in DSA, then
in the switch driver.

> Do you want mvneta to register a similar callback in of_mdio, instead
> of adding an explicit state-updating functions? Something like
> of_phy_fixed_link_set_update_callback()?

You don't need an of_phy_fixed_link_set_update callback, you just need
to provide a fixed_link_update callback in mvneta, that you register,
if and only if you are binding to a fixed PHY which is also SGMII (you
can use a phy-mode property to tell that). So essentially, do the same
thing as net/dsa/slave.c, checking that a PHY is fixed, and if so,
register a fixed_link_update callback, within mvneta, and this
callback updates fixed_phy_status, ala drivers/net/dsa/bcm_sf2.c to
adjust the link parameters.

> This will remove a few changes indeed, but perhaps not too much.
> Please confirm if this is exactly what you want, and then I try.

Let me know if this is clearer now, if not, I can certainly cook a
patch which does what I am suggesting. Thanks!
--=20
=46lorian
