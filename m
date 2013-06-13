From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 11/12] openvswitch: Optimize flow key match for non tunnel flows.
Date: Thu, 13 Jun 2013 11:25:11 -0700
Message-ID: <1371147911-9520-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog135.obsmtp.com ([74.125.149.84]:55029 "HELO
	na3sys009aog135.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932076Ab3FMSZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 14:25:14 -0400
Received: by mail-pd0-f174.google.com with SMTP id 10so10532801pdc.5
        for <netdev@vger.kernel.org>; Thu, 13 Jun 2013 11:25:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch adds start offset for sw_flow-key, so that we can
skip tunneling information in key for non-tunnel flows.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/datapath.c |    7 +----
 net/openvswitch/flow.c     |   49 +++++++++++++++++++++++++++++++++----------
 net/openvswitch/flow.h     |    6 ++--
 3 files changed, 42 insertions(+), 20 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 6318d00..a68b01d 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -894,10 +894,9 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	if (err)
 		goto err_flow_free;
 
-	err = ovs_flow_metadata_from_nlattrs(flow, a[OVS_PACKET_ATTR_KEY]);
+	err = ovs_flow_metadata_from_nlattrs(flow, key_len, a[OVS_PACKET_ATTR_KEY]);
 	if (err)
 		goto err_flow_free;
-	flow->hash = ovs_flow_hash(&flow->key, key_len);
 	acts = ovs_flow_actions_alloc(nla_len(a[OVS_PACKET_ATTR_ACTIONS]));
 	err = PTR_ERR(acts);
 	if (IS_ERR(acts))
@@ -1276,14 +1275,12 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 			error = PTR_ERR(flow);
 			goto err_unlock_ovs;
 		}
-		flow->key = key;
 		clear_stats(flow);
 
 		rcu_assign_pointer(flow->sf_acts, acts);
 
 		/* Put flow in bucket. */
-		flow->hash = ovs_flow_hash(&key, key_len);
-		ovs_flow_tbl_insert(table, flow);
+		ovs_flow_tbl_insert(table, flow, &key, key_len);
 
 		reply = ovs_flow_cmd_build_info(flow, dp, info->snd_portid,
 						info->snd_seq,
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 575c0bd..867ca94 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -353,6 +353,14 @@ struct sw_flow *ovs_flow_tbl_next(struct flow_table *table, u32 *bucket, u32 *la
 	return NULL;
 }
 
+static void __flow_tbl_insert(struct flow_table *table, struct sw_flow *flow)
+{
+	struct hlist_head *head;
+	head = find_bucket(table, flow->hash);
+	hlist_add_head_rcu(&flow->hash_node[table->node_ver], head);
+	table->count++;
+}
+
 static void flow_table_copy_flows(struct flow_table *old, struct flow_table *new)
 {
 	int old_ver;
@@ -369,7 +377,7 @@ static void flow_table_copy_flows(struct flow_table *old, struct flow_table *new
 		head = flex_array_get(old->buckets, i);
 
 		hlist_for_each_entry(flow, head, hash_node[old_ver])
-			ovs_flow_tbl_insert(new, flow);
+			__flow_tbl_insert(new, flow);
 	}
 	old->keep_flows = true;
 }
@@ -763,9 +771,18 @@ out:
 	return error;
 }
 
