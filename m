From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v4 net-next 01/11] net: Simplify GRE case in flow_dissector
Date: Thu, 28 May 2015 11:18:58 -0700
Message-ID: <1432837148-1359931-2-git-send-email-tom@herbertland.com>
References: <1432837148-1359931-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:56865 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754509AbbE1ST1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 14:19:27 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t4SIImFt028564
	for <netdev@vger.kernel.org>; Thu, 28 May 2015 11:19:27 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1up7dr8652-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 28 May 2015 11:19:27 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 121791ca056611e5a13a0002c9521c9e-ab7fc3a0 for <netdev@vger.kernel.org>;	Thu,
 28 May 2015 11:19:25 -0700
In-Reply-To: <1432837148-1359931-1-git-send-email-tom@herbertland.com>
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
