From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH 2/2] net: minor update to Documentation/networking/scaling.txt
Date: Thu, 11 Aug 2011 20:41:48 -0400
Message-ID: <4E4476CC.5050900@google.com>
References: <1312899648.5889.14.camel@gopher.nyc.corp.google.com> <4E418030.2010102@hp.com> <4E44752D.1080905@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: rdunlap@xenotime.net, linux-doc@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org, therbert@google.com
To: Rick Jones <rick.jones2@hp.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <4E44752D.1080905@google.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Incorporate last comments about hyperthreading, interrupt coalescing and
the definition of cache domains into the network scaling document scaling.txt

Signed-off-by: Willem de Bruijn <willemb@google.com>

---
 Documentation/networking/scaling.txt |   23 +++++++++++++++--------
 1 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/Documentation/networking/scaling.txt b/Documentation/networking/scaling.txt
index 3da03c3..6197126 100644
--- a/Documentation/networking/scaling.txt
+++ b/Documentation/networking/scaling.txt
@@ -52,7 +52,8 @@ module parameter for specifying the number of hardware queues to
 configure. In the bnx2x driver, for instance, this parameter is called
 num_queues. A typical RSS configuration would be to have one receive queue
 for each CPU if the device supports enough queues, or otherwise at least
-one for each cache domain at a particular cache level (L1, L2, etc.).
+one for each memory domain, where a memory domain is a set of CPUs that
+share a particular memory level (L1, L2, NUMA node, etc.).
 
 The indirection table of an RSS device, which resolves a queue by masked
 hash, is usually programmed by the driver at initialization. The
@@ -82,11 +83,17 @@ RSS should be enabled when latency is a concern or whenever receive
 interrupt processing forms a bottleneck. Spreading load between CPUs
 decreases queue length. For low latency networking, the optimal setting
 is to allocate as many queues as there are CPUs in the system (or the
-NIC maximum, if lower). Because the aggregate number of interrupts grows
-with each additional queue, the most efficient high-rate configuration
+NIC maximum, if lower). The most efficient high-rate configuration
 is likely the one with the smallest number of receive queues where no
-CPU that processes receive interrupts reaches 100% utilization. Per-cpu
-load can be observed using the mpstat utility.
+receive queue overflows due to a saturated CPU, because in default
+mode with interrupt coalescing enabled, the aggregate number of
+interrupts (and thus work) grows with each additional queue.
+
+Per-cpu load can be observed using the mpstat utility, but note that on
+processors with hyperthreading (HT), each hyperthread is represented as
+a separate CPU. For interrupt handling, HT has shown no benefit in
+initial tests, so limit the number of queues to the number of CPU cores
+in the system.
 
 
 RPS: Receive Packet Steering
@@ -145,7 +152,7 @@ the bitmap.
 == Suggested Configuration
 
 For a single queue device, a typical RPS configuration would be to set
-the rps_cpus to the CPUs in the same cache domain of the interrupting
+the rps_cpus to the CPUs in the same memory domain of the interrupting
 CPU. If NUMA locality is not an issue, this could also be all CPUs in
 the system. At high interrupt rate, it might be wise to exclude the
 interrupting CPU from the map since that already performs much work.
@@ -154,7 +161,7 @@ For a multi-queue system, if RSS is configured so that a hardware
 receive queue is mapped to each CPU, then RPS is probably redundant
 and unnecessary. If there are fewer hardware queues than CPUs, then
 RPS might be beneficial if the rps_cpus for each queue are the ones that
-share the same cache domain as the interrupting CPU for that queue.
+share the same memory domain as the interrupting CPU for that queue.
 
 
 RFS: Receive Flow Steering
@@ -326,7 +333,7 @@ The queue chosen for transmitting a particular flow is saved in the
 corresponding socket structure for the flow (e.g. a TCP connection).
 This transmit queue is used for subsequent packets sent on the flow to
 prevent out of order (ooo) packets. The choice also amortizes the cost
-of calling get_xps_queues() over all packets in the connection. To avoid
+of calling get_xps_queues() over all packets in the flow. To avoid
 ooo packets, the queue for a flow can subsequently only be changed if
 skb->ooo_okay is set for a packet in the flow. This flag indicates that
 there are no outstanding packets in the flow, so the transmit queue can
-- 
1.7.3.1
