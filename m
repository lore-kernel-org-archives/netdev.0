From: Yanjun Zhu <yanjun.zhu@oracle.com>
Subject: Re: [PATCH 1/1] forcedeth: remove tx_stop variable
Date: Thu, 14 Sep 2017 15:55:10 +0800
Message-ID: <139fbb88-f69f-ecf0-5224-8ab2c283a84c@oracle.com>
References: <1504873725-30180-1-git-send-email-yanjun.zhu@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:30779 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751206AbdINHyh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2017 03:54:37 -0400
In-Reply-To: <1504873725-30180-1-git-send-email-yanjun.zhu@oracle.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, all

After this patch is applied, the TCP && UDP tests are made.

The TCP bandwidth is 939 Mbits/sec. The UDP bandwidth is 806 Mbits/sec.

So I think this patch can work well.

host1 <-----> host2

host1: forcedeth NIC
IP: 1.1.1.107
iperf -s

host2: forcedeth NIC
IP:1.1.1.105
iperf -c 1.1.1.107

The TCP Bandwidth is as below:
------------------------------------------------------------
Client connecting to 1.1.1.107, TCP port 5001
TCP window size: 85.0 KByte (default)
------------------------------------------------------------
[  3] local 1.1.1.105 port 46092 connected with 1.1.1.107 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec  1.09 GBytes   939 Mbits/sec

The UDP is as below:

iperf -c 1.1.1.107 -u -b 1000m
------------------------------------------------------------
Client connecting to 1.1.1.107, UDP port 5001
Sending 1470 byte datagrams
UDP buffer size:  208 KByte (default)
------------------------------------------------------------
[  3] local 1.1.1.105 port 47265 connected with 1.1.1.107 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec   964 MBytes   809 Mbits/sec
[  3] Sent 687990 datagrams
[  3] Server Report:
[  3]  0.0-10.0 sec   960 MBytes   806 Mbits/sec   0.019 ms 2942/687989 
(0.43%)
[  3]  0.0-10.0 sec  1 datagrams received out-of-order

Zhu Yanjun

On 2017/9/8 20:28, Zhu Yanjun wrote:
> The variable tx_stop is used to indicate the tx queue state: started
> or stopped. In fact, the inline function netif_queue_stopped can do
> the same work. So replace the variable tx_stop with the
> function netif_queue_stopped.
>
> Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>
> ---
>   drivers/net/ethernet/nvidia/forcedeth.c | 13 ++++---------
>   1 file changed, 4 insertions(+), 9 deletions(-)
>
> diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
> index 994a83a..e6e0de4 100644
> --- a/drivers/net/ethernet/nvidia/forcedeth.c
> +++ b/drivers/net/ethernet/nvidia/forcedeth.c
> @@ -834,7 +834,6 @@ struct fe_priv {
>   	u32 tx_pkts_in_progress;
>   	struct nv_skb_map *tx_change_owner;
>   	struct nv_skb_map *tx_end_flip;
> -	int tx_stop;
>   
>   	/* TX software stats */
>   	struct u64_stats_sync swstats_tx_syncp;
> @@ -1939,7 +1938,6 @@ static void nv_init_tx(struct net_device *dev)
>   	np->tx_pkts_in_progress = 0;
>   	np->tx_change_owner = NULL;
>   	np->tx_end_flip = NULL;
> -	np->tx_stop = 0;
>   
>   	for (i = 0; i < np->tx_ring_size; i++) {
>   		if (!nv_optimized(np)) {
> @@ -2211,7 +2209,6 @@ static netdev_tx_t nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
>   	empty_slots = nv_get_empty_tx_slots(np);
>   	if (unlikely(empty_slots <= entries)) {
>   		netif_stop_queue(dev);
> -		np->tx_stop = 1;
>   		spin_unlock_irqrestore(&np->lock, flags);
>   		return NETDEV_TX_BUSY;
>   	}
> @@ -2359,7 +2356,6 @@ static netdev_tx_t nv_start_xmit_optimized(struct sk_buff *skb,
>   	empty_slots = nv_get_empty_tx_slots(np);
>   	if (unlikely(empty_slots <= entries)) {
>   		netif_stop_queue(dev);
> -		np->tx_stop = 1;
>   		spin_unlock_irqrestore(&np->lock, flags);
>   		return NETDEV_TX_BUSY;
>   	}
> @@ -2583,8 +2579,8 @@ static int nv_tx_done(struct net_device *dev, int limit)
>   
>   	netdev_completed_queue(np->dev, tx_work, bytes_compl);
>   
> -	if (unlikely((np->tx_stop == 1) && (np->get_tx.orig != orig_get_tx))) {
> -		np->tx_stop = 0;
> +	if (unlikely(netif_queue_stopped(dev) &&
> +		     (np->get_tx.orig != orig_get_tx))) {
>   		netif_wake_queue(dev);
>   	}
>   	return tx_work;
> @@ -2637,8 +2633,8 @@ static int nv_tx_done_optimized(struct net_device *dev, int limit)
>   
>   	netdev_completed_queue(np->dev, tx_work, bytes_cleaned);
>   
> -	if (unlikely((np->tx_stop == 1) && (np->get_tx.ex != orig_get_tx))) {
> -		np->tx_stop = 0;
> +	if (unlikely(netif_queue_stopped(dev) &&
> +		     (np->get_tx.ex != orig_get_tx))) {
>   		netif_wake_queue(dev);
>   	}
>   	return tx_work;
> @@ -2724,7 +2720,6 @@ static void nv_tx_timeout(struct net_device *dev)
>   	/* 2) complete any outstanding tx and do not give HW any limited tx pkts */
>   	saved_tx_limit = np->tx_limit;
>   	np->tx_limit = 0; /* prevent giving HW any limited pkts */
> -	np->tx_stop = 0;  /* prevent waking tx queue */
>   	if (!nv_optimized(np))
>   		nv_tx_done(dev, np->tx_ring_size);
>   	else
