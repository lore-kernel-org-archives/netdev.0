From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net-next v4 0/7] Faster SO_REUSEPORT for TCP
Date: Wed, 10 Feb 2016 11:50:34 -0500
Message-ID: <1455123041-22638-1-git-send-email-kraigatgoog@gmail.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:36610 "EHLO
	mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753037AbcBJQuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 11:50:46 -0500
Received: by mail-qk0-f177.google.com with SMTP id s68so8942848qkh.3
        for <netdev@vger.kernel.org>; Wed, 10 Feb 2016 08:50:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

This patch series complements an earlier series (6a5ef90c58da)
which added faster SO_REUSEPORT lookup for UDP sockets by
extending the feature to TCP sockets.  It uses the same
array-based data structure which allows for socket selection
after finding the first listening socket that matches an incoming
packet.  Prior to this feature, every socket in the reuseport
group needed to be found and examined before a selection could be
made.

With this series the SO_ATTACH_REUSEPORT_CBPF and
SO_ATTACH_REUSEPORT_EBPF socket options now work for TCP sockets
as well.  The test at the end of the series includes an example of
how to use these options to select a reuseport socket based on the
cpu core id handling the incoming packet.

There are several refactoring patches that precede the feature
implementation.  Only the last two patches in this series
should result in any behavioral changes.

v4
- Fix build issue when compiling IPv6 as a module.  This required
  moving the ipv6_rcv_saddr_equal into an object that is included as a
  built-in object.  I included this change in the second patch which
  adds inet6_hash since that is where ipv6_rcv_saddr_equal will
  later be called from non-module code.

v3:
- Another warning in the first patch caught by a build bot.  Return 0 in
  the no-op UDP hash function.

v2:
- In the first patched I missed a couple of hash functions that should now be
  returning int instead of void.  I missed these the first time through as it
  only generated a warning and not an error :\

Craig Gallek (7):
  sock: struct proto hash function may error
  inet: create IPv6-equivalent inet_hash function
  tcp: __tcp_hdrlen() helper
  inet: refactor inet[6]_lookup functions to take skb
  soreuseport: Prep for fast reuseport TCP socket selection
  soreuseport: fast reuseport TCP socket selection
  soreuseport: BPF selection functional test for TCP

 include/linux/tcp.h                             |   7 +-
 include/net/addrconf.h                          |   2 +
 include/net/inet6_hashtables.h                  |  13 +-
 include/net/inet_hashtables.h                   |  25 ++-
 include/net/phonet/phonet.h                     |   2 +-
 include/net/ping.h                              |   2 +-
 include/net/raw.h                               |   2 +-
 include/net/sock.h                              |   6 +-
 include/net/udp.h                               |   3 +-
 net/core/filter.c                               |   2 +-
 net/core/sock.c                                 |   1 +
 net/dccp/ipv4.c                                 |   2 +-
 net/dccp/ipv6.c                                 |   4 +-
 net/ieee802154/socket.c                         |  17 +-
 net/ipv4/af_inet.c                              |   9 +-
 net/ipv4/inet_connection_sock.c                 |  22 +-
 net/ipv4/inet_diag.c                            |   6 +-
 net/ipv4/inet_hashtables.c                      |  67 +++++-
 net/ipv4/ping.c                                 |   4 +-
 net/ipv4/raw.c                                  |   4 +-
 net/ipv4/tcp_ipv4.c                             |  10 +-
 net/ipv4/udp.c                                  |   4 +-
 net/ipv6/af_inet6.c                             |   6 +-
 net/ipv6/inet6_connection_sock.c                |   2 +
 net/ipv6/inet6_hashtables.c                     |  78 ++++++-
 net/ipv6/tcp_ipv6.c                             |  10 +-
 net/ipv6/udp.c                                  |  44 +---
 net/l2tp/l2tp_ip6.c                             |   3 +-
 net/netfilter/xt_TPROXY.c                       |  31 ++-
 net/netfilter/xt_socket.c                       |  28 ++-
 net/phonet/socket.c                             |   6 +-
 net/sctp/socket.c                               |   3 +-
 tools/testing/selftests/net/.gitignore          |   1 +
 tools/testing/selftests/net/Makefile            |   2 +-
 tools/testing/selftests/net/reuseport_bpf.c     | 117 ++++++++++-
 tools/testing/selftests/net/reuseport_bpf_cpu.c | 258 ++++++++++++++++++++++++
 36 files changed, 670 insertions(+), 133 deletions(-)
 create mode 100644 tools/testing/selftests/net/reuseport_bpf_cpu.c

-- 
2.7.0.rc3.207.g0ac5344
