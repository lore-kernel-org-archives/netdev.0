From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v6 net-next 07/11] net: Get rid of IPv6 hash addresses flow keys
Date: Thu, 4 Jun 2015 09:16:42 -0700
Message-ID: <1433434606-527444-8-git-send-email-tom@herbertland.com>
References: <1433434606-527444-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:27994 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753698AbbFDQRL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 12:17:11 -0400
Received: from pps.filterd (m0004060 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t54GFfZB030450
	for <netdev@vger.kernel.org>; Thu, 4 Jun 2015 09:17:11 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1utrt58aq8-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 04 Jun 2015 09:17:11 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 2627c88c0ad511e591d324be0593f280-48cd0280 for <netdev@vger.kernel.org>;	Thu,
 04 Jun 2015 09:17:09 -0700
In-Reply-To: <1433434606-527444-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We don't need to return the IPv6 address hash as part of flow keys.
In general, using the IPv6 address hash is risky in a hash value
since the underlying use of xor provides no entropy. If someone
really needs the hash value they can get it from the full IPv6
addresses in flow keys (e.g. from flow_get_u32_src).

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/flow_dissector.h |  1 -
 net/core/flow_dissector.c    | 17 -----------------
 2 files changed, 18 deletions(-)

diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index 3ee606a..59f00f9 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -103,7 +103,6 @@ enum flow_dissector_key_id {
 	FLOW_DISSECTOR_KEY_BASIC, /* struct flow_dissector_key_basic */
 	FLOW_DISSECTOR_KEY_IPV4_ADDRS, /* struct flow_dissector_key_ipv4_addrs */
 	FLOW_DISSECTOR_KEY_IPV6_ADDRS, /* struct flow_dissector_key_ipv6_addrs */
-	FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS, /* struct flow_dissector_key_addrs */
 	FLOW_DISSECTOR_KEY_PORTS, /* struct flow_dissector_key_ports */
 	FLOW_DISSECTOR_KEY_ETH_ADDRS, /* struct flow_dissector_key_eth_addrs */
 	FLOW_DISSECTOR_KEY_TIPC_ADDRS, /* struct flow_dissector_key_tipc_addrs */
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 91861c3..5348a46 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -200,19 +200,6 @@ ipv6:
 		nhoff += sizeof(struct ipv6hdr);
 
 		if (skb_flow_dissector_uses_key(flow_dissector,
-						FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS)) {
-			key_addrs = skb_flow_dissector_target(flow_dissector,
-							      FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS,
-							      target_container);
-
-			key_addrs->v4addrs.src =
-				(__force __be32)ipv6_addr_hash(&iph->saddr);
-			key_addrs->v4addrs.dst =
-				(__force __be32)ipv6_addr_hash(&iph->daddr);
-			key_control->addr_type = FLOW_DISSECTOR_KEY_IPV4_ADDRS;
-			goto flow_label;
-		}
-		if (skb_flow_dissector_uses_key(flow_dissector,
 						FLOW_DISSECTOR_KEY_IPV6_ADDRS)) {
 			struct flow_dissector_key_ipv6_addrs *key_ipv6_addrs;
 
@@ -651,10 +638,6 @@ static const struct flow_dissector_key flow_keys_dissector_keys[] = {
 		.offset = offsetof(struct flow_keys, addrs.v6addrs),
 	},
 	{
-		.key_id = FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS,
-		.offset = offsetof(struct flow_keys, addrs.v4addrs),
-	},
-	{
 		.key_id = FLOW_DISSECTOR_KEY_TIPC_ADDRS,
 		.offset = offsetof(struct flow_keys, addrs.tipcaddrs),
 	},
-- 
1.8.1
