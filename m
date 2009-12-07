From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH] tcp: documents timewait refcnt tricks
Date: Mon, 07 Dec 2009 08:06:58 -0800
Message-ID: <4B1D2822.5030704@xenotime.net>
References: <99d458640911301802i4bde20f4wa314668d543e3170@mail.gmail.com> <4B152F97.1090409@gmail.com> <4B1912CE.5040304@gmail.com> <20091205212148.GA26270@ioremap.net> <4B1CD20D.8030407@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	kapil dakhane <kdakhane@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([72.52.64.118]:55242 "HELO xenotime.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S934681AbZLGQGz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Dec 2009 11:06:55 -0500
Received: from ::ffff:96.253.169.185 ([96.253.169.185]) by xenotime.net for <netdev@vger.kernel.org>; Mon, 7 Dec 2009 08:06:59 -0800
In-Reply-To: <4B1CD20D.8030407@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Evgeniy Polyakov a =E9crit :
>> Hi Eric.
>>
>> On Fri, Dec 04, 2009 at 02:46:54PM +0100, Eric Dumazet (eric.dumazet=
@gmail.com) wrote:
>>> First patch changes __inet_hash_nolisten() and __inet6_hash()
>>> to get a timewait parameter to be able to unhash it from ehash
>>> at same time the new socket is inserted in hash.
>>>
>>> This makes sure timewait socket wont be found by a concurrent
>>> writer in __inet_check_established()
>> Both patches look good, although trick with returning reference coun=
ter
>> may look like a hack especially when only viewing into ip code and n=
ot
>> hashtable itself. Can you please cook up a documentation update for =
hash
>> function that it is supposed to return refcnt when socket was in has=
h
>> table.
>>
>=20
> Sure, here it is :
>=20
> Thanks !
>=20
> [PATCH] tcp: documents timewait refcnt tricks=20
>=20
> Adds kerneldoc for inet_twsk_unhash() & inet_twsk_bind_unhash().
>=20
> Suggested-by: Evgeniy Polyakov <zbr@ioremap.net>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>=20
> diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_s=
ock.c
> index 1958cf5..cf719c2 100644
> --- a/net/ipv4/inet_timewait_sock.c
> +++ b/net/ipv4/inet_timewait_sock.c
> @@ -15,9 +15,13 @@
>  #include <net/ip.h>
> =20
> =20
> -/*
> - * unhash a timewait socket from established hash
> - * lock must be hold by caller
> +/**
> + *	inet_twsk_unhash - unhash a timewait socket from established hash
> + *	@tw: timewait socket
> + *
> + *	unhash a timewait socket from established hash, if hashed.
> + *	ehash lock must be hold by caller.

	                   held

> + *	Returns 1 if caller should call inet_twsk_put() after lock releas=
e.
>   */
>  int inet_twsk_unhash(struct inet_timewait_sock *tw)
>  {
> @@ -26,12 +30,21 @@ int inet_twsk_unhash(struct inet_timewait_sock *t=
w)
> =20
>  	hlist_nulls_del_rcu(&tw->tw_node);
>  	sk_nulls_node_init(&tw->tw_node);
> +	/*
> +	 * We cannot call inet_twsk_put() ourself under lock,
> +	 * caller must call it for us.
> +	 */
>  	return 1;
>  }
> =20
> -/*
> - * unhash a timewait socket from bind hash
> - * lock must be hold by caller
> +/**
> + *	inet_twsk_bind_unhash - unhash a timewait socket from bind hash
> + *	@tw: timewait socket
> + *	@hashinfo: hashinfo pointer
> + *
> + *	unhash a timewait socket from bind hash, if hashed.
> + *	bind hash lock must be hold by caller.

	                       held

> + *	Returns 1 if caller should call inet_twsk_put() after lock releas=
e.
>   */
>  int inet_twsk_bind_unhash(struct inet_timewait_sock *tw,
>  			  struct inet_hashinfo *hashinfo)


thanks.
--=20
~Randy
