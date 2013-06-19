From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 2/2] macvtap: Perform GSO on forwarding path.
Date: Wed, 19 Jun 2013 22:09:07 +0400
Message-ID: <51C1F3C3.4060900@cogentembedded.com>
References: <1371653272-11703-1-git-send-email-vyasevic@redhat.com> <1371653272-11703-3-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, mst@redhat.com,
	jasowang@redhat.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:43469 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933869Ab3FSSJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 14:09:08 -0400
Received: by mail-lb0-f178.google.com with SMTP id y6so4966843lbh.37
        for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 11:09:05 -0700 (PDT)
In-Reply-To: <1371653272-11703-3-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/19/2013 06:47 PM, Vlad Yasevich wrote:

> When macvtap forwards skb to its tap, it needs to check
> if GSO needs to be performed.  This is necessary
> when the HW device performed GRO, but the guest reading
> from the tap does not support it (ex: Windows 7).

> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
>   drivers/net/macvtap.c | 26 +++++++++++++++++++++++++-
>   1 file changed, 25 insertions(+), 1 deletion(-)

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

    According to Documentation/CodingStyle, *else* branch should have {} 
if the other branch has it (and vice versa).

WBR, Sergei
