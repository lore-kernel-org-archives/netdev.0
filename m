From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next v2 00/13] socket sendmsg MSG_ZEROCOPY
Date: Wed, 21 Jun 2017 16:36:39 -0400
Message-ID: <20170621203652.15306-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, linux-api@vger.kernel.org,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:33385 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751041AbdFUUg5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 16:36:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Introduce zerocopy socket send flag MSG_ZEROCOPY. This extends the
shared page support (SKBTX_SHARED_FRAG) from sendpage to sendmsg.
Implement the feature for TCP, UDP, RAW and packet sockets.

On a send call with MSG_ZEROCOPY, the kernel pins user pages and
links these directly into the skbuff frags[] array.

Each send call with MSG_ZEROCOPY that transmits data will eventually
queue a completion notification on the error queue: a per-socket u32
incremented on each such call. A request may have to revert to copy
to succeed, for instance when a device cannot support scatter-gather
IO. In that case a flag is passed along to notify that the operation
succeeded without zerocopy optimization.

The implementation extends the existing zerocopy infra for tuntap,
vhost and xen with features needed for TCP, notably reference
counting to handle cloning on retransmit and GSO.

For more details, see also the netdev 2.1 paper and presentation at
https://netdevconf.org/2.1/session.html?debruijn

Changelog:

  v1 -> v2:
    - fix (kbuild-bot): do not remove uarg until patch 5
    - fix (kbuild-bot): move zerocopy_sg_from_iter doc with function
    - fix: remove unused extern in header file

  RFCv2 -> v1:
    - patch 2
        - review comment: in skb_copy_ubufs, always allocate order-0
            page, also when replacing compound source pages.
    - patch 3
        - fix: always queue completion notification on MSG_ZEROCOPY,
	    also if revert to copy.
	- fix: on syscall abort, correctly revert notification state
	- minor: skip queue notification on SOCK_DEAD
	- minor: replace BUG_ON with WARN_ON in recoverable error
    - patch 4
        - new: add socket option SOCK_ZEROCOPY.
	    only honor MSG_ZEROCOPY if set, ignore for legacy apps.
    - patch 5
        - fix: clear zerocopy state on skb_linearize
    - patch 6
        - fix: only coalesce if prev errqueue elem is zerocopy
	- minor: try coalescing with list tail instead of head
        - minor: merge bytelen limit patch
    - patch 7
        - new: signal when data had to be copied
    - patch 8 (tcp)
        - optimize: avoid setting PSH bit when exceeding max frags.
	    that limits GRO on the client. do not goto new_segment.
	- fix: fail on MSG_ZEROCOPY | MSG_FASTOPEN
	- minor: do not wait for memory: does not work for optmem
	- minor: simplify alloc
    - patch 9 (udp)
        - new: add PF_INET6
        - fix: attach zerocopy notification even if revert to copy
	- minor: simplify alloc size arithmetic
    - patch 10 (raw hdrinc)
        - new: add PF_INET6
    - patch 11 (pf_packet)
        - minor: simplify slightly
    - patch 12
        - new msg_zerocopy regression test: use veth pair to test
	    all protocols: ipv4/ipv6/packet, tcp/udp/raw, cork
	    all relevant ethtool settings: rx off, sg off
	    all relevant packet lengths: 0, <MAX_HEADER, max size

  RFC -> RFCv2:
    - review comment: do not loop skb with zerocopy frags onto rx:
          add skb_orphan_frags_rx to orphan even refcounted frags
	  call this in __netif_receive_skb_core, deliver_skb and tun:
	  the same as 1080e512d44d ("net: orphan frags on receive")
    - fix: hold an explicit sk reference on each notification skb.
          previously relied on the reference (or wmem) held by the
	  data skb that would trigger notification, but this breaks
	  on skb_orphan.
    - fix: when aborting a send, do not inc the zerocopy counter
          this caused gaps in the notification chain
    - fix: in packet with SOCK_DGRAM, pull ll headers before calling
          zerocopy_sg_from_iter
    - fix: if sock_zerocopy_realloc does not allow coalescing,
          do not fail, just allocate a new ubuf
    - fix: in tcp, check return value of second allocation attempt
    - chg: allocate notification skbs from optmem
          to avoid affecting tcp write queue accounting (TSQ)
    - chg: limit #locked pages (ulimit) per user instead of per process
    - chg: grow notification ids from 16 to 32 bit
      - pass range [lo, hi] through 32 bit fields ee_info and ee_data
    - chg: rebased to davem-net-next on top of v4.10-rc7
    - add: limit notification coalescing
          sharing ubufs limits overhead, but delays notification until
	  the last packet is released, possibly unbounded. Add a cap. 
    - tests: add snd_zerocopy_lo pf_packet test
    - tests: two bugfixes (add do_flush_tcp, ++sent not only in debug)

