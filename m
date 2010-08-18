From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 4/8] net: rps: use proto_ports_offset() to handle the AH message correctly
Date: Wed, 18 Aug 2010 13:04:32 +0800
Message-ID: <1282107872-3546-1-git-send-email-xiaosuo@gmail.com>
Cc: netdev@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:63527 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740Ab0HRFEn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 01:04:43 -0400
Received: by pvg2 with SMTP id 2so56838pvg.19
        for <netdev@vger.kernel.org>; Tue, 17 Aug 2010 22:04:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SPI isn't at the beginning of an AH message.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/core/dev.c |   23 +++++++----------------
 1 file changed, 7 insertions(+), 16 deletions(-)
diff --git a/net/core/dev.c b/net/core/dev.c
index b7c5309..ba248f4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2266,7 +2266,7 @@ static inline void ____napi_schedule(struct softnet_data *sd,
  */
 __u32 __skb_get_rxhash(struct sk_buff *skb)
 {
-	int nhoff, hash = 0;
+	int nhoff, hash = 0, poff;
 	struct ipv6hdr *ip6;
 	struct iphdr *ip;
 	u8 ip_proto;
@@ -2306,24 +2306,15 @@ __u32 __skb_get_rxhash(struct sk_buff *skb)
 		goto done;
 	}
 
-	switch (ip_proto) {
-	case IPPROTO_TCP:
-	case IPPROTO_UDP:
-	case IPPROTO_DCCP:
-	case IPPROTO_ESP:
-	case IPPROTO_AH:
-	case IPPROTO_SCTP:
-	case IPPROTO_UDPLITE:
-		if (pskb_may_pull(skb, (ihl * 4) + 4 + nhoff)) {
-			ports.v32 = * (__force u32 *) (skb->data + nhoff +
-						       (ihl * 4));
+	ports.v32 = 0;
+	poff = proto_ports_offset(ip_proto);
+	if (poff >= 0) {
+		nhoff += ihl * 4 + poff;
+		if (pskb_may_pull(skb, nhoff + 4)) {
+			ports.v32 = * (__force u32 *) (skb->data + nhoff);
 			if (ports.v16[1] < ports.v16[0])
 				swap(ports.v16[0], ports.v16[1]);
-			break;
 		}
-	default:
-		ports.v32 = 0;
-		break;
 	}
 
 	/* get a consistent hash (same value on both flow directions) */
