From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next 1/2] net/mlx4_en: Add Low Latency Socket (LLS)
 support
Date: Mon, 17 Jun 2013 15:43:49 +0300
Message-ID: <51BF0485.2040608@mellanox.com>
References: <1371466703-3370-1-git-send-email-amirv@mellanox.com>  <1371466703-3370-2-git-send-email-amirv@mellanox.com> <1371469024.3252.184.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<eliezer.tamir@linux.intel.com>, Or Gerlitz <ogerlitz@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog123.obsmtp.com ([207.126.144.155]:53416 "EHLO
	eu1sys200aog123.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932641Ab3FQMn5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 08:43:57 -0400
In-Reply-To: <1371469024.3252.184.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/06/2013 14:37, Eric Dumazet wrote:
> On Mon, 2013-06-17 at 13:58 +0300, Amir Vadai wrote:
>> Add basic support for LLS.
>>
>> Signed-off-by: Amir Vadai <amirv@mellanox.com>
>> ---
>>  drivers/net/ethernet/mellanox/mlx4/en_cq.c     |   2 +
>>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c |  49 +++++++++-
>>  drivers/net/ethernet/mellanox/mlx4/en_rx.c     |   8 ++
>>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   | 124 +++++++++++++++++++++++++
>>  4 files changed, 181 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_cq.c b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
>> index 1e6c594..5e47efd 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/en_cq.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
>> @@ -139,6 +139,7 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
>>  
>>  	if (!cq->is_tx) {
>>  		netif_napi_add(cq->dev, &cq->napi, mlx4_en_poll_rx_cq, 64);
>> +		napi_hash_add(&cq->napi);
>>  		napi_enable(&cq->napi);
>>  	}
>>  
>> @@ -162,6 +163,7 @@ void mlx4_en_deactivate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq)
>>  {
>>  	if (!cq->is_tx) {
>>  		napi_disable(&cq->napi);
>> +		napi_hash_del(&cq->napi);
> 
> Are we sure an RCU grace period is respected before deletion of memory
> holding cq->napi ?
I assumed that when mlx4_en_deactivate_cq() is called, no users of the
object mlx4_en_cq which holds the napi context, exist. But now that I
look at it again, this is not true.
Will add a call to synchronize_rcu() in v1.
Thanks.


> 
>>  		netif_napi_del(&cq->napi);
>>  	}
>>  
> 
> ...
> 
>>  
>>  static const struct net_device_ops mlx4_netdev_ops_master = {
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
>> index 02aee1e..15b5980 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
>> @@ -31,6 +31,7 @@
>>   *
>>   */
>>  
>> +#include <net/ll_poll.h>
>>  #include <linux/mlx4/cq.h>
>>  #include <linux/slab.h>
>>  #include <linux/mlx4/qp.h>
>> @@ -737,6 +738,8 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>>  					       timestamp);
>>  		}
>>  
>> +		skb_mark_ll(skb, &cq->napi);
>> +
> 
> It seems there is a second point in the driver calling napi_gro_frags(),
> around line 696
> 
> It looks like LLS wont be supported for this case ?
> 
I don't want LLS to be supported when GRO is on.

>>  		/* Push it up the stack */
>>  		netif_receive_skb(skb);
>>  
>> @@ -781,8 +784,13 @@ int mlx4_en_poll_rx_cq(struct napi_struct *napi, int budget)
>>  	struct mlx4_en_priv *priv = netdev_priv(dev);
>>  	int done;
>>  
>> +	if (!mlx4_en_cq_lock_napi(cq))
>> +		return budget;
>> +
>>  	done = mlx4_en_process_rx_cq(dev, cq, budget);
>>  
>> +	mlx4_en_cq_unlock_napi(cq);
>> +
>>  	/* If we used up all the quota - we're probably not done yet... */
>>  	if (done == budget)
>>  		INC_PERF_COUNTER(priv->pstats.napi_quota);
> 
> 

Thanks,
Amir
