From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/2] of_mdio: add new DT property 'link' for fixed-link
Date: Thu, 09 Jul 2015 14:15:08 -0700
Message-ID: <559EE45C.4040408@gmail.com>
References: <559EB0A4.5080101@list.ru> <559EB1A6.1090008@list.ru> <559EBC59.6020003@gmail.com> <559EDD0C.7020907@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
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
To: Stas Sergeev <stsp@list.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <559EDD0C.7020907@list.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/07/15 13:43, Stas Sergeev wrote:
> 09.07.2015 21:24, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>> (there is no such thing as linux-net@vger.kernel.org, please remove =
it
>> from your future submissions).
>>
>> On 09/07/15 10:38, Stas Sergeev wrote:
>>> Currently for fixed-link the link state is always set to UP.
>> Not quite true, this is always a driver decision to make.
> But what about this part of of_mdio.c:of_phy_register_fixed_link():
> ---
>=20
>      fixed_link_node =3D of_get_child_by_name(np, "fixed-link");
>      if (fixed_link_node) {
>         status.link =3D 1
>=20
> ---

This seems like a logical consequence of finding a "fixed-link" propert=
y
for the DT node of interest. If no such property exist, then we do not
set anything.

>=20
>>> This patch introduces the new property 'link' that accepts the
>>> following string arguments: "up", "down" and "auto".
>>> "down" may be needed if the link is physically unconnected.
>> In which case you probably do not even care about inserting such a
>> property in the first place, do you? What would be the value of forc=
ibly
>> having a link permanently down (not counting loopback)?
> The DTs have a common parts that are included by other
> parts. So if you include the definition of your SoC that have
> all ethernets defined, and you only set up the external things
> like PHYs, then I would see a potential use for "down".

"down" is equivalent to using a status =3D "disabled", in fact the latt=
er
is much better since you can even conserve energy and resources by not
enabling something which is not usable.

> Other than that, it is probably not a big deal.
> Please note that I haven't even hard-coded it anywhere:
> whatever is not "up" or "auto", is down.
> I can remove it from the description if you think that way,
> but I'd rather leave it for consistency and for a small but
> possible use. Eg my board has 4 ethernets and only 2 are
> connected. I feel its right to include the SoC definition and
> set the unconnected ones to "down", but other approaches
> are possible too.
> Should I remove it?

What you describe about your board is the perfect example of how a
"status" property should be used.

>=20
>>> "auto" is needed to enable the link paramaters auto-negotiation,
>>> that is built into some MII protocols, namely SGMII.
>> RGMII also has an in-band status FWIW.
> Thanks, will take that into account in v2.
>=20
>>> The appropriate documentation is added and explicitly states that
>>> "auto" is very specific (protocol, HW and driver-specific), and
>>> is therefore should be used with care.
>> And therefore probably be made a device (and driver) specific decisi=
on
>> whether this is the right thing to do.
> This doesn't work.
> It appears even if the driver supports it and wants to use it, the
> PHY HW may simply not generate the inband status. This is actually
> the whole point why we have a regression now. It is _currently_
> a driver decision, and that doesn't work for some people.
> The point of this patch set is to make it a DT decision instead.

Then, if the in-band status indication is not reliable (which really
should be completely understood), you can just ignore the in-band statu=
s
and use all the parameter in a 'fixed-link' property, should not we?

If in-band status can be used, then you can decide this with a separate
property which is not in 'fixed-link', would that seem reasonable?

>=20
>>> -            return -EINVAL;
>>> +        if (of_property_read_u32(fixed_link_node, "speed",
>>> +                     &status.speed) !=3D 0) {
>>> +            /* in auto mode just set to some sane value:
>>> +             * it will be changed by MAC later */
>>> +            if (link_auto)
>>> +                status.speed =3D 1000;
>> This is a completely arbitrary speed, that does not more or less sen=
se
>> than defaulting to 100 or anything else,
> Exactly.
> But if I leave it to 0, then fixed-phy driver will return an error,
> so I took an arbitrary value.
> But if it obscures the code, I'll hack fixed-phy to accept 0 instead,
> to get something cleaner. So in v2.
>=20
>>   a driver should be able to set
>> the speed it wants, based on the parsing of a 'phy-mode' property fo=
r
>> instance.
> It actually does, that value is just to "cheat" fixed-phy.
> I'll make things more obvious next time.


--=20
=46lorian
