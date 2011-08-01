From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH] net: add Documentation/networking/scaling.txt
Date: Mon, 1 Aug 2011 11:41:42 -0700
Message-ID: <20110801114142.544a109d.rdunlap@xenotime.net>
References: <alpine.DEB.2.00.1107312346350.28722@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-doc@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, willemb@google.com
To: Tom Herbert <therbert@google.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1107312346350.28722@pokey.mtv.corp.google.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 31 Jul 2011 23:56:26 -0700 (PDT) Tom Herbert wrote:

> Describes RSS, RPS, RFS, accelerated RFS, and XPS.
>=20
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  Documentation/networking/scaling.txt |  346 ++++++++++++++++++++++++=
++++++++++
>  1 files changed, 346 insertions(+), 0 deletions(-)
>  create mode 100644 Documentation/networking/scaling.txt
>=20
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
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=20
> +
> +This document describes a set of complementary techniques in the Lin=
ux
> +networking stack to increase parallelism and improve performance (in
> +throughput, latency, CPU utilization, etc.) for multi-processor syst=
ems.
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
> +and TCP ports of a packet. The most common hardware implementation o=
f
> +RSS uses a 128 entry indirection table where each entry stores a que=
ue

              128-entry

> +number. The receive queue for a packet is determined by masking out =
the
> +low order seven bits of the computed hash for the packet (usually a
> +Toeplitz hash), taking this number as a key into the indirection tab=
le
> +and reading the corresponding value.
> +
> +Some advanced NICs allow steering packets to queues based on
> +programmable filters. For example, webserver bound TCP port 80 packe=
ts
> +can be directed to their own receive queue. Such =E2=80=9Cn-tuple=E2=
=80=9D filters can
> +be configured from ethtool (--config-ntuple).
> +
> +=3D=3D RSS Configuration
> +
> +The driver for a multi-queue capable NIC typically provides a module
> +parameter specifying the number of hardware queues to configure. In =
the
> +bnx2x driver, for instance, this parameter is called num_queues. A
> +typical RSS configuration would be to have one receive queue for eac=
h
> +CPU if the device supports enough queues, or otherwise at least one =
for
> +each cache domain at a particular cache level (L1, L2, etc.).
> +
> +The indirection table of an RSS device, which resolves a queue by ma=
sked
> +hash, is usually programmed by the driver at initialization.  The
> +default mapping is to distribute the queues evenly in the table, but=
 the
> +indirection table can be retrieved and modified at runtime using eth=
tool
> +commands (--show-rxfh-indir and --set-rxfh-indir).  Modifying the
> +indirection table could be done to to give different queues differen=
t

                                   ^^drop one "to"

> +relative weights.=20

Drop trailing whitespace above and anywhere else that it's found. (5 pl=
aces)

I thought (long ago :) that multiple RX queues were for prioritizing tr=
affic,
but there is nothing here about using multi-queues for priorities.
Is that (no longer) done?


> +
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
> +non-negligible part of packet processing takes place in receive
> +interrupt handling, it is advantageous to spread receive interrupts
> +between CPUs. To manually adjust the IRQ affinity of each interrupt =
see
> +Documentation/IRQ-affinity. On some systems, the irqbalance daemon i=
s
> +running and will try to dynamically optimize this setting.

or (avoid a split infinitive):  will try to optimize this setting dynam=
ically.

> +
> +
> +RPS: Receive Packet Steering
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
> +
> +Receive Packet Steering (RPS) is logically a software implementation=
 of
> +RSS.  Being in software, it is necessarily called later in the datap=
ath.
> +Whereas RSS selects the queue and hence CPU that will run the hardwa=
re
> +interrupt handler, RPS selects the CPU to perform protocol processin=
g
> +above the interrupt handler.  This is accomplished by placing the pa=
cket
> +on the desired CPU=E2=80=99s backlog queue and waking up the CPU for=
 processing.
