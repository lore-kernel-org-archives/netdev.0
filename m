From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH RFC 04/30] net: fec: fix interrupt handling races
Date: Fri, 20 Jun 2014 12:39:57 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1725F962@AcuExch.aculab.com>
References: <20140620121118.GR32514@n2100.arm.linux.org.uk>
 <E1Wxxfn-0005X5-KD@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Fugang Duan <B38611@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Russell King' <rmk+kernel@arm.linux.org.uk>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:54141 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S966831AbaFTMlV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 08:41:21 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 03564-04 for <netdev@vger.kernel.org>;
 Fri, 20 Jun 2014 13:41:13 +0100 (BST)
In-Reply-To: <E1Wxxfn-0005X5-KD@rmk-PC.arm.linux.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King
> While running: while :; do iperf -c <HOST> -P 4; done, transmit timeouts
> are regularly reported.  With the tx ring dumping in place, we can see
> that all entries are in use, and the hardware has finished transmitting
> these packets.  However, the driver has not reclaimed these ring
> entries.
> 
> This can occur if the interrupt handler is invoked at the wrong moment -
> eg:
> 
> 	CPU0				CPU1
> 	fec_enet_tx()
> 					interrupt, IEVENT = FEC_ENET_TXF
> 					FEC_ENET_TXF cleared
> 					napi_schedule_prep()
> 	napi_complete()
> 
> The result is that we clear the transmit interrupt, but we don't trigger
> any cleaning of the transmit ring.  Instead, use a different strategy:
> 
> - When receiving a transmit or receive interrupt, disable both tx and rx
>   interrupts, but do not acknowledge them.  Schedule a napi poll.  Don't
>   loop.
> 
> - When we are polled, read IEVENT, acknowledging the pending transmit
>   and receive interrupts, before then going on to process the
>   appropriate rings.
> 
> This allows us to avoid the race, and has a number of other advantages:
> - we cut down on the number of transmit interrupts we have to process.
> - we only look at the rings which have pending events.
> - we gain additional throughput: the iperf total bandwidth increases
>   from about 180Mbps to 240Mbps:
...

It is usually possible to reduce the interrupt count even further by:
1) processing the rings.
2) clear the IRQ.
3) check the rings for new entries, if any start again.
This means that you don't take the interrupt for anything that completes
while processing the earlier ring entries.

The slight downside is that it is easy to exit the ISR before the IRQ
line actually drops - resulting in a spurious interrupt.

(patch 24 seems to be similar).

	David
