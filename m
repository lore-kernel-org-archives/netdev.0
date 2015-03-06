From: Nicolas Schichan <nschichan@freebox.fr>
Subject: Re: [PATCH v1] mv643xx_eth: only account for work done in rxq_process
 in poll callback.
Date: Fri, 06 Mar 2015 17:28:00 +0100
Message-ID: <54F9D590.5000406@freebox.fr>
References: <1425492124-5033-1-git-send-email-nschichan@freebox.fr> <20150304213235.GA20596@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.iliad.fr ([212.27.33.1]:60042 "EHLO ns.iliad.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750709AbbCFQ2C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Mar 2015 11:28:02 -0500
In-Reply-To: <20150304213235.GA20596@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/04/2015 10:32 PM, Francois Romieu wrote:
> Nicolas Schichan <nschichan@freebox.fr> :
>> @@ -1050,7 +1049,7 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
>>  	__netif_tx_lock_bh(nq);
>>  
>>  	reclaimed = 0;
>> -	while (reclaimed < budget && txq->tx_desc_count > 0) {
>> +	while (txq->tx_desc_count > 0) {
>>  		int tx_index;
>>  		struct tx_desc *desc;
>>  		u32 cmd_sts;
> 
> You may use a local 'int count = txq->tx_desc_count' variable then
> perform a single update at the end of the locked section. 
> txq->tx_used_desc could be reworked in a similar way.

Hello Francois,

I was trying to minimize the code changes wrt the current source, but if you
want that change to be in the same patch, I can certainly respin a V2 with it.

>> @@ -1105,8 +1104,7 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
>>  
>>  	__netif_tx_unlock_bh(nq);
>>  
>> -	if (reclaimed < budget)
>> -		mp->work_tx &= ~(1 << txq->index);
>> +	mp->work_tx &= ~(1 << txq->index);
>>  
>>  	return reclaimed;
>>  }
> 
> work_tx is also updated in irq context. I'd rather see "clear_flag() then
> reclaim()" than "reclaim() then clear_flag()" in a subsequent patch.

Just to be sure that I understand the issue here, under normal conditions,
work_tx is updated in irq context via mv643xx_eth_collect_events() and then
the mv643xx interrupts are masked and napi_schedule() is called. Only once all
the work has been completed in the poll callback and the work flags have been
cleared, are the interrupt unmasked and napi_complete() is called. As far as I
can see there should be no issue here.

The only problem I can see is in OOM condition when napi_schedule is called
from a timer callback (oom_timer_wrapper()) which will result in the poll
callback being called with the interrupts unmasked and if an interrupt fires
(possibly in an other CPU) at the wrong time, mv643xx_eth_collect_events()
will race with the various flags clear in txq_reclaim, rxq_process and
rxq_refill ?

In that case wouldn't be something like clear_bit/set_bit preferred compared
to the direct bitwise operations ?

Regards,


-- 
Nicolas Schichan
Freebox SAS
