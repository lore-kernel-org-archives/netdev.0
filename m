From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCH net-next v13 5/5] openvswitch: Add support for unique flow IDs.
Date: Tue, 20 Jan 2015 10:32:52 -0800
Message-ID: <1421778772-11879-6-git-send-email-joestringer@nicira.com>
References: <1421778772-11879-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, dev@openvswitch.org,
	pshelar@nicira.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421778772-11879-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Previously, flows were manipulated by userspace specifying a full,
unmasked flow key. This adds significant burden onto flow
serialization/deserialization, particularly when dumping flows.

This patch adds an alternative way to refer to flows using a
variable-length "unique flow identifier" (UFID). At flow setup time,
userspace may specify a UFID for a flow, which is stored with the flow
and inserted into a separate table for lookup, in addition to the
standard flow table. Flows created using a UFID must be fetched or
deleted using the UFID.

All flow dump operations may now be made more terse with OVS_UFID_F_*
flags. For example, the OVS_UFID_F_OMIT_KEY flag allows responses to
omit the flow key from a datapath operation if the flow has a
corresponding UFID. This significantly reduces the time spent assembling
and transacting netlink messages. With all OVS_UFID_F_OMIT_* flags
enabled, the datapath only returns the UFID and statistics for each flow
during flow dump, increasing ovs-vswitchd revalidator performance by 40%
or more.

Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
v13: Embed sw_flow_id in sw_flow.
     Malloc unmasked_key for legacy case.
     Fix bug where key is double-serialized in legacy case.
v12: Merge unmasked_key, ufid into 'struct sw_flow_id'.
     Add identifier_is_{ufid,key}() helpers.
     Add should_fill_{key,mask,actions}() helpers.
     Revert rework of ovs_flow_cmd_set() -- requires key,acts.
     Streamline sw_flow_id copy/alloc.
     Use genlmsg_parse() to find ufid flags in dump.
     Handle new_flow case with same ufid, different flow key.
     Calculate exact message length in ovs_flow_cmd_msg_size().
     Limit UFID to between 1-16 octets.
     Check minimum length for UFID in flow_policy.
     Use jhash() for ufid_hash (arch_fast_hash() went away).
     Rebase.
v11: Separate UFID and unmasked key from sw_flow.
     Modify interface to remove nested UFID attributes.
     Only allow UFIDs between 1-256 octets.
     Move UFID nla fetch helpers to flow_netlink.h.
     Perform complete nlmsg_parsing in ovs_flow_cmd_dump().
     Check UFID table for flows with duplicate UFID at flow setup.
     Tidy up mask/key/ufid insertion into flow_table.
     Rebase.
v10: Ignore flow_key in requests if UFID is specified.
     Only allow UFID flows to be indexed by UFID.
     Only allow non-UFID flows to be indexed by unmasked flow key.
     Unite the unmasked_key and ufid+ufid_hash in 'struct sw_flow'.
     Don't periodically rehash the UFID table.
     Resize the UFID table independently from the flow table.
     Modify table_destroy() to iterate once and delete from both tables.
     Fix UFID memory leak in flow_free().
     Remove kernel-only UFIDs for non-UFID cases.
     Rename "OVS_UFID_F_SKIP_*" -> "OVS_UFID_F_OMIT_*"
     Update documentation.
     Rebase.
v9: No change.
v8: Rename UID -> UFID "unique flow identifier".
    Fix null dereference when adding flow without uid or mask.
    If UFID and not match are specified, and lookup fails, return ENOENT.
    Rebase.
v7: Remove OVS_DP_F_INDEX_BY_UID.
    Rework UID serialisation for variable-length UID.
    Log error if uid not specified and OVS_UID_F_SKIP_KEY is set.
    Rebase against "probe" logging changes.
v6: Fix documentation for supporting UIDs between 32-128 bits.
    Minor style fixes.
    Rebase.
v5: No change.
v4: Fix memory leaks.
    Log when triggering the older userspace issue above.
v3: Initial post.
---
 Documentation/networking/openvswitch.txt |   13 ++
 include/uapi/linux/openvswitch.h         |   20 +++
 net/openvswitch/datapath.c               |  207 ++++++++++++++++++++++--------
 net/openvswitch/flow.h                   |   28 +++-
 net/openvswitch/flow_netlink.c           |   68 +++++++++-
 net/openvswitch/flow_netlink.h           |    8 +-
 net/openvswitch/flow_table.c             |  187 ++++++++++++++++++++++-----
 net/openvswitch/flow_table.h             |    8 +-
 8 files changed, 448 insertions(+), 91 deletions(-)

diff --git a/Documentation/networking/openvswitch.txt b/Documentation/networking/openvswitch.txt
index 37c20ee..b3b9ac6 100644
--- a/Documentation/networking/openvswitch.txt
+++ b/Documentation/networking/openvswitch.txt
@@ -131,6 +131,19 @@ performs best-effort detection of overlapping wildcarded flows and may reject
 some but not all of them. However, this behavior may change in future versions.
 
 
+Unique flow identifiers
+-----------------------
+
+An alternative to using the original match portion of a key as the handle for
+flow identification is a unique flow identifier, or "UFID". UFIDs are optional
+for both the kernel and user space program.
+
+User space programs that support UFID are expected to provide it during flow
+setup in addition to the flow, then refer to the flow using the UFID for all
+future operations. The kernel is not required to index flows by the original
+flow key if a UFID is specified.
+
+
 Basic rule for evolving flow keys
 ---------------------------------
 
diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index cd8d933..7a8785a 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -459,6 +459,14 @@ struct ovs_key_nd {
  * a wildcarded match. Omitting attribute is treated as wildcarding all
  * corresponding fields. Optional for all requests. If not present,
  * all flow key bits are exact match bits.
+ * @OVS_FLOW_ATTR_UFID: A value between 1-16 octets specifying a unique
+ * identifier for the flow. Causes the flow to be indexed by this value rather
+ * than the value of the %OVS_FLOW_ATTR_KEY attribute. Optional for all
+ * requests. Present in notifications if the flow was created with this
+ * attribute.
+ * @OVS_FLOW_ATTR_UFID_FLAGS: A 32-bit value of OR'd %OVS_UFID_F_*
+ * flags that provide alternative semantics for flow installation and
+ * retrieval. Optional for all requests.
  *
  * These attributes follow the &struct ovs_header within the Generic Netlink
  * payload for %OVS_FLOW_* commands.
@@ -474,12 +482,24 @@ enum ovs_flow_attr {
 	OVS_FLOW_ATTR_MASK,      /* Sequence of OVS_KEY_ATTR_* attributes. */
 	OVS_FLOW_ATTR_PROBE,     /* Flow operation is a feature probe, error
 				  * logging should be suppressed. */
+	OVS_FLOW_ATTR_UFID,      /* Variable length unique flow identifier. */
+	OVS_FLOW_ATTR_UFID_FLAGS,/* u32 of OVS_UFID_F_*. */
 	__OVS_FLOW_ATTR_MAX
 };
 
 #define OVS_FLOW_ATTR_MAX (__OVS_FLOW_ATTR_MAX - 1)
 
 /**
+ * Omit attributes for notifications.
+ *
+ * If a datapath request contains an %OVS_UFID_F_OMIT_* flag, then the datapath
+ * may omit the corresponding %OVS_FLOW_ATTR_* from the response.
+ */
+#define OVS_UFID_F_OMIT_KEY      (1 << 0)
+#define OVS_UFID_F_OMIT_MASK     (1 << 1)
+#define OVS_UFID_F_OMIT_ACTIONS  (1 << 2)
+
+/**
  * enum ovs_sample_attr - Attributes for %OVS_ACTION_ATTR_SAMPLE action.
  * @OVS_SAMPLE_ATTR_PROBABILITY: 32-bit fraction of packets to sample with
  * @OVS_ACTION_ATTR_SAMPLE.  A value of 0 samples no packets, a value of
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 257b975..0e27257 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -65,6 +65,8 @@ static struct genl_family dp_packet_genl_family;
 static struct genl_family dp_flow_genl_family;
 static struct genl_family dp_datapath_genl_family;
 
+static const struct nla_policy flow_policy[];
+
 static const struct genl_multicast_group ovs_dp_flow_multicast_group = {
 	.name = OVS_FLOW_MCGROUP,
 };
@@ -662,15 +664,48 @@ static void get_dp_stats(const struct datapath *dp, struct ovs_dp_stats *stats,
 	}
 }
 
-static size_t ovs_flow_cmd_msg_size(const struct sw_flow_actions *acts)
+static bool should_fill_key(const struct sw_flow_id *sfid, uint32_t ufid_flags)
+{
+	return ovs_identifier_is_ufid(sfid) &&
+	       !(ufid_flags & OVS_UFID_F_OMIT_KEY);
+}
+
+static bool should_fill_mask(uint32_t ufid_flags)
+{
+	return !(ufid_flags & OVS_UFID_F_OMIT_MASK);
+}
+
+static bool should_fill_actions(uint32_t ufid_flags)
 {
-	return NLMSG_ALIGN(sizeof(struct ovs_header))
-		+ nla_total_size(ovs_key_attr_size()) /* OVS_FLOW_ATTR_KEY */
-		+ nla_total_size(ovs_key_attr_size()) /* OVS_FLOW_ATTR_MASK */
+	return !(ufid_flags & OVS_UFID_F_OMIT_ACTIONS);
+}
+
+static size_t ovs_flow_cmd_msg_size(const struct sw_flow_actions *acts,
+				    const struct sw_flow_id *sfid,
+				    uint32_t ufid_flags)
+{
+	size_t len = NLMSG_ALIGN(sizeof(struct ovs_header));
+
+	/* OVS_FLOW_ATTR_UFID */
+	if (sfid && ovs_identifier_is_ufid(sfid))
+		len += nla_total_size(sfid->ufid_len);
+
+	/* OVS_FLOW_ATTR_KEY */
+	if (!sfid || should_fill_key(sfid, ufid_flags))
+		len += nla_total_size(ovs_key_attr_size());
+
+	/* OVS_FLOW_ATTR_MASK */
+	if (should_fill_mask(ufid_flags))
+		len += nla_total_size(ovs_key_attr_size());
+
+	/* OVS_FLOW_ATTR_ACTIONS */
+	if (should_fill_actions(ufid_flags))
+		len += nla_total_size(acts->actions_len);
+
+	return len
 		+ nla_total_size(sizeof(struct ovs_flow_stats)) /* OVS_FLOW_ATTR_STATS */
 		+ nla_total_size(1) /* OVS_FLOW_ATTR_TCP_FLAGS */
-		+ nla_total_size(8) /* OVS_FLOW_ATTR_USED */
-		+ nla_total_size(acts->actions_len); /* OVS_FLOW_ATTR_ACTIONS */
+		+ nla_total_size(8); /* OVS_FLOW_ATTR_USED */
 }
 
 /* Called with ovs_mutex or RCU read lock. */
