From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH] igmp: make /proc/net/{igmp,mcfilter} per netns
Date: Thu, 11 Sep 2008 19:15:23 +0200
Message-ID: <48C9522B.8080002@fr.ibm.com>
References: <OFAF5F99D2.464B2693-ON882574BE.00630917-882574BE.0064824E@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	containers@lists.linux-foundation.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([195.212.29.139]:43606 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751850AbYIKRRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 13:17:22 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate6.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m8BHFd1w121526
	for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 17:15:39 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8BHFdtf2478122
	for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 18:15:39 +0100
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8BHFc8J012428
	for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 18:15:39 +0100
In-Reply-To: <OFAF5F99D2.464B2693-ON882574BE.00630917-882574BE.0064824E@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Stevens wrote:
> As I've said before, I really don't like the model you're
> using for multicasting here (if I understand correctly, and
> I shamelessly admit I haven't looked at this code in detail).


Hi David,

Sorry for the delay.

> As I understand it, you're modelling the multiple virtual interfaces
> as different pieces of hardware on the same physical network.

Exact. The network namespace acts at the layer 2 level. The network 
resources are isolated and accessed relatively from the namespace 
instead of a global static variable. For example, the network device 
list is per namespace as well as the loopback.

The network devices belong to a specific namespace and can not be used, 
neither seen from another namespace. How the network namespace is able 
to discuss with the outside world will depends on the inter container 
network configuration: a physical device can be assigned to a network 
namespace, or a system with a bridge + a physical network device + one 
side of a pair device (having the other side to the namespace), or a 
macvlan assigned to a namespace, or 'nat' with a pair device, or a 
tunnel, etc ...

> The implication is that apps joining the same group in multiple
> containers will result in multiple advertisements for the same
> group, from each of the multiple instances of IGMP & MLD.
> In IPv4, that's just ineffecient.

I agree.

 > In IPv6, the question is: do you have
> multiple link-local addresses-- one for each virtual device?
> If not, then MLD will be sending multiple copies of everything in
> violation of the spec (since they'll be from the same source, too).

Yes, each virtual device has its own set of network resources, so when 
it is activated in the namespace, the link local address is computed, 
the DAD is invoked and the ip is set on the device.

> I think IGMP and MLD both belong with the physical interface, since
> they pretty much do exactly what you want already: glom all the
> different filters and group memberships together into exactly the
> minimal set of group memberships needed for everyone to hear
> just the pieces they've requested.
> If you do that at the interface, then you won't have any duplicated
> traffic on the physical net and you can separate copies as needed
> for the different virtual nets on the host. Perfect, and indistinguishable
> externally from a non-container machine (and the code to do it is
> already in IGMP and MLD).
> 
> If you treat them as separate physical devices all the way to the
> wire, then you're just needlessly increasing the host processing
> you need to do, as well as loading the multicast routers and network
> that are unfortunate enough to be on the same network as you are.

That makes sense, but the containers can be configured to have a network 
inside the host which acts like a router, a kind of an internal cluster 
in the host, I want to have each container to send an mcast report to 
reproduce the real behaviour of a physical network.

> I haven't been paying attention, so I'll be happy if you tell me you've
> already addressed this. :-) Otherwise, I think it'd be wise to do so
> before it's released into the wild and can't be easily changed.

No, you are right, I didn't addressed that. I thought we stated that was 
an optimization which can be done later.

I don't think having for N containers, N reports for joining / leaving a 
group is something critical at this point, IMHO we can live with that 
for now.

The critical point is : the protocol must not be violated and AFAICS 
this is the case, right ?

Your points are totally valid and I agree 100% with you. But as you can 
see this optimization is not trivial to realize because we have to take 
into account different use cases of the network namespaces and have the 
network stack to behave in a clever way depending on the report to be 
sent internally in the host each time or externally one time.

I will add this optimization to my huge TODO list :) The only question 
is where should I put it, at the beginning or at the end of the list ?
If you think I missed something and there is something wrong with the 
actual approach (expect it can be more efficient) and it is critical for 
the kernel / the protocol, just let me know and I will go to your 
suggestion.


Thanks for your feedback.

   -- Daniel




