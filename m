From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH RFC ipsec-next 1/2] net: Drop secpath on free after gro
 merge.
Date: Thu, 26 Jan 2017 09:52:17 +0100
Message-ID: <20170126085217.GH30338@gauss.secunet.com>
References: <1485413456-31197-1-git-send-email-steffen.klassert@secunet.com>
 <1485413456-31197-2-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Ilan Tayari <ilant@mellanox.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:39240 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753106AbdAZIwV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Jan 2017 03:52:21 -0500
Content-Disposition: inline
In-Reply-To: <1485413456-31197-2-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 26, 2017 at 07:50:55AM +0100, Steffen Klassert wrote:
> With a followup patch, a gro merged skb can have a secpath.
> So drop it before freeing or reusing the skb.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>  net/core/dev.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 56818f7..c9e541e 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4623,6 +4623,7 @@ static gro_result_t napi_skb_finish(gro_result_t ret, struct sk_buff *skb)
>  	case GRO_MERGED_FREE:
>  		if (NAPI_GRO_CB(skb)->free == NAPI_GRO_FREE_STOLEN_HEAD) {
>  			skb_dst_drop(skb);
> +			secpath_put(skb->sp);
>  			kmem_cache_free(skbuff_head_cache, skb);
>  		} else {
>  			__kfree_skb(skb);
> @@ -4663,6 +4664,7 @@ static void napi_reuse_skb(struct napi_struct *napi, struct sk_buff *skb)
>  	skb->encapsulation = 0;
>  	skb_shinfo(skb)->gso_type = 0;
>  	skb->truesize = SKB_TRUESIZE(skb_end_offset(skb));
> +	secpath_put(skb->sp);

I have to use secpath_reset(skb) here of course.
skb->sp is not even defined if CONFIG_XFRM is not set.

Thanks to "kbuild test robot <lkp@intel.com>" for
pointing to that.