> +RPS has some advantages over RSS: 1) it can be used with any NIC, 2)
> +software filters can easily be added to handle new protocols, 3) it =
does
> +not increase hardware device interrupt rate (but does use IPIs).
> +
> +RPS is called during bottom half of the receive interrupt handler, w=
hen
> +a driver sends a packet up the network stack with netif_rx() or
> +netif_receive_skb(). These call the get_rps_cpu() function, which
> +selects the queue that should process a packet.
> +
> +The first step in determining the target CPU for RPS is to calculate=
 a
> +flow hash over the packet=E2=80=99s addresses or ports (2-tuple or 4=
-tuple hash
> +depending on the protocol). This serves as a consistent hash of the
> +associated flow of the packet. The hash is either provided by hardwa=
re
> +or will be computed in the stack. Capable hardware can pass the hash=
 in
> +the receive descriptor for the packet, this would usually be the sam=
e

                                  packet;

> +hash used for RSS (e.g. computed Toeplitz hash). The hash is saved i=
n
> +skb->rx_hash and can be used elsewhere in the stack as a hash of the
> +packet=E2=80=99s flow.
> +
> +Each receive hardware qeueue has associated list of CPUs which can

                                has an associated list (?)

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

s/flag/kconfig symbol/

> +for smp). Even when compiled in, it is disabled without any

   for SMP).

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
> +
> +For a single queue device, a typical RPS configuration would be to s=
et
> +the rps_cpus to the CPUs in the same cache domain of the interruptin=
g
> +CPU for a queue. If NUMA locality is not an issue, this could also b=
e
> +all CPUs in the system. At high interrupt rate, it might wise to exc=
lude

                                                   it might be wise

> +the interrupting CPU from the map since that already performs much w=
ork.
> +
> +For a multi-queue system, if RSS is configured so that a receive que=
ue
> +is mapped to each CPU, then RPS is probably redundant and unnecessar=
y.
> +If there are fewer queues than CPUs, then RPS might be beneficial if=
 the
> +rps_cpus for each queue are the ones that share the same cache domai=
n as
> +the interrupting CPU for the queue.
> +
> +RFS: Receive Flow Steering
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D
> +
> +While RPS steers packet solely based on hash, and thus generally

             steers packets

> +provides good load distribution, it does not take into account
> +application locality. This is accomplished by Receive Flow Steering
> +(RFS). The goal of RFS is to increase datacache hitrate by steering
> +kernel processing of packets to the CPU where the application thread
> +consuming the packet is running. RFS relies on the same RPS mechanis=
ms
> +to enqueue packets onto the backlog of another CPU and to wake that =
CPU.
> +
> +In RFS, packets are not forwarded directly by the value of their has=
h,
> +but the hash is used as index into a flow lookup table. This table m=
aps
> +flows to the CPUs where those flows are being processed. The flow ha=
sh
> +(see RPS section above) is used to calculate the index into this tab=
le.
> +The CPU recorded in each entry is the one which last processed the f=
low,
> +and if there is not a valid CPU for an entry, then packets mapped to
> +that entry are steered using plain RPS.
> +
> +To avoid out of order packets (ie. when scheduler moves a thread wit=
h

                                 (i.e., when the scheduler moves a thre=
ad that

> +outstanding receive packets on) there are two levels of flow tables =
used

has outstanding receive packets),

> +by RFS: rps_sock_flow_table and rps_dev_flow_table.
> +
> +rps_sock_table is a global flow table. Each table value is a CPU ind=
ex
> +and is populated by recvmsg and sendmsg (specifically, inet_recvmsg(=
),
> +inet_sendmsg(), inet_sendpage() and tcp_splice_read()). This table
> +contains the *desired* CPUs for flows.
> +
> +rps_dev_flow_table is specific to each hardware receive queue of eac=
h
> +device.  Each table value stores a CPU index and a counter. The CPU
> +index represents the *current* CPU that is assigned to processing th=
e
> +matching flows.
> +
> +The counter records the length of this CPU's backlog when a packet i=
n
> +this flow was last enqueued.  Each backlog queue has a head counter =
that
> +is incremented on dequeue. A tail counter is computed as head counte=
r +
> +queue length. In other words, the counter in rps_dev_flow_table[i]
> +records the last element in flow i that has been enqueued onto the
> +currently designated CPU for flow i (of course, entry i is actually
> +selected by hash and multiple flows may hash to the same entry i).=20
> +
> +And now the trick for avoiding out of order packets: when selecting =
the
> +CPU for packet processing (from get_rps_cpu()) the rps_sock_flow tab=
le
> +and the rps_dev_flow table of the queue that the packet was received=
 on
