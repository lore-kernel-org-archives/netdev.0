From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: [PATCH] don't allow CAP_NET_ADMIN to load non-netdev kernel modules
Date: Mon, 28 Feb 2011 12:29:11 +0300
Message-ID: <4D6B6AE7.2050202@msgid.tls.msk.ru>
References: <1298660879.2554.23.camel@bwh-desktop> <1298666310.2554.47.camel@bwh-desktop> <AANLkTikmtKksP6o1hecf0=ZnRv0j4+_Q326UEG8ss16k@mail.gmail.com> <201102272122.52643.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, segoon@openwall.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, eric.dumazet@gmail.com,
	therbert@google.com, xiaosuo@gmail.com, jesse@nicira.com,
	kees.cook@canonical.com, eugene@redhat.com,
	dan.j.rosenberg@gmail.com, akpm@linux-foundation.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201102272122.52643.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

27.02.2011 23:22, Arnd Bergmann wrote:
> On Friday 25 February 2011, Micha=B3 Miros=B3aw wrote:
>>> diff --git a/net/core/dev.c b/net/core/dev.c
>>> index 54aaca6..0d09baa 100644
>>> --- a/net/core/dev.c
>>> +++ b/net/core/dev.c
>>> @@ -1120,8 +1120,20 @@ void dev_load(struct net *net, const char *n=
ame)
>>>        dev =3D dev_get_by_name_rcu(net, name);
>>>        rcu_read_unlock();
>>>
>>> -       if (!dev && capable(CAP_NET_ADMIN))
>>> -               request_module("%s", name);
>>> +       if (!dev && capable(CAP_NET_ADMIN)) {
>>> +               /* Check whether the name looks like one that a net
>>> +                * driver will generate initially.  If not, require=
 a
>>> +                * module alias with a suitable prefix, so that thi=
s
>>> +                * can't be used to load arbitrary modules.
>>> +                */
>>> +               if ((strncmp(name, "eth", 3) =3D=3D 0 &&
>>> +                    isdigit((unsigned char)name[3])) ||
>>> +                   (strncmp(name, "wlan", 4) =3D=3D 0 &&
>>> +                    isdigit((unsigned char)name[4])))
>>> +                       request_module("%s", name);
>>> +               else
>>> +                       request_module("netdev-%s", name);
>>> +       }
>>>  }
>>>  EXPORT_SYMBOL(dev_load);
>>>
>>
>> This might be better as:
>>
>> if (request_module("netdev-%s", name))
>>     ... fallback
>>
>> Then after some years the fallback could be removed if announced pro=
perly.
>=20
> The backwards compatibility should mostly be for systems that today d=
on't
> use split capabilities, right?
>=20
> The fallback could therefore rely on CAP_SYS_MODULE as well:
>=20
> 	if (request_module("netdev-%s", name)) {
> 		if (capable(CAP_SYS_MODULE))
> 			request_module("%s", name);
> 	}
>=20
> Not 100% solution, but should solve the capability escalation nicely =
without
> causing much pain.

To me this looks like the best solution so far - trivial and
compatible.

Thanks!

/mjt
