From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 00/11] net: various udp/tcp changes
Date: Fri,  1 Apr 2016 08:52:11 -0700
Message-ID: <1459525942-30399-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <tom@herbertland.com>,
	Willem de Bruijn <willemb@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33381 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752370AbcDAPwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 11:52:25 -0400
Received: by mail-pa0-f48.google.com with SMTP id zm5so94033395pac.0
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 08:52:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First round of patches for linux-4.7

Add a generic facility for sockets to be freed after an RCU grace
period, if they need to.

Then UDP stack is changed to no longer use SLAB_DESTROY_BY_RCU,
in order to speedup rx processing for traffic encapsulated in UDP.
It gives a 17 % speedup for normal UDP reception in stress conditions.

Then TCP listeners are changed to use SOCK_RCU_FREE as well
to avoid touching sk_refcnt in synflood case :
I got up to 30 % performance increase for a mono listener.

Then three patches add SK_MEMINFO_DROPS to sock_diag
and add per socket rx drops accounting to TCP.

Last patch adds rate limiting on ACK sent on behalf of SYN_RECV
to better resist to SYNFLOOD targeting one or few flows.


Eric Dumazet (11):
  net: add SOCK_RCU_FREE socket flag
  udp: no longer use SLAB_DESTROY_BY_RCU
  tcp/dccp: remove BH disable/enable in lookup
  tcp/dccp: use rcu locking in inet_diag_find_one_icsk()
  inet: reqsk_alloc() needs to take care of dead listeners
  tcp/dccp: do not touch listener sk_refcnt under synflood
  sock_diag: add SK_MEMINFO_DROPS
  tcp: increment sk_drops for dropped rx packets
  tcp: increment sk_drops for listeners
  ipv4: tcp: set SOCK_USE_WRITE_QUEUE for ip_send_unicast_reply()
  tcp: rate limit ACK sent by SYN_RECV request sockets

 include/linux/udp.h            |   8 +-
 include/net/inet6_hashtables.h |  12 +-
 include/net/inet_hashtables.h  |  47 +++----
 include/net/request_sock.h     |  31 +++--
 include/net/sock.h             |  21 ++-
 include/net/tcp.h              |  13 ++
 include/net/udp.h              |   2 +-
 include/uapi/linux/sock_diag.h |   1 +
 net/core/sock.c                |  15 ++-
 net/core/sock_diag.c           |   1 +
 net/dccp/ipv4.c                |   7 +-
 net/dccp/ipv6.c                |   7 +-
 net/ipv4/inet_diag.c           |  10 +-
 net/ipv4/inet_hashtables.c     |  77 ++++-------
 net/ipv4/tcp_input.c           |  41 +++---
 net/ipv4/tcp_ipv4.c            |  74 ++++++-----
 net/ipv4/tcp_minisocks.c       |   5 +-
 net/ipv4/udp.c                 | 293 ++++++++++++-----------------------------
 net/ipv4/udp_diag.c            |  18 +--
 net/ipv6/inet6_hashtables.c    |  62 +++------
 net/ipv6/tcp_ipv6.c            |  32 +++--
 net/ipv6/udp.c                 | 196 +++++++++------------------
 net/netfilter/xt_socket.c      |   6 +-
 23 files changed, 401 insertions(+), 578 deletions(-)

-- 
2.8.0.rc3.226.g39d4020
