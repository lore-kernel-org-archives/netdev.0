From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: Re: [PATCH v3.17 .. v3.19] lib/rhashtable: fix race between rhashtable_lookup_compare
 and hashtable resize
Date: Tue, 30 Jun 2015 12:39:42 +0300
Message-ID: <559263DE.3060702@yandex-team.ru>
References: <20150626104817.16520.77222.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Stable <stable@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Sasha Levin <sasha.levin@oracle.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20150626104817.16520.77222.stgit@buzz>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

+CC Sasha Levin

FYI: this patch fixes race in netlink which leads to hung in glibc
function getaddrinfo() because it doesn't handle errors at all.

On 26.06.2015 13:48, Konstantin Khlebnikov wrote:
> Hash value passed as argument into rhashtable_lookup_compare could be
> computed using different hash table than rhashtable_lookup_compare sees.
>
> This patch passes key into rhashtable_lookup_compare() instead of hash and
> compures hash value right in place using the same table as for lookup.
>
> Also it adds comment for rhashtable_hashfn and rhashtable_obj_hashfn:
> user must prevent concurrent insert/remove otherwise returned hash value
> could be invalid.
>
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Fixes: e341694e3eb5 ("netlink: Convert netlink_lookup() to use RCU protected hash table")
> Link: http://lkml.kernel.org/r/20150514042151.GA5482@gondor.apana.org.au
> Cc: Stable <stable@vger.kernel.org> (v3.17 .. v3.19)
> ---
>   include/linux/rhashtable.h |    2 +-
>   lib/rhashtable.c           |   12 ++++++++----
>   net/netlink/af_netlink.c   |    5 +----
>   3 files changed, 10 insertions(+), 9 deletions(-)
>
> diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
> index fb298e9d6d3a..84056743780a 100644
> --- a/include/linux/rhashtable.h
> +++ b/include/linux/rhashtable.h
> @@ -108,7 +108,7 @@ int rhashtable_expand(struct rhashtable *ht, gfp_t flags);
>   int rhashtable_shrink(struct rhashtable *ht, gfp_t flags);
>
>   void *rhashtable_lookup(const struct rhashtable *ht, const void *key);
> -void *rhashtable_lookup_compare(const struct rhashtable *ht, u32 hash,
> +void *rhashtable_lookup_compare(const struct rhashtable *ht, void *key,
>   				bool (*compare)(void *, void *), void *arg);
>
>   void rhashtable_destroy(const struct rhashtable *ht);
> diff --git a/lib/rhashtable.c b/lib/rhashtable.c
> index 624a0b7c05ef..cb22073fe687 100644
> --- a/lib/rhashtable.c
> +++ b/lib/rhashtable.c
> @@ -61,6 +61,8 @@ static u32 __hashfn(const struct rhashtable *ht, const void *key,
>    * Computes the hash value using the hash function provided in the 'hashfn'
>    * of struct rhashtable_params. The returned value is guaranteed to be
>    * smaller than the number of buckets in the hash table.
> + *
> + * The caller must ensure that no concurrent table mutations occur.
>    */
>   u32 rhashtable_hashfn(const struct rhashtable *ht, const void *key, u32 len)
>   {
> @@ -92,6 +94,8 @@ static u32 obj_hashfn(const struct rhashtable *ht, const void *ptr, u32 hsize)
>    * 'obj_hashfn' depending on whether the hash table is set up to work with
>    * a fixed length key. The returned value is guaranteed to be smaller than
>    * the number of buckets in the hash table.
> + *
> + * The caller must ensure that no concurrent table mutations occur.
>    */
>   u32 rhashtable_obj_hashfn(const struct rhashtable *ht, void *ptr)
>   {
> @@ -474,7 +478,7 @@ EXPORT_SYMBOL_GPL(rhashtable_lookup);
>   /**
>    * rhashtable_lookup_compare - search hash table with compare function
>    * @ht:		hash table
> - * @hash:	hash value of desired entry
> + * @key:	pointer to key
>    * @compare:	compare function, must return true on match
>    * @arg:	argument passed on to compare function
>    *
> @@ -486,14 +490,14 @@ EXPORT_SYMBOL_GPL(rhashtable_lookup);
>    *
>    * Returns the first entry on which the compare function returned true.
>    */
> -void *rhashtable_lookup_compare(const struct rhashtable *ht, u32 hash,
> +void *rhashtable_lookup_compare(const struct rhashtable *ht, void *key,
>   				bool (*compare)(void *, void *), void *arg)
>   {
>   	const struct bucket_table *tbl = rht_dereference_rcu(ht->tbl, ht);
>   	struct rhash_head *he;
> +	u32 hash;
>
> -	if (unlikely(hash >= tbl->size))
> -		return NULL;
> +	hash = __hashfn(ht, key, ht->p.key_len, tbl->size);
>
>   	rht_for_each_rcu(he, tbl->buckets[hash], ht) {
>   		if (!compare(rht_obj(ht, he), arg))
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index c0a418766f9c..c82b2e37e652 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -1003,11 +1003,8 @@ static struct sock *__netlink_lookup(struct netlink_table *table, u32 portid,
>   		.net = net,
>   		.portid = portid,
>   	};
> -	u32 hash;
>
> -	hash = rhashtable_hashfn(&table->hash, &portid, sizeof(portid));
> -
> -	return rhashtable_lookup_compare(&table->hash, hash,
> +	return rhashtable_lookup_compare(&table->hash, &portid,
>   					 &netlink_compare, &arg);
>   }
>
>


-- 
Konstantin
