From: David Daney <david.daney@cavium.com>
Subject: Re: [PATCH v3 1/3] phylib: Convert MDIO and PHY Lib drivers to support
 10G
Date: Fri, 14 Oct 2011 14:52:16 -0700
Message-ID: <4E98AF10.9040208@cavium.com>
References: <1318516660-25452-1-git-send-email-afleming@freescale.com> <1318516660-25452-2-git-send-email-afleming@freescale.com> <4E970B03.9060200@cavium.com> <86469237-B8CD-4A0E-A744-649AFB5E44C2@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Andy Fleming <afleming@freescale.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:12045 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932246Ab1JNVwR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 17:52:17 -0400
In-Reply-To: <86469237-B8CD-4A0E-A744-649AFB5E44C2@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/14/2011 02:17 PM, Andy Fleming wrote:
>
> On Oct 13, 2011, at 11:00 AM, David Daney wrote:
>
>> On 10/13/2011 07:37 AM, Andy Fleming wrote:
>>> 10G MDIO is a totally different protocol (clause 45 of 802.3).
>>> Supporting this new protocol requires a couple of changes:
>>>
>>> * Add a new parameter to the mdiobus_read functions to specify the
>>>    "device address" inside the PHY.
>>> * Add a phy45_read/write function which takes advantage of that
>>>    new parameter
>>> * Convert all of the existing drivers to use the new format
>>>
>>> I created a new clause-45-specific read/write functions because:
>>> 1) phy_read and phy_write are highly overloaded functions, and
>>>     finding every instance which is actually the PHY Lib version
>>>     was quite difficult
>>> 2) Most code which invokes phy_read/phy_write inside PHY Lib is
>>>     Clause-22-specific. None of the phy_read/phy_write invocations
>>>     were useable on 10G PHYs
>>>
>>
>> I think converting all these phy_read/phy_write to take an extra
>> parameter is a mistake.  99% of the users have no need for the "devi=
ce
>> address".  Also you are still passing the protocol mode as a high
>> order bit in the register address, so that part is still quite ugly.
>
>
> I didn't convert *any* of the phy_read/phy_write functions to have
> an extra parameter. I converted only the mdio bus functions.
>
> And=85I'm not passing the protocol mode as a high order bit. Am I
> missing something?
>

I misspoke, I meant all the mdiobus_{read,write} functions.  But my=20
feeling is the same, a lot of churn may not be good.


> Ah, right. That's what the MDIO bitbang driver was converted to
> do. Are there any clients in the tree that actually use that
> functionality (currently a grep of MII_ADDR_C45 yields only the mdio
> bitbang driver and the macro definition)? I agree that's pretty
> ugly. That's why my second patch converted MDIO bit-bang to use the
> devad argument, instead.
>

Granted, there is nothing in-tree.  Not that it is a good excuse, but I=
=20
am actively working on converting my out-of-tree drivers to be in-tree,=
=20
so I have a natural tendency towards the status quo.

> If we were going to use this method of setting a flag in an existing
> parameter, I'd like it if we could make our method the same as the
> mdio.c code's for improved potential for integration. My objection
> to the use of unused bits in the existing arguments is that if we
> pass a C45 argument to a C22 bus, the behavior is undefined. i.e. -
> we don't know whether the underlying drivers will accidentally write
> bits in registers that have unknown effects, or BUG(), or just pass
> the bad value through.  While I agree that my approach is
> disruptive, I also think that a) It's not that bad (I changed all of
> the affected drivers), and b) It makes the API more explicit and
> self-documenting.
>
> mdio.c's read/write functions go with separate arguments...
>

Well there is that...

Really we need a netdev maintainer to decide the best way forward.  It=20
seems like we need to work towards unifying mdio.c and the PHY driver=20
infrastructure if possible.

I can adapt my patches either way, but it would be good to know soon=20
which way it will be.

David Daney

>>
>> The existing infrastructure where we pass the "device address" in bi=
ts
>> 16..20 of the register number is much less disruptive.
>>
>> If you don't like it, an easy and much less intrusive approach might
>> be a simple (untested) wrapper:
>>
>> static inline int phy45_read(struct phy_device *phydev,
>>                              int devad, u16 regnum)
>> {
>> 	u32 c45_reg =3D MII_ADDR_C45 | ((devad&  0x1f)<<  16) | regnum;
>> 	return phy_read(phydev, c45_reg)
>> }
>>
>> static inline int phy45_write(struct phy_device *phydev,
>>                               int devad, u16 regnum, u16 val)
>> {
>> 	u32 c45_reg =3D MII_ADDR_C45 | ((devad&  0x1f)<<  16) | regnum;
>> 	return phy_write(phydev, c45_reg, val)
>> }
>
>
> I admit this is far easier, but it feels much less clean to me. It
> sounds like Grant's ok with it, so if that's the approach we want,
> I'd be fine with converting David's approach to use the mdio45_probe
> equivalent, so we get the more robust device probing.
>
> Andy
