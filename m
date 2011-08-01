From: Tom Herbert <therbert@google.com>
Subject: [PATCH] net: add Documentation/networking/scaling.txt
Date: Sun, 31 Jul 2011 23:56:26 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1107312346350.28722@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="313268064-621198655-1312181786=:28722"
Cc: willemb@google.com
To: rdunlap@xenotime.net, linux-doc@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:30695 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751376Ab1HAG4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2011 02:56:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--313268064-621198655-1312181786=:28722
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

Describes RSS, RPS, RFS, accelerated RFS, and XPS.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 Documentation/networking/scaling.txt |  346 ++++++++++++++++++++++++++++++++++
 1 files changed, 346 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/networking/scaling.txt

diff --git a/Documentation/networking/scaling.txt b/Documentation/networking/scaling.txt
new file mode 100644
index 0000000..aa51f0f
--- /dev/null
+++ b/Documentation/networking/scaling.txt
@@ -0,0 +1,346 @@
+Scaling in the Linux Networking Stack
+
+
+Introduction
+============ 
+
+This document describes a set of complementary techniques in the Linux
+networking stack to increase parallelism and improve performance (in
+throughput, latency, CPU utilization, etc.) for multi-processor systems.
+
+The following technologies are described:
+
+  RSS: Receive Side Scaling
+  RPS: Receive Packet Steering
+  RFS: Receive Flow Steering
+  Accelerated Receive Flow Steering
+  XPS: Transmit Packet Steering
+
+
+RSS: Receive Side Scaling
+=========================
+
+Contemporary NICs support multiple receive queues (multi-queue), which
+can be used to distribute packets amongst CPUs for processing. The NIC
+distributes packets by applying a filter to each packet to assign it to
+one of a small number of logical flows.  Packets for each flow are
+steered to a separate receive queue, which in turn can be processed by
+separate CPUs.  This mechanism is generally known as “Receive-side
+Scaling” (RSS).
+
+The filter used in RSS is typically a hash function over the network or
+transport layer headers-- for example, a 4-tuple hash over IP addresses
+and TCP ports of a packet. The most common hardware implementation of
+RSS uses a 128 entry indirection table where each entry stores a queue
+number. The receive queue for a packet is determined by masking out the
+low order seven bits of the computed hash for the packet (usually a
+Toeplitz hash), taking this number as a key into the indirection table
+and reading the corresponding value.
+
+Some advanced NICs allow steering packets to queues based on
+programmable filters. For example, webserver bound TCP port 80 packets
+can be directed to their own receive queue. Such “n-tuple” filters can
+be configured from ethtool (--config-ntuple).
+
+== RSS Configuration
+
+The driver for a multi-queue capable NIC typically provides a module
+parameter specifying the number of hardware queues to configure. In the
+bnx2x driver, for instance, this parameter is called num_queues. A
+typical RSS configuration would be to have one receive queue for each
+CPU if the device supports enough queues, or otherwise at least one for
+each cache domain at a particular cache level (L1, L2, etc.).
+
+The indirection table of an RSS device, which resolves a queue by masked
+hash, is usually programmed by the driver at initialization.  The
+default mapping is to distribute the queues evenly in the table, but the
+indirection table can be retrieved and modified at runtime using ethtool
+commands (--show-rxfh-indir and --set-rxfh-indir).  Modifying the
+indirection table could be done to to give different queues different
+relative weights. 
+
+== RSS IRQ Configuration
+
+Each receive queue has a separate IRQ associated with it. The NIC
+triggers this to notify a CPU when new packets arrive on the given
+queue. The signaling path for PCIe devices uses message signaled
+interrupts (MSI-X), that can route each interrupt to a particular CPU.
+The active mapping of queues to IRQs can be determined from
+/proc/interrupts. By default, all IRQs are routed to CPU0.  Because a
+non-negligible part of packet processing takes place in receive
+interrupt handling, it is advantageous to spread receive interrupts
+between CPUs. To manually adjust the IRQ affinity of each interrupt see
+Documentation/IRQ-affinity. On some systems, the irqbalance daemon is
+running and will try to dynamically optimize this setting.
+
+
+RPS: Receive Packet Steering
+============================
+
+Receive Packet Steering (RPS) is logically a software implementation of
+RSS.  Being in software, it is necessarily called later in the datapath.
+Whereas RSS selects the queue and hence CPU that will run the hardware
+interrupt handler, RPS selects the CPU to perform protocol processing
+above the interrupt handler.  This is accomplished by placing the packet
+on the desired CPU’s backlog queue and waking up the CPU for processing.
+RPS has some advantages over RSS: 1) it can be used with any NIC, 2)
+software filters can easily be added to handle new protocols, 3) it does
+not increase hardware device interrupt rate (but does use IPIs).
+
+RPS is called during bottom half of the receive interrupt handler, when
+a driver sends a packet up the network stack with netif_rx() or
+netif_receive_skb(). These call the get_rps_cpu() function, which
+selects the queue that should process a packet.
+
+The first step in determining the target CPU for RPS is to calculate a
+flow hash over the packet’s addresses or ports (2-tuple or 4-tuple hash
+depending on the protocol). This serves as a consistent hash of the
+associated flow of the packet. The hash is either provided by hardware
+or will be computed in the stack. Capable hardware can pass the hash in
+the receive descriptor for the packet, this would usually be the same
+hash used for RSS (e.g. computed Toeplitz hash). The hash is saved in
+skb->rx_hash and can be used elsewhere in the stack as a hash of the
+packet’s flow.
+
+Each receive hardware qeueue has associated list of CPUs which can
+process packets received on the queue for RPS.  For each received
+packet, an index into the list is computed from the flow hash modulo the
+size of the list.  The indexed CPU is the target for processing the
+packet, and the packet is queued to the tail of that CPU’s backlog
+queue. At the end of the bottom half routine, inter-processor interrupts
+(IPIs) are sent to any CPUs for which packets have been queued to their
+backlog queue. The IPI wakes backlog processing on the remote CPU, and
+any queued packets are then processed up the networking stack. Note that
+the list of CPUs can be configured separately for each hardware receive
+queue.
+
+== RPS Configuration
+
+RPS requires a kernel compiled with the CONFIG_RPS flag (on by default
+for smp). Even when compiled in, it is disabled without any
+configuration. The list of CPUs to which RPS may forward traffic can be
+configured for each receive queue using the sysfs file entry:
+
+ /sys/class/net/<dev>/queues/rx-<n>/rps_cpus
+
+This file implements a bitmap of CPUs. RPS is disabled when it is zero
+(the default), in which case packets are processed on the interrupting
+CPU.  IRQ-affinity.txt explains how CPUs are assigned to the bitmap.
+
+For a single queue device, a typical RPS configuration would be to set
+the rps_cpus to the CPUs in the same cache domain of the interrupting
+CPU for a queue. If NUMA locality is not an issue, this could also be
+all CPUs in the system. At high interrupt rate, it might wise to exclude
+the interrupting CPU from the map since that already performs much work.
+
+For a multi-queue system, if RSS is configured so that a receive queue
+is mapped to each CPU, then RPS is probably redundant and unnecessary.
+If there are fewer queues than CPUs, then RPS might be beneficial if the
+rps_cpus for each queue are the ones that share the same cache domain as
+the interrupting CPU for the queue.
+
+RFS: Receive Flow Steering
+==========================
+
+While RPS steers packet solely based on hash, and thus generally
+provides good load distribution, it does not take into account
+application locality. This is accomplished by Receive Flow Steering
+(RFS). The goal of RFS is to increase datacache hitrate by steering
+kernel processing of packets to the CPU where the application thread
+consuming the packet is running. RFS relies on the same RPS mechanisms
+to enqueue packets onto the backlog of another CPU and to wake that CPU.
+
+In RFS, packets are not forwarded directly by the value of their hash,
+but the hash is used as index into a flow lookup table. This table maps
+flows to the CPUs where those flows are being processed. The flow hash
+(see RPS section above) is used to calculate the index into this table.
+The CPU recorded in each entry is the one which last processed the flow,
+and if there is not a valid CPU for an entry, then packets mapped to
+that entry are steered using plain RPS.
+
+To avoid out of order packets (ie. when scheduler moves a thread with
+outstanding receive packets on) there are two levels of flow tables used
+by RFS: rps_sock_flow_table and rps_dev_flow_table.
+
+rps_sock_table is a global flow table. Each table value is a CPU index
+and is populated by recvmsg and sendmsg (specifically, inet_recvmsg(),
+inet_sendmsg(), inet_sendpage() and tcp_splice_read()). This table
+contains the *desired* CPUs for flows.
+
+rps_dev_flow_table is specific to each hardware receive queue of each
+device.  Each table value stores a CPU index and a counter. The CPU
+index represents the *current* CPU that is assigned to processing the
+matching flows.
+
+The counter records the length of this CPU's backlog when a packet in
+this flow was last enqueued.  Each backlog queue has a head counter that
+is incremented on dequeue. A tail counter is computed as head counter +
+queue length. In other words, the counter in rps_dev_flow_table[i]
+records the last element in flow i that has been enqueued onto the
+currently designated CPU for flow i (of course, entry i is actually
+selected by hash and multiple flows may hash to the same entry i). 
+
+And now the trick for avoiding out of order packets: when selecting the
+CPU for packet processing (from get_rps_cpu()) the rps_sock_flow table
+and the rps_dev_flow table of the queue that the packet was received on
+are compared.  If the desired CPU for the flow (found in the
+rps_sock_flow table) matches the current CPU (found in the rps_dev_flow
+table), the packet is enqueud onto that CPU’s backlog. If they differ,
+the current cpu is updated to match the desired CPU if one of the
+following is true:
+
+- The current CPU's queue head counter >= the recorded tail counter
+  value in rps_dev_flow[i]
+- The current CPU is unset (equal to NR_CPUS)
+- The current CPU is offline
+
+After this check, the packet is sent to the (possibly updated) current
+CPU.  These rules aim to ensure that a flow only moves to a new CPU when
+there are no packets outstanding on the old CPU, as the outstanding
+packets could arrive later than those about to be processed on the new
+CPU.
+
+== RFS Configuration
+
+RFS is only available if the kernel flag CONFIG_RFS is enabled (on by
+default for smp). The functionality is disabled without any
+configuration. The number of entries in the global flow table is set
+through:
+
+ /proc/sys/net/core/rps_sock_flow_entries
+
+The number of entries in the per queue flow table are set through:
+
+ /sys/class/net/<dev>/queues/tx-<n>/rps_flow_cnt
+
+Both of these need to be set before RFS is enabled for a receive queue.
+Values for both of these are rounded up to the nearest power of two. The
+suggested flow count depends on the expected number active connections
+at any given time, which may be significantly less than the number of
+open connections. We have found that a value of 32768 for
+rps_sock_flow_entries works fairly well on a moderately loaded server.
+
+For a single queue device, the rps_flow_cnt value for the single queue
+would normally be configured to the same value as rps_sock_flow_entries.
+For a multi-queue device, the rps_flow_cnt for each queue might be
+configured as rps_sock_flow_entries / N, where N is the number of
+queues. So for instance, if rps_flow_entries is set to 32768 and there
+are 16 configured receive queues, rps_flow_cnt for each queue might be
+configured as 2048.
+
+
+Accelerated RFS
+===============
+
+Accelerated RFS is to RFS what RSS is to RPS: a hardware-accelerated
+load balancing mechanism that uses soft state to steer flows based on
+where the thread consuming the packets of each flow is running.
+Accelerated RFS should perform better than RFS since packets are sent
+directly to a CPU local to the thread consuming the data. The target CPU
+will either be the same CPU where the application runs, or at least a
+CPU which is local to the application thread’s CPU in the cache
+hierarchy. 
+
+To enable accelerated RFS, the networking stack calls the
+ndo_rx_flow_steer driver function to communicate the desired hardware
+queue for packets matching a particular flow. The network stack
+automatically calls this function every time a flow entry in
+rps_dev_flow_table is updated. The driver in turn uses a device specific
+method to program the NIC to steer the packets.
+
+The hardware queue for a flow is derived from the CPU recorded in
+rps_dev_flow_table. The stack consults a CPU to hardware queue map which
+is maintained by the NIC driver. This is an autogenerated reverse map of
+the IRQ affinity table shown by /proc/interrupts. Drivers can use
+functions in the cpu_rmap (“cpu affinitiy reverse map”) kernel library
+to populate the map. For each CPU, the corresponding queue in the map is
+set to be one whose processing CPU is closest in cache locality.
+
+== Accelerated RFS Configuration
+
+Accelerated RFS is only available if the kernel is compiled with
+CONFIG_RFS_ACCEL and support is provided by the NIC device and driver.
+It also requires that ntuple filtering is enabled via ethtool. The map
+of CPU to queues is automatically deduced from the IRQ affinities
+configured for each receive queue by the driver, so no additional
+configuration should be necessary.
+
+XPS: Transmit Packet Steering
+=============================
+
+Transmit Packet Steering is a mechanism for intelligently selecting
+which transmit queue to use when transmitting a packet on a multi-queue
+device. To accomplish this, a mapping from CPU to hardware queue(s) is
+recorded. The goal of this mapping is usually to assign queues
+exclusively to a subset of CPUs, where the transmit completions for
+these queues are processed on a CPU within this set. This choice
+provides two benefits. First, contention on the device queue lock is
+significantly reduced since fewer CPUs contend for the same queue
+(contention can be eliminated completely if each CPU has its own
+transmit queue).  Secondly, cache miss rate on transmit completion is
+reduced, in particular for data cache lines that hold the sk_buff
+structures.
+
+XPS is configured per transmit queue by setting a bitmap of CPUs that
+may use that queue to transmit. The reverse mapping, from CPUs to
+transmit queues, is computed and maintained for each network device.
+When transmitting the first packet in a flow, the function
+get_xps_queue() is called to select a queue.  This function uses the ID
+of the running CPU as a key into the CPU to queue lookup table. If the
+ID matches a single queue, that is used for transmission.  If multiple
+queues match, one is selected by using the flow hash to compute an index
+into the set.
+
+The queue chosen for transmitting a particular flow is saved in the
+corresponding socket structure for the flow (e.g. a TCP connection).
+This transmit queue is used for subsequent packets sent on the flow to
+prevent out of order (ooo) packets. The choice also amortizes the cost
+of calling get_xps_queues() over all packets in the connection. To avoid
+ooo packets, the queue for a flow can subsequently only be changed if
+skb->ooo_okay is set for a packet in the flow. This flag indicates that
+there are no outstanding packets in the flow, so the transmit queue can
+change without the risk of generating out of order packets. The
+transport layer is responsible for setting ooo_okay appropriately. TCP,
+for instance, sets the flag when all data for a connection has been
+acknowledged.
+
+
+== XPS Configuration
+
+XPS is only available if the kernel flag CONFIG_XPS is enabled (on by
+default for smp). The functionality is disabled without any
+configuration, in which case the the transmit queue for a packet is
+selected by using a flow hash as an index into the set of all transmit
+queues for the device. To enable XPS, the bitmap of CPUs that may use a
+transmit queue is configured using the sysfs file entry:
+
+/sys/class/net/<dev>/queues/tx-<n>/xps_cpus
+
+XPS is disabled when it is zero (the default). IRQ-affinity.txt explains
+how CPUs are assigned to the bitmap. 
+
+For a network device with a single transmission queue, XPS configuration
+has no effect, since there is no choice in this case. In a multi-queue
+system, XPS is usually configured so that each CPU maps onto one queue.
+If there are as many queues as there are CPUs in the system, then each
+queue can also map onto one CPU, resulting in exclusive pairings that
+experience no contention. If there are fewer queues than CPUs, then the
+best CPUs to share a given queue are probably those that share the cache
+with the CPU that processes transmit completions for that queue
+(transmit interrupts).
+
+
+Further Information
+===================
+RPS and RFS were introduced in kernel 2.6.35. XPS was incorporated into
+2.6.38. Original patches were submitted by Tom Herbert
+(therbert@google.com)
+
+
+Accelerated RFS was introduced in 2.6.35. Original patches were
+submitted by Ben Hutchings (bhutchings@solarflare.com)
+
+Authors:
+Tom Herbert (therbert@google.com)
+Willem de Bruijn (willemb@google.com)
+
-- 
1.7.3.1

--313268064-621198655-1312181786=:28722--
