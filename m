From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v6 net-next 01/11] net: Simplify GRE case in flow_dissector
Date: Thu, 4 Jun 2015 09:16:36 -0700
Message-ID: <1433434606-527444-2-git-send-email-tom@herbertland.com>
References: <1433434606-527444-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:28857 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752937AbbFDQRG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 12:17:06 -0400
Received: from pps.filterd (m0004003 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t54GDuTR021887
	for <netdev@vger.kernel.org>; Thu, 4 Jun 2015 09:17:05 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1utr5mgc88-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 04 Jun 2015 09:17:05 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 229b376c0ad511e583200002c991e86a-216da280 for <netdev@vger.kernel.org>;	Thu,
 04 Jun 2015 09:17:03 -0700
In-Reply-To: <1433434606-527444-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do break when we see routing flag or a non-zero version number in GRE
header.

Acked-by: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/core/flow_dissector.c | 44 ++++++++++++++++++++++----------------------
 1 file changed, 22 insertions(+), 22 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 1f2d893..7f69916 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -308,30 +308,30 @@ flow_label:
 		 * Only look inside GRE if version zero and no
 		 * routing
 		 */
-		if (!(hdr->flags & (GRE_VERSION|GRE_ROUTING))) {
-			proto = hdr->proto;
+		if (hdr->flags & (GRE_VERSION | GRE_ROUTING))
+			break;
+
+		proto = hdr->proto;
+		nhoff += 4;
+		if (hdr->flags & GRE_CSUM)
 			nhoff += 4;
-			if (hdr->flags & GRE_CSUM)
-				nhoff += 4;
-			if (hdr->flags & GRE_KEY)
-				nhoff += 4;
-			if (hdr->flags & GRE_SEQ)
-				nhoff += 4;
-			if (proto == htons(ETH_P_TEB)) {
-				const struct ethhdr *eth;
-				struct ethhdr _eth;
-
-				eth = __skb_header_pointer(skb, nhoff,
-							   sizeof(_eth),
-							   data, hlen, &_eth);
-				if (!eth)
-					return false;
-				proto = eth->h_proto;
-				nhoff += sizeof(*eth);
-			}
-			goto again;
+		if (hdr->flags & GRE_KEY)
+			nhoff += 4;
+		if (hdr->flags & GRE_SEQ)
+			nhoff += 4;
+		if (proto == htons(ETH_P_TEB)) {
+			const struct ethhdr *eth;
+			struct ethhdr _eth;
+
+			eth = __skb_header_pointer(skb, nhoff,
+						   sizeof(_eth),
+						   data, hlen, &_eth);
+			if (!eth)
+				return false;
+			proto = eth->h_proto;
+			nhoff += sizeof(*eth);
 		}
-		break;
+		goto again;
 	}
 	case IPPROTO_IPIP:
 		proto = htons(ETH_P_IP);
-- 
1.8.1
