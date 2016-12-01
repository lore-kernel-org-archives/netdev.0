From: Florian Westphal <fw@strlen.de>
Subject: [flamebait] xdp, well meaning but pointless
Date: Thu, 1 Dec 2016 10:11:08 +0100
Message-ID: <20161201091108.GF26507@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:51372 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1757754AbcLAJOL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 04:14:11 -0500
Received: from fw by Chamillionaire.breakpoint.cc with local (Exim 4.84_2)
        (envelope-from <fw@strlen.de>)
        id 1cCNOW-0004Tx-Ne
        for netdev@vger.kernel.org; Thu, 01 Dec 2016 10:11:08 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ As already mentioned in my reply to Tom, here is
the xdp flamebait/critique ]

Lots of XDP related patches started to appear on netdev.
I'd prefer if it would stop...

To me XDP combines all disadvantages of stack bypass solutions like dpdk
with the disadvantages of kernel programming with a more limited
instruction set and toolchain.

Unlike XDP userspace bypass (dpdk et al) allow use of any programming
model or language you want (including scripting languages), which
makes things a lot easier, e.g. garbage collection, debuggers vs.
crash+vmcore+printk...

I have heared the argument that these restrictions that come with
XDP are great because it allows to 'limit what users can do'.

Given existence of DPDK/netmap/userspace bypass is a reality, this is
a very weak argument -- why would anyone pick XDP over a dpdk/netmap
based solution?
XDP will always be less powerful and a lot more complicated,
especially considering users of dpdk (or toolkits built on top of it)
are not kernel programmers and userspace has more powerful ipc
(or storage) mechanisms.

Aside from this, XDP, like DPDK, is a kernel bypass.
You might say 'Its just stack bypass, not a kernel bypass!'.
But what does that mean exactly?  That packets can still be passed
onward to normal stack?
Bypass solutions like netmap can also inject packets back to
kernel stack again.

Running less powerful user code in a restricted environment in the kernel
address space is certainly a worse idea than separating this logic out
to user space.

In light of DPDKs existence it make a lot more sense to me to provide
a). a faster mmap based interface (possibly AF_PACKET based) that allows
to map nic directly into userspace, detaching tx/rx queue from kernel.

John Fastabend sent something like this last year as a proof of
concept, iirc it was rejected because register space got exposed directly
to userspace.  I think we should re-consider merging netmap
(or something conceptually close to its design).

b). with regards to a programmable data path: IFF one wants to do this
in kernel (and thats a big if), it seems much more preferrable to provide
a config/data-based approach rather than a programmable one.  If you want
full freedom DPDK is architecturally just too powerful to compete with.

Proponents of XDP sometimes provide usage examples.
Lets look at some of these.

== Application developement: ==
* DNS Server
data structures and algorithms need to be implemented in a mostly touring
complete language, so eBPF cannot readily be be used for that.
At least it will be orders of magnitude harder than in userspace.

* TCP Endpoint
TCP processing in eBPF is a bit out of question while userspace tcp stacks
based on both netmap and dpdk already exist today.

== Forwarding dataplane: ==

* Router/Switch
Router and switches should actually adhere to standardized and specified
protocols and thus don't need a lot of custom software and specialized
software.  Still a lot more work compared to userspace offloads where
you can do things like allocating a 4GB array to perform nexthop lookup.
Also needs ability to perform tx on another interface.

* Load balancer
State holding algorithm need sorting and searching, so also no fit for
eBPF (could be exposed by function exports, but then can we do DoS by
finding worst case scenarios?).

Also again needs way to forward frame out via another interface.

For cases where packet gets sent out via same interface it would appear
to be easier to use port mirroring in a switch and use stochastic filtering
on end nodes to determine which host should take responsibility.

XDP plus: central authority over how distribution will work in case
nodes are added/removed from pool.
But then again, it will be easier to hande this with netmap/dpdk where
more complicated scheduling algorithms can be used.

* early drop/filtering.
While its possible to do "u32" like filters with ebpf, all modern nics
support ntuple filtering in hardware, which is going to be faster because
such packet will never even be signalled to the operating system.
For more complicated cases (e.g. doing socket lookup to check if particular
packet does match bound socket (and expected sequence numbers etc) I don't
see easy ways to do that with XDP (and without sk_buff context).
Providing it via function exports is possible of course, but that will only
result in an "arms race" where we will see special-sauce functions
all over the place -- DoS will always attempt to go for something
that is difficult to filter against, cf. all the recent volume-based
floodings.

Thanks, Florian
