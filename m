From: Ihar Hrachyshka <ihrachys@redhat.com>
Subject: [PATCH 1/2] arp: decompose is_garp logic into a separate function
Date: Wed, 17 May 2017 14:33:06 -0700
Message-ID: <dfd5a04adf58a1f06a18645e00459a42b0cd40cb.1495056542.git.ihrachys@redhat.com>
References: <cover.1495056542.git.ihrachys@redhat.com>
Cc: Ihar Hrachyshka <ihrachys@redhat.com>, netdev@vger.kernel.org
To: davem@davemloft.net, ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53238 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752318AbdEQVdm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 17 May 2017 17:33:42 -0400
In-Reply-To: <cover.1495056542.git.ihrachys@redhat.com>
In-Reply-To: <cover.1495056542.git.ihrachys@redhat.com>
References: <cover.1495056542.git.ihrachys@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code is quite involving already to earn a separate function for
itself. If anything, it helps arp_process readability.

Signed-off-by: Ihar Hrachyshka <ihrachys@redhat.com>
---
 net/ipv4/arp.c | 35 +++++++++++++++++++++++------------
 1 file changed, 23 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index d54345a..3f06201 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -641,6 +641,27 @@ void arp_xmit(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(arp_xmit);
 
+static bool arp_is_garp(struct net_device *dev, int addr_type,
+			__be16 ar_op,
+			__be32 sip, __be32 tip,
+			unsigned char *sha, unsigned char *tha)
+{
+	bool is_garp = tip == sip && addr_type == RTN_UNICAST;
+
+	/* Unsolicited ARP _replies_ also require target hwaddr to be
+	 * the same as source.
+	 */
+	if (is_garp && ar_op == htons(ARPOP_REPLY))
+		is_garp =
+			/* IPv4 over IEEE 1394 doesn't provide target
+			 * hardware address field in its ARP payload.
+			 */
+			tha &&
+			!memcmp(tha, sha, dev->addr_len);
+
+	return is_garp;
+}
+
 /*
  *	Process an arp request.
  */
@@ -844,18 +865,8 @@ static int arp_process(struct net *net, struct sock *sk, struct sk_buff *skb)
 		   It is possible, that this option should be enabled for some
 		   devices (strip is candidate)
 		 */
-		is_garp = tip == sip && addr_type == RTN_UNICAST;
-
-		/* Unsolicited ARP _replies_ also require target hwaddr to be
-		 * the same as source.
-		 */
-		if (is_garp && arp->ar_op == htons(ARPOP_REPLY))
-			is_garp =
-				/* IPv4 over IEEE 1394 doesn't provide target
-				 * hardware address field in its ARP payload.
-				 */
-				tha &&
-				!memcmp(tha, sha, dev->addr_len);
+		is_garp = arp_is_garp(dev, addr_type, arp->ar_op,
+				      sip, tip, sha, tha);
 
 		if (!n &&
 		    ((arp->ar_op == htons(ARPOP_REPLY)  &&
-- 
2.9.3
