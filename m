From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 5/5] net: mvneta: replace Tx timer with a real interrupt
Date: Tue, 14 Jan 2014 08:30:20 +0100
Message-ID: <20140114073020.GD27536@1wt.eu>
References: <1389519069-1619-1-git-send-email-w@1wt.eu> <1389519069-1619-6-git-send-email-w@1wt.eu> <87y52jeack.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:55351 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751065AbaANHa0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 02:30:26 -0500
Content-Disposition: inline
In-Reply-To: <87y52jeack.fsf@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 14, 2014 at 12:22:03AM +0100, Arnaud Ebalard wrote:
> Hi Willy,
> 
> Willy Tarreau <w@1wt.eu> writes:
> 
> > @@ -1935,14 +1907,22 @@ static int mvneta_poll(struct napi_struct *napi, int budget)
> >  
> >  	/* Read cause register */
> >  	cause_rx_tx = mvreg_read(pp, MVNETA_INTR_NEW_CAUSE) &
> > -		MVNETA_RX_INTR_MASK(rxq_number);
> > +		(MVNETA_RX_INTR_MASK(rxq_number) | MVNETA_TX_INTR_MASK(txq_number));
> > +
> > +	/* Release Tx descriptors */
> > +	if (cause_rx_tx & MVNETA_TX_INTR_MASK_ALL) {
> > +		int tx_todo = 0;
> > +
> > +		mvneta_tx_done_gbe(pp, (cause_rx_tx & MVNETA_TX_INTR_MASK_ALL), &tx_todo);
> > +		cause_rx_tx &= ~MVNETA_TX_INTR_MASK_ALL;
> > +	}
> 
> Unless I missed something, tx_todo above is just here to make the
> compiler happy w/ current prototype of mvneta_tx_done_gbe() but is
> otherwise unused: you could simply remove the third parameter of the
> function (it is only used here) and remove tx_todo.

A number of such changes could be done but should be merged separately,
along with the cleanup and improvement series.

> Additionally, as you do not use the return value of the function, you
> could probably make it void and spare some additional cycles by removing
> the computation of the return value. While at it, mvneta_txq_done()
> could also be made void.
> 
> The patch below gives the idea, it's compile-tested only and applies on
> your whole set (fixes + perf).

You should propose your patches for net-next on top of my series, really,
it's not too late.

Please see my comments below.

> Index: linux/drivers/net/ethernet/marvell/mvneta.c
> ===================================================================
> --- linux.orig/drivers/net/ethernet/marvell/mvneta.c	2014-01-14 00:07:18.728729578 +0100
> +++ linux/drivers/net/ethernet/marvell/mvneta.c	2014-01-14 00:11:57.740949448 +0100
> @@ -1314,25 +1314,23 @@
>  }
>  
>  /* Handle end of transmission */
> -static int mvneta_txq_done(struct mvneta_port *pp,
> +static void mvneta_txq_done(struct mvneta_port *pp,
>  			   struct mvneta_tx_queue *txq)
>  {
>  	struct netdev_queue *nq = netdev_get_tx_queue(pp->dev, txq->id);
>  	int tx_done;
>  
>  	tx_done = mvneta_txq_sent_desc_proc(pp, txq);
> -	if (tx_done == 0)
> -		return tx_done;
> -	mvneta_txq_bufs_free(pp, txq, tx_done);
> +	if (tx_done) {
> +		mvneta_txq_bufs_free(pp, txq, tx_done);

Better just use "if (tx_done == 0) return" above and avoid adding an
extra indent level by inverting the if, that makes the code more readable.

> -	txq->count -= tx_done;
> +		txq->count -= tx_done;
>  
> -	if (netif_tx_queue_stopped(nq)) {
> -		if (txq->size - txq->count >= MAX_SKB_FRAGS + 1)
> -			netif_tx_wake_queue(nq);
> +		if (netif_tx_queue_stopped(nq)) {
> +			if (txq->size - txq->count >= MAX_SKB_FRAGS + 1)
> +				netif_tx_wake_queue(nq);
> +		}
>  	}
> -
> -	return tx_done;
>  }
>  
>  static void *mvneta_frag_alloc(const struct mvneta_port *pp)
> @@ -1704,30 +1702,23 @@
>  /* Handle tx done - called in softirq context. The <cause_tx_done> argument
>   * must be a valid cause according to MVNETA_TXQ_INTR_MASK_ALL.
>   */
> -static u32 mvneta_tx_done_gbe(struct mvneta_port *pp, u32 cause_tx_done,
> -			      int *tx_todo)
> +static void mvneta_tx_done_gbe(struct mvneta_port *pp, u32 cause_tx_done)
>  {
>  	struct mvneta_tx_queue *txq;
> -	u32 tx_done = 0;
>  	struct netdev_queue *nq;
>  
> -	*tx_todo = 0;
>  	while (cause_tx_done) {
>  		txq = mvneta_tx_done_policy(pp, cause_tx_done);
>  
>  		nq = netdev_get_tx_queue(pp->dev, txq->id);
>  		__netif_tx_lock(nq, smp_processor_id());
>  
> -		if (txq->count) {
> -			tx_done += mvneta_txq_done(pp, txq);
> -			*tx_todo += txq->count;
> -		}
> +		if (txq->count)
> +			mvneta_txq_done(pp, txq);
>  
>  		__netif_tx_unlock(nq);
>  		cause_tx_done &= ~((1 << txq->id));
>  	}
> -
> -	return tx_done;
>  }

Seems fine.

>  /* Compute crc8 of the specified address, using a unique algorithm ,
> @@ -1961,9 +1952,7 @@
>  
>  	/* Release Tx descriptors */
>  	if (cause_rx_tx & MVNETA_TX_INTR_MASK_ALL) {
> -		int tx_todo = 0;
> -
> -		mvneta_tx_done_gbe(pp, (cause_rx_tx & MVNETA_TX_INTR_MASK_ALL), &tx_todo);
> +		mvneta_tx_done_gbe(pp, (cause_rx_tx & MVNETA_TX_INTR_MASK_ALL));
>  		cause_rx_tx &= ~MVNETA_TX_INTR_MASK_ALL;
>  	}

Seems fine as well.

Thanks!
Willy
