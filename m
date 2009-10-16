From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/4 v2] net: Introduce sk_tx_queue_mapping
Date: Fri, 16 Oct 2009 11:57:09 +0200
Message-ID: <4AD84375.9020400@gmail.com>
References: <20091016072107.24384.17358.sendpatchset@localhost.localdomain> <20091016072120.24384.54449.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53057 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751512AbZJPJ5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 05:57:55 -0400
In-Reply-To: <20091016072120.24384.54449.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krishna Kumar a =E9crit :
> From: Krishna Kumar <krkumar2@in.ibm.com>
>=20
> Introduce sk_tx_queue_mapping; and functions that set, test and get
> this value. Reset sk_tx_queue_mapping to -1 whenever the dst cache
> is set/reset, and in socket alloc & free (free probably doesn't need
> it).
>=20

Could you please use an u16 instead, and take the convention of 0
being the 'unitialized value' ?

And define sk_tx_queue_clear(sk) instead of sk_record_tx_queue(sk, -1);

I also suggest using following names :

static inline void sk_tx_queue_set(struct sock *sk, u16 tx_queue)
{
	sk->sk_tx_queue_mapping =3D tx_queue + 1;
}

static inline u16 sk_tx_queue_get(const struct sock *sk)
{
	return sk->sk_tx_queue_mapping - 1;
}

static inline u16 sk_tx_queue_clear(struct sock *sk) // or _reset
{
	sk->sk_tx_queue_mapping =3D 0;
}

static inline bool sk_tx_queue_recorded(const struct sock *sk)
{
	return (sk && sk->sk_tx_queue_mapping > 0);
}


> @@ -1016,6 +1019,8 @@ static void sk_prot_free(struct proto *p
>  	struct kmem_cache *slab;
>  	struct module *owner;
> =20
> +	sk_record_tx_queue(sk, -1);
> +
>  	owner =3D prot->owner;
>  	slab =3D prot->slab;
> =20

This is not necessary, we are going to kfree(sk) anyway !
