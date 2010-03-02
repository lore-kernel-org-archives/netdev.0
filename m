From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: RE: [PATCH 1/1] bnx2x: Tx barriers and locks
Date: Tue, 2 Mar 2010 02:38:39 -0800
Message-ID: <8628FE4E7912BF47A96AE7DD7BAC0AADCB46A2B3FE@SJEXCHCCR02.corp.ad.broadcom.com>
References: <1267351922.10409.2.camel@lb-tlvb-vladz>
 <20100301133339.GB2440@dhcp-lab-161.englab.brq.redhat.com>
 <1267466347.19491.31.camel@nseg_linux_HP1.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Matthew Carlson" <mcarlson@broadcom.com>
To: "Michael Chan" <mchan@broadcom.com>,
	"Stanislaw Gruszka" <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1828 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751753Ab0CBKir convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Mar 2010 05:38:47 -0500
In-Reply-To: <1267466347.19491.31.camel@nseg_linux_HP1.broadcom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was assuming that there is an implicit read memory barrier in the construction

if (unlikely(netif_tx_queue_stopped(txq)))

I assumed it looking at the other kernel code using test_bit() in conditional constructions (like net_tx_action()).

After reading a Pentium Developers Manual I'm afraid I might have assumed wrong and there is needed a read memory barrier to ensure that the bit testing is performed not earlier the specified location in the code flow (due to CPU reordering).

Dave, as an author of atomic_ops.txt paper I think u r the best man to ask. Could u pls. clarify that if we need to ensure that the bit testing is needed AFTER the consumer update (namely after the smp_wmb()) I need to replace it with the smp_mb().

If yes, it's a clear bug and I'll prepare an appropriate patch immediately.

Thanks,
vlad

> -----Original Message-----
> From: Michael Chan [mailto:mchan@broadcom.com] 
> Sent: Monday, March 01, 2010 7:59 PM
> To: Stanislaw Gruszka
> Cc: Vladislav Zolotarov; netdev@vger.kernel.org; 
> davem@davemloft.net; Eilon Greenstein; Matthew Carlson
> Subject: Re: [PATCH 1/1] bnx2x: Tx barriers and locks
> 
> 
> On Mon, 2010-03-01 at 05:33 -0800, Stanislaw Gruszka wrote:
> > On Sun, Feb 28, 2010 at 12:12:02PM +0200, Vladislav Zolotarov wrote:
> > > --- a/drivers/net/bnx2x_main.c
> > > +++ b/drivers/net/bnx2x_main.c
> > > @@ -57,8 +57,8 @@
> > >  #include "bnx2x_init_ops.h"
> > >  #include "bnx2x_dump.h"
> > >  
> > > -#define DRV_MODULE_VERSION	"1.52.1-6"
> > > -#define DRV_MODULE_RELDATE	"2010/02/16"
> > > +#define DRV_MODULE_VERSION	"1.52.1-7"
> > > +#define DRV_MODULE_RELDATE	"2010/02/28"
> > >  #define BNX2X_BC_VER		0x040200
> > >  
> > >  #include <linux/firmware.h>
> > > @@ -957,21 +957,34 @@ static int bnx2x_tx_int(struct 
> bnx2x_fastpath *fp)
> > >  	fp->tx_pkt_cons = sw_cons;
> > >  	fp->tx_bd_cons = bd_cons;
> > >  
> > > +	/* Need to make the tx_bd_cons update visible to start_xmit()
> > > +	 * before checking for netif_tx_queue_stopped().  Without the
> > > +	 * memory barrier, there is a small possibility that
> > > +	 * start_xmit() will miss it and cause the queue to be stopped
> > > +	 * forever.
> > > +	 */
> > > +	smp_wmb();
> > > +
> > >  	/* TBD need a thresh? */
> > >  	if (unlikely(netif_tx_queue_stopped(txq))) {
> > > -
> > > -		/* Need to make the tx_bd_cons update visible 
> to start_xmit()
> > > -		 * before checking for 
> netif_tx_queue_stopped().  Without the
> > > -		 * memory barrier, there is a small possibility that
> > > -		 * start_xmit() will miss it and cause the 
> queue to be stopped
> > > -		 * forever.
> > > +		/* Taking tx_lock() is needed to prevent 
> reenabling the queue
> > > +		 * while it's empty. This could have happen if 
> rx_action() gets
> > > +		 * suspended in bnx2x_tx_int() after the 
> condition before
> > > +		 * netif_tx_wake_queue(), while tx_action 
> (bnx2x_start_xmit()):
> > > +		 *
> > > +		 * stops the queue->sees fresh 
> tx_bd_cons->releases the queue->
> > > +		 * sends some packets consuming the whole queue again->
> > > +		 * stops the queue
> > >  		 */
> > > -		smp_mb();
> > > +
> > > +		__netif_tx_lock(txq, smp_processor_id());
> > >  
> > >  		if ((netif_tx_queue_stopped(txq)) &&
> > >  		    (bp->state == BNX2X_STATE_OPEN) &&
> > >  		    (bnx2x_tx_avail(fp) >= MAX_SKB_FRAGS + 3))
> > >  			netif_tx_wake_queue(txq);
> > > +
> > > +		__netif_tx_unlock(txq);
> > >  	}
> > >  	return 0;
> > >  }
> > 
> > There is still difference between what we have in bnx2x and bnx2/tg3
> > regarding memory barriers in tx_poll/start_xmit code. Mainly we have
> > smp_mb() in bnx2/tg3_tx_avail(), and in bnx2/tg3_tx_int() 
> is smp_mb()
> > not smp_wmb(). I do not see that bnx2x is wrong, but would 
> like to know
> > why there is a difference, maybe bnx2/tg3 should be changed?
> > 
> 
> The memory barrier in tx_int() is to make the tx index update happen
> before the netif_tx_queue_stopped() check.  The barrier is to 
> prevent a
> situation like this:
> 
>     CPU0					CPU1
>     start_xmit()
>     	if (tx_ring_full) {
>     						tx_int()
>     							if 
> (!netif_tx_queue_stopped)
>     		netif_tx_stop_queue()
>     		if (!tx_ring_full)
>     							update_tx_index 
>     			netif_tx_wake_queue()
>     	}
>     
> 
> The update_tx_index code is before the if statement in program order,
> but the CPU and/or compiler can reorder it as shown above. 
> smp_mb() will
> prevent that.  Will smp_wmb() prevent that as well?
> 
> 
