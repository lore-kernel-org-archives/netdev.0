From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: L2 network namespace benchmarking
Date: Wed, 28 Mar 2007 09:55:46 +0200
Message-ID: <460A1F82.9090108@free.fr>
References: <460997C2.4030902@fr.ibm.com> <m1ircmunre.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, Dmitry Mishin <dim@openvz.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([195.212.29.135]:48486 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753220AbXC1Hjv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 03:39:51 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate2.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l2S7do4P037744
	for <netdev@vger.kernel.org>; Wed, 28 Mar 2007 07:39:50 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2S7doLE2748492
	for <netdev@vger.kernel.org>; Wed, 28 Mar 2007 08:39:50 +0100
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2S7dn7A003137
	for <netdev@vger.kernel.org>; Wed, 28 Mar 2007 08:39:49 +0100
In-Reply-To: <m1ircmunre.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Daniel Lezcano <dlezcano@fr.ibm.com> writes:
> 
>> 3. General observations
>> -----------------------
>>
>> The objective to have no performances degrations, when the network
>> namespace is off in the kernel, is reached in both solutions.
>>
>> When the network is used outside the container and the network
>> namespace are compiled in, there is no performance degradations.
>>
>> Eric's patchset allows to move network devices between namespaces and
>> this is clearly a good feature, missing in the Dmitry's patchset. This
>> feature helps us to see that the network namespace code does not add
>> overhead when using directly the physical network device into the
>> container.
> 
> Assuming these results are not contradicted this says that the extra
> dereference where we need it does not add measurable to the overhead
> in the Linus network stack.  Performance wise this should be good
> enough to allow merging the code into the linux kernel, as it does
> not measurably affect networking when we do not have multiple
> containers in use.

I have a few questions about merging code into the linux kernel.

* How do you plan to do that ?
* When do you expect to have the network namespace into mainline ?
* Are Dave Miller and Alexey Kuznetov aware of the network namespace ?
* Did they saw your patchset or ever know it exists ?
* Do you have any feedbacks from netdev about the network namespace ?

> 
> Things are good enough that we can even consider not providing
> an option to compile the support out.
> 
>> The loss of performances is very noticeable inside the container and
>> seems to be directly related to the usage of the pair device and the
>> specific network configuration needed for the container. When the
>> packets are sent by the container, the mac address is for the pair
>> device but the IP address is not owned by the host. That directly
>> implies to have the host to act as a router and the packets to be
>> forwarded. That adds a lot of overhead.
> 
> Well it adds measurable overhead.
> 
>> A hack has been made in the ip_forward function to avoid useless
>> skb_cow when using the pair device/tunnel device and the overhead
>> is reduced by the half.
> 
> To be fully satisfactory how we get the packets to the namespace
> still appears to need work.
> 
> We have overhead in routing.  That may simply be the cost of
> performing routing or there may be some optimizations opportunities
> there.
> We have about the same overhead when performing bridging which I
> actually find more surprising, as the bridging code should involve
> less packet handling.

Yep. I will try to figure out what is happening.

> Ideally we can optimize the bridge code or something equivalent to
> it so that we can take one look at the destination mac address and
> know which network namespace we should be in.  Potentially moving this
> work to hardware when the hardware supports multiple queues.
> 
> If we can get the overhead out of the routing code that would be
> tremendous.  However I think it may be more realistic to get the
> overhead out of the ethernet bridging code where we know we don't need
> to modify the packet.

The routing was optimized for the loopback, no ? Why can't we do the 
same for the etun device ?
