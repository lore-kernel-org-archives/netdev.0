From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next 2/2] macvtap: Perform GSO on forwarding path.
Date: Wed, 19 Jun 2013 12:22:24 -0400
Message-ID: <51C1DAC0.4010000@redhat.com>
References: <1371653272-11703-1-git-send-email-vyasevic@redhat.com> <1371653272-11703-3-git-send-email-vyasevic@redhat.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, mst@redhat.com,
	jasowang@redhat.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50255 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757027Ab3FSQW1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jun 2013 12:22:27 -0400
In-Reply-To: <1371653272-11703-3-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/19/2013 10:47 AM, Vlad Yasevich wrote:
> When macvtap forwards skb to its tap, it needs to check
> if GSO needs to be performed.  This is necessary
> when the HW device performed GRO, but the guest reading
> from the tap does not support it (ex: Windows 7).
>
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
>   drivers/net/macvtap.c | 26 +++++++++++++++++++++++++-
>   1 file changed, 25 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index 09f0b1f..698f613 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -291,13 +291,37 @@ static void macvtap_del_queues(struct net_device *dev)
>   static int macvtap_forward(struct net_device *dev, struct sk_buff *skb)
>   {
>   	struct macvtap_queue *q = macvtap_get_queue(dev, skb);
> +	netdev_features_t features;
>   	if (!q)
>   		goto drop;
>
>   	if (skb_queue_len(&q->sk.sk_receive_queue) >= dev->tx_queue_len)
>   		goto drop;
>
> -	skb_queue_tail(&q->sk.sk_receive_queue, skb);
> +	features = netif_skb_features(skb);

Ooops..  This is the wrong patch...

-vlad
> +	if (netif_needs_gso(skb, features)) {
> +		struct sk_buff *segs = skb_gso_segment(skb, features);
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
>   	wake_up_interruptible_poll(sk_sleep(&q->sk), POLLIN | POLLRDNORM | POLLRDBAND);
>   	return NET_RX_SUCCESS;
>
>
