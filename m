From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Subject: Re: [PATCH 0/3]: via-velocity: Fixes for locking issues
Date: Wed, 10 Feb 2010 10:33:58 +0100
Message-ID: <20100210103358.41a45851@marrow.netinsight.se>
References: <20100205165253.3f316b98@marrow.netinsight.se>
	<20100209.163133.38216503.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davej@redhat.com, ben@decadent.org.uk
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ernst.netinsight.se ([194.16.221.21]:45470 "HELO
	ernst.netinsight.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752911Ab0BJJeK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 04:34:10 -0500
In-Reply-To: <20100209.163133.38216503.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David!

Thanks for the comments, I understand the problem more clearly now.

On Tue, 09 Feb 2010 16:31:33 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> The proper thing to do is make the ->poll() handler use the lock
> correctly by disabling interrupts.

In reply to this message is an updated patch series which uses
spin_lock_irqsave/restore in velocity_poll instead.

> If the VIA driver wants to avoid holding interrupts disabled for long
> periods of time in ->poll(), it's locking mechanisms will need to be
> rewritten completely.  The only safe way to do this is to do something
> like how the tg3 driver works, wherein the interrupt handler runs
> lockless, there is a special IRQ quiesce sequence when shutting down
> the chip, and the ->poll() handler et al. use softirq safe locks
> instead of hardirq safe ones.

Yes, I guess that would be the long-term solution for this driver. The
main problem with running the interrupt handler unlocked now is the
error handler, which is executed directly from the interrupt handler.


Anyway, when you are happy with the patch series, I think it is 2.6.33
material as the velocity driver would otherwise contain a regression
compared to 2.6.32.

Changes in the patch series:

* Patch 1: Unchanged

* Patch 2: Unchanged

* Patch 3: Use spin_lock_irqsave in velocity_poll and remove
  spin_trylock from the interrupt handler.


As before, I'm only able to test it on a uniprocessor with spinlock
debugging turned on. With the patch set, I can no longer get it to
lockup when running heavy traffic for both interrupt sources (which was
easy without the patches).

Thanks,
// Simon
