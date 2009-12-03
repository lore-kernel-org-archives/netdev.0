From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 6/7] net: Use rcu lookups in inet_twsk_purge.
Date: Thu, 03 Dec 2009 14:17:41 +0100
Message-ID: <4B17BA75.1040302@gmail.com>
References: <m11vjcnsyr.fsf@fess.ebiederm.org> <1259843349-3810-6-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jamal <hadi@cyberus.ca>, Daniel Lezcano <dlezcano@fr.ibm.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54536 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751226AbZLCNUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 08:20:52 -0500
In-Reply-To: <1259843349-3810-6-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman a =E9crit :
> From: Eric W. Biederman <ebiederm@xmission.com>
>=20
> While we are looking up entries to free there is no reason to take
> the lock in inet_twsk_purge.  We have to drop locks and restart
> occassionally anyway so adding a few more in case we get on the
> wrong list because of a timewait move is no big deal.  At the
> same time not taking the lock for long periods of time is much
> more polite to the rest of the users of the hash table.
>=20
> In my test configuration of killing 4k network namespaces
> this change causes 4k back to back runs of inet_twsk_purge on an
> empty hash table to go from roughly 20.7s to 3.3s, and the total
> time to destroy 4k network namespaces goes from roughly 44s to
> 3.3s.
>=20
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Very nice patch Eric

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

> ---
>  net/ipv4/inet_timewait_sock.c |   39 ++++++++++++++++++++++++-------=
--------
>  1 files changed, 24 insertions(+), 15 deletions(-)
>=20
> diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_s=
ock.c
> index 1f5d508..683ecec 100644
> --- a/net/ipv4/inet_timewait_sock.c
> +++ b/net/ipv4/inet_timewait_sock.c
> @@ -427,31 +427,40 @@ void inet_twsk_purge(struct net *net, struct in=
et_hashinfo *hashinfo,
>  	struct inet_timewait_sock *tw;
>  	struct sock *sk;
>  	struct hlist_nulls_node *node;
> -	int h;
> +	unsigned int slot;
> =20
> -	local_bh_disable();
> -	for (h =3D 0; h <=3D hashinfo->ehash_mask; h++) {
> -		struct inet_ehash_bucket *head =3D
> -			inet_ehash_bucket(hashinfo, h);
> -		spinlock_t *lock =3D inet_ehash_lockp(hashinfo, h);
> +	for (slot =3D 0; slot <=3D hashinfo->ehash_mask; slot++) {
> +		struct inet_ehash_bucket *head =3D &hashinfo->ehash[slot];
> +restart_rcu:
> +		rcu_read_lock();
>  restart:
> -		spin_lock(lock);
> -		sk_nulls_for_each(sk, node, &head->twchain) {
> -
> +		sk_nulls_for_each_rcu(sk, node, &head->twchain) {
>  			tw =3D inet_twsk(sk);
>  			if (!net_eq(twsk_net(tw), net) ||
>  			    tw->tw_family !=3D family)
>  				continue;
> =20
> -			atomic_inc(&tw->tw_refcnt);
> -			spin_unlock(lock);
> +			if (unlikely(!atomic_inc_not_zero(&tw->tw_refcnt)))
> +				continue;
> +
> +			if (unlikely(!net_eq(twsk_net(tw), net) ||
> +				     tw->tw_family !=3D family)) {
> +				inet_twsk_put(tw);
> +				goto restart;
> +			}
> +		=09
> +			rcu_read_unlock();
>  			inet_twsk_deschedule(tw, twdr);
>  			inet_twsk_put(tw);
> -
> -			goto restart;
> +			goto restart_rcu;
>  		}
> -		spin_unlock(lock);
> +		/* If the nulls value we got at the end of this lookup is
> +		 * not the expected one, we must restart lookup.
> +		 * We probably met an item that was moved to another chain.
> +		 */
> +		if (get_nulls_value(node) !=3D slot)
> +			goto restart;
> +		rcu_read_unlock();
>  	}
> -	local_bh_enable();
>  }
>  EXPORT_SYMBOL_GPL(inet_twsk_purge);

