From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH net-next-2.6 v2] filter: optimize sk_run_filter
Date: Fri, 19 Nov 2010 23:17:18 +0900
Message-ID: <201011192317.CFB48465.OtLFOJOMHQSFFV@I-love.SAKURA.ne.jp>
References: <1290160467.3034.33.camel@edumazet-laptop>
	<1290165472.3034.109.camel@edumazet-laptop>
	<AANLkTi=ed79a5HjGULPdwuqmUhj=W8BGzRh7tm2L11ef@mail.gmail.com>
	<AANLkTi==Ovw8xFA1K6rVabg9MW0w6wd=2qvo=XojUXpM@mail.gmail.com>
	<1290172607.3034.124.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, hagen@jauu.net, netdev@vger.kernel.org
To: eric.dumazet@gmail.com, xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wine.ocn.ne.jp ([122.1.235.145]:64672 "EHLO smtp.wine.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754378Ab0KSORY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Nov 2010 09:17:24 -0500
In-Reply-To: <1290172607.3034.124.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just my thought again...

Eric Dumazet wrote:
> @@ -167,34 +168,36 @@ unsigned int sk_run_filter(struct sk_buff *skb, struct sock_filter *filter, int
>  	unsigned long memvalid = 0;
>  	u32 tmp;
>  	int k;

Is this 'k' useful?

> -	int pc;
>  
>  	BUILD_BUG_ON(BPF_MEMWORDS > BITS_PER_LONG);
>  	/*
>  	 * Process array of filter instructions.
>  	 */
> -	for (pc = 0; pc < flen; pc++) {
> -		const struct sock_filter *fentry = &filter[pc];
> -		u32 f_k = fentry->k;
> +	for (;; fentry++) {
> +#if defined(CONFIG_X86_32)
> +#define	K (fentry->k)
> +#else
> +		const u32 K = fentry->k;

What happens if we use

	u32 f_k = fentry->k;

and

>  		case BPF_S_LD_W_ABS:
> -			k = f_k;
> +			k = K;

remove this assignment and

>  load_w:
>  			ptr = load_pointer(skb, k, 4, &tmp);

change to

	ptr = load_pointer(skb, (int) f_k, 4, &tmp);

and

>  		case BPF_S_LD_W_IND:
> -			k = X + f_k;
> +			k = X + K;

change to

	f_k += X;

?
>  			goto load_w;
