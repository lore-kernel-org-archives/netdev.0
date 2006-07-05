From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: RDMA will be reverted
Date: Wed, 05 Jul 2006 12:09:42 -0500
Message-ID: <1152119382.20248.51.camel@trinity.ogc.int>
References: <adawtazgawi.fsf@cisco.com>
	 <20060630.141658.34759102.davem@davemloft.net>
	 <1151708503.11835.8.camel@trinity.ogc.int>  <200607011626.04539.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rdreier@cisco.com,
	netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from es335.com ([67.65.19.105]:16451 "EHLO mail.es335.com")
	by vger.kernel.org with ESMTP id S964870AbWGERJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2006 13:09:44 -0400
To: Andi Kleen <ak@suse.de>
In-Reply-To: <200607011626.04539.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-07-01 at 16:26 +0200, Andi Kleen wrote:
> On Saturday 01 July 2006 01:01, Tom Tucker wrote:
> > On Fri, 2006-06-30 at 14:16 -0700, David Miller wrote:
> > 
> > > The TOE folks have tried to submit their hooks and drivers
> > > on several occaisions, and we've rejected it every time.
> > 
> > iWARP != TOE
> 
> Perhaps a good start of that discussion David asked for would 
> be if you could give us an overview of the differences
> and how you avoid the TOE problems.

I think Roland already gave the high-level overview. For those
interested in some of the details, the API for iWARP transports was
originally conceived independently from IB and is documented in the
RDMAC Verbs Specification found here:

http://www.rdmaconsortium.org/home/draft-hilland-iwarp-verbs-v1.0-RDMAC.pdf

The protocols, etc... are available here:
http://www.ietf.org/html.charters/rddp-charter.html

As Roland mentioned, the RDMAC verbs are *very* similar to the IB verbs
and so when we were thinking about how to design an API for iWARP we
concluded it would be best to leverage the tremendous amount of work
already done for IB by OpenFabrics and then work iteratively to extend
this API to include features unique to iWARP. This work has been ongoing
since September of 2005. 

There is an open source svn repository available for the iWARP source at
https://openib.org/svn/gen2/branches/iwarp.

There is also an open source NFS over RDMA implementation for Linux
available here that: http://sourceforge.net/projects/nfs-rdma.


So how do we avoid the TOE pitfalls with iWARP? I think it depends on
the pitfall. At the low level:

- Stale Network/Address Information: Path MTU Change, ICMP Redirect 
and ARP next hop changes need netlink notifier events so that hardware
can be updated when they change. I see this support as an extension (new
events) to an existing service and a relatively low-level of "parallel
stack integration". iSCSI and IB could also benefit from these events.

- Port Space Collision, i.e. socket app and rdma/iWARP apps collide on 
a port number: The RDMA CMA needs to be able to allocate and de-allocate
port numbers, however, the services that do this today are not exported
and would need some minor tweaking. iSCSI and IB benefit from these
services as well.

- netfilter rules, syn-flood, conn-rate, etc.... You pointed out that 
if connection establishment were done in the native stack (SYN,
SYN/ACK), that this would account for the bulk of the netfilter utility,
however, this probably results in falling into many of the TOE traps
people have issue with.

WRT to http://linux-net.osdl.org/index.php/TOE

Security Updates

"A TOE net stack is closed source firmware. Linux engineers have no way
to fix security issues that arise. As a result, only non-TOE users will
receive security updates, leaving random windows of vulnerability for
each TOE NIC's users."

- A Linux security update may or may not be relevant to a vendors
implementation. 

- If a vendor's implementation has a security issue then the customer
must rely on the vendor to fix it. This is no less true for iWARP than
for any adapter.

Point-in-time Solution

"Each TOE NIC has a limited lifetime of usefulness, because system
hardware rapidly catches up to TOE performance levels, and eventually
exceeds TOE performance levels. We saw this with 10mbit TOE, 100mbit
TOE, gigabit TOE, and soon with 10gig TOE."

- iWARP needs to do protocol processing in order to validate and
evaluate TCP payload in advance of direct data placement. This
requirement is independent of CPU speed. 

Different Network Behavior

"System administrators are quite familiar with how the Linux network
stack interoperates with the world at large. TOE is a black box, each
NIC requires re-examination of network behavior. Network scanners and
analysis tools must be updated, or they will provide faulty analysis."

- Native Linux Tools like tcpdump, netstat, etc... will not work as
expected. 

- Network Analyzers such as Finisar, etc... will work just fine.

Performance

