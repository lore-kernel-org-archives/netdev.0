From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/3] fixed_phy: handle link-down case
Date: Fri, 17 Jul 2015 19:29:03 -0700
Message-ID: <55A9B9EF.2030308@gmail.com>
References: <55A7C45F.1070501@list.ru> <55A7C49E.2020803@list.ru> <55A83D86.2030505@gmail.com> <55A8E64A.3040009@list.ru> <55A94E5A.9010104@gmail.com> <55A95F83.8010900@list.ru> <55A97B51.3030508@gmail.com> <55A98EC5.4040805@list.ru> <55A99138.2030905@gmail.com> <55A9956E.4070205@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Sebastien Rannou <mxs@sbrk.org>,
	Arnaud Ebalard <arno@natisbad.org>,
	Stas Sergeev <stsp@users.sourceforge.net>
To: Stas Sergeev <stsp@list.ru>, netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55A9956E.4070205@list.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 07/17/15 16:53, Stas Sergeev a =C3=A9crit :
> 18.07.2015 02:35, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>> On 17/07/15 16:24, Stas Sergeev wrote:
>>> 18.07.2015 01:01, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>>> On 17/07/15 13:03, Stas Sergeev wrote:
>>>>> 17.07.2015 21:50, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82=
:
>>>>>> On 17/07/15 04:26, Stas Sergeev wrote:
>>>>>>> 17.07.2015 02:25, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82=
:
>>>>>>>> On 16/07/15 07:50, Stas Sergeev wrote:
>>>>>>>>> Currently fixed_phy driver recognizes only the link-up state.
>>>>>>>>> This simple patch adds an implementation of link-down state.
>>>>>>>>> It fixes the status registers when link is down, and also all=
ows
>>>>>>>>> to register the fixed-phy with link down without specifying t=
he
>>>>>>>>> speed.
>>>>>>>> This patch still breaks my setups here, e.g:
>>>>>>>> drivers/net/dsa/bcm_sf2.c,
>>>>>>>> but I will look into it.
>>>>>>>>
>>>>>>>> Do we really need this for now for your two other patches to w=
ork
>>>>>>>> properly, or is it just nicer to have?
>>>>>>> Yes, absolutely.
>>>>>>> Otherwise registering fixed phy will return -EINVAL
>>>>>>> because of the missing link speed (even though the link
>>>>>>> is down).
>>>>>> Ok, I see the problem that you have now. Arguably you could say =
that
>>>>>> according to the fixed-link binding, speed needs to be specified=
 and
>>>>>> the
>>>>>> code correctly errors out with such an error if you do not speci=
fy
>>>>>> it. I
>>>>> Aren't you missing the fact that .link=3D0?
>>>>> I think what you say is true only for the link-up case, no?
>>>>> .speed=3D=3D0 is valid for link-down IMHO: no link - zero speed.
>>>> Pardon me being very dense and stupid here, but your problem is th=
at
>>>> the
>>>> "speed" parameter is not specified in your DT,
>>> Not even a fixed-link at all, since the latest patches.
>>> I removed fixed-link defs from my DT.
>> Hummm, okay, so you just have the inband-status property and that's =
it,
>> not even a fixed-link node anymore, right? How does
>> mvneta_fixed_link_update() work then since it needs a fixed PHY to b=
e
>> registered?
> You can see it from my patch:
> ---
>=20
> +    err =3D of_property_read_string(np, "managed", &managed);
> +    if (err =3D=3D 0) {
> +        if (strcmp(managed, "in-band-status") =3D=3D 0) {
> +            /* status is zeroed, namely its .link member */
> +            phy =3D fixed_phy_register(PHY_POLL, &status, np);
> +            return IS_ERR(phy) ? PTR_ERR(phy) : 0;
> +        }
> +    }
>=20
> ---
> which is the hunk added to the of_phy_register_fixed_link().
> So in that case we register fixed-phy, but do not parse the fixed-lin=
k.

Ok, I missed that part. Could not you just override everything that is
needed here to get past the point where you register your fixed PHY eve=
n
with link =3D 0, this will be discarded anyway once you start in-band
negotiation.

>=20
>>> AFAIK when link is down, you are not allowed to rely on the PHY
>>> status registers to read speed from, or am I wrong? So if my
>>> understanding is correct, this was working by a pure luck.
>> Well, it's more like it is undefined, and before this patch, the fix=
ed
>> PHY would update everything except the link status indication.
> And what about the real MDIO PHY? Or does it never hit this
> "undefined" code path?
> Anyway, if you call it undefined, I guess you automatically agree
> this needs to be fixed. :)

I should have been clearer; it is undefined for real PHYs it was not fo=
r
fixed PHYs, you can rely on the configuration that was done during
registration. Maybe not the best assumption; but it worked, and with
this patch it no longer works, so we want to find something here.

>=20
>>> As for the quick fix - why not to do this pre-init in
>>> fixed_link_update()
>>> instead of adjust_link()? In fixed_link_update() you'll get the spe=
ed
>>> right from DT, so it will be correct.
>> fixed_link_update() only gets called once you start your PHY state
>> machine, unfortunately, not upon fixed PHY device registration, and =
it
>> runs before your adjust_link callback does,
> So you say fixed_link_update() runs before adjust_link callback does,
> which looks logical. Why would you need it to run on device registrat=
ion,
> if it runs earlier than adjust_link (which you use for init) even now=
?

There could be multiple reasons:

- device might be clock gated, until you "open" it you cannot
necessarily start making register accesses

- interfaces can be brought up/down separately so you want to stop the
PHY state machine accordingly

I will work on something anyway.
--=20
=46lorian
