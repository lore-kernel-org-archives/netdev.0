From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH] don't allow CAP_NET_ADMIN to load non-netdev kernel modules
Date: Fri, 25 Feb 2011 21:59:50 +0100
Message-ID: <AANLkTikmtKksP6o1hecf0=ZnRv0j4+_Q326UEG8ss16k@mail.gmail.com>
References: <1298660879.2554.23.camel@bwh-desktop>
	<20110225.111606.115927805.davem@davemloft.net>
	<1298662216.2554.33.camel@bwh-desktop>
	<20110225.114351.28809001.davem@davemloft.net>
	<1298663585.2554.39.camel@bwh-desktop>
	<1298666310.2554.47.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, segoon@openwall.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, eric.dumazet@gmail.com,
	therbert@google.com, xiaosuo@gmail.com, jesse@nicira.com,
	kees.cook@canonical.com, eugene@redhat.com,
	dan.j.rosenberg@gmail.com, akpm@linux-foundation.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298666310.2554.47.camel@bwh-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2011/2/25 Ben Hutchings <bhutchings@solarflare.com>:
> I bet something like this (plus Vasiliy's changes to static module
> aliases) would cover 99.9% of legitimate uses of this feature:
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 54aaca6..0d09baa 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1120,8 +1120,20 @@ void dev_load(struct net *net, const char *nam=
e)
> =A0 =A0 =A0 =A0dev =3D dev_get_by_name_rcu(net, name);
> =A0 =A0 =A0 =A0rcu_read_unlock();
>
> - =A0 =A0 =A0 if (!dev && capable(CAP_NET_ADMIN))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 request_module("%s", name);
> + =A0 =A0 =A0 if (!dev && capable(CAP_NET_ADMIN)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Check whether the name looks like on=
e that a net
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* driver will generate initially. =A0=
If not, require a
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* module alias with a suitable prefi=
x, so that this
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* can't be used to load arbitrary mo=
dules.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((strncmp(name, "eth", 3) =3D=3D 0 &=
&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0isdigit((unsigned char)name[=
3])) ||
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (strncmp(name, "wlan", 4) =3D=3D=
 0 &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0isdigit((unsigned char)name[=
4])))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 request_module("%s", na=
me);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 request_module("netdev-=
%s", name);
> + =A0 =A0 =A0 }
> =A0}
> =A0EXPORT_SYMBOL(dev_load);
>

This might be better as:

if (request_module("netdev-%s", name))
    ... fallback

Then after some years the fallback could be removed if announced proper=
ly.

Best Regards,
Micha=B3 Miros=B3aw
