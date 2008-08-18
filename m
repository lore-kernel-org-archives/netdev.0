From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Mon, 18 Aug 2008 14:27:31 +1000
Message-ID: <20080818042731.GA32637@gondor.apana.org.au>
References: <20080818012516.GB31337@gondor.apana.org.au> <20080817.183505.163224950.davem@davemloft.net> <20080818013633.GA31653@gondor.apana.org.au> <20080817.184921.08829673.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:60186 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750732AbYHRE1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 00:27:38 -0400
Content-Disposition: inline
In-Reply-To: <20080817.184921.08829673.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 17, 2008 at 06:49:21PM -0700, David Miller wrote:
> 
> The test being added to __netif_schedule() is just a reminder that
> we have to address the "both bits clear" case somehow, likely with
> Jarko's patch which I unintentionally reimplemented :)

The patch looks good to me.

> @@ -1790,6 +1793,8 @@ gso:
>  	rcu_read_lock_bh();
>  
>  	txq = dev_pick_tx(dev, skb);
> +
> +resample_qdisc:
>  	q = rcu_dereference(txq->qdisc);
>  
>  #ifdef CONFIG_NET_CLS_ACT
> @@ -1800,6 +1805,11 @@ gso:
>  
>  		spin_lock(root_lock);
>  
> +		if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state))) {
> +			spin_unlock(root_lock);
> +			goto resample_qdisc;
> +		}

We could just drop the packet.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
