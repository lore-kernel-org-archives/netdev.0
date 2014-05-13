From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next 1/9] net/mlx4_core: Enforce irq affinity changes
 immediatly
Date: Tue, 13 May 2014 13:17:30 +0300
Message-ID: <5371F13A.2040803@mellanox.com>
References: <1399880605-28772-1-git-send-email-amirv@mellanox.com>	 <1399880605-28772-2-git-send-email-amirv@mellanox.com> <1399903028.7973.23.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Yevgeny Petrilin" <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	"Yuval Atias" <yuvala@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:48159 "EHLO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933001AbaEMKSn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 06:18:43 -0400
In-Reply-To: <1399903028.7973.23.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/12/2014 4:57 PM, Eric Dumazet wrote:
> On Mon, 2014-05-12 at 10:43 +0300, Amir Vadai wrote:
>> From: Yuval Atias <yuvala@mellanox.com>
>>
>> During heavy traffic, napi is constatntly polling the complition queue
>> and no interrupt is fired. Because of that, changes to irq affinity are
>> ignored until traffic is stopped and resumed.
>>
>> By registering to the irq notifier mechanism, and forcing interrupt when
>> affinity is changed, irq affinity changes will be immediatly enforced.
>>
>> Signed-off-by: Yuval Atias <yuvala@mellanox.com>
>> Signed-off-by: Amir Vadai <amirv@mellanox.com>
>> ---
>
> Interesting. Its a bit sad it has to be in fast path...
Right.
The other option we thought of - was to add some sort of 'restart' to 
the NAPI, to enable the notifier callback to stop any current running 
NAPI loop, and make it start again on the right CPU - this looks very 
complicated and adding one if doesn't seem to be so bad. So we chose 
that option.

>
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>> index 89585c6..81b7571 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>> @@ -474,9 +474,15 @@ int mlx4_en_poll_tx_cq(struct napi_struct *napi, int budget)
>>   	/* If we used up all the quota - we're probably not done yet... */
>>   	if (done < budget) {
>>   		/* Done for now */
>> +		cq->mcq.irq_affinity_change = 0;
>
>
>>   		napi_complete(napi);
>>   		mlx4_en_arm_cq(priv, cq);
>>   		return done;
>> +	} else if (unlikely(cq->mcq.irq_affinity_change)) {
>> +		cq->mcq.irq_affinity_change = 0;
>> +		napi_complete(napi);
>> +		mlx4_en_arm_cq(priv, cq);
>> +		return 0;
>>   	}
>>   	return budget;
>
>
>>   			priv->msix_ctl.pool_bm &= ~(1ULL << i);
>> diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
>> index ba87bd2..74f5aa8 100644
>> --- a/include/linux/mlx4/device.h
>> +++ b/include/linux/mlx4/device.h
>> @@ -586,6 +586,8 @@ struct mlx4_cq {
>>
>>   	atomic_t		refcount;
>>   	struct completion	free;
>> +	u16                     irq;
>> +	bool                    irq_affinity_change;
>>   };
>>
>>   struct mlx4_qp {
>
> But could you place irq_affinity_change in another cache line ?
>
> It seems there is a 32bit hole between cons_index and set_ci_db
>
> (Both fields can be moved)
Done in V1

Thanks,
Amir

>
> Thanks
>
>
