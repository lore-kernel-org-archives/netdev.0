From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next v9 0/3] add hisilicon hip04 ethernet driver
Date: Tue, 16 Dec 2014 18:08:32 +0800
Message-ID: <549004A0.9010106@huawei.com>
References: <1418298150-4944-1-git-send-email-dingtianhong@huawei.com> <2708715.thQWqYuW6a@wuerfel> <548FE5E1.1090300@huawei.com> <26790181.hAWQCCSkRa@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-arm-kernel@lists.infradead.org>, <zhangfei.gao@linaro.org>,
	<davem@davemloft.net>, <linux@arm.linux.org.uk>,
	<f.fainelli@gmail.com>, <sergei.shtylyov@cogentembedded.com>,
	<mark.rutland@arm.com>, <David.Laight@aculab.com>,
	<eric.dumazet@gmail.com>, <xuwei5@hisilicon.com>,
	<netdev@vger.kernel.org>, <devicetree@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:63604 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866AbaLPKJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 05:09:08 -0500
In-Reply-To: <26790181.hAWQCCSkRa@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/12/16 16:54, Arnd Bergmann wrote:
> On Tuesday 16 December 2014 15:57:21 Ding Tianhong wrote:
>> On 2014/12/15 21:29, Arnd Bergmann wrote:
>>> On Thursday 11 December 2014 19:42:27 Ding Tianhong wrote:
>>> @@ -381,57 +392,37 @@ static void hip04_tx_reclaim(struct net_device *ndev, bool force)
>>>  		dev_kfree_skb(priv->tx_skb[tx_tail]);
>>>  		priv->tx_skb[tx_tail] = NULL;
>>>  		tx_tail = TX_NEXT(tx_tail);
>>> -		priv->tx_count--;
>>> -
>>> -		if (priv->tx_count <= 0)
>>> -			break;
>>> +		count--;
>>>  	}
>>>  
> ...
>>> -	queue_delayed_work(priv->wq, &priv->tx_clean_task, delta_in_ticks);
>>> +	return count;
>>
>> I think should return pkts_compl, because may break from the loop, the
>> pkts_compl may smaller than count.
> 
> The calling convention I used is to return the packets that are remaining
> on the queue. Only if that is nonzero we need to reschedule the timer.
> 

OK, agree.

>> and we need to add netif_tx_lock() to protect this function to avoid concurrency conflict.
> 
> Oh, did I miss something? The idea was that the start_xmit function only updates
> the tx_head pointer and reads the tx_tail, while the tx_reclaim function does
> the reverse, and writes to a different cache line, in order to allow a lockless
> queue traversal.
> 
> Can you point to a specific struct member that still need to be protected by
> the lock? Did I miss a race that would allow both functions to exit with
> the timer disabled and entries left on the queue?
> 
OK, got it, no problem.

>>> @@ -623,8 +648,6 @@ static int hip04_mac_stop(struct net_device *ndev)
>>>  	struct hip04_priv *priv = netdev_priv(ndev);
>>>  	int i;
>>>  
>>> -	cancel_delayed_work_sync(&priv->tx_clean_task);
>>> -
>> I think we should cancle the hrtimer when closed and queue the timer when open.
> 
> I was expecting that force-cleaning up the tx queue would be enough for that.
> It it not?
> 
> I suppose it can't hurt to cancel the timer here anyway, and maybe use
> WARN_ON() if it's still active.
> 

Ok, I found no need to worry about this, when the dev is closed, the napi will disable and will not enter timer again.

> Starting the timer after opening seems wrong though: at that point there are
> no packets on the queue yet. The timer should always start ticking at the
> exact point when the first packet is put on the queue while the timer is
> not already pending.
> 
Ok.

>>>  	napi_disable(&priv->napi);
>>>  	netif_stop_queue(ndev);
>>>  	hip04_mac_disable(ndev);
>>> @@ -725,6 +748,7 @@ static int hip04_mac_probe(struct platform_device *pdev)
>>>  	struct hip04_priv *priv;
>>>  	struct resource *res;
>>>  	unsigned int irq;
>>> +	ktime_t txtime;
>>>  	int ret;
>>>  
>>>  	ndev = alloc_etherdev(sizeof(struct hip04_priv));
>>> @@ -751,6 +775,21 @@ static int hip04_mac_probe(struct platform_device *pdev)
>>>  	priv->port = arg.args[0];
>>>  	priv->chan = arg.args[1] * RX_DESC_NUM;
>>>  
>>> +	hrtimer_init(&priv->tx_coalesce_timer, CLOCK_MONOTONIC, HRTIMER_MODE_REL);
>>> +
>>> +	/*
>>> +	 * BQL will try to keep the TX queue as short as possible, but it can't
>>> +	 * be faster than tx_coalesce_usecs, so we need a fast timeout here,
>>> +	 * but also long enough to gather up enough frames to ensure we don't
>>> +	 * get more interrupts than necessary.
>>> +	 * 200us is enough for 16 frames of 1500 bytes at gigabit ethernet rate
>>> +	 */
>>> +	priv->tx_coalesce_frames = TX_DESC_NUM * 3 / 4;
>>> +	priv->tx_coalesce_usecs = 200;
>>> +	/* allow timer to fire after half the time at the earliest */
>>> +	txtime = ktime_set(0, priv->tx_coalesce_usecs * NSEC_PER_USEC / 2);
>>> +	hrtimer_set_expires_range(&priv->tx_coalesce_timer, txtime, txtime);
>>> +
>>
>> I think miss the line:
>>  priv->tx_coalesce_timer.function = tx_done;
> 
> Yes, good point.
> 

I will send v10 when the net-next open again, and these days will test this driver, thanks a lot.

Ding

> 	Arnd
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> .
> 
