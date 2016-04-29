From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 0/7] net: make TCP preemptible
Date: Fri, 29 Apr 2016 14:16:46 -0700
Message-ID: <1461964613-4872-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Soheil Hassas Yeganeh <soheil@google.com>,
	Alexei Starovoitov <ast@fb.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34747 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752705AbcD2VRC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 17:17:02 -0400
Received: by mail-pa0-f52.google.com with SMTP id r5so50989344pag.1
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 14:17:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Most of TCP stack assumed it was running from BH handler.

This is great for most things, as TCP behavior is very sensitive
to scheduling artifacts.

However, the prequeue and backlog processing are problematic,
as they need to be flushed with BH being blocked.

To cope with modern needs, TCP sockets have big sk_rcvbuf values,
in the order of 16 MB, and soon 32 MB.
This means that backlog can hold thousands of packets, and things
like TCP coalescing or collapsing on this amount of packets can
lead to insane latency spikes, since BH are blocked for too long.

It is time to make UDP/TCP stacks preemptible.

Note that fast path still runs from BH handler.

v2: Added "tcp: make tcp_sendmsg() aware of socket backlog"
    to reduce latency problems of large sends.

v3: Fixed a typo in tcp_cdg.c

Eric Dumazet (7):
  tcp: do not assume TCP code is non preemptible
  tcp: do not block bh during prequeue processing
  dccp: do not assume DCCP code is non preemptible
  udp: prepare for non BH masking at backlog processing
  sctp: prepare for socket backlog behavior change
  net: do not block BH while processing socket backlog
  tcp: make tcp_sendmsg() aware of socket backlog

 include/net/sock.h       |  11 +++++
 net/core/sock.c          |  29 +++++------
 net/dccp/input.c         |   2 +-
 net/dccp/ipv4.c          |   4 +-
 net/dccp/ipv6.c          |   4 +-
 net/dccp/options.c       |   2 +-
 net/ipv4/tcp.c           |  14 +++---
 net/ipv4/tcp_cdg.c       |  20 ++++----
 net/ipv4/tcp_cubic.c     |  20 ++++----
 net/ipv4/tcp_fastopen.c  |  12 ++---
 net/ipv4/tcp_input.c     | 126 +++++++++++++++++++----------------------------
 net/ipv4/tcp_ipv4.c      |  14 ++++--
 net/ipv4/tcp_minisocks.c |   2 +-
 net/ipv4/tcp_output.c    |  11 ++---
 net/ipv4/tcp_recovery.c  |   4 +-
 net/ipv4/tcp_timer.c     |  10 ++--
 net/ipv4/udp.c           |   4 +-
 net/ipv6/tcp_ipv6.c      |  12 ++---
 net/ipv6/udp.c           |   4 +-
 net/sctp/inqueue.c       |   2 +
 20 files changed, 150 insertions(+), 157 deletions(-)

-- 
2.8.0.rc3.226.g39d4020
