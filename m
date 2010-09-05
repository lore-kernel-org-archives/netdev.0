From: Ondrej Zary <linux@rainbow-software.org>
Subject: Re: [PATCH] usbnet: allow rx_process() to ignore packets
Date: Sun, 5 Sep 2010 18:16:10 +0200
Message-ID: <201009051816.12823.linux@rainbow-software.org>
References: <365612.7945.qm@web180309.mail.gq1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Brownell <dbrownell@users.sourceforge.net>,
	netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: David Brownell <david-b@pacbell.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <365612.7945.qm@web180309.mail.gq1.yahoo.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 05 September 2010 01:24:46 David Brownell wrote:
> --- On Sat, 9/4/10, Ondrej Zary <linux@rainbow-software.org> wrote:
> > From: Ondrej Zary <linux@rainbow-software.org>
> > Subject: [PATCH] usbnet: allow rx_process() to ignore packets
>
> It already can ... I'm already not
> liking this patch...

How it can? Currently, rx_process() knows only two cases: either rx_fixup() 
returns 0 or a non-zero value. If I return 0, the error counter is 
incremented. If I return non-zero value, packet is processed ("passed up the 
stack" - usbnet_skb_return() called) if the skb has non-zero length, 
otherwise the error counter is incremented. There's no way to not pass the 
packet up the stack without incrementing the error counter.

> You've not convinced me this is even necessary.
>
> > To: "David Brownell" <dbrownell@users.sourceforge.net>
> > Cc: netdev@vger.kernel.org, "Kernel development list"
> > <linux-kernel@vger.kernel.org> Date: Saturday, September 4, 2010, 2:52 PM
> > Allow rx_process() to ignore a packet
> > without incrementing error counters if
> > rx_fixup() returns value other than 0 or 1 (e.g. 2).
> >
> > This allows to simplify rx_fixup() functions of drivers who
> > do complex
> > processing there. Currently, drivers must process
>
> Not many drivers.  Or even most.
>
>  the last
>
> > packet in a
> > special way - leave it for usbnet to process.
>
> Don't you mean "clean up"?  The usbnet core knows
> exactly zero about packet framing,

I mean "pass up the stack".

> Which in your scenario -- packet crosses URB
> boundaries, can't be handled by usbnet at all,
> since it's specific to the framing used by the
> protocol the driver understands.
>
> The way to handle such perversity (or is it bad
> design ... just use large-enough RX urbs!

I cannot change the HW. cx82310 merges the packets in URBs and does not care 
about URB boundaries. If a packet does not fit the URB (4KB), it simply 
continues in the next URB (without any header).

> Or ... have the usbnet minidriver queue up the
> packets it's got to re-assemble, and do that
> work the next time rx_fixup() is called.  Very
> straightforward, and doesn't affect the core
> usbnet framework at all.

That's exactly what I'm already doing. When the packet is not complete, I copy 
the partial data. And return what? I cannot return 1 as the packet is not 
complete. If I return 0, the error counter gets incremented even if this is 
not an error condition. This is why this patch was created.

The cx82310_eth (mini)driver already works
(see http://www.spinics.net/lists/netdev/msg139950.html)
and the only problem I can see are the error statistics.

> Better of course is to stick to the simple
> framing model that places the least load on the
> whole stack:  one Ethernet packet per URB...

The device probably tries to maximize the throughput by merging everything it 
can.

> This is not
>
> > easily possible
> > when a driver (like the new cx82310_eth) needs to process
> > packets that cross
> > URB (and thus skb) boundaries. With this patch, the driver
> > can process all
> > packets in the skb and just return 2 at the end.
>
> With "2" signifying just what?  And what's keeping
> that routine from handing up multiple SKBs *NOW* ??

"2" means that rx_process() should neither call usbnet_skb_return() nor 
increment the error counter.

> ISTR nothing is keeping it from doing that, since
> the RNDIS code has done so forever.  (More evidence
> that this change is not needed.)

RNDIS processes multiple packets per skb but not packets that cross skb 
boundaries.
cdc_eem, smsc75xx, smsc95xx and also rndis_host treat last packet differently 
just because usbnet need to pass it up the stack by itself.

> > Also fix asix driver that was returning 2 at one place
> > before this change
> > (probably by mistake).
>
> If that's worth fixing, it's worth doing it
> in a patch by itself, instead of glommed into
> an otherwise unrelated patch.  Does that really
> break that driver?

When semantic of "return 2" changes, the asix driver would be doing something 
other that it's doing now. I don't want to break anything so the driver 
should be fixed at the same time (or before).

-- 
Ondrej Zary
