From: =?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@gmail.com>
Subject: [RFC PATCH 00/14] Introducing AF_PACKET V4 support
Date: Tue, 31 Oct 2017 13:41:31 +0100
Message-ID: <20171031124145.9667-1-bjorn.topel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@intel.com>,
        jesse.brandeburg@intel.com, anjali.singhai@intel.com,
        rami.rosen@intel.com, jeffrey.b.shaw@intel.com,
        ferruh.yigit@intel.com, qi.z.zhang@intel.com
To: bjorn.topel@gmail.com, magnus.karlsson@intel.com,
        alexander.h.duyck@intel.com, alexander.duyck@gmail.com,
        john.fastabend@gmail.com, ast@fb.com, brouer@redhat.com,
        michael.lundkvist@ericsson.com, ravineet.singh@ericsson.com,
        daniel@iogearbox.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:38316 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751050AbdJaMmH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 08:42:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Björn Töpel <bjorn.topel@intel.com>

This RFC introduces AF_PACKET_V4 and PACKET_ZEROCOPY that are
optimized for high performance packet processing and zero-copy
semantics. Throughput improvements can be up to 40x compared to V2 and
V3 for the micro benchmarks included. Would be great to get your
feedback on it.

The main difference between V4 and V2/V3 is that TX and RX descriptors
are separated from packet buffers. An RX or TX descriptor points to a
data buffer in a packet buffer area. RX and TX can share the same
packet buffer so that a packet does not have to be copied between RX
and TX. Moreover, if a packet needs to be kept for a while due to a
possible retransmit, then the descriptor that points to that packet
buffer can be changed to point to another buffer and reused right
away. This again avoids copying data.

The RX and TX descriptor rings are registered with the setsockopts
PACKET_RX_RING and PACKET_TX_RING, as usual. The packet buffer area is
allocated by user space and registered with the kernel using the new
PACKET_MEMREG setsockopt. All these three areas are shared between
user space and kernel space.

When V4 executes like this, we say that it executes in
"copy-mode". Each packet is sent to the Linux stack and a copy of it
is sent to user space, so V4 behaves in the same way as V2 and V3. All
syscalls operating on file descriptors should just work as if it was
V2 or V3. However, when the new PACKET_ZEROCOPY setsockopt is called,
V4 starts to operate in true zero-copy mode. In this mode, the
networking HW (or SW driver if it is a virtual driver like veth)
DMAs/puts packets straight into the packet buffer that is shared
between user space and kernel space. The RX and TX descriptor queues
of the networking HW are NOT shared to user space. Only the kernel can
read and write these and it is the kernel drivers responsibility to
translate these HW specific descriptors to the HW agnostic ones in the
V4 virtual descriptor rings that user space sees. This way, a
malicious user space program cannot mess with the networking HW.

The PACKET_ZEROCOPY setsockopt acts on a queue pair (channel in
ethtool speak), so one needs to steer the traffic to the zero-copy
enabled queue pair. Which queue to use, is up to the user.

For an untrusted application, HW packet steering to a specific queue
pair (the one associated with the application) is a requirement, as
the application would otherwise be able to see other user space
processes' packets. If the HW cannot support the required packet
steering, packets need to be DMA:ed into non user-space visible kernel
buffers and from there copied out to user space. This RFC only
addresses NIC HW with packet steering capabilities.

PACKET_ZEROCOPY comes with "XDP batteries included", so XDP programs
will be executed for zero-copy enabled queues. We're also suggesting
adding a new XDP action, XDP_PASS_TO_KERNEL, to pass copies to the
kernel stack instead of the V4 user space queue in zero-copy mode.

There's a tpbench benchmarking/test application included. Say that
you'd like your UDP traffic from port 4242 to end up in queue 16, that
we'll enable zero-copy on. Here, we use ethtool for this:

      ethtool -N p3p2 rx-flow-hash udp4 fn
      ethtool -N p3p2 flow-type udp4 src-port 4242 dst-port 4242 \
          action 16

Running the benchmark in zero-copy mode can then be done using:

      tpbench -i p3p2 --rxdrop --zerocopy 17

Note that the --zerocopy command-line argument is one-based, and not
zero-based.

