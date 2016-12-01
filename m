From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [flamebait] xdp, well meaning but pointless
Date: Thu, 1 Dec 2016 16:52:36 +0100
Message-ID: <7e2be2fc-7c04-b333-59c7-43d4fcfcb451@stressinduktion.org>
References: <20161201091108.GF26507@breakpoint.cc>
 <20161201145834.GA569@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>, Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:32954 "EHLO
        out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754525AbcLAPwk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 10:52:40 -0500
In-Reply-To: <20161201145834.GA569@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 01.12.2016 15:58, Thomas Graf wrote:
> On 12/01/16 at 10:11am, Florian Westphal wrote:
>> Aside from this, XDP, like DPDK, is a kernel bypass.
>> You might say 'Its just stack bypass, not a kernel bypass!'.
>> But what does that mean exactly?  That packets can still be passed
>> onward to normal stack?
>> Bypass solutions like netmap can also inject packets back to
>> kernel stack again.
> 
> I have a fundamental issue with the approach of exporting packets into
> user space and reinjecting them: Once the packet leaves the kernel,
> any security guarantees are off. I have no control over what is
> running in user space and whether whatever listener up there has been
> compromised or not. To me, that's a no go, in particular for servers
> hosting multi tenant workloads. This is one of the main reasons why
> XDP, in particular in combination with BPF, is very interesting to me.

First of all, this is a rant targeted at XDP and not at eBPF as a whole.
XDP manipulates packets at free will and thus all security guarantees
are off as well as in any user space solution.

Secondly user space provides policy, acl, more controlled memory
protection, restartability and better debugability. If I had multi
tenant workloads I would definitely put more complex "business/acl"
logic into user space, so I can make use of LSM and other features to
especially prevent a network facing service to attack the tenants. If
stuff gets put into the kernel you run user controlled code in the
kernel exposing a much bigger attack vector.

What use case do you see in XDP specifically e.g. for container networking?

>> b). with regards to a programmable data path: IFF one wants to do this
>> in kernel (and thats a big if), it seems much more preferrable to provide
>> a config/data-based approach rather than a programmable one.  If you want
>> full freedom DPDK is architecturally just too powerful to compete with.
> 
> I must have missed the legal disclaimer that is usually put in front
> of the DPDK marketing show :-)
>
> I don't want full freedom. I want programmability with stack integration
> at sufficient speed and the ability to benefit from the hardware
> abstractions that the kernel provides.
> 
>> Proponents of XDP sometimes provide usage examples.
>> Lets look at some of these.
> 
> [ I won't comment on any of the other use cases because they are of no
>   interest to me ]
> 
>> * Load balancer
>> State holding algorithm need sorting and searching, so also no fit for
>> eBPF (could be exposed by function exports, but then can we do DoS by
>> finding worst case scenarios?).
>>
>> Also again needs way to forward frame out via another interface.
>>
>> For cases where packet gets sent out via same interface it would appear
>> to be easier to use port mirroring in a switch and use stochastic filtering
>> on end nodes to determine which host should take responsibility.
>>
>> XDP plus: central authority over how distribution will work in case
>> nodes are added/removed from pool.
>> But then again, it will be easier to hande this with netmap/dpdk where
>> more complicated scheduling algorithms can be used.
> 
> I agree with you if the LB is a software based appliance in either a
> dedicated VM or on dedicated baremetal.
> 
> The reality is turning out to be different in many cases though, LB
> needs to be performed not only for north south but east west as well.
> So even if I would handle LB for traffic entering my datacenter in user
> space, I will need the same LB for packets from my applications and
> I definitely don't want to move all of that into user space.

The open question to me is why is programmability needed here.

Look at the discussion about ECMP and consistent hashing. It is not very
easy to actually write this code correctly. Why can't we just put C code
into the kernel that implements this once and for all and let user space
update the policies?

Load balancers have to deal correctly with ICMP packets, e.g. they even
have to be duplicated to every ECMP route. This seems to be problematic
to do in eBPF programs due to looping constructs so you end up with
complicated user space anyway.

>> * early drop/filtering.
>> While its possible to do "u32" like filters with ebpf, all modern nics
>> support ntuple filtering in hardware, which is going to be faster because
>> such packet will never even be signalled to the operating system.
>> For more complicated cases (e.g. doing socket lookup to check if particular
>> packet does match bound socket (and expected sequence numbers etc) I don't
>> see easy ways to do that with XDP (and without sk_buff context).
>> Providing it via function exports is possible of course, but that will only
>> result in an "arms race" where we will see special-sauce functions
>> all over the place -- DoS will always attempt to go for something
>> that is difficult to filter against, cf. all the recent volume-based
>> floodings.
> 
> You probably put this last because this was the most difficult to
> shoot down ;-)
> 
> The benefits of XDP for this use case are extremely obvious in combination
> with local applications which need to be protected. ntuple filters won't
> cut it. They are limited and subject to a certain rate at which they
> can be configured. Any serious mitigation will require stateful filtering
> with at least minimal L7 matching abilities and this is exactly where XDP
> will excel.

In my experience and research of DoS attacks you certainly want to put a
bit more logic into a filter than to look up something from hash tables
and drop it then. You certainly also want to have some more logic than
32 * 4096 instructions to execute, e.g. parsing and matching of DNS/NTP
packets with certain conditions and side look-ups. If you seriously do
that stuff you end up with a highly optimized programs containing
stochastic filters and also complex database logic.

If I want to drop based on hash table lookups, as Florian wrote, I would
let the hardware do that and assemble the tables in user space.

Bye,
Hannes
