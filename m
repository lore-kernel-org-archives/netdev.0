From: Prashant Sreedharan <prashant@broadcom.com>
Subject: Re: [PATCH v2 3/3] tg3: Fix tx_pending checks for tg3_tso_bug
Date: Fri, 22 Aug 2014 16:17:27 -0700
Message-ID: <1408749447.8268.53.camel@prashant>
References: <1408658240-6811-1-git-send-email-bpoirier@suse.de>
	 <1408658240-6811-3-git-send-email-bpoirier@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Benjamin Poirier <bpoirier@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408658240-6811-3-git-send-email-bpoirier@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Benjamin, thanks for the patch. Broadcom QA will be testing the changes.
Couple of comments below.
>  	segs = skb_gso_segment(skb, tp->dev->features &
>  				    ~(NETIF_F_TSO | NETIF_F_TSO6));
> -	if (IS_ERR(segs) || !segs)
> +	if (IS_ERR_OR_NULL(segs))
>  		goto tg3_tso_bug_end;
>  
>  	do {
> +		unsigned int desc_cnt = skb_shinfo(segs)->nr_frags + 1;
> +
>  		nskb = segs;
>  		segs = segs->next;
>  		nskb->next = NULL;
> -		tg3_start_xmit(nskb, tp->dev);
> +
> +		if (tg3_tx_avail(tnapi) <= segs_remaining - 1 + desc_cnt &&
> +		    skb_linearize(nskb)) {
> +			nskb->next = segs;
> +			segs = nskb;
> +			do {
> +				nskb = segs->next;
> +
> +				dev_kfree_skb_any(segs);
> +				segs = nskb;
> +			} while (segs);

If skb_linearize() fails need to increment the tp->tx_dropped count

> +			goto tg3_tso_bug_end;
> +		}
> +		segs_remaining--;
> +		if (segs_remaining)
> +			__tg3_start_xmit(nskb, tp->dev, segs_remaining);

To clarify passing segs_remaining will make sure the queue is never
stopped correct ?

> +		else
> +			tg3_start_xmit(nskb, tp->dev);
>  	} while (segs);
>  
