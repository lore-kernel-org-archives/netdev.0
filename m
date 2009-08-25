From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Tue, 25 Aug 2009 13:44:20 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0908251340510.26329@gentwo.org>
References: <alpine.DEB.1.10.0908171548040.20399@gentwo.org>  <4A89C026.4030402@us.ibm.com>  <alpine.DEB.1.10.0908171642500.20399@gentwo.org>  <1250545839.25939.21.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908171813070.15956@gentwo.org>
 <1250549034.25939.30.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908171848370.15956@gentwo.org> <1250554332.25939.46.camel@w-sridhar.beaverton.ibm.com> <alpine.DEB.1.10.0908241334230.30487@gentwo.org> <4A930DEF.5000008@gmail.com>
 <alpine.DEB.1.10.0908250945460.5972@gentwo.org> <4A93EB9B.5020600@gmail.com> <alpine.DEB.1.10.0908250958540.28552@gentwo.org> <4A9403F0.2060301@gmail.com> <alpine.DEB.1.10.0908251135380.26329@gentwo.org> <4A940A10.60607@gmail.com> <alpine.DEB.1.10.0908251203220.26329@gentwo.org>
 <4A9410E9.6090602@gmail.com> <alpine.DEB.1.10.0908251230430.26329@gentwo.org> <4A9415F5.6020006@gmail.com> <alpine.DEB.1.10.0908251258000.26329@gentwo.org> <4A941AA6.5070506@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Nivedita Singhvi <niv@us.ibm.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.ultrahosting.com ([74.213.175.253]:43311 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755046AbZHYRoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 13:44:24 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 46EBD82C2DD
	for <netdev@vger.kernel.org>; Tue, 25 Aug 2009 13:45:19 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id j62AeOu-IJ4y for <netdev@vger.kernel.org>;
	Tue, 25 Aug 2009 13:45:19 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 8D7C182C2E1
	for <netdev@vger.kernel.org>; Tue, 25 Aug 2009 13:45:14 -0400 (EDT)
In-Reply-To: <4A941AA6.5070506@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Aug 2009, Eric Dumazet wrote:

> Christoph Lameter a ?crit :
> > On Tue, 25 Aug 2009, Eric Dumazet wrote:
> >
> >>> The initial point was that the SNMP counters are not updated if IP_RECVERR
> >>> is not set which is clearly a bug and your and my patch addresses that.
> >> Technically speaking, the send() syscall is in error. Frame is not sent, so
> >> there is no drop at all. Like trying to send() from a bad user buffer, or write()
> >> to a too big file...
> >
> > Frame is submitted to the IP layer which discards it. That is the
> > definition of an output discard.
> >
>
> Last patch accounts for this *error* AFAIK, or did I missed something ?

Right.

> >> Question is : should we just allow send() to return an error (-ENOBUF) regardless
> >> of IP_RECVERR being set or not ? I dont think it would be so bad after all.
> >> Most apps probably dont care, or already handle the error.
> >
> > Some applications will then start to fail because so far you can send with
> > impunity without getting errors. AFAICT IP_RECVERR was added to preserve
> > that behavior. Your patch is changing basic send() semantics.
>
> Sorry ???, I guess your machines have plenty available LOWMEM then, and kmalloc() never fail then...

Nope. Currently sendto() just drops the packet and returns success if the
TX ring is full. That can be done ad infinitum and at very high traffic
rates. We had one person here believing he could send 800k 300 byte
packets per second on a 1G wire.... ROTFL.

> basic send() semantics are respected.

basic send() semantics are changed by your patch. The 800k pps would no
longer work without sendto() returning errors.

