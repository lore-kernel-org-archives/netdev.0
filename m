From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next v3 0/3] udp: reduce cache pressure
Date: Mon, 12 Jun 2017 11:23:40 +0200
Message-ID: <cover.1497026892.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57034 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752010AbdFLJYb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Jun 2017 05:24:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the most common use case, many skb fields are not used by recvmsg(), and
the few ones actually accessed lays on cold cachelines, which leads to several
cache miss per packet.

This patch series attempts to reduce such misses with different strategies:
* caching the interesting fields in the scratched space
* avoid accessing at all uninteresting fields
* prefetching

Tested using the udp_sink program by Jesper[1] as the receiver, an h/w l4 rx
hash on the ingress nic, so that the number of ingress nic rx queues hit by the
udp traffic could be controlled via ethtool -L.

The udp_sink program was bound to the first idle cpu, to get more
stable numbers.

On a single numa node receiver:

nic rx queues           vanilla                 patched kernel      delta
1                       1850 kpps               1850 kpps           0%
2                       2370 kpps               2700 kpps           13.9%
16                      2000 kpps               2220 kpps           11%

[1] https://github.com/netoptimizer/network-testing/blob/master/src/udp_sink.c

v1 -> v2:
  - replaced secpath_reset() with skb_release_head_state()
  - changed udp_dev_scratch fields types to u{32,16} variant,
    replaced bitfield with bool

v2 -> v3:
  - no changes, tested against apachebench for performances regression

Paolo Abeni (3):
  net: factor out a helper to decrement the skb refcount
  udp: avoid a cache miss on dequeue
  udp: try to avoid 2 cache miss on dequeue

 include/linux/skbuff.h |  15 +++++++
 net/core/datagram.c    |   4 +-
 net/core/skbuff.c      |  38 ++++++++++------
 net/ipv4/udp.c         | 120 ++++++++++++++++++++++++++++++++++++++++++++-----
 4 files changed, 148 insertions(+), 29 deletions(-)

-- 
2.9.4
