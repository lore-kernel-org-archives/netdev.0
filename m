From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: remove all rt cache entries on UNREGISTER event
Date: Tue, 28 Sep 2010 18:33:49 +0200
Message-ID: <1285691629.3154.80.camel@edumazet-laptop>
References: <4CA208C9.1020800@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Octavian Purdila <opurdila@ixiacom.com>
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:34735 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755012Ab0I1QeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 12:34:07 -0400
Received: by fxm14 with SMTP id 14so115772fxm.19
        for <netdev@vger.kernel.org>; Tue, 28 Sep 2010 09:33:53 -0700 (PDT)
In-Reply-To: <4CA208C9.1020800@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 28 septembre 2010 =C3=A0 17:24 +0200, Nicolas Dichtel a =C3=A9=
crit :
> Hi,
>=20
> I face a problem when I try to remove an interface,=20
> netdev_wait_allrefs() complains about refcount.
>=20
> Here is a trivial scenario to reproduce the problem:
> # ip tunnel add mode ipip remote 10.16.0.164 local 10.16.0.72 dev eth=
0
> # ./a.out tunl1
> # ip tunnel del tunl1
>=20
> Note: a.out binary create an IPv4 raw socket, attach it to tunl1=20
> (SO_BINDTODEVICE), set it as multicast (IP_MULTICAST_LOOP), set the=20
> multicast interface to tunl1 (IP_MULTICAST_IF), build the IP header=20
> (IP_HDRINCL) and then send a single packet (192.168.6.1 -> 224.0.0.18=
).
>=20
> Note2: when a.out is executed, tunl1 has no ip address and is down.
>=20

CC Octavian Purdila, the patch author.

I am just wondering why this route is created in the first place.

Maybe a fix would be to forbid this ?

Some machines have a giant route cache, so its very important to avoid
expensive scans.

> Then, I got a serie of "kernel:[1206699.728010] unregister_netdevice:=
=20
> waiting for tunl1 to become free. Usage count =3D 3" and after some t=
ime,=20
> interface is removed.
>=20
> The problem is that route cache entries are only invalidate on=20
> UNREGISTER event, and not removed (introduced by commit=20
> e2ce146848c81af2f6d42e67990191c284bf0c33). We must wait that=20
> rt_check_expire() remove the remaining route cache entries.
>=20
> To fix the problem, I propose to remove a part of the previous commit=
=2E
>=20
> Regards,
> Nicolas
> pi=C3=A8ce jointe diff=C3=A9rences entre fichiers
> (0001-ipv4-remove-all-rt-cache-entries-on-UNREGISTER-even.patch)
> From 3344e2e0431fe803c4dac8757a8746908357d780 Mon Sep 17 00:00:00 200=
1
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Tue, 28 Sep 2010 16:38:19 +0200
> Subject: [PATCH] ipv4: remove all rt cache entries on UNREGISTER even=
t
>=20
> Commit e2ce146848c81af2f6d42e67990191c284bf0c33 (ipv4: factorize cach=
e clearing
> for batched unregister operations) add a new parameter to fib_disable=
_ip() to
> only invalidate route cache entries on unregister event.
> This is wrong, we should ensure that all cache entries are removed on
> unregister event, else netdev_wait_allrefs() may complain. A cache en=
try
> can be created between event DOWN and UNREGISTER.
>=20
> So, I revert a part of the patch.
>=20
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  net/ipv4/fib_frontend.c |   10 +++++-----
>  1 files changed, 5 insertions(+), 5 deletions(-)
>=20
> diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
> index 7d02a9f..377e815 100644
> --- a/net/ipv4/fib_frontend.c
> +++ b/net/ipv4/fib_frontend.c
> @@ -917,11 +917,11 @@ static void nl_fib_lookup_exit(struct net *net)
>  	net->ipv4.fibnl =3D NULL;
>  }
> =20
> -static void fib_disable_ip(struct net_device *dev, int force, int de=
lay)
> +static void fib_disable_ip(struct net_device *dev, int force)
>  {
>  	if (fib_sync_down_dev(dev, force))
>  		fib_flush(dev_net(dev));
> -	rt_cache_flush(dev_net(dev), delay);
> +	rt_cache_flush(dev_net(dev), 0);
>  	arp_ifdown(dev);
>  }
> =20
> @@ -944,7 +944,7 @@ static int fib_inetaddr_event(struct notifier_blo=
ck *this, unsigned long event,
>  			/* Last address was deleted from this interface.
>  			   Disable IP.
>  			 */
> -			fib_disable_ip(dev, 1, 0);
> +			fib_disable_ip(dev, 1);
>  		} else {
>  			rt_cache_flush(dev_net(dev), -1);
>  		}
> @@ -959,7 +959,7 @@ static int fib_netdev_event(struct notifier_block=
 *this, unsigned long event, vo
>  	struct in_device *in_dev =3D __in_dev_get_rtnl(dev);
> =20
>  	if (event =3D=3D NETDEV_UNREGISTER) {
> -		fib_disable_ip(dev, 2, -1);
> +		fib_disable_ip(dev, 2);
>  		return NOTIFY_DONE;
>  	}
> =20
> @@ -977,7 +977,7 @@ static int fib_netdev_event(struct notifier_block=
 *this, unsigned long event, vo
>  		rt_cache_flush(dev_net(dev), -1);
>  		break;
>  	case NETDEV_DOWN:
> -		fib_disable_ip(dev, 0, 0);
> +		fib_disable_ip(dev, 0);
>  		break;
>  	case NETDEV_CHANGEMTU:
>  	case NETDEV_CHANGE:


