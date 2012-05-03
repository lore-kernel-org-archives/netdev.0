From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH net-next] net: Fix truesize accounting in skb_gro_receive()
Date: Thu, 03 May 2012 03:48:52 -0700
Message-ID: <4FA26294.9080900@intel.com>
References: <20120503071141.13636.37564.stgit@gitlad.jf.intel.com>	 <20120503071859.13636.30050.stgit@gitlad.jf.intel.com> <1336037601.3752.8.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:47108 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756194Ab2ECKn6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2012 06:43:58 -0400
In-Reply-To: <1336037601.3752.8.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/03/2012 02:33 AM, Eric Dumazet wrote:
> From: Eric Dumazet<edumazet@google.com>
>
> GRO is very optimistic in skb truesize estimates, only taking into
> account the used part of fragments.
>
> Be conservative, and use more precise computation, so that bloated GRO
> skbs can be collapsed eventually.
>
> Signed-off-by: Eric Dumazet<edumazet@google.com>
> Cc: Alexander Duyck<alexander.h.duyck@intel.com>
> Cc: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
> ---
>   net/core/skbuff.c |   11 ++++++++---
>   1 file changed, 8 insertions(+), 3 deletions(-)
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 9e8caa0..e1f8bba 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -2871,6 +2871,7 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
>   	unsigned int len = skb_gro_len(skb);
>   	unsigned int offset = skb_gro_offset(skb);
>   	unsigned int headlen = skb_headlen(skb);
> +	unsigned int delta_truesize;
>
>   	if (p->len + len>= 65536)
>   		return -E2BIG;
> @@ -2900,11 +2901,14 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
>   		frag->page_offset += offset;
>   		skb_frag_size_sub(frag, offset);
>
> +		/* all fragments truesize : remove (head size + sk_buff) */
> +		delta_truesize = skb->truesize - SKB_TRUESIZE(skb_end_pointer(skb) - skb->head);
> +
>   		skb->truesize -= skb->data_len;
>   		skb->len -= skb->data_len;
>   		skb->data_len = 0;
>
> -		NAPI_GRO_CB(skb)->free = 1;
> +		NAPI_GRO_CB(skb)->free = NAPI_GRO_FREE;
>   		goto done;
>   	} else if (skb->head_frag) {
>   		int nr_frags = pinfo->nr_frags;
> @@ -2929,6 +2933,7 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
>   		memcpy(frag + 1, skbinfo->frags, sizeof(*frag) * skbinfo->nr_frags);
>   		/* We dont need to clear skbinfo->nr_frags here */
>
> +		delta_truesize = skb->truesize - SKB_DATA_ALIGN(sizeof(struct sk_buff));
>   		NAPI_GRO_CB(skb)->free = NAPI_GRO_FREE_STOLEN_HEAD;
>   		goto done;
>   	} else if (skb_gro_len(p) != pinfo->gso_size)
> @@ -2971,7 +2976,7 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
>   	p = nskb;
>
>   merge:
> -	p->truesize += skb->truesize - len;
> +	delta_truesize = skb->truesize;
>   	if (offset>  headlen) {
>   		unsigned int eat = offset - headlen;
>
> @@ -2991,7 +2996,7 @@ merge:
>   done:
>   	NAPI_GRO_CB(p)->count++;
>   	p->data_len += len;
> -	p->truesize += len;
> +	p->truesize += delta_truesize;
>   	p->len += len;
>
>   	NAPI_GRO_CB(skb)->same_flow = 1;
>
>
Couldn't sleep so I figured I would review some patches and maybe get a 
few more written before the sun came up.   I was actually thinking of 
trying to get to this before I logged in.  Looks like you have this one 
taken care of already so I will go take care of skb_head_is_locked.

Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
