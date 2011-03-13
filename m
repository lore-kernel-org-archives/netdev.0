From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] inetpeer: Don't disable BH for initial fast RCU lookup.
Date: Sun, 13 Mar 2011 11:04:09 +0100
Message-ID: <1300010649.2761.3.camel@edumazet-laptop>
References: <20110308.145954.59682618.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:55198 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754222Ab1CMKEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 06:04:15 -0400
Received: by fxm17 with SMTP id 17so2126707fxm.19
        for <netdev@vger.kernel.org>; Sun, 13 Mar 2011 03:04:14 -0700 (PDT)
In-Reply-To: <20110308.145954.59682618.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 08 mars 2011 =C3=A0 14:59 -0800, David Miller a =C3=A9crit :
> If modifications on other cpus are ok, then modifications to
> the tree during lookup done by the local cpu are ok too.
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/ipv4/inetpeer.c |   18 +++++++++---------
>  1 files changed, 9 insertions(+), 9 deletions(-)
>=20
> diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
> index f604ffd..6442c35 100644
> --- a/net/ipv4/inetpeer.c
> +++ b/net/ipv4/inetpeer.c
> @@ -206,16 +206,16 @@ static int addr_compare(const struct inetpeer_a=
ddr *a,
>  })
> =20
>  /*
> - * Called with rcu_read_lock_bh()
> + * Called with rcu_read_lock()
>   * Because we hold no lock against a writer, its quite possible we f=
all
>   * in an endless loop.
>   * But every pointer we follow is guaranteed to be valid thanks to R=
CU.
>   * We exit from this function if number of links exceeds PEER_MAXDEP=
TH
>   */
> -static struct inet_peer *lookup_rcu_bh(const struct inetpeer_addr *d=
addr,
> -				       struct inet_peer_base *base)
> +static struct inet_peer *lookup_rcu(const struct inetpeer_addr *dadd=
r,
> +				    struct inet_peer_base *base)
>  {
> -	struct inet_peer *u =3D rcu_dereference_bh(base->root);
> +	struct inet_peer *u =3D rcu_dereference(base->root);
>  	int count =3D 0;
> =20
>  	while (u !=3D peer_avl_empty) {
> @@ -231,9 +231,9 @@ static struct inet_peer *lookup_rcu_bh(const stru=
ct inetpeer_addr *daddr,
>  			return u;
>  		}
>  		if (cmp =3D=3D -1)
> -			u =3D rcu_dereference_bh(u->avl_left);
> +			u =3D rcu_dereference(u->avl_left);
>  		else
> -			u =3D rcu_dereference_bh(u->avl_right);
> +			u =3D rcu_dereference(u->avl_right);
>  		if (unlikely(++count =3D=3D PEER_MAXDEPTH))
>  			break;
>  	}
> @@ -470,11 +470,11 @@ struct inet_peer *inet_getpeer(struct inetpeer_=
addr *daddr, int create)
>  	/* Look up for the address quickly, lockless.
>  	 * Because of a concurrent writer, we might not find an existing en=
try.
>  	 */
> -	rcu_read_lock_bh();
> +	rcu_read_lock();
>  	sequence =3D read_seqbegin(&base->lock);
> -	p =3D lookup_rcu_bh(daddr, base);
> +	p =3D lookup_rcu(daddr, base);
>  	invalidated =3D read_seqretry(&base->lock, sequence);
> -	rcu_read_unlock_bh();
> +	rcu_read_unlock();
> =20
>  	if (p) {
>  		/* The existing node has been found.

David, I am not sure this is safe, since we use call_rcu_bh() when
freeing one item. One cpu could decide to kfree() one item while anothe=
r
cpu could still use it.

rcu_read_lock_bh() was signalling to others cpu we were in a softirq
section, so we were delaying a possible kfree().



