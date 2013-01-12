From: David Miller <davem@davemloft.net>
Subject: Re: [RFC davem] revert: net: Make skb->skb_iif always track
 skb->dev
Date: Sat, 12 Jan 2013 13:36:30 -0800 (PST)
Message-ID: <20130112.133630.257139657732337147.davem@davemloft.net>
References: <50F1699E.1000200@hartkopp.net>
	<20130112.132316.2121287993605534669.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60708 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754148Ab3ALVgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 16:36:31 -0500
In-Reply-To: <20130112.132316.2121287993605534669.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Sat, 12 Jan 2013 13:23:16 -0800 (PST)

> From: Oliver Hartkopp <socketcan@hartkopp.net>
> Date: Sat, 12 Jan 2013 14:48:14 +0100
> 
>> To me it is not clear why skb_iff is needed anyway as the value should
>> always be available via skb->dev->ifindex, right?
> 
> But all the code uses skb_iif, in particular the ipv4 routing
> lookups use that as the key.
> 
> It absolutely must follow whatever is skb->dev, it is a hard
> invariant.
> 
> I am not reverting this change.

More information, because I can't believe how idiotic and
ignorant people are being able this issue.

skb->dev->ifindex IS NOT the same as skb->skb_iif

Why don't you put a test into tcp_recvmsg() for packets being removed
from the socket's receive queue and see if skb->dev->ifindex is the
same as skb->skb_iif

Surprise, skb->dev is going to be NULL at that point.

Why?

Because on packet receive we don't take references on devices we hook
into skb->dev, therefore we cannot let that pointer escape the
software interrupt packet input paths.

Therefore, as a bug trap, TCP input will set skb->dev to NULL.

The only valid way to figure out the final demuxed device the packet
arrived on, is therefore, via skb->skb_iif.

As per your problem with CAN, that's also rediculous.  You have an SKB
control block in skb->cb[] that you can put whatever values with
whatever semantics you want.

Use it.

I'm not discussing this any further.
