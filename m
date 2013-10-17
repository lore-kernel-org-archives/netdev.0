From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: transmit lockup using smsc95xx ethernet on usb3
Date: Thu, 17 Oct 2013 15:30:56 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7394@saturn3.aculab.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B738B@saturn3.aculab.com> <20131017000758.GL7082@xanatos>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	"Xenia Ragiadakou" <burzalodowa@gmail.com>
To: "Sarah Sharp" <sarah.a.sharp@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:45898 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755698Ab3JQOdE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 10:33:04 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 28478-08 for <netdev@vger.kernel.org>;
 Thu, 17 Oct 2013 15:32:59 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <20131017000758.GL7082@xanatos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Sarah Sharp [mailto:sarah.a.sharp@linux.intel.com]

Thanks for taking an interest.

> On Tue, Oct 15, 2013 at 10:59:18AM +0100, David Laight wrote:
> > We are seeing complete lockups of the transmit side when using
> > the smsc95xx driver connected to a USB3 port on an i7 (Ivybridge) cpu.
> > These errors are very intermittent - less than once a day, and
> > it isn't actually clear that they are related to traffic load.
> >
> > Most of the systems are running the 3.2 kernel from Ubuntu 12.04
> > but I've seen the same problem when running a 3.4 kernel.
> 
> Have you tried the latest stable kernel or the latest -rc kernel?

No. Although I've written a lot of device driver and comms protocol
stack code over the years I've not had to work out how to build
linux kernels - this may be the time I start!

Given the difficulty (or rather the infrequency) of reproducing the
problem I'd like to sort out the failing code path before changing
kernels so that I can then verify that a more recent kernel fixes it.

...
> > We are also seeing similar problems if we connect to a USB2
> > header.
> 
> Do you mean a USB 2.0 port under the xHCI host controller?  What does
> `lsusb -t` show as the parent host controller in that case?

To clarify the fail trace below is from an xhci controller, but
I'm pretty sure we've seen a tx lockup when using ohci.

The usbmon trace when the tx locks up starts with:

> > Two Bo 'fail -71', 6 succeed, one fails -32 the rest fail -104.
> >    done:9871:6913:60 ffff88020ea16a80 293818155 C Bo:3:003:2 -71 EPROTO 512 > 
> >    done:9872:6927:59 ffff88020ea16f00 293818235 C Bo:3:003:2 -71 EPROTO 0
> >    done:9873:6875:58 ffff88020ea16480 293818313 C Bo:3:003:2 0 1514 >
> >    done:9874:6786:57 ffff88020c7c83c0 293818353 C Bo:3:003:2 0 1514 >
> >    done:9875:6794:56 ffff88020c7c80c0 293818470 C Bo:3:003:2 0 1514 >
> >    done:9876:6789:55 ffff88020c7c8e40 293818589 C Bo:3:003:2 0 1514 >
> >    done:9877:6775:54 ffff88020c7c8240 293818702 C Bo:3:003:2 0 1090 >
> >    done:9878:6751:53 ffff88020c7c8180 293818803 C Bo:3:003:2 0 1514 >
> >    done:9879:6735:52 ffff88020c7c89c0 293818885 C Bo:3:003:2 -32 EPIPE 0
> >    done:9880:6671:51 ffff88020c7c8900 293818925 C Bo:3:003:2 -104 ECONNRESET 0
> > ... the ring is cleared in a software loop
> >     done:9927:1292:4 ffff88020cf0c480 293819015 C Bo:3:003:2 -104 0
> >     done:9928:1170:3 ffff88020ea160c0 293819016 C Bo:3:003:2 -104 0
> > Something is known to be wrong...
> >   start:9931         ffff88020ea160c0 293819037 S Co:3:003:0
> >                          s 02 01 0000 0002 0000 0
> >     done:9929:1080:3 ffff88020ea16780 293819044 C Bo:3:003:2 -104 0
> >      done:9930:945:2 ffff88020ea16000 293819044 C Bo:3:003:2 -104 0
> >       done:9931:48:1 ffff88020ea160c0 293819085 C Co:3:003:0 0 0