-u32 ovs_flow_hash(const struct sw_flow_key *key, int key_len)
+static u32 ovs_flow_hash(const struct sw_flow_key *key, int key_start, int key_len)
+{
+	return jhash2((u32 *)((u8 *)key + key_start),
+		      DIV_ROUND_UP(key_len - key_start, sizeof(u32)), 0);
+}
+
+static int flow_key_start(struct sw_flow_key *key)
 {
-	return jhash2((u32 *)key, DIV_ROUND_UP(key_len, sizeof(u32)), 0);
+	if (key->tun_key.ipv4_dst)
+		return 0;
+	else
+		return offsetof(struct sw_flow_key, phy);
 }
 
 struct sw_flow *ovs_flow_tbl_lookup(struct flow_table *table,
@@ -773,28 +790,31 @@ struct sw_flow *ovs_flow_tbl_lookup(struct flow_table *table,
 {
 	struct sw_flow *flow;
 	struct hlist_head *head;
+	u8 *_key;
+	int key_start;
 	u32 hash;
 
-	hash = ovs_flow_hash(key, key_len);
+	key_start = flow_key_start(key);
+	hash = ovs_flow_hash(key, key_start, key_len);
 
+	_key = (u8 *) key + key_start;
 	head = find_bucket(table, hash);
 	hlist_for_each_entry_rcu(flow, head, hash_node[table->node_ver]) {
 
 		if (flow->hash == hash &&
-		    !memcmp(&flow->key, key, key_len)) {
+		    !memcmp((u8 *)&flow->key + key_start, _key, key_len - key_start)) {
 			return flow;
 		}
 	}
 	return NULL;
 }
 
-void ovs_flow_tbl_insert(struct flow_table *table, struct sw_flow *flow)
+void ovs_flow_tbl_insert(struct flow_table *table, struct sw_flow *flow,
+			 struct sw_flow_key *key, int key_len)
 {
-	struct hlist_head *head;
-
-	head = find_bucket(table, flow->hash);
-	hlist_add_head_rcu(&flow->hash_node[table->node_ver], head);
-	table->count++;
+	flow->hash = ovs_flow_hash(key, flow_key_start(key), key_len);
+	memcpy(&flow->key, key, sizeof(flow->key));
+	__flow_tbl_insert(table, flow);
 }
 
 void ovs_flow_tbl_remove(struct flow_table *table, struct sw_flow *flow)
@@ -1235,6 +1255,7 @@ int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
 /**
  * ovs_flow_metadata_from_nlattrs - parses Netlink attributes into a flow key.
  * @flow: Receives extracted in_port, priority, tun_key and skb_mark.
+ * @key_len: Length of key in @flow.  Used for calculating flow hash.
  * @attr: Netlink attribute holding nested %OVS_KEY_ATTR_* Netlink attribute
  * sequence.
  *
@@ -1243,7 +1264,7 @@ int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
  * get the metadata, that is, the parts of the flow key that cannot be
  * extracted from the packet itself.
  */
-int ovs_flow_metadata_from_nlattrs(struct sw_flow *flow,
+int ovs_flow_metadata_from_nlattrs(struct sw_flow *flow, int key_len,
 				   const struct nlattr *attr)
 {
 	struct ovs_key_ipv4_tunnel *tun_key = &flow->key.tun_key;
@@ -1289,6 +1310,10 @@ int ovs_flow_metadata_from_nlattrs(struct sw_flow *flow,
 	}
 	if (rem)
 		return -EINVAL;
+
+	flow->hash = ovs_flow_hash(&flow->key,
+				   flow_key_start(&flow->key), key_len);
+
 	return 0;
 }
 
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index b1bb01b..9bcd7a3 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -156,7 +156,7 @@ u64 ovs_flow_used_time(unsigned long flow_jiffies);
 int ovs_flow_to_nlattrs(const struct sw_flow_key *, struct sk_buff *);
 int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
 		      const struct nlattr *);
-int ovs_flow_metadata_from_nlattrs(struct sw_flow *flow,
+int ovs_flow_metadata_from_nlattrs(struct sw_flow *flow, int key_len,
 				  const struct nlattr *attr);
 
 #define MAX_ACTIONS_BUFSIZE    (32 * 1024)
@@ -188,9 +188,9 @@ void ovs_flow_tbl_deferred_destroy(struct flow_table *table);
 struct flow_table *ovs_flow_tbl_alloc(int new_size);
 struct flow_table *ovs_flow_tbl_expand(struct flow_table *table);
 struct flow_table *ovs_flow_tbl_rehash(struct flow_table *table);
-void ovs_flow_tbl_insert(struct flow_table *table, struct sw_flow *flow);
+void ovs_flow_tbl_insert(struct flow_table *table, struct sw_flow *flow,
+			 struct sw_flow_key *key, int key_len);
 void ovs_flow_tbl_remove(struct flow_table *table, struct sw_flow *flow);
-u32 ovs_flow_hash(const struct sw_flow_key *key, int key_len);
 
 struct sw_flow *ovs_flow_tbl_next(struct flow_table *table, u32 *bucket, u32 *idx);
 extern const int ovs_key_lens[OVS_KEY_ATTR_MAX + 1];
-- 
1.7.1
