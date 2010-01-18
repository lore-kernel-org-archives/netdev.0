From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [net-next PATCH v3] ipv4: allow warming up the ARP cache with request type gratuitous ARP
Date: Tue, 19 Jan 2010 00:58:44 +0200
Message-ID: <201001190058.44495.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Julian Anastasov <ja@ssi.bg>, Laurent Chavey <chavey@google.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:1702 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756223Ab0ARXCI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2010 18:02:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the per device ARP_ACCEPT option is enable, currently we only allow
creating new ARP cache entries for response type gratuitous ARP.

Allowing gratuitous ARP to create new ARP entries (not only to update
existing ones) is useful when we want to avoid unnecessary delays for
the first packet of a stream.

This patch allows request type gratuitous ARP to create new ARP cache
entries as well. This is useful when we want to populate the ARP cache
entries for a large number of hosts on the same LAN.

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 Documentation/networking/ip-sysctl.txt |   15 ++++++++++++---
 net/ipv4/arp.c                         |    3 ++-
 2 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index c532884..2dc7a1d 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -852,9 +852,18 @@ arp_notify - BOOLEAN
 	    or hardware address changes.
 
 arp_accept - BOOLEAN
-	Define behavior when gratuitous arp replies are received:
-	0 - drop gratuitous arp frames
-	1 - accept gratuitous arp frames
+	Define behavior for gratuitous ARP frames who's IP is not
+	already present in the ARP table:
+	0 - don't create new entries in the ARP table
+	1 - create new entries in the ARP table
+
+	Both replies and requests type gratuitous arp will trigger the
+	ARP table to be updated, if this setting is on.
+
+	If the ARP table already contains the IP address of the
+	gratuitous arp frame, the arp table will be updated regardless
+	if this setting is on or off.
+
 
 app_solicit - INTEGER
 	The maximum number of probes to send to the user space ARP daemon
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 0787092..1940b4d 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -907,7 +907,8 @@ static int arp_process(struct sk_buff *skb)
 		   devices (strip is candidate)
 		 */
 		if (n == NULL &&
-		    arp->ar_op == htons(ARPOP_REPLY) &&
+		    (arp->ar_op == htons(ARPOP_REPLY) ||
+		     (arp->ar_op == htons(ARPOP_REQUEST) && tip == sip)) &&
 		    inet_addr_type(net, sip) == RTN_UNICAST)
 			n = __neigh_lookup(&arp_tbl, &sip, dev, 1);
 	}
-- 
1.5.6.5