I've also seen resets that start with an interrupt from device 1.
In this case the ring is cleared with ESHUTDOWN and dmesg traces what looks
like an unplug-plug action.

Last successful ethernet transmit
ffff88020c4870c0 701760986 C Bo:3:018:2 0 1090 >
ffff88020c4870c0 701760992 S Bo:3:018:2 -115 1090
                  = 3a340000 3a440000 22003200 00224d98
                    d8460002 1f0057d7 08004500 042879ca
Interrupt - I think from the root hub.
ffff88020c8570c0 701761038 C Ii:3:001:1 0:2048 1 = 02
ffff88020c8570c0 701761042 S Ii:3:001:1 -115:2048 4 <
ffff88020ea16840 701761046 C Ii:3:018:3 -71:1 0  EPROTO
ffff88020ea16840 701761047 S Ii:3:018:3 -115:1 16 <
ffff88020c53c480 701761051 C Bi:3:018:1 -71 0
ffff88020c487180 701761054 C Bo:3:018:2 -71 1024 >
ffff880210570240 701761063 S Ci:3:001:0 s a3 00 0000 0001 0004 4 <
ffff880210570240 701761071 C Ci:3:001:0 0 4 = 00010100
ffff880210570240 701761074 S Co:3:001:0 s 23 01 0010 0001 0000 0
ffff88020c53c540 701761076 C Bi:3:018:1 -71 0
ffff880210570240 701761078 C Co:3:001:0 0 0
ffff88020c487240 701761117 C Bo:3:018:2 -71 0
ffff88020c53cd80 701761156 C Bi:3:018:1 -108 0   ESHITDOWN
ffff88020c53c9c0 701761158 C Bi:3:018:1 -108 0
ffff88020c487840 701761196 C Bo:3:018:2 -108 0
ffff88020c487900 701761201 C Bo:3:018:2 -108 0
... lots of similar lines deleted
ffff88020c487540 701761299 C Bo:3:018:2 -108 0
ffff88020c4870c0 701761300 C Bo:3:018:2 -108 0
ffff88020ea16840 701761304 C Ii:3:018:3 -71:1 0
ffff88020c8570c0 701782179 C Ii:3:001:1 0:2048 1 = 02
ffff88020c8570c0 701782183 S Ii:3:001:1 -115:2048 4 <
ffff88020c95be40 703089906 C Ii:3:020:1 -108:8 0
device 17 will be the hub on the smsc95xx chip
ffff88020c95b240 703427572 C Ii:3:017:1 -108:2048 0
ffff88020c487540 703427788 S Ci:3:001:0 s a3 00 0000 0001 0004 4 <
ffff88020c487540 703427803 C Ci:3:001:0 0 4 = 01010100

...
> I would suggest you try with the latest stable kernel, with
> CONFIG_USB_DEBUG and CONFIG_USB_XHCI_HCD_DEBUGGING enabled.  If you try
> the latest 3.12-rc, you will only need the CONFIG_USB_DEBUG.  Or, if
> that output is too much (it will spew on short packets, which may be an
> issue with your ethernet adapter),

The only way I've got the above usbmon trace is by reading 1000000
lines (with dd) and saving the file if the last line output by dmesg
changes. I suspect the above might trace too much for that!
I think the kernel I have has the xhci_warn() compiled out - I'm not
seeing any of those reported by dmesg. I looked at the .h files and
couldn't see where xhci_warn() gets suppressed.

> with the 3.12-rc kernel, you can turn
> off CONFIG_USB_DEBUG and capture command trace events through the xHCI
> trace infrastructure.  Xenia can help you with that if necessary (I'm
> going to be at a conference starting Friday).
> 
> Without that dmesg, I really can't tell what's happening at an xHCI
> level.

Have you any idea which code loops are clearing the ring with ECONNRESET
and ESHUTDOWN and where they might be being called from?
I've been reading the code but couldn't see any obvious paths that would
lead to the ring being cleared with those codes.

	David