> +are compared.  If the desired CPU for the flow (found in the
> +rps_sock_flow table) matches the current CPU (found in the rps_dev_f=
low
> +table), the packet is enqueud onto that CPU=E2=80=99s backlog. If th=
ey differ,

                         enqueued

> +the current cpu is updated to match the desired CPU if one of the

s/cpu/CPU/ (globally as needed)

> +following is true:
> +
> +- The current CPU's queue head counter >=3D the recorded tail counte=
r
> +  value in rps_dev_flow[i]
> +- The current CPU is unset (equal to NR_CPUS)
> +- The current CPU is offline
> +
> +After this check, the packet is sent to the (possibly updated) curre=
nt
> +CPU.  These rules aim to ensure that a flow only moves to a new CPU =
when
> +there are no packets outstanding on the old CPU, as the outstanding
> +packets could arrive later than those about to be processed on the n=
ew
> +CPU.
> +
> +=3D=3D RFS Configuration
> +
> +RFS is only available if the kernel flag CONFIG_RFS is enabled (on b=
y

s/flag/kconfig symbol/

> +default for smp). The functionality is disabled without any

s/smp/SMP/

> +configuration. The number of entries in the global flow table is set
> +through:
> +
> + /proc/sys/net/core/rps_sock_flow_entries
> +
> +The number of entries in the per queue flow table are set through:

                                per-queue

> +
> + /sys/class/net/<dev>/queues/tx-<n>/rps_flow_cnt
> +
> +Both of these need to be set before RFS is enabled for a receive que=
ue.
> +Values for both of these are rounded up to the nearest power of two.=
 The
> +suggested flow count depends on the expected number active connectio=
ns

                                                number of

> +at any given time, which may be significantly less than the number o=
f
> +open connections. We have found that a value of 32768 for
> +rps_sock_flow_entries works fairly well on a moderately loaded serve=
r.
> +
> +For a single queue device, the rps_flow_cnt value for the single que=
ue
> +would normally be configured to the same value as rps_sock_flow_entr=
ies.
> +For a multi-queue device, the rps_flow_cnt for each queue might be
> +configured as rps_sock_flow_entries / N, where N is the number of
> +queues. So for instance, if rps_flow_entries is set to 32768 and the=
re
> +are 16 configured receive queues, rps_flow_cnt for each queue might =
be
> +configured as 2048.
> +
> +
> +Accelerated RFS
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +Accelerated RFS is to RFS what RSS is to RPS: a hardware-accelerated
> +load balancing mechanism that uses soft state to steer flows based o=
n
> +where the thread consuming the packets of each flow is running.
> +Accelerated RFS should perform better than RFS since packets are sen=
t
> +directly to a CPU local to the thread consuming the data. The target=
 CPU
> +will either be the same CPU where the application runs, or at least =
a
> +CPU which is local to the application thread=E2=80=99s CPU in the ca=
che
> +hierarchy.=20
> +
> +To enable accelerated RFS, the networking stack calls the
> +ndo_rx_flow_steer driver function to communicate the desired hardwar=
e
> +queue for packets matching a particular flow. The network stack
> +automatically calls this function every time a flow entry in
> +rps_dev_flow_table is updated. The driver in turn uses a device spec=
ific

                                                            device-spec=
ific

> +method to program the NIC to steer the packets.
> +
> +The hardware queue for a flow is derived from the CPU recorded in
> +rps_dev_flow_table. The stack consults a CPU to hardware queue map w=
hich

                                            CPU-to-hardware-queue map

