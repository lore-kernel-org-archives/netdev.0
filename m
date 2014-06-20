From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH RFC 04/30] net: fec: fix interrupt handling races
Date: Fri, 20 Jun 2014 16:00:45 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1725FB35@AcuExch.aculab.com>
References: <20140620121118.GR32514@n2100.arm.linux.org.uk>
 <E1Wxxfn-0005X5-KD@rmk-PC.arm.linux.org.uk>
 <063D6719AE5E284EB5DD2968C1650D6D1725F962@AcuExch.aculab.com>
 <20140620153614.GU32514@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Fugang Duan <B38611@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Russell King - ARM Linux' <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:33834 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751985AbaFTQCJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 12:02:09 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 32218-06 for <netdev@vger.kernel.org>;
 Fri, 20 Jun 2014 17:02:00 +0100 (BST)
In-Reply-To: <20140620153614.GU32514@n2100.arm.linux.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King - ARM Linux
> On Fri, Jun 20, 2014 at 12:39:57PM +0000, David Laight wrote:
> > It is usually possible to reduce the interrupt count even further by:
> > 1) processing the rings.
> > 2) clear the IRQ.
> > 3) check the rings for new entries, if any start again.
> > This means that you don't take the interrupt for anything that completes
> > while processing the earlier ring entries.
> >
> > The slight downside is that it is easy to exit the ISR before the IRQ
> > line actually drops - resulting in a spurious interrupt.
> >
> > (patch 24 seems to be similar).
> 
> ITYM patch 26, as patch 24 is an update to the errata workaround.

Misread my jottings.
> 
> Patch 4 is what I regard to be the bare minimum fix, patch 26 is an
> improvement over it.
> 
> Remember though that the real interrupt processing happens in the NAPI
> handler, not the main interrupt handler - upon seeing a transmit and/or
> receive complete interrupt, the main interrupt handler masks both of
> these interrupts at the chip and triggers the NAPI handler to run.
> 
> Nevertheless, your suggestion is equally valid for a NAPI handler:
> - process the rings
> - clear the interrupt(s)
> - if more work is allowed (according to the NAPI weight), repeat

Not quite, you only want to clear the hardware IRQ and unmask the ISR
when there are no ring entries to process.
(There is no point doing the slow bus cycles until then.)

If you clear the hardware IRQ at the start of processing the ring you'll
get another interrupt when you finally enable the interrupt for a rx
packet that arrives while processing the earlier packets.
However you must check the ring AFTER clearing the IRQ - otherwise
you miss the interrupt for a packet the arrives at that time.

So the sequence is:
1) Find that there are no ring entries to process.
(a packet can arrive here)
2) Clear the IRQ request.
3) Check there are still no ring entries to process.
4) Unmask the interrupt.

> This is simple enough for the RX ring, where each packet received is
> equal one one NAPI unit of work.  The TX side is less obvious as
> the NAPI documentation suggests that cleaning the ring partially
> equates to no NAPI units of work but a clean of the entire ring
> equates to the full allowance.  Maybe I've mis-understood something
> there (which would mean there's another bug which needs fixing in the
> tx reaping code...)

I've never tried to understand NAPI work limits.
I suspect that once the NAPI callbacks for other devices (etc) have
had a chance to run, you get called again.
So you'd leave the hardware interrupt masked until then.

	David
