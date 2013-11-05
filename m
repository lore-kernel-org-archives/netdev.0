From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: [patch net-next 3/3] fix skb_morph to preserve skb->sk and skb->destructor
 pointers
Date: Tue, 05 Nov 2013 09:50:40 -0200
Message-ID: <5278DB90.1060605@redhat.com>
References: <1383649333-6321-1-git-send-email-jiri@resnulli.us> <1383649333-6321-4-git-send-email-jiri@resnulli.us>
Reply-To: mleitner@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, yoshfuji@linux-ipv6.org,
	kadlec@blackhole.kfki.hu, kaber@trash.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, wensong@linux-vs.org, horms@verge.net.au,
	ja@ssi.bg, edumazet@google.com, pshelar@nicira.com,
	jasowang@redhat.com, alexander.h.duyck@intel.com,
	coreteam@netfilter.org, fw@strlen.de
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2972 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754480Ab3KELvl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Nov 2013 06:51:41 -0500
In-Reply-To: <1383649333-6321-4-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em 05-11-2013 09:02, Jiri Pirko escreveu:
> Currently __skb_clone sets skb->sk and skb->destructor to NULL. This is
> not right for skb_morph use case because skb->sk may be previously
> set (e. g. by xt_TPROXY).
>
> Also, during skb_morph the destructor should not be called. It might be
> previously set, e. g. by xt_TPROXY to sock_edemux, and that would cause
> put sk while skb is still in flight.
>
> This patch fixes these.
>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>

> ---
>   net/core/skbuff.c | 44 +++++++++++++++++++++++++++-----------------
>   1 file changed, 27 insertions(+), 17 deletions(-)
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 3735fad..21b320e 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -515,7 +515,7 @@ static void skb_free_head(struct sk_buff *skb)
>   		kfree(skb->head);
>   }
>
> -static void skb_release_data(struct sk_buff *skb)
> +static void __skb_release_data(struct sk_buff *skb)
>   {
>   	if (!skb->cloned ||
>   	    !atomic_sub_return(skb->nohdr ? (1 << SKB_DATAREF_SHIFT) + 1 : 1,
> @@ -579,16 +579,12 @@ static void kfree_skbmem(struct sk_buff *skb)
>   	}
>   }
>
> -static void skb_release_head_state(struct sk_buff *skb)
> +static void __skb_release_head_state(struct sk_buff *skb)
>   {
>   	skb_dst_drop(skb);
>   #ifdef CONFIG_XFRM
>   	secpath_put(skb->sp);
>   #endif
> -	if (skb->destructor) {
> -		WARN_ON(in_irq());
> -		skb->destructor(skb);
> -	}
>   #if IS_ENABLED(CONFIG_NF_CONNTRACK)
>   	nf_conntrack_put(skb->nfct);
>   #endif
> @@ -607,12 +603,19 @@ static void skb_release_head_state(struct sk_buff *skb)
>   #endif
>   }
>
> -/* Free everything but the sk_buff shell. */
> -static void skb_release_all(struct sk_buff *skb)
> +static void skb_release_head_state(struct sk_buff *skb)
> +{
> +	if (skb->destructor) {
> +		WARN_ON(in_irq());
> +		skb->destructor(skb);
> +	}
> +	__skb_release_head_state(skb);
> +}
> +
> +static void skb_release_data(struct sk_buff *skb)
>   {
> -	skb_release_head_state(skb);
>   	if (likely(skb->head))
> -		skb_release_data(skb);
> +		__skb_release_data(skb);
>   }
>
>   /**
> @@ -626,7 +629,8 @@ static void skb_release_all(struct sk_buff *skb)
>
>   void __kfree_skb(struct sk_buff *skb)
>   {
> -	skb_release_all(skb);
> +	skb_release_head_state(skb);
> +	skb_release_data(skb);
>   	kfree_skbmem(skb);
>   }
>   EXPORT_SYMBOL(__kfree_skb);
> @@ -761,12 +765,11 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
>    * You should not add any new code to this function.  Add it to
>    * __copy_skb_header above instead.
>    */
> -static struct sk_buff *__skb_clone(struct sk_buff *n, struct sk_buff *skb)
> +static struct sk_buff *___skb_clone(struct sk_buff *n, struct sk_buff *skb)
>   {
>   #define C(x) n->x = skb->x
>
>   	n->next = n->prev = NULL;
> -	n->sk = NULL;
>   	__copy_skb_header(n, skb);
>
>   	C(len);
> @@ -775,7 +778,6 @@ static struct sk_buff *__skb_clone(struct sk_buff *n, struct sk_buff *skb)
>   	n->hdr_len = skb->nohdr ? skb_headroom(skb) : skb->hdr_len;
>   	n->cloned = 1;
>   	n->nohdr = 0;
> -	n->destructor = NULL;
>   	C(tail);
>   	C(end);
>   	C(head);
> @@ -791,6 +793,13 @@ static struct sk_buff *__skb_clone(struct sk_buff *n, struct sk_buff *skb)
>   #undef C
>   }
>
> +static struct sk_buff *__skb_clone(struct sk_buff *n, struct sk_buff *skb)
> +{
> +	n->sk = NULL;
> +	n->destructor = NULL;
> +	return ___skb_clone(n, skb);
> +}
> +
>   /**
>    *	skb_morph	-	morph one skb into another
>    *	@dst: the skb to receive the contents
> @@ -803,8 +812,9 @@ static struct sk_buff *__skb_clone(struct sk_buff *n, struct sk_buff *skb)
>    */
>   struct sk_buff *skb_morph(struct sk_buff *dst, struct sk_buff *src)
>   {
> -	skb_release_all(dst);
> -	return __skb_clone(dst, src);
> +	__skb_release_head_state(dst);
> +	skb_release_data(dst);
> +	return ___skb_clone(dst, src);
>   }
>   EXPORT_SYMBOL_GPL(skb_morph);
>
> @@ -1107,7 +1117,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
>   		if (skb_has_frag_list(skb))
>   			skb_clone_fraglist(skb);
>
> -		skb_release_data(skb);
> +		__skb_release_data(skb);
>   	} else {
>   		skb_free_head(skb);
>   	}
>