"Experience has shown that TOE implementations require additional work
(programming the hardware, hardware-specific socket manipulation) to set
up and tear down connections. For connection intensive protocols such as
HTTP, TOE often underperforms."

- I suspect that connection rates for RDMA adapters fall well-below the
rates attainable with a dumb device. That said, all of the RDMA
applications that I know of are not connection intensive. Even for TOE,
the later HTTP versions makes connection rates less of an issue.

Hardware-specific limits 

"TOE NICs are more resource limited than your overall computer system.
This is most readily apparent under load, when trying to support
thousands of simultaneous connections. TOE NICs simply do not have the
memory resources to buffer thousands of connections, much less have the
CPU power to handle such loads. Further, each TOE NIC has different
resource limitations (often unpublished, only to be discovered at the
worst moments)."

- Any hardware device has this issue and so does iWARP

"Once resources are exhausted, TOE will either fall back to 100%
software net stack, defeating the purpose of TOE, or will deny service
to additional clients."

- A depleted iWARP adapter will simply fail the request. There is no
parallel iWARP stack to fall back on.

Resource-based denial-of-service attacks 

"If an attacker can discover the TOE NIC model in use, they can use this
information to enable resource-based algorithmic attacks. For example, a
SYN flood could potentially use up all TOE resources in a matter of
seconds. The TOE NIC will either stop accepting connections (complete
DoS), or will constantly bounce back to the software net stack."

- True of iWARP too.

RFC compliance 

"Linux is the most RFC-compliant network stack available. TOE can only
diminish this. Further, as a black box, each TOE NIC will have a
different level of RFC compliance, and different TCP/IP features they
do/don't support."

- True of iWARP too.

Linux features 

"TOE is by definition poorly integrated into Linux. TOE NICs will not
provide netfilter, packet scheduling, QoS, and many other features that
Linux users depend on. Or if they do provide this, they implement the
features in a vendor-specific manner. The featureset becomes
vendor-specific."

- This is the problem we're trying to solve...incrementally and
responsibly.

Requires vendor-specific tools 

"In order to configure a TOE NIC, hardware-specific tools are usually
required. This dramatically increases support costs."

- OpenFabrics is an attempt to solve this not only across vendors, but
also across transports (at this time IB and iWARP)

Poor user support 

"Linux engineers cannot provide an adequate level of support for TOE
users, and must instead refer users to the vendor -- who in all
likelihood cares more about non-Linux operating systems."

- This will certainly be true for iWARP early on.

Short term kernel maintenance 

"Supporting TOE requires massive, heavily invasive hooks into the
network stack. This increases the kernel maintenance burden on Linux
engineers, to support a solution Linux engineers have no control over."

- iWARP does not use sockets and does not share data structures with the
TCP stack. 
- It is not my opinion, however, that the patches in question consist of
"massive, heavily invasive hooks into the network stack". 

Long term user support 

"Linux has been in existence for over a decade, and some pieces of
decade-old hardware continue to be used and supported. In contrast, most
hardware vendors end-of-life (stop supporting) their hardware after just
a few years. For most hardware vendors, the sales of old hardware simply
do not justify dedicating engineers to Linux support for many years."

- If the hooks are not hideous and invasive then support should not be
any more onerous than for any other hardware device.

Long term kernel maintenance 

"Similarly, kernel engineers must support TOE for as long as users
continue to use the hardware. Hardware vendors disappear, get bought, or
simply disappear (go out of business) during our maintenance timeframe.
Once a hardware vendor loses interest in Linux, TOE NICs will cease to
receive security updates, and hardware issues become incredibly
difficult to debug. Each new generation of system hardware often
requires re-examination of hardware drivers, a task made far more
difficult without a hardware vendor to receive questions."

- This seems like a general rant against any hardware device and so it
applies to iWARP too. 

Eliminates global system view 

"With TOE, the system no longer has a complete picture of all resources
used by network connections. Some connections are software-based, and
thus limited by existing policy controls (such as per-socket memory
limits). Other connections are managed by TOE, and these details are
hidden. As such, the VM cannot adequately manage overall socket buffer
memory usage, TOE-enabled connections cannot be rate-limited by the same
controls as software-based connections, per-user socket security limits
may be ignored, etc."

- iWARP doesn't use socket buffers.

Linux has several TCP Congestion Control algorithms available. For TOE
connections, this would no longer be true, all the congestion control
would be done by proprietary vendor specific algorithms on the card.

- I don't know of any proprietary congestion control algorithms built
into iWARP and doubt they would work between vendors. There is an iWARP
Interoperability Lab at UNH that tests this kind of thing.


> 
> -Andi
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

