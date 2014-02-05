From: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Subject: Re: [RFT 1/2] xhci 1.0: Limit arbitrarily-aligned scatter gather.
Date: Wed, 5 Feb 2014 13:08:47 -0800
Message-ID: <20140205210847.GD12087@xanatos>
References: <cover.1391544195.git.sarah.a.sharp@linux.intel.com>
 <baa32650c285a89671030370f638e2203171b3a0.1391544195.git.sarah.a.sharp@linux.intel.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F6B8C70@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Lord <mlord@pobox.com>, netdev <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	=?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	Freddy Xin <freddy@asix.com.tw>,
	Ming Lei <ming.lei@canonical.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:45470 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751903AbaBEVJV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Feb 2014 16:09:21 -0500
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6B8C70@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 05, 2014 at 11:58:12AM +0000, David Laight wrote:
> From: Sarah Sharp 
> > xHCI 1.0 hosts have a set of requirements on how to align transfer
> > buffers on the endpoint rings called "TD fragment" rules.  When the
> > ax88179_178a driver added support for scatter gather in 3.12, with
> > commit 804fad45411b48233b48003e33a78f290d227c8 "USBNET: ax88179_178a:
> > enable tso if usb host supports sg dma", it broke the device under xHCI
> > 1.0 hosts.  Under certain network loads, the device would see an
> > unexpected short packet from the host, which would cause the device to
> > stop sending ethernet packets, even through USB packets would still be
> > sent.
> > 
> > Commit 35773dac5f86 "usb: xhci: Link TRB must not occur within a USB
> > payload burst" attempted to fix this.  It was a quick hack to partially
> > implement the TD fragment rules.  However, it caused regressions in the
> > usb-storage layer and userspace USB drivers using libusb.  The patches
> > to attempt to fix this are too far reaching into the USB core, and we
> > really need to implement the TD fragment rules correctly in the xHCI
> > driver, instead of continuing to wallpaper over the issues.
> > 
> > Disable arbitrarily-aligned scatter-gather in the xHCI driver for 1.0
> > hosts.  Only the ax88179_178a driver checks the no_sg_constraint flag,
> > so don't set it for 1.0 hosts.  This should not impact usb-storage or
> > usbfs behavior, since they pass down max packet sized aligned sg-list
> > entries (512 for USB 2.0 and 1024 for USB 3.0).
> 
> I believe that this will cause the ax88179 driver to discard some
> receive packets on (at least) my panther point 1.00 controller.

Please go test with that branch, and see if you can trigger this issue.
If you can reproduce this, please send me the exact instructions or
commands to do so.

> I certainly saw bursts of lost packets in some testing I did before the
> scatter-gather transfers were enabled, and before any of my patches.

What is the user impact of these lost packets?  Does the device drop one
particular transfer, and continue with the next transfer, or does the
device get wedged and stop sending packets all together?

Ethernet protocols are designed to deal with packet loss.  Does the user
care about a dropped packet every once and while?  Especially for USB
ethernet devices, which really shouldn't be used in an enterprise
setting?

I'm not saying this shouldn't be fixed.  I'm simply trying to see how
much of a priority it is to fix this.  I really want to re-architect the
code and do this right, and it will take some time.

> The problem is that the ax88179_178a driver submits receive URBs that
> cross 64k boundaries, and are not aligned (they start at an 0x40 boundary).
> Receive USB frames can contain multiple ethernet frames, by default they
> are 20kB (and sit in 24kB of memory).

Perhaps you should add printks when a TRB is split on 64KB boundaries
and see if the device drops packets around that time?

> I'm not entirely convinced that this is acceptable long term behaviour.

If the 64KB boundaries are an issue, it will mean that bug has been in
the xHCI driver for a very long time.  In the kernel community, if a fix
for something that has been historically broken causes regressions,
we revert it.

Sarah Sharp
