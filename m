From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [ovs-dev] [PATCH net 0/2] vxlan: Set a large MTU on ovs-created
 vxlan devices
Date: Thu, 7 Jan 2016 18:50:18 +0100
Message-ID: <568EA55A.7070305@stressinduktion.org>
References: <1452087186-12926-1-git-send-email-david@weave.works>
 <20160106.155950.1007160228570301281.davem@davemloft.net>
 <8660z6qohn.fsf@weave.works>
 <CAEh+42iWSZOyikNydU2Bs8meqYfrKfUJLDGFJ8HzQ06k64LP0g@mail.gmail.com>
 <568DADEE.1050206@stressinduktion.org>
 <CAEh+42h_dH5-AYBN+L=+LMfNLXhSfs-AwWh_aZ_oLfZ1NV48Zg@mail.gmail.com>
 <20160107114935.GJ32456@pox.localdomain>
 <CAEh+42hA69_e1HRGzsfzc2yGNgr6d8Bg4+pD8EQPdou5LzUegA@mail.gmail.com>
 <20160107172137.GA24672@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Wragg <david@weave.works>,
	David Miller <davem@davemloft.net>, dev@openvswitch.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>, Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:47307 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751534AbcAGRuX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 12:50:23 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 7AD0D21795
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2016 12:50:22 -0500 (EST)
In-Reply-To: <20160107172137.GA24672@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07.01.2016 18:21, Thomas Graf wrote:
> On 01/07/16 at 08:35am, Jesse Gross wrote:
>> On Thu, Jan 7, 2016 at 3:49 AM, Thomas Graf <tgraf@suug.ch> wrote:
>>> A simple start could be to add a new return code for > MTU drops in
>>> the dev_queue_xmit() path and check for NET_XMIT_DROP_MTU in
>>> ovs_vport_send() and emit proper ICMPs.
>>
>> That could be interesting. The problem in the past was making sure
>> that ICMPs that are generated fit in the virtual network appropriately
>> - right addresses, etc. This requires either spoofing addresses or
>> some additional knowledge about the topology that we don't currently
>> have in the kernel.
>
> Are you worried about emitting an ICMP with a source which is not
> a local host address?

We have uRPF enabled for IPv4 by default on all kernels. Thus if we 
generate an IPv4 ICMP packet back with an error message it must have a 
source address which the receiving kernel considers valid. Valid means 
that sending to the source address would have used the same outgoing 
interface the ICMP error came in from.

> Can't we just use icmp_send() in the context of the inner header and
> feed it to the flow table to send it back? It should be the same as
> for ip_forward().

The bridge's ip address often has no valid path as seen from the end 
host system receiving the icmp error, because the openvswitch is not 
really part of the L3 forwarding chain.

Faking the address from the packet (e.g. using the destination address 
of the original packet) will make traceroute go nuts.

> skb->dev or skb->dst should lead us to the real MTU which can be
> included in the ICMP frag needed. It's a bit tricky because we would
> have to know whether it was encapsulated or not and adjust
> accordingly.

Exactly, but this would be the way to go regarding figuring out the 
correct mtu.

Normally ethernet devices don't return icmp error messages. E.g. broken 
jumbo frame configuration just leads to silent packet loss because the 
packet is discarded before a router can handle it. Thus it would be best 
in case of local ovs installation if the error is already transported 
back to the client application via the network call stack. This might be 
very difficult in case we enqueue the packet to a backlog queue and 
reschedule softirqs. Probably we need some way of faking source 
addresses from bridges now.... :/

Bye,
Hannes
