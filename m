From: James Morris <jmorris@namei.org>
Subject: Re: [RFC PATCH v2 1/2] NET: Clone the sk_buff 'iif' field in
 __skb_clone()
Date: Tue, 8 Jan 2008 08:11:11 +1100 (EST)
Message-ID: <Xine.LNX.4.64.0801080810010.15645@us.intercode.com.au>
References: <20080107173829.13488.47471.stgit@flek.americas.hpqcorp.net>
 <20080107174741.13488.93482.stgit@flek.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from namei.org ([69.55.235.186]:34004 "EHLO us.intercode.com.au"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752951AbYAGVLY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jan 2008 16:11:24 -0500
In-Reply-To: <20080107174741.13488.93482.stgit@flek.americas.hpqcorp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 7 Jan 2008, Paul Moore wrote:

> Both NetLabel and SELinux (other LSMs may grow to use it as well) rely on the
> 'iif' field to determine the receiving network interface of inbound packets.
> Unfortunately, at present this field is not preserved across a skb clone
> operation which can lead to garbage values if the cloned skb is sent back
> through the network stack.  This patch corrects this problem by properly
> copying the 'iif' field in __skb_clone() and removing the 'iif' field
> assignment from skb_act_clone() since it is no longer needed.
> 
> Also, while we are here, put the assignments in the same order as the offsets
> to reduce cacheline bounces.
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>

Dave, perhaps this one should pushed to Linus now as a bugfix?

> ---
> 
>  include/net/sch_generic.h |    1 -
>  net/core/skbuff.c         |   11 ++++++-----
>  2 files changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index c926551..4c3b351 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -325,7 +325,6 @@ static inline struct sk_buff *skb_act_clone(struct sk_buff *skb, gfp_t gfp_mask)
>  		n->tc_verd = SET_TC_VERD(n->tc_verd, 0);
>  		n->tc_verd = CLR_TC_OK2MUNGE(n->tc_verd);
>  		n->tc_verd = CLR_TC_MUNGED(n->tc_verd);
> -		n->iif = skb->iif;
>  	}
>  	return n;
>  }
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 5b4ce9b..b628377 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -416,16 +416,17 @@ static struct sk_buff *__skb_clone(struct sk_buff *n, struct sk_buff *skb)
>  	C(len);
>  	C(data_len);
>  	C(mac_len);
> -	n->cloned = 1;
>  	n->hdr_len = skb->nohdr ? skb_headroom(skb) : skb->hdr_len;
> +	n->cloned = 1;
>  	n->nohdr = 0;
>  	n->destructor = NULL;
> -	C(truesize);
> -	atomic_set(&n->users, 1);
> -	C(head);
> -	C(data);
> +	C(iif);
>  	C(tail);
>  	C(end);
> +	C(head);
> +	C(data);
> +	C(truesize);
> +	atomic_set(&n->users, 1);
>  
>  	atomic_inc(&(skb_shinfo(skb)->dataref));
>  	skb->cloned = 1;
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
James Morris
<jmorris@namei.org>
