From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 03/10] ixgbe: Drop the TX work limit and instead
 just leave it to budget
Date: Mon, 22 Aug 2011 16:40:27 -0700 (PDT)
Message-ID: <20110822.164027.1830363266993513959.davem@davemloft.net>
References: <4E52920F.7060603@intel.com>
	<20110822.135644.683110224886588181.davem@davemloft.net>
	<4E52DEEF.40504@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56518 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751589Ab1HVXkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 19:40:43 -0400
In-Reply-To: <4E52DEEF.40504@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Mon, 22 Aug 2011 15:57:51 -0700

> The problem was occurring even without large rings.
> I was seeing issues with rings just 256 descriptors in size.

And the default in the ixgbe driver is 512 entries which I think
itself is quite excessive.  Something like 128 is more in line with
what I'd call a sane default.

So the only side effect of your change is to decrease the TX quota to
64 (the default NAPI quota) from it's current value of 512
(IXGBE_DEFAULT_TXD).

Talking about the existing code, I can't even see how the current
driver private TX quota can trigger except in the most extreme cases.
This is because the quota is set the same as the size you're setting
the TX ring to.

> The problem seemed to be that the TX cleanup being a multiple of
> budget was allowing one CPU to overwhelm the other and the fact that
> the TX was essentially unbounded was just allowing the issue to
> feedback on itself.

I still don't understand what issue you could even be running into.

On each CPU we round robin against all NAPI requestors for that CPU.

In your routing test setup, we should have one cpu doing the RX and
another different cpu doing TX.

Therefore if the TX cpu simply spins in a loop doing nothing but TX
reclaim work it should not really matter.

And if you hit the TX budget on the TX cpu, it's just going to come
right back into the ixgbe NAPI handler and thus the TX reclaim
processing not even a dozen cycles later.

The only effect is to have us go through the whole function call
sequence and data structure setup into local variables more than you
would be doing so before.

> In addition since the RX and TX workload was balanced it kept both
> locked into polling while the CPU was saturated instead of allowing
> the TX to become interrupt driven.  In addition since the TX was
> working on the same budget as the RX the number of SKBs freed up in
> the TX path would match the number consumed when being reallocated
> on the RX path.

So the only conclusion I can come to is that what happens is we're now
executing what are essentially wasted cpu cycles and this takes us
over the threshold such that we poll more and take interrupts less.
And this improves performance.

That's pretty unwise if you ask me, we should do something useful with
cpu cycles instead of wasting them merely to make us poll more.

> The problem seemed to be present as long as I allowed the TX budget to
> be a multiple of the RX budget.  The easiest way to keep things
> balanced and avoid allowing the TX from one CPU to overwhelm the RX on
> another was just to keep the budgets equal.

You're executing 10 or 20 cpu cycles after every 64 TX reclaims,
that's the only effect of these changes.  That's not even long enough
for a cache line to transfer between two cpus.
