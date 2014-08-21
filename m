From: Michael Chan <mchan@broadcom.com>
Subject: Re: [PATCH 1/3] tg3: Limit minimum tx queue wakeup threshold
Date: Thu, 21 Aug 2014 15:32:35 -0700
Message-ID: <1408660355.7644.50.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1408474371-19509-1-git-send-email-bpoirier@suse.de>
	 <1408485647.7404.3.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <20140821220424.GB7117@f1.synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: Prashant Sreedharan <prashant@broadcom.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Benjamin Poirier <bpoirier@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140821220424.GB7117@f1.synalogic.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-08-21 at 15:04 -0700, Benjamin Poirier wrote: 
> On 2014/08/19 15:00, Michael Chan wrote:
> > On Tue, 2014-08-19 at 11:52 -0700, Benjamin Poirier wrote: 
> > > diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> > > index 3ac5d23..b11c0fd 100644
> > > --- a/drivers/net/ethernet/broadcom/tg3.c
> > > +++ b/drivers/net/ethernet/broadcom/tg3.c
> > > @@ -202,7 +202,8 @@ static inline void _tg3_flag_clear(enum TG3_FLAGS flag, unsigned long *bits)
> > >  #endif
> > >  
> > >  /* minimum number of free TX descriptors required to wake up TX process */
> > > -#define TG3_TX_WAKEUP_THRESH(tnapi)            ((tnapi)->tx_pending / 4)
> > > +#define TG3_TX_WAKEUP_THRESH(tnapi)    max_t(u32, (tnapi)->tx_pending / 4, \
> > > +                                             MAX_SKB_FRAGS + 1)
> > 
> > I think we should precompute this and store it in something like
> > tp->tx_wake_thresh.
> 
> I've tried this by adding the following patch at the end of the v2
> series but I did not measure a significant latency improvement. Was
> there another reason for the change? 

Just performance.  The wake up threshold is checked in the tx fast path
in both start_xmit() and tg3_tx().  I would optimize such code for speed
as much as possible.  In the current code, it was just a right shift
operation.  Now, with max_t() added, I think I prefer having it
pre-computed.  The performance difference may not be measurable, but I
think the compiled code size may be smaller too.
