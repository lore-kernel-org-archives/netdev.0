From: Tom Herbert <tom@herbertland.com>
Subject: Re: [flamebait] xdp, well meaning but pointless
Date: Thu, 1 Dec 2016 10:02:24 -0800
Message-ID: <CALx6S35J0N6QZFr_ucGLgHtD_LQhTU+Q0d7WsDwffyr4OSEBkQ@mail.gmail.com>
References: <20161201091108.GF26507@breakpoint.cc> <CALx6S35R_ZStV=DbD-7Gf_y5xXqQq113_6m5p-p0GQfv46v0Ow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:34367 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752948AbcLASC0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 13:02:26 -0500
Received: by mail-qk0-f196.google.com with SMTP id y205so27322353qkb.1
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 10:02:25 -0800 (PST)
In-Reply-To: <CALx6S35R_ZStV=DbD-7Gf_y5xXqQq113_6m5p-p0GQfv46v0Ow@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 1, 2016 at 10:01 AM, Tom Herbert <tom@herbertland.com> wrote:
>
>
> On Thu, Dec 1, 2016 at 1:11 AM, Florian Westphal <fw@strlen.de> wrote:
>>
>> [ As already mentioned in my reply to Tom, here is
>> the xdp flamebait/critique ]
>>
>> Lots of XDP related patches started to appear on netdev.
>> I'd prefer if it would stop...
>>
>> To me XDP combines all disadvantages of stack bypass solutions like dpdk
>> with the disadvantages of kernel programming with a more limited
>> instruction set and toolchain.
>>
>> Unlike XDP userspace bypass (dpdk et al) allow use of any programming
>> model or language you want (including scripting languages), which
>> makes things a lot easier, e.g. garbage collection, debuggers vs.
>> crash+vmcore+printk...
>>
>> I have heared the argument that these restrictions that come with
>> XDP are great because it allows to 'limit what users can do'.
>>
>> Given existence of DPDK/netmap/userspace bypass is a reality, this is
>> a very weak argument -- why would anyone pick XDP over a dpdk/netmap
>> based solution?
>
Because, we've seen time an time again that attempts to bypass the
stack and run parallel stacks under the banner of "the kernel is too
slow" does not scale for large deployment. We've seen this with RDMA,
TOE, OpenOnload, and we'll see this for DPDK, FD.io, VPP and whatever
else people are going to dream up. If I have a couple hundred machines
running a single application like the HFT guys do, then sure I'd
probably look into such solutions. But when I have datacenters with
100Ks running an assortment of applications even contemplating the
possibility of deploying a parallel stacks gives me headache. We need
to consider an seemingly endless list of security issues,
manageability. robustness, protocol compatibility, etc. I really have
little interest in bringing a huge pile of 3rd party code that I have
to support, and I definitely have no interest in constantly replacing
all of my hardware to get the latest and greatest support for these
offloads as vendors leak them out. Given a choice between buying into
some kernel bypass solution versus hacking Linux a little bit to carve
out an accelerated data path to address the "kernel is too slow"
argument, I will choose the latter any day of the week.

Tom

>
> Because, we've seen time an time again that attempts to bypass the stack and
> run parallel stacks under the banner of "the kernel is too slow" does not
> scale for large deployment. We've seen this with RDMA, TOE, OpenOnload, and
> we'll see this for DPDK, FD.io, VPP and whatever else people are going to
> dream up. If I have a couple hundred machines running a single application
> like the HFT guys do, then sure I'd probably look into such solutions. But
> when I have datacenters with 100Ks running an assortment of applications
> even contemplating the possibility of deploying a parallel stacks gives me
> headache. We need to consider an seemingly endless list of security issues,
> manageability. robustness, protocol compatibility, etc. I really have little
> interest in bringing a huge pile of 3rd party code that I have to support,
> and I definitely have no interest in constantly replacing all of my hardware
> to get the latest and greatest support for these offloads as vendors leak
> them out. Given a choice between buying into some kernel bypass solution
> versus hacking Linux a little bit to carve out an accelerated data path to
> address the "kernel is too slow" argument, I will choose the latter any day
> of the week.
>
> Tom
>
>> XDP will always be less powerful and a lot more complicated,
>> especially considering users of dpdk (or toolkits built on top of it)
>> are not kernel programmers and userspace has more powerful ipc
>> (or storage) mechanisms.
>>
>> Aside from this, XDP, like DPDK, is a kernel bypass.
>> You might say 'Its just stack bypass, not a kernel bypass!'.
>> But what does that mean exactly?  That packets can still be passed
>> onward to normal stack?
>> Bypass solutions like netmap can also inject packets back to
>> kernel stack again.
>>
>> Running less powerful user code in a restricted environment in the kernel
>> address space is certainly a worse idea than separating this logic out
>> to user space.
>>
>> In light of DPDKs existence it make a lot more sense to me to provide
>> a). a faster mmap based interface (possibly AF_PACKET based) that allows
>> to map nic directly into userspace, detaching tx/rx queue from kernel.
>>
>> John Fastabend sent something like this last year as a proof of
>> concept, iirc it was rejected because register space got exposed directly
>> to userspace.  I think we should re-consider merging netmap
>> (or something conceptually close to its design).
>>
>> b). with regards to a programmable data path: IFF one wants to do this
>> in kernel (and thats a big if), it seems much more preferrable to provide
>> a config/data-based approach rather than a programmable one.  If you want
>> full freedom DPDK is architecturally just too powerful to compete with.
>>
>> Proponents of XDP sometimes provide usage examples.
>> Lets look at some of these.
>>
>> == Application developement: ==
>> * DNS Server
>> data structures and algorithms need to be implemented in a mostly touring
>> complete language, so eBPF cannot readily be be used for that.
>> At least it will be orders of magnitude harder than in userspace.
>>
>> * TCP Endpoint
>> TCP processing in eBPF is a bit out of question while userspace tcp stacks
>> based on both netmap and dpdk already exist today.
>>
>> == Forwarding dataplane: ==
>>
>> * Router/Switch
>> Router and switches should actually adhere to standardized and specified
>> protocols and thus don't need a lot of custom software and specialized
>> software.  Still a lot more work compared to userspace offloads where
>> you can do things like allocating a 4GB array to perform nexthop lookup.
>> Also needs ability to perform tx on another interface.
>>
>> * Load balancer
>> State holding algorithm need sorting and searching, so also no fit for
>> eBPF (could be exposed by function exports, but then can we do DoS by
>> finding worst case scenarios?).
>>
>> Also again needs way to forward frame out via another interface.
>>
>> For cases where packet gets sent out via same interface it would appear
>> to be easier to use port mirroring in a switch and use stochastic
>> filtering
>> on end nodes to determine which host should take responsibility.
>>
>> XDP plus: central authority over how distribution will work in case
>> nodes are added/removed from pool.
>> But then again, it will be easier to hande this with netmap/dpdk where
>> more complicated scheduling algorithms can be used.
>>
>> * early drop/filtering.
>> While its possible to do "u32" like filters with ebpf, all modern nics
>> support ntuple filtering in hardware, which is going to be faster because
>> such packet will never even be signalled to the operating system.
>> For more complicated cases (e.g. doing socket lookup to check if
>> particular
>> packet does match bound socket (and expected sequence numbers etc) I don't
>> see easy ways to do that with XDP (and without sk_buff context).
>> Providing it via function exports is possible of course, but that will
>> only
>> result in an "arms race" where we will see special-sauce functions
>> all over the place -- DoS will always attempt to go for something
>> that is difficult to filter against, cf. all the recent volume-based
>> floodings.
>>
>> Thanks, Florian
>
>
