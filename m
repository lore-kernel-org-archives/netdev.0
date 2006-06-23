From: Vojtech Pavlik <vojtech@suse.cz>
Subject: Re: [RFC PATCH 1/2] Hardware button support for Wireless cards: radiobtn
Date: Fri, 23 Jun 2006 21:32:46 +0200
Message-ID: <20060623193246.GC6270@suse.cz>
References: <200605251716.00742.IvDoorn@gmail.com> <20060622175546.7eebebb4@griffin.suse.cz> <20060623110819.GA29574@suse.cz> <200606232051.37518.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Benc <jbenc@suse.cz>, Stefan Rompf <stefan@loplof.de>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:43697 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751957AbWFWTdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 15:33:15 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
Content-Disposition: inline
In-Reply-To: <200606232051.37518.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 23, 2006 at 08:51:33PM +0200, Ivo van Doorn wrote:

> > > This is of course not possible for all hardware, but it gives the most
> > > flexibility while keeping the possibility to switch of the radio without
> > > userspace support.
> >  
> > Let me elaborate a little bit on the possible implementation:
> > 
> > 	1) 802.11 card drivers will implement an input device for each card in
> > 	the system that has a user-controlled RF-Kill button or switch.
> 
> So basicly 1 input device for every single wireless driver that implements
> the RF-Kill button?

Yes.

> Is there any particular reason for not using 1 input device shared by all?

Yes.

In the unlikely case where there are two devices which implement a
rfkill button in the system, the input core doesn't have a way how to
express the state of these two different buttons with the same meaning
(and hence the same code - KEY_RFKILL) in a single input device.

You'd have to assign a range of codes to the shared device, which goes
agains the design of the Linux inpu layer.

Anyway, for the most common case, where you have a single RF-Kill key in
the whole system, there will not be any difference to using the shared
device.

What do you consider the benefits of using a shared input device?

> > 	2) 802.11 card drivers will implement an interface to enable/disable the
> > 	radio, be it through a call, ioctl, or whatever, that is accessible from
> > 	both the kernel and userspace.
> 
> Userspace could switch off the radio by using the txpower ioctl of
> ifdown/ifup. Or should an approach call be implemented?

I'm an input guy, the details of how to disable the radio I'll leave up
to you - the WiFi folks on netdev.

You may want to consider that the radio chip usually synthesizes a
frequency that it mixes with the incoming signal to frequency-shift it
to a low frequency which then can be demodulated. Because of that, even
the receiver, when working, can affect devices nearby. This is why FM
radio receivers are not allowed on airplanes.

Hardware RF-Kill disables both RX and TX, by stopping the radio chip.
Setting TX power to an extremely low value might not be the same.

On the other hand, you may define in the API that setting TX power to
zero also disables the receiver.

> > 	3) ACPI buttons drivers, and keyboard drivers will generate KEY_RFKILL
> > 	on machines where RF-Kill keys are reported using ACPI events or
> > 	keyboard scancodes.
> 
> Why both an input and ACPI event?
> With ACPI restricted to x86 only, wouldn't a more generic approach be desired?

I was talking about the ACPI EC sending us an event. This is how are
ACPI buttons implemented in certain notebooks. I definitely don't want
to use the acpi events as received by acpid now as the interface. Sorry
for the confusion.

> > 	3) A rfkill.ko input handler module will be implemented, that listens to
> > 	the SW_RFKILL and KEY_RFKILL events from all devices in the system, and
> > 	will enable/disable radios on all 802.11 devices in the system.
> >
> > The above will make the RF-Kill button work under all real scenarios as
> > user expects - it will enable/disable the radio. In the case where a
> > user has an additional PCMCIA card, both the radios will be disabled by
> > presing the RF-Kill button, which is arguably what the user expects.
> > Even BlueTooth or other RF technologies (CDMA, EDGE) can hook into this
> > mechanism.
> > 
> > 	4) When userspace wants to take over the control over RF-Kill, and start
> > 	additional services based on that, it can open the input devices to get
> > 	the state of the buttons/switches, AND it can issue the EVIOCGRAB
> > 	ioctl() to prevent the rfkill.ko and any other handlers from getting the
> > 	events.
> >
> > This allows simple implementation of dbus notifications and
> > NetworkManager-style configuration of network interfaces.

-- 
Vojtech Pavlik
Director SuSE Labs
