From: Benjamin Poirier <bpoirier@suse.de>
Subject: Re: [PATCH 1/3] tg3: Limit minimum tx queue wakeup threshold
Date: Thu, 21 Aug 2014 16:06:07 -0700
Message-ID: <20140821230607.GB7724@f1.synalogic.ca>
References: <1408474371-19509-1-git-send-email-bpoirier@suse.de>
 <1408485647.7404.3.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
 <20140821220424.GB7117@f1.synalogic.ca>
 <1408660355.7644.50.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Prashant Sreedharan <prashant@broadcom.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:50374 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752342AbaHUXGP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Aug 2014 19:06:15 -0400
Content-Disposition: inline
In-Reply-To: <1408660355.7644.50.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/08/21 15:32, Michael Chan wrote:
> On Thu, 2014-08-21 at 15:04 -0700, Benjamin Poirier wrote: 
> > On 2014/08/19 15:00, Michael Chan wrote:
> > > On Tue, 2014-08-19 at 11:52 -0700, Benjamin Poirier wrote: 
> > > > diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> > > > index 3ac5d23..b11c0fd 100644
> > > > --- a/drivers/net/ethernet/broadcom/tg3.c
> > > > +++ b/drivers/net/ethernet/broadcom/tg3.c
> > > > @@ -202,7 +202,8 @@ static inline void _tg3_flag_clear(enum TG3_FLAGS flag, unsigned long *bits)
> > > >  #endif
> > > >  
> > > >  /* minimum number of free TX descriptors required to wake up TX process */
> > > > -#define TG3_TX_WAKEUP_THRESH(tnapi)            ((tnapi)->tx_pending / 4)
> > > > +#define TG3_TX_WAKEUP_THRESH(tnapi)    max_t(u32, (tnapi)->tx_pending / 4, \
> > > > +                                             MAX_SKB_FRAGS + 1)
> > > 
> > > I think we should precompute this and store it in something like
> > > tp->tx_wake_thresh.
> > 
> > I've tried this by adding the following patch at the end of the v2
> > series but I did not measure a significant latency improvement. Was
> > there another reason for the change? 
> 
> Just performance.  The wake up threshold is checked in the tx fast path
> in both start_xmit() and tg3_tx().  I would optimize such code for speed

I don't see what you mean. The code in those two functions that used to
invoke TG3_TX_WAKEUP_THRESH is wrapped in unlikely() conditions. You
can't tell me that's the fast path ;) It's only checked when the queue
is stopped.

Moreover, the patches I've sent already add tg3_napi.wakeup_thresh. It
is over those patches that I've made the measurements.

> as much as possible.  In the current code, it was just a right shift
> operation.  Now, with max_t() added, I think I prefer having it
> pre-computed.  The performance difference may not be measurable, but I
> think the compiled code size may be smaller too.

Maybe in certain areas, but not overall:

with v2 patches 1-3
   text    data     bss     dec     hex filename
 149495    1247       0  150742   24cd6 drivers/net/ethernet/broadcom/tg3.o
with v2 patches 1-3 + tx_wake_thresh_def
   text    data     bss     dec     hex filename
 149524    1247       0  150771   24cf3 drivers/net/ethernet/broadcom/tg3.o

I really don't see a gain.

> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
