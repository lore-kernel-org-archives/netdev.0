From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next v2 0/5] bpf: BPF for lightweight tunnel encapsulation
Date: Tue,  1 Nov 2016 01:37:04 +0100
Message-ID: <cover.1477959702.git.tgraf@suug.ch>
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        tom@herbertland.com, roopa@cumulusnetworks.com,
        netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:45273 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S948209AbcKAAhX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 20:37:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

{Open question:
 Tom brought up the question on whether it is safe to modify the packet
 in artbirary ways before dst_output(). This is the equivalent to a raw
 socket injecting illegal headers. This v2 currently assumes that
 dst_output() is ready to accept invalid header values. This needs to be
 verified and if not the case, then raw sockets or dst_output() handlers
 must be fixed as well. Another option is to mark lwtunnel_output() as
 read-only for now.}

This series implements BPF program invocation from dst entries via the
lightweight tunnels infrastructure. The BPF program can be attached to
lwtunnel_input(), lwtunnel_output() or lwtunnel_xmit() and sees an L3
skb as context. input is read-only, output can write, xmit can write,
push headers, and redirect.

Motiviation for this work:
 - Restricting outgoing routes beyond what the route tuple supports
 - Per route accounting byond realms
 - Fast attachment of L2 headers where header does not require resolving
   L2 addresses
 - ILA like uses cases where L3 addresses are resolved and then routed
   in an async manner
 - Fast encapsulation + redirect. For now limited to use cases where not
   setting inner and outer offset/protocol is OK.

A couple of samples on how to use it can be found in patch 04.

v1 -> v2:
 - Added new BPF_LWT_REROUTE return code for program to indicate
   that new route lookup should be performed. Suggested by Tom.
 - New sample to illustrate rerouting
 - New patch 05: Recursion limit for lwtunnel_output for the case
   when user creates circular dst redirection. Also resolves the
   issue for ILA.
 - Fix to ensure headroom for potential future L2 header is still
   guaranteed

Thomas Graf (5):
  route: Set orig_output when redirecting to lwt on locally generated
    traffic
  route: Set lwtstate for local traffic and cached input dsts
  bpf: BPF for lightweight tunnel encapsulation
  bpf: Add samples for LWT-BPF
  lwtunnel: Limit number of recursions on output to 5

 include/linux/filter.h        |   2 +-
 include/uapi/linux/bpf.h      |  37 +++-
 include/uapi/linux/lwtunnel.h |  21 ++
 kernel/bpf/verifier.c         |  16 +-
 net/Kconfig                   |   1 +
 net/core/Makefile             |   2 +-
 net/core/filter.c             | 148 ++++++++++++-
 net/core/lwt_bpf.c            | 504 ++++++++++++++++++++++++++++++++++++++++++
 net/core/lwtunnel.c           |  15 +-
 net/ipv4/route.c              |  37 +++-
 samples/bpf/bpf_helpers.h     |   4 +
 samples/bpf/lwt_bpf.c         | 235 ++++++++++++++++++++
 samples/bpf/test_lwt_bpf.sh   | 370 +++++++++++++++++++++++++++++++
 13 files changed, 1373 insertions(+), 19 deletions(-)
 create mode 100644 net/core/lwt_bpf.c
 create mode 100644 samples/bpf/lwt_bpf.c
 create mode 100755 samples/bpf/test_lwt_bpf.sh

-- 
2.7.4
