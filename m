From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] ifb: add multiqueue operation
Date: Mon, 06 Jul 2015 17:19:59 -0700
Message-ID: <559B1B2F.5050300@plumgrid.com>
References: <1436213128.4571.14.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.fastabend@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33988 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754812AbbGGAUB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 20:20:01 -0400
Received: by pabvl15 with SMTP id vl15so103088666pab.1
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 17:20:00 -0700 (PDT)
In-Reply-To: <1436213128.4571.14.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/6/15 1:05 PM, Eric Dumazet wrote:
> Add multiqueue capabilities to ifb netdevice.
>
> This removes last bottleneck for ingress when mq qdisc can be used
> to shard load from multiple RX queues on physical device.
...
> Signed-off-by: Eric Dumazet<edumazet@google.com>
> Cc: Alexei Starovoitov<ast@plumgrid.com>
> Cc: Jamal Hadi Salim<jhs@mojatatu.com>
> Cc: John Fastabend<john.fastabend@gmail.com>
> ---
>   drivers/net/ifb.c |  207 +++++++++++++++++++++++++-------------------
>   1 file changed, 120 insertions(+), 87 deletions(-)
...
> -struct ifb_private {
> +struct ifb_q_private {
...
> -};
> +} ____cacheline_aligned_in_smp;
...
> +static int ifb_dev_init(struct net_device *dev)
> +{
> +	struct ifb_dev_private *dp = netdev_priv(dev);
> +	struct ifb_q_private *txp;
> +	int i;
> +
> +	txp = kcalloc(dev->num_tx_queues, sizeof(*txp), GFP_KERNEL);
...
>   static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_device *dev)
>   {
> -	struct ifb_private *dp = netdev_priv(dev);
> +	struct ifb_dev_private *dp = netdev_priv(dev);
>   	u32 from = G_TC_FROM(skb->tc_verd);
> +	struct ifb_q_private *txp = dp->tx_private + skb_get_queue_mapping(skb);

All makes sense. Nicely done!
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
