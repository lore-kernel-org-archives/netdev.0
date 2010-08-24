From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix deadlock between boomerang_interrupt and
 boomerang_start_tx in 3c59x
Date: Tue, 24 Aug 2010 01:48:42 -0700 (PDT)
Message-ID: <20100824.014842.193701591.davem@davemloft.net>
References: <20100823202452.GC12906@hmsreliant.think-freely.org>
	<1282596538.2378.340.camel@edumazet-laptop>
	<20100823234006.GA8976@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59858
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751327Ab0HXIsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 04:48:24 -0400
In-Reply-To: <20100823234006.GA8976@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon, 23 Aug 2010 19:41:44 -0400

> Ah, I see what your saying.  Since bitfield access is not a single instruction
> you get races when multiple accesses take place at once, since the assignment is
> non-atomic, nor is the read.
> 
> In this case, thats ok.  I say that because in the only time we really care what
> the value of this bitfield is, is when we've recursed from the interrupt handler
> to the netconsole module, back into the transmit path on the same cpu.  In that
> case the read is guaranteed to be ordered after the write, since its a linear
> code path.  In the case where cpu 0 is in the interrupt handler and cpu1 is
> going into the transmit method for this driver, we don't really care what the
> value of the bitfield is, its a don't care.  If we read it as a zero, thats ok,
> we have the driver-internal sempahore still protecting us (the one that
> deadlocks if you recurse via netconsole on the same cpu).  And if we read it as
> a 1, thats ok too, because we simply cause the network scheduler to queue the
> frame and send it again as soon as we're out of the interrupt handler.

Right this should be OK.

The only write to the bit happens with the lock held.

The other bits are never modified while the device is active
and interrupts can run.

I've applied Neil's patch, thanks Neil.
