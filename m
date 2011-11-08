From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH] ipv6: drop packets when source address is multicast
Date: Tue, 08 Nov 2011 09:41:42 -0500
Message-ID: <4EB93FA6.3090709@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Kumar Sanghvi <divinekumar@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:8503 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755121Ab1KHOvm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 09:51:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC 4291 Section 2.7 says Multicast addresses must not be used as source
addresses in IPv6 packets - drop them on input so we don't process the
packet further.

Signed-off-by: Brian Haley <brian.haley@hp.com>
Reported-and-Tested-by: Kumar Sanghvi <divinekumar@gmail.com>

diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 027c7ff..a46c64e 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -111,6 +111,14 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 	    ipv6_addr_loopback(&hdr->daddr))
 		goto err;
 
+	/*
+	 * RFC4291 2.7
+	 * Multicast addresses must not be used as source addresses in IPv6
+	 * packets or appear in any Routing header.
+	 */
+	if (ipv6_addr_is_multicast(&hdr->saddr))
+		goto err;
+
 	skb->transport_header = skb->network_header + sizeof(*hdr);
 	IP6CB(skb)->nhoff = offsetof(struct ipv6hdr, nexthdr);
 
