From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [patch 1/3] net: serialize hrtimer callback in sched_cbq
Date: Tue, 14 Jul 2009 10:30:59 +0200
Message-ID: <1247560259.7500.46.camel@twins>
References: <20090709215455.703939259@linutronix.de>
	 <20090709215606.526259917@linutronix.de>
	 <20090712.135555.207096388.davem@davemloft.net>
	 <4A5C402A.7090906@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, tglx@linutronix.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:59959 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750768AbZGNIbD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2009 04:31:03 -0400
In-Reply-To: <4A5C402A.7090906@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-07-14 at 10:22 +0200, Patrick McHardy wrote:
> 
> That's my understanding what HRTIMER_SOFTIRQ is used for. I think
> simply grabbing the root lock in cbq_undelay() should be fine.

Its not, and its going away soon (again) :-)

The current use of HRTIMER_SOFTIRQ is for when we enqueue a hrtimer with
an expiration time in the past. The current implementation tries to run
the timer instantly, however we cannot do it from the context calling
hrtimer_start(), since that might be holding locks the timer callback
also wants to hold, resulting in deadlocks.

Instead we queue the timer to the softirq, and kick the softirq. Which
leads to another problem in that we cannot always kick the softirq (esp
from within the scheduler).

We're going to change hrtimer_start() to return -ETIME instead of trying
to run the timer in-place, leaving the callers to figure it out.

The basic patch is done, but I still need to audit all the hrtimer users
in the kernel.


