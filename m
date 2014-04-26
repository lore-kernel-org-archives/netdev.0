From: Lorenzo Colitti <lorenzo@google.com>
Subject: [RFC net-next 0/4] Support UID range routing.
Date: Sat, 26 Apr 2014 13:48:21 +0900
Message-ID: <1398487705-13430-1-git-send-email-lorenzo@google.com>
Cc: hannes@stressinduktion.org, davem@davemloft.net, jpa@google.com,
	Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:64153 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750728AbaDZEsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2014 00:48:39 -0400
Received: by mail-pd0-f174.google.com with SMTP id z10so3026157pdj.19
        for <netdev@vger.kernel.org>; Fri, 25 Apr 2014 21:48:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In some environments it is useful to route packets differently
based on the user ID. This can be done with iptables owner match
and MASQUERADE, but that forces the use of iptables to fix up
parameters such as MSS and imposes a per-packet cost, plus it
breaks applications that expect end-to-end.

This patch series adds support for routing on the UID that owns
the socket and allow userspace to configure routing rules based
on UID ranges.

Points I'd like feedback on:

1. The code uses sock_i_uid, which grabs sk_callback_lock.
   Is that necessary? For example, xt_owner doesn't grab it - it
   just dereferences sk->sk_socket->file. If it is necessary, I
   don't know know how much contention it can cause. Should UID
   routing be made a config option as a result?
2. This patch defines new fib attributes (FRA_UID_START and
   FRA_UID_END) at the end of the currently-defined range.
   Should it instead replace some FRA_UNUSED_x attributes?
3. Is is a bad idea to use two attributes? I played around with
   making this an array of two integers, or a struct, but the
   results seemed uglier than the current code.

Limitations:

1. Sockets that have been closed have no UID any more. I think
   xt_owner also has this limitation - it's because the UID
   is in the struct socket, which is gone at that point. This
   could be fixed by writing the UID back into the struct sock
   sock when orphaning the socket.
2. Path MTU discovery does not (yet) specify the UID in the
   routing lookup to clone the route. This is not hard to fix
   but I haven't gotten around to it yet. A packet too big or DF
   needed packet will still affect the MTU of the socket that
   caused it though.

Tested:

Black-box tested using user-mode Linux by pointing different
UIDs to different TAP interfaces. Tested the following in IPv4
and IPv6:

- TCP inbound and outbound connections
- UDP send connect+send
- Ping
- Userspace communication using a patched IP binary:
  - UID range rule add / delete
  - Route lookup with a UID

Lorenzo Colitti (4):
  net: ipv6: Introduce flowi6_init_output.
  net: core: Add a UID range to fib rules.
  net: core: Add the UID to flowi[46]_init_output.
  net: core: Add a RTA_UID attribute to routes.

 include/net/fib_rules.h          |  6 ++++-
 include/net/flow.h               | 31 ++++++++++++++++++++++-
 include/net/ip.h                 |  1 +
 include/net/route.h              |  5 ++--
 include/uapi/linux/fib_rules.h   |  2 ++
 include/uapi/linux/rtnetlink.h   |  1 +
 net/core/fib_rules.c             | 53 ++++++++++++++++++++++++++++++++++++++--
 net/ipv4/fib_frontend.c          |  1 +
 net/ipv4/inet_connection_sock.c  |  6 +++--
 net/ipv4/ip_output.c             |  3 ++-
 net/ipv4/ping.c                  |  3 ++-
 net/ipv4/raw.c                   |  3 ++-
 net/ipv4/route.c                 | 19 +++++++++-----
 net/ipv4/syncookies.c            |  3 ++-
 net/ipv4/udp.c                   |  3 ++-
 net/ipv6/af_inet6.c              | 13 ++++------
 net/ipv6/datagram.c              | 12 ++++-----
 net/ipv6/inet6_connection_sock.c | 25 ++++++++-----------
 net/ipv6/raw.c                   |  1 +
 net/ipv6/route.c                 |  7 ++++++
 net/ipv6/syncookies.c            | 13 +++++-----
 net/ipv6/tcp_ipv6.c              | 12 ++++-----
 net/ipv6/udp.c                   |  1 +
 23 files changed, 161 insertions(+), 63 deletions(-)

-- 
1.9.1.423.g4596e3a
