From: Michael Chan <mchan@broadcom.com>
Subject: Re: [PATCH 1/3] tg3: Limit minimum tx queue wakeup threshold
Date: Thu, 21 Aug 2014 16:26:42 -0700
Message-ID: <1408663602.7644.63.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1408474371-19509-1-git-send-email-bpoirier@suse.de>
	 <1408485647.7404.3.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <20140821220424.GB7117@f1.synalogic.ca>
	 <1408660355.7644.50.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <20140821230607.GB7724@f1.synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: Prashant Sreedharan <prashant@broadcom.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Benjamin Poirier <bpoirier@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140821230607.GB7724@f1.synalogic.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-08-21 at 16:06 -0700, Benjamin Poirier wrote: 
> On 2014/08/21 15:32, Michael Chan wrote:
> > On Thu, 2014-08-21 at 15:04 -0700, Benjamin Poirier wrote: 
> > > On 2014/08/19 15:00, Michael Chan wrote:
> > > > On Tue, 2014-08-19 at 11:52 -0700, Benjamin Poirier wrote: 
> > > > > diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> > > > > index 3ac5d23..b11c0fd 100644
> > > > > --- a/drivers/net/ethernet/broadcom/tg3.c
> > > > > +++ b/drivers/net/ethernet/broadcom/tg3.c
> > > > > @@ -202,7 +202,8 @@ static inline void _tg3_flag_clear(enum TG3_FLAGS flag, unsigned long *bits)
> > > > >  #endif
> > > > >  
> > > > >  /* minimum number of free TX descriptors required to wake up TX process */
> > > > > -#define TG3_TX_WAKEUP_THRESH(tnapi)            ((tnapi)->tx_pending / 4)
> > > > > +#define TG3_TX_WAKEUP_THRESH(tnapi)    max_t(u32, (tnapi)->tx_pending / 4, \
> > > > > +                                             MAX_SKB_FRAGS + 1)
> > > > 
> > > > I think we should precompute this and store it in something like
> > > > tp->tx_wake_thresh.
> > > 
> > > I've tried this by adding the following patch at the end of the v2
> > > series but I did not measure a significant latency improvement. Was
> > > there another reason for the change? 
> > 
> > Just performance.  The wake up threshold is checked in the tx fast path
> > in both start_xmit() and tg3_tx().  I would optimize such code for speed
> 
> I don't see what you mean. The code in those two functions that used to
> invoke TG3_TX_WAKEUP_THRESH is wrapped in unlikely() conditions. You
> can't tell me that's the fast path ;) It's only checked when the queue
> is stopped.

I missed the unlikely().  So you're right.  It's not really in the fast
path.

> 
> Moreover, the patches I've sent already add tg3_napi.wakeup_thresh. It
> is over those patches that I've made the measurements.

Right.  But my original comment was over your original patch #1 which
was adding max_t() to the macro TG3_TX_WAKE_THRESH without adding
wakeup_thresh field.  All my comments (performance and smaller code)
were based on your original patch #1.  Later I did see that your patch 3
converted TG3_TX_WAKEUP_THRESH to a structure field so it's no longer an
issue.

> 
> > as much as possible.  In the current code, it was just a right shift
> > operation.  Now, with max_t() added, I think I prefer having it
> > pre-computed.  The performance difference may not be measurable, but I
> > think the compiled code size may be smaller too.
> 
> Maybe in certain areas, but not overall:
> 
> with v2 patches 1-3
>    text    data     bss     dec     hex filename
>  149495    1247       0  150742   24cd6 drivers/net/ethernet/broadcom/tg3.o
> with v2 patches 1-3 + tx_wake_thresh_def
>    text    data     bss     dec     hex filename
>  149524    1247       0  150771   24cf3 drivers/net/ethernet/broadcom/tg3.o
> 
> I really don't see a gain.
> 

Agreed.  Once you have converted the TG3_TX_WAKEUP_THRESH to a structure
field, that's sufficient.  No need to have multiple fields.  Thanks.
