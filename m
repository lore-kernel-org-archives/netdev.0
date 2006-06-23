From: Vojtech Pavlik <vojtech@suse.cz>
Subject: Re: [RFC PATCH 1/2] Hardware button support for Wireless cards: radiobtn
Date: Fri, 23 Jun 2006 13:08:19 +0200
Message-ID: <20060623110819.GA29574@suse.cz>
References: <200605251716.00742.IvDoorn@gmail.com> <200606041002.33696.IvDoorn@gmail.com> <200606041214.45999.stefan@loplof.de> <200606171705.59498.IvDoorn@gmail.com> <20060622175546.7eebebb4@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ivo van Doorn <ivdoorn@gmail.com>, Stefan Rompf <stefan@loplof.de>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:43659 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S933032AbWFWLIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 07:08:22 -0400
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
In-Reply-To: <20060622175546.7eebebb4@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 22, 2006 at 05:55:46PM +0200, Jiri Benc wrote:

> On Sat, 17 Jun 2006 17:05:55 +0200, Ivo van Doorn wrote:
> > With this approach more buttons can be registered,
> > it includes the optional field to report an update of the key status
> > to the driver that registered it, and it supports for non-polling keys.
> 
> I think this is not specific to networking anymore, so it should go to
> lkml. Please be sure to Cc: input devices maintainer, Dmitry Torokhov.
> 
> Regarding rfkill button, I talked about that with Vojtech Pavlik (Cc:ed)
> and he suggests this solution:
> 
> - driver is responsible for turning on/off radio when the input device
>   is not opened;
> - when something opens the input device, it receives input events and 
>   gets responsible to turn on/off the radio (by ioctl or putting the 
>   network interfaces up/down).
> 
> This is of course not possible for all hardware, but it gives the most
> flexibility while keeping the possibility to switch of the radio without
> userspace support.
 
Let me elaborate a little bit on the possible implementation:

	1) 802.11 card drivers will implement an input device for each card in
	the system that has a user-controlled RF-Kill button or switch.

	2) 802.11 card drivers will implement an interface to enable/disable the
	radio, be it through a call, ioctl, or whatever, that is accessible from
	both the kernel and userspace.

	3) ACPI buttons drivers, and keyboard drivers will generate KEY_RFKILL
	on machines where RF-Kill keys are reported using ACPI events or
	keyboard scancodes.

	3) A rfkill.ko input handler module will be implemented, that listens to
	the SW_RFKILL and KEY_RFKILL events from all devices in the system, and
	will enable/disable radios on all 802.11 devices in the system.

The above will make the RF-Kill button work under all real scenarios as
user expects - it will enable/disable the radio. In the case where a
user has an additional PCMCIA card, both the radios will be disabled by
presing the RF-Kill button, which is arguably what the user expects.
Even BlueTooth or other RF technologies (CDMA, EDGE) can hook into this
mechanism.

	4) When userspace wants to take over the control over RF-Kill, and start
	additional services based on that, it can open the input devices to get
	the state of the buttons/switches, AND it can issue the EVIOCGRAB
	ioctl() to prevent the rfkill.ko and any other handlers from getting the
	events.

This allows simple implementation of dbus notifications and
NetworkManager-style configuration of network interfaces.

-- 
Vojtech Pavlik
Director SuSE Labs
