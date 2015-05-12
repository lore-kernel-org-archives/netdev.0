From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v3 net-next 4/5] net: Add IPv6 flow label to flow_keys
Date: Tue, 12 May 2015 08:23:01 -0700
Message-ID: <1431444182-3935169-5-git-send-email-tom@herbertland.com>
References: <1431444182-3935169-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:44905 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933076AbbELPXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 11:23:23 -0400
Received: from pps.filterd (m0004348 [127.0.0.1])
	by m0004348.ppops.net (8.14.5/8.14.5) with SMTP id t4CFJKI0031266
	for <netdev@vger.kernel.org>; Tue, 12 May 2015 08:23:22 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0004348.ppops.net with ESMTP id 1ubkuag15s-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 12 May 2015 08:23:22 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 d2da6526f8ba11e483b20002c992ebde-688ad1e0 for <netdev@vger.kernel.org>;	Tue,
 12 May 2015 08:23:21 -0700
In-Reply-To: <1431444182-3935169-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In flow_dissector set the flow label in flow_keys for IPv6. This also
removes the shortcircuiting of flow dissection when a non-zero label
is present, the flow label can be considered to provide additional
entropy for a hash.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/flow_keys.h   |  3 ++-
 net/core/flow_dissector.c | 15 +--------------
 2 files changed, 3 insertions(+), 15 deletions(-)

diff --git a/include/net/flow_keys.h b/include/net/flow_keys.h
index 14298e2..906d47a 100644
--- a/include/net/flow_keys.h
+++ b/include/net/flow_keys.h
@@ -26,7 +26,8 @@ struct flow_keys {
 	__be16	n_proto;
 	u8	ip_proto;
 	u8	padding;
-	u32	vlan_id:12;
+	u32	vlan_id:12,
+		flow_label:20;
 
 	union {
 		__be32 ports;
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 312a11a..f1fb7a5 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -102,7 +102,6 @@ ip:
 	case htons(ETH_P_IPV6): {
 		const struct ipv6hdr *iph;
 		struct ipv6hdr _iph;
-		__be32 flow_label;
 
 ipv6:
 		iph = __skb_header_pointer(skb, nhoff, sizeof(_iph), data, hlen, &_iph);
@@ -118,19 +117,7 @@ ipv6:
 
 		iph_to_flow_copy_v6addrs(flow, iph);
 
-		flow_label = ip6_flowlabel(iph);
-		if (flow_label) {
-			/* Awesome, IPv6 packet has a flow label so we can
-			 * use that to represent the ports without any
-			 * further dissection.
-			 */
-			flow->n_proto = proto;
-			flow->ip_proto = ip_proto;
-			flow->ports = flow_label;
-			flow->thoff = (u16)nhoff;
-
-			return true;
-		}
+		flow->flow_label = ntohl(ip6_flowlabel(iph));
 
 		break;
 	}
-- 
1.8.1
