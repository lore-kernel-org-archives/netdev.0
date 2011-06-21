From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Netconf 2011 notes
Date: Tue, 21 Jun 2011 15:02:10 +0100
Message-ID: <1308664930.2743.11.camel@bwh-desktop>
References: <20110615.145937.1748734114172641662.davem@davemloft.net>
	 <4DF9D644.708@linux.vnet.ibm.com>
	 <20110616.171110.2293322834897062244.davem@davemloft.net>
	 <1308259955.2925.16.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: seenutn@linux.vnet.ibm.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:45422 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751623Ab1FUOCN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 10:02:13 -0400
In-Reply-To: <1308259955.2925.16.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-06-16 at 22:32 +0100, Ben Hutchings wrote:
> On Thu, 2011-06-16 at 17:11 -0400, David Miller wrote:
> > From: Srinivasa T N <seenutn@linux.vnet.ibm.com>
> > Date: Thu, 16 Jun 2011 15:39:08 +0530
> > 
> > > 	Were there some interesting topics which is useful for the community?
> > > 	(Few lines on each such topic would do).
> > 
> > There is a topic description for each presentation, plus the
> > slides themselves on the web site.
> > 
> > I can't think of anything more significant that could be
> > provided.
> 
> It would be nice to have some record of significant questions and
> answers; and any conclusions or consensus from discussions.
> 
> I can provide the notes I took regarding my own topics.

Here are my notes.  These are somewhat biased by own areas of interest
and ignorance; others may wish to correct or fill in some gaps.

Stephen Hemminger: Crossing the next bridge
http://vger.kernel.org/netconf2011_slides/shemminger_Bridge2.pdf

Linux bridge driver is missing some features found in other software
(and hardware) bridges.
These include virtualisation features like VEPA VEB and VN tag.
Should the bridge control plane remain entirely in the kernel, or should
the bridge call out to userspace (like Openflow)?  Benefits include
easier persistence of state, complex policies.  Performance can be
lower; is that significant?
Some discussion but no conclusions that I recall.

Jesse Brandeburg: Reducing Stack Latency
http://vger.kernel.org/netconf2011_slides/jesse_brandeburg_netconf2011.pdf

Jesse presented some graphs showing cycle counts spent in packet
processing in the network stack and driver (ixgbe) on several hardware
platforms, for a netperf UDP_RR test.  Some discussion of why certain
functions are expensive.  No conclusions but I expect that the numbers
will be useful.  Jeese said the ranges on the graphs show the variation
between different hardware platforms (not between packets), but I don't
think this is correct.

Jiri Pirko: LNST Project
http://vger.kernel.org/netconf2011_slides/Netconf2011_lnst.pdf
https://fedorahosted.org/lnst/

Jiri is working on LNST (Linux Network Stack Test), a test framework for
network topologies, currently concentrated on regression-testing various
software devices (bridge, bond, VLAN).
Currently at an early stage of development.
Written in Python; uses XML-RPC to control DUTs.
Configuration file specifies setup using Linux net devices and switch
ports, and commands to test with.

Jiri Pirko: Team driver
http://vger.kernel.org/netconf2011_slides/Netconf2011_team.pdf

Current bonding driver supports various different policies and protocols
implemented by different people.  It has become a mess and this is
probably not fixable due to backward compatibility concerns.  (All
agreed.)
Jiri proposes a simpler replacement for the current bonding driver, with
all policy defined by user-space.
General support for this, but 'show us the code'.
I questioned how load balancing would be done without built-in policies
for flow hashing.  Answer: user-space provides hash function as BPF code
or similar; we now have a JIT compiler for BPF so this should not be too
slow.

Herbert Xu: Scalability
http://vger.kernel.org/netconf2011_slides/herbert_xu_netconf2011.odp

XPS (transmit packet steering) may reorder packets in a flow when it
changes the TX queue used.  Protocol sets a flag to indicate whether
this is OK, and currently only TCP does that.  Should we set it for UDP,
by default or by socket option?
Conclusion: depends on applications; add the socket option but also a
sysctl for the default so users don't need to modify applications.

Enumerated some areas of networking that still involve global or
per-device locks or other mutable state, and network structures that are
not allocated in a NUMA-aware way.  Some discussion of what can be done
to improve this.

