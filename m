From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] 3c59x: fix deadlock when using netconsole with 3c59x
Date: Tue, 10 Aug 2010 21:16:42 -0400
Message-ID: <20100811011642.GA2060@localhost.localdomain>
References: <20100809163210.GA1781@hmsreliant.think-freely.org>
 <20100810.164803.13754555.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:47381 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753282Ab0HKBQt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 21:16:49 -0400
Content-Disposition: inline
In-Reply-To: <20100810.164803.13754555.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 10, 2010 at 04:48:03PM -0700, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Mon, 9 Aug 2010 12:32:10 -0400
> 
> > When using netpoll, its possible to deadlock the 3c59x driver.  Since it takes
> > an internal spinlock (vp->lock) that serializes boomerang_interrupt and parts
> > of boomerang_start_xmit, if we call pr_debug in the former, we can go through
> > the tx path on the same cpu, and recurse into the same driver again, deadlocking
> > in the transmit routine.
> > 
> > This patch fixes that problem by stopping the queues during interrupt
> > processing, so that subsequent transmits will get queued until a later point.
> > Its not a great solution, but we need to find some way to serialize access to
> > the register file on the card without enforcing a deadlock.  I think the queue
> > stop is the best way to do that.  And since we only print things in
> > boomerang_interrupt when we have debug enabled, we can mitigate the impact of
> > this change to only stop the queues when debug is on.
> > 
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> 
> Nothing serialized changes to "vortex_debug" with the tests you're
> making here.  Simply turning it off when a packet arrives can deadlock
> the send queue of the device.
> 
> Even if proper serializatio did exist, I still see this as an awful
> solution.
> 
> And the default value of this thing is "1" so it's always going to be
> doing this send queue state flipping for effectively everyone.
> 
> Please find another way to solve this problem.
> 

Crap-spackle, you're right.  I was thinking the module_param defaulted it to
zero, but it doesn't.  Regardless, sysfs would let us change this value and
deadlock it all to heck.

Recinded.  I'll find a better way to fix this.  Sorry for the noise
Neil

