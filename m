From: Stas Sergeev <stsp@list.ru>
Subject: Re: [PATCH 1/2] of_mdio: add new DT property 'link' for fixed-link
Date: Thu, 9 Jul 2015 23:43:56 +0300
Message-ID: <559EDD0C.7020907@list.ru>
References: <559EB0A4.5080101@list.ru> <559EB1A6.1090008@list.ru>
 <559EBC59.6020003@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Sebastien Rannou <mxs@sbrk.org>,
	Arnaud Ebalard <arno@natisbad.org>,
	Stas Sergeev <stsp@users.sourceforge.net>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Grant Likely <grant.likely@linaro.org>,
	devicetree@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp34.i.mail.ru ([94.100.177.94]:49658 "EHLO smtp34.i.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754569AbbGIUoO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jul 2015 16:44:14 -0400
In-Reply-To: <559EBC59.6020003@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

09.07.2015 21:24, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> (there is no such thing as linux-net@vger.kernel.org, please remove i=
t
> from your future submissions).
>
> On 09/07/15 10:38, Stas Sergeev wrote:
>> Currently for fixed-link the link state is always set to UP.
> Not quite true, this is always a driver decision to make.
But what about this part of of_mdio.c:of_phy_register_fixed_link():
---

  	fixed_link_node =3D of_get_child_by_name(np, "fixed-link");
  	if (fixed_link_node) {
		status.link =3D 1

---

>> This patch introduces the new property 'link' that accepts the
>> following string arguments: "up", "down" and "auto".
>> "down" may be needed if the link is physically unconnected.
> In which case you probably do not even care about inserting such a
> property in the first place, do you? What would be the value of forci=
bly
> having a link permanently down (not counting loopback)?
The DTs have a common parts that are included by other
parts. So if you include the definition of your SoC that have
all ethernets defined, and you only set up the external things
like PHYs, then I would see a potential use for "down".
Other than that, it is probably not a big deal.
Please note that I haven't even hard-coded it anywhere:
whatever is not "up" or "auto", is down.
I can remove it from the description if you think that way,
but I'd rather leave it for consistency and for a small but
possible use. Eg my board has 4 ethernets and only 2 are
connected. I feel its right to include the SoC definition and
set the unconnected ones to "down", but other approaches
are possible too.
Should I remove it?

>> "auto" is needed to enable the link paramaters auto-negotiation,
>> that is built into some MII protocols, namely SGMII.
> RGMII also has an in-band status FWIW.
Thanks, will take that into account in v2.

>> The appropriate documentation is added and explicitly states that
>> "auto" is very specific (protocol, HW and driver-specific), and
>> is therefore should be used with care.
> And therefore probably be made a device (and driver) specific decisio=
n
> whether this is the right thing to do.
This doesn't work.
It appears even if the driver supports it and wants to use it, the
PHY HW may simply not generate the inband status. This is actually
the whole point why we have a regression now. It is _currently_
a driver decision, and that doesn't work for some people.
The point of this patch set is to make it a DT decision instead.

>> -			return -EINVAL;
>> +		if (of_property_read_u32(fixed_link_node, "speed",
>> +					 &status.speed) !=3D 0) {
>> +			/* in auto mode just set to some sane value:
>> +			 * it will be changed by MAC later */
>> +			if (link_auto)
>> +				status.speed =3D 1000;
> This is a completely arbitrary speed, that does not more or less sens=
e
> than defaulting to 100 or anything else,
Exactly.
But if I leave it to 0, then fixed-phy driver will return an error,
so I took an arbitrary value.
But if it obscures the code, I'll hack fixed-phy to accept 0 instead,
to get something cleaner. So in v2.

>   a driver should be able to set
> the speed it wants, based on the parsing of a 'phy-mode' property for
> instance.
It actually does, that value is just to "cheat" fixed-phy.
I'll make things more obvious next time.
