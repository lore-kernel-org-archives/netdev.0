From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] net: add Documentation/networking/scaling.txt
Date: Mon, 01 Aug 2011 11:49:08 -0700
Message-ID: <4E36F524.7090301@hp.com>
References: <alpine.DEB.2.00.1107312346350.28722@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rdunlap@xenotime.net, linux-doc@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org, willemb@google.com
To: Tom Herbert <therbert@google.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1107312346350.28722@pokey.mtv.corp.google.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/31/2011 11:56 PM, Tom Herbert wrote:
> Describes RSS, RPS, RFS, accelerated RFS, and XPS.
>
> Signed-off-by: Tom Herbert<therbert@google.com>
> ---
>   Documentation/networking/scaling.txt |  346 +++++++++++++++++++++++=
+++++++++++
>   1 files changed, 346 insertions(+), 0 deletions(-)
>   create mode 100644 Documentation/networking/scaling.txt
>
> diff --git a/Documentation/networking/scaling.txt b/Documentation/net=
working/scaling.txt
> new file mode 100644
> index 0000000..aa51f0f
> --- /dev/null
> +++ b/Documentation/networking/scaling.txt
> @@ -0,0 +1,346 @@
> +Scaling in the Linux Networking Stack
> +
> +
> +Introduction
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +This document describes a set of complementary techniques in the Lin=
ux
> +networking stack to increase parallelism and improve performance (in
> +throughput, latency, CPU utilization, etc.) for multi-processor syst=
ems.

Why not just leave-out the parenthetical lest some picky pedant find a=20
specific example where either of those three are not improved?

> +
> +The following technologies are described:
> +
> +  RSS: Receive Side Scaling
> +  RPS: Receive Packet Steering
> +  RFS: Receive Flow Steering
> +  Accelerated Receive Flow Steering
> +  XPS: Transmit Packet Steering
> +
> +
> +RSS: Receive Side Scaling
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D
> +
> +Contemporary NICs support multiple receive queues (multi-queue), whi=
ch
> +can be used to distribute packets amongst CPUs for processing. The N=
IC
> +distributes packets by applying a filter to each packet to assign it=
 to
> +one of a small number of logical flows.  Packets for each flow are
> +steered to a separate receive queue, which in turn can be processed =
by
> +separate CPUs.  This mechanism is generally known as =E2=80=9CReceiv=
e-side
> +Scaling=E2=80=9D (RSS).
> +
> +The filter used in RSS is typically a hash function over the network=
 or
> +transport layer headers-- for example, a 4-tuple hash over IP addres=
ses

Network *and* transport layer headers?  And/or?


> +=3D=3D RSS IRQ Configuration
> +
> +Each receive queue has a separate IRQ associated with it. The NIC
> +triggers this to notify a CPU when new packets arrive on the given
> +queue. The signaling path for PCIe devices uses message signaled
> +interrupts (MSI-X), that can route each interrupt to a particular CP=
U.
> +The active mapping of queues to IRQs can be determined from
> +/proc/interrupts. By default, all IRQs are routed to CPU0.  Because =
a

Really?

> +non-negligible part of packet processing takes place in receive
> +interrupt handling, it is advantageous to spread receive interrupts
> +between CPUs. To manually adjust the IRQ affinity of each interrupt =
see
> +Documentation/IRQ-affinity. On some systems, the irqbalance daemon i=
s
> +running and will try to dynamically optimize this setting.

I would probably make it explicit that the irqbalance daemon will undo=20
one's manual changes:

"Some systems will be running an irqbalance daemon which will be trying=
=20
to dynamically optimize IRQ assignments and will undo manual adjustment=
s."

Whether one needs to go so far as to explicitly suggest that the=20
irqbalance daemon should be disabled in such cases I'm not sure.


> +RPS: Receive Packet Steering
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
> +
> +Receive Packet Steering (RPS) is logically a software implementation=
 of
> ...
> +
> +Each receive hardware qeueue has associated list of CPUs which can

"queue has an associated" (spelling and grammar nits)

> +process packets received on the queue for RPS.  For each received
> +packet, an index into the list is computed from the flow hash modulo=
 the
