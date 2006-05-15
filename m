From: David Zeuthen <davidz@redhat.com>
Subject: Re: Hardware button support for Wireless cards
Date: Mon, 15 May 2006 12:19:04 -0400
Message-ID: <1147709945.3670.22.camel@daxter.boston.redhat.com>
References: <!~!UENERkVCMDkAAQACAAAAAAAAAAAAAAAAAC4AAAAAAAAAWMRZS97Em0WybTChcxl4cAEALirLb4lrrkmZC6EvT+GpyAAAAABE9gAAEAAAALs6jNngvN9OooViTUM1CgIBAAAAAA==@serialmonkey.com>
	 <1147703855.2193.47.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Mark Wallis <mwallis@serialmonkey.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:2764 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751604AbWEOQSt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 May 2006 12:18:49 -0400
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1147703855.2193.47.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-05-15 at 10:37 -0400, Dan Williams wrote:
> Ideally, here's what would happen:  the driver/card/whatever generates
> an ACPI event, which is noticed by HAL.  HAL sets a property on the
> _exact_ device which the event is for, and propagates the signal out
> over dbus.  Any interested application can listen for, and respond to,
> the rf-kill signal.  (or, the event can be handled by acpid and the
> distro can run scripts for it.  01dsk001.  whatever)

Yes, I agree this needs to happen in user space partly because it's
policy even though I can only come up with crack reasons on why you
wouldn't want to turn off the radio when the button is pressed.

However, I suppose we need to do it in user space for some laptops
anyway since I'm not sure the "RF Kill Switch" button and the networking
hardware may be related; see below.

> 
> But this means a few things.  We need:
> 
> 1) common interface/signal for _all_ cards and drivers

Right, this would be nice. This is sorta like the mess that is hotkeys
on laptops. We sorta deal with those in HAL but it's a lot of ugly code
to present a sane abstract interface to user space.

> 2) Enough information to identify which specific pci/pcmcia/etc device
> the event is for (or system-wide?)

No, I'm not really sure we need to know exactly what device this is
triggered for and I'm not even sure that the kernel can figure this out
anyway: the RF Kill buttons may be implemented as a USB HID device for
example which may have little relation to the hardware. Another example
is where the user is using a USB or PC Card Wifi adapter instead of the
built-in Wifi. We want to turn off the radio on the USB or PC Card in
these cases too.

So what we need from user space is basically just an event saying "RF
Kill button pressed" perhaps with some detail such as 'bluetooth' or
'wifi' depending on the graphics of the button (no, I'm not kidding). 

It would also be nice with some way to query state, e.g. "is the button
pressed or not" if the hardware supports this. So, I think perhaps it
may make sense to model this as an input device. Then we can simply
query this input device from user space (in HAL) and emit the right
events and provide an interface to query whether the button is pressed
or not [1]. Specifically, on startup, NetworkManager would just ask HAL
whether the button is pressed or not (if the hardware supports it) and
do the right thing, e.g. selectively suspend all networking devices with
a radio via the power/state file in sysfs which will turn off the radio.
When the user presses the button, NetworkManager enables / disables the
device [2] and so on.

Hope this helps.

    David

[1] : we do the same thing for other buttons in HAL; e.g. the power
button on some Powerbooks.

[2] : this raises another problem. What happens to class devices when a
bus device is turned off (e.g. selective suspend). For example, does the
class device /sys/class/net/eth0 go away when I put the physical to
sleep via the /sys/class/net/eth0/device/power/state file?

Maybe off topic, but what happens in general? For example what happens
when I selectively suspend a USB harddisk enclosure, does /sys/block/sda
go away? If it doesn't, does '# touch /dev/sda' wake it up? (it probably
shouldn't)... 

This kind of stuff needs to be precisely defined, yes? Is it already
defined?


