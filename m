From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: RE: [RFC PATCH] bnx2x: fix tx queue locking and memory barriers
Date: Thu, 25 Feb 2010 05:28:16 -0800
Message-ID: <8628FE4E7912BF47A96AE7DD7BAC0AADCB46A2ADA6@SJEXCHCCR02.corp.ad.broadcom.com>
References: <20100225140834.0169e9f2@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"David Howells" <dhowells@redhat.com>
To: "Stanislaw Gruszka" <sgruszka@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1787 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932475Ab0BYN2d convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2010 08:28:33 -0500
In-Reply-To: <20100225140834.0169e9f2@dhcp-lab-109.englab.brq.redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stanislaw,

there is no need for memory barrier in bnx2x_tx_avail() as long as they are taken outside the function the way we minimize the possibility of calls for that barrier only to the rare cases, when the ring is going to be closed (XOFF).

The same is with the smp_mb() in bnx2x_tx_int() - we don't want to call it unless we really needed and this is only in the case we need to XON the queue which is currently XOFFed.

The tx_lock() is not needed there as well. There is a slight and very hypothetical possibility for the case when we might release the queue, when it's full and then there is a possibility that bnx2x_start_xmit() will return NETIF_TX_BUSY. And even if it happens (while nobody has reported about such a case) it's not fatal.

Dave, I'm running stress tests on the patch, which will eliminate even that hypothetical issue, I've mentioned before. Once we fill confident with this patch we'll send it to u.

Thanks,
vlad


> -----Original Message-----
> From: Stanislaw Gruszka [mailto:sgruszka@redhat.com] 
> Sent: Thursday, February 25, 2010 3:09 PM
> To: netdev@vger.kernel.org; Vladislav Zolotarov
> Cc: David Miller; Eilon Greenstein; David Howells
> Subject: [RFC PATCH] bnx2x: fix tx queue locking and memory barriers
> 
> We have done some optimizations in bnx2x_start_xmit() and 
> bnx2x_tx_int(), which 
> in my opinion can lead into some theoretical race conditions. 
> 
> I can be pretty wrong here, but if so, we have to optimize 
> some other drivers,
> which use memory barriers/locking schema from that patch 
> (like tg3, bnx2).
> 
> Memory barriers here IMHO, prevent to make queue permanently 
> stopped when on one
> cpu bnx2x_tx_int() make queue empty, whereas on other cpu 
> bnx2x_start_xmit() see
> it full and make stop it, such cause queue will be stopped forever. 
> 
> I'm not quite sure what for is __netif_tx_lock, but other 
> drivers use it.
> 
> diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
> index 5adf2a0..ca91aa8 100644
> --- a/drivers/net/bnx2x_main.c
> +++ b/drivers/net/bnx2x_main.c
> @@ -893,7 +893,10 @@ static inline u16 bnx2x_tx_avail(struct 
> bnx2x_fastpath *fp)
>  	u16 prod;
>  	u16 cons;
>  
> -	barrier(); /* Tell compiler that prod and cons can change */
> +	/* prod and cons can change on other cpu, want to see
> +	   consistend available space and queue (stop/running) state */
> +	smp_mb();
> +
>  	prod = fp->tx_bd_prod;
>  	cons = fp->tx_bd_cons;
>  
> @@ -957,21 +960,23 @@ static int bnx2x_tx_int(struct 
> bnx2x_fastpath *fp)
>  	fp->tx_pkt_cons = sw_cons;
>  	fp->tx_bd_cons = bd_cons;
>  
> +	/* Need to make the tx_bd_cons update visible to start_xmit()
> +	 * before checking for netif_tx_queue_stopped().  Without the
> +	 * memory barrier, there is a small possibility that 
> start_xmit()
> +	 * will miss it and cause the queue to be stopped forever. This
> +	 * can happen when we make queue empty here, when on other cpu
> +	 * start_xmit() still see it becoming full and stop.
> +	 */
> +	smp_mb();
> +
>  	/* TBD need a thresh? */
>  	if (unlikely(netif_tx_queue_stopped(txq))) {
> -
> -		/* Need to make the tx_bd_cons update visible 
> to start_xmit()
> -		 * before checking for 
> netif_tx_queue_stopped().  Without the
> -		 * memory barrier, there is a small possibility that
> -		 * start_xmit() will miss it and cause the 
> queue to be stopped
> -		 * forever.
> -		 */
> -		smp_mb();
> -
> +		__netif_tx_lock(txq, smp_processor_id());
>  		if ((netif_tx_queue_stopped(txq)) &&
>  		    (bp->state == BNX2X_STATE_OPEN) &&
>  		    (bnx2x_tx_avail(fp) >= MAX_SKB_FRAGS + 3))
>  			netif_tx_wake_queue(txq);
> +		__netif_tx_unlock(txq);
>  	}
>  	return 0;
>  }
> 
> 
> 
> 
> 
