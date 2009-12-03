From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 7/7] net: Batch inet_twsk_purge
Date: Thu, 03 Dec 2009 14:23:21 +0100
Message-ID: <4B17BBC9.8070106@gmail.com>
References: <m11vjcnsyr.fsf@fess.ebiederm.org> <1259843349-3810-7-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jamal <hadi@cyberus.ca>, Daniel Lezcano <dlezcano@fr.ibm.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:58331 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755774AbZLCNXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 08:23:23 -0500
In-Reply-To: <1259843349-3810-7-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman a =E9crit :
> From: Eric W. Biederman <ebiederm@xmission.com>
>=20
> This function walks the whole hashtable so there is no point in
> passing it a network namespace.  Instead I purge all timewait
> sockets from dead network namespaces that I find.  If the namespace
> is one of the once I am trying to purge I am guaranteed no new timewa=
it
> sockets can be formed so this will get them all.  If the namespace
> is one I am not acting for it might form a few more but I will
> call inet_twsk_purge again and  shortly to get rid of them.  In
> any even if the network namespace is dead timewait sockets are
> useless.
>=20
> Move the calls of inet_twsk_purge into batch_exit routines so
> that if I am killing a bunch of namespaces at once I will just
> call inet_twsk_purge once and save a lot of redundant unnecessary
> work.
>=20
> My simple 4k network namespace exit test the cleanup time dropped fro=
m
> roughly 8.2s to 1.6s.  While the time spent running inet_twsk_purge f=
ell
> to about 2ms.  1ms for ipv4 and 1ms for ipv6.
>=20
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> ---
>  include/net/inet_timewait_sock.h |    6 +++---
>  net/ipv4/inet_timewait_sock.c    |   10 +++++-----
>  net/ipv4/tcp_ipv4.c              |   11 ++++++++---
>  net/ipv6/tcp_ipv6.c              |   11 ++++++++---
>  4 files changed, 24 insertions(+), 14 deletions(-)
>=20
> diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_time=
wait_sock.h
> index 773b10f..4fd007f 100644
> --- a/include/net/inet_timewait_sock.h
> +++ b/include/net/inet_timewait_sock.h
> @@ -212,14 +212,14 @@ extern void inet_twsk_schedule(struct inet_time=
wait_sock *tw,
>  extern void inet_twsk_deschedule(struct inet_timewait_sock *tw,
>  				 struct inet_timewait_death_row *twdr);
> =20
> -extern void inet_twsk_purge(struct net *net, struct inet_hashinfo *h=
ashinfo,
> +extern void inet_twsk_purge(struct inet_hashinfo *hashinfo,
>  			    struct inet_timewait_death_row *twdr, int family);
> =20
>  static inline
>  struct net *twsk_net(const struct inet_timewait_sock *twsk)
>  {
>  #ifdef CONFIG_NET_NS
> -	return twsk->tw_net;
> +	return rcu_dereference(twsk->tw_net);
>  #else
>  	return &init_net;
>  #endif
> @@ -229,7 +229,7 @@ static inline
>  void twsk_net_set(struct inet_timewait_sock *twsk, struct net *net)
>  {
>  #ifdef CONFIG_NET_NS
> -	twsk->tw_net =3D net;
> +	rcu_assign_pointer(twsk->tw_net, net);
>  #endif
>  }
>  #endif	/* _INET_TIMEWAIT_SOCK_ */
> diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_s=
ock.c
> index 683ecec..a3699ac 100644
> --- a/net/ipv4/inet_timewait_sock.c
> +++ b/net/ipv4/inet_timewait_sock.c
> @@ -421,7 +421,7 @@ out:
> =20
>  EXPORT_SYMBOL_GPL(inet_twdr_twcal_tick);
> =20
> -void inet_twsk_purge(struct net *net, struct inet_hashinfo *hashinfo=
,
> +void inet_twsk_purge(struct inet_hashinfo *hashinfo,
>  		     struct inet_timewait_death_row *twdr, int family)
>  {
>  	struct inet_timewait_sock *tw;
> @@ -436,15 +436,15 @@ restart_rcu:
>  restart:
>  		sk_nulls_for_each_rcu(sk, node, &head->twchain) {
>  			tw =3D inet_twsk(sk);
> -			if (!net_eq(twsk_net(tw), net) ||
> -			    tw->tw_family !=3D family)
> +			if ((tw->tw_family !=3D family) ||
> +				atomic_read(&twsk_net(tw)->count))
>  				continue;
> =20
>  			if (unlikely(!atomic_inc_not_zero(&tw->tw_refcnt)))
>  				continue;
> =20
> -			if (unlikely(!net_eq(twsk_net(tw), net) ||
> -				     tw->tw_family !=3D family)) {
> +			if (unlikely((tw->tw_family !=3D family) ||
> +				     atomic_read(&twsk_net(tw)->count))) {
>  				inet_twsk_put(tw);
>  				goto restart;
>  			}
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index df18ce0..e30f026 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -2468,12 +2468,17 @@ static int __net_init tcp_sk_init(struct net =
*net)
>  static void __net_exit tcp_sk_exit(struct net *net)
>  {
>  	inet_ctl_sock_destroy(net->ipv4.tcp_sock);
> -	inet_twsk_purge(net, &tcp_hashinfo, &tcp_death_row, AF_INET);
> +}
> +
> +static void __net_exit tcp_sk_exit_batch(struct list_head *net_exit_=
list)
> +{
> +	inet_twsk_purge(&tcp_hashinfo, &tcp_death_row, AF_INET);
>  }
> =20
>  static struct pernet_operations __net_initdata tcp_sk_ops =3D {
> -       .init =3D tcp_sk_init,
> -       .exit =3D tcp_sk_exit,
> +       .init	   =3D tcp_sk_init,
> +       .exit	   =3D tcp_sk_exit,
> +       .exit_batch =3D tcp_sk_exit_batch,
>  };
> =20
>  void __init tcp_v4_init(void)
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index de70909..5f46d36 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -2126,12 +2126,17 @@ static int tcpv6_net_init(struct net *net)
>  static void tcpv6_net_exit(struct net *net)
>  {
>  	inet_ctl_sock_destroy(net->ipv6.tcp_sk);
> -	inet_twsk_purge(net, &tcp_hashinfo, &tcp_death_row, AF_INET6);
> +}
> +
> +static void tcpv6_net_exit_batch(struct list_head *net_exit_list)
> +{
> +	inet_twsk_purge(&tcp_hashinfo, &tcp_death_row, AF_INET6);
>  }
> =20
>  static struct pernet_operations tcpv6_net_ops =3D {
> -	.init =3D tcpv6_net_init,
> -	.exit =3D tcpv6_net_exit,
> +	.init	    =3D tcpv6_net_init,
> +	.exit	    =3D tcpv6_net_exit,
> +	.exit_batch =3D tcpv6_net_exit_batch,
>  };
> =20
>  int __init tcpv6_init(void)


OK, but why calling inet_twsk_purge() twice, one for AF_INET, once for =
AF_INET6

I believe you could zap family check as well in inet_twsk_purge(), and =
not
need tcpv6_net_ops.exit_batch =3D tcpv6_net_exit_batch

