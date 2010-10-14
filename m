From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG ? ipip unregister_netdevice_many()
Date: Thu, 14 Oct 2010 05:57:11 +0200
Message-ID: <1287028631.2649.100.camel@edumazet-laptop>
References: <m11v801tfr.fsf@fess.ebiederm.org>
	 <20101012.130520.48517464.davem@davemloft.net> <4CB62FAF.1030009@free.fr>
	 <20101013.162321.183058542.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: daniel.lezcano@free.fr, ebiederm@xmission.com,
	hans.schillstrom@ericsson.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:45363 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753226Ab0JND5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 23:57:32 -0400
Received: by wwi14 with SMTP id 14so605423wwi.1
        for <netdev@vger.kernel.org>; Wed, 13 Oct 2010 20:57:31 -0700 (PDT)
In-Reply-To: <20101013.162321.183058542.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 13 octobre 2010 =C3=A0 16:23 -0700, David Miller a =C3=A9cr=
it :
> From: Daniel Lezcano <daniel.lezcano@free.fr>
> Date: Thu, 14 Oct 2010 00:16:15 +0200
>=20
> > do you mind to wait I test the patch before merging it ?
> > I would like to stress a bit this routine with multiple containers.
>=20
> Yes, it would be great if you could test this.
>=20
> Please make sure you get the fix for the bug that
> Jarek found ('list' needs to be initialized to NULL)
>=20
> I've included the latest version below:
>=20
> diff --git a/include/net/route.h b/include/net/route.h
> index 7e5e73b..8d24761 100644
> --- a/include/net/route.h
> +++ b/include/net/route.h
> @@ -106,7 +106,7 @@ extern int		ip_rt_init(void);
>  extern void		ip_rt_redirect(__be32 old_gw, __be32 dst, __be32 new_gw=
,
>  				       __be32 src, struct net_device *dev);
>  extern void		rt_cache_flush(struct net *net, int how);
> -extern void		rt_cache_flush_batch(void);
> +extern void		rt_cache_flush_batch(struct net *net);
>  extern int		__ip_route_output_key(struct net *, struct rtable **, co=
nst struct flowi *flp);
>  extern int		ip_route_output_key(struct net *, struct rtable **, stru=
ct flowi *flp);
>  extern int		ip_route_output_flow(struct net *, struct rtable **rp, s=
truct flowi *flp, struct sock *sk, int flags);
> diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
> index 919f2ad..4039f56 100644
> --- a/net/ipv4/fib_frontend.c
> +++ b/net/ipv4/fib_frontend.c
> @@ -999,7 +999,7 @@ static int fib_netdev_event(struct notifier_block=
 *this, unsigned long event, vo
>  		rt_cache_flush(dev_net(dev), 0);
>  		break;
>  	case NETDEV_UNREGISTER_BATCH:
> -		rt_cache_flush_batch();
> +		rt_cache_flush_batch(dev_net(dev));
>  		break;
>  	}
>  	return NOTIFY_DONE;
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 0755aa4..6ad730c 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -712,13 +712,14 @@ static inline int rt_is_expired(struct rtable *=
rth)
>   * Can be called by a softirq or a process.
>   * In the later case, we want to be reschedule if necessary
>   */
> -static void rt_do_flush(int process_context)
> +static void rt_do_flush(struct net *net, int process_context)
>  {
>  	unsigned int i;
>  	struct rtable *rth, *next;
> -	struct rtable * tail;
> =20
>  	for (i =3D 0; i <=3D rt_hash_mask; i++) {
> +		struct rtable *list =3D NULL, **pprev;
> +
>  		if (process_context && need_resched())
>  			cond_resched();
>  		rth =3D rt_hash_table[i].chain;
> @@ -726,41 +727,27 @@ static void rt_do_flush(int process_context)
>  			continue;
> =20
>  		spin_lock_bh(rt_hash_lock_addr(i));
> -#ifdef CONFIG_NET_NS
> -		{
> -		struct rtable ** prev, * p;
> =20
> -		rth =3D rt_hash_table[i].chain;
> +		pprev =3D &rt_hash_table[i].chain;
> +		rth =3D *pprev;
> +		while (rth) {
> +			next =3D rth->dst.rt_next;
> +			if (dev_net(rth->dst.dev) =3D=3D net) {

		if (net_eq(dev_net(rth->dst.dev), net)) {


> +				*pprev =3D next;
> =20
> -		/* defer releasing the head of the list after spin_unlock */
> -		for (tail =3D rth; tail; tail =3D tail->dst.rt_next)
> -			if (!rt_is_expired(tail))
> -				break;
> -		if (rth !=3D tail)
> -			rt_hash_table[i].chain =3D tail;
> -
> -		/* call rt_free on entries after the tail requiring flush */
> -		prev =3D &rt_hash_table[i].chain;
> -		for (p =3D *prev; p; p =3D next) {
> -			next =3D p->dst.rt_next;
> -			if (!rt_is_expired(p)) {
> -				prev =3D &p->dst.rt_next;
> -			} else {
> -				*prev =3D next;
> -				rt_free(p);
> -			}
> -		}
> +				rth->dst.rt_next =3D list;
> +				list =3D rth;

I was wondering about RCU rules here.
We change pointers while a reader might enter in a loop.
It seems fine : At soon as we spin_unlock(), the loop should be closed.

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

minor coding style : You should add a brace in the else clause :

pprev =3D &rt_hash_table[i].chain;
for (rth =3D *pprev; rth !=3D NULL; rth =3D next) {
	next =3D rth->dst.rt_next;
	if (net_eq(dev_net(rth->dst.dev), net)) {
		*pprev =3D next;
		rth->dst.rt_next =3D list;
		list =3D rth;
	} else {
		pprev =3D &rth->dst.rt_next;
	}
}

Thanks !


