From: Stas Sergeev <stsp@list.ru>
Subject: Re: [PATCH 1/3] fixed_phy: handle link-down case
Date: Sat, 18 Jul 2015 02:24:53 +0300
Message-ID: <55A98EC5.4040805@list.ru>
References: <55A7C45F.1070501@list.ru> <55A7C49E.2020803@list.ru>
 <55A83D86.2030505@gmail.com> <55A8E64A.3040009@list.ru>
 <55A94E5A.9010104@gmail.com> <55A95F83.8010900@list.ru>
 <55A97B51.3030508@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Sebastien Rannou <mxs@sbrk.org>,
	Arnaud Ebalard <arno@natisbad.org>,
	Stas Sergeev <stsp@users.sourceforge.net>
To: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55A97B51.3030508@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

18.07.2015 01:01, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On 17/07/15 13:03, Stas Sergeev wrote:
>> 17.07.2015 21:50, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>> On 17/07/15 04:26, Stas Sergeev wrote:
>>>> 17.07.2015 02:25, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>>>> On 16/07/15 07:50, Stas Sergeev wrote:
>>>>>> Currently fixed_phy driver recognizes only the link-up state.
>>>>>> This simple patch adds an implementation of link-down state.
>>>>>> It fixes the status registers when link is down, and also allows
>>>>>> to register the fixed-phy with link down without specifying the =
speed.
>>>>> This patch still breaks my setups here, e.g: drivers/net/dsa/bcm_=
sf2.c,
>>>>> but I will look into it.
>>>>>
>>>>> Do we really need this for now for your two other patches to work
>>>>> properly, or is it just nicer to have?
>>>> Yes, absolutely.
>>>> Otherwise registering fixed phy will return -EINVAL
>>>> because of the missing link speed (even though the link
>>>> is down).
>>> Ok, I see the problem that you have now. Arguably you could say tha=
t
>>> according to the fixed-link binding, speed needs to be specified an=
d the
>>> code correctly errors out with such an error if you do not specify =
it. I
>> Aren't you missing the fact that .link=3D0?
>> I think what you say is true only for the link-up case, no?
>> .speed=3D=3D0 is valid for link-down IMHO: no link - zero speed.
> Pardon me being very dense and stupid here, but your problem is that =
the
> "speed" parameter is not specified in your DT,
Not even a fixed-link at all, since the latest patches.
I removed fixed-link defs from my DT.

>   and we end-up returning
> -EINVAL from of_phy_register_fixed_link(), is that what is happening?
Yes.

> And even if we silenced that error,
I don't agree with calling it an error silencing.
To me it is a fix. It will also return a more correct status when
link is down.

>   we would end-up calling
> fixed_phy_add() which would also return -EINVAL because then, we woul=
d
> have status.link =3D 1, but no speed.
Why link=3D1 and no speed? This is not valid, should never
be used. The error checking is still there to prevent it.

>   So I better understand what is it
> that you are after here, and that is also a broken Device Tree, is no=
t
> it?
I don't understand. If you didn't specify the in-band status, you
_must_ set the speed. There is no broken DT in either case.

>   So this was the reason why in earlier versions of the patchset you
> ended-up with a given speed which would make us pass this condition, =
right?
As explained earlier, yes.


>>> So is different is that I use a link_update callback, and so we rel=
y on
>>> at least one call of this function to initialize the hardware in
>>> drivers/net/dsa/bcm_sf2.c
>> Do you mean this?:
>> core_writel(priv, reg, CORE_STS_OVERRIDE_GMIIP_PORT(port));
>> Maybe just moving the HW initialization bits to some init func
>> will be a quick fix?
> Well, the problem with that is that to know how we should be configur=
ing
> the hardware in the adjust_link function, we need to run the link_upd=
ate
> function first. By default, there is no auto-negotiation on these fix=
ed
> links at all, so we cannot rely on any value being programmed other t=
han
> those specified in DT.
Ah, so is my understanding correct that in fixed_link_update()
you set .link=3D0 and as a result get wrong speed in adjust_link(),
which gets then written to init HW?
AFAIK when link is down, you are not allowed to rely on the PHY
status registers to read speed from, or am I wrong? So if my
understanding is correct, this was working by a pure luck.
As for the quick fix - why not to do this pre-init in fixed_link_update=
()
instead of adjust_link()? In fixed_link_update() you'll get the speed
right from DT, so it will be correct.

> The changes are not trivial, it took a while to get that logic done
=46or a longer term fix,
how about adding a *status arg to of_phy_register_fixed_link() to
always get the status back to the driver, unless NULL is provided?
Using an update callback for that doesn't look like the best thing
to do. And besides, if we move to my fixed_phy_update_state(),
this will be needed anyway.
