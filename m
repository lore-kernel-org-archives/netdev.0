From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH v8 3/3] net: hisilicon: new hip04 ethernet driver
Date: Wed, 10 Dec 2014 14:45:29 +0800
Message-ID: <5487EC09.8090907@huawei.com>
References: <1397869980-21187-1-git-send-email-zhangfei.gao@linaro.org> <5483C977.2060308@huawei.com> <54842298.2010007@suse.de> <2619239.NTtdNaZCJM@wuerfel> <5487C357.9030507@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Zhangfei Gao <zhangfei.gao@linaro.org>, <davem@davemloft.net>,
	<linux@arm.linux.org.uk>, <f.fainelli@gmail.com>,
	<sergei.shtylyov@cogentembedded.com>, <mark.rutland@arm.com>,
	<David.Laight@aculab.com>, <eric.dumazet@gmail.com>,
	<xuwei5@hisilicon.com>, <linux-arm-kernel@lists.infradead.org>,
	<netdev@vger.kernel.org>, <devicetree@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>, Alexander Graf <agraf@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:12061 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932211AbaLJGqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 01:46:46 -0500
In-Reply-To: <5487C357.9030507@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/12/10 11:51, Ding Tianhong wrote:
> On 2014/12/8 4:09, Arnd Bergmann wrote:
>> On Sunday 07 December 2014 10:49:12 Alexander Graf wrote:
>>> On 07.12.14 04:28, Ding Tianhong wrote:
>>>> On 2014/12/7 8:42, Alexander Graf wrote:
>>>>> On 19.04.14 03:13, Zhangfei Gao wrote:
>>>>>> Support Hisilicon hip04 ethernet driver, including 100M / 1000M controller.
>>>>>> The controller has no tx done interrupt, reclaim xmitted buffer in the poll.
>>>>>>
>>>>>> Signed-off-by: Zhangfei Gao <zhangfei.gao@linaro.org>
>>>>>
>>>>> Is this driver still supposed to go upstream? I presume this was the
>>>>> last submission and it's been quite some time ago 
>>>>>
>>>>
>>>> yes, it is really a long time, but The hip04 did not support tx irq, 
>>>> we couldn't get any better idea to fix this defect, do you have any suggestion?
>>>
>>> Well, if hardware doesn't have a TX irq I don't see there's anything we
>>> can do to fix that ;).
>>
>> I don't know if it's related to the ethernet on hip01, but I would assume
>> it is, and that platform is currently being submitted for inclusion, so
>> I'd definitely hope to see this driver get merged too eventually.
>>
>> IIRC, the last revision of the patch set had basically fixed the problem,
>> except for a race that would still allow the napi poll function to exit
>> with poll_complete() but a full queue of TX descriptors and no fallback
>> to clean them up. There was also still an open question about whether or
>> not the driver should use skb_orphan, but I may be misremembering that part.
>>  
> 
> Hi Arnd:
> 
> what about use a state machine to check the tx queue and free the skb, just like:
> 
> diff --git a/drivers/net/ethernet/hisilicon/hip04_eth.c b/drivers/net/ethernet/hisilicon/hip04_eth.c
> index 8593658..71faca8 100644
> --- a/drivers/net/ethernet/hisilicon/hip04_eth.c
> +++ b/drivers/net/ethernet/hisilicon/hip04_eth.c
> @@ -396,9 +396,25 @@ static int hip04_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>         stats->tx_packets++;
>         priv->tx_count++;
> 
> +
> +       queue_delayed_work(priv->wq, &priv->tx_queue, delay);
> +
>         return NETDEV_TX_OK;
>  }
> 
> +static void hip04_tx_queue_monitor(struct work_struct *work)
> +{
> +       struct hip04_priv *priv = container_of(work, struct hip04_priv,
> +                                              queue_work.work);
> +       struct net_device *dev = priv->ndev;
> +       hip04_tx_reclain(ndev, false);
> +
> +       if (TX_QUEUE_IS_EMPRY(ndev))
> +               return;
> +
> +       queue_delayed_work(priv->wq, &priv->tx_queue, delay);
> +}
> +
>  static int hip04_rx_poll(struct napi_struct *napi, int budget)
>  {
>         struct hip04_priv *priv = container_of(napi, struct hip04_priv, napi);
> @@ -736,6 +752,8 @@ static int hip04_mac_probe(struct platform_device *pdev)
>                 goto alloc_fail;
>         }
> 
> +       INIT_DELAYED_WORK(&priv->tx_queue, hip04_tx_queue_monitor);
> +
>         return 0;
> 
> 
> 
> what do you think of this solution?
> 
> Regards
> Ding
> 

Miss this code, I think the best way is skb_orphan(skb), just like the cxgb3 drivers, some hardware
didn't use the tx inq to free dmad Tx packages.

Ding

> 
>>> Dave, what's your take here? Should we keep a driver from going upstream
>>> just because the hardware is partly broken? I'd really prefer to have an
>>> upstream driver on that SoC rather than some random (eventually even
>>> more broken) downstream code.
>>
>> We can certainly have a slow driver for this hardware, and I'd much
>> prefer slow over broken. I'd guess that some of the performance impact
>> of the missing interrupts can now be offset with the xmit_more	 logic.
>>
>> 	Arnd
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>> .
>>
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> .
> 
