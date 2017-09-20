From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 0/5] net: introduce noref sk
Date: Wed, 20 Sep 2017 18:54:00 +0200
Message-ID: <cover.1505926196.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52526 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750938AbdITQ6J (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 20 Sep 2017 12:58:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series introduce the infrastructure to store inside the skb a socket
pointer without carrying a refcount to the socket.

Such infrastructure is then used in the network receive path - and
specifically the early demux operation.

This allows the UDP early demux to perform a full lookup for UDP sockets,
with many benefits:

- the UDP early demux code is now much simpler
- the early demux does not hit any performance penalties in case of UDP hash
  table collision - previously the early demux performed a partial, unsuccesful,
  lookup
- early demux is now operational also for unconnected sockets.

This infrastrcture will be used in follow-up series to allow dst caching for
unconnected UDP sockets, and than to extend the same features to TCP listening
sockets.

Paolo Abeni (5):
  net: add support for noref skb->sk
  net: allow early demux to fetch noref socket
  udp: do not touch socket refcount in early demux
  net: add simple socket-like dst cache helpers
  udp: perform full socket lookup in early demux

 include/linux/skbuff.h           | 30 +++++++++++++++
 include/linux/udp.h              |  2 +
 include/net/dst.h                | 12 ++++++
 net/core/dst.c                   | 16 ++++++++
 net/core/sock.c                  |  6 +++
 net/ipv4/ip_input.c              | 12 ++++++
 net/ipv4/ipmr.c                  | 18 +++++++--
 net/ipv4/netfilter/nf_dup_ipv4.c |  3 ++
 net/ipv4/udp.c                   | 80 ++++++++++++++++------------------------
 net/ipv6/ip6_input.c             |  7 +++-
 net/ipv6/netfilter/nf_dup_ipv6.c |  3 ++
 net/ipv6/udp.c                   | 67 ++++++++++-----------------------
 net/netfilter/nf_queue.c         |  3 ++
 13 files changed, 159 insertions(+), 100 deletions(-)

-- 
2.13.5
