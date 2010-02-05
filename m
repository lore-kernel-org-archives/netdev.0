From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Subject: [PATCH 0/3]: via-velocity: Fixes for locking issues
Date: Fri, 5 Feb 2010 16:52:53 +0100
Message-ID: <20100205165253.3f316b98@marrow.netinsight.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net, davej@redhat.com,
	ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from ernst.netinsight.se ([194.16.221.21]:43814 "HELO
	ernst.netinsight.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754078Ab0BEPw7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2010 10:52:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This series of patches fixes a set of locking issues in the
via-velocity driver. Since some of the problems were introduced in
2.6.33-rc1 (with my patches, sorry!), it would be good if they could
get in before the final 2.6.33 release.

The patches are (the third one is the complex one):

  * A small cleanup to remove unused parameters for rx_srv and tx_srv

  * Take the spinlock from set_coalesce

  * Fix races that occur with shared interrupts

We have a system where the interrupt for the VIA card is shared with a
USB controller. The last patch fixes a deadlock situation, which we can
trigger on our UP with spinlock debugging, where the VIA driver is
executing in velocity_poll (the NAPI poll callback) when the USB
controller interrupts the CPU. Since the interrupt controller takes the
(already held) lock, it will deadlock.


Some questions about the implementation though:

The patch uses spin_trylock in the interrupt handler, and returns
IRQ_NONE if it's already held. Here is a place where I'm unsure about
the right way though. Another alternative is to use spin_lock_irqsave
in velocity_poll(), but I'd like to avoid turning the interrupts off
for "long" periods of time when the actual velocity interrupt can't
happen anyway (since it is turned off while executing velocity_poll().

With spin_trylock and spinlock debugging on our UP, we get a bug from
the debugging code:

  BUG: spinlock trylock failure on UP on CPU#0, swapper/0

which looking at the debug code isn't unexpected since spin_trylock is
called from an interrupt handler. In this case though, I don't think
this is an actual error.


We don't have access to any multiprocessor machine with a VIA NIC (I
guess they are not very common), so I haven't been able to test these
patches on actual SMP hardware.

The locking in via-velocity in general would be good to look over, I
think.

// Simon
