From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Mon, 7 Aug 2006 16:35:36 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.63.0608071628370.3576@jbrandeb-desk.amr.corp.intel.com>
References: <4807377b0608061616p5731524fvb0612bdbc32e59b@mail.gmail.com>
 <1154955036.5246.32.camel@jzny2> <20060807152126.GL24653@edgar.underground.se.axis.com>
 <1154965249.5446.15.camel@jzny2> <20060807155929.GM24653@edgar.underground.se.axis.com>
 <1154968319.5446.30.camel@jzny2> <20060807170403.GA10818@edgar.underground.se.axis.com>
 <1154973625.5446.56.camel@jzny2> <20060807184748.GA10909@edgar.underground.se.axis.com>
 <1154977413.5446.83.camel@jzny2> <20060807232340.GA11088@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jamal <hadi@cyberus.ca>,
	"Edgar E. Iglesias" <edgar.iglesias@axis.com>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	David Miller <davem@davemloft.net>, shemminger@osdl.org,
	mchan@broadcom.com, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:5548 "EHLO
	orsmga102-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S932413AbWHGXfn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 19:35:43 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060807232340.GA11088@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 8 Aug 2006, Herbert Xu wrote:
> > -#define E1000_TX_WEIGHT 64
> > -               /* weight of a sort for tx, to avoid endless transmit
> > cleanup */
> > -               if (count++ == E1000_TX_WEIGHT) break;
> > +               /* avoid endless transmit cleanup */
> > +               if (count++ == tx_ring->prunet) break;
> > 
> > As you can see E1000_TX_WEIGHT threshold exists today and you are right
> > if no TX interupts, packet arrivals or scheduled wakes happen the that
> > descriptor that was not pruned will sit there forever (which is a bad
> > thing for TCP). Are we in sync?
> > If yes, what is the likelihood they will sit there forever? I think
> > perhaps some TX interupts will happen, no?
> 
> I thought this code is only used for NAPI so as long as work was done
> it'll keep calling this.

yes, you're correct.
 
> One thing I'm not sure about though is the time between it decides that
> there is no work and the point where the interrupts are reenabled.

e1000 only clears the interrupts when it reads ICR in e1000_intr (before 
scheduling napi poll) so any interrupts that occur while polling (and 
interrupts are disabled) will cause a new assertion once interrupts are 
re-enabled.  Sometimes a little bit inefficient due to extra trips through 
poll, but guarantees never to miss an int.  I'm open to creative ways to 
avoid this, but adding an I/O read in e1000_clean would be pretty yucky.

> What if work arrives in that time and no work ever arrives after the
> interrupts are turned on again? Does that mean the work will sit there
> forever?

nope, see above.
