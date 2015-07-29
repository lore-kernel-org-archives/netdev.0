From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [net-next PATCH 2/2] drivers: net: cpsw: add separate napi for
 tx packet handling for performance improvment
Date: Wed, 29 Jul 2015 10:48:56 +0530
Message-ID: <55B86240.4090301@ti.com>
References: <1437995941-5857-1-git-send-email-mugunthanvnm@ti.com> <1437995941-5857-3-git-send-email-mugunthanvnm@ti.com> <20150727212206.GA8912@electric-eye.fr.zoreil.com> <55B71E99.50807@ti.com> <20150728223013.GA10669@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:47266 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957AbbG2FTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 01:19:09 -0400
In-Reply-To: <20150728223013.GA10669@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 29 July 2015 04:00 AM, Francois Romieu wrote:
> Mugunthan V N <mugunthanvnm@ti.com> :
>> On Tuesday 28 July 2015 02:52 AM, Francois Romieu wrote:
>>> Mugunthan V N <mugunthanvnm@ti.com> :
> [...]
>>>> @@ -752,13 +753,22 @@ static irqreturn_t cpsw_tx_interrupt(int irq, void *dev_id)
>>>>  	struct cpsw_priv *priv = dev_id;
>>>>  
>>>>  	cpdma_ctlr_eoi(priv->dma, CPDMA_EOI_TX);
>>>> -	cpdma_chan_process(priv->txch, 128);
>>>> +	writel(0, &priv->wr_regs->tx_en);
>>>> +
>>>> +	if (netif_running(priv->ndev)) {
>>>> +		napi_schedule(&priv->napi_tx);
>>>> +		return IRQ_HANDLED;
>>>> +	}
>>>
>>>
>>> cpsw_ndo_stop calls napi_disable: you can remove netif_running.
>>>
>>
>> This netif_running check is to find which interface is up as the
>> interrupt is shared by both the interfaces. When first interface is down
>> and second interface is active then napi_schedule for first interface
>> will fail and second interface napi needs to be scheduled.
>>
>> So I don't think netif_running needs to be removed.
> 
> Each interface has its own napi tx (resp. rx) context: I would had expected
> two unconditional napi_schedule per tx (resp. rx) shared irq, not one.
> 
> I'll read it again after some sleep.
> 

For each interrupt only one napi will be scheduled, when the first
interface is down then only second interface napi is scheduled in both
tx and rx irqs.

Regards
Mugunthan V N
