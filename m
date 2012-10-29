From: Mathieu Desnoyers <mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v7 14/16] net,rds: use new hashtable implementation
Date: Mon, 29 Oct 2012 09:25:52 -0400
Message-ID: <20121029132552.GB16391@Krystal>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com> <1351450948-15618-14-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org,
	bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org,
	venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, ejt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, lw-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
To: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1351450948-15618-14-git-send-email-levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

* Sasha Levin (levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org) wrote:
> Switch rds to use the new hashtable implementation. This reduces the amount of
> generic unrelated code in rds.
> 
> Signed-off-by: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  net/rds/bind.c       |  28 +++++++++-----
>  net/rds/connection.c | 102 +++++++++++++++++++++++----------------------------
>  2 files changed, 63 insertions(+), 67 deletions(-)
> 
> diff --git a/net/rds/bind.c b/net/rds/bind.c
> index 637bde5..79d65ce 100644
> --- a/net/rds/bind.c
> +++ b/net/rds/bind.c
> @@ -36,16 +36,16 @@
>  #include <linux/if_arp.h>
>  #include <linux/jhash.h>
>  #include <linux/ratelimit.h>
> +#include <linux/hashtable.h>
>  #include "rds.h"
>  
> -#define BIND_HASH_SIZE 1024
> -static struct hlist_head bind_hash_table[BIND_HASH_SIZE];
> +#define BIND_HASH_BITS 10
> +static DEFINE_HASHTABLE(bind_hash_table, BIND_HASH_BITS);
>  static DEFINE_SPINLOCK(rds_bind_lock);
>  
> -static struct hlist_head *hash_to_bucket(__be32 addr, __be16 port)
> +static u32 rds_hash(__be32 addr, __be16 port)
>  {
> -	return bind_hash_table + (jhash_2words((u32)addr, (u32)port, 0) &
> -				  (BIND_HASH_SIZE - 1));
> +	return jhash_2words((u32)addr, (u32)port, 0);
>  }
>  
>  static struct rds_sock *rds_bind_lookup(__be32 addr, __be16 port,
> @@ -53,12 +53,12 @@ static struct rds_sock *rds_bind_lookup(__be32 addr, __be16 port,
>  {
>  	struct rds_sock *rs;
>  	struct hlist_node *node;
> -	struct hlist_head *head = hash_to_bucket(addr, port);
> +	u32 key = rds_hash(addr, port);
>  	u64 cmp;
>  	u64 needle = ((u64)be32_to_cpu(addr) << 32) | be16_to_cpu(port);
>  
>  	rcu_read_lock();
> -	hlist_for_each_entry_rcu(rs, node, head, rs_bound_node) {
> +	hash_for_each_possible_rcu(bind_hash_table, rs, node, rs_bound_node, key) {

here too, key will be hashed twice:

- once by jhash_2words,
- once by hash_32(),

is this intended ?

Thanks,

Mathieu

-- 
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
