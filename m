From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [flamebait] xdp Was: Re: bpf bounded loops. Was: [flamebait] xdp
Date: Sun, 4 Dec 2016 17:05:28 +0100
Message-ID: <eee898ad-9a77-2987-c38d-984231139475@stressinduktion.org>
References: <20161201091108.GF26507@breakpoint.cc>
 <20161201145834.GA569@pox.localdomain>
 <7e2be2fc-7c04-b333-59c7-43d4fcfcb451@stressinduktion.org>
 <20161201162814.GA31300@pox.localdomain>
 <583b8947-3395-8529-933b-08e1a86a0778@stressinduktion.org>
 <CALx6S36=Y0dSux+-omWXZKtxb73_g4+DXhPBawb79+UF6rp9rw@mail.gmail.com>
 <9b4264f8-26b9-a611-56f0-0840cecf9c44@stressinduktion.org>
 <20161202183903.GC54949@ast-mbp.thefacebook.com>
 <2f3ce25c-3f59-9120-7d09-619be9b58e7a@stressinduktion.org>
 <1480707761.3858425.806609417.2E2C5E07@webmail.messagingengine.com>
 <20161202233430.GA58522@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>, Thomas Graf <tgraf@suug.ch>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:52936 "EHLO
        out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750867AbcLDQFc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 11:05:32 -0500
In-Reply-To: <20161202233430.GA58522@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On 03.12.2016 00:34, Alexei Starovoitov wrote:
> On Fri, Dec 02, 2016 at 08:42:41PM +0100, Hannes Frederic Sowa wrote:
>> On Fri, Dec 2, 2016, at 20:25, Hannes Frederic Sowa wrote:
>>> On 02.12.2016 19:39, Alexei Starovoitov wrote:
>>>> On Thu, Dec 01, 2016 at 10:27:12PM +0100, Hannes Frederic Sowa wrote:
>>>>> like") and the problematic of parsing DNS packets in XDP due to string
>>>>> processing and looping inside eBPF.
>>>>
>>>> Hannes,
>>>> Not too long ago you proposed a very interesting idea to add
>>>> support for bounded loops without adding any new bpf instructions and
>>>> changing llvm (which was way better than my 'rep' like instructions
>>>> I was experimenting with). I thought systemtap guys also wanted bounded
>>>> loops and you were cooperating on the design, so I gave up on my work and
>>>> was expecting an imminent patch from you. I guess it sounds like you know
>>>> believe that bounded loops are impossible or I misunderstand your statement ?
>>>
>>> Your argument was that it would need a new verifier as the current first
>>> pass checks that we indeed can lay out the basic blocks as a DAG which
>>> the second pass depends on. This would be violated.
> 
> yes. today the main part of verifier depends on cfg check that confirms DAG
> property of the program. This was done as a simplification for the algorithm,
> so any programmer that understands C can understand the verifier code.
> It certainly was the case, since most of the people who hacked
> verifier had zero compiler background.
> Now I'm thinking to introduce proper compiler technologies to it.
> On one side it will make the bar to understand higher and on the other
> side it will cleanup the logic and reuse tens of years of data flow
> analysis theory and will make verifier more robust and mathematically
> solid.

See below.

>>> Because eBPF is available by non privileged users this would need a lot
>>> of effort to rewrite and verify (or indeed keep two verifiers in the
>>> kernel for priv and non-priv). The verifier itself is exposed to
>>> unprivileged users.
> 
> I certainly hear your concerns that people unfamiliar with it are simply
> scared that more and more verification logic being added. So I don't mind
> freezing current verifier for unpriv and let proper data flow analysis
> to be done in root only component.
> 
>>> Also, by design, if we keep the current limits, this would not give you
>>> more instructions to operate on compared to the flattened version of the
>>> program, it would merely reduce the numbers of optimizations in LLVM
>>> that let the verifier reject the program.
> 
> I think we most likely will keep 4k insn limit (since there were no
> requests to increase it). The bounded loops will improve performance
> and reduce I-cache misses.