@@ -741,7 +776,7 @@ static int ovs_flow_cmd_fill_actions(const struct sw_flow *flow,
 /* Called with ovs_mutex or RCU read lock. */
 static int ovs_flow_cmd_fill_info(const struct sw_flow *flow, int dp_ifindex,
 				  struct sk_buff *skb, u32 portid,
-				  u32 seq, u32 flags, u8 cmd)
+				  u32 seq, u32 flags, u8 cmd, u32 ufid_flags)
 {
 	const int skb_orig_len = skb->len;
 	struct ovs_header *ovs_header;
@@ -754,21 +789,31 @@ static int ovs_flow_cmd_fill_info(const struct sw_flow *flow, int dp_ifindex,
 
 	ovs_header->dp_ifindex = dp_ifindex;
 
-	err = ovs_nla_put_unmasked_key(flow, skb);
+	err = ovs_nla_put_identifier(flow, skb);
 	if (err)
 		goto error;
 
-	err = ovs_nla_put_mask(flow, skb);
-	if (err)
-		goto error;
+	if (should_fill_key(&flow->id, ufid_flags)) {
+		err = ovs_nla_put_masked_key(flow, skb);
+		if (err)
+			goto error;
+	}
+
+	if (should_fill_mask(ufid_flags)) {
+		err = ovs_nla_put_mask(flow, skb);
+		if (err)
+			goto error;
+	}
 
 	err = ovs_flow_cmd_fill_stats(flow, skb);
 	if (err)
 		goto error;
 
-	err = ovs_flow_cmd_fill_actions(flow, skb, skb_orig_len);
-	if (err)
-		goto error;
+	if (should_fill_actions(ufid_flags)) {
+		err = ovs_flow_cmd_fill_actions(flow, skb, skb_orig_len);
+		if (err)
+			goto error;
+	}
 
 	genlmsg_end(skb, ovs_header);
 	return 0;
@@ -780,15 +825,19 @@ error:
 
 /* May not be called with RCU read lock. */
 static struct sk_buff *ovs_flow_cmd_alloc_info(const struct sw_flow_actions *acts,
+					       const struct sw_flow_id *sfid,
 					       struct genl_info *info,
-					       bool always)
+					       bool always,
+					       uint32_t ufid_flags)
 {
 	struct sk_buff *skb;
+	size_t len;
 
 	if (!always && !ovs_must_notify(&dp_flow_genl_family, info, 0))
 		return NULL;
 
-	skb = genlmsg_new_unicast(ovs_flow_cmd_msg_size(acts), info, GFP_KERNEL);
+	len = ovs_flow_cmd_msg_size(acts, sfid, ufid_flags);
+	skb = genlmsg_new_unicast(len, info, GFP_KERNEL);
 	if (!skb)
 		return ERR_PTR(-ENOMEM);
 
@@ -799,19 +848,19 @@ static struct sk_buff *ovs_flow_cmd_alloc_info(const struct sw_flow_actions *act
 static struct sk_buff *ovs_flow_cmd_build_info(const struct sw_flow *flow,
 					       int dp_ifindex,
 					       struct genl_info *info, u8 cmd,
-					       bool always)
+					       bool always, u32 ufid_flags)
 {
 	struct sk_buff *skb;
 	int retval;
 
-	skb = ovs_flow_cmd_alloc_info(ovsl_dereference(flow->sf_acts), info,
-				      always);
+	skb = ovs_flow_cmd_alloc_info(ovsl_dereference(flow->sf_acts),
+				      &flow->id, info, always, ufid_flags);
 	if (IS_ERR_OR_NULL(skb))
 		return skb;
 
 	retval = ovs_flow_cmd_fill_info(flow, dp_ifindex, skb,
 					info->snd_portid, info->snd_seq, 0,
-					cmd);
+					cmd, ufid_flags);
 	BUG_ON(retval < 0);
 	return skb;
 }
@@ -820,12 +869,14 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 {
 	struct nlattr **a = info->attrs;
 	struct ovs_header *ovs_header = info->userhdr;
-	struct sw_flow *flow, *new_flow;
+	struct sw_flow *flow = NULL, *new_flow;
 	struct sw_flow_mask mask;
 	struct sk_buff *reply;
 	struct datapath *dp;
+	struct sw_flow_key key;
 	struct sw_flow_actions *acts;
 	struct sw_flow_match match;
+	u32 ufid_flags = ovs_nla_get_ufid_flags(a[OVS_FLOW_ATTR_UFID_FLAGS]);
 	int error;
 	bool log = !a[OVS_FLOW_ATTR_PROBE];
 
@@ -850,13 +901,19 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	}
 
 	/* Extract key. */
-	ovs_match_init(&match, &new_flow->unmasked_key, &mask);
+	ovs_match_init(&match, &key, &mask);
 	error = ovs_nla_get_match(&match, a[OVS_FLOW_ATTR_KEY],
 				  a[OVS_FLOW_ATTR_MASK], log);
 	if (error)
 		goto err_kfree_flow;
 
-	ovs_flow_mask_key(&new_flow->key, &new_flow->unmasked_key, &mask);
+	ovs_flow_mask_key(&new_flow->key, &key, &mask);
+
+	/* Extract flow identifier. */
+	error = ovs_nla_get_identifier(&new_flow->id, a[OVS_FLOW_ATTR_UFID],
+				       &key, log);
+	if (error)
+		goto err_kfree_flow;
 
 	/* Validate actions. */
 	error = ovs_nla_copy_actions(a[OVS_FLOW_ATTR_ACTIONS], &new_flow->key,
@@ -866,7 +923,8 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 		goto err_kfree_flow;
 	}
 
-	reply = ovs_flow_cmd_alloc_info(acts, info, false);
+	reply = ovs_flow_cmd_alloc_info(acts, &new_flow->id, info, false,
+					ufid_flags);
 	if (IS_ERR(reply)) {
 		error = PTR_ERR(reply);
 		goto err_kfree_acts;
@@ -878,8 +936,12 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 		error = -ENODEV;
 		goto err_unlock_ovs;
 	}
+
 	/* Check if this is a duplicate flow */
-	flow = ovs_flow_tbl_lookup(&dp->table, &new_flow->unmasked_key);
+	if (ovs_identifier_is_ufid(&new_flow->id))
+		flow = ovs_flow_tbl_lookup_ufid(&dp->table, &new_flow->id);
+	if (!flow)
+		flow = ovs_flow_tbl_lookup(&dp->table, &new_flow->key);
 	if (likely(!flow)) {
 		rcu_assign_pointer(new_flow->sf_acts, acts);
 
@@ -895,7 +957,8 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 						       ovs_header->dp_ifindex,
 						       reply, info->snd_portid,
 						       info->snd_seq, 0,
-						       OVS_FLOW_CMD_NEW);
+						       OVS_FLOW_CMD_NEW,
+						       ufid_flags);
 			BUG_ON(error < 0);
 		}
 		ovs_unlock();
@@ -913,10 +976,15 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 			error = -EEXIST;
 			goto err_unlock_ovs;
 		}
-		/* The unmasked key has to be the same for flow updates. */
-		if (unlikely(!ovs_flow_cmp_unmasked_key(flow, &match))) {
-			/* Look for any overlapping flow. */
-			flow = ovs_flow_tbl_lookup_exact(&dp->table, &match);
+		/* The flow identifier has to be the same for flow updates.
+		 * Look for any overlapping flow.
+		 */
+		if (unlikely(!ovs_flow_cmp(flow, &match))) {
+			if (ovs_identifier_is_key(&flow->id))
+				flow = ovs_flow_tbl_lookup_exact(&dp->table,
+								 &match);
+			else /* UFID matches but key is different */
+				flow = NULL;
 			if (!flow) {
 				error = -ENOENT;
 				goto err_unlock_ovs;
@@ -931,7 +999,8 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 						       ovs_header->dp_ifindex,
 						       reply, info->snd_portid,
 						       info->snd_seq, 0,
-						       OVS_FLOW_CMD_NEW);
+						       OVS_FLOW_CMD_NEW,
+						       ufid_flags);
 			BUG_ON(error < 0);
 		}
 		ovs_unlock();
@@ -987,8 +1056,11 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
 	struct datapath *dp;
 	struct sw_flow_actions *old_acts = NULL, *acts = NULL;
 	struct sw_flow_match match;
+	struct sw_flow_id sfid;
+	u32 ufid_flags = ovs_nla_get_ufid_flags(a[OVS_FLOW_ATTR_UFID_FLAGS]);
 	int error;
 	bool log = !a[OVS_FLOW_ATTR_PROBE];
+	bool ufid_present;
 
 	/* Extract key. */
 	error = -EINVAL;
@@ -997,6 +1069,7 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
 		goto error;
 	}
 
