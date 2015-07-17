From: Stas Sergeev <stsp@list.ru>
Subject: Re: [PATCH 1/3] fixed_phy: handle link-down case
Date: Fri, 17 Jul 2015 23:03:15 +0300
Message-ID: <55A95F83.8010900@list.ru>
References: <55A7C45F.1070501@list.ru> <55A7C49E.2020803@list.ru>
 <55A83D86.2030505@gmail.com> <55A8E64A.3040009@list.ru>
 <55A94E5A.9010104@gmail.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp52.i.mail.ru ([94.100.177.112]:36906 "EHLO smtp52.i.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752189AbbGQUDV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jul 2015 16:03:21 -0400
In-Reply-To: <55A94E5A.9010104@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

17.07.2015 21:50, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On 17/07/15 04:26, Stas Sergeev wrote:
>> 17.07.2015 02:25, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>> On 16/07/15 07:50, Stas Sergeev wrote:
>>>> Currently fixed_phy driver recognizes only the link-up state.
>>>> This simple patch adds an implementation of link-down state.
>>>> It fixes the status registers when link is down, and also allows
>>>> to register the fixed-phy with link down without specifying the sp=
eed.
>>> This patch still breaks my setups here, e.g: drivers/net/dsa/bcm_sf=
2.c,
>>> but I will look into it.
>>>
>>> Do we really need this for now for your two other patches to work
>>> properly, or is it just nicer to have?
>> Yes, absolutely.
>> Otherwise registering fixed phy will return -EINVAL
>> because of the missing link speed (even though the link
>> is down).
> Ok, I see the problem that you have now. Arguably you could say that
> according to the fixed-link binding, speed needs to be specified and =
the
> code correctly errors out with such an error if you do not specify it=
=2E I
Aren't you missing the fact that .link=3D0?
I think what you say is true only for the link-up case, no?
=2Espeed=3D=3D0 is valid for link-down IMHO: no link - zero speed.

> So is different is that I use a link_update callback, and so we rely =
on
> at least one call of this function to initialize the hardware in
> drivers/net/dsa/bcm_sf2.c
Do you mean this?:
core_writel(priv, reg, CORE_STS_OVERRIDE_GMIIP_PORT(port));
Maybe just moving the HW initialization bits to some init func
will be a quick fix?

>   for this to work, after that, the hardware
> reflects the fixed link parameters we configured, and we feed the
> fixed_phy_status information from the hardware directly.
>
> >From there I see two different ways to fix this:
>
> - we ignore the fixed_phy_update_regs return value in fixed_phy_add()=
,
> but that will make us avoid doing verification on the speed, which is
> not so great, but is essentially what your patch does anyway
No, it does not. All it does is to allow no speed _when link is down_,
which is IMHO a very logical fix. The speed checks for the link-up
case are all still there.

> - we update the use of the fixed PHY link_update in drivers using it
IMHO just 2 drivers: bcmii.c and bcm_sf2.c, and the change
is likely trivial, although of course I am not sure in details.

>   and
> convert them to use fixed_phy_update_state instead, which can take so=
me
> time and effort to convert
Maybe just move the initialization bits out of the link_update
callback, but still use the callback for now? Should be simple, no?
