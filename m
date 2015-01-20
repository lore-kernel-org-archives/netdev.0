From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/3] skbuff: Add skb_list_linearize()
Date: Tue, 20 Jan 2015 13:43:15 -0800
Message-ID: <1421790195.4832.12.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1421785543-19823-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:50110 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751473AbbATVnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 16:43:17 -0500
Received: by mail-ig0-f176.google.com with SMTP id hl2so17679539igb.3
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 13:43:16 -0800 (PST)
In-Reply-To: <1421785543-19823-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-01-20 at 12:25 -0800, Pravin B Shelar wrote:
> similar to skb_linearize(), this API takes skb list as arg and
> linearize it into one big skb. STT driver patch will use this.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
>  include/linux/skbuff.h |  2 ++
>  net/core/skbuff.c      | 35 +++++++++++++++++++++++++++++++++++
>  2 files changed, 37 insertions(+)
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 85ab7d7..c9194c1 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -2532,6 +2532,8 @@ static inline int skb_linearize(struct sk_buff *skb)
>  	return skb_is_nonlinear(skb) ? __skb_linearize(skb) : 0;
>  }
>  
> +int skb_list_linearize(struct sk_buff *head, gfp_t gfp_mask);
> +
>  /**
>   * skb_has_shared_frag - can any frag be overwritten
>   * @skb: buffer to test
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 56db472..9ef2881 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -2329,6 +2329,41 @@ void skb_copy_and_csum_dev(const struct sk_buff *skb, u8 *to)
>  }
>  EXPORT_SYMBOL(skb_copy_and_csum_dev);
>  
> +int skb_list_linearize(struct sk_buff *head, gfp_t gfp_mask)
> +{
> +	struct sk_buff *skb;
> +	int tlen = 0;
> +	int err;
> +
> +	err = skb_linearize(head);
> +	if (err)
> +		return err;
> +
> +	skb = head->next;
> +	while (skb) {
> +		tlen += skb->len;
> +		skb = skb->next;
> +	}
> +	err = pskb_expand_head(head, 0, tlen, gfp_mask);
> +	if (err)
> +		return err;
> +
> +	skb = head->next;
> +	while (skb) {
> +		err = skb_copy_bits(skb, 0, skb_tail_pointer(head), skb->len);
> +		if (err)
> +			return err;
> +		head->tail += skb->len;
> +		skb = skb->next;
> +	}
> +	kfree_skb_list(head->next);
> +	head->next = NULL;
> +	head->len += tlen;
> +	head->truesize = SKB_TRUESIZE(skb_end_offset(head));

This is buggy : skb can have a destructor, like sock_wfree()
