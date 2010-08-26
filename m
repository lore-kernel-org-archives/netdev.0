From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 1/2] qdisc: Allow qdiscs to provide backpressure up
 the stack.
Date: Thu, 26 Aug 2010 15:59:15 -0700 (PDT)
Message-ID: <20100826.155915.200379485.davem@davemloft.net>
References: <1282762851-3612-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36862
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754609Ab0HZW67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 18:58:59 -0400
In-Reply-To: <1282762851-3612-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Wed, 25 Aug 2010 12:00:50 -0700

> Some qdiscs, in some instances, can reliably detect when they
> are about to drop a packet in the dev_queue_xmit path.  In
> this case, it would be nice to provide backpressure up the
> stack, and NOT free the skb in the qdisc logic.
> 
> Signed-off-by: Ben Greear <greearb@candelatech.com>

I agree with Stephen that, if you're going to do this, it's better to
just update all of the qdiscs to be able to handle the new semantic
than to make this special case code path.

Right now the only configuration where you scheme is going to work is
one with the default qdisc.  That is way too narrow in scope in my
opinion.

There is also the issue of what this actually accomplishes.  All I can
happening is that instead of being limited to the child device's
backlog limits, you're limited by the combined backlog of two devices.

In reality I don't see this helping much at all.  The most downstream
device provides the TX queue limiting and that ought to be sufficient.
In fact, allowing such increase in backlogging is something which might
be completely unexpected.

If the limit is insufficient in the most downstream device, increase
it.

If the only remaining problem is pktgen, we can look into changing it
to operate with more information than just plain NETDEV_TX_BUSY.

Also, there is the issue of waking up the queue.  If you pass back
NETDEV_TX_BUSY the generic scheduler layer assumes that this means
that there will absolutely be something which triggers to get the
queue transmitting again.  Usually that is the hardware queue waking up
in the device.

But as implemented, you've added no such notifications and therefore I
think it's possible for the pipline of packets going through these
layered devices to get wedged and stop forever.

This is why you can't mix and match hardware queue status notifications
with qdisc software ones.  If you pass NETDEV_TX_BUSY back you better
have fake queue wakeup notifications to get the send engine going again
as well.  But I believe we really don't want that.

The only indication we really want to propagate back down to the callers
is NET_XMIT_CN which, as far as I can tell, does happen correctly right
now.  If not that's a bug.

You're essentially trying to pass down a hardware queue condition for
something that is caused by a software queue limit.  And therefore I
strongly disagree with what these changes are doing.

