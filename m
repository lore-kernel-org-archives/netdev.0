From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v4 net-next 01/11] net: Simplify GRE case in flow_dissector
Date: Thu, 21 May 2015 17:11:36 -0700
Message-ID: <1432253506-3646977-2-git-send-email-tom@herbertland.com>
References: <1432253506-3646977-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <jiri@resnulli.us>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:16227 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755787AbbEVAMB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 20:12:01 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t4M0848N010413
	for <netdev@vger.kernel.org>; Thu, 21 May 2015 17:12:00 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1uhrt705bx-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 21 May 2015 17:12:00 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 296ddb4e001711e58a870002c95209d8-d12dc3a0 for <netdev@vger.kernel.org>;	Thu,
 21 May 2015 17:11:58 -0700
In-Reply-To: <1432253506-3646977-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do break when we see routing flag or a non-zero version number in GRE
header.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/core/flow_dissector.c | 44 ++++++++++++++++++++++----------------------
 1 file changed, 22 insertions(+), 22 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 703d059..4a2cb93 100644
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
+			nhoff += 4;
+		if (hdr->flags & GRE_KEY)
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
