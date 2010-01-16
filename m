From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [PATCH v2] ipv4: support for request type gratuitous ARP
Date: Sun, 17 Jan 2010 00:18:54 +0200
Message-ID: <1263680334-1770-1-git-send-email-opurdila@ixiacom.com>
References: <20100110.132105.179935794.davem@davemloft.net>
Cc: netdev@vger.kernel.org, Laurent Chavey <chavey@google.com>,
	Octavian Purdila <opurdila@ixiacom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:29047 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752496Ab0APWWc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jan 2010 17:22:32 -0500
In-Reply-To: <20100110.132105.179935794.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Even though we currently support response type gratuitous ARP
[response type, source mac, dest mac, source IP, source IP] we do not
support the request type [request type, source mac, ff:ff:ff:ff:ff:ff,
source IP, source IP].

RFC2002 says:

     In either case, for a gratuitous ARP, the ARP packet MUST be
     transmitted as a local broadcast packet on the local link.  As
     specified in [16], any node receiving any ARP packet (Request or
     Reply) MUST update its local ARP cache with the Sender Protocol
     and Hardware Addresses in the ARP packet, if the receiving node
     has an entry for that IP address already in its ARP cache.  This
     requirement in the ARP protocol applies even for ARP Request
     packets, and for ARP Reply packets that do not match any ARP
     Request transmitted by the receiving node [16].

This patch adds support for request type gratuitous ARP, but due to
security reasons the ARP table is updated only if the per device
ARP_ACCEPT option is enabled.

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 net/ipv4/arp.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index c95cd93..588fed8 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -811,8 +811,13 @@ static int arp_process(struct sk_buff *skb)
 		goto out;
 	}
 
-	if (arp->ar_op == htons(ARPOP_REQUEST) &&
-	    ip_route_input(skb, tip, sip, 0, dev) == 0) {
+	if (arp->ar_op == htons(ARPOP_REQUEST)) {
+		/* gratuitous ARP */
+		if (tip == sip && IPV4_DEVCONF_ALL(dev_net(dev), ARP_ACCEPT)) {
+			n = neigh_event_ns(&arp_tbl, sha, &sip, dev);
+			goto update;
+		} else if (ip_route_input(skb, tip, sip, 0, dev) != 0)
+			goto update_lookup;
 
 		rt = skb_rtable(skb);
 		addr_type = rt->rt_type;
@@ -853,6 +858,7 @@ static int arp_process(struct sk_buff *skb)
 		}
 	}
 
+update_lookup:
 	/* Update our ARP tables */
 
 	n = __neigh_lookup(&arp_tbl, &sip, dev, 0);
@@ -868,6 +874,7 @@ static int arp_process(struct sk_buff *skb)
 			n = __neigh_lookup(&arp_tbl, &sip, dev, 1);
 	}
 
+update:
 	if (n) {
 		int state = NUD_REACHABLE;
 		int override;
-- 
1.5.6.5