We've run some benchmarks on a dual socket system with two Broadwell
E5 2660 @ 2.0 GHz with hyperthreading turned off. Each socket has 14
cores which gives a total of 28, but only two cores are used in these
experiments. One for Tx/Rx and one for the user space application. The
memory is DDR4 @ 1067 MT/s and the size of each DIMM is 8192MB and
with 8 of those DIMMs in the system we have 64 GB of total memory. The
compiler used is gcc version 5.4.0 20160609. The NIC is an Intel I40E
40Gbit/s using the i40e driver.

Below are the results in Mpps of the I40E NIC benchmark runs for 64
byte packets, generated by commercial packet generator HW that is
generating packets at full 40 Gbit/s line rate.

Benchmark   V2     V3     V4     V4+ZC
rxdrop      0.67   0.73   0.74   33.7
txpush      0.98   0.98   0.91   19.6
l2fwd       0.66   0.71   0.67   15.5

The results are generated using the "bench_all.sh" script.

We'll do a presentation on AF_PACKET V4 in NetDev 2.2 [1] Seoul,
Korea, and our paper with complete benchmarks will be released shortly
on the NetDev 2.2 site.

We based this patch set on net-next commit e1ea2f9856b7 ("Merge
git://git.kernel.org/pub/scm/linux/kernel/git/davem/net").

Please focus your review on:

* The V4 user space interface
* PACKET_ZEROCOPY and its semantics
* Packet array interface
* XDP semantics when excuting in zero-copy mode (user space passed
  buffers)
* XDP_PASS_TO_KERNEL semantics

To do:

* Investigate the user-space ring structure’s performance problems
* Continue the XDP integration into packet arrays
* Optimize performance
* SKB <-> V4 conversions in tp4a_populate & tp4a_flush
* Packet buffer is unnecessarily pinned for virtual devices
* Support shared packet buffers
* Unify V4 and SKB receive path in I40E driver
* Support for packets spanning multiple frames
* Disassociate the packet array implementation from the V4 queue
  structure

We would really like to thank the reviewers of the limited
distribution RFC for all their comments that have helped improve the
interfaces and the code significantly: Alexei Starovoitov, Alexander
Duyck, Jesper Dangaard Brouer, and John Fastabend. The internal team
at Intel that has been helping out reviewing code, writing tests, and
sanity checking our ideas: Rami Rosen, Jeff Shaw, Ferruh Yigit, and Qi
Zhang, your participation has really helped.

Thanks: Björn and Magnus

[1] https://www.netdevconf.org/2.2/

Björn Töpel (7):
  packet: introduce AF_PACKET V4 userspace API
  packet: implement PACKET_MEMREG setsockopt
  packet: enable AF_PACKET V4 rings
  packet: wire up zerocopy for AF_PACKET V4
  i40e: AF_PACKET V4 ndo_tp4_zerocopy Rx support
  i40e: AF_PACKET V4 ndo_tp4_zerocopy Tx support
  samples/tpacket4: added tpbench

Magnus Karlsson (7):
  packet: enable Rx for AF_PACKET V4
  packet: enable Tx support for AF_PACKET V4
  netdevice: add AF_PACKET V4 zerocopy ops
  veth: added support for PACKET_ZEROCOPY
  samples/tpacket4: added veth support
  i40e: added XDP support for TP4 enabled queue pairs
  xdp: introducing XDP_PASS_TO_KERNEL for PACKET_ZEROCOPY use

 drivers/net/ethernet/intel/i40e/i40e.h         |    3 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c |    9 +
 drivers/net/ethernet/intel/i40e/i40e_main.c    |  837 ++++++++++++-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c    |  582 ++++++++-
 drivers/net/ethernet/intel/i40e/i40e_txrx.h    |   38 +
 drivers/net/veth.c                             |  174 +++
 include/linux/netdevice.h                      |   16 +
 include/linux/tpacket4.h                       | 1502 ++++++++++++++++++++++++
 include/uapi/linux/bpf.h                       |    1 +
 include/uapi/linux/if_packet.h                 |   65 +-
 net/packet/af_packet.c                         | 1252 +++++++++++++++++---
 net/packet/internal.h                          |    9 +
 samples/tpacket4/Makefile                      |   12 +
 samples/tpacket4/bench_all.sh                  |   28 +
 samples/tpacket4/tpbench.c                     | 1390 ++++++++++++++++++++++
 15 files changed, 5674 insertions(+), 244 deletions(-)
 create mode 100644 include/linux/tpacket4.h
 create mode 100644 samples/tpacket4/Makefile
 create mode 100755 samples/tpacket4/bench_all.sh
 create mode 100644 samples/tpacket4/tpbench.c

-- 
2.11.0
