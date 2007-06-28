From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/3] NET: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: Thu, 28 Jun 2007 21:17:21 +0200
Message-ID: <46840941.5040407@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC329031F0614@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, hadi@cyberus.ca
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57687 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763995AbXF1TSU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2007 15:18:20 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC329031F0614@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Waskiewicz Jr, Peter P wrote:
>>PJ Waskiewicz wrote:
>>
>>>+#ifdef CONFIG_NET_SCH_MULTIQUEUE
>>>+			if (q->mq)
>>>+				skb->queue_mapping = 
>>>+						
>>
>>q->prio2band[band&TC_PRIO_MAX];
>>
>>>+			else
>>>+				skb->queue_mapping = 0;
>>>+#endif
>>
>>
>>Setting it to zero here is wrong, consider:
>>
>>root qdisc: prio multiqueue
>>child qdisc: prio non-multiqueue
>>
>>The top-level qdisc will set it, the child qdisc will unset it again.
>>When multiqueue is inactive it should not touch it.
>>
>>I'll fix that as well.
> 
> 
> But the child can't assume the device is multiqueue if the child is
> non-multiqueue.

The child doesn't have to assume anything.

> This is the same issue with IP forwarding, where if you
> forward through a multiqueue device to a non-mq device, you don't know
> if the destination device is multiqueue.

No its not. I'm talking about nested qdiscs, which are all on
a single device.

> So the last qdisc to actually
> dequeue into a device should have control what the queue mapping is.


Fully agreed. And that is always the top-level qdisc.

> If
> a user had a multiqueue qdisc as root, and configured a child qdisc as
> non-mq, that is a configuration error if the underlying device is indeed
> multiqueue IMO.


Absolutely not. First of all, its perfectly valid to use non-multiqueue
qdiscs on multiqueue devices. Secondly, its only the root qdisc that
has to know about multiqueue since that one controls the child qdiscs.

Think about it, it makes absolutely no sense to have the child
qdisc even know about multiqueue. Changing my example to have
a multiqueue qdisc as child:

root qdisc: 2 band prio multiqueue
child qdisc of band 0: 2 band prio multiqueue

When the root qdisc decides to dequeue band0, it checks whether subqueue
0 is active and dequeues the child qdisc. If the child qdisc is indeed
another multiqueue qdisc as you suggest, if might decide to dequeue its
own band 1 and checks that subqueue state. So where should the packet
finally end up? And what if one of both subqueues is inactive?

The only reasonable thing it can do is not care about multiqueue and
just dequeue as usual. In fact I think it should be an error to
configure multiqueue on a non-root qdisc.
