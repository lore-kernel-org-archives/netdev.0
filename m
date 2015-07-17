From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/3] fixed_phy: handle link-down case
Date: Fri, 17 Jul 2015 15:01:53 -0700
Message-ID: <55A97B51.3030508@gmail.com>
References: <55A7C45F.1070501@list.ru> <55A7C49E.2020803@list.ru> <55A83D86.2030505@gmail.com> <55A8E64A.3040009@list.ru> <55A94E5A.9010104@gmail.com> <55A95F83.8010900@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Sebastien Rannou <mxs@sbrk.org>,
	Arnaud Ebalard <arno@natisbad.org>,
	Stas Sergeev <stsp@users.sourceforge.net>
To: Stas Sergeev <stsp@list.ru>, netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55A95F83.8010900@list.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17/07/15 13:03, Stas Sergeev wrote:
> 17.07.2015 21:50, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>> On 17/07/15 04:26, Stas Sergeev wrote:
>>> 17.07.2015 02:25, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>>> On 16/07/15 07:50, Stas Sergeev wrote:
>>>>> Currently fixed_phy driver recognizes only the link-up state.
>>>>> This simple patch adds an implementation of link-down state.
>>>>> It fixes the status registers when link is down, and also allows
>>>>> to register the fixed-phy with link down without specifying the s=
peed.
>>>> This patch still breaks my setups here, e.g: drivers/net/dsa/bcm_s=
f2.c,
>>>> but I will look into it.
>>>>
>>>> Do we really need this for now for your two other patches to work
>>>> properly, or is it just nicer to have?
>>> Yes, absolutely.
>>> Otherwise registering fixed phy will return -EINVAL
>>> because of the missing link speed (even though the link
>>> is down).
>> Ok, I see the problem that you have now. Arguably you could say that
>> according to the fixed-link binding, speed needs to be specified and=
 the
>> code correctly errors out with such an error if you do not specify i=
t. I
> Aren't you missing the fact that .link=3D0?
> I think what you say is true only for the link-up case, no?
> .speed=3D=3D0 is valid for link-down IMHO: no link - zero speed.

Pardon me being very dense and stupid here, but your problem is that th=
e
"speed" parameter is not specified in your DT, and we end-up returning
-EINVAL from of_phy_register_fixed_link(), is that what is happening?

And even if we silenced that error, we would end-up calling
fixed_phy_add() which would also return -EINVAL because then, we would
have status.link =3D 1, but no speed. So I better understand what is it
that you are after here, and that is also a broken Device Tree, is not
it? So this was the reason why in earlier versions of the patchset you
ended-up with a given speed which would make us pass this condition, ri=
ght?

>=20
>> So is different is that I use a link_update callback, and so we rely=
 on
>> at least one call of this function to initialize the hardware in
>> drivers/net/dsa/bcm_sf2.c
> Do you mean this?:
> core_writel(priv, reg, CORE_STS_OVERRIDE_GMIIP_PORT(port));
> Maybe just moving the HW initialization bits to some init func
> will be a quick fix?

Well, the problem with that is that to know how we should be configurin=
g
the hardware in the adjust_link function, we need to run the link_updat=
e
function first. By default, there is no auto-negotiation on these fixed
links at all, so we cannot rely on any value being programmed other tha=
n
those specified in DT.

>=20
>>   for this to work, after that, the hardware
>> reflects the fixed link parameters we configured, and we feed the
>> fixed_phy_status information from the hardware directly.
>>
>> >From there I see two different ways to fix this:
>>
>> - we ignore the fixed_phy_update_regs return value in fixed_phy_add(=
),
>> but that will make us avoid doing verification on the speed, which i=
s
>> not so great, but is essentially what your patch does anyway
> No, it does not. All it does is to allow no speed _when link is down_=
,
> which is IMHO a very logical fix. The speed checks for the link-up
> case are all still there.
>=20
>> - we update the use of the fixed PHY link_update in drivers using it
> IMHO just 2 drivers: bcmii.c and bcm_sf2.c, and the change
> is likely trivial, although of course I am not sure in details.

The changes are not trivial, it took a while to get that logic done
correctly, and this would increase the number of patches to backport to
-stable, which is not ideal.

>=20
>>   and
>> convert them to use fixed_phy_update_state instead, which can take s=
ome
>> time and effort to convert
> Maybe just move the initialization bits out of the link_update
> callback, but still use the callback for now? Should be simple, no?

Let me see if I have a smart idea other the weekend on how to do this.
--=20
=46lorian
