From: Martin Fuzzey <mfuzzey@gmail.com>
Subject: Re: Problem with non aligned DMA in usbnet on ARM
Date: Fri, 13 Aug 2010 12:06:54 +0200
Message-ID: <4C65193E.4090807@gmail.com>
References: <AANLkTi=ycg=adcizNWKMCb7EdfDANM=6Es7r_gF1LbhV@mail.gmail.com>	<4C627479.4060400@parrot.com>	<AANLkTinU2JEkeYJHo4tA+kD9Pd_F3YcUTbK9w6igc7s8@mail.gmail.com>	<4C62C7B3.2030706@nvidia.com> <20100811203505.GA463@n2100.arm.linux.org.uk> <4C632217.9000608@gmail.com> <4C642AA9.1060404@parrot.com>
Reply-To: mfuzzey@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Gary King <GKing@nvidia.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	linux-usb <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Greg KH <greg@kroah.com>
To: Matthieu CASTET <matthieu.castet@parrot.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:34942 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761413Ab0HMKHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Aug 2010 06:07:04 -0400
In-Reply-To: <4C642AA9.1060404@parrot.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matthieu CASTET wrote:
> memmove is our friend :
> the buffer allocated in usbnet got an offset.
> All you have to do it remove this offset and memmove the data. That
> what I did [1], and why it is better to do it in usb driver.
>
>
> [1] http://article.gmane.org/gmane.linux.usb.general/28700
The problem I see with this approach is that it requires the usb driver
to be aware of the device controller's quirks  (hence the
gadget_dma32()) your patch adds. That appears to be the norm (and maybe
unavoidable) on the gadget side but on the host side things aren't
supposed to work like that.

The expectation for USB hosts is that any properly written usb driver
will work with any properly written host controller driver. I don't
think it's reasonable to expect driver developers to test their code
with all the HCDs, nor expect HCD developers to test their code with all
the drivers.

So I think a policy needs to be defined to ensure this and enforced in
the code. I can see two possible methods:

1) Require that usb drivers submit buffers obtained from kmalloc() and
friends with no extra offsets. If they want some other alignment later
they can use memmove in the completion handler. Enforce this in the core
by checking the buffer pointers are aligned to ARCH_KMALLOC_MINALIGN

or

2) Require that usb_submit_urb() accept byte aligned buffers. Enforce
this by a new test in usbtest (which all HCDs are expected to pass).
Implement it either in individual HCDs that require it or by letting
HCDs inform the core of their requirements and have the core do the
alignment (as it already does the dma mapping). Of course HCDs that can
implement byte aligned transfers (either natively or using tricks such
as the one Russell suggested) should do so.

I think 2) is the better solution because:
a) Solution 1 will impose a runtime overhead even on platforms / HCDs
that don't need it (including the most common cases)
b) There are more drivers than HCDs

Martin


