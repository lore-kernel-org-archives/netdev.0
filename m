From: David Miller <davem@davemloft.net>
Subject: Re: de4x5 hangs with SMP: synchronize_irq() in interrupt handler?
Date: Fri, 24 Sep 2010 21:27:02 -0700 (PDT)
Message-ID: <20100924.212702.116381928.davem@davemloft.net>
References: <201009212230.51036.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux@rainbow-software.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33645
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751491Ab0IYE0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Sep 2010 00:26:42 -0400
In-Reply-To: <201009212230.51036.linux@rainbow-software.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ondrej Zary <linux@rainbow-software.org>
Date: Tue, 21 Sep 2010 22:30:49 +0200

> I'm trying to get two Compex FreedomLine 32 PnP-PCI2 cards to work (21041-AA 
> and 21041-PA) - there are problems with de2104x driver (one of the cards does 
> not work at all and the other one switches to non-existing AUI port when the 
> link goes down and never switches back to RJ45) and I know that de4x5 driver 
> worked for me in past.
> 
> Loading de4x5 causes the machine to hang immediately. It hangs at 
> synchronize_irq() call from de4x5_interrupt(). Commenting out this allows the 
> driver to work. Without SMP, synchronize_irq() is redefined to barrier() so 
> it works.
> 
> I don't have a clue how to fix this properly - does anyone know?

This driver is an enormous mess.

Someone half-converted the driver over to use a spinlock to protect
the interrupt handler and other parts of the driver, but that
conversion is so obvsiously buggy that I can't see how it was
ever tested.

All of the tests on lp->interrupt are racy, nothing protects the
setting and testing of that value.  It is set with lp->lock held
but tested asynchronously by the driver's ->ndo_start_xmit
method.

It uses this value to determine if it should queue the packet into
a software queue that gets processed at the end of the interrupt
processing.

Problem is, that code path deadlocks, the end of de4x5_interrupt
pulls the packets out of that queue in a loop, and sends them
to the function named de4x5_queue_pkt().

Which tries to take the lp->lock spinlock, which is already held
by de4x5_interrupt().

This driver needs major surgery to get into a working state on
SMP.
