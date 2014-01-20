From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V5 0/3] net: Add GRO support for UDP encapsulating protocols
Date: Mon, 20 Jan 2014 13:59:18 +0200
Message-ID: <1390219161-9881-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, hkchu@google.com, edumazet@google.com,
	herbert@gondor.apana.org.au, yanb@mellanox.com,
	shlomop@mellanox.com, therbert@google.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:34346 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751665AbaATL7a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jan 2014 06:59:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds GRO handlers for protocols that do UDP encapsulation, with the
intent of being able to coalesce packets which encapsulate packets belonging to
the same TCP session.

For GRO purposes, the destination UDP port takes the role of the ether type
field in the ethernet header or the next protocol in the IP header.

The UDP GRO handler will only attempt to coalesce packets whose destination
port is registered to have gro handler.

The patches done against net-next 75e4364f67 "net: stmmac: fix NULL pointer 
dereference in stmmac_get_tx_hwtstamp"

Or.

v4 --> v5 changes:
  - followed Eric's directives to avoid using atomic get/put ops on the
    udp gro receive and complete callbacks and instead keep the rcu_read_lock
    when calling the next handler on the chain.

v3 --> v4 changes:

  - applied feedback from Tom on some micro-optimizations that save 
    branches and goto directives in the udp gro logic

 - applied feedback from Eric on correct RCU programming for the 
   add/remove flow of the upper protocols udp gro handlers


v2 --> v3 changes:

 - moved to use linked list to store the udp gro handlers, this solves the
   problem of consuming 512KB of memory for the handlers.

 - use a mark on the skb GRO CB data to disallow running the udp gro_receive twice
   on a packet, this solves the problem of udp encapsulated packets whose inner VM
   packet is udp and happen to carry a port which has registered offloads - and flush it.

 - invoke the udp offload protocol registration and de-registration from the vxlan driver
   in a sleepable context 


Or Gerlitz (3):
  net: Add GRO support for UDP encapsulating protocols
  net: Export gro_find_by_type helpers
  net: Add GRO support for vxlan traffic

 drivers/net/vxlan.c       |  117 ++++++++++++++++++++++++++++++++++--
 include/linux/netdevice.h |   10 +++-
 include/net/protocol.h    |    3 +
 include/net/vxlan.h       |    1 +
 net/core/dev.c            |    3 +
 net/ipv4/udp_offload.c    |  143 +++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 269 insertions(+), 8 deletions(-)
