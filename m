From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC] net: ipv4: drop unicast encapsulated in L2 multicast
Date: Thu, 21 Aug 2014 19:22:27 +0200
Message-ID: <1408641747-22199-1-git-send-email-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:37650 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751997AbaHURZD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Aug 2014 13:25:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

RFC 1122 says that unicast packets encapsulated in broadcast
link-layer packets should be dropped. Implement that, but also
extend it to link-layer multicast packets.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 net/ipv4/route.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index eaa4b000c7b4..c374fcc73ee0 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1710,6 +1710,23 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 		goto no_route;
 	}
 
+	/* RFC 1122 3.3.6:
+	 *
+	 *   When a host sends a datagram to a link-layer broadcast address,
+	 *   the IP destination address MUST be a legal IP broadcast or IP
+	 *   multicast address.
+	 *
+	 *   A host SHOULD silently discard a datagram that is received via
+	 *   a link-layer broadcast (see Section 2.4) but does not specify
+	 *   an IP multicast or broadcast destination address.
+	 *
+	 * We also do this for link-layer multicast.
+	 */
+	if ((skb->pkt_type == PACKET_BROADCAST ||
+	     skb->pkt_type == PACKET_MULTICAST) &&
+	    res.type != RTN_BROADCAST)
+		goto e_inval;
+
 	if (res.type == RTN_BROADCAST)
 		goto brd_input;
 
-- 
2.0.0
