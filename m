From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCHv2 net-next 4/4] macvtap: Perform GSO on forwarding path.
Date: Wed, 26 Jun 2013 00:25:28 +0400
Message-ID: <51C9FCB8.7070201@cogentembedded.com>
References: <1372190662-30815-1-git-send-email-vyasevic@redhat.com> <1372190662-30815-5-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, eric.dumazet@gmail.com,
	davem@davemloft.net
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:57690 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751005Ab3FYUZa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 16:25:30 -0400
Received: by mail-la0-f52.google.com with SMTP id fo12so12761515lab.39
        for <netdev@vger.kernel.org>; Tue, 25 Jun 2013 13:25:27 -0700 (PDT)
In-Reply-To: <1372190662-30815-5-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/26/2013 12:04 AM, Vlad Yasevich wrote:

> When macvtap forwards skb to its tap, it needs to check
> if GSO needs to be performed.  This is sometimes necessary
> when the HW device performed GRO, but the guest reading
> from the tap does not support it (ex: Windows 7).

> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
>   drivers/net/macvtap.c | 31 ++++++++++++++++++++++++++++++-
>   1 file changed, 30 insertions(+), 1 deletion(-)

> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index 7eab019..e370b79 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -276,14 +276,43 @@ static void macvtap_del_queues(struct net_device *dev)
>    */
>   static int macvtap_forward(struct net_device *dev, struct sk_buff *skb)
>   {
> +	struct macvlan_dev *vlan = netdev_priv(dev);
>   	struct macvtap_queue *q = macvtap_get_queue(dev, skb);
> +	netdev_features_t features;
>   	if (!q)
>   		goto drop;
>
>   	if (skb_queue_len(&q->sk.sk_receive_queue) >= dev->tx_queue_len)
>   		goto drop;
>
> -	skb_queue_tail(&q->sk.sk_receive_queue, skb);
> +	skb->dev = dev;
> +	/* Apply the forward feature mask so that we perform segmentation
> +	 * according to users wishes.
> +	 */
> +	features = netif_skb_features(skb) & vlan->tap_features;
> +	if (netif_needs_gso(skb, features)) {
> +		struct sk_buff *segs = __skb_gso_segment(skb, features, false);
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

    According to Documentation/CodingStyle chapter 3, you should have {} 
on both branches of *if* statement, if one branch has it.

WBR, Sergei
