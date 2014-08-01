From: Nikolay Aleksandrov <nikolay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next 3/3] nftables: Convert nft_hash to
 use generic rhashtable
Date: Fri, 01 Aug 2014 14:21:31 +0200
Message-ID: <53DB864B.2070205@redhat.com>
References: <cover.1406891028.git.tgraf@suug.ch>
 <bd4d9fa542072358cb0bd77e493ec5785a1d9666.1406891028.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org,
 netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org,
 paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, walpole-sKt6ljEC1JY3uPMLIKxrzw@public.gmane.org
To: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <bd4d9fa542072358cb0bd77e493ec5785a1d9666.1406891028.git.tgraf-G/eBtMaohhA@public.gmane.org>
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

On 08/01/2014 01:58 PM, Thomas Graf wrote:
> The sizing of the hash table and the practice of requiring a lookup
> to retrieve the pprev to be stored in the element cookie before the
> deletion of an entry is left intact.
> 
> Signed-off-by: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
> Acked-by: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
> ---
<<snip>>
> @@ -257,36 +82,28 @@ static void nft_hash_elem_destroy(const struct nft_set *set,
>  static void nft_hash_remove(const struct nft_set *set,
>  			    const struct nft_set_elem *elem)
>  {
> -	struct nft_hash *priv = nft_set_priv(set);
> -	struct nft_hash_table *tbl = nft_dereference(priv->tbl);
> -	struct nft_hash_elem *he, __rcu **pprev;
> +	struct rhashtable *priv = nft_set_priv(set);
> +	struct rhash_head *he, __rcu **pprev;
>  
>  	pprev = elem->cookie;
> -	he = nft_dereference((*pprev));
> -
> -	RCU_INIT_POINTER(*pprev, he->next);
> -	synchronize_rcu();
> -	kfree(he);
> +	he = rht_dereference((*pprev), priv);
>  
> -	/* Shrink table beneath 30% load */
> -	if (set->nelems - 1 < tbl->size * 3 / 10 &&
> -	    tbl->size > NFT_HASH_MIN_SIZE)
> -		nft_hash_tbl_shrink(set, priv);
> +	rhashtable_remove_pprev(priv, he, pprev, GFP_KERNEL);
>  }
<<snip>>
Hi again,
Sorry for the late response but I just got around to check the 3rd patch now,
so my question about this fragment is: before nft_hash_remove() would free the
element after removal, but after this change I don't see where and when the
removed element would get freed ?

Nik
