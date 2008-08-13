From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] netconsole: avoid deadlock on printk from driver
 code
Date: Wed, 13 Aug 2008 03:29:46 -0700 (PDT)
Message-ID: <20080813.032946.114949936.davem@davemloft.net>
References: <20080813095324.GA15055@ben.ifi.uio.no>
	<20080813095942.GA9145@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vegard.nossum@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49077
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751309AbYHMK3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 06:29:45 -0400
In-Reply-To: <20080813095942.GA9145@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Wed, 13 Aug 2008 13:59:43 +0400

> On Wed, Aug 13, 2008 at 11:53:24AM +0200, Vegard Nossum wrote:
> > I encountered a hard-to-debug deadlock when I pulled out the plug of my
> > RealTek 8139 which was also running netconsole: The driver wants to print
> > a "link down" message. However, this triggers netconsole, which wants to
> > print the message using the same device. Here is a backtrace:
> > 
> >  [<c05916b6>] _spin_lock_irqsave+0x76/0x90
> >  [<c035b255>] rtl8139_start_xmit+0x65/0x130 <-- spin_lock(&tp->lock)
> >  [<c04c5e28>] netpoll_send_skb+0x158/0x1a0
> >  [<c04c62fb>] netpoll_send_udp+0x1db/0x1f0
> >  [<c037c70c>] write_msg+0x8c/0xc0
> >  [<c0135883>] __call_console_drivers+0x53/0x60
> >  [<c01358db>] _call_console_drivers+0x4b/0x90
> >  [<c0135a25>] release_console_sem+0xc5/0x1f0
> >  [<c0135f0b>] vprintk+0x1ab/0x3e0
> >  [<c013615b>] printk+0x1b/0x20
> >  [<c0349736>] mii_check_media+0x196/0x1e0
> >  [<c03597f4>] rtl_check_media+0x24/0x30
> >  [<c035a0ea>] rtl8139_interrupt+0x42a/0x4a0 <-- spin_lock(&tp->lock)
> >  [<c01716d8>] handle_IRQ_event+0x28/0x70
> >  [<c0172d9b>] handle_fasteoi_irq+0x6b/0xe0
> >  [<c0107128>] do_IRQ+0x48/0xa0
> > 
> > The least invasive fix is to detect that we're trying to re-enter the
> > driver code. We provide a netdev_busy() function which can be used to
> > determine whether a deadlock can occur if we try to transmit another
> > packet.
> > 
> > Note that this may lead to lost messages if the driver is active on
> > another CPU while we try to use the same device for netconsole.
> 
> This sucks.

It's also the wrong fix.

As a quicker and more palatable solution, print your link status
message in some kind of deferred context where you can have the
lock not held or similar.
