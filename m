From: Ihar Hrachyshka <ihrachys@redhat.com>
Subject: [PATCH v2 3/4] arp: postpone addr_type calculation to as late as possible
Date: Thu, 18 May 2017 12:41:20 -0700
Message-ID: <774fefce840e229c1f062181ade2ea3b9a8c7eb7.1495136258.git.ihrachys@redhat.com>
References: <cover.1495136258.git.ihrachys@redhat.com>
Cc: Ihar Hrachyshka <ihrachys@redhat.com>, netdev@vger.kernel.org
To: davem@davemloft.net, ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45510 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932342AbdERTlk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 May 2017 15:41:40 -0400
In-Reply-To: <cover.1495136258.git.ihrachys@redhat.com>
In-Reply-To: <cover.1495136258.git.ihrachys@redhat.com>
References: <cover.1495136258.git.ihrachys@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The addr_type retrieval can be costly, so it's worth trying to avoid its
calculation as much as possible. This patch makes it calculated only
for gratuitous ARP packets. This is especially important since later we
may want to move is_garp calculation outside of arp_accept block, at
which point the costly operation will be executed for all setups.

The patch is the result of a discussion in net-dev:
http://marc.info/?l=linux-netdev&m=149506354216994

Suggested-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Ihar Hrachyshka <ihrachys@redhat.com>
---
 net/ipv4/arp.c | 24 +++++++++++++++++-------
 1 file changed, 17 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index ca6e1e6..c22103c 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -641,12 +641,12 @@ void arp_xmit(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(arp_xmit);
 
-static bool arp_is_garp(struct net_device *dev, int addr_type,
-			__be16 ar_op,
+static bool arp_is_garp(struct net *net, struct net_device *dev,
+			int *addr_type, __be16 ar_op,
 			__be32 sip, __be32 tip,
 			unsigned char *sha, unsigned char *tha)
 {
-	bool is_garp = tip == sip && addr_type == RTN_UNICAST;
+	bool is_garp = tip == sip;
 
 	/* Gratuitous ARP _replies_ also require target hwaddr to be
 	 * the same as source.
@@ -659,6 +659,11 @@ static bool arp_is_garp(struct net_device *dev, int addr_type,
 			tha &&
 			!memcmp(tha, sha, dev->addr_len);
 
+	if (is_garp) {
+		*addr_type = inet_addr_type_dev_table(net, dev, sip);
+		if (*addr_type != RTN_UNICAST)
+			is_garp = false;
+	}
 	return is_garp;
 }
 
@@ -859,18 +864,23 @@ static int arp_process(struct net *net, struct sock *sk, struct sk_buff *skb)
 	n = __neigh_lookup(&arp_tbl, &sip, dev, 0);
 
 	if (IN_DEV_ARP_ACCEPT(in_dev)) {
-		unsigned int addr_type = inet_addr_type_dev_table(net, dev, sip);
+		addr_type = -1;
 
 		/* Unsolicited ARP is not accepted by default.
 		   It is possible, that this option should be enabled for some
 		   devices (strip is candidate)
 		 */
-		is_garp = arp_is_garp(dev, addr_type, arp->ar_op,
+		is_garp = arp_is_garp(net, dev, &addr_type, arp->ar_op,
 				      sip, tip, sha, tha);
 
 		if (!n &&
-		    ((arp->ar_op == htons(ARPOP_REPLY)  &&
-				addr_type == RTN_UNICAST) || is_garp))
+		    (is_garp ||
+		     (arp->ar_op == htons(ARPOP_REPLY) &&
+		      (addr_type == RTN_UNICAST ||
+		       (addr_type < 0 &&
+			/* postpone calculation to as late as possible */
+			inet_addr_type_dev_table(net, dev, sip) ==
+				RTN_UNICAST)))))
 			n = __neigh_lookup(&arp_tbl, &sip, dev, 1);
 	}
 
-- 
2.9.3
