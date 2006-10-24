From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH REPOST 1/2] NET: Accurate packet	scheduling	for	ATM/ADSL
 (kernel)
Date: Tue, 24 Oct 2006 18:19:08 +0200
Message-ID: <453E3CFC.80007@trash.net>
References: <1161041677.6247.1.camel@ras.pc.brisbane.lube>	 <1161090444.5555.13.camel@jzny2>  <45378DE3.8080700@trash.net>	 <1161602527.5502.155.camel@ras.pc.stuart.local>	 <453CB801.4010902@trash.net> <1161640444.5502.214.camel@ras.pc.stuart.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47095 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1030418AbWJXQTL
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Oct 2006 12:19:11 -0400
To: Russell Stuart <russell-tcatm@stuart.id.au>
In-Reply-To: <1161640444.5502.214.camel@ras.pc.stuart.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Russell Stuart wrote:
> On Mon, 2006-10-23 at 14:39 +0200, Patrick McHardy wrote:
> 
>>The implementation may be different, but the intention and the
>>result is the same. I probably would mind less if it wouldn't
>>affect userspace compatibility, but we need to carry this stuff
>>for ever even if we add another implementation that covers all
>>qdiscs.
> 
> 
> So where is the overlap?  Your patch will make qdiscs
> that use packet length work with ATM.  Ours makes the
> rest, ie those that use Alexy's RTAB, work with ATM.
> They would probably both apply with minimal conflicts.
> You have previously said you have no intention of 
> changing the current RTAB implantation with your STAB
> patch.

No, my patch works for qdiscs with and without RTABs, this
is where they overlap.

> As an aside non-work conserving qdisc's that do 
> scheduling are the real targets of ATM patch.  The 
> rest are not effected by ATM overly.  The only one 
> of those that doesn't use Alexy's RTAB is the one you 
> introduced - HFSC.  You are the best person to fix
> things so HFSC does work with ATM, and that is what
> I thought you were doing with the STAB patch.

No, as we already discussed, SFQ uses the packet size for
calculating remaining quanta, and fairness would increase
if the real transmission size (and time) were used. RED
uses the backlog size to calculate the drop probabilty
(and supports attaching inner qdiscs nowadays), so keeping
accurate backlog statistics seems to be a win as well
(besides their use for estimators). It is also possible
to specify the maximum latency for TBF instead of a byte
limit (which is passed as max. backlog value to the inner
bfifo qdisc), this would also need accurate backlog statistics.

>>What do I need to explain further? As I stated several times,
>>I would like to see a patch that handles all qdiscs. And it
>>should probably not have hardcoded ATM values, there is other
>>media that behaves similar.
> 
> 
> I am not aware of other media that behaves in a similar
> way, although I am no expert.

Ethernet, VLAN, Tunnels, ... its especially useful for tunnels
if you also shape on the underlying device since the qdisc
on the tunnel device and the qdisc on the underlying device
should ideally be in sync (otherwise no accurate bandwidth
reservation is possible).

> What have I missed?  The
> hard coded ATM values don't effect this patch btw, they
> are a user space thing only.

Sure, I'm just mentioning it. Is seems to be quite deeply codified
in userspace though.

>>>A negative cell align is possible, and in fact is typical.
>>>If slot ended up being less than 0 then the configuration
>>>parameters passed to "tc" would of been wrong - they could
>>>not of matched the actual traffic.  The error can't be 
>>>detected in "tc", but it can't be allowed to cause the
>>>kernel to index off the end of an array either.
>>
>>I'm not sure I understand what you're saying here. The transmission
>>time gets _smaller_ by transmitting over ATM? Does this have anything
>>to do with the off-by-one during rate table calculation you or
>>Jesper noticed?
> 
> 
> There is nothing I would describe as an "off-by-one
> error" in the RTAB calculation, so I can't be sure
> what you are referring to.

Either you or Jesper pointed to this code in iproute:

        for (i=0; i<256; i++) {
                unsigned sz = (i<<cell_log);
...
                rtab[i] = tc_core_usec2tick(1000000*((double)sz/bps));

which tends to underestimate the transmission time by using
the smallest possible size for each cell.

> The packetisation done
> by ATM does introduce rounding / truncation errors
> of up to ((1 << cell_log) - 1).  Negative cell 
> alignments is the easiest way to fix that.

Doesn't this cause underestimates as well for minimum sized (within
a cell size) packets? The error is the same as the one I mentioned
above (apparently in the opposite direction though), which is why I
thought this might be related.

