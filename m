From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 00/17] tcp/dccp: lockless listener
Date: Fri,  2 Oct 2015 11:43:22 -0700
Message-ID: <1443811419-4798-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Ying Cai <ycai@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36384 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752773AbbJBSnp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 14:43:45 -0400
Received: by pablk4 with SMTP id lk4so112682555pab.3
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2015 11:43:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCP listener refactoring : this is becoming interesting !

This patch series takes the steps to use normal TCP/DCCP ehash
table to store SYN_RECV requests, instead of the private per-listener
hash table we had until now.

SYNACK skb are now attached to their syn_recv request socket,
so that we no longer heavily modify listener sk_wmem_alloc.

listener lock is no longer held in fast path, including
SYNCOOKIE mode.

During my tests, my server was able to process 3,500,000
SYN packets per second on one listener and still had available
cpu cycles.

That is about 2 to 3 order of magnitude what we had with older kernels.

This effort started two years ago and I am pleased to reach expectations.

We'll probably extend SO_REUSEPORT to add proper cpu/numa affinities,
so that heavy duty TCP servers can get proper siloing thanks to multi-queues
NIC.

Eric Dumazet (17):
  tcp: add a spinlock to protect struct request_sock_queue
  tcp: move qlen/young out of struct listen_sock
  tcp: move synflood_warned into struct request_sock_queue
  tcp: call sk_mark_napi_id() on the child, not the listener
  tcp/dccp: init sk_prot and call sk_node_init() in reqsk_alloc()
  tcp: cleanup tcp_v[46]_inbound_md5_hash()
  tcp: remove BUG_ON() in tcp_check_req()
  tcp: get_openreq[46]() changes
  tcp/dccp: remove inet_csk_reqsk_queue_added() timeout argument
  tcp/dccp: install syn_recv requests into ehash table
  tcp/dccp: shrink struct listen_sock
  ipv6: remove obsolete inet6 functions
  tcp: attach SYNACK messages to request sockets instead of listener
  tcp/dccp: remove struct listen_sock
  tcp: remove max_qlen_log
  tcp/dccp: add a reschedule point in inet_csk_listen_stop()
  tcp: do not lock listener to process SYN packets

 include/net/inet6_connection_sock.h |   9 --
 include/net/inet_connection_sock.h  |   9 +-
 include/net/inet_hashtables.h       |   1 +
 include/net/request_sock.h          | 132 ++++++++++--------------------
 include/net/tcp.h                   |  10 +--
 net/core/request_sock.c             |  84 +------------------
 net/dccp/ipv4.c                     |  64 +++++----------
 net/dccp/ipv6.c                     |  72 +++++-----------
 net/ipv4/inet_connection_sock.c     | 145 ++++++++------------------------
 net/ipv4/inet_diag.c                |  96 ++--------------------
 net/ipv4/inet_hashtables.c          |  14 +++-
 net/ipv4/syncookies.c               |   4 +
 net/ipv4/tcp_fastopen.c             |   4 +-
 net/ipv4/tcp_input.c                |  30 +++----
 net/ipv4/tcp_ipv4.c                 | 159 +++++++++++++-----------------------
 net/ipv4/tcp_minisocks.c            |   2 -
 net/ipv4/tcp_output.c               |  22 +++--
 net/ipv6/inet6_connection_sock.c    |  67 ---------------
 net/ipv6/tcp_ipv6.c                 | 117 +++++++++++++-------------
 net/sched/sch_fq.c                  |  12 +--
 20 files changed, 307 insertions(+), 746 deletions(-)

-- 
2.6.0.rc2.230.g3dd15c0
