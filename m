From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net 0/2] udp: fix early demux for mcast packets
Date: Thu, 28 Sep 2017 15:51:35 +0200
Message-ID: <cover.1506606381.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59298 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752859AbdI1Nwg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 28 Sep 2017 09:52:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the early demux callbacks do not perform source address validation.
This is not an issue for TCP or UDP unicast, where the early demux
is only allowed for connected sockets and the source address is validated
for the first packet and never change.

The UDP protocol currently allows early demux also for unconnected multicast
sockets, and we are not currently doing any validation for them, after that
the first packet lands on the socket: beyond ignoring the rp_filter - if 
enabled - any kind of martian sources are also allowed.

This series addresses the issue allowing the early demux callback to return an
error code, and performing the proper checks for unconnected UDP multicast
sockets before leveraging the rx dst cache.

Alternatively we could disable the early demux for unconnected mcast sockets,
but that would cause relevant performance regression - around 50% - while with
this series, with full rp_filter in place, we keep the regression to a more 
moderate level.

Paolo Abeni (2):
  IPv4: early demux can return an error code
  udp: perform source validation for mcast early demux

 include/net/protocol.h |  4 ++--
 include/net/route.h    |  4 +++-
 include/net/tcp.h      |  2 +-
 include/net/udp.h      |  2 +-
 net/ipv4/ip_input.c    | 25 +++++++++++++++----------
 net/ipv4/route.c       | 46 ++++++++++++++++++++++++++--------------------
 net/ipv4/tcp_ipv4.c    |  9 +++++----
 net/ipv4/udp.c         | 24 ++++++++++++++++++------
 8 files changed, 71 insertions(+), 45 deletions(-)

-- 
2.13.5
