From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v4 net-next 09/11] net: Add IPv6 flow label to flow_keys
Date: Thu, 21 May 2015 17:11:44 -0700
Message-ID: <1432253506-3646977-10-git-send-email-tom@herbertland.com>
References: <1432253506-3646977-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <jiri@resnulli.us>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:64617 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755787AbbEVAMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 20:12:13 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t4M0848T010413
	for <netdev@vger.kernel.org>; Thu, 21 May 2015 17:12:13 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1uhrt705cp-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 21 May 2015 17:12:13 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 311fdf86001711e5aa260002c992ebde-912d23a0 for <netdev@vger.kernel.org>;	Thu,
 21 May 2015 17:12:11 -0700
In-Reply-To: <1432253506-3646977-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In flow_dissector set the flow label in flow_keys for IPv6. This also
removes the shortcircuiting of flow dissection when a non-zero label
is present, the flow label can be considered to provide additional
entropy for a hash.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/flow_dissector.h |  4 +++-
 net/core/flow_dissector.c    | 37 +++++++++++++------------------------
 2 files changed, 16 insertions(+), 25 deletions(-)

diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index 08480fb..effe607 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -28,7 +28,8 @@ struct flow_dissector_key_basic {
 };
 
 struct flow_dissector_key_tags {
-	u32	vlan_id:12;
+	u32	vlan_id:12,
+		flow_label:20;
 };
 
 /**
@@ -111,6 +112,7 @@ enum flow_dissector_key_id {
 	FLOW_DISSECTOR_KEY_ETH_ADDRS, /* struct flow_dissector_key_eth_addrs */
 	FLOW_DISSECTOR_KEY_TIPC_ADDRS, /* struct flow_dissector_key_tipc_addrs */
 	FLOW_DISSECTOR_KEY_VLANID, /* struct flow_dissector_key_flow_tags */
+	FLOW_DISSECTOR_KEY_FLOW_LABEL, /* struct flow_dissector_key_flow_label */
 
 	FLOW_DISSECTOR_KEY_MAX,
 };
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 3512366..2fba492 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -190,7 +190,7 @@ ip:
 	case htons(ETH_P_IPV6): {
 		const struct ipv6hdr *iph;
 		struct ipv6hdr _iph;
-		__be32 flow_label;
+		u32 flow_label;
 
 ipv6:
 		iph = __skb_header_pointer(skb, nhoff, sizeof(_iph), data, hlen, &_iph);
@@ -210,30 +210,15 @@ ipv6:
 
 			memcpy(key_ipv6_addrs, &iph->saddr, sizeof(*key_ipv6_addrs));
 			key_control->addr_type = FLOW_DISSECTOR_KEY_IPV6_ADDRS;
-			goto flow_label;
 		}
-		break;
-flow_label:
-		flow_label = ip6_flowlabel(iph);
-		if (flow_label) {
-			/* Awesome, IPv6 packet has a flow label so we can
-			 * use that to represent the ports without any
-			 * further dissection.
-			 */
-
-			key_basic->n_proto = proto;
-			key_basic->ip_proto = ip_proto;
-			key_control->thoff = (u16)nhoff;
-
-			if (!skb_flow_dissector_uses_key(flow_dissector,
-							 FLOW_DISSECTOR_KEY_PORTS))
-				break;
-			key_ports = skb_flow_dissector_target(flow_dissector,
-							      FLOW_DISSECTOR_KEY_PORTS,
-							      target_container);
-			key_ports->ports = flow_label;
-
-			return true;
+
+		flow_label = ntohl(ip6_flowlabel(iph));
+		if (flow_label && skb_flow_dissector_uses_key(flow_dissector,
+				FLOW_DISSECTOR_KEY_FLOW_LABEL)) {
+			key_tags = skb_flow_dissector_target(flow_dissector,
+			    FLOW_DISSECTOR_KEY_FLOW_LABEL, target_container);
+
+			key_tags->flow_label = flow_label;
 		}
 
 		break;
@@ -659,6 +644,10 @@ static const struct flow_dissector_key flow_keys_dissector_keys[] = {
 		.key_id = FLOW_DISSECTOR_KEY_VLANID,
 		.offset = offsetof(struct flow_keys, tags),
 	},
+	{
+		.key_id = FLOW_DISSECTOR_KEY_FLOW_LABEL,
+		.offset = offsetof(struct flow_keys, tags),
+	},
 };
 
 static const struct flow_dissector_key flow_keys_buf_dissector_keys[] = {
-- 
1.8.1
