From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ksz884x: fix receive polling race condition
Date: Wed, 19 Dec 2012 12:45:17 -0800 (PST)
Message-ID: <20121219.124517.1102318399340089630.davem@davemloft.net>
References: <20121218135700.GT23447@wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Tristram.Ha@micrel.com, dannyfeng@tencent.com,
	netdev@vger.kernel.org, cphealy@gmail.com
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49344 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752310Ab2LSUpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 15:45:18 -0500
In-Reply-To: <20121218135700.GT23447@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Tue, 18 Dec 2012 14:57:00 +0100

> The ksz884x driver does receive processing in a custom tasklet, and
> seems to be assuming that since it takes its private interface spinlock
> with spin_lock_irq(), it won't be running concurrently with its own
> interrupt handler, as it cannot be preempted by it, but since its
> interrupt handler doesn't do any locking whatsoever, the receive
> processing tasklet and interrupt handler can end up running concurrently
> on different CPUs.
> 
> As a result of this, the ksz884x receive path ends up locking up fairly
> easily, when the receive processing tasklet's reenabling of receive
> interrupts (due to it being done with polling the receive ring) races
> with the interrupt handler's disabling of receive interrupts (due to a
> new receive interrupt coming in) resulting in the receive interrupt
> being masked but the receive processing tasklet not being scheduled.
> 
> Fix this by making the ksz884x interrupt handler take its private
> interface spinlock.  This requires upgrading the spin_lock() in the
> transmit cleanup tasklet to a spin_lock_irq(), as otherwise the IRQ
> handler can preempt transmit cleanup and deadlock the system, but
> with those two changes, no more receive lockups have been observed.
> 
> Reported-by: Chris Healy <cphealy@gmail.com>
> Signed-off-by: Lennert Buytenhek <buytenh@wantstofly.org>

Applied, thanks.
