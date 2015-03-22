From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/8] tcp listener refactoring part 15
Date: Sun, 22 Mar 2015 10:22:17 -0700
Message-ID: <1427044945-32608-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f74.google.com ([209.85.213.74]:33072 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751795AbbCVRWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 13:22:31 -0400
Received: by yhoc41 with SMTP id c41so6107744yho.0
        for <netdev@vger.kernel.org>; Sun, 22 Mar 2015 10:22:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am trying to make the final patch pushing request socks into ehash
as small as possible. In this patch series, I made various adjustments
for the SYNACK generation, allowing me to reach 1 Mpps SYNACK in my
stress test (still hitting LISTENER spinlock of course, and the syn_wait
spinlock)

I also converted the ICMP handlers a bit ahead of time :

They no longer need to get the LISTENER socket, and can use
only a lookup in ehash table. No big deal if we ignore ICMP
for requests socks before the final steps.

Eric Dumazet (8):
  inet: cache listen_sock_qlen() and read rskq_defer_accept once
  inet: remove sk_listener parameter from syn_ack_timeout()
  inet: remove some sk_listener dependencies
  net: convert syn_wait_lock to a spinlock
  ipv4: tcp: handle ICMP messages on TCP_NEW_SYN_RECV request sockets
  ipv6: tcp: handle ICMP messages on TCP_NEW_SYN_RECV request sockets
  ipv4: dccp: handle ICMP messages on DCCP_NEW_SYN_RECV request sockets
  ipv6: dccp: handle ICMP messages on DCCP_NEW_SYN_RECV request sockets

 include/linux/dccp.h             |  4 +-
 include/net/request_sock.h       | 14 ++-----
 include/net/tcp.h                |  3 +-
 net/core/request_sock.c          | 14 +++----
 net/dccp/dccp.h                  |  1 +
 net/dccp/ipv4.c                  | 72 +++++++++++++++++------------------
 net/dccp/ipv6.c                  | 41 ++++----------------
 net/ipv4/inet_connection_sock.c  | 47 ++++++++++++-----------
 net/ipv4/inet_diag.c             |  4 +-
 net/ipv4/tcp_ipv4.c              | 81 ++++++++++++++++++++--------------------
 net/ipv4/tcp_timer.c             |  8 ++--
 net/ipv6/inet6_connection_sock.c |  4 +-
 net/ipv6/tcp_ipv6.c              | 47 ++++++-----------------
 13 files changed, 146 insertions(+), 194 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
