From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 03/10] ixgbe: Drop the TX work limit and instead
 just leave it to budget
Date: Mon, 22 Aug 2011 13:56:44 -0700 (PDT)
Message-ID: <20110822.135644.683110224886588181.davem@davemloft.net>
References: <4E528437.5060302@intel.com>
	<1314031612.2803.7.camel@bwh-desktop>
	<4E52920F.7060603@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48245 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751086Ab1HVU4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 16:56:47 -0400
In-Reply-To: <4E52920F.7060603@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Mon, 22 Aug 2011 10:29:51 -0700

> The only problem I was seeing with that was that in certain cases it
> seemed like the TX cleanup could consume enough CPU time to cause
> pretty significant delays in processing the RX cleanup.  This in turn
> was causing single queue bi-directional routing tests to come out
> pretty unbalanced since what seemed to happen is that one CPUs RX work
> would overwhelm the other CPU with the TX processing resulting in an
> unbalanced flow that was something like a 60/40 split between the
> upstream and downstream throughput.

But the problem is that now you're applying the budget to two operations
that have much differing costs.  Freeing up a TX ring packet is probably
on the order of 1/10th the cost of processing an incoming RX ring frame.

I've advocated to not apply the budget at all to TX ring processing.

I can see your delimma with respect to RX ring processing being delayed,
but if that's really happening you can consider whether the TX ring is
simply too large.

In any event can you try something like dampening the cost applied to
budget for TX work (1/2, 1/4, etc.)?  Because as far as I can tell, if
you are really hitting the budget limit on TX then you won't be doing
any RX work on that device until a future NAPI round that depletes the
TX ring work without going over the budget.
