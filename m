From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/5] rhashtable: Remove gfp_flags from insert and remove
 functions
Date: Mon, 15 Sep 2014 05:35:35 -0700
Message-ID: <1410784535.7106.164.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1410782841.git.tgraf@suug.ch>
	 <bd3aa4282e89b022620225101ab491e344852f5f.1410782841.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, paulmck@linux.vnet.ibm.com,
	john.r.fastabend@intel.com, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <bd3aa4282e89b022620225101ab491e344852f5f.1410782841.git.tgraf@suug.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-09-15 at 14:18 +0200, Thomas Graf wrote:
> As the expansion/shrinking is moved to a worker thread, no allocations
> will be performed anymore.
> 

You meant : no GFP_ATOMIC allocations ?

I would rephrase using something like :

Because hash resizes are potentially time consuming, they'll be
performed in process context where GFP_KERNEL allocations are preferred.

> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> ---
>  include/linux/rhashtable.h | 10 +++++-----
>  lib/rhashtable.c           | 41 +++++++++++++++++------------------------
>  net/netfilter/nft_hash.c   |  4 ++--
>  net/netlink/af_netlink.c   |  4 ++--
>  4 files changed, 26 insertions(+), 33 deletions(-)
> 
> diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
> index fb298e9d..942fa44 100644
> --- a/include/linux/rhashtable.h
> +++ b/include/linux/rhashtable.h
> @@ -96,16 +96,16 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params);
>  u32 rhashtable_hashfn(const struct rhashtable *ht, const void *key, u32 len);
>  u32 rhashtable_obj_hashfn(const struct rhashtable *ht, void *ptr);
>  
> -void rhashtable_insert(struct rhashtable *ht, struct rhash_head *node, gfp_t);
> -bool rhashtable_remove(struct rhashtable *ht, struct rhash_head *node, gfp_t);
> +void rhashtable_insert(struct rhashtable *ht, struct rhash_head *node);
> +bool rhashtable_remove(struct rhashtable *ht, struct rhash_head *node);
>  void rhashtable_remove_pprev(struct rhashtable *ht, struct rhash_head *obj,
> -			     struct rhash_head __rcu **pprev, gfp_t flags);
> +			     struct rhash_head __rcu **pprev);
>  
>  bool rht_grow_above_75(const struct rhashtable *ht, size_t new_size);
>  bool rht_shrink_below_30(const struct rhashtable *ht, size_t new_size);
>  
> -int rhashtable_expand(struct rhashtable *ht, gfp_t flags);
> -int rhashtable_shrink(struct rhashtable *ht, gfp_t flags);
> +int rhashtable_expand(struct rhashtable *ht);
> +int rhashtable_shrink(struct rhashtable *ht);
>  
>  void *rhashtable_lookup(const struct rhashtable *ht, const void *key);
>  void *rhashtable_lookup_compare(const struct rhashtable *ht, u32 hash,
> diff --git a/lib/rhashtable.c b/lib/rhashtable.c
> index 8dfec3f..c133d82 100644
> --- a/lib/rhashtable.c
> +++ b/lib/rhashtable.c
> @@ -108,13 +108,13 @@ static u32 head_hashfn(const struct rhashtable *ht,
>  	return obj_hashfn(ht, rht_obj(ht, he), hsize);
>  }
>  
> -static struct bucket_table *bucket_table_alloc(size_t nbuckets, gfp_t flags)
> +static struct bucket_table *bucket_table_alloc(size_t nbuckets)
>  {
>  	struct bucket_table *tbl;
>  	size_t size;
>  
>  	size = sizeof(*tbl) + nbuckets * sizeof(tbl->buckets[0]);
> -	tbl = kzalloc(size, flags);
> +	tbl = kzalloc(size, GFP_KERNEL);

Add __GFP_NOWARN, as you fallback to vzalloc ?

>  	if (tbl == NULL)
>  		tbl = vzalloc(size);

btw, inet hash table uses alloc_large_system_hash() which spreads the
pages on all available NUMA nodes :

# dmesg | grep "TCP established"
[    1.223046] TCP established hash table entries: 524288 (order: 10, 4194304 bytes)
# grep alloc_large_system_hash /proc/vmallocinfo | grep pages=1024
0xffffc900181d6000-0xffffc900185d7000 4198400 alloc_large_system_hash+0x177/0x237 pages=1024 vmalloc vpages N0=512 N1=512
0xffffc900185d7000-0xffffc900189d8000 4198400 alloc_large_system_hash+0x177/0x237 pages=1024 vmalloc vpages N0=512 N1=512
0xffffc90028a01000-0xffffc90028e02000 4198400 alloc_large_system_hash+0x177/0x237 pages=1024 vmalloc vpages N0=512 N1=512

So we might keep in mind to keep this numa policy.

Rest of the patch looks fine to me, thanks.
