From: Amir Vadai <amirv.mellanox@gmail.com>
Subject: Re: [PATCH net V1 1/3] net/mlx4_en: Don't use irq_affinity_notifier
 to track changes in IRQ affinity map
Date: Mon, 30 Jun 2014 11:34:22 +0300
Message-ID: <53B1210E.6040409@gmail.com>
References: <1404032097-5132-1-git-send-email-amirv@mellanox.com>	 <1404032097-5132-2-git-send-email-amirv@mellanox.com> <1404110511.15139.44.camel@edumazet-glaptop2.roam.corp.google.com>
Reply-To: amirv@mellanox.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ben Hutchings <ben@decadent.org.uk>, amira@mellanox.com,
	Yuval Atias <yuvala@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:56209 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751231AbaF3Ie0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 04:34:26 -0400
Received: by mail-wi0-f179.google.com with SMTP id cc10so5539707wib.6
        for <netdev@vger.kernel.org>; Mon, 30 Jun 2014 01:34:25 -0700 (PDT)
In-Reply-To: <1404110511.15139.44.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/30/2014 9:41 AM, Eric Dumazet wrote:
> On Sun, 2014-06-29 at 11:54 +0300, Amir Vadai wrote:
>> IRQ affinity notifier can only have a single notifier - cpu_rmap
>> notifier. Can't use it to track changes in IRQ affinity map.
>> Detect IRQ affinity changes by comparing CPU to current IRQ affinity map
>> during NAPI poll thread.
> 
> ...
> 
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>> index 8be7483..ac3dead 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>> @@ -474,15 +474,9 @@ int mlx4_en_poll_tx_cq(struct napi_struct *napi, int budget)
>>  	/* If we used up all the quota - we're probably not done yet... */
>>  	if (done < budget) {
>>  		/* Done for now */
>> -		cq->mcq.irq_affinity_change = false;
>>  		napi_complete(napi);
>>  		mlx4_en_arm_cq(priv, cq);
>>  		return done;
>> -	} else if (unlikely(cq->mcq.irq_affinity_change)) {
>> -		cq->mcq.irq_affinity_change = false;
>> -		napi_complete(napi);
>> -		mlx4_en_arm_cq(priv, cq);
>> -		return 0;
>>  	}
>>  	return budget;
>>  }
> 
> It seems nothing is done then for the TX side after this patch ?
> 
> You might want to drain whole queue instead of limiting to a 'budget',
> otherwise, a cpu might be stuck servicing (soft)irq for the TX
> completion, even if irq affinities say otherwise.
> 

TX completions are very quick compared to the skb preparation and
sending. Which is not the case for RX completions. Because of that, it
is very easy to reproduce the problem in RX flows, but we never had any
report of that problem in the TX flow.
I prefer not to spend time on the TX, since we plan to send a patch soon
to use the same NAPI for both TX and RX.

Amir
