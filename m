From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: fec: fix the race between xmit and bdp
 reclaiming path
Date: Mon, 10 Aug 2015 13:28:35 -0700 (PDT)
Message-ID: <20150810.132835.492224591558177468.davem@davemloft.net>
References: <1438926757-24447-1-git-send-email-haokexin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: haokexin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44168 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754644AbbHJU2g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 16:28:36 -0400
In-Reply-To: <1438926757-24447-1-git-send-email-haokexin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kevin Hao <haokexin@gmail.com>
Date: Fri,  7 Aug 2015 13:52:37 +0800

> When we transmit a fragmented skb, we may run into a race like the
> following scenario (assume txq->cur_tx is next to txq->dirty_tx):
>            cpu 0                                          cpu 1
>   fec_enet_txq_submit_skb
>     reserve a bdp for the first fragment
>     fec_enet_txq_submit_frag_skb
>        update the bdp for the other fragment
>        update txq->cur_tx
>                                                    fec_enet_tx_queue
>                                                      bdp = fec_enet_get_nextdesc(txq->dirty_tx, fep, queue_id);
>                                                      This bdp is the bdp reserved for the first segment. Given
>                                                      that this bdp BD_ENET_TX_READY bit is not set and txq->cur_tx
>                                                      is already pointed to a bdp beyond this one. We think this is a
>                                                      completed bdp and try to reclaim it.
>     update the bdp for the first segment
>     update txq->cur_tx
> 
> So we shouldn't update the txq->cur_tx until all the update to the
> bdps used for fragments are performed. Also add the corresponding
> memory barrier to guarantee that the update to the bdps, dirty_tx and
> cur_tx performed in the proper order.
> 
> Signed-off-by: Kevin Hao <haokexin@gmail.com>

Applied, thanks.
