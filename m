From: Weidong Wang <wangweidong1@huawei.com>
Subject: Re: [PATCH net-next] BNX2: fix a Null Pointer for stats_blk
Date: Thu, 24 Sep 2015 10:00:45 +0800
Message-ID: <5603594D.70408@huawei.com>
References: <56014CC0.3050201@huawei.com> <20150923.153117.2291008783799112683.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <sony.chacko@qlogic.com>, <Dept-HSGLinuxNICDev@qlogic.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<rui.xiang@huawei.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150923.153117.2291008783799112683.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2015/9/24 6:31, David Miller wrote:
> From: Weidong Wang <wangweidong1@huawei.com>
> Date: Tue, 22 Sep 2015 20:42:40 +0800
> 
>> @@ -880,6 +882,7 @@ bnx2_alloc_mem(struct bnx2 *bp)
>>  		}
>>  	}
>>
>> +	spin_lock(&bp->stats64_lock);
>>  	bp->stats_blk = status_blk + status_blk_size;
>>
>>  	bp->stats_blk_mapping = bp->status_blk_mapping + status_blk_size;
>> @@ -894,20 +897,23 @@ bnx2_alloc_mem(struct bnx2 *bp)
>>  						&bp->ctx_blk_mapping[i],
>>  						GFP_KERNEL);
>>  			if (bp->ctx_blk[i] == NULL)
>> -				goto alloc_mem_err;
>> +				goto free_stats64_lock;
>>  		}
>>  	}
>>
>>  	err = bnx2_alloc_rx_mem(bp);
>>  	if (err)
>> -		goto alloc_mem_err;
>> +		goto free_stats64_lock;
> 
> You're holding a spinlock while doing GFP_KERNEL allocations.
> 

hm, yep, I should move it after the allocations. Like this:

@@ -880,7 +882,9 @@ bnx2_alloc_mem(struct bnx2 *bp)
                }
        }

+	spin_lock(&bp->stats64_lock);
	bp->stats_blk = status_blk + status_blk_size;
+	spin_unlock(&bp->stats64_lock);

the allocations won't use the stats_blk, so I shouldn't hold the
lock while doing allocations.

> Second of all, taking a spinlock in get_stats64() defeats the whole
> intention of making statistics acquisition as fast and as SMP scalable
> as possible.
> 

It does affect the intention. Although, the problem exists then makes the
system panic within some case.

Do you have any idea about it?

Best Regards,
Weidong

> .
> 
