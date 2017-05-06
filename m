From: Paolo Abeni <pabeni@redhat.com>
Subject: [RFC PATCH 0/3] udp: scalability improvements
Date: Sat,  6 May 2017 22:42:35 +0200
Message-ID: <cover.1494103184.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34244 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750780AbdEFUnv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 6 May 2017 16:43:51 -0400
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

The measured overall gain under udp flood is in the 20-35% range depending on
the numa layout and the number of ingress queue used by the relevant nic.

On a single numa node host, the peak tput is now reached when the traffic
targeting the udp socket uses multiple nic rx queues, while on current net-next
the tput always decreases when moving from a single rx queue to multiple ones.


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
