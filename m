From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/4] tcp: better smp listener behavior
Date: Thu,  8 Oct 2015 08:37:03 -0700
Message-ID: <1444318627-27883-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34969 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933809AbbJHPhP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 11:37:15 -0400
Received: by pacgl6 with SMTP id gl6so1649125pac.2
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 08:37:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As promised in last patch series, we implement a better SO_REUSEPORT
strategy, based on cpu affinities if selected by the application.

We also moved sk_refcnt out of the cache line containing the lookup
keys, as it was considerably slowing down smp operations because
of false sharing. This was simpler than converting listen sockets
to conventional RCU (to avoid sk_refcnt dirtying)

Could process 6.0 Mpps SYN instead of 4.2 Mpps on my test server.

Eric Dumazet (4):
  net: SO_INCOMING_CPU setsockopt() support
  net: align sk_refcnt on 128 bytes boundary
  net: shrink struct sock and request_sock by 8 bytes
  tcp: shrink tcp_timewait_sock by 8 bytes

 include/linux/tcp.h              |  4 ++--
 include/net/inet_timewait_sock.h |  2 +-
 include/net/request_sock.h       |  7 +++----
 include/net/sock.h               | 37 +++++++++++++++++++++++++++----------
 net/core/sock.c                  |  5 +++++
 net/ipv4/inet_hashtables.c       |  5 +++++
 net/ipv4/syncookies.c            |  4 ++--
 net/ipv4/tcp_input.c             |  2 +-
 net/ipv4/tcp_ipv4.c              |  2 +-
 net/ipv4/tcp_minisocks.c         | 18 +++++++++---------
 net/ipv4/tcp_output.c            |  2 +-
 net/ipv4/udp.c                   | 12 +++++++++++-
 net/ipv6/inet6_hashtables.c      |  5 +++++
 net/ipv6/syncookies.c            |  4 ++--
 net/ipv6/tcp_ipv6.c              |  2 +-
 net/ipv6/udp.c                   | 11 +++++++++++
 16 files changed, 87 insertions(+), 35 deletions(-)

-- 
2.6.0.rc2.230.g3dd15c0
