From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [flamebait] xdp, well meaning but pointless
Date: Thu, 1 Dec 2016 21:44:33 +0100
Message-ID: <583b8947-3395-8529-933b-08e1a86a0778@stressinduktion.org>
References: <20161201091108.GF26507@breakpoint.cc>
 <20161201145834.GA569@pox.localdomain>
 <7e2be2fc-7c04-b333-59c7-43d4fcfcb451@stressinduktion.org>
 <20161201162814.GA31300@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:54050 "EHLO
        out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751198AbcLAUog (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 15:44:36 -0500
In-Reply-To: <20161201162814.GA31300@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

this is a good conversation and I simply want to bring my worries
across. I don't have good solutions for the problems XDP tries to solve
but I fear we could get caught up in maintenance problems in the long
term given the ideas floating around on how to evolve XDP currently.

On 01.12.2016 17:28, Thomas Graf wrote:
> On 12/01/16 at 04:52pm, Hannes Frederic Sowa wrote:
>> First of all, this is a rant targeted at XDP and not at eBPF as a whole.
>> XDP manipulates packets at free will and thus all security guarantees
>> are off as well as in any user space solution.
>>
>> Secondly user space provides policy, acl, more controlled memory
>> protection, restartability and better debugability. If I had multi
>> tenant workloads I would definitely put more complex "business/acl"
>> logic into user space, so I can make use of LSM and other features to
>> especially prevent a network facing service to attack the tenants. If
>> stuff gets put into the kernel you run user controlled code in the
>> kernel exposing a much bigger attack vector.
>>
>> What use case do you see in XDP specifically e.g. for container networking?
> 
> DDOS mitigation to protect distributed applications in large clusters.
> Relying on CDN works to protect API gateways and frontends (as long as
> they don't throw you out of their network) but offers no protection
> beyond that, e.g. a noisy/hostile neighbour. Doing this at the server
> level and allowing the mitigation capability to scale up with the number
> of servers is natural and cheap.

So far we e.g. always considered L2 attacks a problem of the network
admin to correctly protect the environment. Are you talking about
protecting the L3 data plane? Are there custom proprietary protocols in
place which need custom protocol parsers that need involvement of the
kernel before it could verify the packet?

In the past we tried to protect the L3 data plane as good as we can in
Linux to allow the plain old server admin to set an IP address on an
interface and install whatever software in user space. We try not only
to protect it but also try to achieve fairness by adding a lot of
counters everywhere. Are protections missing right now or are we talking
about better performance?

To provide fairness you often have to share validated data within the
kernel and with XDP. This requires consistent lookup methods for sockets
in the lower level. Those can be exported to XDP via external functions
and become part of uAPI which will limit our ability to change those
functions in future. When the discussion started about early demuxing in
XDP I became really nervous, because suddenly the XDP program has to
decide correctly which protocol type it has and look in the correct
socket table for the socket. Different semantics for sockets can apply
here, e.g. some sockets are RCU managed, some end up using reference
counts. A wrong decision here would cause havoc in the kernel (XDP
considers packet as UDP but kernel stack as TCP). Also, who knows that
we won't have per-cpu socket tables we would keep that as uAPI (this is
btw. the dragonflyBSD approach to scaling)? Imagine someone writing a
SIP rewriter in XDP and depending on a coherent view of all sockets even
if their hash doesn't fit to the one of the queue? Suddenly something
which was thought of as being only mutable by one CPU becomes global
again and because of XDP we need to add locking because of uAPI.

This discussion is parallel to the discussion about trace points, which
are not considered uAPI. If eBPF functions are not considered uAPI then
eBPF in the network stack will have much less value, because you
suddenly depend on specific kernel versions again and cannot simply load
the code into the kernel. The API checks will become very difficult to
implement, see also the ongoing MODVERSIONS discussions on LKML some
days back.

>>> I agree with you if the LB is a software based appliance in either a
>>> dedicated VM or on dedicated baremetal.
>>>
>>> The reality is turning out to be different in many cases though, LB
>>> needs to be performed not only for north south but east west as well.
>>> So even if I would handle LB for traffic entering my datacenter in user
>>> space, I will need the same LB for packets from my applications and
>>> I definitely don't want to move all of that into user space.
>>
>> The open question to me is why is programmability needed here.
>>
>> Look at the discussion about ECMP and consistent hashing. It is not very
>> easy to actually write this code correctly. Why can't we just put C code
>> into the kernel that implements this once and for all and let user space
>> update the policies?
> 
> Whatever LB logic is put in place with native C code now is unlikely the
> logic we need in two years. We can't really predict the future. If it
> was the case, networking would have been done long ago and we would all
> be working on self eating ice cream now.

Did LB algorithms on the networking layer change that much?

There is a long history of using consistent hashing for load balancing,
as e.g. is done in haproxy or F5.

>> Load balancers have to deal correctly with ICMP packets, e.g. they even
>> have to be duplicated to every ECMP route. This seems to be problematic
>> to do in eBPF programs due to looping constructs so you end up with
>> complicated user space anyway.
> 
> Feel free to implement such complex LBs in user space or natively. It is
> not required for the majority of use cases. The most popular LBs for
> application load balancing have no idea of ECMP and require ECMP aware
> routers to be made redundant itself.

They are already available and e.g. deployed as part of some kubernetes
stacks as I wrote above.

It is a generally available algorithm which fits a lot of use cases,
basically every website that wants to shard its sessions can make use of
it. Also it is independent of ECMP and mostly is implemented in load
balancers due to its need for a lot of memory.

New algorithms outdate old ones but the core principles will be the same
and don't require major changes to the interface, e.g. ipvs scheduler.

If we are talking about security features for early drop inside TCP
streams, like http, you need to have a proper stream reassembly engine.
Snort e.g. dropped a complete stream of TCP packets if you send a RST
with the same quadruple but a wrong sequence number. End system didn't
consider the RST but non synchronized solutions ended up not inspecting
this flow anymore. How do you handle diverting views on meta data in
networking protocols? Also look how hard it is to keep e.g. the fib
table synchronized to the hardware.

In retrospect, I think Tom Herbert's move putting ILA stateless
translation into the XDP hook wasn't that bad after all. ILA maybe
hopefully becomes a standard and its implementation is already in the
kernel so why keep its translator not part of the kernel, too?

TLDR; what I'm trying to argue is that evolution of the network stack is
problematic with a programmable backplane in the kernel which locks out
future modifications of the stack in some places. On the other side, if
we don't add those features we will have a half baked solution and
people will simply prefer netmap or DPDK.

Bye,
Hannes
