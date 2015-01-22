From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCH net-next v14 3/5] openvswitch: Use sw_flow_key_range for key ranges.
Date: Wed, 21 Jan 2015 16:42:50 -0800
Message-ID: <1421887372-56414-4-git-send-email-joestringer@nicira.com>
References: <1421887372-56414-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, dev@openvswitch.org,
	pshelar@nicira.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog119.obsmtp.com ([74.125.149.246]:55939 "HELO
	na3sys009aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752838AbbAVAnE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 19:43:04 -0500
Received: by mail-pa0-f50.google.com with SMTP id bj1so56281695pad.9
        for <netdev@vger.kernel.org>; Wed, 21 Jan 2015 16:43:03 -0800 (PST)
In-Reply-To: <1421887372-56414-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These minor tidyups make a future patch a little tidier.

Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
 net/openvswitch/flow_table.c |   20 +++++++++-----------
 1 file changed, 9 insertions(+), 11 deletions(-)

diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
index 81b977d..9a3f41f 100644
--- a/net/openvswitch/flow_table.c
+++ b/net/openvswitch/flow_table.c
@@ -357,9 +357,11 @@ int ovs_flow_tbl_flush(struct flow_table *flow_table)
 	return 0;
 }
 
-static u32 flow_hash(const struct sw_flow_key *key, int key_start,
-		     int key_end)
+static u32 flow_hash(const struct sw_flow_key *key,
+		     const struct sw_flow_key_range *range)
 {
+	int key_start = range->start;
+	int key_end = range->end;
 	const u32 *hash_key = (const u32 *)((const u8 *)key + key_start);
 	int hash_u32s = (key_end - key_start) >> 2;
 
@@ -395,9 +397,9 @@ static bool cmp_key(const struct sw_flow_key *key1,
 
 static bool flow_cmp_masked_key(const struct sw_flow *flow,
 				const struct sw_flow_key *key,
-				int key_start, int key_end)
+				const struct sw_flow_key_range *range)
 {
-	return cmp_key(&flow->key, key, key_start, key_end);
+	return cmp_key(&flow->key, key, range->start, range->end);
 }
 
 bool ovs_flow_cmp_unmasked_key(const struct sw_flow *flow,
@@ -416,18 +418,15 @@ static struct sw_flow *masked_flow_lookup(struct table_instance *ti,
 {
 	struct sw_flow *flow;
 	struct hlist_head *head;
-	int key_start = mask->range.start;
-	int key_end = mask->range.end;
 	u32 hash;
 	struct sw_flow_key masked_key;
 
 	ovs_flow_mask_key(&masked_key, unmasked, mask);
-	hash = flow_hash(&masked_key, key_start, key_end);
+	hash = flow_hash(&masked_key, &mask->range);
 	head = find_bucket(ti, hash);
 	hlist_for_each_entry_rcu(flow, head, hash_node[ti->node_ver]) {
 		if (flow->mask == mask && flow->hash == hash &&
-		    flow_cmp_masked_key(flow, &masked_key,
-					  key_start, key_end))
+		    flow_cmp_masked_key(flow, &masked_key, &mask->range))
 			return flow;
 	}
 	return NULL;
@@ -590,8 +589,7 @@ static void flow_key_insert(struct flow_table *table, struct sw_flow *flow)
 	struct table_instance *new_ti = NULL;
 	struct table_instance *ti;
 
-	flow->hash = flow_hash(&flow->key, flow->mask->range.start,
-			flow->mask->range.end);
+	flow->hash = flow_hash(&flow->key, &flow->mask->range);
 	ti = ovsl_dereference(table->ti);
 	table_instance_insert(ti, flow);
 	table->count++;
-- 
1.7.10.4
