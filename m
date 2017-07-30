From: Florian Westphal <fw@strlen.de>
Subject: [net-next 0/6] tcp: remove prequeue and header prediction
Date: Sun, 30 Jul 2017 03:57:17 +0200
Message-ID: <20170730015723.25587-1-fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:45054 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752485AbdG3B5G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2017 21:57:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During a hallway discussion with Eric Dumazet at Netdev 1.2 in
Tokyo some maybe-not-so-useful-anymore TCP stack features came up,
among these header prediction and prequeueing.

In brief, TCP prequeue assumes a single-process-blocking-read design,
which is not that common anymore. The most frequently used high-performance
networking program that is an excellent fit for these features is netperf.

The idea behind prequeueing is to move part of tcp processing, including
retransmit queue cleaning, to process context.

With (e)poll designs, prequeue is always skipped, so for such programs
this is dead-code removal.

Header prediction is also less useful nowadays.
For packet trains, GRO will do packet aggregation so we do not get the
per-packet benefit that this had before GRO anymore.

Because of SACK, header prediction also will be ineffective once
a connection suffers even light packet losses.

code removal aside, after this change processing always occurs in BH
context, this allows to experiment e.g. with doing bulk freeing of
skb heads when incoming ACKs clean packets from the retransmit queue.

There are no changes since the RFC, except in last patch (i missed
another no-longer-used mib counter). I also edited a few commit messages.

 Documentation/networking/ip-sysctl.txt |    7
 include/linux/tcp.h                    |   15 -
 include/net/tcp.h                      |   40 ----
 include/uapi/linux/snmp.h              |    9
 net/ipv4/proc.c                        |    9
 net/ipv4/sysctl_net_ipv4.c             |    3
 net/ipv4/tcp.c                         |  109 -----------
 net/ipv4/tcp_input.c                   |  303 +++------------------------------
 net/ipv4/tcp_ipv4.c                    |   63 ------
 net/ipv4/tcp_minisocks.c               |    3
 net/ipv4/tcp_output.c                  |    2
 net/ipv4/tcp_timer.c                   |   12 -
 net/ipv4/tcp_westwood.c                |   31 ---
 net/ipv6/tcp_ipv6.c                    |    3
 14 files changed, 43 insertions(+), 566 deletions(-)
