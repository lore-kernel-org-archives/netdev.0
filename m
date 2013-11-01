From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next RFC 0/5] xen-netback: TX grant mapping instead
 of copy
Date: Fri, 1 Nov 2013 19:00:07 +0000
Message-ID: <5273FA37.6020903@citrix.com>
References: <1383094220-14775-1-git-send-email-zoltan.kiss@citrix.com> <1383303035.672.29.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1383303035.672.29.camel@kazak.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/11/13 10:50, Ian Campbell wrote:
> Does this always avoid copying when bridging/openvswitching/forwarding
> (e.g. masquerading etc)? For both domU->domU and domU->physical NIC?
I've tested the domU->domU, domU->physical with bridge and openvswitch 
usecase, and now I've created a new stat counter to see how often copy 
happens (the callback's second parameter tells you whether the skb was 
freed or copied). It doesn't do copy in all of these scenarios.
What do you mean by forwarding? The scenario when you use bridge and 
iptables mangling with the packet, not just filtering?

> How does it deal with broadcast traffic?
Most of the real broadcast traffic actually small packets fit in the 
PKT_PROT_LEN sized linear space, so it doesn't make any difference, 
apart from doing a mapping before copy. But that will be eliminated 
later on, I plan to add an incremental improvement to grant copy the 
linear part.
I haven't spent too much time on that, but I couldn't find any broadcast 
protocol which use large enough packets and easy to test, so I'm open to 
ideas.
What I already know, skb_clone trigger a copy, and if the caller use the 
original skb for every cloning, it will do several copy. I think that 
could be fixed by using the first clone to do any further clones.

> Do you have any numbers for the dom0 cpu usage impact?
DomU->NIC: the vif took 40% according to top, I guess the bottleneck 
there is the TLB flushing.
DomU->DomU: the vif of the RX side cause the bottleneck due to grant 
copy to the guest

> Aggregate throughput for many guests would be a useful datapoint too.
I will do measurements about that.

 >> Based on my investigations the packet get only copied if it is 
delivered to
 >>Dom0 stack, which is due to this patch:
 >>https://lkml.org/lkml/2012/7/20/363
 >>That's a bit unfortunate, but as far as I know for the huge majority 
this use
 >>case is not too important.
> Likely to be true, but it would still be interesting to know how badly
> this use case suffers with this change, and any increase in CPU usage
> would be interesting to know about as well.
I can't find my numbers, but as far as I remember it wasn't 
significantly worse than grant copy. I will check that again.

Zoli
