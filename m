From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next v4 0/4] bpf: BPF for lightweight tunnel encapsulation
Date: Wed, 30 Nov 2016 17:10:07 +0100
Message-ID: <cover.1480522144.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, tom@herbertland.com,
        roopa@cumulusnetworks.com, hannes@stressinduktion.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:45394 "EHLO
        merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758022AbcK3QKT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 11:10:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series implements BPF program invocation from dst entries via the
lightweight tunnels infrastructure. The BPF program can be attached to
lwtunnel_input(), lwtunnel_output() or lwtunnel_xmit() and see an L3
skb as context. Programs attached to input and output are read-only.
Programs attached to lwtunnel_xmit() can modify and redirect, push headers
and redirect packets.

The facility can be used to:
 - Collect statistics and generate sampling data for a subset of traffic
   based on the dst utilized by the packet thus allowing to extend the
   existing realms.
 - Apply additional per route/dst filters to prohibit certain outgoing
   or incoming packets based on BPF filters. In particular, this allows
   to maintain per dst custom state across multiple packets in BPF maps
   and apply filters based on statistics and behaviour observed over time.
 - Attachment of L2 headers at transmit where resolving the L2 address
   is not required.
 - Possibly many more.

v3 -> v4:
 - Bumped LWT_BPF_MAX_HEADROOM from 128 to 256 (Alexei)
 - Renamed bpf_skb_push() helper to bpf_skb_change_head() to relate to
   existing bpf_skb_change_tail() helper (Alexei/Daniel)
 - Added check in __bpf_redirect_common() to verify that program added a
   link header before redirecting to a l2 device. Adding the check to
   lwt-bpf code was considered but dropped due to massive code required
   due to retrieval of net_device via per-cpu redirect buffer. A test
   case was added to cover the scenario when a program directs to an l2
   device without adding an appropriate l2 header.
   (Alexei)
 - Prohibited access to tc_classid (Daniel)
 - Collapsed bpf_verifier_ops instance for lwt in/out as they are
   identical (Daniel)
 - Some cosmetic changes

v2 -> v3:
 - Added real world sample lwt_len_hist_kern.c which demonstrates how to
   collect a histogram on packet sizes for all packets flowing through
   a number of routes.
 - Restricted output to be read-only. Since the header can no longer
   be modified, the rerouting functionality has been removed again.
 - Added test case which cover destructive modification of packet data.

v1 -> v2:
 - Added new BPF_LWT_REROUTE return code for program to indicate
   that new route lookup should be performed. Suggested by Tom.
 - New sample to illustrate rerouting
 - New patch 05: Recursion limit for lwtunnel_output for the case
   when user creates circular dst redirection. Also resolves the
   issue for ILA.
 - Fix to ensure headroom for potential future L2 header is still
   guaranteed

Thomas Graf (4):
  route: Set orig_output when redirecting to lwt on locally generated
    traffic
  route: Set lwtstate for local traffic and cached input dsts
  bpf: BPF for lightweight tunnel infrastructure
  bpf: Add tests and samples for LWT-BPF

 include/linux/filter.h          |   2 +-
 include/uapi/linux/bpf.h        |  32 +++-
 include/uapi/linux/lwtunnel.h   |  23 +++
 kernel/bpf/verifier.c           |  14 +-
 net/Kconfig                     |   8 +
 net/core/Makefile               |   1 +
 net/core/filter.c               | 173 +++++++++++++++++
 net/core/lwt_bpf.c              | 396 +++++++++++++++++++++++++++++++++++++++
 net/core/lwtunnel.c             |   2 +
 net/ipv4/route.c                |  37 ++--
 samples/bpf/Makefile            |   4 +
 samples/bpf/bpf_helpers.h       |   4 +
 samples/bpf/lwt_len_hist.sh     |  37 ++++
 samples/bpf/lwt_len_hist_kern.c |  82 +++++++++
 samples/bpf/lwt_len_hist_user.c |  76 ++++++++
 samples/bpf/test_lwt_bpf.c      | 253 +++++++++++++++++++++++++
 samples/bpf/test_lwt_bpf.sh     | 399 ++++++++++++++++++++++++++++++++++++++++
 17 files changed, 1527 insertions(+), 16 deletions(-)
 create mode 100644 net/core/lwt_bpf.c
 create mode 100755 samples/bpf/lwt_len_hist.sh
 create mode 100644 samples/bpf/lwt_len_hist_kern.c
 create mode 100644 samples/bpf/lwt_len_hist_user.c
 create mode 100644 samples/bpf/test_lwt_bpf.c
 create mode 100755 samples/bpf/test_lwt_bpf.sh

-- 
2.7.4
