From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 03/18] ipvs: zero percpu stats
Date: Sun, 06 Mar 2011 10:06:07 +0100
Message-ID: <1299402367.2758.87.camel@edumazet-laptop>
References: <1299368760-14271-1-git-send-email-horms@verge.net.au>
	 <1299368760-14271-4-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, lvs-devel@vger.kernel.org,
	Julian Anastasov <ja@ssi.bg>,
	Hans Schillstrom <hans@schillstrom.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1299368760-14271-4-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 06 mars 2011 =C3=A0 08:45 +0900, Simon Horman a =C3=A9crit =
:
> From: Julian Anastasov <ja@ssi.bg>
>=20
>  	Zero the new percpu stats because we copy from there.
>=20
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Simon Horman <horms@verge.net.au>
> ---
>  net/netfilter/ipvs/ip_vs_ctl.c |   17 +++++++++++++++++
>  1 files changed, 17 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_v=
s_ctl.c
> index a2a67ad..fd74527 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -715,8 +715,25 @@ static void ip_vs_trash_cleanup(struct net *net)
>  static void
>  ip_vs_zero_stats(struct ip_vs_stats *stats)
>  {
> +	struct ip_vs_cpu_stats *cpustats =3D stats->cpustats;
> +	int i;
> +
>  	spin_lock_bh(&stats->lock);
> =20
> +	for_each_possible_cpu(i) {
> +		struct ip_vs_cpu_stats *u =3D per_cpu_ptr(cpustats, i);
> +		unsigned int start;
> +
> +		/* Do not pretend to be writer, it is enough to
> +		 * sync with writers that modify the u64 counters
> +		 * because under stats->lock we are the only reader.
> +		 */
> +		do {
> +			start =3D u64_stats_fetch_begin(&u->syncp);
> +			memset(&u->ustats, 0, sizeof(u->ustats));
> +		} while (u64_stats_fetch_retry(&u->syncp, start));


Sorry this makes no sense to me.

This code _is_ a writer, and hardly a hot path.

Why try to pretend its a reader and confuse people ?

Either :

- Another writer can modify the counters in same time, and we must
synchronize with them (we are a writer after all)

- Another reader can read the counters in same time, and we must let
them catch we mihjt have cleared half of their values.

- No reader or writer can access data, no synch is needed, a pure
memset() is OK.


> +	}
> +
>  	memset(&stats->ustats, 0, sizeof(stats->ustats));
>  	ip_vs_zero_estimator(stats);
> =20


