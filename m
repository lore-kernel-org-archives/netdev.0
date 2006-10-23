From: Russell Stuart <russell-tcatm@stuart.id.au>
Subject: Re: [PATCH REPOST 1/2] NET: Accurate packet
	scheduling	for	ATM/ADSL (kernel)
Date: Tue, 24 Oct 2006 07:54:04 +1000
Message-ID: <1161640444.5502.214.camel@ras.pc.stuart.local>
References: <1161041677.6247.1.camel@ras.pc.brisbane.lube>
	 <1161090444.5555.13.camel@jzny2>  <45378DE3.8080700@trash.net>
	 <1161602527.5502.155.camel@ras.pc.stuart.local>
	 <453CB801.4010902@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 58.105.229.78.optusnet.com.au ([58.105.229.78]:2795 "EHLO
	adsl-kenny.stuart.id.au") by vger.kernel.org with ESMTP
	id S1752026AbWJWVyg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Oct 2006 17:54:36 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <453CB801.4010902@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-10-23 at 14:39 +0200, Patrick McHardy wrote:
> The implementation may be different, but the intention and the
> result is the same. I probably would mind less if it wouldn't
> affect userspace compatibility, but we need to carry this stuff
> for ever even if we add another implementation that covers all
> qdiscs.

So where is the overlap?  Your patch will make qdiscs
that use packet length work with ATM.  Ours makes the
rest, ie those that use Alexy's RTAB, work with ATM.
They would probably both apply with minimal conflicts.
You have previously said you have no intention of 
changing the current RTAB implantation with your STAB
patch.

As an aside non-work conserving qdisc's that do 
scheduling are the real targets of ATM patch.  The 
rest are not effected by ATM overly.  The only one 
of those that doesn't use Alexy's RTAB is the one you 
introduced - HFSC.  You are the best person to fix
things so HFSC does work with ATM, and that is what
I thought you were doing with the STAB patch.

> What do I need to explain further? As I stated several times,
> I would like to see a patch that handles all qdiscs. And it
> should probably not have hardcoded ATM values, there is other
> media that behaves similar.

I am not aware of other media that behaves in a similar
way, although I am no expert.  What have I missed?  The
hard coded ATM values don't effect this patch btw, they
are a user space thing only.

> >>Besides that:
> >>
> >>+static inline u32 qdisc_l2t(struct qdisc_rate_table* rtab, int pktlen)
> >>+{
> >>+	int slot = pktlen + rtab->rate.cell_align;
> >>+	if (slot < 0)
> >>+	  	slot = 0;
> >>
> >>Why would it go negative? A negative cell_align doesn't make sense I
> >>guess.
> > 
> > 
> > A negative cell align is possible, and in fact is typical.
> > If slot ended up being less than 0 then the configuration
> > parameters passed to "tc" would of been wrong - they could
> > not of matched the actual traffic.  The error can't be 
> > detected in "tc", but it can't be allowed to cause the
> > kernel to index off the end of an array either.
> 
> I'm not sure I understand what you're saying here. The transmission
> time gets _smaller_ by transmitting over ATM? Does this have anything
> to do with the off-by-one during rate table calculation you or
> Jesper noticed?

There is nothing I would describe as an "off-by-one
error" in the RTAB calculation, so I can't be sure
what you are referring to.  The packetisation done
by ATM does introduce rounding / truncation errors
of up to ((1 << cell_log) - 1).  Negative cell 
alignments is the easiest way to fix that.

> >>+	slot >>= rtab->rate.cell_log;
> >>+	if (slot > 255)
> >>+		return rtab->data[255] + 1;
> >>
> >>Whats the point of this? Is it just to keep htb giant statistics
> >>working?
> > 
> > 
> > Yes.
> 
> TBF and policers already make sure this can never happen, this is
> what HTB should do as well. If it is also needed for CBQ it is
> a bugfix and should be done seperately.

OK.  I will change it.