Limitations / Known Issues:
    - TCP may build slightly smaller than max TSO packets due to
      exceeding MAX_SKB_FRAGS frags when zerocopy pages are unaligned.
    - All SKBTX_SHARED_FRAG may require additional __skb_linearize or
      skb_copy_ubufs calls in u32, skb_find_text, similar to
      skb_checksum_help.
    - UDP and RAW may be of limited use without loopback due to
      MTU being too small to see copy avoidance gains.

Notification skbuffs are allocated from optmem. For sockets that
cannot effectively coalesce notifications, the optmem max may need
to be increased to avoid hitting -ENOBUFS:

  sysctl -w net.core.optmem_max=1048576

In application load, copy avoidance shows a roughly 5% systemwide
reduction in cycles when streaming large flows and a 4-8% reduction in
wall clock time on early tensorflow test workloads.

For the single-machine veth tests to succeed, loopback support has to
be temporarily enabled by making skb_orphan_frags_rx map to
skb_orphan_frags.

* Performance

The below table shows cycles reported by perf for a netperf process
sending a single 10 Gbps TCP_STREAM. The first three columns show
Mcycles spent in the netperf process context. The second three columns
show time spent systemwide (-a -C A,B) on the two cpus that run the
process and interrupt handler. Reported is the median of at least 3
runs. std is a standard netperf, zc uses zerocopy and % is the ratio.
Netperf is pinned to cpu 2, network interrupts to cpu3, rps and rfs
are disabled and the kernel is booted with idle=halt.

NETPERF=./netperf -t TCP_STREAM -H $host -T 2 -l 30 -- -m $size

perf stat -e cycles $NETPERF
perf stat -C 2,3 -a -e cycles $NETPERF

        --process cycles--      ----cpu cycles----
           std      zc   %      std         zc   %
4K      27,609  11,217  41      49,217  39,175  79
16K     21,370   3,823  18      43,540  29,213  67
64K     20,557   2,312  11      42,189  26,910  64
256K    21,110   2,134  10      43,006  27,104  63
1M      20,987   1,610   8      42,759  25,931  61

Perf record indicates the main source of these differences. Process
cycles only at 1M writes (perf record; perf report -n):

std:
Samples: 42K of event 'cycles', Event count (approx.): 21258597313                                                   
 79.41%         33884  netperf  [kernel.kallsyms]  [k] copy_user_generic_string
  3.27%          1396  netperf  [kernel.kallsyms]  [k] tcp_sendmsg
  1.66%           694  netperf  [kernel.kallsyms]  [k] get_page_from_freelist
  0.79%           325  netperf  [kernel.kallsyms]  [k] tcp_ack
  0.43%           188  netperf  [kernel.kallsyms]  [k] __alloc_skb

zc:
Samples: 1K of event 'cycles', Event count (approx.): 1439509124                                                     
 30.36%           584  netperf.zerocop  [kernel.kallsyms]  [k] gup_pte_range
 14.63%           284  netperf.zerocop  [kernel.kallsyms]  [k] __zerocopy_sg_from_iter
  8.03%           159  netperf.zerocop  [kernel.kallsyms]  [k] skb_zerocopy_add_frags_iter
  4.84%            96  netperf.zerocop  [kernel.kallsyms]  [k] __alloc_skb
  3.10%            60  netperf.zerocop  [kernel.kallsyms]  [k] kmem_cache_alloc_node


* Safety

