From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: addrconf: refcnt with  IPV6_PRIVACY enabled
Date: Tue, 23 Nov 2010 15:33:23 +0100
Message-ID: <1290522803.3046.11.camel@edumazet-laptop>
References: <20101123134003.GB4142@swordfish.minsk.epam.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101123134003.GB4142@swordfish.minsk.epam.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 23 novembre 2010 =C3=A0 15:40 +0200, Sergey Senozhatsky a =C3=A9=
crit :
> Hello,
>=20
> I've sent a patch http://lkml.org/lkml/2010/11/21/124=20
> "[PATCH] ipv6: fix inet6_dev refcnt with IPV6_PRIVACY enabled" relate=
d
> to wrong in6_dev refcnt value when IPV6_PRIVACY enabled.
>=20
> I've took a second look, and question arised -=20
> Is it actually necessary to in6_dev_hold/in6_dev_put in ipv6_regen_rn=
did?
> In ipv6_regen_rndid we call in6_dev_hold only when mod_timer =3D=3D 0=
,
> and always in6_dev_put.=20
>=20
>=20
> I've removed check for < 0 and goto from __ipv6_regen_rndid call, sin=
ce it=20
> always return 0.
>=20
>=20
> Please, kindly review V2.
>=20
> ---
>=20
>  net/ipv6/addrconf.c |   10 +++-------
>  1 files changed, 3 insertions(+), 7 deletions(-)
>=20
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 2fc35b3..8187d14 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -425,7 +425,6 @@ static struct inet6_dev * ipv6_add_dev(struct net=
_device *dev)
>  		       dev->name);
>  		ndev->cnf.use_tempaddr =3D -1;
>  	} else {
> -		in6_dev_hold(ndev);
>  		ipv6_regen_rndid((unsigned long) ndev);
>  	}
>  #endif
> @@ -1653,8 +1652,7 @@ static void ipv6_regen_rndid(unsigned long data=
)
>  	if (idev->dead)
>  		goto out;
> =20
> -	if (__ipv6_regen_rndid(idev) < 0)
> -		goto out;
> +	__ipv6_regen_rndid(idev);
> =20
>  	expires =3D jiffies +
>  		idev->cnf.temp_prefered_lft * HZ -
> @@ -1667,13 +1665,11 @@ static void ipv6_regen_rndid(unsigned long da=
ta)
>  		goto out;
>  	}
> =20
> -	if (!mod_timer(&idev->regen_timer, expires))
> -		in6_dev_hold(idev);
> -
> +	mod_timer(&idev->regen_timer, expires);
> +=09
>  out:
>  	write_unlock_bh(&idev->lock);
>  	rcu_read_unlock_bh();
> -	in6_dev_put(idev);
>  }
> =20
>  static int __ipv6_try_regen_rndid(struct inet6_dev *idev, struct in6=
_addr *tmpaddr) {
>=20


Sergey, I dont think your patches (V1 or V2) are correct.

You leak a refcount if (idev->dead) is true

ipv6_regen_rndid() is the timer handler function, it must call
in6_dev_put() at the end, unless we rearm the timer.

So this code is correct.


if (!mod_timer(&idev->regen_timer, expires))
	in6_dev_hold(idev);
=2E..
in6_dev_put(idev);


And we must call in6_dev_hold() before calling the handler, either
directly from ipv6_add_dev() [Where your first patch tried to remove th=
e
dev_hold() call], or when arming the timer.

Are you sure the problem you try to solve is not already solved in
commit 88b2a9a3d98a19496d64aadda7158c0ad51cbe7d in net-2.6 tree ?

http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-2.6.git;a=3Dcommi=
tdiff;h=3D88b2a9a3d98a19496d64aadda7158c0ad51cbe7d
