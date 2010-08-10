From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 3c59x: fix deadlock when using netconsole with 3c59x
Date: Tue, 10 Aug 2010 16:48:03 -0700 (PDT)
Message-ID: <20100810.164803.13754555.davem@davemloft.net>
References: <20100809163210.GA1781@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39098
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751881Ab0HJXro (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 19:47:44 -0400
In-Reply-To: <20100809163210.GA1781@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon, 9 Aug 2010 12:32:10 -0400

> When using netpoll, its possible to deadlock the 3c59x driver.  Since it takes
> an internal spinlock (vp->lock) that serializes boomerang_interrupt and parts
> of boomerang_start_xmit, if we call pr_debug in the former, we can go through
> the tx path on the same cpu, and recurse into the same driver again, deadlocking
> in the transmit routine.
> 
> This patch fixes that problem by stopping the queues during interrupt
> processing, so that subsequent transmits will get queued until a later point.
> Its not a great solution, but we need to find some way to serialize access to
> the register file on the card without enforcing a deadlock.  I think the queue
> stop is the best way to do that.  And since we only print things in
> boomerang_interrupt when we have debug enabled, we can mitigate the impact of
> this change to only stop the queues when debug is on.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Nothing serialized changes to "vortex_debug" with the tests you're
making here.  Simply turning it off when a packet arrives can deadlock
the send queue of the device.

Even if proper serializatio did exist, I still see this as an awful
solution.

And the default value of this thing is "1" so it's always going to be
doing this send queue state flipping for effectively everyone.

Please find another way to solve this problem.
