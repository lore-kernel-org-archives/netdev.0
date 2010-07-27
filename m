From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Tx queue selection
Date: Tue, 27 Jul 2010 20:31:52 +0100
Message-ID: <1280259112.2132.43.camel@achroite.uk.solarflarecom.com>
References: <1280227867.1970.208.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:12445 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751017Ab0G0Tb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 15:31:56 -0400
In-Reply-To: <1280227867.1970.208.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-07-27 at 20:51 +1000, Benjamin Herrenschmidt wrote:
> Hi folks !
> 
> I'm putting my newbie hat on ... :-)
> 
> While looking at our ehea driver (and in fact another upcoming driver
> I'm helping with), I noticed it's using the "old style" multiqueue. IE.
> It doesn't use the alloc_netdev_mq() variant, creates one queue on the
> linux side, an makes its own selection of HW queue in start_xmit.
> 
> This had many drawbacks, obviously, such as not getting per-queue locks
> etc...
> 
> Now, the mechanics of converting that to the new scheme are easy enough
> to figure out by reading the code. However, where my lack of networking
> background fails me is when it comes to the policy of choosing a Tx
> queue.
> 
> ehea uses its own hash of the header, different from the "default" queue
> selection in the net core. Looking at other drivers such as ixgbe, I see
> that it can chose to use smp_processor_id() when a flag is set for which
> I don't totally understand the meaning or default to the core algorithm.
>
> Now, while I can understand why it's a good idea to use the current
> processor, in order to limit cache ping pong etc... I'm not really
> confident I understand the pro/cons of using the hashing for tx. I
> understand that the net core can play interesting games with associating
> sockets with queues etc... but I'm a bit at a loss when it comes to
> deciding what's best for this driver. I suppose I could start by
> implementing my own queue selection based on what ehea does today but I
> have the nasty feeling that's going to be sub-optimal :-)
>
> So I would very much appreciate (and reward with free beer at the next
> conference) if somebody could give me a bit of a heads up on how things
> are expected to be done there, pro/cons, perf impact etc...

In the past Dave has recommended against implementing
ndo_select_queue().

When forwarding between multiqueue interfaces, we expect the input
device to spread traffic out between RX queues and we then use the
corresponding TX queue on output (assuming equal numbers of queues on
interfaces).  Thus we should easily avoid contention on TX queues.

For endpoints, the situation is more complex.  Ideally we would have one
IRQ, one RX queue and one TX queue per processor; we would let each
processor send on its own TX queue and NICs would automatically steer RX
packets to the RX queue for wherever the receiving thread will be
scheduled.  In practice the NIC doesn't know that and even if it does we
can easily introduce reordering.  This also depends on the driver being
able to control affinity of its IRQs.

ixgbe, in conjunction with the firmware 'Flow Director' feature attempts
to implement this, using the last TX queue for the flow as an indicator
of which RX queue to use, but so far as I can see it punts on the
reordering issue.  It sets affinity 'hints' and apparently requires that
irqbalance follows these.

Another approach is to assume that when a receiving thread is regularly
woken up by packet reception on a given CPU then it will tend to be
scheduled and to transmit on the same flow from that CPU.  On that basis
we should set the TX queue for a connected socket to match the RX queue
it last received on.  (See
<http://article.gmane.org/gmane.linux.network/158477>.)  It's not clear
whether this is really true.

Receive Flow Steering implements the steering entirely in software, but
AFAIK does nothing for the TX side; it seems mostly targetted at
single-queue NICs.

I will shortly be proposing some changes that I hope will allow at least
some multiqueue NIC drivers to move closer to that ideal.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

