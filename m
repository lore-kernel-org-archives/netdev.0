From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next RFC 00/10] socket sendmsg MSG_ZEROCOPY
Date: Thu, 20 Aug 2015 10:36:39 -0400
Message-ID: <1440081408-12302-1-git-send-email-willemb@google.com>
Cc: mst@redhat.com, jasowang@redhat.com,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:35132 "EHLO
	mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751665AbbHTOgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 10:36:53 -0400
Received: by qkbm65 with SMTP id m65so16085380qkb.2
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 07:36:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Add zerocopy socket sendmsg() support with flag MSG_ZEROCOPY.
Implement the feature for TCP, UDP, RAW and packet sockets. This is
a generalization of a previous packet socket RFC patch

  http://patchwork.ozlabs.org/patch/413184/

On a send call with MSG_ZEROCOPY, the kernel pins the user pages and
creates skbuff fragments directly from these pages. On tx completion,
it notifies the socket owner that it is safe to modify memory by
queuing a completion notification onto the socket error queue.

The kernel already implements such copy avoidance with vmsplice plus
splice and with ubuf_info for tun and virtio. Extend the second
with features required by TCP and others: reference counting to
support cloning (retransmit queue) and shared fragments (GSO) and
notification coalescing to handle corking.

Notifications are queued onto the socket error queue as a range
range [N, N+m], where N is a per-socket counter incremented on each
successful zerocopy send call.

* Performance

The below table shows cycles reported by perf for a netperf process
sending a single 10 Gbps TCP_STREAM. The first three columns show
Mcycles spent in the netperf process context. The second three columns
show time spent systemwide (-a -C A,B) on the two cpus that run the
process and interrupt handler. Reported is the median of 3 runs. std
is a standard netperf, zc uses zerocopy and % is the ratio.

NETPERF=./netperf -t TCP_STREAM -H $host -T 2 -- -m $size

perf stat -e cycles $NETPERF
perf stat -C 2,3 -a -e cycles $NETPERF

	--process cycles--	----cpu cycles----
	   std	   zc	 %	std	    zc	 %
4K	11,060	5,615	51	20,517	19,694	96
16K	 8,706	2,045	23	17,913	15,549	86
64K	 8,105	1,152	14	17,592	12,167	69
256K	 8,087	 926	11	16,953	11,279	66
1M	 7,955	 826	10	17,228	10,655	62

Perf record indicates the main source of these differences. Process
cycles only (perf record; perf report -n):

std:
 Samples: 15K of event 'cycles', Event count (approx.): 7967793182
 73.02%         11564  netperf  [kernel.kallsyms]  [k] copy_user_generic_string
  4.73%           746  netperf  [kernel.kallsyms]  [k] __memset
  2.73%           433  netperf  [kernel.kallsyms]  [k] tcp_sendmsg
  2.41%           383  netperf  [kernel.kallsyms]  [k] get_page_from_freelist
  0.90%           143  netperf  [kernel.kallsyms]  [k] copy_from_iter

zc:
 Samples: 1K of event 'cycles', Event count (approx.): 858290585
 17.11%           182  netperf.zc.aug2  [kernel.kallsyms]   [k] gup_pte_range
  9.31%           100  netperf.zc.aug2  [kernel.kallsyms]   [k] __memset
  7.79%            81  netperf.zc.aug2  [kernel.kallsyms]   [k] __zerocopy_sg_from_iter
  3.87%            44  netperf.zc.aug2  [kernel.kallsyms]   [k] __alloc_skb
  3.75%            18  netperf.zc.aug2  netperf.zc.aug2015  [.] allocate_buffer_ring

The individual patches report additional micro-benchmark results.


* Safety

The number of pages that can be pinned on behalf of a process with
MSG_ZEROCOPY is bound by the locked memory ulimit.

Pages are not mapped read-only. Processes can modify packet contents
while packets are in flight in the kernel path. Bytes on which kernel
control flow depends (headers) are copied to avoid TOCTTOU attacks.

Datapath integrity does not otherwise depend on payload, with three
exceptions: checksums, optional sk_filter/tc u32/.. and device +
driver logic. The effect of wrong checksums is limited to the
misbehaving process. Filters may have to be addressed by inserting a
preventative skb_copy_ubufs(). Device drivers can be whitelisted,
similar to scatter-gather support (NETIF_F_SG).

Conversely, while the kernel holds process memory pinned, a process
cannot safely reuse those pages for other purposes. Some protocols,
notably TCP, may hold data for an unbounded length of time. Tun and
virtio bound latency by calling skb_copy_ubuf before cloning and
before injecting packets in unbounded latency paths. This approach
is not feasible for TCP.

Processes can safely avoid OOM conditions by bounding the number of
bytes passed with MSG_ZEROCOPY and by removing shared pages after
transmission from their own memory map -- for instance, depending on
type of page, by calling munmap() or with madvise MADV_SOFT_OFFLINE or
MADV_DONTNEED. Long-lived kernel references are an anomaly and this
operation should be rare. The mechanism was suggested in the earlier
zerocopy packet socket patch.


* Limitations / Known Issues

- PF_INET6 and PF_UNIX are not yet supported.
- UDP/RAW/PACKET should sleep on ubuf_info alloc failure
     they currently immediately return ENOBUFS
- TCP does not build max GSO packets, especially for
     small send buffers (< 4 KB)

Willem de Bruijn (10):
  sock: skb_copy_ubufs support for compound pages
  sock: add generic socket zerocopy
  sock: enable generic socket zerocopy
  sock: zerocopy coalesce support
  tcp: enable MSG_ZEROCOPY
  udp: enable MSG_ZEROCOPY
  raw: enable MSG_ZEROCOPY with hdrincl
  packet: enable MSG_ZEROCOPY
  sock: RLIMIT number of pinned pages with MSG_ZEROCOPY
  test: add zerocopy tests

 drivers/vhost/net.c                           |   1 +
 include/linux/mm_types.h                      |   1 +
 include/linux/skbuff.h                        |  72 +++-
 include/linux/socket.h                        |   1 +
 include/net/sock.h                            |   2 +
 include/uapi/linux/errqueue.h                 |   1 +
 net/core/datagram.c                           |  37 +-
 net/core/skbuff.c                             | 297 ++++++++++++--
 net/core/sock.c                               |   2 +
 net/ipv4/ip_output.c                          |  30 +-
 net/ipv4/raw.c                                |  27 +-
 net/ipv4/tcp.c                                |  31 +-
 net/packet/af_packet.c                        |  44 ++-
 tools/testing/selftests/net/Makefile          |   2 +-
 tools/testing/selftests/net/snd_zerocopy.c    | 353 +++++++++++++++++
 tools/testing/selftests/net/snd_zerocopy_lo.c | 535 ++++++++++++++++++++++++++
 16 files changed, 1372 insertions(+), 64 deletions(-)
 create mode 100644 tools/testing/selftests/net/snd_zerocopy.c
 create mode 100644 tools/testing/selftests/net/snd_zerocopy_lo.c

-- 
2.5.0.276.gf5e568e
