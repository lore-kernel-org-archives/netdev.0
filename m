From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] netfilter: fix the hash random initializing race
Date: Fri, 20 Aug 2010 18:17:03 +0200
Message-ID: <1282321023.2484.285.camel@edumazet-laptop>
References: <1282320404-2948-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1282320404-2948-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le samedi 21 ao=C3=BBt 2010 =C3=A0 00:06 +0800, Changli Gao a =C3=A9cri=
t :
> nf_conntrack_alloc() isn't called with nf_conntrack_lock locked, so h=
ash
> random initializing code maybe executed more than once on different C=
PUs.
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ---
>  net/netfilter/nf_conntrack_core.c |   17 +++++++++++------
>  1 file changed, 11 insertions(+), 6 deletions(-)
> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_con=
ntrack_core.c
> index df3eedb..7ae7f71 100644
> --- a/net/netfilter/nf_conntrack_core.c
> +++ b/net/netfilter/nf_conntrack_core.c
> @@ -65,8 +65,7 @@ EXPORT_SYMBOL_GPL(nf_conntrack_max);
>  DEFINE_PER_CPU(struct nf_conn, nf_conntrack_untracked);
>  EXPORT_PER_CPU_SYMBOL(nf_conntrack_untracked);
> =20
> -static int nf_conntrack_hash_rnd_initted;
> -static unsigned int nf_conntrack_hash_rnd;
> +static unsigned int nf_conntrack_hash_rnd __read_mostly;
> =20
>  static u_int32_t __hash_conntrack(const struct nf_conntrack_tuple *t=
uple,
>  				  u16 zone, unsigned int size, unsigned int rnd)
> @@ -574,10 +573,16 @@ struct nf_conn *nf_conntrack_alloc(struct net *=
net, u16 zone,
>  {
>  	struct nf_conn *ct;
> =20
> -	if (unlikely(!nf_conntrack_hash_rnd_initted)) {
> -		get_random_bytes(&nf_conntrack_hash_rnd,
> -				sizeof(nf_conntrack_hash_rnd));
> -		nf_conntrack_hash_rnd_initted =3D 1;
> +	if (unlikely(!nf_conntrack_hash_rnd)) {
> +		unsigned int rand;
> +
> +		/* Why not initialize nf_conntrack_rnd in a "init()" function ?
> +		 * Because there isn't enough entropy when system initializing,
> +		 * and we initialize it as late as possible. */

This patch is fine but a fine multi line comment is :
	/* Some
	 * fine
	 * comment
	 */

> +		do {
> +			get_random_bytes(&rand, sizeof(rand));
> +		} while (!rand);
> +		cmpxchg(&nf_conntrack_hash_rnd, 0, rand);
>  	}
> =20
>  	/* We don't want any race condition at early drop stage */


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