+	ufid_present = ovs_nla_get_ufid(&sfid, a[OVS_FLOW_ATTR_UFID], log);
 	ovs_match_init(&match, &key, &mask);
 	error = ovs_nla_get_match(&match, a[OVS_FLOW_ATTR_KEY],
 				  a[OVS_FLOW_ATTR_MASK], log);
@@ -1013,7 +1086,8 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
 		}
 
 		/* Can allocate before locking if have acts. */
-		reply = ovs_flow_cmd_alloc_info(acts, info, false);
+		reply = ovs_flow_cmd_alloc_info(acts, &sfid, info, false,
+						ufid_flags);
 		if (IS_ERR(reply)) {
 			error = PTR_ERR(reply);
 			goto err_kfree_acts;
@@ -1027,7 +1101,10 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
 		goto err_unlock_ovs;
 	}
 	/* Check that the flow exists. */
-	flow = ovs_flow_tbl_lookup_exact(&dp->table, &match);
+	if (ufid_present)
+		flow = ovs_flow_tbl_lookup_ufid(&dp->table, &sfid);
+	else
+		flow = ovs_flow_tbl_lookup_exact(&dp->table, &match);
 	if (unlikely(!flow)) {
 		error = -ENOENT;
 		goto err_unlock_ovs;
@@ -1043,13 +1120,16 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
 						       ovs_header->dp_ifindex,
 						       reply, info->snd_portid,
 						       info->snd_seq, 0,
-						       OVS_FLOW_CMD_NEW);
+						       OVS_FLOW_CMD_NEW,
+						       ufid_flags);
 			BUG_ON(error < 0);
 		}
 	} else {
 		/* Could not alloc without acts before locking. */
 		reply = ovs_flow_cmd_build_info(flow, ovs_header->dp_ifindex,
-						info, OVS_FLOW_CMD_NEW, false);
+						info, OVS_FLOW_CMD_NEW, false,
+						ufid_flags);
+
 		if (unlikely(IS_ERR(reply))) {
 			error = PTR_ERR(reply);
 			goto err_unlock_ovs;
@@ -1086,17 +1166,22 @@ static int ovs_flow_cmd_get(struct sk_buff *skb, struct genl_info *info)
 	struct sw_flow *flow;
 	struct datapath *dp;
 	struct sw_flow_match match;
-	int err;
+	struct sw_flow_id ufid;
+	u32 ufid_flags = ovs_nla_get_ufid_flags(a[OVS_FLOW_ATTR_UFID_FLAGS]);
+	int err = 0;
 	bool log = !a[OVS_FLOW_ATTR_PROBE];
+	bool ufid_present;
 
-	if (!a[OVS_FLOW_ATTR_KEY]) {
+	ufid_present = ovs_nla_get_ufid(&ufid, a[OVS_FLOW_ATTR_UFID], log);
+	if (a[OVS_FLOW_ATTR_KEY]) {
+		ovs_match_init(&match, &key, NULL);
+		err = ovs_nla_get_match(&match, a[OVS_FLOW_ATTR_KEY], NULL,
+					log);
+	} else if (!ufid_present) {
 		OVS_NLERR(log,
 			  "Flow get message rejected, Key attribute missing.");
-		return -EINVAL;
+		err = -EINVAL;
 	}
-
-	ovs_match_init(&match, &key, NULL);
-	err = ovs_nla_get_match(&match, a[OVS_FLOW_ATTR_KEY], NULL, log);
 	if (err)
 		return err;
 
@@ -1107,14 +1192,17 @@ static int ovs_flow_cmd_get(struct sk_buff *skb, struct genl_info *info)
 		goto unlock;
 	}
 
-	flow = ovs_flow_tbl_lookup_exact(&dp->table, &match);
+	if (ufid_present)
+		flow = ovs_flow_tbl_lookup_ufid(&dp->table, &ufid);
+	else
+		flow = ovs_flow_tbl_lookup_exact(&dp->table, &match);
 	if (!flow) {
 		err = -ENOENT;
 		goto unlock;
 	}
 
 	reply = ovs_flow_cmd_build_info(flow, ovs_header->dp_ifindex, info,
-					OVS_FLOW_CMD_NEW, true);
+					OVS_FLOW_CMD_NEW, true, ufid_flags);
 	if (IS_ERR(reply)) {
 		err = PTR_ERR(reply);
 		goto unlock;
@@ -1133,13 +1221,17 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	struct ovs_header *ovs_header = info->userhdr;
 	struct sw_flow_key key;
 	struct sk_buff *reply;
-	struct sw_flow *flow;
+	struct sw_flow *flow = NULL;
 	struct datapath *dp;
 	struct sw_flow_match match;
+	struct sw_flow_id ufid;
+	u32 ufid_flags = ovs_nla_get_ufid_flags(a[OVS_FLOW_ATTR_UFID_FLAGS]);
 	int err;
 	bool log = !a[OVS_FLOW_ATTR_PROBE];
+	bool ufid_present;
 
-	if (likely(a[OVS_FLOW_ATTR_KEY])) {
+	ufid_present = ovs_nla_get_ufid(&ufid, a[OVS_FLOW_ATTR_UFID], log);
+	if (a[OVS_FLOW_ATTR_KEY]) {
 		ovs_match_init(&match, &key, NULL);
 		err = ovs_nla_get_match(&match, a[OVS_FLOW_ATTR_KEY], NULL,
 					log);
@@ -1154,12 +1246,15 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 		goto unlock;
 	}
 
-	if (unlikely(!a[OVS_FLOW_ATTR_KEY])) {
+	if (unlikely(!a[OVS_FLOW_ATTR_KEY] && !ufid_present)) {
 		err = ovs_flow_tbl_flush(&dp->table);
 		goto unlock;
 	}
 
-	flow = ovs_flow_tbl_lookup_exact(&dp->table, &match);
+	if (ufid_present)
+		flow = ovs_flow_tbl_lookup_ufid(&dp->table, &ufid);
+	else
+		flow = ovs_flow_tbl_lookup_exact(&dp->table, &match);
 	if (unlikely(!flow)) {
 		err = -ENOENT;
 		goto unlock;
@@ -1169,14 +1264,15 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	ovs_unlock();
 
 	reply = ovs_flow_cmd_alloc_info((const struct sw_flow_actions __force *) flow->sf_acts,
-					info, false);
+					&flow->id, info, false, ufid_flags);
 	if (likely(reply)) {
 		if (likely(!IS_ERR(reply))) {
 			rcu_read_lock();	/*To keep RCU checker happy. */
 			err = ovs_flow_cmd_fill_info(flow, ovs_header->dp_ifindex,
 						     reply, info->snd_portid,
 						     info->snd_seq, 0,
-						     OVS_FLOW_CMD_DEL);
+						     OVS_FLOW_CMD_DEL,
+						     ufid_flags);
 			rcu_read_unlock();
 			BUG_ON(err < 0);
 
@@ -1195,9 +1291,18 @@ unlock:
 
 static int ovs_flow_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
+	struct nlattr *a[__OVS_FLOW_ATTR_MAX];
 	struct ovs_header *ovs_header = genlmsg_data(nlmsg_data(cb->nlh));
 	struct table_instance *ti;
 	struct datapath *dp;
+	u32 ufid_flags;
+	int err;
+
+	err = genlmsg_parse(cb->nlh, &dp_flow_genl_family, a,
+			    OVS_FLOW_ATTR_MAX, flow_policy);
+	if (err)
+		return err;
+	ufid_flags = ovs_nla_get_ufid_flags(a[OVS_FLOW_ATTR_UFID_FLAGS]);
 
 	rcu_read_lock();
 	dp = get_dp_rcu(sock_net(skb->sk), ovs_header->dp_ifindex);
@@ -1220,7 +1325,7 @@ static int ovs_flow_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
 		if (ovs_flow_cmd_fill_info(flow, ovs_header->dp_ifindex, skb,
 					   NETLINK_CB(cb->skb).portid,
 					   cb->nlh->nlmsg_seq, NLM_F_MULTI,
-					   OVS_FLOW_CMD_NEW) < 0)
+					   OVS_FLOW_CMD_NEW, ufid_flags) < 0)
 			break;
 
 		cb->args[0] = bucket;
@@ -1236,6 +1341,8 @@ static const struct nla_policy flow_policy[OVS_FLOW_ATTR_MAX + 1] = {
 	[OVS_FLOW_ATTR_ACTIONS] = { .type = NLA_NESTED },
 	[OVS_FLOW_ATTR_CLEAR] = { .type = NLA_FLAG },
 	[OVS_FLOW_ATTR_PROBE] = { .type = NLA_FLAG },
+	[OVS_FLOW_ATTR_UFID] = { .type = NLA_UNSPEC, .len = 1 },
+	[OVS_FLOW_ATTR_UFID_FLAGS] = { .type = NLA_U32 },
 };
 
 static const struct genl_ops dp_flow_genl_ops[] = {
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index d3d0a40..a076e44 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -197,6 +197,16 @@ struct sw_flow_match {
 	struct sw_flow_mask *mask;
 };
 
+#define MAX_UFID_LENGTH 16 /* 128 bits */
+
+struct sw_flow_id {
+	u32 ufid_len;
+	union {
+		u32 ufid[MAX_UFID_LENGTH / 4];
+		struct sw_flow_key *unmasked_key;
+	};
+};
+
 struct sw_flow_actions {
 	struct rcu_head rcu;
 	u32 actions_len;
@@ -213,13 +223,15 @@ struct flow_stats {
 
 struct sw_flow {
 	struct rcu_head rcu;
-	struct hlist_node hash_node[2];
-	u32 hash;
+	struct {
+		struct hlist_node node[2];
+		u32 hash;
+	} flow_table, ufid_table;
 	int stats_last_writer;		/* NUMA-node id of the last writer on
 					 * 'stats[0]'.
 					 */
 	struct sw_flow_key key;
-	struct sw_flow_key unmasked_key;
+	struct sw_flow_id id;
 	struct sw_flow_mask *mask;
 	struct sw_flow_actions __rcu *sf_acts;
 	struct flow_stats __rcu *stats[]; /* One for each NUMA node.  First one
@@ -243,6 +255,16 @@ struct arp_eth_header {
 	unsigned char       ar_tip[4];		/* target IP address        */
 } __packed;
 
+static inline bool ovs_identifier_is_ufid(const struct sw_flow_id *sfid)
+{
+	return sfid->ufid_len;
+}
+
+static inline bool ovs_identifier_is_key(const struct sw_flow_id *sfid)
+{
+	return !ovs_identifier_is_ufid(sfid);
+}
+
 void ovs_flow_stats_update(struct sw_flow *, __be16 tcp_flags,
 			   const struct sk_buff *);
 void ovs_flow_stats_get(const struct sw_flow *, struct ovs_flow_stats *,
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 398f110..42b3fa8 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -1180,6 +1180,59 @@ free_newmask:
 	return err;
 }
 
+static size_t get_ufid_len(const struct nlattr *attr, bool log)
+{
+	size_t len;
+
+	if (!attr)
+		return 0;
+
+	len = nla_len(attr);
+	if (len < 1 || len > MAX_UFID_LENGTH) {
+		OVS_NLERR(log, "Flow ufid size %u bytes is outside the range "
+			       "(1, %d)", nla_len(attr), MAX_UFID_LENGTH);
+		return 0;
+	}
+
+	return len;
+}
+
+/* Initializes 'flow->ufid', returning true if 'attr' contains a valid UFID,
+ * or false otherwise. */
+bool ovs_nla_get_ufid(struct sw_flow_id *sfid, const struct nlattr *attr,
+		      bool log)
+{
+	sfid->ufid_len = get_ufid_len(attr, log);
+	if (sfid->ufid_len)
+		memcpy(sfid->ufid, nla_data(attr), sfid->ufid_len);
+
+	return sfid->ufid_len;
+}
+
+int ovs_nla_get_identifier(struct sw_flow_id *sfid, const struct nlattr *ufid,
+			   const struct sw_flow_key *key, bool log)
+{
+	struct sw_flow_key *new_key;
+
+	if (ovs_nla_get_ufid(sfid, ufid, log))
+		return 0;
+
+	/* If UFID was not provided, use unmasked key. */
+	new_key = kmalloc(sizeof(*new_key), GFP_KERNEL);
+	if (!new_key)
+		return -ENOMEM;
+	memcpy(new_key, key, sizeof(*key));
+	sfid->unmasked_key = new_key;
+
+	return 0;
+}
+
+
+u32 ovs_nla_get_ufid_flags(const struct nlattr *attr)
+{
+	return attr ? nla_get_u32(attr) : 0;
+}
+
 /**
  * ovs_nla_get_flow_metadata - parses Netlink attributes into a flow key.
  * @key: Receives extracted in_port, priority, tun_key and skb_mark.
@@ -1450,9 +1503,20 @@ int ovs_nla_put_key(const struct sw_flow_key *swkey,
 }
 
 /* Called with ovs_mutex or RCU read lock. */
-int ovs_nla_put_unmasked_key(const struct sw_flow *flow, struct sk_buff *skb)
+int ovs_nla_put_identifier(const struct sw_flow *flow, struct sk_buff *skb)
+{
+	if (ovs_identifier_is_ufid(&flow->id))
+		return nla_put(skb, OVS_FLOW_ATTR_UFID, flow->id.ufid_len,
+			       flow->id.ufid);
+
+	return ovs_nla_put_key(flow->id.unmasked_key, flow->id.unmasked_key,
+			       OVS_FLOW_ATTR_KEY, false, skb);
+}
+
+/* Called with ovs_mutex or RCU read lock. */
+int ovs_nla_put_masked_key(const struct sw_flow *flow, struct sk_buff *skb)
 {
-	return ovs_nla_put_key(&flow->unmasked_key, &flow->unmasked_key,
+	return ovs_nla_put_key(&flow->mask->key, &flow->key,
 				OVS_FLOW_ATTR_KEY, false, skb);
 }
 
diff --git a/net/openvswitch/flow_netlink.h b/net/openvswitch/flow_netlink.h
index 9ed09e6..5c3d75b 100644
--- a/net/openvswitch/flow_netlink.h
+++ b/net/openvswitch/flow_netlink.h
@@ -48,7 +48,8 @@ int ovs_nla_put_key(const struct sw_flow_key *, const struct sw_flow_key *,
 int ovs_nla_get_flow_metadata(const struct nlattr *, struct sw_flow_key *,
 			      bool log);
 
-int ovs_nla_put_unmasked_key(const struct sw_flow *flow, struct sk_buff *skb);
+int ovs_nla_put_identifier(const struct sw_flow *flow, struct sk_buff *skb);
+int ovs_nla_put_masked_key(const struct sw_flow *flow, struct sk_buff *skb);
 int ovs_nla_put_mask(const struct sw_flow *flow, struct sk_buff *skb);
 
 int ovs_nla_get_match(struct sw_flow_match *, const struct nlattr *key,
@@ -56,6 +57,11 @@ int ovs_nla_get_match(struct sw_flow_match *, const struct nlattr *key,
 int ovs_nla_put_egress_tunnel_key(struct sk_buff *,
 				  const struct ovs_tunnel_info *);
 
+bool ovs_nla_get_ufid(struct sw_flow_id *, const struct nlattr *, bool log);
+int ovs_nla_get_identifier(struct sw_flow_id *sfid, const struct nlattr *ufid,
+			   const struct sw_flow_key *key, bool log);
+u32 ovs_nla_get_ufid_flags(const struct nlattr *attr);
+
 int ovs_nla_copy_actions(const struct nlattr *attr,
 			 const struct sw_flow_key *key,
 			 struct sw_flow_actions **sfa, bool log);
diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
index 9a3f41f..5e57628 100644
--- a/net/openvswitch/flow_table.c
+++ b/net/openvswitch/flow_table.c
@@ -139,6 +139,8 @@ static void flow_free(struct sw_flow *flow)
 {
 	int node;
 
+	if (ovs_identifier_is_key(&flow->id))
+		kfree(flow->id.unmasked_key);
 	kfree((struct sw_flow_actions __force *)flow->sf_acts);
 	for_each_node(node)
 		if (flow->stats[node])
@@ -200,18 +202,28 @@ static struct table_instance *table_instance_alloc(int new_size)
 
 int ovs_flow_tbl_init(struct flow_table *table)
 {
-	struct table_instance *ti;
+	struct table_instance *ti, *ufid_ti;
 
 	ti = table_instance_alloc(TBL_MIN_BUCKETS);
 
 	if (!ti)
 		return -ENOMEM;
 
+	ufid_ti = table_instance_alloc(TBL_MIN_BUCKETS);
+	if (!ufid_ti)
+		goto free_ti;
+
 	rcu_assign_pointer(table->ti, ti);
+	rcu_assign_pointer(table->ufid_ti, ufid_ti);
 	INIT_LIST_HEAD(&table->mask_list);
 	table->last_rehash = jiffies;
 	table->count = 0;
+	table->ufid_count = 0;
 	return 0;
+
+free_ti:
+	__table_instance_destroy(ti);
+	return -ENOMEM;
 }
 
 static void flow_tbl_destroy_rcu_cb(struct rcu_head *rcu)
@@ -221,13 +233,16 @@ static void flow_tbl_destroy_rcu_cb(struct rcu_head *rcu)
 	__table_instance_destroy(ti);
 }
 
-static void table_instance_destroy(struct table_instance *ti, bool deferred)
+static void table_instance_destroy(struct table_instance *ti,
+				   struct table_instance *ufid_ti,
+				   bool deferred)
 {
 	int i;
 
 	if (!ti)
 		return;
 
+	BUG_ON(!ufid_ti);
 	if (ti->keep_flows)
 		goto skip_flows;
 
@@ -236,18 +251,24 @@ static void table_instance_destroy(struct table_instance *ti, bool deferred)
 		struct hlist_head *head = flex_array_get(ti->buckets, i);
 		struct hlist_node *n;
 		int ver = ti->node_ver;
+		int ufid_ver = ufid_ti->node_ver;
 
-		hlist_for_each_entry_safe(flow, n, head, hash_node[ver]) {
-			hlist_del_rcu(&flow->hash_node[ver]);
+		hlist_for_each_entry_safe(flow, n, head, flow_table.node[ver]) {
+			hlist_del_rcu(&flow->flow_table.node[ver]);
+			if (ovs_identifier_is_ufid(&flow->id))
+				hlist_del_rcu(&flow->ufid_table.node[ufid_ver]);
 			ovs_flow_free(flow, deferred);
 		}
 	}
 
 skip_flows:
-	if (deferred)
+	if (deferred) {
 		call_rcu(&ti->rcu, flow_tbl_destroy_rcu_cb);
-	else
+		call_rcu(&ufid_ti->rcu, flow_tbl_destroy_rcu_cb);
+	} else {
 		__table_instance_destroy(ti);
+		__table_instance_destroy(ufid_ti);
+	}
 }
 
 /* No need for locking this function is called from RCU callback or
@@ -256,8 +277,9 @@ skip_flows:
 void ovs_flow_tbl_destroy(struct flow_table *table)
 {
 	struct table_instance *ti = rcu_dereference_raw(table->ti);
+	struct table_instance *ufid_ti = rcu_dereference_raw(table->ufid_ti);
 
-	table_instance_destroy(ti, false);
+	table_instance_destroy(ti, ufid_ti, false);
 }
 
 struct sw_flow *ovs_flow_tbl_dump_next(struct table_instance *ti,
@@ -272,7 +294,7 @@ struct sw_flow *ovs_flow_tbl_dump_next(struct table_instance *ti,
 	while (*bucket < ti->n_buckets) {
 		i = 0;
 		head = flex_array_get(ti->buckets, *bucket);
-		hlist_for_each_entry_rcu(flow, head, hash_node[ver]) {
+		hlist_for_each_entry_rcu(flow, head, flow_table.node[ver]) {
 			if (i < *last) {
 				i++;
 				continue;
@@ -294,16 +316,26 @@ static struct hlist_head *find_bucket(struct table_instance *ti, u32 hash)
 				(hash & (ti->n_buckets - 1)));
 }
 
-static void table_instance_insert(struct table_instance *ti, struct sw_flow *flow)
+static void table_instance_insert(struct table_instance *ti,
+				  struct sw_flow *flow)
 {
 	struct hlist_head *head;
 
-	head = find_bucket(ti, flow->hash);
-	hlist_add_head_rcu(&flow->hash_node[ti->node_ver], head);
+	head = find_bucket(ti, flow->flow_table.hash);
+	hlist_add_head_rcu(&flow->flow_table.node[ti->node_ver], head);
+}
+
+static void ufid_table_instance_insert(struct table_instance *ti,
+				       struct sw_flow *flow)
+{
+	struct hlist_head *head;
+
+	head = find_bucket(ti, flow->ufid_table.hash);
+	hlist_add_head_rcu(&flow->ufid_table.node[ti->node_ver], head);
 }
 
 static void flow_table_copy_flows(struct table_instance *old,
-				  struct table_instance *new)
+				  struct table_instance *new, bool ufid)
 {
 	int old_ver;
 	int i;
@@ -318,15 +350,21 @@ static void flow_table_copy_flows(struct table_instance *old,
 
 		head = flex_array_get(old->buckets, i);
 
-		hlist_for_each_entry(flow, head, hash_node[old_ver])
-			table_instance_insert(new, flow);
+		if (ufid)
+			hlist_for_each_entry(flow, head,
+					     ufid_table.node[old_ver])
+				ufid_table_instance_insert(new, flow);
+		else
+			hlist_for_each_entry(flow, head,
+					     flow_table.node[old_ver])
+				table_instance_insert(new, flow);
 	}
 
 	old->keep_flows = true;
 }
 
 static struct table_instance *table_instance_rehash(struct table_instance *ti,
-					    int n_buckets)
+						    int n_buckets, bool ufid)
 {
 	struct table_instance *new_ti;
 
@@ -334,27 +372,38 @@ static struct table_instance *table_instance_rehash(struct table_instance *ti,
 	if (!new_ti)
 		return NULL;
 
-	flow_table_copy_flows(ti, new_ti);
+	flow_table_copy_flows(ti, new_ti, ufid);
 
 	return new_ti;
 }
 
 int ovs_flow_tbl_flush(struct flow_table *flow_table)
 {
-	struct table_instance *old_ti;
-	struct table_instance *new_ti;
+	struct table_instance *old_ti, *new_ti;
+	struct table_instance *old_ufid_ti, *new_ufid_ti;
 
-	old_ti = ovsl_dereference(flow_table->ti);
 	new_ti = table_instance_alloc(TBL_MIN_BUCKETS);
 	if (!new_ti)
 		return -ENOMEM;
+	new_ufid_ti = table_instance_alloc(TBL_MIN_BUCKETS);
+	if (!new_ufid_ti)
+		goto err_free_ti;
+
+	old_ti = ovsl_dereference(flow_table->ti);
+	old_ufid_ti = ovsl_dereference(flow_table->ufid_ti);
 
 	rcu_assign_pointer(flow_table->ti, new_ti);
+	rcu_assign_pointer(flow_table->ufid_ti, new_ufid_ti);
 	flow_table->last_rehash = jiffies;
 	flow_table->count = 0;
+	flow_table->ufid_count = 0;
 
-	table_instance_destroy(old_ti, true);
+	table_instance_destroy(old_ti, old_ufid_ti, true);
 	return 0;
+
+err_free_ti:
+	__table_instance_destroy(new_ti);
+	return -ENOMEM;
 }
 
 static u32 flow_hash(const struct sw_flow_key *key,
@@ -402,14 +451,15 @@ static bool flow_cmp_masked_key(const struct sw_flow *flow,
 	return cmp_key(&flow->key, key, range->start, range->end);
 }
 
-bool ovs_flow_cmp_unmasked_key(const struct sw_flow *flow,
-			       const struct sw_flow_match *match)
+static bool ovs_flow_cmp_unmasked_key(const struct sw_flow *flow,
+				      const struct sw_flow_match *match)
 {
 	struct sw_flow_key *key = match->key;
 	int key_start = flow_key_start(key);
 	int key_end = match->range.end;
 
-	return cmp_key(&flow->unmasked_key, key, key_start, key_end);
+	BUG_ON(ovs_identifier_is_ufid(&flow->id));
+	return cmp_key(flow->id.unmasked_key, key, key_start, key_end);
 }
 
 static struct sw_flow *masked_flow_lookup(struct table_instance *ti,
@@ -424,8 +474,8 @@ static struct sw_flow *masked_flow_lookup(struct table_instance *ti,
 	ovs_flow_mask_key(&masked_key, unmasked, mask);
 	hash = flow_hash(&masked_key, &mask->range);
 	head = find_bucket(ti, hash);
-	hlist_for_each_entry_rcu(flow, head, hash_node[ti->node_ver]) {
-		if (flow->mask == mask && flow->hash == hash &&
+	hlist_for_each_entry_rcu(flow, head, flow_table.node[ti->node_ver]) {
+		if (flow->mask == mask && flow->flow_table.hash == hash &&
 		    flow_cmp_masked_key(flow, &masked_key, &mask->range))
 			return flow;
 	}
@@ -468,7 +518,48 @@ struct sw_flow *ovs_flow_tbl_lookup_exact(struct flow_table *tbl,
 	/* Always called under ovs-mutex. */
 	list_for_each_entry(mask, &tbl->mask_list, list) {
 		flow = masked_flow_lookup(ti, match->key, mask);
-		if (flow && ovs_flow_cmp_unmasked_key(flow, match))  /* Found */
+		if (flow && ovs_identifier_is_key(&flow->id) &&
+		    ovs_flow_cmp_unmasked_key(flow, match))
+			return flow;
+	}
+	return NULL;
+}
+
+static u32 ufid_hash(const struct sw_flow_id *sfid)
+{
+	return jhash(sfid->ufid, sfid->ufid_len, 0);
+}
+
+static bool ovs_flow_cmp_ufid(const struct sw_flow *flow,
+			      const struct sw_flow_id *sfid)
+{
+	if (flow->id.ufid_len != sfid->ufid_len)
+		return false;
+
+	return !memcmp(flow->id.ufid, sfid->ufid, sfid->ufid_len);
+}
+
+bool ovs_flow_cmp(const struct sw_flow *flow, const struct sw_flow_match *match)
+{
+	if (ovs_identifier_is_ufid(&flow->id))
+		return flow_cmp_masked_key(flow, match->key, &match->range);
+
+	return ovs_flow_cmp_unmasked_key(flow, match);
+}
+
+struct sw_flow *ovs_flow_tbl_lookup_ufid(struct flow_table *tbl,
+					 const struct sw_flow_id *ufid)
+{
+	struct table_instance *ti = rcu_dereference_ovsl(tbl->ufid_ti);
+	struct sw_flow *flow;
+	struct hlist_head *head;
+	u32 hash;
+
+	hash = ufid_hash(ufid);
+	head = find_bucket(ti, hash);
+	hlist_for_each_entry_rcu(flow, head, ufid_table.node[ti->node_ver]) {
+		if (flow->ufid_table.hash == hash &&
+		    ovs_flow_cmp_ufid(flow, ufid))
 			return flow;
 	}
 	return NULL;
@@ -485,9 +576,10 @@ int ovs_flow_tbl_num_masks(const struct flow_table *table)
 	return num;
 }
 
-static struct table_instance *table_instance_expand(struct table_instance *ti)
+static struct table_instance *table_instance_expand(struct table_instance *ti,
+						    bool ufid)
 {
-	return table_instance_rehash(ti, ti->n_buckets * 2);
+	return table_instance_rehash(ti, ti->n_buckets * 2, ufid);
 }
 
 /* Remove 'mask' from the mask list, if it is not needed any more. */
@@ -512,10 +604,15 @@ static void flow_mask_remove(struct flow_table *tbl, struct sw_flow_mask *mask)
 void ovs_flow_tbl_remove(struct flow_table *table, struct sw_flow *flow)
 {
 	struct table_instance *ti = ovsl_dereference(table->ti);
+	struct table_instance *ufid_ti = ovsl_dereference(table->ufid_ti);
 
 	BUG_ON(table->count == 0);
-	hlist_del_rcu(&flow->hash_node[ti->node_ver]);
+	hlist_del_rcu(&flow->flow_table.node[ti->node_ver]);
 	table->count--;
+	if (ovs_identifier_is_ufid(&flow->id)) {
+		hlist_del_rcu(&flow->ufid_table.node[ufid_ti->node_ver]);
+		table->ufid_count--;
+	}
 
 	/* RCU delete the mask. 'flow->mask' is not NULLed, as it should be
 	 * accessible as long as the RCU read lock is held.
@@ -589,25 +686,47 @@ static void flow_key_insert(struct flow_table *table, struct sw_flow *flow)
 	struct table_instance *new_ti = NULL;
 	struct table_instance *ti;
 
-	flow->hash = flow_hash(&flow->key, &flow->mask->range);
+	flow->flow_table.hash = flow_hash(&flow->key, &flow->mask->range);
 	ti = ovsl_dereference(table->ti);
 	table_instance_insert(ti, flow);
 	table->count++;
 
 	/* Expand table, if necessary, to make room. */
 	if (table->count > ti->n_buckets)
-		new_ti = table_instance_expand(ti);
+		new_ti = table_instance_expand(ti, false);
 	else if (time_after(jiffies, table->last_rehash + REHASH_INTERVAL))
-		new_ti = table_instance_rehash(ti, ti->n_buckets);
+		new_ti = table_instance_rehash(ti, ti->n_buckets, false);
 
 	if (new_ti) {
 		rcu_assign_pointer(table->ti, new_ti);
-		table_instance_destroy(ti, true);
+		call_rcu(&ti->rcu, flow_tbl_destroy_rcu_cb);
 		table->last_rehash = jiffies;
 	}
 }
 
 /* Must be called with OVS mutex held. */
+static void flow_ufid_insert(struct flow_table *table, struct sw_flow *flow)
+{
+	struct table_instance *ti;
+
+	flow->ufid_table.hash = ufid_hash(&flow->id);
+	ti = ovsl_dereference(table->ufid_ti);
+	ufid_table_instance_insert(ti, flow);
+	table->ufid_count++;
+
+	/* Expand table, if necessary, to make room. */
+	if (table->ufid_count > ti->n_buckets) {
+		struct table_instance *new_ti;
+
+		new_ti = table_instance_expand(ti, true);
+		if (new_ti) {
+			rcu_assign_pointer(table->ufid_ti, new_ti);
+			call_rcu(&ti->rcu, flow_tbl_destroy_rcu_cb);
+		}
+	}
+}
+
+/* Must be called with OVS mutex held. */
 int ovs_flow_tbl_insert(struct flow_table *table, struct sw_flow *flow,
 			const struct sw_flow_mask *mask)
 {
@@ -617,6 +736,8 @@ int ovs_flow_tbl_insert(struct flow_table *table, struct sw_flow *flow,
 	if (err)
 		return err;
 	flow_key_insert(table, flow);
+	if (ovs_identifier_is_ufid(&flow->id))
+		flow_ufid_insert(table, flow);
 
 	return 0;
 }
diff --git a/net/openvswitch/flow_table.h b/net/openvswitch/flow_table.h
index 309fa64..616eda1 100644
--- a/net/openvswitch/flow_table.h
+++ b/net/openvswitch/flow_table.h
@@ -47,9 +47,11 @@ struct table_instance {
 
 struct flow_table {
 	struct table_instance __rcu *ti;
+	struct table_instance __rcu *ufid_ti;
 	struct list_head mask_list;
 	unsigned long last_rehash;
 	unsigned int count;
+	unsigned int ufid_count;
 };
 
 extern struct kmem_cache *flow_stats_cache;
@@ -78,8 +80,10 @@ struct sw_flow *ovs_flow_tbl_lookup(struct flow_table *,
 				    const struct sw_flow_key *);
 struct sw_flow *ovs_flow_tbl_lookup_exact(struct flow_table *tbl,
 					  const struct sw_flow_match *match);
-bool ovs_flow_cmp_unmasked_key(const struct sw_flow *flow,
-			       const struct sw_flow_match *match);
+struct sw_flow *ovs_flow_tbl_lookup_ufid(struct flow_table *,
+					 const struct sw_flow_id *);
+
+bool ovs_flow_cmp(const struct sw_flow *, const struct sw_flow_match *);
 
 void ovs_flow_mask_key(struct sw_flow_key *dst, const struct sw_flow_key *src,
 		       const struct sw_flow_mask *mask);
-- 
1.7.10.4