I agree that bounded loops will increase performance and in general I
see lifting this limitation as something good if it works out.

>> The only solution to protect the verifier, which I saw, would be to
>> limit it by time and space, thus making loading of eBPF programs
>> depending on how fast and hot (thermal throttling) one CPU thread is.
> 
> the verifier already has time and space limits.
> See no reason to rely on physical cpu sensors.

Time and space is bounded by the DAG property. It is still bounded in
the directed cyclic case (some arbitrary upper limit), but can have a
combinatorical explosion because of the switch from proving properties
for each node+state to prove properties for each path+state.

Compiler algorithms maybe a help here, but historically have focused on
other properties, mainly optimization and thus are mostly heuristics.

Compiler developers don't write the algorithm under the assumption they
will execute in a security and resource sensitive environment (only the
generated code should be safe). I believe that optimization algorithms
increase the attack surface, as their big-O worst case might be an
additional cost, additionally to the worst case verification path. I
don't think compiler engineers think about the code to optimize
attacking the optimization algorithm itself.

Verification of a malicious BPF program (complexity bomb) in the kernel
should not disrupt nor create a security threat (we are also mostly
voluntary preemptible in this code and hold a lock). Verification might
fail when memory fragmentation becomes more probably, as the huge state
table for path sensitive verification cannot be allocated.

In user space, instead of verification of many properties regarding
program state (which you actually need in the BPF verifier), the
development effort concentrates on sanitizers. Otherwise look how good
gcc is in finding uninitialized variables.

Most mathematical proofs that are written for compiler optimization I
know of are written to show equivalence between program text and the
optimization. Compile time recently became a more important aspect of
the open source compilers at least.

I am happy to be shown wrong here and assume there is no better
algorithm, which is reasonable easy for the kernel - I am a pessimist
but am happy to look at proposals.

>> Those are the complexity problems I am talking and concerned about.
> 
> Do you have concerns when people implement encryption algorithm
> that you're unfamiliar with?

Absolutely not, this can already be done in user space very much the
same, I can remove it, delete it, uninstall it. APIs in the kernel stay
forever.

> Isn't it much bigger concern, since any bugs in the algorithm
> are directly exploitable and when encryption is actually used
> it's protecting sensitive data, whereas here the verifier
> protects kernel from crashing.

Bugs happen everywhere, but a bug in the kernel itself creates a whole
bigger mess than a bug in a security constrained user space application
with proper privilege drops (at least it should).

The complexity arguments in random order:

1) The code itself - if the route is taken to provide two verifiers for
eBPF, this certainly comes with a maintenance cost to keep them secure
(secure as in the verifier itself should not expose a threat neither is
the to be verified program allowed to leak data or exceed its address
space nor some time budget).

If one of those eBPF verifiers only accepts a certain number of INSN, as
fundamental as backwards jumps, we might end up with two compiler?

At some point Google might start to fuzz them like right now other
fundamental parts of the kernel and someone must review all the code and
fix them in both of them.

If we shift verification to new heuristics programs will still fail,
just under new conditions, this exposes complexity to the users.
Libraries cannot even be exchanged between those twos.

2) Integration and API considerations:

E.g. the newly added cgroup socket bpf interface, which can modify
bound_dev_if. If you restart networking (old way
/etc/init.d/networking), those if_indexes are all outdated and the
system will behave strangely. Network management software needs to walk
cgroup (a different kernel subsystem) now, too, in order to refresh
outdated information, recompile and insert. Even worse, all user space
programs which might be in the cgroups need to be restarted, too, as the
change is permanent per socket lifetime. Instead of reconfiguring
networking, I will probably now restart the whole box.
Furthermore it gets even more complicated because cgroup can be
namespace'd nowadays and doesn't necessarily need to have no 1:1
relation with the network namespace, so this gets really complicated.

Misconfiguration causes security problems.

