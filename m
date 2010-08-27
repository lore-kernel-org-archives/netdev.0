From: Ben Greear <greearb@candelatech.com>
Subject: Re: [net-next 1/2] qdisc: Allow qdiscs to provide backpressure up
 the stack.
Date: Thu, 26 Aug 2010 21:14:39 -0700
Message-ID: <4C773BAF.7010809@candelatech.com>
References: <1282762851-3612-1-git-send-email-greearb@candelatech.com> <20100826.155915.200379485.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:53229 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751328Ab0H0EOm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Aug 2010 00:14:42 -0400
In-Reply-To: <20100826.155915.200379485.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/2010 03:59 PM, David Miller wrote:
> From: Ben Greear<greearb@candelatech.com>
> Date: Wed, 25 Aug 2010 12:00:50 -0700
>
>> Some qdiscs, in some instances, can reliably detect when they
>> are about to drop a packet in the dev_queue_xmit path.  In
>> this case, it would be nice to provide backpressure up the
>> stack, and NOT free the skb in the qdisc logic.
>>
>> Signed-off-by: Ben Greear<greearb@candelatech.com>
>
> I agree with Stephen that, if you're going to do this, it's better to
> just update all of the qdiscs to be able to handle the new semantic
> than to make this special case code path.

Do you mean I should add a try_enqueue method to each one, or make
the existing enqueue method able to return the new error code and fix
up all callers?

> Right now the only configuration where you scheme is going to work is
> one with the default qdisc.  That is way too narrow in scope in my
> opinion.

No argument there, but no use in doing that work until we agree on
an API.

> There is also the issue of what this actually accomplishes.  All I can
> happening is that instead of being limited to the child device's
> backlog limits, you're limited by the combined backlog of two devices.
>
> In reality I don't see this helping much at all.  The most downstream
> device provides the TX queue limiting and that ought to be sufficient.
> In fact, allowing such increase in backlogging is something which might
> be completely unexpected.
>
> If the limit is insufficient in the most downstream device, increase
> it.
>
> If the only remaining problem is pktgen, we can look into changing it
> to operate with more information than just plain NETDEV_TX_BUSY.
>
> Also, there is the issue of waking up the queue.  If you pass back
> NETDEV_TX_BUSY the generic scheduler layer assumes that this means
> that there will absolutely be something which triggers to get the
> queue transmitting again.  Usually that is the hardware queue waking up
> in the device.
>
> But as implemented, you've added no such notifications and therefore I
> think it's possible for the pipline of packets going through these
> layered devices to get wedged and stop forever.
>
> This is why you can't mix and match hardware queue status notifications
> with qdisc software ones.  If you pass NETDEV_TX_BUSY back you better
> have fake queue wakeup notifications to get the send engine going again
> as well.  But I believe we really don't want that.
>
> The only indication we really want to propagate back down to the callers
> is NET_XMIT_CN which, as far as I can tell, does happen correctly right
> now.  If not that's a bug.
>
> You're essentially trying to pass down a hardware queue condition for
> something that is caused by a software queue limit.  And therefore I
> strongly disagree with what these changes are doing.

I'll look into the NET_XMIT_CN, but if that propagates backpressure up
through mac-vlan, then something must know how to re-start the tx logic.
That same logic could be used for my purposes I believe.

One thing that really bothers me about the current qdisc stuff is that
it just frees the packet when it cannot accept it.  I would like to
be able to not delete the packet, similar to how the NET_XMIT_BUSY is
supposed to work.  This *should* allow us to better throttle UDP
sockets without dropping as many packets on the sending side,
and would probably help TCP as well.  And, I know qdiscs cannot
always know at acceptance time if they are going to drop the skb,
but at least some of them *do* know, so I'd like to use that
knowledge when it exists.

As for waking up queues, perhaps we could have some generic framework
for things to register for waking with a netdevice?  Pktgen could
benefit from this by not having to busy-spin on a full network device,
normal queues must already have something similar, and things like
mac-vlans and 802.1q vlans could register themselves as well.

It would be assumed that the bottom level netdevice would have interrupts
or similar to wake it, and then it could propagate recursively to all
things registered to be notified.

I have a patch that even I am embarrassed to post that accomplishes this
wait-queue logic for pktgen, but with a bit of work, it could be
made more generic and publish-able :)

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
