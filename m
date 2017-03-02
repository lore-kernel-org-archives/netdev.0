From: <tomasz.dzieciol@nokia.com>
Subject: [PATCH] arp: Race condition in gratuitous ARP reception handling.
Date: Thu, 2 Mar 2017 14:59:47 +0100
Message-ID: <1488463187-17365-1-git-send-email-tomasz.dzieciol@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr20098.outbound.protection.outlook.com ([40.107.2.98]:49664
        "EHLO EUR02-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752560AbdCBOB1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 2 Mar 2017 09:01:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tomasz Dzieciol <tomasz.dzieciol@nokia.com>

Fix an issue where is_garp variable is not set when arp_accept option is
disabled for a net device. There might be a situation where gratuitous ARP
will be ignored when an existing neighbour is updated in a time smaller
than LOCKTIME (for example by a timer - transition between states).

Signed-off-by: Tomasz Dzieciol <tomasz.dzieciol@nokia.com>
---
 net/ipv4/arp.c | 24 +++++++++++++++++++++---
 1 file changed, 21 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 51b27ae..9fd23c9 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -641,6 +641,13 @@ void arp_xmit(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(arp_xmit);
 
+static inline bool arp_is_gratuitous(unsigned int addr_type,
+				     int op, __be32 sip, __be32 tip)
+{
+	return op == ARPOP_REQUEST && tip == sip &&
+		addr_type == RTN_UNICAST;
+}
+
 /*
  *	Process an arp request.
  */
@@ -836,19 +843,30 @@ static int arp_process(struct net *net, struct sock *sk, struct sk_buff *skb)
 	n = __neigh_lookup(&arp_tbl, &sip, dev, 0);
 
 	if (IN_DEV_ARP_ACCEPT(in_dev)) {
-		unsigned int addr_type = inet_addr_type_dev_table(net, dev, sip);
+		unsigned int addr_type = inet_addr_type_dev_table(net,
+								  dev, sip);
 
 		/* Unsolicited ARP is not accepted by default.
 		   It is possible, that this option should be enabled for some
 		   devices (strip is candidate)
 		 */
-		is_garp = arp->ar_op == htons(ARPOP_REQUEST) && tip == sip &&
-			  addr_type == RTN_UNICAST;
+		is_garp = arp_is_gratuitous(addr_type, ntohs(arp->ar_op),
+					    sip, tip);
 
 		if (!n &&
 		    ((arp->ar_op == htons(ARPOP_REPLY)  &&
 				addr_type == RTN_UNICAST) || is_garp))
 			n = __neigh_lookup(&arp_tbl, &sip, dev, 1);
+	} else if (n) {
+		unsigned int addr_type = inet_addr_type_dev_table(net,
+								  dev, sip);
+
+		/* If the ARP table already contains the IP address of the
+		   gratuitous arp frame, the arp table will be updated
+		   regardless if this setting is on or off.
+		 */
+		is_garp = arp_is_gratuitous(addr_type, ntohs(arp->ar_op),
+					    sip, tip);
 	}
 
 	if (n) {
-- 
2.5.0
