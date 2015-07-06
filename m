From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] rhashtable: fix for resize events during table walk
Date: Mon, 6 Jul 2015 21:30:40 +0800
Message-ID: <20150706133040.GA22723@gondor.apana.org.au>
References: <1436184102-19175-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, sparclinux@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, daniel@iogearbox.net, geert@linux-m68k.org,
	mroos@linux.ee
To: Phil Sutter <phil@nwl.cc>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1436184102-19175-1-git-send-email-phil@nwl.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 06, 2015 at 02:01:42PM +0200, Phil Sutter wrote:
> If rhashtable_walk_next detects a resize operation in progress, it jumps
> to the new table and continues walking that one. But it misses to drop
> the reference to it's current item, leading it to continue traversing
> the new table's bucket in which the current item is sorted into, and
> after reaching that bucket's end continues traversing the new table's
> second bucket instead of the first one, thereby potentially missing
> items.
> 
> This fixes the rhashtable runtime test for me. Bug probably introduced
> by Herbert Xu's patch eddee5ba ("rhashtable: Fix walker behaviour during
> rehash") although not explicitly tested.
> 
> Fixes: eddee5ba ("rhashtable: Fix walker behaviour during rehash")
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Good catch!

> diff --git a/lib/rhashtable.c b/lib/rhashtable.c
> index a60a6d3..e36b94b 100644
> --- a/lib/rhashtable.c
> +++ b/lib/rhashtable.c
> @@ -585,6 +585,7 @@ void *rhashtable_walk_next(struct rhashtable_iter *iter)
>  	struct bucket_table *tbl = iter->walker->tbl;
>  	struct rhashtable *ht = iter->ht;
>  	struct rhash_head *p = iter->p;
> +	void *rc = NULL;
>  
>  	if (p) {
>  		p = rht_dereference_bucket_rcu(p->next, tbl, iter->slot);
> @@ -617,12 +618,12 @@ next:
>  	if (iter->walker->tbl) {
>  		iter->slot = 0;
>  		iter->skip = 0;
> -		return ERR_PTR(-EAGAIN);
> +		rc = ERR_PTR(-EAGAIN);
>  	}
>  
>  	iter->p = NULL;

I think a simpler fix would be to move "iter->p = NULL" before
the if statement.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
