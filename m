From: Michael Kerrisk <mtk.manpages@gmail.com>
Subject: Re: [PATCH RFC v2 00/12] socket sendmsg MSG_ZEROCOPY
Date: Mon, 27 Feb 2017 19:57:45 +0100
Message-ID: <CAHO5Pa1QdQTyEFVAc_E+y3GkYhXM2=z6UXSeoH79ybFiBxs7ag@mail.gmail.com>
References: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Linux API <linux-api@vger.kernel.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:36578 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751617AbdB0S6H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 13:58:07 -0500
In-Reply-To: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[CC += linux-api@vger.kernel.org]

Hi Willem

This is a change to the kernel-user-space API. Please CC
linux-api@vger.kernel.org on any future iterations of this patch.

Thanks,

Michael



On Wed, Feb 22, 2017 at 5:38 PM, Willem de Bruijn
<willemdebruijn.kernel@gmail.com> wrote:
> From: Willem de Bruijn <willemb@google.com>
>
> RFCv2:
>
> I have received a few requests for status and rebased code of this
> feature. We have been running this code internally, discovering and
> fixing various bugs. With net-next closed, now seems like a good time
> to share an updated patchset with fixes. The rebase from RFCv1/v4.2
> was mostly straightforward: mainly iov_iter changes. Full changelog:
>
>   RFC -> RFCv2:
>     - review comment: do not loop skb with zerocopy frags onto rx:
>           add skb_orphan_frags_rx to orphan even refcounted frags
>           call this in __netif_receive_skb_core, deliver_skb and tun:
>           the same as 1080e512d44d ("net: orphan frags on receive")
>     - fix: hold an explicit sk reference on each notification skb.
>           previously relied on the reference (or wmem) held by the
>           data skb that would trigger notification, but this breaks
>           on skb_orphan.
>     - fix: when aborting a send, do not inc the zerocopy counter
>           this caused gaps in the notification chain
>     - fix: in packet with SOCK_DGRAM, pull ll headers before calling
>           zerocopy_sg_from_iter
>     - fix: if sock_zerocopy_realloc does not allow coalescing,
>           do not fail, just allocate a new ubuf
>     - fix: in tcp, check return value of second allocation attempt
>     - chg: allocate notification skbs from optmem
>           to avoid affecting tcp write queue accounting (TSQ)
>     - chg: limit #locked pages (ulimit) per user instead of per process
>     - chg: grow notification ids from 16 to 32 bit
>       - pass range [lo, hi] through 32 bit fields ee_info and ee_data
>     - chg: rebased to davem-net-next on top of v4.10-rc7
>     - add: limit notification coalescing
>           sharing ubufs limits overhead, but delays notification until
>           the last packet is released, possibly unbounded. Add a cap.
>     - tests: add snd_zerocopy_lo pf_packet test
>     - tests: two bugfixes (add do_flush_tcp, ++sent not only in debug)
>
> The change to allocate notification skbuffs from optmem requires
> ensuring that net.core.optmem is at least a few 100KB. To
> experiment, run
>
>   sysctl -w net.core.optmem_max=1048576
>
> The snd_zerocopy_lo benchmarks reported in the individual patches were
> rerun for RFCv2. To make them work, calls to skb_orphan_frags_rx were
> replaced with skb_orphan_frags to allow looping to local sockets. The
> netperf results below are also rerun with v2.
>
> In application load, copy avoidance shows a roughly 5% systemwide
> reduction in cycles when streaming large flows and a 4-8% reduction in
> wall clock time on early tensorflow test workloads.
>
>
> Overview (from original RFC):
>
> Add zerocopy socket sendmsg() support with flag MSG_ZEROCOPY.
> Implement the feature for TCP, UDP, RAW and packet sockets. This is
> a generalization of a previous packet socket RFC patch
>
>   http://patchwork.ozlabs.org/patch/413184/
>
> On a send call with MSG_ZEROCOPY, the kernel pins the user pages and
> creates skbuff fragments directly from these pages. On tx completion,
> it notifies the socket owner that it is safe to modify memory by
> queuing a completion notification onto the socket error queue.
>
> The kernel already implements such copy avoidance with vmsplice plus
> splice and with ubuf_info for tun and virtio. Extend the second
> with features required by TCP and others: reference counting to
> support cloning (retransmit queue) and shared fragments (GSO) and
> notification coalescing to handle corking.
>
> Notifications are queued onto the socket error queue as a range
> range [N, N+m], where N is a per-socket counter incremented on each
> successful zerocopy send call.
>
> * Performance
>
> The below table shows cycles reported by perf for a netperf process
> sending a single 10 Gbps TCP_STREAM. The first three columns show
> Mcycles spent in the netperf process context. The second three columns
> show time spent systemwide (-a -C A,B) on the two cpus that run the
> process and interrupt handler. Reported is the median of at least 3
> runs. std is a standard netperf, zc uses zerocopy and % is the ratio.
> Netperf is pinned to cpu 2, network interrupts to cpu3, rps and rfs
> are disabled and the kernel is booted with idle=halt.
>
> NETPERF=./netperf -t TCP_STREAM -H $host -T 2 -l 30 -- -m $size
>
> perf stat -e cycles $NETPERF
> perf stat -C 2,3 -a -e cycles $NETPERF
>
>         --process cycles--      ----cpu cycles----
>            std      zc   %      std         zc   %
> 4K      27,609  11,217  41      49,217  39,175  79
> 16K     21,370   3,823  18      43,540  29,213  67
> 64K     20,557   2,312  11      42,189  26,910  64
> 256K    21,110   2,134  10      43,006  27,104  63
> 1M      20,987   1,610   8      42,759  25,931  61
>
> Perf record indicates the main source of these differences. Process
> cycles only at 1M writes (perf record; perf report -n):
>
> std:
> Samples: 42K of event 'cycles', Event count (approx.): 21258597313
>  79.41%         33884  netperf  [kernel.kallsyms]  [k] copy_user_generic_string
>   3.27%          1396  netperf  [kernel.kallsyms]  [k] tcp_sendmsg
>   1.66%           694  netperf  [kernel.kallsyms]  [k] get_page_from_freelist
>   0.79%           325  netperf  [kernel.kallsyms]  [k] tcp_ack
>   0.43%           188  netperf  [kernel.kallsyms]  [k] __alloc_skb
>
> zc:
> Samples: 1K of event 'cycles', Event count (approx.): 1439509124
>  30.36%           584  netperf.zerocop  [kernel.kallsyms]  [k] gup_pte_range
>  14.63%           284  netperf.zerocop  [kernel.kallsyms]  [k] __zerocopy_sg_from_iter
>   8.03%           159  netperf.zerocop  [kernel.kallsyms]  [k] skb_zerocopy_add_frags_iter
>   4.84%            96  netperf.zerocop  [kernel.kallsyms]  [k] __alloc_skb
>   3.10%            60  netperf.zerocop  [kernel.kallsyms]  [k] kmem_cache_alloc_node
>
>
> * Safety
>
> The number of pages that can be pinned on behalf of a user with
> MSG_ZEROCOPY is bound by the locked memory ulimit.
>
> While the kernel holds process memory pinned, a process cannot safely
> reuse those pages for other purposes. Packets looped onto the receive
> stack and queued to a socket can be held indefinitely. Avoid unbounded
> notification latency by restricting user pages to egress paths only.
> skb_orphan_frags_rx() will create a private copy of pages even for
> refcounted packets when these are looped, as did skb_orphan_frags for
> the original tun zerocopy implementation.
>
> Pages are not remapped read-only. Processes can modify packet contents
> while packets are in flight in the kernel path. Bytes on which kernel
> control flow depends (headers) are copied to avoid TOCTTOU attacks.
> Datapath integrity does not otherwise depend on payload, with three
> exceptions: checksums, optional sk_filter/tc u32/.. and device +
> driver logic. The effect of wrong checksums is limited to the
> misbehaving process. TC filters that access contents may have to be
> excluded by adding an skb_orphan_frags_rx.
>
> Processes can also safely avoid OOM conditions by bounding the number
> of bytes passed with MSG_ZEROCOPY and by removing shared pages after
> transmission from their own memory map.
>
>
> * Limitations / Known Issues
>
> - PF_INET6 is not yet supported.
> - TCP does not build max GSO packets, especially for
>      small send buffers (< 4 KB)
>
> Willem de Bruijn (12):
>   sock: allocate skbs from optmem
>   sock: skb_copy_ubufs support for compound pages
>   sock: add generic socket zerocopy
>   sock: enable sendmsg zerocopy
>   sock: sendmsg zerocopy notification coalescing
>   sock: sendmsg zerocopy ulimit
>   sock: sendmsg zerocopy limit bytes per notification
>   tcp: enable sendmsg zerocopy
>   udp: enable sendmsg zerocopy
>   raw: enable sendmsg zerocopy with IP_HDRINCL
>   packet: enable sendmsg zerocopy
>   test: add sendmsg zerocopy tests
>
>  drivers/net/tun.c                             |   2 +-
>  drivers/vhost/net.c                           |   1 +
>  include/linux/sched.h                         |   2 +-
>  include/linux/skbuff.h                        |  94 +++-
>  include/linux/socket.h                        |   1 +
>  include/net/sock.h                            |   4 +
>  include/uapi/linux/errqueue.h                 |   1 +
>  net/core/datagram.c                           |  35 +-
>  net/core/dev.c                                |   4 +-
>  net/core/skbuff.c                             | 327 ++++++++++++--
>  net/core/sock.c                               |  29 ++
>  net/ipv4/ip_output.c                          |  34 +-
>  net/ipv4/raw.c                                |  27 +-
>  net/ipv4/tcp.c                                |  37 +-
>  net/packet/af_packet.c                        |  52 ++-
>  tools/testing/selftests/net/.gitignore        |   2 +
>  tools/testing/selftests/net/Makefile          |   1 +
>  tools/testing/selftests/net/snd_zerocopy.c    | 354 +++++++++++++++
>  tools/testing/selftests/net/snd_zerocopy_lo.c | 596 ++++++++++++++++++++++++++
>  19 files changed, 1536 insertions(+), 67 deletions(-)
>  create mode 100644 tools/testing/selftests/net/snd_zerocopy.c
>  create mode 100644 tools/testing/selftests/net/snd_zerocopy_lo.c
>
> --
> 2.11.0.483.g087da7b7c-goog
>



-- 
Michael Kerrisk Linux man-pages maintainer;
http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface", http://blog.man7.org/
