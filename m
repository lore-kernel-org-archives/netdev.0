From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] BNX2: fix a Null Pointer for stats_blk
Date: Wed, 23 Sep 2015 15:31:17 -0700 (PDT)
Message-ID: <20150923.153117.2291008783799112683.davem@davemloft.net>
References: <56014CC0.3050201@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sony.chacko@qlogic.com, Dept-HSGLinuxNICDev@qlogic.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rui.xiang@huawei.com
To: wangweidong1@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56014CC0.3050201@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Weidong Wang <wangweidong1@huawei.com>
Date: Tue, 22 Sep 2015 20:42:40 +0800

> @@ -880,6 +882,7 @@ bnx2_alloc_mem(struct bnx2 *bp)
>  		}
>  	}
> 
> +	spin_lock(&bp->stats64_lock);
>  	bp->stats_blk = status_blk + status_blk_size;
> 
>  	bp->stats_blk_mapping = bp->status_blk_mapping + status_blk_size;
> @@ -894,20 +897,23 @@ bnx2_alloc_mem(struct bnx2 *bp)
>  						&bp->ctx_blk_mapping[i],
>  						GFP_KERNEL);
>  			if (bp->ctx_blk[i] == NULL)
> -				goto alloc_mem_err;
> +				goto free_stats64_lock;
>  		}
>  	}
> 
>  	err = bnx2_alloc_rx_mem(bp);
>  	if (err)
> -		goto alloc_mem_err;
> +		goto free_stats64_lock;

You're holding a spinlock while doing GFP_KERNEL allocations.

Second of all, taking a spinlock in get_stats64() defeats the whole
intention of making statistics acquisition as fast and as SMP scalable
as possible.
