From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next] flow_dissector: remove __flow_hash_consistentify
Date: Wed, 29 Jul 2015 13:49:03 -0700
Message-ID: <1438202943-937619-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:38967 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752424AbbG2UtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 16:49:12 -0400
Received: from pps.filterd (m0004060 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t6TKlMHE020955
	for <netdev@vger.kernel.org>; Wed, 29 Jul 2015 13:49:11 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1vy5360agt-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 29 Jul 2015 13:49:11 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 434154cc363311e5b6d70002c99293a0-363fd2b0 for <netdev@vger.kernel.org>;	Wed,
 29 Jul 2015 13:49:10 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The intent of this function was to produce a consistent hash for both
directions of a flow. However, since we added more inputs to the flow
hashing (IPv6 flow labels for instance) in a lot of cases we won't get
the same hash computed for each direction anyway. Also, there is no
defined correlation between the hashes computed in each direction of a
flow.

This patch removes the function since it is not providing significant
value and is expensive to be called for every packet. If there are
ever users of the flow_hash_from_keys that did require consistency
they can swap addresses and ports as needed in the flow_keys before
calling flow_hash_from_keys.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/core/flow_dissector.c | 35 -----------------------------------
 1 file changed, 35 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 2a834c6..9c9236b 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -500,45 +500,10 @@ __be32 flow_get_u32_dst(const struct flow_keys *flow)
 }
 EXPORT_SYMBOL(flow_get_u32_dst);
 
-static inline void __flow_hash_consistentify(struct flow_keys *keys)
-{
-	int addr_diff, i;
-
-	switch (keys->control.addr_type) {
-	case FLOW_DISSECTOR_KEY_IPV4_ADDRS:
-		addr_diff = (__force u32)keys->addrs.v4addrs.dst -
-			    (__force u32)keys->addrs.v4addrs.src;
-		if ((addr_diff < 0) ||
-		    (addr_diff == 0 &&
-		     ((__force u16)keys->ports.dst <
-		      (__force u16)keys->ports.src))) {
-			swap(keys->addrs.v4addrs.src, keys->addrs.v4addrs.dst);
-			swap(keys->ports.src, keys->ports.dst);
-		}
-		break;
-	case FLOW_DISSECTOR_KEY_IPV6_ADDRS:
-		addr_diff = memcmp(&keys->addrs.v6addrs.dst,
-				   &keys->addrs.v6addrs.src,
-				   sizeof(keys->addrs.v6addrs.dst));
-		if ((addr_diff < 0) ||
-		    (addr_diff == 0 &&
-		     ((__force u16)keys->ports.dst <
-		      (__force u16)keys->ports.src))) {
-			for (i = 0; i < 4; i++)
-				swap(keys->addrs.v6addrs.src.s6_addr32[i],
-				     keys->addrs.v6addrs.dst.s6_addr32[i]);
-			swap(keys->ports.src, keys->ports.dst);
-		}
-		break;
-	}
-}
-
 static inline u32 __flow_hash_from_keys(struct flow_keys *keys, u32 keyval)
 {
 	u32 hash;
 
-	__flow_hash_consistentify(keys);
-
 	hash = __flow_hash_words((u32 *)flow_keys_hash_start(keys),
 				 flow_keys_hash_length(keys), keyval);
 	if (!hash)
-- 
1.8.1
