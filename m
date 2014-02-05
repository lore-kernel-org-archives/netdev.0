From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [RFT 1/2] xhci 1.0: Limit arbitrarily-aligned scatter gather.
Date: Wed, 5 Feb 2014 11:58:12 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6B8C70@AcuExch.aculab.com>
References: <cover.1391544195.git.sarah.a.sharp@linux.intel.com>
 <baa32650c285a89671030370f638e2203171b3a0.1391544195.git.sarah.a.sharp@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	=?Windows-1252?Q?Bj=F8rn_Mork?= <bjorn@mork.no>,
	Freddy Xin <freddy@asix.com.tw>,
	Ming Lei <ming.lei@canonical.com>
To: 'Sarah Sharp' <sarah.a.sharp@linux.intel.com>,
	Mark Lord <mlord@pobox.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:33498 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752000AbaBEL7C convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Feb 2014 06:59:02 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 13788-08 for <netdev@vger.kernel.org>;
 Wed,  5 Feb 2014 11:59:00 +0000 (GMT)
In-Reply-To: <baa32650c285a89671030370f638e2203171b3a0.1391544195.git.sarah.a.sharp@linux.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sarah Sharp 
> xHCI 1.0 hosts have a set of requirements on how to align transfer
> buffers on the endpoint rings called "TD fragment" rules.  When the
> ax88179_178a driver added support for scatter gather in 3.12, with
> commit 804fad45411b48233b48003e33a78f290d227c8 "USBNET: ax88179_178a:
> enable tso if usb host supports sg dma", it broke the device under xHCI
> 1.0 hosts.  Under certain network loads, the device would see an
> unexpected short packet from the host, which would cause the device to
> stop sending ethernet packets, even through USB packets would still be
> sent.
> 
> Commit 35773dac5f86 "usb: xhci: Link TRB must not occur within a USB
> payload burst" attempted to fix this.  It was a quick hack to partially
> implement the TD fragment rules.  However, it caused regressions in the
> usb-storage layer and userspace USB drivers using libusb.  The patches
> to attempt to fix this are too far reaching into the USB core, and we
> really need to implement the TD fragment rules correctly in the xHCI
> driver, instead of continuing to wallpaper over the issues.
> 
> Disable arbitrarily-aligned scatter-gather in the xHCI driver for 1.0
> hosts.  Only the ax88179_178a driver checks the no_sg_constraint flag,
> so don't set it for 1.0 hosts.  This should not impact usb-storage or
> usbfs behavior, since they pass down max packet sized aligned sg-list
> entries (512 for USB 2.0 and 1024 for USB 3.0).

I believe that this will cause the ax88179 driver to discard some
receive packets on (at least) my panther point 1.00 controller.

I certainly saw bursts of lost packets in some testing I did before the
scatter-gather transfers were enabled, and before any of my patches.

The problem is that the ax88179_178a driver submits receive URBs that
cross 64k boundaries, and are not aligned (they start at an 0x40 boundary).
Receive USB frames can contain multiple ethernet frames, by default they
are 20kB (and sit in 24kB of memory).

I'm not entirely convinced that this is acceptable long term behaviour.

	David
