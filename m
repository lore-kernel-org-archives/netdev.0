From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: Fix skb csum races when peeking
Date: Tue, 14 Jul 2015 08:11:53 +0200
Message-ID: <1436854313.1374.5.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150710115141.12980.88829.stgit@buzz>
	 <20150713072352.GA8485@gondor.apana.org.au>
	 <1436774742.9402.3.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150713081040.GB8971@gondor.apana.org.au>
	 <1436775754.9402.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150713082544.GA9176@gondor.apana.org.au>
	 <CANn89iLFCJWqmfvwOUB_7VUk_7jHHvOHZR6=fufDr848thSrHQ@mail.gmail.com>
	 <20150713083100.GA9263@gondor.apana.org.au>
	 <20150713120142.GA9787@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:34815 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752155AbbGNGL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 02:11:57 -0400
Received: by wgkl9 with SMTP id l9so23276wgk.1
        for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 23:11:56 -0700 (PDT)
In-Reply-To: <20150713120142.GA9787@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-07-13 at 20:01 +0800, Herbert Xu wrote:

> ---8<---
> When we calculate the checksum on the recv path, we store the
> result in the skb as an optimisation in case we need the checksum
> again down the line.
> 
> This is in fact bogus for the MSG_PEEK case as this is done without
> any locking.  So multiple threads can peek and then store the result
> to the same skb, potentially resulting in bogus skb states.
> 
> This patch fixes this by only storing the result if the skb is not
> shared.  This preserves the optimisations for the few cases where
> it can be done safely due to locking or other reasons, e.g., SIOCINQ.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> diff --git a/net/core/datagram.c b/net/core/datagram.c
> index b80fb91..4967262 100644
> --- a/net/core/datagram.c
> +++ b/net/core/datagram.c
> @@ -622,7 +657,8 @@ __sum16 __skb_checksum_complete_head(struct sk_buff *skb, int len)
>  		    !skb->csum_complete_sw)
>  			netdev_rx_csum_fault(skb->dev);
>  	}
> -	skb->csum_valid = !sum;
> +	if (!skb_shared(skb))
> +		skb->csum_valid = !sum;
>  	return sum;
>  }
>  EXPORT_SYMBOL(__skb_checksum_complete_head);
> @@ -642,11 +678,13 @@ __sum16 __skb_checksum_complete(struct sk_buff *skb)
>  			netdev_rx_csum_fault(skb->dev);
>  	}
>  
> -	/* Save full packet checksum */
> -	skb->csum = csum;
> -	skb->ip_summed = CHECKSUM_COMPLETE;
> -	skb->csum_complete_sw = 1;
> -	skb->csum_valid = !sum;
> +	if (!skb_shared(skb)) {
> +		/* Save full packet checksum */
> +		skb->csum = csum;
> +		skb->ip_summed = CHECKSUM_COMPLETE;
> +		skb->csum_complete_sw = 1;
> +		skb->csum_valid = !sum;
> +	}
>  
>  	return sum;
>  }

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