Herbert Xu: Hardware LRO

GRO + forwarding can results in moving segment boundaries.  Does anyone
mind?  Can we also let LRO implementations set gso_type like GRO does,
and not disable them when forwarding?

Stephen Hemminger: IRQ name/balancing
http://vger.kernel.org/netconf2011_slides/shemminger_IRQ.pdf

There is no information about IRQ/queue mapping in sysfs, and IRQs may
not even be visible while interface is down.
IRQs do appear in /proc/interrupts, but the name format for per-queue
IRQs is inconsistent between different drivers!
Conclusion: naming scheme has already been agreed but we need to fix
some multiqueue drivers; we should add a function to generate standard
names.

irqbalance: most agree that it doesn't work at the moment, but Intel is
happy that current version follows their hints.
Currently irqbalance usually does things wrong and everyone has to write
their own scripts.
Further discussion deferred to my slot.

Stephen Hemminger: Open vSwitch
http://openvswitch.org/

I didn't take any notes for this.  Apparently it's an interesting
project.

Stephen Hemminger: Virtualized Networking Performance
http://vger.kernel.org/netconf2011_slides/shemminger_VirtPerfSummary.pdf

Presented networking throughput measurements for hosts and routers.
Performance is terrible, although VMware does better than Xen or KVM.

Thomas Graf: Network Configuration Usability and World IPv6 Day
http://vger.kernel.org/netconf2011_slides/tgraf_netconf2011.pdf

Presented libnl 3.0, its Python bindings and the 'ncfg' tool as a
potential replacement for many of the current network configuration
tools.  (Slide 4 seems to show other tools building on top of ncfg, but
this is not actually what he meant.  They should use libnl too.)

Requesting dump of interface state though netlink can currently provide
too much information.  Should be a way for user-space to request partial
state, e.g. statistics.
Automatic dump retry: if I understood correctly, it is possible to get
inconsistent information when a dump uses multiple packets.  So there
should be some way for user-space to detect and handle this.
Some interface state only accessible through ethtool ioctl; should be
accessible through netlink too.  Problem with setting through netlink is
that each setting operation may fail and there is no way to commit or
rollback atomically (without changing most drivers).

