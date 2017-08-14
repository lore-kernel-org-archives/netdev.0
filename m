From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [net 1/1] tipc: accept PACKET_MULTICAST packets
Date: Mon, 14 Aug 2017 17:55:56 +0200
Message-ID: <1502726156-5536-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <parthasarathy.bhuvaragan@ericsson.com>, <ying.xue@windriver.com>,
        <tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:61542 "EHLO
        sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753000AbdHNP4V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 11:56:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On L2 bearers, the TIPC broadcast function is sending out packets using
the corresponding L2 broadcast address. At reception, we filter such
packets under the assumption that they will also be delivered as
broadcast packets.

This assumption doesn't always hold true. Under high load, we have seen
that a switch may convert the destination address and deliver the packet
as a PACKET_MULTICAST, something leading to inadvertently dropped
packets and a stale and reset broadcast link.

We fix this by extending the reception filtering to accept packets of
type PACKET_MULTICAST.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bearer.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index d174ee3..767e053 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -596,7 +596,7 @@ static int tipc_l2_rcv_msg(struct sk_buff *skb, struct net_device *dev,
 	rcu_read_lock();
 	b = rcu_dereference_rtnl(dev->tipc_ptr);
 	if (likely(b && test_bit(0, &b->up) &&
-		   (skb->pkt_type <= PACKET_BROADCAST))) {
+		   (skb->pkt_type <= PACKET_MULTICAST))) {
 		skb->next = NULL;
 		tipc_rcv(dev_net(dev), skb, b);
 		rcu_read_unlock();
-- 
2.1.4
