From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net] ipv6: drop non loopback packets claiming to originate from ::1
Date: Fri, 14 Apr 2017 20:22:43 +0200
Message-ID: <20170414182243.24506-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:55600 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752042AbdDNSWZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 14:22:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We lack a saddr check for ::1. This causes security issues e.g. with acls
permitting connections from ::1 because of assumption that these originate
from local machine.

Assuming a source address of ::1 is local seems reasonable.
RFC4291 doesn't allow such a source address either, so drop such packets.

Reported-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv6/ip6_input.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index aacfb4bce153..c45b12b4431c 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -122,11 +122,14 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 			max_t(unsigned short, 1, skb_shinfo(skb)->gso_segs));
 	/*
 	 * RFC4291 2.5.3
+	 * The loopback address must not be used as the source address in IPv6
+	 * packets that are sent outside of a single node. [..]
 	 * A packet received on an interface with a destination address
 	 * of loopback must be dropped.
 	 */
-	if (!(dev->flags & IFF_LOOPBACK) &&
-	    ipv6_addr_loopback(&hdr->daddr))
+	if ((ipv6_addr_loopback(&hdr->saddr) ||
+	     ipv6_addr_loopback(&hdr->daddr)) &&
+	     !(dev->flags & IFF_LOOPBACK))
 		goto err;
 
 	/* RFC4291 Errata ID: 3480
-- 
2.10.2
