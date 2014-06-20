From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH RFC 04/30] net: fec: fix interrupt handling races
Date: Fri, 20 Jun 2014 16:36:14 +0100
Message-ID: <20140620153614.GU32514@n2100.arm.linux.org.uk>
References: <20140620121118.GR32514@n2100.arm.linux.org.uk> <E1Wxxfn-0005X5-KD@rmk-PC.arm.linux.org.uk> <063D6719AE5E284EB5DD2968C1650D6D1725F962@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Fugang Duan <B38611@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:36619 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753833AbaFTPgX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 11:36:23 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1725F962@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 20, 2014 at 12:39:57PM +0000, David Laight wrote:
> It is usually possible to reduce the interrupt count even further by:
> 1) processing the rings.
> 2) clear the IRQ.
> 3) check the rings for new entries, if any start again.
> This means that you don't take the interrupt for anything that completes
> while processing the earlier ring entries.
> 
> The slight downside is that it is easy to exit the ISR before the IRQ
> line actually drops - resulting in a spurious interrupt.
> 
> (patch 24 seems to be similar).

ITYM patch 26, as patch 24 is an update to the errata workaround.

Patch 4 is what I regard to be the bare minimum fix, patch 26 is an
improvement over it.

Remember though that the real interrupt processing happens in the NAPI
handler, not the main interrupt handler - upon seeing a transmit and/or
receive complete interrupt, the main interrupt handler masks both of
these interrupts at the chip and triggers the NAPI handler to run.

Nevertheless, your suggestion is equally valid for a NAPI handler:
- process the rings
- clear the interrupt(s)
- if more work is allowed (according to the NAPI weight), repeat

This is simple enough for the RX ring, where each packet received is
equal one one NAPI unit of work.  The TX side is less obvious as
the NAPI documentation suggests that cleaning the ring partially
equates to no NAPI units of work but a clean of the entire ring
equates to the full allowance.  Maybe I've mis-understood something
there (which would mean there's another bug which needs fixing in the
tx reaping code...)

-- 
FTTC broadband for 0.8mile line: now at 9.7Mbps down 460kbps up... slowly
improving, and getting towards what was expected from it.
