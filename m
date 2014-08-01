From: Nikolay Aleksandrov <nikolay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next 1/3] lib: Resizable, Scalable,
 Concurrent Hash Table
Date: Fri, 01 Aug 2014 12:01:16 +0200
Message-ID: <53DB656C.9000907@redhat.com>
References: <cover.1406882738.git.tgraf@suug.ch>
 <15a766adefc269dd26001474e9b67dbbd0d5bc82.1406882738.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org,
 netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org,
 paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, walpole-sKt6ljEC1JY3uPMLIKxrzw@public.gmane.org
To: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <15a766adefc269dd26001474e9b67dbbd0d5bc82.1406882738.git.tgraf-G/eBtMaohhA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 08/01/2014 10:51 AM, Thomas Graf wrote:
> Generic implementation of a resizable, scalable, concurrent hash table
> based on [0]. The implementation supports both, fixed size keys specified
> via an offset and length, or arbitrary keys via own hash and compare
> functions.
> 
> Lookups are lockless and protected as RCU read side critical sections.
> Automatic growing/shrinking based on user configurable watermarks is
> available while allowing concurrent lookups to take place.
> 
> Objects to be hashed must include a struct rhash_head. The reason for not
> using the existing struct hlist_head is that the expansion and shrinking
> will have two buckets point to a single entry which would lead in obscure
> reverse chaining behaviour.
> 
> Code includes a boot selftest if CONFIG_TEST_RHASHTABLE is defined.
> 
> [0] https://www.usenix.org/legacy/event/atc11/tech/final_files/Triplett.pdf
> 
> Signed-off-by: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
> ---
>  include/linux/rhashtable.h | 213 ++++++++++++
>  lib/Kconfig.debug          |   8 +
>  lib/Makefile               |   2 +-
>  lib/rhashtable.c           | 797 +++++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 1019 insertions(+), 1 deletion(-)
>  create mode 100644 include/linux/rhashtable.h
>  create mode 100644 lib/rhashtable.c
> 
<<snip>>
> +
> +/**
> + * rhashtable_init - initialize a new hash table
> + * @ht:		hash table to be initialized
> + * @params:	configuration parameters
> + *
> + * Initializes a new hash table based on the provided configuration
> + * parameters. A table can be configured either with a variable or
> + * fixed length key:
> + *
> + * Configuration Example 1: Fixed length keys
> + * struct test_obj {
> + *	int			key;
> + *	void *			my_member;
> + *	struct rhash_head	node;
> + * };
> + *
> + * struct rhashtable_params params = {
> + *	.head_offset = offsetof(struct test_obj, node),
> + *	.key_offset = offsetof(struct test_obj, key),
> + *	.key_len = sizeof(int),
> + *	.hashfn = arch_fast_hash,
> + *	.mutex_is_held = &my_mutex_is_held,
> + * };
> + *
> + * Configuration Example 2: Variable length keys
> + * struct test_obj {
> + *	[...]
> + *	struct rhash_head	node;
> + * };
> + *
> + * u32 my_hash_fn(const void *data, u32 seed)
> + * {
> + *	struct test_obj *obj = data;
> + *
> + *	return [... hash ...];
> + * }
> + *
> + * struct rhashtable_params params = {
> + *	.head_offset = offsetof(struct test_obj, node),
> + *	.hashfn = arch_fast_hash,
> + *	.obj_hashfn = my_hash_fn,
> + *	.mutex_is_held = &my_mutex_is_held,
> + * };
> + */
> +int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
> +{
> +	struct bucket_table *tbl;
> +	size_t size;
> +
> +	size = HASH_MIN_SIZE;
> +
> +	if ((params->key_len && !params->hashfn) ||
> +	    (!params->key_len && !params->obj_hashfn))
> +		return -EINVAL;
> +
> +	if (params->nelem_hint)
> +		size = rounded_hashtable_size(params->nelem_hint);
> +
> +	tbl = bucket_table_alloc(size, GFP_KERNEL);
> +	if (tbl == NULL)
> +		return -ENOMEM;
> +
> +	ht->shift = ilog2(tbl->size);
> +
> +	memset(ht, 0, sizeof(*ht));
Hi Thomas,
I see that ht->shift is being set but then ht is being zeroed, wouldn't this
allow for the table to double ilog2(tbl->size) times more ?

Nik

> +	memcpy(&ht->p, params, sizeof(*params));
> +	RCU_INIT_POINTER(ht->tbl, tbl);
> +
> +	if (!ht->p.hash_rnd)
> +		get_random_bytes(&ht->p.hash_rnd, sizeof(ht->p.hash_rnd));
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(rhashtable_init);
> +
> +/**
> + * rhashtable_destroy - destroy hash table
> + * @ht:		the hash table to destroy
> + *
> + * Frees the bucket array.
> + */
> +void rhashtable_destroy(const struct rhashtable *ht)
> +{
> +	const struct bucket_table *tbl = rht_dereference(ht->tbl, ht);
> +
> +	bucket_table_free(tbl);
> +}
> +EXPORT_SYMBOL_GPL(rhashtable_destroy);
<<snip>>
