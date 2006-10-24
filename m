From: Russell Stuart <russell-tcatm@stuart.id.au>
Subject: Re: [PATCH REPOST 1/2] NET: Accurate
	packet	scheduling	for	ATM/ADSL (kernel)
Date: Wed, 25 Oct 2006 09:46:36 +1000
Message-ID: <1161733596.3829.91.camel@ras.pc.brisbane.lube>
References: <1161041677.6247.1.camel@ras.pc.brisbane.lube>
	 <1161090444.5555.13.camel@jzny2>  <45378DE3.8080700@trash.net>
	 <1161602527.5502.155.camel@ras.pc.stuart.local>
	 <453CB801.4010902@trash.net>
	 <1161640444.5502.214.camel@ras.pc.stuart.local>  <453E3CFC.80007@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 58.105.229.78.optusnet.com.au ([58.105.229.78]:45965 "EHLO
	adsl-kenny.stuart.id.au") by vger.kernel.org with ESMTP
	id S1422842AbWJXXq7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Oct 2006 19:46:59 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <453E3CFC.80007@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-10-24 at 18:19 +0200, Patrick McHardy wrote:
> No, my patch works for qdiscs with and without RTABs, this
> is where they overlap.

Could you explain how this works?  I didn't see how
qdiscs that used RTAB to measure rates of transmission 
could use your STAB to do the same thing.  At least not
without substantial modifications to your patch.

> > As an aside non-work conserving qdisc's that do 
> > scheduling are the real targets of ATM patch.  The 
> > rest are not effected by ATM overly.  The only one 
> > of those that doesn't use Alexy's RTAB is the one you 
> > introduced - HFSC.  You are the best person to fix
> > things so HFSC does work with ATM, and that is what
> > I thought you were doing with the STAB patch.
> 
> No, as we already discussed, SFQ uses the packet size for
> calculating remaining quanta, and fairness would increase
> if the real transmission size (and time) were used. RED
> uses the backlog size to calculate the drop probabilty
> (and supports attaching inner qdiscs nowadays), so keeping
> accurate backlog statistics seems to be a win as well
> (besides their use for estimators). It is also possible
> to specify the maximum latency for TBF instead of a byte
> limit (which is passed as max. backlog value to the inner
> bfifo qdisc), this would also need accurate backlog statistics.

This is all beside the point if you can show how
you patch gets rid of RTAB - currently I am acting
under the assumption it doesn't.  If it does you
get all you describe for free.

Otherwise - yes, you are correct.  The ATM patch does
not introduce accurate packet lengths into the kernel,
which is what is required to give the benefits you
describe.  But that was never the ATM patches goal.
The ATM patch gives accurate rate calculations for ATM
links, nothing more.  Accurate packet length calculations
is apparently the goal of your patch, and I wish you 
luck with it.

> Ethernet, VLAN, Tunnels, ... its especially useful for tunnels
> if you also shape on the underlying device since the qdisc
> on the tunnel device and the qdisc on the underlying device
> should ideally be in sync (otherwise no accurate bandwidth
> reservation is possible).

Hmmm - not as far as I am aware.  In all those cases
the IP layer breaks up the data into MTU sized packets
before they get to the scheduler.  ATM is the only
technology I am known of where setting the MTU to be
bigger than the end to end link can support is normal.

> > What have I missed?  The
> > hard coded ATM values don't effect this patch btw, they
> > are a user space thing only.
> 
> Sure, I'm just mentioning it. Is seems to be quite deeply codified
> in userspace though.

We will have to disagree on that.   Jesper and I had the
discussion.  It came down to using a #define, or letting
it be defined on the command line.   I actually wrote
code for both.  In the end I decided the command line
option was a waste of time.  The difference in lines of
code is not huge, however.

> Either you or Jesper pointed to this code in iproute:
> 
>         for (i=0; i<256; i++) {
>                 unsigned sz = (i<<cell_log);
> ...
>                 rtab[i] = tc_core_usec2tick(1000000*((double)sz/bps));
> 
> which tends to underestimate the transmission time by using
> the smallest possible size for each cell.

This is going to be long, Patrick.  I know you don't
like long emails, so if you don't have the patience
for it stop reading now.  The remainder of this email
addresses this one point.

Firstly, yes you are correct.  It will under some
circumstances underestimate the number of cells it
takes to send a packet.  The reason is because the 
whole aim of the ATM patch was to make maximum use 
of the ATM link, while at the same time keeping 
control of scheduling decisions.  To keep control of
scheduling decisions, we must _never_ overestimate 
the speed of the link.  If we do the ISP will take 
control of the scheduling.

At first sight this seems a minor issue.  Its not, because
the error can be large.  An example of overestimating the
link speed would be were one RTAB entry covers both the
2 and 3 cell cases.  If we say the IP packet is going to
use 2 cells, and in fact it uses 3, then the error is 50%.
This is a huge error, and in fact eliminating this error
is the whole point of the ATM patch.

As an example of its impact, I was trying to make VOIP
work over a shared link.  If the ISP starts making the
scheduling decisions then VOIP packets start being
dropped or delayed, rendering VOIP unusable.  So in
order to use VOIP on the link I have to understate the
link capacity by 50%.  As it happens, VOIP generates a
stream of packets in the 2-3 cell size range, the actual
size depending on the codec negotiated by the end points.

Jesper in his thesis gives perhaps an more important
example what happens if you overestimate the link speed.
It turns out in interacts with TCP's flow control badly,
slowing down all TCP flows over the link.  The reasons
are subtle so I won't go into it here.  But the end
result is if you overestimate the link speed and let the
ISP do the scheduling, you end up under-utilising the 
ATM link.

So in the ATM patch there is a deliberate design decision -
we always assign an RTAB entry the smallest cell size it 
covers.  Originally Jesper and I wrote our own versions
of the ATM patch independently, and we both made the same
design decision - I presume for the same reason.

Secondly, and possibly more importantly, the ATM patch is
designed so that a single RTAB entry always covers exactly
one cell size.  So on a patched kernel the underestimate  
never occurs - the rate returned by the RTAB is always
exactly correct.  In fact, that aspect of it seems to cause 
you the most trouble - the off by one error and so on. The 
code you point out is only there so the new version of "tc" 
also works as well as it can for non-patched kernels.

