From: Stefan Agner <stefan@agner.ch>
Subject: Re: Micrel PHY and power down mode
Date: Wed, 10 Feb 2016 14:20:23 -0800
Message-ID: <aa94591013f9e656878d318526a5442e@agner.ch>
References: <ea1cb242a247bc6665947ab9a77cb454@agner.ch>
 <56BBB558.3010205@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: david.choi@micrel.com, netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kmu-office.ch ([178.209.48.109]:36714 "EHLO
	mail.kmu-office.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752AbcBJWWx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 17:22:53 -0500
In-Reply-To: <56BBB558.3010205@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016-02-10 14:10, Florian Fainelli wrote:
> Hi Stefan,
>=20
> On 10/02/16 11:25, Stefan Agner wrote:
>> Hi David, Hi Florian,
>>
>> We use a Micrel KSZ8041NL and we observe sometimes continuous RX err=
ors
>> (PHY's RXER counter is continuously incrementing, activity LED blink=
s
>> and no communication is possible). It seems that only some PHY's are
>> affected (3-4%) and only in certain temperature ranges (the PHY I ca=
n
>> reproduce the issue here shows the problem ~30=C2=B0C). We could nar=
row the
>> issue down, and realized that the problem only appears after the PHY=
 has
>> been in power down mode. Since Linux calls suspend/resume when
>> attaching/detaching the PHY, a simple ifup/ifdown bascially can trig=
ger
>> the issue.
>>
>> Currently, the wakeup sequence writes the following registers
>> 0x8000 to 0x00 (phy_attach_direct -> phy_init_hw -> genphy_soft_rese=
t)
>> 0x3000 to 0x00 (phy_attach_direct -> genphy_resume)
>>
>> I am not sure if this sequence is really ok. It seems to me that
>> genphy_soft_reset clears the power down bit already, which makes
>> genphy_resume somewhat useless. However, altering the behavior of
>> genphy_soft_reset to not clear the power down bit (yet) did not reso=
lve
>> the issue.
>=20
> AFAIR, issuing a BMCR reset, with a PHY which was in power down shoul=
d
> clear the power down bit, but I would not be surprised if some PHYs w=
ere
> not quite behaving like that though.

Yes, that seems to be the case. However, since it is clearing the power
down bit, calling resume after reset seems somewhat superfluous. But
maybe there are PHY's out there which require that?

>=20
>>
>> Is clearing the power down bit and generating the reset in one go
>> intended? I checked the datasheet, and did not found particular
>> information about the "resume" sequence...
>=20
> Does it help if your PHY resume callback does the same thing as what =
the
> config_init() does? You have the ability to skip the generic software
> reset of the PHY via BMCR bit 15, and instead do nothing by implement=
ing
> your own soft_reset() callback, that might tell you whether the softw=
are
> reset is what is screwing things up?

By using U-Boot's mii read/write commands I could isolate the problem
and try some possible combinations manually. So far I was not able to
find a sequence of commands which allowed to take the PHY reliably out
of power down....=20

>=20
> Getting some insight from somebody at Micrel would definitively help
> with understanding what a workaround or fix would look like.

Ok, thanks, will get in touch with Micrel.
