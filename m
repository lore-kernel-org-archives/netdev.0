From: Stas Sergeev <stsp@list.ru>
Subject: Re: [PATCH 1/3] fixed_phy: handle link-down case
Date: Sat, 18 Jul 2015 02:53:18 +0300
Message-ID: <55A9956E.4070205@list.ru>
References: <55A7C45F.1070501@list.ru> <55A7C49E.2020803@list.ru>
 <55A83D86.2030505@gmail.com> <55A8E64A.3040009@list.ru>
 <55A94E5A.9010104@gmail.com> <55A95F83.8010900@list.ru>
 <55A97B51.3030508@gmail.com> <55A98EC5.4040805@list.ru>
 <55A99138.2030905@gmail.com>
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
In-Reply-To: <55A99138.2030905@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

18.07.2015 02:35, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On 17/07/15 16:24, Stas Sergeev wrote:
>> 18.07.2015 01:01, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>> On 17/07/15 13:03, Stas Sergeev wrote:
>>>> 17.07.2015 21:50, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>>>> On 17/07/15 04:26, Stas Sergeev wrote:
>>>>>> 17.07.2015 02:25, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82=
:
>>>>>>> On 16/07/15 07:50, Stas Sergeev wrote:
>>>>>>>> Currently fixed_phy driver recognizes only the link-up state.
>>>>>>>> This simple patch adds an implementation of link-down state.
>>>>>>>> It fixes the status registers when link is down, and also allo=
ws
>>>>>>>> to register the fixed-phy with link down without specifying th=
e
>>>>>>>> speed.
>>>>>>> This patch still breaks my setups here, e.g:
>>>>>>> drivers/net/dsa/bcm_sf2.c,
>>>>>>> but I will look into it.
>>>>>>>
>>>>>>> Do we really need this for now for your two other patches to wo=
rk
>>>>>>> properly, or is it just nicer to have?
>>>>>> Yes, absolutely.
>>>>>> Otherwise registering fixed phy will return -EINVAL
>>>>>> because of the missing link speed (even though the link
>>>>>> is down).
>>>>> Ok, I see the problem that you have now. Arguably you could say t=
hat
>>>>> according to the fixed-link binding, speed needs to be specified =
and
>>>>> the
>>>>> code correctly errors out with such an error if you do not specif=
y
>>>>> it. I
>>>> Aren't you missing the fact that .link=3D0?
>>>> I think what you say is true only for the link-up case, no?
>>>> .speed=3D=3D0 is valid for link-down IMHO: no link - zero speed.
>>> Pardon me being very dense and stupid here, but your problem is tha=
t the
>>> "speed" parameter is not specified in your DT,
>> Not even a fixed-link at all, since the latest patches.
>> I removed fixed-link defs from my DT.
> Hummm, okay, so you just have the inband-status property and that's i=
t,
> not even a fixed-link node anymore, right? How does
> mvneta_fixed_link_update() work then since it needs a fixed PHY to be
> registered?
You can see it from my patch:
---

+	err =3D of_property_read_string(np, "managed", &managed);
+	if (err =3D=3D 0) {
+		if (strcmp(managed, "in-band-status") =3D=3D 0) {
+			/* status is zeroed, namely its .link member */
+			phy =3D fixed_phy_register(PHY_POLL, &status, np);
+			return IS_ERR(phy) ? PTR_ERR(phy) : 0;
+		}
+	}

---
which is the hunk added to the of_phy_register_fixed_link().
So in that case we register fixed-phy, but do not parse the fixed-link.

>> AFAIK when link is down, you are not allowed to rely on the PHY
>> status registers to read speed from, or am I wrong? So if my
>> understanding is correct, this was working by a pure luck.
> Well, it's more like it is undefined, and before this patch, the fixe=
d
> PHY would update everything except the link status indication.
And what about the real MDIO PHY? Or does it never hit this
"undefined" code path?
Anyway, if you call it undefined, I guess you automatically agree
this needs to be fixed. :)

>> As for the quick fix - why not to do this pre-init in fixed_link_upd=
ate()
>> instead of adjust_link()? In fixed_link_update() you'll get the spee=
d
>> right from DT, so it will be correct.
> fixed_link_update() only gets called once you start your PHY state
> machine, unfortunately, not upon fixed PHY device registration, and i=
t
> runs before your adjust_link callback does,
So you say fixed_link_update() runs before adjust_link callback does,
which looks logical. Why would you need it to run on device registratio=
n,
if it runs earlier than adjust_link (which you use for init) even now?
