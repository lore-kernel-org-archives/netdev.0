From: Ihar Hrachyshka <ihrachys@redhat.com>
Subject: [PATCH 2/2] arp: always override existing neigh entries with gratuitous ARP
Date: Wed, 17 May 2017 14:33:07 -0700
Message-ID: <8d14e8bd5c4d988f073eb14307bbb8491896414c.1495056542.git.ihrachys@redhat.com>
References: <cover.1495056542.git.ihrachys@redhat.com>
Cc: Ihar Hrachyshka <ihrachys@redhat.com>, netdev@vger.kernel.org
To: davem@davemloft.net, ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6065 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753847AbdEQVdn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 17 May 2017 17:33:43 -0400
In-Reply-To: <cover.1495056542.git.ihrachys@redhat.com>
In-Reply-To: <cover.1495056542.git.ihrachys@redhat.com>
References: <cover.1495056542.git.ihrachys@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, when arp_accept is 1, we always override existing neigh
entries with incoming gratuitous ARP replies. Otherwise, we override
them only if new replies satisfy _locktime_ conditional (packets arrive
not earlier than _locktime_ seconds since the last update to the neigh
entry).

The idea behind locktime is to pick the very first (=> close) reply
received in a unicast burst when ARP proxies are used. This helps to
avoid ARP thrashing where Linux would switch back and forth from one
proxy to another.

This logic has nothing to do with gratuitous ARP replies that are
generally not aligned in time when multiple IP address carriers send
them into network.

This patch enforces overriding of existing neigh entries by all incoming
gratuitous ARP packets, irrespective of their time of arrival. This will
make the kernel honour all incoming gratuitous ARP packets.

Signed-off-by: Ihar Hrachyshka <ihrachys@redhat.com>
---
 net/ipv4/arp.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 3f06201..97ea9d8 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -858,16 +858,16 @@ static int arp_process(struct net *net, struct sock *sk, struct sk_buff *skb)
 
 	n = __neigh_lookup(&arp_tbl, &sip, dev, 0);
 
-	if (IN_DEV_ARP_ACCEPT(in_dev)) {
-		unsigned int addr_type = inet_addr_type_dev_table(net, dev, sip);
-
-		/* Unsolicited ARP is not accepted by default.
-		   It is possible, that this option should be enabled for some
-		   devices (strip is candidate)
-		 */
+	if (n || IN_DEV_ARP_ACCEPT(in_dev)) {
+		addr_type = inet_addr_type_dev_table(net, dev, sip);
 		is_garp = arp_is_garp(dev, addr_type, arp->ar_op,
 				      sip, tip, sha, tha);
+	}
 
+	if (IN_DEV_ARP_ACCEPT(in_dev)) {
+		/* It is possible, that this option should be enabled for some
+		 * devices (strip is candidate)
+		 */
 		if (!n &&
 		    ((arp->ar_op == htons(ARPOP_REPLY)  &&
 				addr_type == RTN_UNICAST) || is_garp))
-- 
2.9.3
