From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/3] fixed_phy: handle link-down case
Date: Fri, 17 Jul 2015 11:50:02 -0700
Message-ID: <55A94E5A.9010104@gmail.com>
References: <55A7C45F.1070501@list.ru> <55A7C49E.2020803@list.ru> <55A83D86.2030505@gmail.com> <55A8E64A.3040009@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Sebastien Rannou <mxs@sbrk.org>,
	Arnaud Ebalard <arno@natisbad.org>,
	Stas Sergeev <stsp@users.sourceforge.net>
To: Stas Sergeev <stsp@list.ru>, netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55A8E64A.3040009@list.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17/07/15 04:26, Stas Sergeev wrote:
> 17.07.2015 02:25, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>> On 16/07/15 07:50, Stas Sergeev wrote:
>>>
>>> Currently fixed_phy driver recognizes only the link-up state.
>>> This simple patch adds an implementation of link-down state.
>>> It fixes the status registers when link is down, and also allows
>>> to register the fixed-phy with link down without specifying the spe=
ed.
>>
>> This patch still breaks my setups here, e.g: drivers/net/dsa/bcm_sf2=
=2Ec,
>> but I will look into it.
>>
>> Do we really need this for now for your two other patches to work
>> properly, or is it just nicer to have?
> Yes, absolutely.
> Otherwise registering fixed phy will return -EINVAL
> because of the missing link speed (even though the link
> is down).

Ok, I see the problem that you have now. Arguably you could say that
according to the fixed-link binding, speed needs to be specified and th=
e
code correctly errors out with such an error if you do not specify it. =
I
also agree that having to specify speed and duplex for something you
will end-up auto-negotiating has no useful purpose.

>=20
> Please, see what makes a problem. I can't reproduce what you report.
>=20

So is different is that I use a link_update callback, and so we rely on
at least one call of this function to initialize the hardware in
drivers/net/dsa/bcm_sf2.c for this to work, after that, the hardware
reflects the fixed link parameters we configured, and we feed the
fixed_phy_status information from the hardware directly.

=46rom there I see two different ways to fix this:

- we ignore the fixed_phy_update_regs return value in fixed_phy_add(),
but that will make us avoid doing verification on the speed, which is
not so great, but is essentially what your patch does anyway

- we update the use of the fixed PHY link_update in drivers using it an=
d
convert them to use fixed_phy_update_state instead, which can take some
time and effort to convert

What do you think? I would go with option 1 and eventually introduce a
special switch() case on the speed settings just to validate we know th=
em.

Thanks
--=20
=46lorian