World IPv6 Day seems to have mostly worked.  However there are still
some gaps and silly bugs in IPv6 suport in both Linux kernel (e.g.
netfilter can't track DHCPv6 properly) and user-space (e.g. ping6
doesn't restrict hostname lookup to IPv6 addresses).

Tom Herbert: Super Networking Performance
http://vger.kernel.org/netconf2011_slides/therbert_netconf2011.pdf

Gave reasons for wanting higher networking performance.
Presented results using Onload with simple benchmarks and a real
application (load balancer).  Attendees seemed generally impressed; some
questions to me about how Onload works.
Showed how kernel stack latency improves with greater use of polling and
avoiding user-space rescheduling.
Presented some performance goals and networking features that may help
to get there.

David S. Miller: Routing Cache: Just Say No
http://vger.kernel.org/netconf2011_slides/davem_netconf2011.pdf

David wants to get rid of the IPv4 routing cache.  Removing the cache
entirely seems to make route lookup take about 50% longer than it
currently does for a cache hit, and much less time than for a cache
miss.  It avoids some potential for denial of service (forced cache
misses) and generally simplifies routing.

This was a progress report on the refactoring required; none of this was
familiar to me so I didn't try to summarise.

Ben Hutchings: Managing multiple queues: affinity and other issues
http://vger.kernel.org/netconf2011_slides/bwh_netconf2011.pdf

I recapped the current situation of affinity settings and presented the
two options I see for improving and simplifying it.  The consensus was
to go with option 2: each queue will have irq (read-only) and affinity
(read-write) attributes exposed in sysfs, and the networking core will
generate IRQ affinity hints which irqbalance should normally follow.  I
think there's enough support for this that we won't have to do all the
work.

I recapped the way RX queues are currently selected and why this may not
be optimal, and proposed some kind of system policy that could be used
to control this.  This would provide a superset of the functionality to
the rss_cpus module parameter and IRQ affinity setting in our
out-of-tree driver.  I believe this was agreed to be a reasonable
feature, though I'm not sure everyone looked at the details I listed.

Some people wanted an ethtool interface to set per-queue interrupt
moderation.
Some would really like to be able to add and remove RX queues, or at
least set indirection table, based on demand.  This would save power.
Tom wants an interface to set steering + hashing; ideally automatic when
multiple threads listen on the same (host, port).

PJ Waskiewicz: iWarp portspace
http://vger.kernel.org/netconf2011_slides/pj_netconf2011.ppt

iWarp offload previously required kernel patch to reserve ports.  RHEL
stopped carrying the patch.  Port reservation will now be handled by a
user-space daemon holding sockets.

PJ Waskiewicz: Standard netdev module parms
http://vger.kernel.org/netconf2011_slides/pj_netdev_params.odp

Proposed some standardisation of options that may need to be established
before net device registration, e.g. interrupt mode or number of VFs to
enable.
Per-device parameters would be provided as list (as in Intel out-of-tree
drivers).  But this assumes enumeration order is stable, which it isn't
in general.
Not much support for module parameters.  Someone suggested that
per-device settings could be requested at probe time, similarly to
request_firmware().

PJ Waskiewicz: Advanced stats
http://vger.kernel.org/netconf2011_slides/pj_advanced_stats.odp

Complex devices with many VFs, bridge functionality, etc. can present
many more statistics.  ethtool API is unstructured and won't scale to
this.  Proposes to put them in sysfs.  The total number could be a
big problem, as each needs an inode in memory.

Eric Dumazet: JIT, UDP, Packet Schedulers
http://vger.kernel.org/netconf2011_slides/edumazet_netconf2011.pdf

Implemented JIT compiler for BPF on x86_64; porting should be easy.
Room for further optimisation.  Can we use a similar technique to speed
up iptables/ip6tables filters?

UDP multiqueue transmit perf is suffering from cache bouncing.
Kernel takes reference to dst information (for MTU etc.) before
copying from userspace.  Copying from userspace may sleep so we must
take counted reference not RCU.  For small packets, could copy onto
kernel stack first, then no need for refcounting.
How about an adaptive refcount that dynamically switches to percpu
counter if highly contended?
My suggestion: assuming we only need dst for MTU, in order to
fragment into skbs - why bother doing that here?  The output path
can already do fragmentation (GSO-UFO).

Smart packet schedulers needed for proper accounting of packets of
varying size and for software QoS.  However the smarter schedulers
don't currently work well with multiqueue (without hardware priority).
HTB is entirely single-queue so it can maintain per-device rate
limits.  Can we reduce locking by batching packet accounting?  (Reduce
precision of limiting but improve performance.)

Jeffrey T. Kirsher: drivers/net rearrangement
http://vger.kernel.org/netconf2011_slides/jkirsher_netconf2011.odp

As previously discussed, drivers/net and corresponding configuration
menus are a mess.  Almost finished the proposed rearrangement by link
layer type and other groupings.

Jamal Hadi Salim: Catching up With Herbert
http://vger.kernel.org/netconf2011_slides/jamal_netconf2011.pdf
http://vger.kernel.org/netconf2011_slides/netconf-2011-flash.tgz
(don't miss the animations)

History of TX locking:
1. Each sender enters and locks qdisc (sw queue) and hw queue in turn;
repeats for each packet until done.  Many senders can be spinning.
2. Add busy flag; sender sets when entering qdisc.  When not
previously set, the sender takes responsibility for draining sw queue
into hw queue.  Other senders only add to sw queue.  Draining sender
yields at the next clock tick or (some other condition).
3. Spinlock behaviour changed to Baker's algorithm (ticket locking).
Generally better but means the draining sender has to wait behind
other senders when re-locking the qdisc.  (Contention is not so
high for multiqueue devices, though.)
4. Busylock: extra lock for senders preparing to lock qdisc first
time, not taken by draining sender when re-entering.  Effectively gives
the draining sender higher priority.

Potential for great unfairness, as some senders take care of hw
queueing for others - for up to a tick (variable length of time!).
Proposes quota for draining instead of or as well as the current
limits.  Showed results suggesting that good quota is #CPU + 1.

Eric and Herbert objected that his experiments on the dummy device
may not be representative.

David S. Miller / Jamal Hadi Salim: Closing statements, future netconf planning

David open to proposals for netconf in Feb-Apr next year.  Wants to
invite wider range of people.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

