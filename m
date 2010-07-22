From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 1/1] Bluetooth: hidp: Add support for hidraw   
 HIDIOCGFEATURE and HIDIOCSFEATURE
Date: Thu, 22 Jul 2010 08:21:55 -0700
Message-ID: <1279812115.2621.6.camel@localhost.localdomain>
References: <1276467601-9066-1-git-send-email-alan@signal11.us>
	 <1278623485.10421.73.camel@localhost.localdomain>
	 <4C369CDC.9080104@signal11.us>
	 <1278662497.10421.94.camel@localhost.localdomain>
	 <4C371DE8.9020002@signal11.us>
	 <1278680790.10421.106.camel@localhost.localdomain>
	 <4C372CEE.3070109@signal11.us>
	 <1278696815.10421.137.camel@localhost.localdomain>
	 <alpine.LNX.2.00.1007221612450.4741@pobox.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alan Ott <alan@signal11.us>, David S Miller <davem@davemloft.net>,
	Michael Poole <mdpoole@troilus.org>,
	Bastien Nocera <hadess@hadess.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:35647 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752384Ab0GVPWF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 11:22:05 -0400
In-Reply-To: <alpine.LNX.2.00.1007221612450.4741@pobox.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

> > > >>> what is usb-hid.ko doing here? I would expect a bunch of code
> > > >>> duplication with minor difference between USB and Bluetooth.
> > > >>>        
> > > >> usbhid doesn't have a lot of code for hidraw. Two functions are involved:
> > > >>       usbhid_output_raw_report()
> > > >>           - calls usb_control_msg() with Get_Report
> > > >>       usbhid_get_raw_report()
> > > >>           - calls usb_control_msg() with Set_Report
> > > >>               OR
> > > >>           - calls usb_interrupt_msg() on the Ouput pipe.
> > > >>
> > > >> This is of course easier than bluetooth because usb_control_msg() is
> > > >> synchronous, even when requesting reports, mostly because of the nature
> > > >> of USB, where the request and response are part of the same transfer.
> > > >>
> > > >> For Bluetooth, it's a bit more complicated since the kernel treats it
> > > >> more like a networking interface (and indeed it is). My understanding is
> > > >> that to make a synchronous transfer in bluetooth, one must:
> > > >>       - send the request packet
> > > >>       - block (wait_event_*())
> > > >>       - when the response is received in the input handler, wake_up_*().
> > > >>
> > > >> There's not really any code duplication, mostly because initiating
> > > >> synchronous USB transfers (input and output) is easy (because of the
> > > >> usb_*_msg() functions), while making synchronous Bluetooth transfers
> > > >> must be done manually. If there's a nice, convenient, synchronous
> > > >> function in Bluetooth similar to usb_control_msg() that I've missed,
> > > >> then let me know, as it would simplify this whole thing.
> > > >>      
> > > > there is not and I don't think we ever get one. My question here was
> > > > more in the direction why HID core is doing these synchronously in the
> > > > first place. Especially since USB can do everything async as well.
> > >
> > > I'm open to suggestions. The way I see it is from a user space 
> > > perspective. With Get_Feature being on an ioctl(), I don't see any clean 
> > > way to do it other than synchronously. Other operating systems (I can 
> > > say for sure Windows, Mac OS X, and FreeBSD) handle Get/Set Feature the 
> > > same way (synchronously) from user space.
> > > 
> > > You seem to be proposing an asynchronous interface. What would that look 
> > > like from user space?
> > 
> > not necessarily from user space, but at least from HID core to HIDP and
> > usb-hid transports. At least that is what I would expect, Jiri?
> 
> Sorry for this taking too long (vacations, conferences, you name it) for 
> me to respond.
> 
> As all the _raw() callbacks are purely intended for userspace interaction 
> anyway, it's perfectly fine (and in fact desirable) for the low-level 
> transport drivers to perform these operations synchronously (and that's 
> what USB implementation does as well).
> 
> Marcel, if your opposition to synchronous interface is strong, we'll have 
> to think about other aproaches, but from my POV, the patch is fine as-is 
> for Bluetooth.

that the ioctl() API is synchronous is fine to me, however pushing that
down to the transport drivers seems wrong to me. I think the HID core
should be able to handle a fully asynchronous transport driver. I know
that with the USB subsystem you are little bit spoiled here, but for
Bluetooth it is not the case. And in the end even using the asynchronous
USB URB calls would be nice as well.

So why not make the core actually wait for responses from the transport
driver. I would make the transport drivers a lot simpler in the long
run. And I know that most likely besides Bluetooth and USB you won't see
another, but you never know.

Regards

Marcel


