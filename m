From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH] usbnet: allow rx_process() to ignore packets
Date: Sat, 4 Sep 2010 16:24:46 -0700 (PDT)
Message-ID: <365612.7945.qm@web180309.mail.gq1.yahoo.com>
References: <201009042352.24197.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: David Brownell <dbrownell@users.sourceforge.net>,
	Ondrej Zary <linux@rainbow-software.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201009042352.24197.linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



--- On Sat, 9/4/10, Ondrej Zary <linux@rainbow-software.org> wrote:

> From: Ondrej Zary <linux@rainbow-software.org>
> Subject: [PATCH] usbnet: allow rx_process() to ignore packets

It already can ... I'm already not
liking this patch...

You've not convinced me this is even necessary.


> To: "David Brownell" <dbrownell@users.sourceforge.net>
> Cc: netdev@vger.kernel.org, "Kernel development list" <linux-kernel@vger.kernel.org>
> Date: Saturday, September 4, 2010, 2:52 PM
> Allow rx_process() to ignore a packet
> without incrementing error counters if 
> rx_fixup() returns value other than 0 or 1 (e.g. 2).
> 
> This allows to simplify rx_fixup() functions of drivers who
> do complex 
> processing there. Currently, drivers must process

Not many drivers.  Or even most.

 the last
> packet in a 
> special way - leave it for usbnet to process.

Don't you mean "clean up"?  The usbnet core knows
exactly zero about packet framing, 

Which in your scenario -- packet crosses URB
boundaries, can't be handled by usbnet at all,
since it's specific to the framing used by the
protocol the driver understands.

The way to handle such perversity (or is it bad
design ... just use large-enough RX urbs!

Or ... have the usbnet minidriver queue up the
packets it's got to re-assemble, and do that
work the next time rx_fixup() is called.  Very
straightforward, and doesn't affect the core
usbnet framework at all.

Better of course is to stick to the simple
framing model that places the least load on the
whole stack:  one Ethernet packet per URB...

This is not
> easily possible 
> when a driver (like the new cx82310_eth) needs to process
> packets that cross 
> URB (and thus skb) boundaries. With this patch, the driver
> can process all 
> packets in the skb and just return 2 at the end.

With "2" signifying just what?  And what's keeping
that routine from handing up multiple SKBs *NOW* ??

ISTR nothing is keeping it from doing that, since
the RNDIS code has done so forever.  (More evidence
that this change is not needed.)
> 
> Also fix asix driver that was returning 2 at one place
> before this change 
> (probably by mistake).


If that's worth fixing, it's worth doing it
in a patch by itself, instead of glommed into
an otherwise unrelated patch.  Does that really
break that driver?


> 
> 
