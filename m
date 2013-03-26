From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] ipv6: don't accept node local multicast traffic from the wire
Date: Tue, 26 Mar 2013 19:13:34 +0100
Message-ID: <20130326181334.GH29705@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: erik.hugne@ericsson.com, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:60014 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752345Ab3CZSNf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 14:13:35 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Erik Hugne's errata proposal (Errata ID: 3480) to RFC4291 has been
verified: http://www.rfc-editor.org/errata_search.php?eid=3480

We have to check for pkt_type and loopback flag because either the
packets are allowed to travel over the loopback interface (in which case
pkt_type is PACKET_HOST and IFF_LOOPBACK flag is set) or they travel
over a non-loopback interface back to us (in which case PACKET_TYPE is
PACKET_LOOPBACK and IFF_LOOPBACK flag is not set).

Cc: Erik Hugne <erik.hugne@ericsson.com>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/ip6_input.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index e33fe0a..2bab2aa 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -118,6 +118,18 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 	    ipv6_addr_loopback(&hdr->daddr))
 		goto err;
 
+	/* RFC4291 Errata ID: 3480
+	 * Interface-Local scope spans only a single interface on a
+	 * node and is useful only for loopback transmission of
+	 * multicast.  Packets with interface-local scope received
+	 * from another node must be discarded.
+	 */
+	if (!(skb->pkt_type == PACKET_LOOPBACK ||
+	      dev->flags & IFF_LOOPBACK) &&
+	    ipv6_addr_is_multicast(&hdr->daddr) &&
+	    IPV6_ADDR_MC_SCOPE(&hdr->daddr) == 1)
+		goto err;
+
 	/* RFC4291 2.7
 	 * Nodes must not originate a packet to a multicast address whose scope
 	 * field contains the reserved value 0; if such a packet is received, it
-- 
1.8.1.4
