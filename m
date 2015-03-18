From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/6] inet: tcp listener refactoring, part 13
Date: Wed, 18 Mar 2015 14:05:32 -0700
Message-ID: <1426712738-23395-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f201.google.com ([209.85.213.201]:33416 "EHLO
	mail-ig0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933160AbbCRVFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 17:05:41 -0400
Received: by igjz20 with SMTP id z20so3404784igj.0
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2015 14:05:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inet_hash functions are in a bad state : Too much IPv6/IPv4 copy/pasting.

Lets refactor a bit.

Idea is that we do not want to have an equivalent of inet_csk(sk)->icsk_af_ops
for request socks in order to be able to use the right variant.

In this patch series, I started to let IPv6/IPv4 converge to common helpers.

Idea is to use ipv6_addr_set_v4mapped() even for AF_INET sockets, so that
we can test
       if (sk->sk_family == AF_INET6 &&
           !ipv6_addr_v4mapped(&sk->sk_v6_daddr))
to tell if we deal with an IPv6 socket, or IPv4 one, at least in slow paths.

Ideally, we could save 8 bytes per struct sock_common, if we
alias skc_daddr & skc_rcv_saddr to skc_v6_daddr[3]/skc_v6_rcv_saddr[3].


Eric Dumazet (6):
  netns: constify net_hash_mix() and various callers
  net: introduce sk_ehashfn() helper
  inet: add IPv6 support to sk_ehashfn()
  ipv6: get rid of __inet6_hash()
  inet: get rid of last __inet_hash_connect() argument
  inet: request sock should init IPv6/IPv4 addresses

 include/linux/udp.h            |  2 +-
 include/net/inet6_hashtables.h |  2 --
 include/net/inet_hashtables.h  | 32 ++++++++++++++++++-----
 include/net/netns/hash.h       |  4 +--
 include/net/request_sock.h     |  5 ++++
 net/dccp/ipv4.c                | 13 +++++-----
 net/dccp/ipv6.c                | 27 +++-----------------
 net/ipv4/devinet.c             |  2 +-
 net/ipv4/inet_diag.c           |  4 +--
 net/ipv4/inet_hashtables.c     | 55 ++++++++++++++++++++-------------------
 net/ipv4/ping.c                |  6 ++---
 net/ipv4/syncookies.c          |  4 +--
 net/ipv4/tcp_ipv4.c            | 16 ++++++------
 net/ipv4/udp.c                 | 10 ++++----
 net/ipv6/inet6_hashtables.c    | 58 +++---------------------------------------
 net/ipv6/tcp_ipv6.c            | 28 +++-----------------
 net/ipv6/udp.c                 | 16 ++++++------
 17 files changed, 110 insertions(+), 174 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
