From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH v3 net-next 0/4] bpf: BPF for lightweight tunnel encapsulation
Date: Tue, 29 Nov 2016 14:21:19 +0100
Message-ID: <cover.1480424542.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, tom@herbertland.com,
        roopa@cumulusnetworks.com, hannes@stressinduktion.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:38865 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753356AbcK2NVa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 08:21:30 -0500
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
 net/core/filter.c               | 148 ++++++++++++++-
 net/core/lwt_bpf.c              | 397 ++++++++++++++++++++++++++++++++++++++++
 net/core/lwtunnel.c             |   2 +
 net/ipv4/route.c                |  37 ++--
 samples/bpf/Makefile            |   4 +
 samples/bpf/bpf_helpers.h       |   4 +
 samples/bpf/lwt_len_hist.sh     |  37 ++++
 samples/bpf/lwt_len_hist_kern.c |  82 +++++++++
 samples/bpf/lwt_len_hist_user.c |  76 ++++++++
 samples/bpf/test_lwt_bpf.c      | 247 +++++++++++++++++++++++++
 samples/bpf/test_lwt_bpf.sh     | 385 ++++++++++++++++++++++++++++++++++++++
 17 files changed, 1482 insertions(+), 17 deletions(-)
 create mode 100644 net/core/lwt_bpf.c
 create mode 100755 samples/bpf/lwt_len_hist.sh
 create mode 100644 samples/bpf/lwt_len_hist_kern.c
 create mode 100644 samples/bpf/lwt_len_hist_user.c
 create mode 100644 samples/bpf/test_lwt_bpf.c
 create mode 100755 samples/bpf/test_lwt_bpf.sh

-- 
2.7.4