The number of pages that can be pinned on behalf of a user with
MSG_ZEROCOPY is bound by the locked memory ulimit.

While the kernel holds process memory pinned, a process cannot safely
reuse those pages for other purposes. Packets looped onto the receive
stack and queued to a socket can be held indefinitely. Avoid unbounded
notification latency by restricting user pages to egress paths only.
skb_orphan_frags_rx() will create a private copy of pages even for
refcounted packets when these are looped, as did skb_orphan_frags for
the original tun zerocopy implementation.

Pages are not remapped read-only. Processes can modify packet contents
while packets are in flight in the kernel path. Bytes on which kernel
control flow depends (headers) are copied to avoid TOCTTOU attacks.
Datapath integrity does not otherwise depend on payload, with three
exceptions: checksums, optional sk_filter/tc u32/.. and device +
driver logic. The effect of wrong checksums is limited to the
misbehaving process. TC filters that access contents may have to be
excluded by adding an skb_orphan_frags_rx. 

Processes can also safely avoid OOM conditions by bounding the number
of bytes passed with MSG_ZEROCOPY and by removing shared pages after
transmission from their own memory map.


Willem de Bruijn (13):
  sock: allocate skbs from optmem
  sock: skb_copy_ubufs support for compound pages
  sock: add MSG_ZEROCOPY
  sock: add SOCK_ZEROCOPY sockopt
  sock: enable MSG_ZEROCOPY
  sock: MSG_ZEROCOPY notification coalescing
  sock: add ee_code SO_EE_CODE_ZEROCOPY_COPIED
  sock: ulimit on MSG_ZEROCOPY pages
  tcp: enable MSG_ZEROCOPY
  udp: enable MSG_ZEROCOPY
  raw: enable MSG_ZEROCOPY with IP_HDRINCL
  packet: enable MSG_ZEROCOPY
  test: add msg_zerocopy test

 arch/alpha/include/uapi/asm/socket.h        |   2 +
 arch/frv/include/uapi/asm/socket.h          |   2 +
 arch/ia64/include/uapi/asm/socket.h         |   2 +
 arch/m32r/include/uapi/asm/socket.h         |   2 +
 arch/mips/include/uapi/asm/socket.h         |   2 +
 arch/mn10300/include/uapi/asm/socket.h      |   2 +
 arch/parisc/include/uapi/asm/socket.h       |   2 +
 arch/s390/include/uapi/asm/socket.h         |   2 +
 arch/sparc/include/uapi/asm/socket.h        |   2 +
 arch/xtensa/include/uapi/asm/socket.h       |   2 +
 drivers/net/tun.c                           |   2 +-
 drivers/vhost/net.c                         |   1 +
 include/linux/sched/user.h                  |   3 +-
 include/linux/skbuff.h                      | 106 ++++-
 include/linux/socket.h                      |   1 +
 include/net/sock.h                          |   4 +
 include/uapi/asm-generic/socket.h           |   2 +
 include/uapi/linux/errqueue.h               |   3 +
 net/core/datagram.c                         |  55 ++-
 net/core/dev.c                              |   4 +-
 net/core/skbuff.c                           | 390 ++++++++++++++--
 net/core/sock.c                             |  43 ++
 net/ipv4/ip_output.c                        |  37 +-
 net/ipv4/raw.c                              |  23 +-
 net/ipv4/tcp.c                              |  32 +-
 net/ipv6/ip6_output.c                       |  40 +-
 net/ipv6/raw.c                              |  20 +-
 net/packet/af_packet.c                      |  36 +-
 tools/testing/selftests/net/.gitignore      |   1 +
 tools/testing/selftests/net/Makefile        |   2 +-
 tools/testing/selftests/net/msg_zerocopy.c  | 697 ++++++++++++++++++++++++++++
 tools/testing/selftests/net/msg_zerocopy.sh | 113 +++++
 32 files changed, 1535 insertions(+), 100 deletions(-)
 create mode 100644 tools/testing/selftests/net/msg_zerocopy.c
 create mode 100755 tools/testing/selftests/net/msg_zerocopy.sh

-- 
2.13.1.611.g7e3b11ae1-goog