> +is maintained by the NIC driver. This is an autogenerated reverse ma=
p of
> +the IRQ affinity table shown by /proc/interrupts. Drivers can use
> +functions in the cpu_rmap (=E2=80=9Ccpu affinitiy reverse map=E2=80=9D=
) kernel library
> +to populate the map. For each CPU, the corresponding queue in the ma=
p is
> +set to be one whose processing CPU is closest in cache locality.
> +
> +=3D=3D Accelerated RFS Configuration
> +
> +Accelerated RFS is only available if the kernel is compiled with
> +CONFIG_RFS_ACCEL and support is provided by the NIC device and drive=
r.
> +It also requires that ntuple filtering is enabled via ethtool. The m=
ap
> +of CPU to queues is automatically deduced from the IRQ affinities
> +configured for each receive queue by the driver, so no additional
> +configuration should be necessary.
> +
> +XPS: Transmit Packet Steering
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
> +
> +Transmit Packet Steering is a mechanism for intelligently selecting
> +which transmit queue to use when transmitting a packet on a multi-qu=
eue
> +device. To accomplish this, a mapping from CPU to hardware queue(s) =
is
> +recorded. The goal of this mapping is usually to assign queues
> +exclusively to a subset of CPUs, where the transmit completions for
> +these queues are processed on a CPU within this set. This choice
> +provides two benefits. First, contention on the device queue lock is
> +significantly reduced since fewer CPUs contend for the same queue
> +(contention can be eliminated completely if each CPU has its own
> +transmit queue).  Secondly, cache miss rate on transmit completion i=
s
> +reduced, in particular for data cache lines that hold the sk_buff
> +structures.
> +
> +XPS is configured per transmit queue by setting a bitmap of CPUs tha=
t
> +may use that queue to transmit. The reverse mapping, from CPUs to
> +transmit queues, is computed and maintained for each network device.
> +When transmitting the first packet in a flow, the function
> +get_xps_queue() is called to select a queue.  This function uses the=
 ID
> +of the running CPU as a key into the CPU to queue lookup table. If t=
he

                                        CPU-to-queue

> +ID matches a single queue, that is used for transmission.  If multip=
le
> +queues match, one is selected by using the flow hash to compute an i=
ndex
> +into the set.
> +
> +The queue chosen for transmitting a particular flow is saved in the
> +corresponding socket structure for the flow (e.g. a TCP connection).
> +This transmit queue is used for subsequent packets sent on the flow =
to
> +prevent out of order (ooo) packets. The choice also amortizes the co=
st
> +of calling get_xps_queues() over all packets in the connection. To a=
void
> +ooo packets, the queue for a flow can subsequently only be changed i=
f
> +skb->ooo_okay is set for a packet in the flow. This flag indicates t=
hat
> +there are no outstanding packets in the flow, so the transmit queue =
can
> +change without the risk of generating out of order packets. The
> +transport layer is responsible for setting ooo_okay appropriately. T=
CP,
> +for instance, sets the flag when all data for a connection has been
> +acknowledged.
> +
> +
> +=3D=3D XPS Configuration
> +
> +XPS is only available if the kernel flag CONFIG_XPS is enabled (on b=
y

s/flag/kconfig symbol/

> +default for smp). The functionality is disabled without any

s/smp/SMP/

> +configuration, in which case the the transmit queue for a packet is
> +selected by using a flow hash as an index into the set of all transm=
it
> +queues for the device. To enable XPS, the bitmap of CPUs that may us=
e a
> +transmit queue is configured using the sysfs file entry:
> +
> +/sys/class/net/<dev>/queues/tx-<n>/xps_cpus
> +
> +XPS is disabled when it is zero (the default). IRQ-affinity.txt expl=
ains
> +how CPUs are assigned to the bitmap.=20
> +
> +For a network device with a single transmission queue, XPS configura=
tion
> +has no effect, since there is no choice in this case. In a multi-que=
ue
> +system, XPS is usually configured so that each CPU maps onto one que=
ue.
> +If there are as many queues as there are CPUs in the system, then ea=
ch
> +queue can also map onto one CPU, resulting in exclusive pairings tha=
t
> +experience no contention. If there are fewer queues than CPUs, then =
the
> +best CPUs to share a given queue are probably those that share the c=
ache
> +with the CPU that processes transmit completions for that queue
> +(transmit interrupts).
> +
> +
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
> --=20


Very nice writeup.  Thanks.

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your cod=
e ***
