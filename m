From: Florian Westphal <fw@strlen.de>
Subject: [RFC net-next 0/6] tcp: remove prequeue and header prediction
Date: Fri, 28 Jul 2017 01:31:11 +0200
Message-ID: <20170727233117.29695-1-fw@strlen.de>
Cc: ycheng@google.com, ncardwell@google.com, edumazet@google.com,
        soheil@google.com, weiwan@google.com, brakmo@fb.com
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:38338 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751113AbdG0XbQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 19:31:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This RFC removes tcp prequeueing and header prediction support.

After a hallway discussion with Eric Dumazet some
maybe-not-so-useful-anymore TCP stack features came up, HP and
Prequeue among these.

So this RFC proposes to axe both.

In brief, TCP prequeue assumes a single-process-blocking-read
design, which is not that common anymore, and the most frequently
used high-performance networking program that does this is netperf :)

With more commong (e)poll designs, prequeue doesn't work.

The idea behind prequeueing isn't so bad in itself; it moves
part of tcp processing -- including ack processing (including
retransmit queue processing) into process context.
However, removing it would not just avoid some code, for most
programs it elimiates dead code.

As processing then always occurs in BH context, it would allow us
to experiment e.g. with bulk-freeing of skb heads when a packet acks
data on the retransmit queue.

Header prediction is also less useful nowadays.
For packet trains, GRO will aggregate packets so we do not get
a per-packet benefit.
Header prediction will also break down with light packet loss due to SACK.

So, In short: What do others think?

Florian Westphal (6):
      tcp: remove prequeue support
      tcp: reindent two spots after prequeue removal
      tcp: remove low_latency sysctl
      tcp: remove header prediction
      tcp: remove CA_ACK_SLOWPATH
      tcp: remove unused mib counters

 Documentation/networking/ip-sysctl.txt |    7 
 include/linux/tcp.h                    |   15 -
 include/net/tcp.h                      |   40 ----
 include/uapi/linux/snmp.h              |    8 
 net/ipv4/proc.c                        |    8 
 net/ipv4/sysctl_net_ipv4.c             |    3 
 net/ipv4/tcp.c                         |  109 -----------
 net/ipv4/tcp_input.c                   |  303 +++------------------------------
 net/ipv4/tcp_ipv4.c                    |   63 ------
 net/ipv4/tcp_minisocks.c               |    3 
 net/ipv4/tcp_output.c                  |    2 
 net/ipv4/tcp_timer.c                   |   12 -
 net/ipv4/tcp_westwood.c                |   31 ---
 net/ipv6/tcp_ipv6.c                    |    3 
 14 files changed, 43 insertions(+), 564 deletions(-)
