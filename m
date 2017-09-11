From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH] netfilter: ipset: ipset list may return wrong member
 count for set with timeout
Date: Mon, 11 Sep 2017 21:36:38 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1709112134060.12411@blackhole.kfki.hu>
References: <1502947435-18549-1-git-send-email-vpai@akamai.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, johunt@akamai.com,
        pai.vishwain@gmail.com, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org
To: Vishwanath Pai <vpai@akamai.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1502947435-18549-1-git-send-email-vpai@akamai.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Your patch is applied in the ipset git tree and I'm going to push it for 
kernel inclusion.

I modified the comment part: the elements counter can still be incorrect 
in the case of a huge set, because elements might time out during the 
listing.

Thanks for your patience!

Best regards,
Jozsef

On Thu, 17 Aug 2017, Vishwanath Pai wrote:

> Simple testcase:
> 
> $ ipset create test hash:ip timeout 5
> $ ipset add test 1.2.3.4
> $ ipset add test 1.2.2.2
> $ sleep 5
> 
> $ ipset l
> Name: test
> Type: hash:ip
> Revision: 5
> Header: family inet hashsize 1024 maxelem 65536 timeout 5
> Size in memory: 296
> References: 0
> Number of entries: 2
> Members:
> 
> We return "Number of entries: 2" but no members are listed. That is
> because mtype_list runs "ip_set_timeout_expired" and does not list the
> expired entries, but set->elements is never upated (until mtype_gc
> cleans it up later).
> 
> Reviewed-by: Joshua Hunt <johunt@akamai.com>
> Signed-off-by: Vishwanath Pai <vpai@akamai.com>
> ---
>  net/netfilter/ipset/ip_set_hash_gen.h | 12 +++++++++++-
>  1 file changed, 11 insertions(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
> index f236c0b..ff3d31c 100644
> --- a/net/netfilter/ipset/ip_set_hash_gen.h
> +++ b/net/netfilter/ipset/ip_set_hash_gen.h
> @@ -1041,12 +1041,22 @@ struct htype {
>  static int
>  mtype_head(struct ip_set *set, struct sk_buff *skb)
>  {
> -	const struct htype *h = set->data;
> +	struct htype *h = set->data;
>  	const struct htable *t;
>  	struct nlattr *nested;
>  	size_t memsize;
>  	u8 htable_bits;
>  
> +	/* If any members have expired, set->elements will be wrong
> +	 * mytype_expire function will update it with the right count.
> +	 * we do not hold set->lock here, so grab it first.
> +	 */
> +	if (SET_WITH_TIMEOUT(set)) {
> +		spin_lock_bh(&set->lock);
> +		mtype_expire(set, h);
> +		spin_unlock_bh(&set->lock);
> +	}
> +
>  	rcu_read_lock_bh();
>  	t = rcu_dereference_bh_nfnl(h->table);
>  	memsize = mtype_ahash_memsize(h, t) + set->ext_size;
> -- 
> 1.9.1
> 
> 

-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
