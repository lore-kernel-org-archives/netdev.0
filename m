From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Wed, 23 Dec 2009 08:57:37 -0600
Message-ID: <4B322FE1.2070104@codemonkey.ws>
References: <4B1D4F29.8020309@gmail.com> <4B30F214.80206@codemonkey.ws> <20091223065129.GA19600@elte.hu> <200912231407.20130.bzolnier@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>,
	Gregory Haskins <gregory.haskins@gmail.com>,
	Avi Kivity <avi@redhat.com>, kvm@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:59540 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752959AbZLWO5m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 09:57:42 -0500
In-Reply-To: <200912231407.20130.bzolnier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/23/2009 07:07 AM, Bartlomiej Zolnierkiewicz wrote:
> On Wednesday 23 December 2009 07:51:29 am Ingo Molnar wrote:

> KVM guys were offered assistance from Gregory and had few months to prove that
> they can get the same kind of performance using existing architecture and they
> DID NOT do it.

With all due respect, there is a huge misunderstanding that's unpinning 
this thread which is that vbus is absolutely more performant than 
virtio-net and that we've failed to demonstrate that we can obtain the 
same level of performance in virtio-net.  This is simply untrue.

In fact, within a week or so of Greg's first posting of vbus, I posted a 
proof of concept patch to the virtio-net backend that got equivalent 
results.  But I did not feel at the time that this was the right 
solution to the problem and we've been trying to do something much 
better.  By the same token, I don't feel that vbus is the right approach 
to solving the problem.

There are really three factors that affect networking performance in a 
virtual environment: the number of copies of the data, the number of 
exits required per-packet transmission, and the cost of each exit.

The "poor" packet latency of virtio-net is a result of the fact that we 
do software timer based TX mitigation.  We do this such that we can 
decrease the number of exits per-packet and increase throughput.  We set 
a timer for 250ms and per-packet latency will be at least that much.

We have to use a timer for the userspace backend because the tun/tap 
device is rather quick to queue a packet which means that we get no 
feedback that we can use to trigger TX mitigation.

vbus works around this by introducing a transmit and receive thread and 
relies on the time it takes to schedule those threads to do TX 
mitigation.  The version of KVM in RHEL5.4 does the same thing.  How 
effective this is depends on a lot of factors including the overall 
system load, the default time slice length, etc.

This tends to look really good when you're trying to drive line speed 
but it absolutely sucks when you're looking at the CPU cost of low 
packet rates.  IOW, this is a heuristic that looks really good when 
doing netperf TCP_RR and TCP_STREAM, but it starts to look really bad 
when doing things like partial load CPU usage comparisons with other 
hypervisors.

vhost-net takes a different, IMHO superior, approach in that it 
associates with some type of network device (tun/tap or physical device) 
and uses the device's transmit interface to determine how to mitigate 
packets.  This means that we can potentially get to the point where 
instead of relying on short timeouts to do TX mitigation, we can use the 
underlying physical device's packet processing state which will provide 
better results in most circumstances.

N.B. using a separate thread for transmit mitigation looks really good 
on benchmarks because when doing a simple ping test, you'll see very 
short latencies because you're not batching at all.  It's somewhat 
artificial in this regard.

With respect to number of copies, vbus up until recently had the same 
number of copies as virtio-net.  Greg has been working on zero-copy 
transmit, which is great stuff, but Rusty Russell had done the same 
thing with virtio-net and tun/tap.  There are some hidden nasties when 
using skb destructors to achieve this and I think the feeling was this 
wasn't going to work.  Hopefully, Greg has better luck but suffice to 
say, we've definitely demonstrated this before with virtio-net.  If the 
issues around skb destruction can be resolved, we can incorporate this 
into tun/tap (and therefore, use it in virtio) very easily.

In terms of the cost per exit, the main advantage vbus had over 
virtio-net was that virtio-net's userspace backend was in userspace 
which required a heavy-weight exit which is a few times more expensive 
than a lightweight exit.  We've addressed this with vhost-net which 
implements the backend in the kernel.  Originally, vbus was able to do 
edge triggered interrupts whereas virtio-pci was using level triggered 
interrupts.  We've since implemented MSI-X support (already merged 
upstream) and we now can also do edge triggered interrupts with virtio.

The only remaining difference is the fact that vbus can mitigate exits 
due to EOI's in the virtual APIC because it relies on a paravirtual 
interrupt controller.

This is rather controversial for a few reasons.  The first is that there 
is absolutely no way that a paravirtual interrupt controller would work 
for Windows, older Linux guests, or probably any non-Linux guest.  As a 
design point, this is a big problem for KVM.  We've seen the struggle 
with this sort of thing with Xen.  The second is that it's very likely 
that this problem will go away on it's own either because we'll rely on 
x2apic (which will eventually work with Windows) or we'll see better 
hardware support for eoi shadowing (there is already hardware support 
for tpr shadowing).  Most importantly though, it's unclear how much EOI 
mitigation actually matters.  Since we don't know how much of a win this 
is, we have no way of evaluating whether it's even worth doing in the 
first place.

At any rate, a paravirtual interrupt controller is entirely orthogonal 
to a paravirtual IO model.  You could use a paravirtual interrupt 
controller with virtio and KVM as well as you could use it with vbus. 
In fact, if that bit was split out of vbus and considered separately, 
then I don't think there would be objections to it in principle 
(although Avi has some scalability concerns with the current 
implementation).

vbus also uses hypercalls instead of PIO.  I think we've established 
pretty concretely that the two are almost identical though from a 
performance perspective.  We could easily use hypercalls with virtio-pci 
but our understanding is that the difference in performance would be 
lost in the noise.

Then there's an awful lot of other things that vbus does differentiately 
but AFAICT, none of them have any impact on performance whatsoever.  The 
shared memory abstraction is at a different level.  virtio models 
something of a bulk memory transfer API whereas vbus models a shared 
memory API.  Bulk memory transfer was chosen for virtio in order to 
support hypervisors like Xen that aren't capable of doing robust shared 
memory and instead rely on either page flipping or a fixed sharing pool 
that often requires copying into or out of that pool.

vbus has a very different discovery mechanism that is more akin to Xen's 
paravirtual I/O mechanism.  virtio has not baked in concept of discovery 
although we must commonly piggy back off of PCI for discovery.  The way 
devices are created and managed is very different in vbus.  vbus also 
has some provisions in it to support non-virtualized environments.  I 
think virtio is fundamentally capable of that but it's not a design 
point for virtio.

We could take any of this other differences, and have a discussion about 
whether it makes sense to introduce such a thing in virtio or what the 
use cases are for that.  I don't think Greg is really interested in 
that.  I think he wants all of vbus or nothing at all.  I don't see the 
point of having multiple I/O models supported in upstream Linux though 
or in upstream KVM.  It's bad for users and it splits development effort.

Greg, if there are other things that you think come into play with 
respect to performance, please do speak up.  This is the best that 
"google" is able to answer my questions ;-)

Regards,

Anthony Liguori
