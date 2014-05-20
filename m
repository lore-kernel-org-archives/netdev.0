From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] Fixed zero copy GSO without orphaning the fragments
Date: Tue, 20 May 2014 14:50:47 +0300
Message-ID: <20140520115047.GB29805@redhat.com>
References: <1400585062-13580-1-git-send-email-igorr@swortex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Tom Herbert <therbert@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Simon Horman <horms@verge.net.au>,
	Joe Perches <joe@perches.com>, Jiri Pirko <jiri@resnulli.us>,
	Florian Westphal <fw@strlen.de>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	Thomas Graf <tgraf@suug.ch>, Jan Beulich <JBeulich@suse.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Miklos Szeredi <mszeredi@suse.cz>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Anton Nayshtut <anton@swortex.com>
To: Igor Royzis <igorr@swortex.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1400585062-13580-1-git-send-email-igorr@swortex.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 20, 2014 at 02:24:21PM +0300, Igor Royzis wrote:
> Fix accessing GSO fragments memory (and a possible corruption therefore) after
> reporting completion in a zero copy callback. The previous fix in the commit 1fd819ec
> orphaned frags which eliminates zero copy advantages. The fix makes the completion
> called after all the fragments were processed avoiding unnecessary orphaning/copying
> from userspace.
> 
> The GSO fragments corruption issue was observed in a typical QEMU/KVM VM setup that
> hosts a Windows guest (since QEMU virtio-net Windows driver doesn't support GRO).
> The fix has been verified by running the HCK OffloadLSO test.
> 
> Signed-off-by: Igor Royzis <igorr@swortex.com>
> Signed-off-by: Anton Nayshtut <anton@swortex.com>

OK but with 1fd819ec there's no corruption, correct?
So this patch is in fact an optimization?
If true, I'd like to see some performance numbers please.

Thanks!

> ---
>  include/linux/skbuff.h |    1 +
>  net/core/skbuff.c      |   18 +++++++++++++-----
>  2 files changed, 14 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 08074a8..8c49edc 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -287,6 +287,7 @@ struct skb_shared_info {
>  	struct sk_buff	*frag_list;
>  	struct skb_shared_hwtstamps hwtstamps;
>  	__be32          ip6_frag_id;
> +	struct sk_buff  *zcopy_src;
>  
>  	/*
>  	 * Warning : all fields before dataref are cleared in __alloc_skb()
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 1b62343..6fa6342 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -610,14 +610,18 @@ EXPORT_SYMBOL(__kfree_skb);
>   */
>  void kfree_skb(struct sk_buff *skb)
>  {
> +	struct sk_buff *zcopy_src;
>  	if (unlikely(!skb))
>  		return;
>  	if (likely(atomic_read(&skb->users) == 1))
>  		smp_rmb();
>  	else if (likely(!atomic_dec_and_test(&skb->users)))
>  		return;
> +	zcopy_src = skb_shinfo(skb)->zcopy_src;
>  	trace_kfree_skb(skb, __builtin_return_address(0));
>  	__kfree_skb(skb);
> +	if (unlikely(zcopy_src))
> +		kfree_skb(zcopy_src);
>  }
>  EXPORT_SYMBOL(kfree_skb);
>  
> @@ -662,14 +666,18 @@ EXPORT_SYMBOL(skb_tx_error);
>   */
>  void consume_skb(struct sk_buff *skb)
>  {
> +	struct sk_buff *zcopy_src;
>  	if (unlikely(!skb))
>  		return;
>  	if (likely(atomic_read(&skb->users) == 1))
>  		smp_rmb();
>  	else if (likely(!atomic_dec_and_test(&skb->users)))
>  		return;
> +	zcopy_src = skb_shinfo(skb)->zcopy_src;
>  	trace_consume_skb(skb);
>  	__kfree_skb(skb);
> +	if (unlikely(zcopy_src))
> +		consume_skb(zcopy_src);
>  }
>  EXPORT_SYMBOL(consume_skb);
>  
> @@ -2867,7 +2875,6 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
>  	skb_frag_t *frag = skb_shinfo(head_skb)->frags;
>  	unsigned int mss = skb_shinfo(head_skb)->gso_size;
>  	unsigned int doffset = head_skb->data - skb_mac_header(head_skb);
> -	struct sk_buff *frag_skb = head_skb;
>  	unsigned int offset = doffset;
>  	unsigned int tnl_hlen = skb_tnl_header_len(head_skb);
>  	unsigned int headroom;
> @@ -2913,7 +2920,6 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
>  			i = 0;
>  			nfrags = skb_shinfo(list_skb)->nr_frags;
>  			frag = skb_shinfo(list_skb)->frags;
> -			frag_skb = list_skb;
>  			pos += skb_headlen(list_skb);
>  
>  			while (pos < offset + len) {
> @@ -2975,6 +2981,11 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
>  						 nskb->data - tnl_hlen,
>  						 doffset + tnl_hlen);
>  
> +		if (skb_shinfo(head_skb)->tx_flags & SKBTX_DEV_ZEROCOPY) {
> +			skb_shinfo(nskb)->zcopy_src = head_skb;
> +			atomic_inc(&head_skb->users);
> +		}
> +
>  		if (nskb->len == len + doffset)
>  			goto perform_csum_check;
>  
> @@ -3001,7 +3012,6 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
>  				i = 0;
>  				nfrags = skb_shinfo(list_skb)->nr_frags;
>  				frag = skb_shinfo(list_skb)->frags;
> -				frag_skb = list_skb;
>  
>  				BUG_ON(!nfrags);
>  
> @@ -3016,8 +3026,6 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
>  				goto err;
>  			}
>  
> -			if (unlikely(skb_orphan_frags(frag_skb, GFP_ATOMIC)))
> -				goto err;
>  
>  			*nskb_frag = *frag;
>  			__skb_frag_ref(nskb_frag);
> -- 
> 1.7.9.5
