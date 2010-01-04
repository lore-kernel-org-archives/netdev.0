From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [RFC] ipv4: support for request type gratuitous ARP
Date: Tue, 5 Jan 2010 00:04:44 +0200
Message-ID: <201001050004.45004.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:22881 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751051Ab0ADWII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 17:08:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---

I've noticed that even though we currently support response type gratuitous ARP
[response type, source mac, dest mac, source IP, source IP] *with a clean ARP table*
we do not support the request type [request type, source mac, ff:ff:ff:ff:ff:ff, source IP, source IP].

This patch makes request type work as well, but RFC2002 says that gratuitous ARP
(both request and response) must update the ARP table *if* the IP already
exists in the table:

          In either case, for a gratuitous ARP, the ARP packet MUST be
          transmitted as a local broadcast packet on the local link.  As
          specified in [16], any node receiving any ARP packet (Request or
          Reply) MUST update its local ARP cache with the Sender Protocol
          and Hardware Addresses in the ARP packet, if the receiving node
          has an entry for that IP address already in its ARP cache.  This
          requirement in the ARP protocol applies even for ARP Request
          packets, and for ARP Reply packets that do not match any ARP
          Request transmitted by the receiving node [16].

so, I am not sure if this is right. But current behavior for response type
gratuitous ARP does not seem to be covered by the RFC either.

 net/ipv4/arp.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index c95cd93..81ef2d5 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -811,8 +811,13 @@ static int arp_process(struct sk_buff *skb)
 		goto out;
 	}
 
-	if (arp->ar_op == htons(ARPOP_REQUEST) &&
-	    ip_route_input(skb, tip, sip, 0, dev) == 0) {
+	if (arp->ar_op == htons(ARPOP_REQUEST)) {
+		/* gratuitous ARP */
+		if (tip == sip) {
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
