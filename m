From: Dan Williams <dcbw@redhat.com>
Subject: Re: Hardware button support for Wireless cards
Date: Mon, 15 May 2006 10:37:35 -0400
Message-ID: <1147703855.2193.47.camel@localhost.localdomain>
References: <!~!UENERkVCMDkAAQACAAAAAAAAAAAAAAAAAC4AAAAAAAAAWMRZS97Em0WybTChcxl4cAEALirLb4lrrkmZC6EvT+GpyAAAAABE9gAAEAAAALs6jNngvN9OooViTUM1CgIBAAAAAA==@serialmonkey.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Zeuthen <davidz@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:32484 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S964950AbWEOOj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 May 2006 10:39:28 -0400
To: Mark Wallis <mwallis@serialmonkey.com>
In-Reply-To: <!~!UENERkVCMDkAAQACAAAAAAAAAAAAAAAAAC4AAAAAAAAAWMRZS97Em0WybTChcxl4cAEALirLb4lrrkmZC6EvT+GpyAAAAABE9gAAEAAAALs6jNngvN9OooViTUM1CgIBAAAAAA==@serialmonkey.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-05-15 at 22:57 +1000, Mark Wallis wrote:
> Hi everyone,
> 
> Currently, in our rt2x00 (using the devicescape stack) we are firing off an
> ACPI event so that the hardware button can be handled in userspace. This
> allows the user to basically do whatever they want when this button is
> pressed - including bringing down the wireless interface. The problem here
> is no distro's currently contain scripts to run from this event so for many
> users it just "doesn't work" without them manually having to write scripts
> to handle the ACPI even themselves.
> 
> Some people are saying that instead of throwing and ACPI event we should be
> either use hotplug or internally just disable the radio and somehow inform
> the dscape stack that the radio has been disabled.
> 
> What are peoples thoughts here, should we 
> 
> A. be handling this within our drivers and doing "what the user expects" and
> disabling the hardware radio, or 

> B. should we be firing an ACPI event and getting the distro's to add scripts
> so when this event is fired they bring down all the wireless interfaces.

(had this issue in the back of my head for a while already...)

Isn't the rf-kill switch specific to the manufacturer lots of times?  Is
the switch connected directly to the card, or is it incumbent on the
driver to notice the event and disable the card via software?  We need
to handle this for Bluetooth too, in situations where there's both a
bluetooth and an 802.11 card in the box.  Does the rf-kill apply to
both?  Or just to one?

WRT to disabling the radio, I'm not sure it makes a difference either
way.  Hitting a button generally means "do this _NOW_", so it makes
sense for the driver to disable the radio and then send out the event.
Apps need to be able to deal with these resources going out from
underneath them, and I'm not sure it makes sense to wait around for some
scripts to run that just might possibly at some future point disable it,
but you're never sure.

In the end, an ACPI event is probably fine.  I must stress that we NEED
to have a common event structure for this, such that every driver and
card presents the same interface.  I don't want to have to write stuff
for each of 3 or 4 different cards to notice the rf-kill stuff.  Witness
all the extra binaries that each driver has already for this sort of
thing.  What interface does the ipw[2|3]xxx driver and hardware present?
What common bits can be drawn out from both?

Ideally, here's what would happen:  the driver/card/whatever generates
an ACPI event, which is noticed by HAL.  HAL sets a property on the
_exact_ device which the event is for, and propagates the signal out
over dbus.  Any interested application can listen for, and respond to,
the rf-kill signal.  (or, the event can be handled by acpid and the
distro can run scripts for it.  01dsk001.  whatever)

But this means a few things.  We need:

1) common interface/signal for _all_ cards and drivers
2) Enough information to identify which specific pci/pcmcia/etc device
the event is for (or system-wide?)

Dan