In the past we had dependency trees and notifiers to e.g. clean up IPs,
multicast, disable netfilter rules, routes, etc., because the current
kernel tries to keep a specific semantic when you disable an interface
and bring it back up or do some other configuration change.

Like in the eBPF example with cgroups above, networking stack state
might become hard coded in XDP programs because of simplicity and
regularly needs to be refreshed to correspond linux networking changes
from user space, too. User space program crashes or gets killed by an
admin and doesn't remember to clean-up, the kernel is partly tainted
with some state you can search in different subsystems, cgroups, XDP,
qdiscs and clean up yourself (if we assume we can't do everything in XDP).

All those changes pretty much speak for a new user space control plane,
which wasn't that much necessary so far. Two places to keep your data up
to date creates intermediate states where it is not up to date and also
the update process itself might be complex (e.g. simple things like
unicast/multicast address filter changes on the NIC vs. what the XDP
program thinks). Ergo, more complexity. What do you do when one of those
two systems fail? What is the reference data? What do you do if on a
highly busy box during DoS constant reloading of your vmalloc happens (I
don't know if it is a problem under DoS)?

Lot's of effort went into transparent hw offloading to still retain this
property of transparency and behave as a proper citizen.

If XDP should not be considered an outsider of the networking stack, it
should as well understand reconfiguration events which leads to leakage
of kernel internals into XDP (e.g. Jesper's example of writing a bridge
in XDP, or offloading examples where we need some network config pieces).

I find it strange that hw offloading people try as much as possible to
discover the state of the linux networking stack inside the kernel and
apply this state transparently to hw offloads. Will there be shulti
switch available to allow user space to sniff switchdev events to
compile them to XDP or update hashtables?

"Software offloading" basically brings the control and dataplane into
user space (not technically but from the users PoV), making it
abnormally difficult to fit in with the traditional network admin tools.

3) Security complexity:

I was e.g. wondering if there is an architectural TOCTTOU in
"env->allow_ptr_leaks = capable(CAP_SYS_ADMIN);" in the verifier,
because bpf objects can be easily passed around and be attached to file
descriptors etc. of processes that might be sandboxed.

Leaks of pointers can e.g. lead to discover the state of address space
layout randomization. Can we now pass verifier-ng verified eBPF programs
around to untrusted programs? To sandboxes? Need they be tainted? Do we
need to consider that for bpffs? What about user namespaces? If it turns
out to be a problem now, would a change like this be backwards compatible?

Helpers for eBPF need to be checked regularly if they still provide
their safety guarantees, especially if they call into other subsystems,
also when new features get added.

4) Complexity for users of this framework (compiler problems solved):

I tried to argue that someone wanting to build netmap/DPDK-alike things
in XDP, one faces the problem of synchronized IPC. Hashmaps solve this
to some degree but cannot be synchronized. Recent offloading series
showed e.g. how hard it is to keep state up-to-date in multiple places.
If XDP-user space sharing happens this might be solved.

Adding external functions to eBPF might also freeze some kernel
internals or the eBPF wrappers might become complex down some years.

DPDK even can configure various hw offloads already before the kernel
can do so. If users want to use those, they switch to DPDK also, as I
have seen the industry always wanting the best performance. DPDK can use
SIMD instructions, all AVX, SSE and MMX stuff, and they do it.

Users still depend on specific versions of the kernel due to which
functions are exported to XDP.

Debugging is harder but currently worked on. But will probably always be
harder than simply using a debugger.

This all leads to gigantic user space control planes like neutron and
others that just make everyone's life much harder. The model requires
this. And that is what I fear.

I am not at all that negative against a hook before allocating the
packet, but making everyone using it and marketing as an alternative to
DPDK doesn't seem to fit for me.

It seems to me if XDP should even remotely be comparable to DPDK a lot
of complexity has to be added. It is not Linux network stack for me
either so far.

Sorry if I hijacked the bounded loop discussion for the rant. I am happy
to discuss or follow-up on ideas regarding lifting the looping limit in
eBPF.

Bye,
Hannes
