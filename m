From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: fix the race when initializing nf_ct_expect_hash_rnd
Date: Wed, 15 Dec 2010 23:16:33 +0100
Message-ID: <4D093E41.2010306@trash.net>
References: <1291566397-24318-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1291566397-24318-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 05.12.2010 17:26, schrieb Changli Gao:
> Since nf_ct_expect_dst_hash() may be called without nf_conntrack_lock
> locked, nf_ct_expect_hash_rnd should be initialized in the atomic way.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ---
>  net/netfilter/nf_conntrack_expect.c |   12 +++++++-----
>  1 file changed, 7 insertions(+), 5 deletions(-)
> diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
> index 46e8966..e2bb3ef 100644
> --- a/net/netfilter/nf_conntrack_expect.c
> +++ b/net/netfilter/nf_conntrack_expect.c
> @@ -34,7 +34,6 @@ EXPORT_SYMBOL_GPL(nf_ct_expect_hsize);
>  
>  static unsigned int nf_ct_expect_hash_rnd __read_mostly;
>  unsigned int nf_ct_expect_max __read_mostly;
> -static int nf_ct_expect_hash_rnd_initted __read_mostly;
>  
>  static struct kmem_cache *nf_ct_expect_cachep __read_mostly;
>  
> @@ -77,10 +76,13 @@ static unsigned int nf_ct_expect_dst_hash(const struct nf_conntrack_tuple *tuple
>  {
>  	unsigned int hash;
>  
> -	if (unlikely(!nf_ct_expect_hash_rnd_initted)) {
> -		get_random_bytes(&nf_ct_expect_hash_rnd,
> -				 sizeof(nf_ct_expect_hash_rnd));
> -		nf_ct_expect_hash_rnd_initted = 1;
> +	if (unlikely(!nf_ct_expect_hash_rnd)) {
> +		unsigned int rand;
> +
> +		do {
> +			get_random_bytes(&rand, sizeof(rand));
> +		} while (!rand);
> +		cmpxchg(&nf_ct_expect_hash_rnd, 0, rand);
>  	}

I'd rather just re-use the conntrack hash random value.
