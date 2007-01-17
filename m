From: Russell Stuart <russell-tcatm@stuart.id.au>
Subject: Re: [PATCH REPOST 1/2] NET:
	Accurate	packet	scheduling	for	ATM/ADSL (kernel)
Date: Thu, 18 Jan 2007 09:07:02 +1000
Message-ID: <1169075223.7560.15.camel@ras>
References: <1161041677.6247.1.camel@ras.pc.brisbane.lube>
	 <1161090444.5555.13.camel@jzny2>  <45378DE3.8080700@trash.net>
	 <1161602527.5502.155.camel@ras.pc.stuart.local>
	 <453CB801.4010902@trash.net>
	 <1161640444.5502.214.camel@ras.pc.stuart.local> <453E3CFC.80007@trash.net>
	 <1161733596.3829.91.camel@ras.pc.brisbane.lube>
	 <456ED79E.2070707@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 58.105.229.78.optusnet.com.au ([58.105.229.78]:48414 "EHLO
	adsl-kenny.stuart.id.au" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751425AbXAQXdW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jan 2007 18:33:22 -0500
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <456ED79E.2070707@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-11-30 at 14:07 +0100, Patrick McHardy wrote: 
> Qdiscs don't use RTABs to measure rates but to calculate
> transmission times. Transmission time is always related
> to the length, the difference between our patches is that
> you modify the RTABs in advance to include the overhead
> in the calculation, my patch changes the length used to
> look up the transmission time. Which works with or
> without RTABs.

Thanks, I understand now.

I had decided that that STAB was indeed the way forward,
and hence I should devote my time to making it work 
with ADSL/ATM.  The only issue is now I don't have 
any spare time right now.

Yesterday I was chatting about this at LCA 2007, and 
it dawned on me that there is a problem with the dual
RTAB/STAB approach.

Currently the lookup in the kernel is
  time_to_transmit_a_packet = RTAB[packet_length_seen_by_kernel]

As I understand it, you are proposing to change that to
  time_to_transmit_a_packet
    = RTAB[STAB[packet_length_seen_by_kernel]]
    = RTAB[packet_length_seen_on_the_wire]

Given RTAB is the same in both cases the results of the
calculation will be different (and ergo wrong in one case
or the other).  RTAB can't change and remain compatible 
with old kernels.  Ergo this approach breaks backward 
compatibility.

I can't see any way forward but to break the link 
between RTAB and STAB.  Personally I think this is a 
good thing, as I think STAB should replace RTAB 
completely.  One way to do this is to give the kernel
STAB + transmission rate, so the calculation above
becomes:

  time_to_transmit_a_packet
    = STAB[packet_length_seen_by_kernel] * transmission_rate

RTAB disappears in new kernels, and the compatibility
problem goes with it.

Can you think of other ways forward?  I need some way 
forward so I can get this thing working.


