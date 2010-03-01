From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 1/1] bnx2x: Tx barriers and locks
Date: Mon, 1 Mar 2010 09:59:07 -0800
Message-ID: <1267466347.19491.31.camel@nseg_linux_HP1.broadcom.com>
References: <1267351922.10409.2.camel@lb-tlvb-vladz>
 <20100301133339.GB2440@dhcp-lab-161.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Vladislav Zolotarov" <vladz@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Matthew Carlson" <mcarlson@broadcom.com>
To: "Stanislaw Gruszka" <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4751 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752427Ab0CASLU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Mar 2010 13:11:20 -0500
In-Reply-To: <20100301133339.GB2440@dhcp-lab-161.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2010-03-01 at 05:33 -0800, Stanislaw Gruszka wrote:
> On Sun, Feb 28, 2010 at 12:12:02PM +0200, Vladislav Zolotarov wrote:
> > --- a/drivers/net/bnx2x_main.c
> > +++ b/drivers/net/bnx2x_main.c
> > @@ -57,8 +57,8 @@
> >  #include "bnx2x_init_ops.h"
> >  #include "bnx2x_dump.h"
> >  
> > -#define DRV_MODULE_VERSION	"1.52.1-6"
> > -#define DRV_MODULE_RELDATE	"2010/02/16"
> > +#define DRV_MODULE_VERSION	"1.52.1-7"
> > +#define DRV_MODULE_RELDATE	"2010/02/28"
> >  #define BNX2X_BC_VER		0x040200
> >  
> >  #include <linux/firmware.h>
> > @@ -957,21 +957,34 @@ static int bnx2x_tx_int(struct bnx2x_fastpath *fp)
> >  	fp->tx_pkt_cons = sw_cons;
> >  	fp->tx_bd_cons = bd_cons;
> >  
> > +	/* Need to make the tx_bd_cons update visible to start_xmit()
> > +	 * before checking for netif_tx_queue_stopped().  Without the
> > +	 * memory barrier, there is a small possibility that
> > +	 * start_xmit() will miss it and cause the queue to be stopped
> > +	 * forever.
> > +	 */
> > +	smp_wmb();
> > +
> >  	/* TBD need a thresh? */
> >  	if (unlikely(netif_tx_queue_stopped(txq))) {
> > -
> > -		/* Need to make the tx_bd_cons update visible to start_xmit()
> > -		 * before checking for netif_tx_queue_stopped().  Without the
> > -		 * memory barrier, there is a small possibility that
> > -		 * start_xmit() will miss it and cause the queue to be stopped
> > -		 * forever.
> > +		/* Taking tx_lock() is needed to prevent reenabling the queue
> > +		 * while it's empty. This could have happen if rx_action() gets
> > +		 * suspended in bnx2x_tx_int() after the condition before
> > +		 * netif_tx_wake_queue(), while tx_action (bnx2x_start_xmit()):
> > +		 *
> > +		 * stops the queue->sees fresh tx_bd_cons->releases the queue->
> > +		 * sends some packets consuming the whole queue again->
> > +		 * stops the queue
> >  		 */
> > -		smp_mb();
> > +
> > +		__netif_tx_lock(txq, smp_processor_id());
> >  
> >  		if ((netif_tx_queue_stopped(txq)) &&
> >  		    (bp->state == BNX2X_STATE_OPEN) &&
> >  		    (bnx2x_tx_avail(fp) >= MAX_SKB_FRAGS + 3))
> >  			netif_tx_wake_queue(txq);
> > +
> > +		__netif_tx_unlock(txq);
> >  	}
> >  	return 0;
> >  }
> 
> There is still difference between what we have in bnx2x and bnx2/tg3
> regarding memory barriers in tx_poll/start_xmit code. Mainly we have
> smp_mb() in bnx2/tg3_tx_avail(), and in bnx2/tg3_tx_int() is smp_mb()
> not smp_wmb(). I do not see that bnx2x is wrong, but would like to know
> why there is a difference, maybe bnx2/tg3 should be changed?
> 

The memory barrier in tx_int() is to make the tx index update happen
before the netif_tx_queue_stopped() check.  The barrier is to prevent a
situation like this:

    CPU0					CPU1
    start_xmit()
    	if (tx_ring_full) {
    						tx_int()
    							if (!netif_tx_queue_stopped)
    		netif_tx_stop_queue()
    		if (!tx_ring_full)
    							update_tx_index 
    			netif_tx_wake_queue()
    	}
    

The update_tx_index code is before the if statement in program order,
but the CPU and/or compiler can reorder it as shown above. smp_mb() will
prevent that.  Will smp_wmb() prevent that as well?


