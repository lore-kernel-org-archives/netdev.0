From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 0/4] BPF for lightweight tunnel encapsulation
Date: Sun, 30 Oct 2016 12:58:01 +0100
Message-ID: <cover.1477827877.git.tgraf@suug.ch>
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        tom@herbertland.com, netdev@vger.kernel.org,
        roopa@cumulusnetworks.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:50736 "EHLO
        merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751905AbcJ3L6S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2016 07:58:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

Thomas Graf (4):
  route: Set orig_output when redirecting to lwt on locally generated
    traffic
  route: Set lwtstate for local traffic and cached input dsts
  bpf: BPF for lightweight tunnel encapsulation
  bpf: Add samples for LWT-BPF

 include/linux/filter.h        |   2 +-
 include/uapi/linux/bpf.h      |  31 +++-
 include/uapi/linux/lwtunnel.h |  21 +++
 kernel/bpf/verifier.c         |  16 +-
 net/core/Makefile             |   2 +-
 net/core/filter.c             | 148 ++++++++++++++++-
 net/core/lwt_bpf.c            | 365 ++++++++++++++++++++++++++++++++++++++++++
 net/core/lwtunnel.c           |   1 +
 net/ipv4/route.c              |  37 +++--
 samples/bpf/bpf_helpers.h     |   4 +
 samples/bpf/lwt_bpf.c         | 210 ++++++++++++++++++++++++
 samples/bpf/test_lwt_bpf.sh   | 337 ++++++++++++++++++++++++++++++++++++++
 12 files changed, 1156 insertions(+), 18 deletions(-)
 create mode 100644 net/core/lwt_bpf.c
 create mode 100644 samples/bpf/lwt_bpf.c
 create mode 100755 samples/bpf/test_lwt_bpf.sh

-- 
2.7.4
