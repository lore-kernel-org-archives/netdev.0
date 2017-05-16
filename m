From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next v2 0/3] udp: scalability improvements
Date: Tue, 16 May 2017 11:20:12 +0200
Message-ID: <cover.1494881617.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39658 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750795AbdEPJVK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 16 May 2017 05:21:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series implement an idea suggested by Eric Dumazet to
reduce the contention of the udp sk_receive_queue lock when the socket is
under flood.

An ancillary queue is added to the udp socket, and the socket always
tries first to read packets from such queue. If it's empty, we splice
the content from sk_receive_queue into the ancillary queue.

The first patch introduces some helpers to keep the udp code small, and the
following two implement the ancillary queue strategy. The code is split
to hopefully help the reviewing process.

The measured overall gain under udp flood is up to the 30% depending on
the numa layout and the number of ingress queue used by the relevant nic.

The performance numbers have been gathered using pktgen as sender, with 64
bytes packets, random src port on a host b2b connected via a 10Gbs link
with the dut.

The receiver used the udp_sink program by Jesper [1] and an h/w l4 rx hash on
the ingress nic, so that the number of ingress nic rx queues hit by the udp
traffic could be controlled via ethtool -L.

The udp_sink program was bound to the first idle cpu, to get more
stable numbers.

On a single numa node receiver:

nic rx queues           vanilla                 patched kernel
1                       1820 kpps               1900 kpps
2                       1950 kpps               2500 kpps
16                      1670 kpps               2120 kpps

When using a single nic rx queue, busy polling was also enabled,
elsewhere, in the above scenario, the bh processing becomes the bottle-neck
and this produces large artifacts in the measured performances (e.g.
improving the udp sink run time, decreases the overall tput, since more
action from the scheduler comes into play).

[1] https://github.com/netoptimizer/network-testing/blob/master/src/udp_sink.c

v1 -> v2:
  Patches 1/3 and 2/3 are unchanged, in patch 3/3 the rx_queue_lock_held param
  of udp_rmem_release() is now a bool.

Paolo Abeni (3):
  net/sock: factor out dequeue/peek with offset code
  udp: use a separate rx queue for packet reception
  udp: keep the sk_receive_queue held when splicing

 include/linux/skbuff.h |   7 +++
 include/linux/udp.h    |   3 +
 include/net/sock.h     |   4 +-
 include/net/udp.h      |   9 +--
 include/net/udplite.h  |   2 +-
 net/core/datagram.c    |  90 +++++++++++++++------------
 net/ipv4/udp.c         | 162 +++++++++++++++++++++++++++++++++++++++++++------
 net/ipv6/udp.c         |   3 +-
 8 files changed, 211 insertions(+), 69 deletions(-)

-- 
2.9.3
