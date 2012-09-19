From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next] net: only run neigh_forced_gc() from one cpu
Date: Wed, 19 Sep 2012 06:50:38 -0400
Message-ID: <20120919105038.GA12352@hmsreliant.think-freely.org>
References: <1348046827.26523.571.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Maciej =?utf-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Tom Herbert <therbert@google.com>,
	Lorenzo Colitti <lorenzo@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58687 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753256Ab2ISKux (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 06:50:53 -0400
Content-Disposition: inline
In-Reply-To: <1348046827.26523.571.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 19, 2012 at 11:27:07AM +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>=20
> With multiqueue NIC or RPS, we can have situation where all cpus are
> spending huge amount of cycles in neigh_forced_gc(), and machine can
> crash.
>=20
> Since we are under probable attack, its better to let only one cpu
> do the scan, and other cpus immediately return from neigh_forced_gc()
>=20
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Lorenzo Colitti <lorenzo@google.com>
> Cc: Maciej =C5=BBenczykowski <maze@google.com>
> Cc: Tom Herbert <therbert@google.com>
> ---
> Google-Bug-Id: 7121897
>=20
>  include/net/neighbour.h |    1 +
>  net/core/neighbour.c    |    9 +++++++--
>  2 files changed, 8 insertions(+), 2 deletions(-)
>=20
> diff --git a/include/net/neighbour.h b/include/net/neighbour.h
> index 0dab173..ba21e93 100644
> --- a/include/net/neighbour.h
> +++ b/include/net/neighbour.h
> @@ -178,6 +178,7 @@ struct neigh_table {
>  	struct neigh_statistics	__percpu *stats;
>  	struct neigh_hash_table __rcu *nht;
>  	struct pneigh_entry	**phash_buckets;
> +	spinlock_t		forced_gc_lock;
>  };
> =20
>  #define NEIGH_PRIV_ALIGN	sizeof(long long)
> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
> index c160adb..1f7d8fa 100644
> --- a/net/core/neighbour.c
> +++ b/net/core/neighbour.c
> @@ -134,9 +134,12 @@ static int neigh_forced_gc(struct neigh_table *t=
bl)
>  	int i;
>  	struct neigh_hash_table *nht;
> =20
> +	if (!spin_trylock_bh(&tbl->forced_gc_lock))
> +		return 0;
> +
This is going to cause callers in neigh_alloc to immediately fail their
allocation attempts.  Would it be a good idea to modify that call site =
so that
instead of returning NULL, instead reread tbl->entries before comparing=
 to
gc_thresh3, on the hope that the cpu in the garbage collecting routine =
has freed
some entries?

Neil
