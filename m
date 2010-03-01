From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH 1/1] bnx2x: Tx barriers and locks
Date: Mon, 1 Mar 2010 14:33:40 +0100
Message-ID: <20100301133339.GB2440@dhcp-lab-161.englab.brq.redhat.com>
References: <1267351922.10409.2.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, eilong@broadcom.com,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: Vladislav Zolotarov <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39750 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750836Ab0CANfe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Mar 2010 08:35:34 -0500
Content-Disposition: inline
In-Reply-To: <1267351922.10409.2.camel@lb-tlvb-vladz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 28, 2010 at 12:12:02PM +0200, Vladislav Zolotarov wrote:
> --- a/drivers/net/bnx2x_main.c
> +++ b/drivers/net/bnx2x_main.c
> @@ -57,8 +57,8 @@
>  #include "bnx2x_init_ops.h"
>  #include "bnx2x_dump.h"
>  
> -#define DRV_MODULE_VERSION	"1.52.1-6"
> -#define DRV_MODULE_RELDATE	"2010/02/16"
> +#define DRV_MODULE_VERSION	"1.52.1-7"
> +#define DRV_MODULE_RELDATE	"2010/02/28"
>  #define BNX2X_BC_VER		0x040200
>  
>  #include <linux/firmware.h>
> @@ -957,21 +957,34 @@ static int bnx2x_tx_int(struct bnx2x_fastpath *fp)
>  	fp->tx_pkt_cons = sw_cons;
>  	fp->tx_bd_cons = bd_cons;
>  
> +	/* Need to make the tx_bd_cons update visible to start_xmit()
> +	 * before checking for netif_tx_queue_stopped().  Without the
> +	 * memory barrier, there is a small possibility that
> +	 * start_xmit() will miss it and cause the queue to be stopped
> +	 * forever.
> +	 */
> +	smp_wmb();
> +
>  	/* TBD need a thresh? */
>  	if (unlikely(netif_tx_queue_stopped(txq))) {
> -
> -		/* Need to make the tx_bd_cons update visible to start_xmit()
> -		 * before checking for netif_tx_queue_stopped().  Without the
> -		 * memory barrier, there is a small possibility that
> -		 * start_xmit() will miss it and cause the queue to be stopped
> -		 * forever.
> +		/* Taking tx_lock() is needed to prevent reenabling the queue
> +		 * while it's empty. This could have happen if rx_action() gets
> +		 * suspended in bnx2x_tx_int() after the condition before
> +		 * netif_tx_wake_queue(), while tx_action (bnx2x_start_xmit()):
> +		 *
> +		 * stops the queue->sees fresh tx_bd_cons->releases the queue->
> +		 * sends some packets consuming the whole queue again->
> +		 * stops the queue
>  		 */
> -		smp_mb();
> +
> +		__netif_tx_lock(txq, smp_processor_id());
>  
>  		if ((netif_tx_queue_stopped(txq)) &&
>  		    (bp->state == BNX2X_STATE_OPEN) &&
>  		    (bnx2x_tx_avail(fp) >= MAX_SKB_FRAGS + 3))
>  			netif_tx_wake_queue(txq);
> +
> +		__netif_tx_unlock(txq);
>  	}
>  	return 0;
>  }

There is still difference between what we have in bnx2x and bnx2/tg3
regarding memory barriers in tx_poll/start_xmit code. Mainly we have
smp_mb() in bnx2/tg3_tx_avail(), and in bnx2/tg3_tx_int() is smp_mb()
not smp_wmb(). I do not see that bnx2x is wrong, but would like to know
why there is a difference, maybe bnx2/tg3 should be changed?

Stanislaw
