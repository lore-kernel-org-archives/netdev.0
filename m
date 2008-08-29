From: Joe Malicki <jmalicki@metacarta.com>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Fri, 29 Aug 2008 11:43:21 -0400 (EDT)
Message-ID: <9908552.1357791220024601650.JavaMail.root@ouachita>
References: <20080829153036.GV26610@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, johnpol@2ka.mipt.ru,
	dada1@cosmosbay.com, denys@visp.net.lb, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, juhlenko@akamai.com, sammy@sammy.net
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from silene.metacarta.com ([208.80.142.18]:49043 "EHLO
	silene.metacarta.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751471AbYH2Pn2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2008 11:43:28 -0400
In-Reply-To: <20080829153036.GV26610@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Joe Malicki
Software Engineer
MetaCarta, Inc.

----- "Andi Kleen" <andi@firstfloor.org> wrote:
> > That adds variance, and packets aren't comparable because they may
> > suffer different kernel/hardware delays.
> 
> And there are no "different kernel/hardware delays" in the network?
> 
> If your RTT measurement method cannot handle some variance (using
> standard sampling and data smoothing techniques similar to TCP) then
> it 
> just needs to be fixed.

Noone's measuring RTT... what ever made you think that?

I should explain the application of SO_TIMESTAMP better.

 Video camera -> Video jack -> Digitization -> Compression ->
     Packetization -> NIC -> Ethernet -> NIC -> Interrupt Handler -> Queue -> Application

 Microphone   -> MIC jack -> Digitization -> Compression ->
      Packetization -> NIC -> Ethernet -> NIC -> Interrupt Handler -> Queue -> Application

One wants to know the original time sound and light waves hit the camera
and microphone, because one wants to know when they should hit the soundcard and
video on the other end (i.e. any delays should be synchronized) but one only has control
over the receiving system.  There are timestamps at the application level for this...
unfortunately, many implementations in the real world have independent clocks that skew
relative to each other, with little correction on the sending system.

Yeah, that's broken, but one has to be liberal in what one accepts from popular products.

One way to mitigate the skew between the clocks is to take measurements on the receiving
host, which you do control, and compare the average skew between the two streams and
correct for it.  Interrupt handler time has variance, but it's less than application-level
time, so it's a better, more reliable estimator.

> Besides measuring in the interrupt handler doesn't protect you
> against local variances anyways because the interrupt timing has
> variability
> (e.g due to irq off regions or due to interrupt mitigation or
> higher priority interrupts) too
>
True, but occasionally it's the best approximation to original send time.

> > > Yes, but why ignore local scheduling delays? 
> > 
> > Because one would want to ignore even network scheduling delays
> > if possible... unfortunately in some instances it's not.
> 
> The local delays add to the user experience too.
> It's unclear why you want to ignore those.
> 
> -Andi

You don't want to ignore them, you want to compensate for them
by getting an earlier timestamp.
