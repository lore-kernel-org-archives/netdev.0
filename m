From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [net-next 0/16] Proposal for VRF-lite - v3
Date: Tue, 28 Jul 2015 12:07:15 -0500
Message-ID: <87d1zcp5x8.fsf@x220.int.ebiederm.org>
References: <1438021869-49186-1-git-send-email-dsa@cumulusnetworks.com>
	<87egjtz6kn.fsf@x220.int.ebiederm.org>
	<55B7A779.6040906@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	jtoppins@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	ddutt@cumulusnetworks.com, hannes@stressinduktion.org,
	nicolas.dichtel@6wind.com, stephen@networkplumber.org,
	hadi@mojatatu.com, davem@davemloft.net, svaidya@brocade.com,
	mingo@kernel.org, luto@amacapital.net
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:60028 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752650AbbG1RNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 13:13:53 -0400
In-Reply-To: <55B7A779.6040906@cumulusnetworks.com> (David Ahern's message of
	"Tue, 28 Jul 2015 10:02:01 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Ahern <dsa@cumulusnetworks.com> writes:

> On 7/27/15 2:30 PM, Eric W. Biederman wrote:
>> This paragraph is false when it comes to sockets, as I have already
>> pointed out.
>>
>> - VPN Routing and Forwarding (RFC4364 and it's kin) implies isolation
>>    strong enough to allow using the the same ip on different machines
>>    in different VPN instances and not have confusion.
>>
>> - The routing table is not the only table in the kernel that uses
>>    an ip address as a key.
>>
>>    The result is that you can combine packets fragments that come in
>>    on different interfaces (irrespective of your VPN), confuse tcp
>>    parameters between interfaces, scramble your ipsec connections and I
>>    don't know what else.
>
> The duplicate IP address is a problem with the networking stack today; the VRF
> device does not introduce it. The VRF device does allow duplicate IP addresses
> within a namespace but separate VRFs, though yes various places that rely solely
> on source address like IP fragmentation do need to be fixed.

No. The same IP address being used by different machines is not a
problem with the IP stack today.  IP addresses are defined to be
globally unique.

At the point you introduce VPNs/VRFs you introduce duplicate IP
addresses and then the code needs to cope.

As such I think there is a deep mismatch between the semantics of
BINDTODEVICE and VRFs because BINDTODEVICE by definition does not worry
about duplicate IP addresses.

Which means that you can't just reuse the BINDTODEVICE infrastructure.
It is fundamentally insufficient to the task.  So as you are discovering
you have to invent something new.

That new thing needs a definition.  Maybe the new thing makes sense and
you can just slice off a chunk of a network namespace.  Maybe you go
through and change all of the code.

> I looked at the IPv4 fragmentation code yesterday and will continue today. So
> help me with the history: is there any reason why the device index is not used
> today? It seems like a straight forward change.

Sigh.  I would have hoped someone dealing with routing issues would have
seen this at a glance.  The reason is multi-path reception of fragments.

Adding the device index into the fragment reassembly logic would break
fragment reassembly when fragments of the same packet come into a
machine on different network devices.  Given that only the first
fragment has port numbers I can easily see network path selection code
hashing fragments onto different paths through the network.

> Is there a use case where I can't add ifindex of the incoming device (or higher
> level device if skb->dev is changed) to the hash and lookup for
> fragments?

As detailed above.  That breaks fragment reassembly on multiple paths.

>>> Version 3
>>> - addressed comments from first 2 RFCs with the exception of the name
>>>    Nicolas: We will do the name conversion once we agree on what the
>>>             correct name should be (vrf, mrf or something else)
>>
>> Not so.  I described the deep problems between your goals and your
>> implementation and they are not even mentioned let alone addressed.
>
> I have addressed comments to the extent that I can. As I stated in my last
> followup to you Eric I did not understand your point. I asked for clarification,
> a --verbose if you will. I can't read your mind, so I need you to elaborate on
> your points to be able to respond and address your concerns.

Hopefully this helps.

Everything we are talking about follows from what I said at the outset.
You are introducing the idea of having the same ip address refer to
different network destinations depending upon context.  Outside of
network namespaces that concept is new and it breaks a lot of
assumptions.

The entire network stack is too large to fit in my head.  I don't know
every place where ip addresses are used as part of the index into a
table.  It is beholden on the implementor of a new feature to figure out
how to introduce such a concept safely.  I don't see that happening with
VRF-lite.

Pretty fundamentally a network device index is insufficient for your needs.

>>> -  packets flow through the VRF device in both directions allowing the
>>>     following:
>>>     - tcpdump -i vrf<n>
>>>     - tc rules on vrf device
>>>     - netfilter rules on vrf device
>>>
>>> Ingo/Andy: I added you two as a start point for the proposed task related
>>>             changes. Not sure who should be the reviewer; please let me know
>>>             if someone else is more appropriate. Thanks.
>>
>> It looks like you are trying to implement a namespace that isn't a
>> namespace.  Given that it is broken by design you have my nack.
>
> This is an L3 separation within a namespace, not a device level separation which
> is what namespaces provide.

Not my meaning.  I was not talking about network namespaces and how your
vrf is almost but not completely the same as a network namespace.

What I was talking about is that you are implementing something that is
used roughly the same way as the other namespaces pid, mount, ipc, net,
uts, etc.  As the poor excuse for an overall maintainer of namespaces
I am one of, if not the person, you need to talk to, to add something to
the task struct.

Until you sort out your semantics and have something that doesn't look
like it will break users with every maintenance patch.  I am saying no.
You don't have something that is currently appropriate to add to task
struct.

Eric
