From: David Brownell <david-b@pacbell.net>
Subject: Re: Runtime power management for network interfaces
Date: Tue, 25 Jul 2006 10:03:44 -0700
Message-ID: <200607251003.45314.david-b@pacbell.net>
References: <Pine.LNX.4.44L0.0607251147040.6498-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Network development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp112.sbc.mail.mud.yahoo.com ([68.142.198.211]:13454 "HELO
	smtp112.sbc.mail.mud.yahoo.com") by vger.kernel.org with SMTP
	id S932101AbWGYRDs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jul 2006 13:03:48 -0400
To: Alan Stern <stern@rowland.harvard.edu>
In-Reply-To: <Pine.LNX.4.44L0.0607251147040.6498-100000@iolanthe.rowland.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 25 July 2006 8:59 am, Alan Stern wrote:
> During a Power Management session at the Ottawa Linux Symposium, it was
> generally agreed that network interface drivers ought to automatically
> suspend their devices (if possible) whenever:
> 
>     (1) The interface is ifconfig'ed down, or
> 
>     (2) No link is available.
> 
> Presumably (1) should be easy enough to implement.

I can't imagine that there are many network drivers that couldn't
put the hardware in some kind of low power mode at that point.

All PCI drivers can certainly set_pci_power_state(pdev, PCI_D3hot)
and save a certain amount of power.  Of course, that means coping
with a possible device reset when going to PCI_D0, and I can imagine
some devices might prefer to use PCI_D2 rather than reload firmware.

Embedded chips probably have an easier time with this; just turn
off all the clocks going to that controller and its PHY.  


> (2) might or might not 
> be feasible, depending on how much WOL support is available.

A network adapter without PHY support in the WOL hardware wouldn't be
able to implement (2).  And in today's systems, where we can't rely on
ACPI+PCI to morph PME# to pci_driver.resume() during runtime suspend,
not all platforms can implement (2).  Embedded chips probably have an
easier time here ... I know for a fact that at91_ether can do that sort
of thing easily, at least on boards where the PHY IRQ is hooked up, so
that the driver doesn't need to poll link status.

The USB analogy here is that _some_ external transceivers (PHY) can
report link state changes via IRQs, supporting a mode where everything
else is powered off until the link can be active, at which point the
controller can come out of its low power state.  Those are of course
transceivers intended for use in systems with itty bitty batteries.


(I keep thinking wakeup event handling is pretty weak in Linux today.
As you know, we're still shaking the USB HCDs into shape there, since
some system configs have issues.  Network adapters seem to be another
major use case for wakeup events in Linux, and I get the impression
they're not as widely used -- or functional -- as would be good.)


> (It might 
> not be feasible at all for wireless networking.)  Still, there can be no
> question that it would be a Good Thing for laptops to power-down their
> ethernet controllers when the network cable is unplugged.
> 
> Has any progress been made in this direction?  If not, a natural approach 
> would be to start with a reference implementation in one driver which 
> could then be copied to other drivers.
> 
> Any suggestions?

My initial thought was that network drivers could be refactored so
that they have ifsuspend() and ifresume() methods to put the hardware
into the low power state.

The remove(), open() and resume() methods would call ifresume(); probe(),
close() and suspend() would call ifsuspend() ... thatid give (1).  And
for hardware supporting (2) there'd be some housekeeping for the WOL support
during suspend() and resume(), in addition to netif_device_{de,at}tach().

For hardware where a PHY can report link state without requiring an active
Ethernet controller (e.g. at91_ether for sure) some events could trigger
ifresume()/ifsuspend() when the interface is active.

- Dave

