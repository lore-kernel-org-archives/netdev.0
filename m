From: tndave <tushar.n.dave@oracle.com>
Subject: Re: [PATCH] netpoll: Check for skb->queue_mapping
Date: Thu, 20 Apr 2017 12:08:42 -0700
Message-ID: <a94139a3-9eaf-6682-3dff-cfb161e62d32@oracle.com>
References: <1491444383-29017-1-git-send-email-tushar.n.dave@oracle.com>
 <1491474377.10124.57.camel@edumazet-glaptop3.roam.corp.google.com>
 <5927b630-865e-b7af-33a1-1a6b772e3fb7@oracle.com>
 <1491506056.10124.81.camel@edumazet-glaptop3.roam.corp.google.com>
 <b98cb4f6-2e4c-71ba-1431-1824bf334f8e@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com, brouer@redhat.com,
        netdev@vger.kernel.org, sowmini.varadhan@oracle.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:17018 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938784AbdDTTKF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 15:10:05 -0400
In-Reply-To: <b98cb4f6-2e4c-71ba-1431-1824bf334f8e@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04/12/2017 03:37 PM, tndave wrote:
>
>
> On 04/06/2017 12:14 PM, Eric Dumazet wrote:
>> On Thu, 2017-04-06 at 12:07 -0700, tndave wrote:
>>
>>>> +            q_index = q_index % dev->real_num_tx_queues;
>>> cpu interrupted here and dev->real_num_tx_queues has reduced!
>>>> +            skb_set_queue_mapping(skb, q_index);
>>>> +        }
>>>> +        txq = netdev_get_tx_queue(dev, q_index);
>>> or cpu interrupted here and dev->real_num_tx_queues has reduced!
>>
>> If dev->real_num_tx_queues can be changed while this code is running we
>> are in deep deep trouble.
>>
>> Better make sure that when control path does this change, device (and/pr
>> netpoll) is frozen and no packet can be sent.
> When control path is making change to real_num_tx_queues, underlying
> device is disabled; also netdev tx queues are stopped/disabled so
> certainly no transmit is happening.
>
>
> The corner case I was referring is if netpoll's queue_process() code is
> interrupted and while it is not running, control path makes change to
> dev->real_num_tx_queues and exits. Later on, interrupted queue_process()
> resume execution and it can end up with wrong skb->queue_mapping and txq.
> We can prevent this case with below change:
>
> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> index 9424673..29be246 100644
> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -105,15 +105,21 @@ static void queue_process(struct work_struct *work)
>         while ((skb = skb_dequeue(&npinfo->txq))) {
>                 struct net_device *dev = skb->dev;
>                 struct netdev_queue *txq;
> +               unsigned int q_index;
>
>                 if (!netif_device_present(dev) || !netif_running(dev)) {
>                         kfree_skb(skb);
>                         continue;
>                 }
>
> -               txq = skb_get_tx_queue(dev, skb);
> -
>                 local_irq_save(flags);
> +               /* check if skb->queue_mapping is still valid */
> +               q_index = skb_get_queue_mapping(skb);
> +               if (unlikely(q_index >= dev->real_num_tx_queues)) {
> +                       q_index = q_index % dev->real_num_tx_queues;
> +                       skb_set_queue_mapping(skb, q_index);
> +               }
> +               txq = netdev_get_tx_queue(dev, q_index);
>                 HARD_TX_LOCK(dev, txq, smp_processor_id());
>                 if (netif_xmit_frozen_or_stopped(txq) ||
>                     netpoll_start_xmit(skb, dev, txq) != NETDEV_TX_OK) {
>
>
> Thanks for your patience.
Eric,

Let me know if you are okay with above changes and me sending v2.

-Tushar
>
> -Tushar
>>
>>
>>
>>
>
