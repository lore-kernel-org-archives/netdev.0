From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH RFC 24/30] net: fec: better implementation of iMX6
	ERR006358 quirk
Date: Sun, 22 Jun 2014 09:24:00 +0100
Message-ID: <20140622082359.GC32514@n2100.arm.linux.org.uk>
References: <20140620121118.GR32514@n2100.arm.linux.org.uk> <E1WxxhR-0005YP-Q1@rmk-PC.arm.linux.org.uk> <316b383d2512440db51ea7c55992920d@BLUPR03MB373.namprd03.prod.outlook.com> <20140622081234.GB32514@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:38146 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751326AbaFVIYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jun 2014 04:24:05 -0400
Content-Disposition: inline
In-Reply-To: <20140622081234.GB32514@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 22, 2014 at 09:12:35AM +0100, Russell King - ARM Linux wrote:
> On Sun, Jun 22, 2014 at 07:49:11AM +0000, fugang.duan@freescale.com wrote:
> > The issue has happened customer product, and was fixed by previous
> > workaround.  The issue only happened at little packets transmission.
> > Special for command communicate protocol to the other end.
> 
> So, please explain to me why, with the current solution, I get:
> 
> 1. half duplex performance is abismal, to the point that the ethernet
>    only achieves about 12-25% of the bandwidth, and jumps massively
>    using the solution in this patch (which is as per the workaround
>    documented in the errata document.)
> 
> 2. transmit timeouts when operating in half-duplex mode.

I also forgot to point out that in half duplex mode with the current
solution, I get /lots/ of collisions (which is the case of (1)),
including "late" collisions which are never supposed to happen.

Late collisions occur because another ethernet station is found to be
transmitting onto the shared media after a certain point in the packet.
This point is set in the standards according to the maximum cable length
and the packet propagation delays, and the occurance of a late collision
indicates that either the cables are too long, or the hardware is not
detecting the presence of a receive carrier before it starts blurting
out on the shared media - over an existing transmission.

It seems that when regularly writing to FEC_X_DES_ACTIVE, this breaks
the half-duplex hold-off mechanism, and the FEC just blurts out the next
packet without respecting the media access rules.

In my case, I can assure you that it is not a faulty hub, or an
excessively long cable (which was less than 1m) since the only hardware
which exhibits this behaviour is iMX6, and this behaviour occurs with
the two hubs I have here (one a 10bT hub, the other a 10/100bT hub).

I did a lot of experiments with various setups of switches and hubs
which conclusively prove that the iMX6 is the broken party.

-- 
FTTC broadband for 0.8mile line: now at 9.7Mbps down 460kbps up... slowly
improving, and getting towards what was expected from it.
