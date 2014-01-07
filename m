From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V2 0/3] net: Add GRO support for UDP encapsulating protocols
Date: Tue,  7 Jan 2014 17:29:51 +0200
Message-ID: <1389108594-665-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net, yanb@mellanox.com,
	shlomop@mellanox.com, Or Gerlitz <ogerlitz@mellanox.com>
To: hkchu@google.com, edumazet@google.com, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:36874 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751358AbaAGPaI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jan 2014 10:30:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These series adds GRO handlers for protocols that do UDP encapsulation, with the 
intent of being able to coalesce packets which encapsulate packets belonging to
the same TCP session.

For GRO purposes, the destination UDP port takes the role of the ether type 
field in the ethernet header or the next protocol in the IP header.

The UDP GRO handler will only attempt to coalesce packets whose destination
port is registered to have gro handler.

Patches are against net-next 4a8deae2f4653 "r8152: correct some messages" plus
Jerry's gro-gre patch which adds the gro_find_receive/complete_by_type helpers

On my setup, which is net-next (now with the mlx4 vxlan offloads patches) -- 
for single TCP session that goes through vxlan tunneling I got nice improvement
from 6.8Gbs to 11.5Gbs

TODO:
 - identify udp encapsulated packets whose inner VM packet is udp and happen
   to carry a port which has registered offloads - and flush it.

 - invoke the udp offload protocol de-registration from the vxlan driver from 
   sleepable context

Or Gerlitz (3):
  net: Add GRO support for UDP encapsulating protocols
  net: Export gro_find_by_type helpers
  net: Add GRO support for vxlan traffic

 drivers/net/vxlan.c    |  101 +++++++++++++++++++++++++++++++++++++++++++++++-
 include/net/protocol.h |    6 +++
 net/core/dev.c         |    2 +
 net/ipv4/protocol.c    |   21 ++++++++++
 net/ipv4/udp_offload.c |   69 ++++++++++++++++++++++++++++++++
 5 files changed, 197 insertions(+), 2 deletions(-)