> +size of the list.  The indexed CPU is the target for processing the
> +packet, and the packet is queued to the tail of that CPU=E2=80=99s b=
acklog
> +queue. At the end of the bottom half routine, inter-processor interr=
upts
> +(IPIs) are sent to any CPUs for which packets have been queued to th=
eir
> +backlog queue. The IPI wakes backlog processing on the remote CPU, a=
nd
> +any queued packets are then processed up the networking stack. Note =
that
> +the list of CPUs can be configured separately for each hardware rece=
ive
> +queue.
> +
> +=3D=3D RPS Configuration
> +
> +RPS requires a kernel compiled with the CONFIG_RPS flag (on by defau=
lt
> +for smp). Even when compiled in, it is disabled without any
> +configuration. The list of CPUs to which RPS may forward traffic can=
 be
> +configured for each receive queue using the sysfs file entry:
> +
> + /sys/class/net/<dev>/queues/rx-<n>/rps_cpus
> +
> +This file implements a bitmap of CPUs. RPS is disabled when it is ze=
ro
> +(the default), in which case packets are processed on the interrupti=
ng
> +CPU.  IRQ-affinity.txt explains how CPUs are assigned to the bitmap.

Earlier in the writeup (snipped) it is presented as=20
"Documentation/IRQ-affinity" and here as IRQ-affinity.txt, should that=20
be "Documentation/IRQ-affinity.txt" in both cases?

> +For a single queue device, a typical RPS configuration would be to s=
et
> +the rps_cpus to the CPUs in the same cache domain of the interruptin=
g
> +CPU for a queue. If NUMA locality is not an issue, this could also b=
e
> +all CPUs in the system. At high interrupt rate, it might wise to exc=
lude
> +the interrupting CPU from the map since that already performs much w=
ork.
> +
> +For a multi-queue system, if RSS is configured so that a receive que=
ue

Multple hardware queue to help keep the "queues" separate in the mind o=
f=20
the reader?

> +is mapped to each CPU, then RPS is probably redundant and unnecessar=
y.
> +If there are fewer queues than CPUs, then RPS might be beneficial if=
 the

same.

> +rps_cpus for each queue are the ones that share the same cache domai=
n as
> +the interrupting CPU for the queue.
> +
> +RFS: Receive Flow Steering
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D
> +
> +While RPS steers packet solely based on hash, and thus generally
> +provides good load distribution, it does not take into account
> +application locality. This is accomplished by Receive Flow Steering

Should it also mention how an application thread of execution might be=20
processing requests on multiple connections, which themselves might not=
=20
normally hash to the same place?


> +=3D=3D RFS Configuration
> +
> +RFS is only available if the kernel flag CONFIG_RFS is enabled (on b=
y
> +default for smp). The functionality is disabled without any
> +configuration.

Perhaps just wordsmithing, but "This functionality remains disabled=20
until explicitly configured." seems clearer.

> +=3D=3D Accelerated RFS Configuration
> +
> +Accelerated RFS is only available if the kernel is compiled with
> +CONFIG_RFS_ACCEL and support is provided by the NIC device and drive=
r.
> +It also requires that ntuple filtering is enabled via ethtool.

Requires that ntuple filtering be enabled?

> +XPS: Transmit Packet Steering
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
> +
> +Transmit Packet Steering is a mechanism for intelligently selecting
> +which transmit queue to use when transmitting a packet on a multi-qu=
eue
> +device.

Minor nit.  Up to this point a multi-queue device was only described as=
=20
one with multiple receive queues.


> +Further Information
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +RPS and RFS were introduced in kernel 2.6.35. XPS was incorporated i=
nto
> +2.6.38. Original patches were submitted by Tom Herbert
> +(therbert@google.com)
> +
> +
> +Accelerated RFS was introduced in 2.6.35. Original patches were
> +submitted by Ben Hutchings (bhutchings@solarflare.com)
> +
> +Authors:
> +Tom Herbert (therbert@google.com)
> +Willem de Bruijn (willemb@google.com)
> +

While there are tidbits and indications in the descriptions of each=20
mechanism, a section with explicit description of when one would use th=
e=20
different mechanisms would be goodness.

rick jones
