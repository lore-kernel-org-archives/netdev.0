From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH] net: phy: b53: switchdev driver for Broadcom BCM53xx switches
Date: Tue, 24 Feb 2015 23:29:16 +0100
Message-ID: <CACna6ryiyzeGDoFwSpkOQ9MnumQxB699vEtoY=XRwaD9HE0ryA@mail.gmail.com>
References: <1424799727-30946-1-git-send-email-zajec5@gmail.com>
	<20150224215155.GA15633@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Jonas Gorski <jogo@openwrt.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Felix Fietkau <nbd@openwrt.org>, Jiri Pirko <jiri@resnulli.us>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:52833 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751444AbbBXW3R convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 17:29:17 -0500
Received: by mail-ig0-f172.google.com with SMTP id l13so30744109iga.5
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 14:29:17 -0800 (PST)
In-Reply-To: <20150224215155.GA15633@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24 February 2015 at 22:51, Andrew Lunn <andrew@lunn.ch> wrote:
> On Tue, Feb 24, 2015 at 06:42:07PM +0100, Rafa?? Mi??ecki wrote:
>> BCM53xx is series of Broadcom Ethernet switches that can be found in
>> various (mostly home) routers.
>> They are quite simple switches with mainly just support for:
>> 1) Tagging incoming packets (PVID)
>> 2) Untagging outgoing packets
>> 3) Forwarding all packets across a single VLAN
>>
>> This driver is split into common code (module) and bus specific code=
=2E
>> Right now only PHY (MDIO) support is included, other could follow af=
ter
>> accepting this driver. It was successfully tested on BCM4706 SoC wit=
h
>> BCM53125.
>>
>> You could notice it's yet another try of submitting b53 driver. This
>> time it was modified to use recently introduced switchdev API which
>> hopefully make it possible to accept it mainline.
>>
>> Signed-off-by: Rafa?? Mi??ecki <zajec5@gmail.com>
>> ---
>> Example usage. My BCM4706 router has switch with 6 ports:
>> 0: WAN port
>> 1-4: LAN ports
>> 8: CPU connected port (on-SoC Ethernet device)
>>
>> I decided to use VLAN 1 for WAN and VLAN 2 for LAN. I was able to
>> successfully configure it using:
>>
>> bridge vlan add vid 1 dev sw0p1 pvid untagged
>> bridge vlan add vid 1 dev sw0p2 pvid untagged
>> bridge vlan add vid 1 dev sw0p3 pvid untagged
>> bridge vlan add vid 1 dev sw0p4 pvid untagged
>> bridge vlan add vid 1 dev sw0p8
>>
>> bridge vlan add vid 2 dev sw0p0 pvid untagged
>> bridge vlan add vid 2 dev sw0p8
>> ---
>>  drivers/net/phy/Kconfig          |   2 +
>>  drivers/net/phy/Makefile         |   1 +
>>  drivers/net/phy/b53/Kconfig      |  12 +
>>  drivers/net/phy/b53/Makefile     |   2 +
>>  drivers/net/phy/b53/b53_common.c | 961 ++++++++++++++++++++++++++++=
+++++++++++
>>  drivers/net/phy/b53/b53_mdio.c   | 418 +++++++++++++++++
>>  drivers/net/phy/b53/b53_priv.h   | 299 ++++++++++++
>>  drivers/net/phy/b53/b53_regs.h   | 313 +++++++++++++
>
> Hi Rafa??
>
> I have a question about the location. Why drivers/net/phy?

It wasn't really my idea, all out-of-tree switch drivers
developed/used in OpenWrt are placed in drivers/net/phy/. My guess is
that it's because many of them register themselves as PHY drivers
(phy_driver_register, or module_phy_driver helper). AFAIK all mainline
PHY drivers all located in this directory. It's the same about
b53_mdio.c - we call phy_driver_register [0] for 3 different phy_id-s.

Now, there may be some exceptions, indeed. For example some devices
with BCM53xx switches use memory mapped registers instead of
MII-accessible registers. This means that after adding support for
such devices we'll get also some platform driver in
drivers/net/phy/b53/ (most likely b53_mmap.c). I'm not sure how much
acceptable it is. It seems we already have some non-PHY drivers in
drivers/net/phy/ like spi_ks8995.c. So maybe it's also acceptable to
have there some platform drivers?

That said, I'm not aware of any better place for switchdev drivers.
Unless we create some new directory like drivers/net/switch/ or
similar. But won't that somehow duplicate drivers/net/phy/ then?

[0] Actually it seems we should simply use module_phy_driver in
b53_mdio.c, I'll do this in V2!

--=20
Rafa=C5=82
