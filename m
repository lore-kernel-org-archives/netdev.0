From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 7/7] net: Batch inet_twsk_purge
Date: Thu, 03 Dec 2009 05:36:52 -0800
Message-ID: <m1ws14kwln.fsf@fess.ebiederm.org>
References: <m11vjcnsyr.fsf@fess.ebiederm.org>
	<1259843349-3810-7-git-send-email-ebiederm@xmission.com>
	<4B17BBC9.8070106@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jamal <hadi@cyberus.ca>, Daniel Lezcano <dlezcano@fr.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:49165 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751465AbZLCNgx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 08:36:53 -0500
In-Reply-To: <4B17BBC9.8070106@gmail.com> (Eric Dumazet's message of "Thu\, 03 Dec 2009 14\:23\:21 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> Eric W. Biederman a =C3=A9crit :
>> From: Eric W. Biederman <ebiederm@xmission.com>
>>=20
>> This function walks the whole hashtable so there is no point in
>> passing it a network namespace.  Instead I purge all timewait
>> sockets from dead network namespaces that I find.  If the namespace
>> is one of the once I am trying to purge I am guaranteed no new timew=
ait
>> sockets can be formed so this will get them all.  If the namespace
>> is one I am not acting for it might form a few more but I will
>> call inet_twsk_purge again and  shortly to get rid of them.  In
>> any even if the network namespace is dead timewait sockets are
>> useless.
>>=20
>> Move the calls of inet_twsk_purge into batch_exit routines so
>> that if I am killing a bunch of namespaces at once I will just
>> call inet_twsk_purge once and save a lot of redundant unnecessary
>> work.
>>=20
>> My simple 4k network namespace exit test the cleanup time dropped fr=
om
>> roughly 8.2s to 1.6s.  While the time spent running inet_twsk_purge =
fell
>> to about 2ms.  1ms for ipv4 and 1ms for ipv6.
>>=20
>> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
>> ---
>>  include/net/inet_timewait_sock.h |    6 +++---
>>  net/ipv4/inet_timewait_sock.c    |   10 +++++-----
>>  net/ipv4/tcp_ipv4.c              |   11 ++++++++---
>>  net/ipv6/tcp_ipv6.c              |   11 ++++++++---
>>  4 files changed, 24 insertions(+), 14 deletions(-)
>>=20
>> diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_tim=
ewait_sock.h
>> index 773b10f..4fd007f 100644
>> --- a/include/net/inet_timewait_sock.h
>> +++ b/include/net/inet_timewait_sock.h
>> @@ -212,14 +212,14 @@ extern void inet_twsk_schedule(struct inet_tim=
ewait_sock *tw,
>>  extern void inet_twsk_deschedule(struct inet_timewait_sock *tw,
>>  				 struct inet_timewait_death_row *twdr);
>> =20
>> -extern void inet_twsk_purge(struct net *net, struct inet_hashinfo *=
hashinfo,
>> +extern void inet_twsk_purge(struct inet_hashinfo *hashinfo,
>>  			    struct inet_timewait_death_row *twdr, int family);
>> =20
>>  static inline
>>  struct net *twsk_net(const struct inet_timewait_sock *twsk)
>>  {
>>  #ifdef CONFIG_NET_NS
>> -	return twsk->tw_net;
>> +	return rcu_dereference(twsk->tw_net);
>>  #else
>>  	return &init_net;
>>  #endif
>> @@ -229,7 +229,7 @@ static inline
>>  void twsk_net_set(struct inet_timewait_sock *twsk, struct net *net)
>>  {
>>  #ifdef CONFIG_NET_NS
>> -	twsk->tw_net =3D net;
>> +	rcu_assign_pointer(twsk->tw_net, net);
>>  #endif
>>  }
>>  #endif	/* _INET_TIMEWAIT_SOCK_ */
>> diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_=
sock.c
>> index 683ecec..a3699ac 100644
>> --- a/net/ipv4/inet_timewait_sock.c
>> +++ b/net/ipv4/inet_timewait_sock.c
>> @@ -421,7 +421,7 @@ out:
>> =20
>>  EXPORT_SYMBOL_GPL(inet_twdr_twcal_tick);
>> =20
>> -void inet_twsk_purge(struct net *net, struct inet_hashinfo *hashinf=
o,
>> +void inet_twsk_purge(struct inet_hashinfo *hashinfo,
>>  		     struct inet_timewait_death_row *twdr, int family)
>>  {
>>  	struct inet_timewait_sock *tw;
>> @@ -436,15 +436,15 @@ restart_rcu:
>>  restart:
>>  		sk_nulls_for_each_rcu(sk, node, &head->twchain) {
>>  			tw =3D inet_twsk(sk);
>> -			if (!net_eq(twsk_net(tw), net) ||
>> -			    tw->tw_family !=3D family)
>> +			if ((tw->tw_family !=3D family) ||
>> +				atomic_read(&twsk_net(tw)->count))
>>  				continue;
>> =20
>>  			if (unlikely(!atomic_inc_not_zero(&tw->tw_refcnt)))
>>  				continue;
>> =20
>> -			if (unlikely(!net_eq(twsk_net(tw), net) ||
>> -				     tw->tw_family !=3D family)) {
>> +			if (unlikely((tw->tw_family !=3D family) ||
>> +				     atomic_read(&twsk_net(tw)->count))) {
>>  				inet_twsk_put(tw);
>>  				goto restart;
>>  			}
>> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
>> index df18ce0..e30f026 100644
>> --- a/net/ipv4/tcp_ipv4.c
>> +++ b/net/ipv4/tcp_ipv4.c
>> @@ -2468,12 +2468,17 @@ static int __net_init tcp_sk_init(struct net=
 *net)
>>  static void __net_exit tcp_sk_exit(struct net *net)
>>  {
>>  	inet_ctl_sock_destroy(net->ipv4.tcp_sock);
>> -	inet_twsk_purge(net, &tcp_hashinfo, &tcp_death_row, AF_INET);
>> +}
>> +
>> +static void __net_exit tcp_sk_exit_batch(struct list_head *net_exit=
_list)
>> +{
>> +	inet_twsk_purge(&tcp_hashinfo, &tcp_death_row, AF_INET);
>>  }
>> =20
>>  static struct pernet_operations __net_initdata tcp_sk_ops =3D {
>> -       .init =3D tcp_sk_init,
>> -       .exit =3D tcp_sk_exit,
>> +       .init	   =3D tcp_sk_init,
>> +       .exit	   =3D tcp_sk_exit,
>> +       .exit_batch =3D tcp_sk_exit_batch,
>>  };
>> =20
>>  void __init tcp_v4_init(void)
>> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
>> index de70909..5f46d36 100644
>> --- a/net/ipv6/tcp_ipv6.c
>> +++ b/net/ipv6/tcp_ipv6.c
>> @@ -2126,12 +2126,17 @@ static int tcpv6_net_init(struct net *net)
>>  static void tcpv6_net_exit(struct net *net)
>>  {
>>  	inet_ctl_sock_destroy(net->ipv6.tcp_sk);
>> -	inet_twsk_purge(net, &tcp_hashinfo, &tcp_death_row, AF_INET6);
>> +}
>> +
>> +static void tcpv6_net_exit_batch(struct list_head *net_exit_list)
>> +{
>> +	inet_twsk_purge(&tcp_hashinfo, &tcp_death_row, AF_INET6);
>>  }
>> =20
>>  static struct pernet_operations tcpv6_net_ops =3D {
>> -	.init =3D tcpv6_net_init,
>> -	.exit =3D tcpv6_net_exit,
>> +	.init	    =3D tcpv6_net_init,
>> +	.exit	    =3D tcpv6_net_exit,
>> +	.exit_batch =3D tcpv6_net_exit_batch,
>>  };
>> =20
>>  int __init tcpv6_init(void)
>
>
> OK, but why calling inet_twsk_purge() twice, one for AF_INET, once fo=
r AF_INET6
>
> I believe you could zap family check as well in inet_twsk_purge(), an=
d not
> need tcpv6_net_ops.exit_batch =3D tcpv6_net_exit_batch

Technically it is needed if someone does rmmod ipv6.  rmmod ipv6 didn't=
 seem
to work for me, but if it ever does...  That and the cost is now in the=
 noise
in human terms.

I think dccp may also need a inet_twsk_purge as well, but I couldn't fi=
gure out what
it was doing with timewait sockets.

Eric


