From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH -next 2/3] net: sched: remove AT INGRESS/EGRESS
Date: Fri, 15 May 2015 09:23:21 -0700
Message-ID: <20150515162319.GA8234@Alexeis-MBP.westell.com>
References: <1431679850-31896-1-git-send-email-fw@strlen.de>
 <1431679850-31896-3-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, daniel@iogearbox.net
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:36629 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934533AbbEOQXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 12:23:23 -0400
Received: by igbpi8 with SMTP id pi8so227319934igb.1
        for <netdev@vger.kernel.org>; Fri, 15 May 2015 09:23:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1431679850-31896-3-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 15, 2015 at 10:50:49AM +0200, Florian Westphal wrote:
>  
>  enum skb_tc_state {
> +	TC_NO_STATE = 0, /* must be 0 */
> +
>  	/* set by act_mirred to tell IFB that skb needs to be ... */
>  	TC_FROM_INGRESS = 1, /* ... re-injected to local stack */
>  	TC_FROM_EGRESS = 2,  /* ... transmitted to device */
> +
> +	/* used by act_mirred to learn its called during skb rx processing
> +	 * and has to push back the (already pulled) l2 header.
> +	 */
> +	TC_AT_INGRESS = 3,
>  };
>  
...
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 0e7afef..802b9b9 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3071,9 +3071,6 @@ static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
>  	txq = netdev_pick_tx(dev, skb, accel_priv);
>  	q = rcu_dereference_bh(txq->qdisc);
>  
> -#ifdef CONFIG_NET_CLS_ACT
> -	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_EGRESS);
> -#endif

I don't think it's a good change.
Squeezing 4 bits into 2 by losing AT_STACK condition, imo, is wrong.
Before ifb could differentiate AT_STACK and AT_EGRESS, but when
they're aliased we lose this information.
I think we should keep AT_STACK, AT_INGRESS, AT_EGRESS.
