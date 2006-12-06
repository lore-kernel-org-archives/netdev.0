From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [RFC] rfkill - Add support for input key to control wireless radio
Date: Wed, 6 Dec 2006 22:41:58 +0100
Message-ID: <200612062241.58476.IvDoorn@gmail.com>
References: <200612031936.34343.IvDoorn@gmail.com> <200612062031.57148.IvDoorn@gmail.com> <d120d5000612061218x4eac87e0jc18409f82bb7c99c@mail.gmail.com>
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
Received: from ug-out-1314.google.com ([66.249.92.168]:62255 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937660AbWLFVmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 16:42:07 -0500
Received: by ug-out-1314.google.com with SMTP id 44so276301uga
        for <netdev@vger.kernel.org>; Wed, 06 Dec 2006 13:42:04 -0800 (PST)
To: "Dmitry Torokhov" <dmitry.torokhov@gmail.com>
In-Reply-To: <d120d5000612061218x4eac87e0jc18409f82bb7c99c@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> > > That is my point. Given the fact that there are keys that are not
> > > directly connected with the radio switch userspace will have to handle
> > > them (wait for events then turn off radios somehow). You are
> > > advocating that userspace should also implement 2nd method for buttons
> > > that belong to rfkill interface. I do not understand the need for 2nd
> > > interface. If you separate radio switch from button code then
> > > userspace only need to implement 1st interface and be done with it.
> > > You will have set of cards that provide interface to enable/disable
> > > their transmitters and set of buttons that signal userspace desired
> > > state change. If both switch and button is implemented by the same
> > > driver then the driver can implement automatic button handling.
> > > Otherwise userspace help is necessary.
> >
> > Well there are 3 possible hardware key approaches:
> >
> >  1 - Hardware key that controls the hardware radio, and does not report anything to userspace
> 
> Can't do anything here so just ignore it.

Ok.

> >  2 - Hardware key that does not control the hardware radio and does not report anything to userspace
> 
> Kind of uninteresting button ;)

And this is the button that rfkill was originally designed for.
Laptops with integrated WiFi cards from Ralink have a hardware button that don't send anything to
userspace (unless the ACPI event is read) and does not directly control the radio itself.

> >  3 - Hardware key that does not control the hardware radio and reports the key to userspace
> >
> > So rfkill should not be used in the case of (1) and (3), but we still need something to support (2)
> > or should the keys not be handled by userspace and always by the driver?
> > This is making rfkill moving slowly away from the generic approach for all rfkill keys as the initial
> > intention was.
> >
> 
> I my "vision" rfkill would represent userspace namageable radio
> switch. We have the followng possible configurations:
> 
> 1. A device that does not allow controlling its transmitter from
> userspace. The driver should not use/register with rfkill subsystem as
> userspace can't do anyhting with it. If device has a button killing
> the transmitter the driver can still signal userspace appropriate
> event (KEY_WIFI, KEY_BLUETOOTH, etc) if it can detect that button was
> presssed so userspace can monitor state of the transmitter and
> probably shut down other transmitters to keep everything in sync.

And this event should be reported by a generic approach right? So it should
be similar as with your point 2 below. But this would mean that the driver
should create the input device. Or can a driver send the KEY_WIFI event
over a main layer without the need of a personal input device?
I am not that familiar with the input device layer in the kernel, and this is
my first attempt on creating something for it, so I might have missed something. ;)

Because it could still register with rfkill, only not give the callback functions
for changing the radio or polling. Then the driver can use the send_event function
to inform rfkill of the event and process it further. The sysfs attributes could
even be reduced to only add the change_status attribute when the radio_enable
and radio_disable callback functions are implemented.

> 2. A device that does allow controlling its transmitter. The driver
> may (should) register with rfkill subsystem. Additionally, if there is
> a button, the driver should register it with input subsystem. Driver
> should manage transmitter state in response to button presses unless
> userspace takes over the process.

This is indeed the main goal of rfkill. :)

> 3. A device without transmitter but with a button - just register with
> input core. Userspace will have to manage state of other devices with
> transmitters in response to button presses.

This is clear too. Rfkill is only intended for drivers that control a device with
a transmitter (WiFi, Bluetooth, IRDA) that have a button that is intended to
do something with the radio/transmitter.

> Does this make sense?

Yes, this was what I intended to do with rfkill, so at that point we have
the same goal.

> > > > > attribute should be a tri-state on/off/auto, "auto" meaning the driver
> > > > > itself manages radio state. This would avoid another tacky IMHO point
> > > > > that in your implementation mere opening of an input device takes over
> > > > > RF driver. Explicit control allow applications "snoop" RF state
> > > > > without disturbing it.
> > > >
> > > > Currently userspace can always check the state of the button whenever
> > > > they like by checking the sysfs entry.
> > > >
> > >
> > > Unless the key is not directly connected to the driver (so there is no
> > > sysfs entry). Again you force 2 different interfaces.
> >
> > Ok, so input device opening should not block the rfkill signal and the rfkill handler
> > should still go through with its work unless a different config option indicates that
> > userspace wants to handle the event.
> >
> 
> I don't think a config option is a good idea unless by config option
> you mean a sysfs attribute.

I indeed meant a sysfs attribute. I should have been more clear on this. :)

Ivo
