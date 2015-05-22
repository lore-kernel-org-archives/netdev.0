From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v4 net-next 06/11] net: Add keys for TIPC address
Date: Thu, 21 May 2015 17:11:41 -0700
Message-ID: <1432253506-3646977-7-git-send-email-tom@herbertland.com>
References: <1432253506-3646977-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <jiri@resnulli.us>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:33855 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756097AbbEVAMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 20:12:10 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t4M07w4I009797
	for <netdev@vger.kernel.org>; Thu, 21 May 2015 17:12:09 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1uhrt705cm-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 21 May 2015 17:12:09 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 2f07883e001711e5aea70002c95209d8-d1add3a0 for <netdev@vger.kernel.org>;	Thu,
 21 May 2015 17:12:07 -0700
In-Reply-To: <1432253506-3646977-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new flow key for TIPC addresses.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/flow_dissector.h | 10 ++++++++++
 net/core/flow_dissector.c    | 20 ++++++++++++++------
 2 files changed, 24 insertions(+), 6 deletions(-)

diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index 306d461..3ee606a 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -50,6 +50,14 @@ struct flow_dissector_key_ipv6_addrs {
 };
 
 /**
+ * struct flow_dissector_key_tipc_addrs:
+ * @srcnode: source node address
+ */
+struct flow_dissector_key_tipc_addrs {
+	__be32 srcnode;
+};
+
+/**
  * struct flow_dissector_key_addrs:
  * @v4addrs: IPv4 addresses
  * @v6addrs: IPv6 addresses
@@ -58,6 +66,7 @@ struct flow_dissector_key_addrs {
 	union {
 		struct flow_dissector_key_ipv4_addrs v4addrs;
 		struct flow_dissector_key_ipv6_addrs v6addrs;
+		struct flow_dissector_key_tipc_addrs tipcaddrs;
 	};
 };
 
@@ -97,6 +106,7 @@ enum flow_dissector_key_id {
 	FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS, /* struct flow_dissector_key_addrs */
 	FLOW_DISSECTOR_KEY_PORTS, /* struct flow_dissector_key_ports */
 	FLOW_DISSECTOR_KEY_ETH_ADDRS, /* struct flow_dissector_key_eth_addrs */
+	FLOW_DISSECTOR_KEY_TIPC_ADDRS, /* struct flow_dissector_key_tipc_addrs */
 
 	FLOW_DISSECTOR_KEY_MAX,
 };
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index d77619f..8d6f089 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -294,13 +294,12 @@ flow_label:
 		key_control->thoff = (u16)nhoff;
 
 		if (skb_flow_dissector_uses_key(flow_dissector,
-						FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS)) {
+				FLOW_DISSECTOR_KEY_TIPC_ADDRS)) {
 			key_addrs = skb_flow_dissector_target(flow_dissector,
-							      FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS,
-							      target_container);
-			key_addrs->v4addrs.src = hdr->srcnode;
-			key_addrs->v4addrs.dst = 0;
-			key_control->addr_type = FLOW_DISSECTOR_KEY_IPV4_ADDRS;
+				FLOW_DISSECTOR_KEY_TIPC_ADDRS,
+				target_container);
+			key_addrs->tipcaddrs.srcnode = hdr->srcnode;
+			key_control->addr_type = FLOW_DISSECTOR_KEY_TIPC_ADDRS;
 		}
 		return true;
 	}
@@ -408,6 +407,9 @@ static inline size_t flow_keys_hash_length(struct flow_keys *flow)
 	case FLOW_DISSECTOR_KEY_IPV6_ADDRS:
 		diff -= sizeof(flow->addrs.v6addrs);
 		break;
+	case FLOW_DISSECTOR_KEY_TIPC_ADDRS:
+		diff -= sizeof(flow->addrs.tipcaddrs);
+		break;
 	}
 	return (sizeof(*flow) - diff) / sizeof(u32);
 }
@@ -420,6 +422,8 @@ __be32 flow_get_u32_src(const struct flow_keys *flow)
 	case FLOW_DISSECTOR_KEY_IPV6_ADDRS:
 		return (__force __be32)ipv6_addr_hash(
 			&flow->addrs.v6addrs.src);
+	case FLOW_DISSECTOR_KEY_TIPC_ADDRS:
+		return flow->addrs.tipcaddrs.srcnode;
 	default:
 		return 0;
 	}
@@ -651,6 +655,10 @@ static const struct flow_dissector_key flow_keys_dissector_keys[] = {
 		.offset = offsetof(struct flow_keys, addrs.v4addrs),
 	},
 	{
+		.key_id = FLOW_DISSECTOR_KEY_TIPC_ADDRS,
+		.offset = offsetof(struct flow_keys, addrs.tipcaddrs),
+	},
+	{
 		.key_id = FLOW_DISSECTOR_KEY_PORTS,
 		.offset = offsetof(struct flow_keys, ports),
 	},
-- 
1.8.1
