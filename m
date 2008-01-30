From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH] Optimize cxgb3 xmit path (a bit)
Date: Wed, 30 Jan 2008 12:35:00 +0530
Message-ID: <OF64BDE46A.7BC69769-ON652573E0.00274DF7-652573E0.0026E92E@in.ibm.com>
References: <20080130070016.29078.94125.sendpatchset@N20wks267652wss.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp05.in.ibm.com ([59.145.155.5]:49378 "EHLO
	e28esmtp05.in.ibm.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751764AbYA3HHL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 02:07:11 -0500
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp05.in.ibm.com (8.13.1/8.13.1) with ESMTP id m0U777K3001780
	for <netdev@vger.kernel.org>; Wed, 30 Jan 2008 12:37:07 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0U777wu917672
	for <netdev@vger.kernel.org>; Wed, 30 Jan 2008 12:37:07 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id m0U776F8015267
	for <netdev@vger.kernel.org>; Wed, 30 Jan 2008 07:07:07 GMT
In-Reply-To: <20080130070016.29078.94125.sendpatchset@N20wks267652wss.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I forgot to mention but the patch is only compile tested as I don't have
hardware to test it.

Krishna Kumar2/India/IBM@IBMIN wrote on 01/30/2008 12:30:16 PM:

> Changes:
>    1. Add common code for stopping queue.
>    2. No need to call netif_stop_queue followed by netif_wake_queue (and
>       infact a netif_start_queue could have been used instead), instead
>       call stop_queue if required, and remove code under USE_GTS macro.
>    3. There is no need to check for netif_queue_stopped, as the network
>       core guarantees that for us (I am sure every driver could remove
>       that check, eg e1000 - I have tested that path a few billion times
>       with about a few hundred thousand qstops but the condition never
>       hit even once).
>
> Thanks,
>
> - KK
>
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
>  sge.c |   35 +++++++++++++++--------------------
>  1 files changed, 15 insertions(+), 20 deletions(-)
>
> diff -ruNp a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
> --- a/drivers/net/cxgb3/sge.c   2008-01-30 11:42:39.000000000 +0530
> +++ b/drivers/net/cxgb3/sge.c   2008-01-30 12:15:28.000000000 +0530
> @@ -1059,6 +1059,14 @@ static void write_tx_pkt_wr(struct adapt
>            htonl(V_WR_TID(q->token)));
>  }
>
> +static inline void t3_stop_queue(struct net_device *dev, struct sge_qset
*qs,
> +             struct sge_txq *q)
> +{
> +   netif_stop_queue(dev);
> +   set_bit(TXQ_ETH, &qs->txq_stopped);
> +   q->stops++;
> +}
> +
>  /**
>   *   eth_xmit - add a packet to the Ethernet Tx queue
>   *   @skb: the packet
> @@ -1090,31 +1098,18 @@ int t3_eth_xmit(struct sk_buff *skb, str
>     ndesc = calc_tx_descs(skb);
>
>     if (unlikely(credits < ndesc)) {
> -      if (!netif_queue_stopped(dev)) {
> -         netif_stop_queue(dev);
> -         set_bit(TXQ_ETH, &qs->txq_stopped);
> -         q->stops++;
> -         dev_err(&adap->pdev->dev,
> -            "%s: Tx ring %u full while queue awake!\n",
> -            dev->name, q->cntxt_id & 7);
> -      }
> +      t3_stop_queue(dev, qs, q);
> +      dev_err(&adap->pdev->dev,
> +         "%s: Tx ring %u full while queue awake!\n",
> +         dev->name, q->cntxt_id & 7);
>        spin_unlock(&q->lock);
>        return NETDEV_TX_BUSY;
>     }
>
>     q->in_use += ndesc;
> -   if (unlikely(credits - ndesc < q->stop_thres)) {
> -      q->stops++;
> -      netif_stop_queue(dev);
> -      set_bit(TXQ_ETH, &qs->txq_stopped);
> -#if !USE_GTS
> -      if (should_restart_tx(q) &&
> -          test_and_clear_bit(TXQ_ETH, &qs->txq_stopped)) {
> -         q->restarts++;
> -         netif_wake_queue(dev);
> -      }
> -#endif
> -   }
> +   if (unlikely(credits - ndesc < q->stop_thres))
> +      if (USE_GTS || !should_restart_tx(q))
> +         t3_stop_queue(dev, qs, q);
>
>     gen = q->gen;
>     q->unacked += ndesc;

