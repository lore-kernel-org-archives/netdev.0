From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Fix locking issues in PPP, 6pack, mkiss and strip
 line disciplines.
Date: Mon, 13 Jul 2009 10:31:39 -0700 (PDT)
Message-ID: <20090713.103139.188324296.davem@davemloft.net>
References: <20090712234854.10cfcef2@lxorguk.ukuu.org.uk>
	<20090712.210730.170014470.davem@davemloft.net>
	<20090713091928.7e89bab8@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, netdev@vger.kernel.org,
	guido@trentalancia.com, paulus@samba.org,
	linux-hams@vger.kernel.org, hans@esrac.ele.tue.nl
To: alan@lxorguk.ukuu.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32962
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756730AbZGMRbg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2009 13:31:36 -0400
In-Reply-To: <20090713091928.7e89bab8@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Mon, 13 Jul 2009 09:19:28 +0100

> Historically it went
> 
> 		network bh
> 			transmit packet
> 				ldisc layer
> 					tty write method
> 
> and lots of code assumed that.

They still can assume such things.  All locking is BH based, all
networking transmit paths occur in BH or with BH's disabled, never in
hardware interrupt context.

Even TX reclaim hardware interrupts that free SKBs reschedule that
work to BH context.

> Today the network bits get kicked off at IRQ level.

That would be news to me :)

Where do you see that in the traces that Ralf posted?  His trace was
in fact a TTY receive path via USB:

cpu_idle()
	handle_IRQ_event()
	uhci_irq()
	ftdi_read_bulk_callback()
	ftdi_process_read()
	tty_flip_buffer()
		flush_to_ldisc()
		mkiss_receive_buf()
		spin_lock_bh() --> BH disable in hard IRQ, OH NOEZ!

And, as Ralf's changelog stated:

--------------------
The issue was, that the locking code in mkiss was assuming it was only
ever being called in process or bh context.  Fixed by converting the
involved locking code to use irq-safe locks.
--------------------

mkiss_receive_buf(), the problematic code path, is invoked by
the TTY layer directly from LDISC flushing and the TTY device's
IRQ handler here.

How does networking's TX policy have anything to do with this?
