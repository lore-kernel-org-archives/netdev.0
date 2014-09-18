From: Raghuram Kothakota <Raghuram.Kothakota@oracle.com>
Subject: Re: [PATCHv6 net-next 1/3] sunvnet: upgrade to VIO protocol version 1.6
Date: Thu, 18 Sep 2014 11:49:06 -0700
Message-ID: <9BA1705F-0C89-471A-9872-688A3FA3165C@oracle.com>
References: <541A2316.5010603@oracle.com> <2AB76E42-C12D-47C5-8476-0D0C611691A5@oracle.com> <541AD838.50700@oracle.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David L Stevens <david.stevens@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:45720 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751099AbaIRStO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 14:49:14 -0400
In-Reply-To: <541AD838.50700@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sep 18, 2014, at 6:03 AM, David L Stevens <david.stevens@oracle.com> wrote:

> 
> 
> On 09/18/2014 12:09 AM, Raghuram Kothakota wrote:
> 
>>> @@ -1048,8 +1116,8 @@ static int vnet_port_alloc_tx_bufs(struct vnet_port *port)
>>> 	void *dring;
>>> 
>>> 	for (i = 0; i < VNET_TX_RING_SIZE; i++) {
>>> -		void *buf = kzalloc(ETH_FRAME_LEN + 8, GFP_KERNEL);
>>> -		int map_len = (ETH_FRAME_LEN + 7) & ~7;
>>> +		void *buf = kzalloc(VNET_MAXPACKET + 8, GFP_KERNEL);
>> 
>> 
>> This patch doesn't change the VNET_MAXPACKET to 64k, but the patch 2/3 changes
>> it to 64k+. Allocating buffers of size VNET_MAXPACKET always can consume too much
>> memory for every port/LDC, that would be more than 32MB.  You may want to allocate
>> buffers based on the mtu that is negotiated, so that this memory used only when
>> such large packets are accepted by the peer.
> 
> I originally had code to dynamically allocate them after the MTU negotiation, but
> that opens up a can of worms regarding stopping and freeing an active ring. I don't
> believe the shutdown code addresses this adequately, either, and I think this is
> worth addressing, but separately.
> 

I am probably not as knowledgeable of sunvnet as you may be, but I would assume
the code is capable of handling the a vport removal and should have sufficient method
cleanup as well. 

> I convinced myself to do it this way because:
> a) memory is cheap

In the virtualization world, we want resources to be efficiently used and memory is
still very important resource. My concern is mostly because this memory usage of
32+MB is on a per LDC basis. LDoms today supports a max of 128 domains, but
from my experience seen actual deployments of the order of 50 domains. This is
going up as the platforms getting more and more powerful.  If there are really
that many peers,  then the amount of memory consumed by one vnet instance
is 50 * 32+MB = 1.6GB+.  It's fine if this memory is really used, but it seems like this
will be useful only when the peer is another linux guest with this version of vnet and
also the MTU is configured to use 64K.  The memory is being wasted for all other
peers that either don't support 64K MTU or not configured to use it and also 
the switch port as obviously it doesn't support 64K MTU today.

Note, it's just buffer space that is being consumed here, it is also the LDC shared
memory space. Luckily the SHADOW_MAPPED shared memory space has
very less limitations otherwise it can cause other impact to other virtual devices.


> b) I think most people will want to use large MTUs for performance; enough so
> 	that perhaps the bring-up MTU should be 64K too


>From my experience in SPARC world, most customers pushed us back for any
proposal to use Jumbo Frames. The customers who configured Jumbo frames,
mostly used 9K for performance of NFS etc.

> c) future (actually current) TSO/GSO work will want large buffers even if the MTU
> 	is not changed
> 

When we implemented TSO support, we evaluated the cost of the buffers vs
performance. We were able to limit TSO support to 8K(actually bit less) and still
achieve high performance, for example we are able to drive line rate on a 10G
and guest-to-guest of the order of 45+Gbps. So, my suggestion would be to
increase the parallelism of the code more than depending on large MTU.

> So, if this is actually too much memory, I was more inclined to reduce the ring
> size rather than either add complicating code to handle active-ring reallocation
> that would typically be run once per boot, or another alternative of adding
> module parameters to specify the buffer size TSO/GSO will need 64K to perform
> well, regardless of the device MTU.
> 

Note, my experience shows that reducing ring size can have larger impact on the
standard MTU case. I would assume the sunvnet code to be dynamic in any case
to deal with ports being added and removed and ports going down and up and
this is just one aspect of those operations.

-Raghuram

> 							+-DLS
