From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 5/9] net: Have xmit_list() signal more==true when
 appropriate.
Date: Tue, 2 Sep 2014 09:25:38 +0200
Message-ID: <20140902092538.7987db64@redhat.com>
References: <20140901.152459.592105486574617399.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9462 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751268AbaIBHZl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Sep 2014 03:25:41 -0400
In-Reply-To: <20140901.152459.592105486574617399.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 01 Sep 2014 15:24:59 -0700 (PDT) David Miller <davem@davemloft.net> wrote:

> diff --git a/net/core/dev.c b/net/core/dev.c
> index f0ed5a6..6d82194 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2600,7 +2600,7 @@ netdev_features_t netif_skb_features(struct sk_buff *skb)
>  EXPORT_SYMBOL(netif_skb_features);
>  
>  static int xmit_one(struct sk_buff *skb, struct net_device *dev,
> -		    struct netdev_queue *txq)
> +		    struct netdev_queue *txq, bool more)
>  {
>  	unsigned int len;
>  	int rc;
> @@ -2610,7 +2610,7 @@ static int xmit_one(struct sk_buff *skb, struct net_device *dev,
>  
>  	len = skb->len;
>  	trace_net_dev_start_xmit(skb, dev);
> -	rc = netdev_start_xmit(skb, dev, txq, false);
> +	rc = netdev_start_xmit(skb, dev, txq, more);
>
>  	trace_net_dev_xmit(skb, rc, dev, len);
>  
>  	return rc;
> @@ -2626,7 +2626,7 @@ static struct sk_buff *xmit_list(struct sk_buff *first, struct net_device *dev,
>  		struct sk_buff *next = skb->next;
>  
>  		skb->next = NULL;
> -		rc = xmit_one(skb, dev, txq);
> +		rc = xmit_one(skb, dev, txq, next != NULL);

Guess, the caller constructing the skb list to xmit_list() must make
sure all SKBs have the same TXQ.


>  		if (unlikely(!dev_xmit_complete(rc))) {
>  			skb->next = next;
>  			goto out;

In the exit case (!dev_xmit_complete(rc)) is it,
1. the responsibility of the driver to "flush" the tail, or
2. do we depend on qdisc or softirq to be reactivated soonish?

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
