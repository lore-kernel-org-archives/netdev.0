From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next 2/2] macvtap: Perform GSO on forwarding path.
Date: Wed, 19 Jun 2013 18:30:47 +0300
Message-ID: <20130619153047.GB12619@redhat.com>
References: <1371653272-11703-1-git-send-email-vyasevic@redhat.com>
 <1371653272-11703-3-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jasowang@redhat.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39886 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756860Ab3FSQ1q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jun 2013 12:27:46 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r5JGRkea006424
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 12:27:46 -0400
Content-Disposition: inline
In-Reply-To: <1371653272-11703-3-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 19, 2013 at 10:47:52AM -0400, Vlad Yasevich wrote:
> When macvtap forwards skb to its tap, it needs to check
> if GSO needs to be performed.  This is necessary
> when the HW device performed GRO, but the guest reading
> from the tap does not support it (ex: Windows 7).
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
>  drivers/net/macvtap.c | 26 +++++++++++++++++++++++++-
>  1 file changed, 25 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index 09f0b1f..698f613 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -291,13 +291,37 @@ static void macvtap_del_queues(struct net_device *dev)
>  static int macvtap_forward(struct net_device *dev, struct sk_buff *skb)
>  {
>  	struct macvtap_queue *q = macvtap_get_queue(dev, skb);
> +	netdev_features_t features;
>  	if (!q)
>  		goto drop;
>  
>  	if (skb_queue_len(&q->sk.sk_receive_queue) >= dev->tx_queue_len)
>  		goto drop;
>  
> -	skb_queue_tail(&q->sk.sk_receive_queue, skb);
> +	features = netif_skb_features(skb);

Confused. skb->dev here points to the source macvlan
so features are wrong - we need destination features, no?

> +	if (netif_needs_gso(skb, features)) {
> +		struct sk_buff *segs = skb_gso_segment(skb, features);

I'd prefer a different name for this variable.
skb_seg?

> +
> +		if (IS_ERR(segs))
> +			goto drop;
> +
> +		if (!segs) {
> +			skb_queue_tail(&q->sk.sk_receive_queue, skb);
> +			goto wake_up;
> +		}
> +
> +		kfree_skb(skb);
> +		while (segs) {
> +			struct sk_buff *nskb = segs->next;
> +
> +			segs->next = NULL;
> +			skb_queue_tail(&q->sk.sk_receive_queue, segs);
> +			segs = nskb;
> +		}


> +	} else
> +		skb_queue_tail(&q->sk.sk_receive_queue, skb);
> +
> +wake_up:
>  	wake_up_interruptible_poll(sk_sleep(&q->sk), POLLIN | POLLRDNORM | POLLRDBAND);
>  	return NET_RX_SUCCESS;
>  
> -- 
> 1.8.1.4
