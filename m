From: James Yonan <james@openvpn.net>
Subject: Re: GSO/GRO and UDP performance
Date: Fri, 06 Sep 2013 03:22:37 -0600
Message-ID: <52299EDD.1030208@openvpn.net>
References: <52270659.1090208@openvpn.net> <1378295631.7360.98.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from magnetar.openvpn.net ([74.52.27.18]:41797 "EHLO
	magnetar.openvpn.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750862Ab3IFJWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 05:22:39 -0400
In-Reply-To: <1378295631.7360.98.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/09/2013 05:53, Eric Dumazet wrote:
> On Wed, 2013-09-04 at 04:07 -0600, James Yonan wrote:
>
>> The bundle of UDP packets would traverse the stack as a unit until it
>> reaches the socket layer, where recvmmsg could pass the whole bundle up
>> to userspace in a single transaction (or recvmsg could disaggregate the
>> bundle and pass each datagram individually).
>
> That would require a lot of work, say in netfilter, but also in core
> network stack in forwarding, and all UDP users (L2TP, vxlan).
>
> Very unlikely to happen IMHO.

I agree that aggregating packets by chaining multiple packets into a 
single skb would be too disruptive.

However I believe GSO/GRO provides a potential solution here that would 
be transparent to the core network stack and existing in-kernel UDP users.

GSO/GRO already allows any L4 protocol or lower to define their own 
segmentation and aggregation algorithms, as long as the algorithms are 
lossless.

There's no reason why GSO/GRO couldn't operate on L5 or higher protocols 
if segmentation and aggregation algorithms are provided by a kernel 
module that understands the specific app protocol.

It looks like this could be done with minimal changes to the GSO/GRO 
core.  There would need to be a hook where a kernel module could 
register itself as a GSO/GRO provider for UDP.  It could then perform 
segmentation/aggregation on UDP packets that belong to it.  The dispatch 
to the UDP GSO/GRO providers would be done by the existing offload code 
for UDP, so there would be zero added overhead for non-UDP protocols.

>
> I suspect the performance is coming from aggregation done in user space,
> then re-injected into the kernel ?
>
> You could use a kernel module, using udp_encap_enable() and friends.
>
> Check vxlan_socket_create() for an example

I actually put together a test kernel module using udp_encap_enable to 
see if I could accelerate UDP performance that way.  But even with the 
boost of running in kernel space, the packet processing overhead of 
dealing with 1500 byte packets negates most of the gain, while TCP gets 
a 43x performance boost by being able to aggregate up to 64KB per 
superpacket with GSO/GRO.

So I think that playing well with GSO/GRO is essential to get speedup in 
UDP apps because of this 43x multiplier.

James
