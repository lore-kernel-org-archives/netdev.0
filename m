From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: in-driver QoS
Date: Wed, 9 Jun 2004 10:40:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040609174021.GA26159@bougret.hpl.hp.com>
References: <20040608184831.GA18462@bougret.hpl.hp.com> <1086722317.1023.18.camel@jzny.localdomain> <20040608195238.GA21089@bougret.hpl.hp.com> <1086728139.1023.71.camel@jzny.localdomain> <20040608220109.GA24536@bougret.hpl.hp.com> <1086752809.1049.62.camel@jzny.localdomain>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1086752809.1049.62.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jun 08, 2004 at 11:46:49PM -0400, jamal wrote:
> On Tue, 2004-06-08 at 18:01, Jean Tourrilhes wrote:
> 
> > 	Yep. This impact the contention process.
> > 	This is similar to what was implemented in 100VG / IEEE
> > 802.12, but in more elaborated.
> 
> so the only differentiation is on backoff and contention window
> parameters. In other words, higher prio will get opportunity to be more
> of a hog or aggressive?

	Yep. It's like a fast pass to cut the line at DisneyWorld.

> > There is 4 FIFOs (or whichever number then want to configure)
> > in parallel.
> > Most likely, the FIFOs will share the same memory pool on the
> > card, so when a FIFO is full, most likely the other FIFOs will be full
> > or close to it.
> 
> How do you reach such a conclusion?
> There maybe packets of the same priority for longs periods of time.

	If all the FIFO take from the same memory pool, when one FIFO
is full, it means that the memory pool is exhausted. If the memory
pool is exhausted, then you can't fill the other FIFOs.

> But then you loose sync with the qdisc level scheduling.
> Assume a burst of low prio packets arrive, they get drained to the low
> prio FIFO in the driver. It gets full and now we lock the driver.
> Next a burst of high prio packets come in and they cantt be sent to the
> driver until all low prio packets already on FIFO are sent.

	Yep. That's no worse than what we have today with a single
FIFO in today's cards. Remember that amount of buffer on the card is
limited, so we are not talking of an incredible number of packets in
those FIFO. I'm 100% with Andy in suggesting to keep hardware FIFO as
short as possible, precisely so that the TC scheduling is effective.
	If you let the card scheduler take over, it will screw up your
TC scheduling no matter what, unless the card scheduler use the exact
same scheduling as TC (which is unlikely for complex TC policies).
	If the card policy is to always drain the highest priority
queue first, and you want to guarantee a minimum bandwidth for low
priority traffic at the TC level, if you let the card scheduler do its
business and always feed high priority traffic when it wants it, then
there is no way you can guarantee your minimum bandwidth for low
priority traffic.

> > But, we are talking there as if the hardware was going to have
> > some incredibly smart scheduler across FIFOs. From my experience with
> > wireless MAC implementations, the behaviour will be really simplistic
> > (always send from the highest priority FIFO), if not totally
> > broken. 
> 
> "Always send from highest priority" is fine.

	No, it's fine only if TC policy is "Always send from highest
priority". If TC policy is different, then it's not fine at all.

> Its what the default linux
> scheduler and the prio qdisc do. A lot of research and experienece has
> gone into understanding their behaviors.
> Perhaps you could tell users to configure such prioritization when using
> these NICs.

	You assume that the card scheduler will be configurable, and
work as expected. Wait and see ;-)

> We need to make chnages and do it properly. 
> Your approach to use only one priority/FIFO is not sane. 
> Of course the wireless people dont have to use it - Although that will
> be a mistake. I have a NIC that has two DMA channels which i plan to map
> to X priority levels at the the qdisc levels. 

	Good luck ;-)

> cheers,
> jamal

	Have fun...

	Jean
