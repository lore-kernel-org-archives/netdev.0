From: Russell Stuart <russell-tcatm@stuart.id.au>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Thu, 20 Jul 2006 14:56:04 +1000
Message-ID: <1153371364.4231.61.camel@ras.pc.brisbane.lube>
References: <1150278004.26181.35.camel@localhost.localdomain>
	 <1150286766.5233.15.camel@jzny2>
	 <1150287983.3246.27.camel@ras.pc.brisbane.lube>
	 <1150292693.5197.1.camel@jzny2>
	 <1150843471.17455.2.camel@ras.pc.brisbane.lube>
	 <15653CE98281AD4FBD7F70BCEE3666E53CD54A@comxexch01.comx.local>
	 <1151000966.5392.34.camel@jzny2>
	 <1151066247.4217.254.camel@ras.pc.brisbane.lube>
	 <1151158431.6716.95.camel@jzny2>
	 <1153188409.13145.5.camel@ras.pc.brisbane.lube>
	 <44BD56A4.9090002@andyfurniss.entadsl.com>
	 <1153270932.4242.60.camel@ras.pc.brisbane.lube>
	 <44BE46A6.8000207@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: lists@andyfurniss.entadsl.com, hadi@cyberus.ca,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 58.105.229.78.optusnet.com.au ([58.105.229.78]:34983 "EHLO
	adsl-kenny.stuart.id.au") by vger.kernel.org with ESMTP
	id S932567AbWGTE5J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jul 2006 00:57:09 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <44BE46A6.8000207@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-07-19 at 16:50 +0200, Patrick McHardy wrote:
> Please excuse my silence, I was travelling and am still catching up
> with my mails.

Sorry.  Had I realised you were busy I would of
waited.

> > - As it stands, it doesn't help the qdiscs that use 
> >   RTAB.  So unless he proposes to remove RTAB entirely 
> >   the ATM patch as it will still have to go in.
> 
> Why? The length calculated by my STABs (or something similar)
> is used by _all_ qdiscs. Not only for transmission time calculation,
> but also for statistics and estimators.

Oh.  I didn't see where it is used for the time 
calculation in your patch.  Did I miss something,
or is that the unfinished bit?

This is possibly my stumbling block.  If you don't remove
RTAB the ATM patch as stands will be needed.  Your patch
didn't remove RTAB, and you didn't say it was intended to,
so I presume it wasn't going to.

>  If the length calculation
> doesn't fit for ATM, that can be fixed.

Yes of course.  Just to be clear: as far as I am concerned
this never was an issue.

> > - A bit of effort was put into making this current
> >   ATM patch both backwards and forwards compatible.
> >   Patricks patch would work with newer kernels,
> >   obviously.  Older kernels, and in particular the
> >   kernel that Debian is Etch is likely to distribute
> >   would miss out.
> 
> True, but it provides more consistency, and making current
> kernels behave better is more important than old kernels.

I guess provided the new "tc" works with older kernels this
is OK - although a disappoint to me.  Works here being defined
as "works as well as a previous the version of tc does".  For 
me not working would be OK as well provided "tc" issued a 
warning message to the effect that it "needs kernel version 
XXX or above"", but doing that would probably require it to 
look at the kernel version.  Looking at the kernel version 
in tc seems to be frowned upon.

> You seem to have misunderstood my patch. It doesn't need to
> touch RTABs, it just calculates the packet length as seen
> on the wire (whereever it is) and uses that thoughout the
> entire qdisc layer.

No, you have it in reverse - as I said above.  My problem is 
that your patch does not touch RTAB.  Several qdiscs really 
don't care about the length of a packet (other than for 
keeping track of stats) - they just care about how long 
it takes to send.  Off the top of my these are HTB, CBQ 
and TBF.  They use RTAB to make this calculation.  So unless
you replace RTAB with STAB the current ATM patch will still 
be needed.

> > One other point - the optimisation Patrick proposes
> > for STAB (over RTAB) was to make the number of entries
> > variable.  This seems like a good idea.  However there 
> > is no such thing as a free lunch, and if you did 
> > indeed reduce the number of entries to 16 for Ethernet 
> > (as I think Patrick suggested), then each entry would
> > cover 1500/16 = 93 different packet lengths.  Ie,
> > entry 0 would cover packet lengths 0..93, entry 1
> > 94..186, and so on.  A single entry can't be right
> > for all those packet lengths, so again we are back
> > to a average 30% error for typical VOIP length
> > packets.
> 
> My patch doesn't uses fixed sized cells, so it can deal
> with anything, worst case is you use one cell per packet
> size. Optimizing size and lookup speed for ethernet makes
> a lot more sense than optimizing for ADSL.

I was just responding to a point you made earlier, when
you said STAB could only use 16 entries as opposed to the
256 used by RTAB.  I suspect nobody would actually do that 
because of the inaccuracy it creates, so the comparison is
perhaps unfair.  I agree the flexibility of making STAB 
variable length is a good idea, and comes at 0 cost in 
the kernel.

Andy Furniss wrote:
> > Russell Stuart wrote:
> >> The kernel will have to do a shift and a division
> >> for each packet, which I assume is permissible.
> > 
> > 
> > I guess that is for others to decide :-) I think Patrick has a point
> > about sfq/htb drr, Like you I guess, I thought that alot of extra per
> > packet calculations would have got an instant NO.
> 
> Its only done once per packet (currently, it might be interesting to
> override the length for specific classes and their childs, for example
> if you do queueing on eth0 and have an DSL router one hop apart).
> The division is gone in my patch btw.

Unlike the packet length the time calculation can't be
cached in the skb.  Most classes in HTB/CBQ use different
packet transmission rates.

