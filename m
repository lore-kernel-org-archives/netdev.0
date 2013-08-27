From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 10/11] openvswitch: Rename key_len to key_end
Date: Tue, 27 Aug 2013 13:20:47 -0700
Message-ID: <1377634848-34327-11-git-send-email-jesse@nicira.com>
References: <1377634848-34327-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Andy Zhou <azhou@nicira.com>, Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog102.obsmtp.com ([74.125.149.69]:48613 "HELO
	na3sys009aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753962Ab3H0UVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 16:21:19 -0400
Received: by mail-pb0-f41.google.com with SMTP id rp2so5337035pbb.0
        for <netdev@vger.kernel.org>; Tue, 27 Aug 2013 13:21:19 -0700 (PDT)
In-Reply-To: <1377634848-34327-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Zhou <azhou@nicira.com>

Key_end is a better name describing the ending boundary than key_len.
Rename those variables to make it less confusing.

Signed-off-by: Andy Zhou <azhou@nicira.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/openvswitch/flow.c | 31 ++++++++++++++++---------------
 net/openvswitch/flow.h |  2 +-
 2 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 2b47855..80bcb96 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -997,10 +997,11 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key)
 	return 0;
 }
 
-static u32 ovs_flow_hash(const struct sw_flow_key *key, int key_start, int key_len)
+static u32 ovs_flow_hash(const struct sw_flow_key *key, int key_start,
+			 int key_end)
 {
 	return jhash2((u32 *)((u8 *)key + key_start),
-		      DIV_ROUND_UP(key_len - key_start, sizeof(u32)), 0);
+		      DIV_ROUND_UP(key_end - key_start, sizeof(u32)), 0);
 }
 
 static int flow_key_start(const struct sw_flow_key *key)
@@ -1012,31 +1013,31 @@ static int flow_key_start(const struct sw_flow_key *key)
 }
 
 static bool __cmp_key(const struct sw_flow_key *key1,
-		const struct sw_flow_key *key2,  int key_start, int key_len)
+		const struct sw_flow_key *key2,  int key_start, int key_end)
 {
 	return !memcmp((u8 *)key1 + key_start,
-			(u8 *)key2 + key_start, (key_len - key_start));
+			(u8 *)key2 + key_start, (key_end - key_start));
 }
 
 static bool __flow_cmp_key(const struct sw_flow *flow,
-		const struct sw_flow_key *key, int key_start, int key_len)
+		const struct sw_flow_key *key, int key_start, int key_end)
 {
-	return __cmp_key(&flow->key, key, key_start, key_len);
+	return __cmp_key(&flow->key, key, key_start, key_end);
 }
 
 static bool __flow_cmp_unmasked_key(const struct sw_flow *flow,
-		  const struct sw_flow_key *key, int key_start, int key_len)
+		  const struct sw_flow_key *key, int key_start, int key_end)
 {
-	return __cmp_key(&flow->unmasked_key, key, key_start, key_len);
+	return __cmp_key(&flow->unmasked_key, key, key_start, key_end);
 }
 
 bool ovs_flow_cmp_unmasked_key(const struct sw_flow *flow,
-		const struct sw_flow_key *key, int key_len)
+		const struct sw_flow_key *key, int key_end)
 {
 	int key_start;
 	key_start = flow_key_start(key);
 
-	return __flow_cmp_unmasked_key(flow, key, key_start, key_len);
+	return __flow_cmp_unmasked_key(flow, key, key_start, key_end);
 
 }
 
@@ -1044,11 +1045,11 @@ struct sw_flow *ovs_flow_lookup_unmasked_key(struct flow_table *table,
 				       struct sw_flow_match *match)
 {
 	struct sw_flow_key *unmasked = match->key;
-	int key_len = match->range.end;
+	int key_end = match->range.end;
 	struct sw_flow *flow;
 
 	flow = ovs_flow_lookup(table, unmasked);
-	if (flow && (!ovs_flow_cmp_unmasked_key(flow, unmasked, key_len)))
+	if (flow && (!ovs_flow_cmp_unmasked_key(flow, unmasked, key_end)))
 		flow = NULL;
 
 	return flow;
@@ -1061,16 +1062,16 @@ static struct sw_flow *ovs_masked_flow_lookup(struct flow_table *table,
 	struct sw_flow *flow;
 	struct hlist_head *head;
 	int key_start = mask->range.start;
-	int key_len = mask->range.end;
+	int key_end = mask->range.end;
 	u32 hash;
 	struct sw_flow_key masked_key;
 
 	ovs_flow_key_mask(&masked_key, flow_key, mask);
-	hash = ovs_flow_hash(&masked_key, key_start, key_len);
+	hash = ovs_flow_hash(&masked_key, key_start, key_end);
 	head = find_bucket(table, hash);
 	hlist_for_each_entry_rcu(flow, head, hash_node[table->node_ver]) {
 		if (flow->mask == mask &&
-		    __flow_cmp_key(flow, &masked_key, key_start, key_len))
+		    __flow_cmp_key(flow, &masked_key, key_start, key_end))
 			return flow;
 	}
 	return NULL;
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index d08dcf7..e793051 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -243,7 +243,7 @@ int ovs_ipv4_tun_to_nlattr(struct sk_buff *skb,
 			   const struct ovs_key_ipv4_tunnel *output);
 
 bool ovs_flow_cmp_unmasked_key(const struct sw_flow *flow,
-		const struct sw_flow_key *key, int key_len);
+		const struct sw_flow_key *key, int key_end);
 
 struct sw_flow_mask {
 	int ref_count;
-- 
1.8.1.2
