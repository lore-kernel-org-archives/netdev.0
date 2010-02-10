From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3]: via-velocity: Fixes for locking issues
Date: Tue, 09 Feb 2010 16:31:33 -0800 (PST)
Message-ID: <20100209.163133.38216503.davem@davemloft.net>
References: <20100205165253.3f316b98@marrow.netinsight.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davej@redhat.com, ben@decadent.org.uk
To: simon.kagstrom@netinsight.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47664
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752273Ab0BJAbU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2010 19:31:20 -0500
In-Reply-To: <20100205165253.3f316b98@marrow.netinsight.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Date: Fri, 5 Feb 2010 16:52:53 +0100

> The patch uses spin_trylock in the interrupt handler, and returns
> IRQ_NONE if it's already held. Here is a place where I'm unsure about
> the right way though. Another alternative is to use spin_lock_irqsave
> in velocity_poll(), but I'd like to avoid turning the interrupts off
> for "long" periods of time when the actual velocity interrupt can't
> happen anyway (since it is turned off while executing velocity_poll().

It can happen in this situation and this is not the right way to
handle this.

You will lose interrupt events if the situation is that the interrupt
for the VIA has migrated from one cpu to another and another cpu is in
the VIA interrupt handler when we see the lock held.

Consider also the case where another cpu has the VIA lock as
a result of a device sharing the IRQ with VIA firing.

You'll lose events and jam the chip in that case too.

What this comes down to is not using the lock correctly, you
can't paper around it with this trylock stuff.

The proper thing to do is make the ->poll() handler use the lock
correctly by disabling interrupts.

If the VIA driver wants to avoid holding interrupts disabled for long
periods of time in ->poll(), it's locking mechanisms will need to be
rewritten completely.  The only safe way to do this is to do something
like how the tg3 driver works, wherein the interrupt handler runs
lockless, there is a special IRQ quiesce sequence when shutting down
the chip, and the ->poll() handler et al. use softirq safe locks
instead of hardirq safe ones.

For now you're going to have to accept interrupts being disabled in
order to fix this bug for the time being.

Please resubmit this patch series once you've worked this out.

Thanks!
