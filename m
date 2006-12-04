From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [RFC] rfkill - Add support for input key to control wireless radio
Date: Tue, 5 Dec 2006 00:27:14 +0100
Message-ID: <200612050027.15253.IvDoorn@gmail.com>
References: <200612031936.34343.IvDoorn@gmail.com> <d120d5000612041415r2f471e78s4feb86d22b7706d5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"John Linville" <linville@tuxdriver.com>,
	"Jiri Benc" <jbenc@suse.cz>,
	"Lennart Poettering" <lennart@poettering.net>,
	"Johannes Berg" <johannes@sipsolutions.net>,
	"Larry Finger" <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:27787 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967789AbWLDX1T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 18:27:19 -0500
Received: by ug-out-1314.google.com with SMTP id 44so3158367uga
        for <netdev@vger.kernel.org>; Mon, 04 Dec 2006 15:27:17 -0800 (PST)
To: "Dmitry Torokhov" <dmitry.torokhov@gmail.com>
In-Reply-To: <d120d5000612041415r2f471e78s4feb86d22b7706d5@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> > This patch is a resend of a patch I has been send to the linux kernel
> > and netdev list earlier. The most recent version of a few weeks back
> > didn't compile since I missed 1 line in my patch that changed
> > include/linux/input.h.
> >
> > This patch will offer the handling of radiokeys on a laptop.
> > Such keys often control the wireless devices on the radio
> > like the wifi, bluetooth and irda.
> >
> > The rfkill works as follows, when the user presses the hardware key
> > to control the wireless (wifi, bluetooth or irda) radio a signal will
> > go to rfkill. This happens by the hardware driver sending a signal
> > to rfkill, or rfkill polling for the button status.
> > The key signal will then be processed by rfkill, each key will have
> > its own input device, if this input device has not been openened
> > by the user, rfkill will keep the signal and either turn the radio
> > on or off based on the key status.
> > If the input device has been opened, rfkill will send the signal to
> > userspace and do nothing further. The user is in charge of controlling
> > the radio.
> >
> > This driver (if accepted and applied) will be usefull for the rt2x00 drivers
> > (rt2400pci, rt2500pci, rt2500usb, rt61pci and rt73usb) in the wireless-dev
> > tree and the MSI laptop driver from Lennart Poettering in the main
> > linux kernel tree.
> >
> > Before this patch can be applied to any tree, I first wish to hear
> > if the patch is acceptable. Since the previous time it was send I have made
> > several fixes based on the feedback like adding the sysfs entries for
> > reading the status.
> >
> 
> Hi Ivo,
> 
> I apologize for not responding to your post earlier, it was a busy week.

No problem, it didn't compile anyway. And this time I have CC'ed all
people that have previously shown interest in rfkill, so they are now
updated about rfkill as well. ;)

> I am still not sure that tight coupling of input device with rfkill
> structure is such a good idea. Quite often the button is separated
> from the device itself and radio control is done via BIOS SMM (see
> wistron driver) or there is no special button at all and users might
> want to assign one of their standard keyboard buttons to be an RF
> switch.

Making sure rfkill supports keys that are not handled by the driver
is a bit hard. Just as drivers that can only check if the button is
toggled and not what the current state is.
The problem is that it is hard to make a clean split between the
2 different button controls. Not all drivers allow the radio to be
enabled while the button status are indicating the radio should
be off.
The buttons that are already integrated into the keyboard,
by example by using a Fn key combo don't control the device
directly. So the driver cannot offer anything to the rfkill driver.
Such buttons should be mapped in userspace without the help of rfkill,
since the kernel cannot detect if that key belonged to a radio
control key or not.

> I think it would be better if there was an rfkill class listing all
> controlled devices (preferrably grouped by their type - WiFi, BT,
> IRDA, etc) and if every group would provide an attribute allowing to
> control state of the whole group (do we realistically need to kill
> just one interface? Wouldn't ifconfig be suitable for that?). The

There have been mixed feelings on the netdev list about what should
exactly happen when the button is pressed. The possible options are:

1 - rfkill will kill all interfaces
2 - rfkill will kill all interfaces of the same type (wifi, bt, irda)
3 - rfkill will kill the interface it belongs to
 
Personally I would favour the second option, but used the third after hearing
objections to the second method. So since there are also fans of
the third option I think there should be a decision made about what the
correct option is, so rfkill can follow that method.

> attribute should be a tri-state on/off/auto, "auto" meaning the driver
> itself manages radio state. This would avoid another tacky IMHO point
> that in your implementation mere opening of an input device takes over
> RF driver. Explicit control allow applications "snoop" RF state
> without disturbing it.

Currently userspace can always check the state of the button whenever
they like by checking the sysfs entry. 


> If there are concerns that drivers will have to re-implement most of
> the button handling you are still free to create a simple
> implementation of polled RF button (I don't think that interrupt
> driver RF buttons would share alot of code) so that users would only
> need to implement a polling function.

Isn't the current interface to the driver not clean enough?
It only asks for the (optional) poll method, and the enable/disable method.
I believe this should not add too much code into the drivers, especially when
all methods are optional.

Ivo
