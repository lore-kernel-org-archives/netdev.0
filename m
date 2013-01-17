From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V1 5/6] net/mlx4_en: Fix a race when closing
 TX queue
Date: Thu, 17 Jan 2013 15:44:11 -0500 (EST)
Message-ID: <20130117.154411.908604315438836662.davem@davemloft.net>
References: <1358423241-2452-1-git-send-email-amirv@mellanox.com>
	<1358423241-2452-6-git-send-email-amirv@mellanox.com>
	<1358432538.29723.8.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amirv@mellanox.com, netdev@vger.kernel.org, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com, eugenia@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53337 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756799Ab3AQUoO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 15:44:14 -0500
In-Reply-To: <1358432538.29723.8.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 17 Jan 2013 06:22:18 -0800

> On Thu, 2013-01-17 at 13:47 +0200, Amir Vadai wrote:
>> There is a possible race where the TX completion handler can clean the
>> entire TX queue between the decision that the queue is full and actually
>> closing it. To avoid this situation, check again if the queue is really
>> full, if not, reopen the transmit and continue with sending the packet.
>> 
>> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.com>
>> Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
>> Signed-off-by: Amir Vadai <amirv@mellanox.com>
>> ---
>>  drivers/net/ethernet/mellanox/mlx4/en_tx.c |    9 ++++++++-
>>  1 files changed, 8 insertions(+), 1 deletions(-)
>> 
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>> index 2b799f4..1d17f5f 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>> @@ -592,7 +592,14 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
>>  		netif_tx_stop_queue(ring->tx_queue);
>>  		priv->port_stats.queue_stopped++;
>>  
>> -		return NETDEV_TX_BUSY;
>> +		/* Check again whether the queue was cleaned */
>> +		if (unlikely(((int)(ring->prod - ring->cons)) <=
>> +				ring->size - HEADROOM - MAX_DESC_TXBBS)) {
>> +			netif_tx_wake_queue(ring->tx_queue);
>> +			priv->port_stats.wake_queue++;
>> +		} else {
>> +			return NETDEV_TX_BUSY;
>> +		}
>>  	}
>>  
>>  	/* Track current inflight packets for performance analysis */
> 
> This looks racy to me. You probably want explicit memory barriers ?

The conditional is also not formatted correctly.
