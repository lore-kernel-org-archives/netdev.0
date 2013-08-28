From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 8/8] xfrm: Fix potential null pointer dereference in
 xdst_queue_output
Date: Wed, 28 Aug 2013 04:36:27 -0700
Message-ID: <1377689787.8828.179.camel@edumazet-glaptop>
References: <1377687895-5780-1-git-send-email-steffen.klassert@secunet.com>
	 <1377687895-5780-9-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:46859 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753664Ab3H1Lga (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 07:36:30 -0400
Received: by mail-pa0-f47.google.com with SMTP id kl13so6129865pab.34
        for <netdev@vger.kernel.org>; Wed, 28 Aug 2013 04:36:29 -0700 (PDT)
In-Reply-To: <1377687895-5780-9-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-08-28 at 13:04 +0200, Steffen Klassert wrote:
> The net_device might be not set on the skb when we try refcounting.
> This leads to a null pointer dereference in xdst_queue_output().
> It turned out that the refcount to the net_device is not needed
> after all. The dst_entry has a refcount to the net_device before
> we queue the skb, so it can't go away. Therefore we can remove the
> refcount on queueing to fix the null pointer dereference.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>  net/xfrm/xfrm_policy.c |    9 +--------
>  1 file changed, 1 insertion(+), 8 deletions(-)
> 
> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> index e52cab3..f77c371 100644
> --- a/net/xfrm/xfrm_policy.c
> +++ b/net/xfrm/xfrm_policy.c
> @@ -320,10 +320,8 @@ static void xfrm_queue_purge(struct sk_buff_head *list)
>  {
>  	struct sk_buff *skb;
>  
> -	while ((skb = skb_dequeue(list)) != NULL) {
> -		dev_put(skb->dev);
> +	while ((skb = skb_dequeue(list)) != NULL)
>  		kfree_skb(skb);
> -	}
>  }
>  

xfrm_queue_purge() now looks a lot like skb_queue_purge() ;)
