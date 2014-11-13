From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv10 ovs 12/15] datapath: Add support for unique flow identifiers.
Date: Thu, 13 Nov 2014 11:17:52 -0800
Message-ID: <1415906275-3172-13-git-send-email-joestringer@nicira.com>
References: <1415906275-3172-1-git-send-email-joestringer@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>, netdev@vger.kernel.org
To: dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog029.obsmtp.com ([74.125.150.103]:41666 "HELO
	na6sys009bog029.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S933758AbaKMThy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 14:37:54 -0500
Received: by mail-pa0-f52.google.com with SMTP id fa1so15942027pad.39
        for <netdev@vger.kernel.org>; Thu, 13 Nov 2014 11:37:53 -0800 (PST)
In-Reply-To: <1415906275-3172-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
during flow dump, increasing ovs-vswitchd revalidator performance by up
to 50%.

Signed-off-by: Joe Stringer <joestringer@nicira.com>
CC: Pravin B Shelar <pshelar@nicira.com>
CC: netdev@vger.kernel.org
---
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
 datapath/README.md                                |   13 ++
 datapath/datapath.c                               |  248 +++++++++++++++------
 datapath/flow.h                                   |   20 +-
 datapath/flow_netlink.c                           |   35 +++
 datapath/flow_netlink.h                           |    1 +
 datapath/flow_table.c                             |  214 ++++++++++++++----
 datapath/flow_table.h                             |    8 +
 datapath/linux/compat/include/linux/openvswitch.h |   30 +++
 8 files changed, 453 insertions(+), 116 deletions(-)

diff --git a/datapath/README.md b/datapath/README.md
index a8effa3..9c03a2b 100644
--- a/datapath/README.md
+++ b/datapath/README.md
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
 
diff --git a/datapath/datapath.c b/datapath/datapath.c
index a898584..c14d834 100644
--- a/datapath/datapath.c
+++ b/datapath/datapath.c
@@ -671,11 +671,18 @@ static void get_dp_stats(const struct datapath *dp, struct ovs_dp_stats *stats,
 	}
 }
 
-static size_t ovs_flow_cmd_msg_size(const struct sw_flow_actions *acts)
+static size_t ovs_flow_cmd_msg_size(const struct sw_flow_actions *acts,
+				    const struct sw_flow_id *sfid)
 {
+	size_t sfid_len = 0;
+
+	if (sfid && sfid->ufid_len)
+		sfid_len = nla_total_size(sfid->ufid_len);
+
 	return NLMSG_ALIGN(sizeof(struct ovs_header))
 		+ nla_total_size(ovs_key_attr_size()) /* OVS_FLOW_ATTR_KEY */
 		+ nla_total_size(ovs_key_attr_size()) /* OVS_FLOW_ATTR_MASK */
+		+ sfid_len /* OVS_FLOW_ATTR_UFID */
 		+ nla_total_size(sizeof(struct ovs_flow_stats)) /* OVS_FLOW_ATTR_STATS */
 		+ nla_total_size(1) /* OVS_FLOW_ATTR_TCP_FLAGS */
 		+ nla_total_size(8) /* OVS_FLOW_ATTR_USED */
@@ -684,33 +691,43 @@ static size_t ovs_flow_cmd_msg_size(const struct sw_flow_actions *acts)
 
 /* Called with ovs_mutex or RCU read lock. */
 static int ovs_flow_cmd_fill_match(const struct sw_flow *flow,
-				   struct sk_buff *skb)
+				   struct sk_buff *skb, u32 ufid_flags)
 {
 	struct nlattr *nla;
 	int err;
 
-	/* Fill flow key. */
-	nla = nla_nest_start(skb, OVS_FLOW_ATTR_KEY);
-	if (!nla)
-		return -EMSGSIZE;
-
-	err = ovs_nla_put_flow(&flow->unmasked_key, &flow->unmasked_key, skb,
-			       false);
-	if (err)
-		return err;
-
-	nla_nest_end(skb, nla);
+	/* Fill flow key. If userspace didn't specify a UFID, then ignore the
+	 * OMIT_KEY flag. */
+	if (!(ufid_flags & OVS_UFID_F_OMIT_KEY) ||
+	    !flow->index_by_ufid) {
+		nla = nla_nest_start(skb, OVS_FLOW_ATTR_KEY);
+		if (!nla)
+			return -EMSGSIZE;
+
+		if (flow->index_by_ufid)
+			err = ovs_nla_put_flow(&flow->mask->key, &flow->key,
+					       skb, false);
+		else
+			err = ovs_nla_put_flow(&flow->index.unmasked_key,
+					       &flow->index.unmasked_key, skb,
+					       false);
+		if (err)
+			return err;
+		nla_nest_end(skb, nla);
+	}
 
 	/* Fill flow mask. */
-	nla = nla_nest_start(skb, OVS_FLOW_ATTR_MASK);
-	if (!nla)
-		return -EMSGSIZE;
+	if (!(ufid_flags & OVS_UFID_F_OMIT_MASK)) {
+		nla = nla_nest_start(skb, OVS_FLOW_ATTR_MASK);
+		if (!nla)
+			return -EMSGSIZE;
 
-	err = ovs_nla_put_flow(&flow->key, &flow->mask->key, skb, true);
-	if (err)
-		return err;
+		err = ovs_nla_put_flow(&flow->key, &flow->mask->key, skb, true);
+		if (err)
+			return err;
+		nla_nest_end(skb, nla);
+	}
 
-	nla_nest_end(skb, nla);
 	return 0;
 }
 
@@ -740,6 +757,32 @@ static int ovs_flow_cmd_fill_stats(const struct sw_flow *flow,
 }
 
 /* Called with ovs_mutex or RCU read lock. */
+static int ovs_flow_cmd_fill_ufid(const struct sw_flow *flow,
+				  struct sk_buff *skb)
+{
+	struct nlattr *start;
+	const struct sw_flow_id *sfid;
+
+	if (!flow->index_by_ufid)
+		return 0;
+
+	sfid = &flow->index.ufid;
+	start = nla_nest_start(skb, OVS_FLOW_ATTR_UFID);
+	if (start) {
+		int err;
+
+		err = nla_put(skb, OVS_UFID_ATTR_ID, sfid->ufid_len,
+			      sfid->ufid);
+		if (err)
+			return err;
+		nla_nest_end(skb, start);
+	} else
+		return -EMSGSIZE;
+
+	return 0;
+}
+
+/* Called with ovs_mutex or RCU read lock. */
 static int ovs_flow_cmd_fill_actions(const struct sw_flow *flow,
 				     struct sk_buff *skb, int skb_orig_len)
 {
@@ -782,7 +825,7 @@ static int ovs_flow_cmd_fill_actions(const struct sw_flow *flow,
 /* Called with ovs_mutex or RCU read lock. */
 static int ovs_flow_cmd_fill_info(const struct sw_flow *flow, int dp_ifindex,
 				  struct sk_buff *skb, u32 portid,
-				  u32 seq, u32 flags, u8 cmd)
+				  u32 seq, u32 flags, u8 cmd, u32 ufid_flags)
 {
 	const int skb_orig_len = skb->len;
 	struct ovs_header *ovs_header;
@@ -795,18 +838,24 @@ static int ovs_flow_cmd_fill_info(const struct sw_flow *flow, int dp_ifindex,
 
 	ovs_header->dp_ifindex = dp_ifindex;
 
-	err = ovs_flow_cmd_fill_match(flow, skb);
+	err = ovs_flow_cmd_fill_match(flow, skb, ufid_flags);
 	if (err)
 		goto error;
 
-	err = ovs_flow_cmd_fill_stats(flow, skb);
+	err = ovs_flow_cmd_fill_ufid(flow, skb);
 	if (err)
 		goto error;
 
-	err = ovs_flow_cmd_fill_actions(flow, skb, skb_orig_len);
+	err = ovs_flow_cmd_fill_stats(flow, skb);
 	if (err)
 		goto error;
 
+	if (!(ufid_flags & OVS_UFID_F_OMIT_ACTIONS)) {
+		err = ovs_flow_cmd_fill_actions(flow, skb, skb_orig_len);
+		if (err)
+			goto error;
+	}
+
 	return genlmsg_end(skb, ovs_header);
 
 error:
@@ -816,6 +865,7 @@ error:
 
 /* May not be called with RCU read lock. */
 static struct sk_buff *ovs_flow_cmd_alloc_info(const struct sw_flow_actions *acts,
+					       const struct sw_flow_id *sfid,
 					       struct genl_info *info,
 					       bool always)
 {
@@ -825,30 +875,36 @@ static struct sk_buff *ovs_flow_cmd_alloc_info(const struct sw_flow_actions *act
 					GROUP_ID(&ovs_dp_flow_multicast_group)))
 		return NULL;
 
-	skb = genlmsg_new_unicast(ovs_flow_cmd_msg_size(acts), info, GFP_KERNEL);
+	skb = genlmsg_new_unicast(ovs_flow_cmd_msg_size(acts, sfid), info,
+				  GFP_KERNEL);
 	if (!skb)
 		return ERR_PTR(-ENOMEM);
 
 	return skb;
 }
 
+static const struct sw_flow_id *flow_get_ufid(const struct sw_flow *flow)
+{
+	return flow->index_by_ufid ? &flow->index.ufid : NULL;
+}
+
 /* Called with ovs_mutex. */
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
+				      flow_get_ufid(flow), info, always);
 	if (IS_ERR_OR_NULL(skb))
 		return skb;
 
 	retval = ovs_flow_cmd_fill_info(flow, dp_ifindex, skb,
 					info->snd_portid, info->snd_seq, 0,
-					cmd);
+					cmd, ufid_flags);
 	BUG_ON(retval < 0);
 	return skb;
 }
@@ -863,6 +919,8 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	struct datapath *dp;
 	struct sw_flow_actions *acts;
 	struct sw_flow_match match;
+	struct sw_flow_id sfid;
+	u32 ufid_flags;
 	int error;
 	bool log = !a[OVS_FLOW_ATTR_PROBE];
 
@@ -887,13 +945,20 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	}
 
 	/* Extract key. */
-	ovs_match_init(&match, &new_flow->unmasked_key, &mask);
+	ovs_match_init(&match, &new_flow->index.unmasked_key, &mask);
 	error = ovs_nla_get_match(&match, a[OVS_FLOW_ATTR_KEY],
 				  a[OVS_FLOW_ATTR_MASK], log);
 	if (error)
 		goto err_kfree_flow;
 
-	ovs_flow_mask_key(&new_flow->key, &new_flow->unmasked_key, &mask);
+	ovs_flow_mask_key(&new_flow->key, &new_flow->index.unmasked_key, &mask);
+
+	/* Extract ufid. */
+	error = ovs_nla_get_ufid(a[OVS_FLOW_ATTR_UFID], &sfid, &ufid_flags);
+	if (!error)
+		error = ovs_flow_ufid(new_flow, &sfid);
+	if (error)
+		goto err_kfree_flow;
 
 	/* Validate actions. */
 	error = ovs_nla_copy_actions(a[OVS_FLOW_ATTR_ACTIONS], &new_flow->key,
@@ -903,7 +968,7 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 		goto err_kfree_flow;
 	}
 
-	reply = ovs_flow_cmd_alloc_info(acts, info, false);
+	reply = ovs_flow_cmd_alloc_info(acts, &sfid, info, false);
 	if (IS_ERR(reply)) {
 		error = PTR_ERR(reply);
 		goto err_kfree_acts;
@@ -915,8 +980,9 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 		error = -ENODEV;
 		goto err_unlock_ovs;
 	}
+
 	/* Check if this is a duplicate flow */
-	flow = ovs_flow_tbl_lookup(&dp->table, &new_flow->unmasked_key);
+	flow = ovs_flow_tbl_lookup(&dp->table, &new_flow->key);
 	if (likely(!flow)) {
 		rcu_assign_pointer(new_flow->sf_acts, acts);
 
@@ -932,7 +998,8 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 						       ovs_header->dp_ifindex,
 						       reply, info->snd_portid,
 						       info->snd_seq, 0,
-						       OVS_FLOW_CMD_NEW);
+						       OVS_FLOW_CMD_NEW,
+						       ufid_flags);
 			BUG_ON(error < 0);
 		}
 		ovs_unlock();
@@ -950,14 +1017,16 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 			error = -EEXIST;
 			goto err_unlock_ovs;
 		}
-		/* The unmasked key has to be the same for flow updates. */
-		if (unlikely(!ovs_flow_cmp_unmasked_key(flow, &match))) {
-			/* Look for any overlapping flow. */
+		/* The flow identifier has to be the same for flow updates. */
+		if (sfid.ufid_len) {
+			if (unlikely(!ovs_flow_cmp_ufid(flow, &sfid)))
+				flow = NULL;
+		} else if (unlikely(!ovs_flow_cmp_unmasked_key(flow, &match))) {
 			flow = ovs_flow_tbl_lookup_exact(&dp->table, &match);
-			if (!flow) {
-				error = -ENOENT;
-				goto err_unlock_ovs;
-			}
+		}
+		if (unlikely(!flow)) {
+			error = -ENOENT;
+			goto err_unlock_ovs;
 		}
 		/* Update actions. */
 		old_acts = ovsl_dereference(flow->sf_acts);
@@ -968,7 +1037,8 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 						       ovs_header->dp_ifindex,
 						       reply, info->snd_portid,
 						       info->snd_seq, 0,
-						       OVS_FLOW_CMD_NEW);
+						       OVS_FLOW_CMD_NEW,
+						       ufid_flags);
 			BUG_ON(error < 0);
 		}
 		ovs_unlock();
@@ -1018,30 +1088,36 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
 	struct nlattr **a = info->attrs;
 	struct ovs_header *ovs_header = info->userhdr;
 	struct sw_flow_key key;
-	struct sw_flow *flow;
+	struct sw_flow *flow = NULL;
 	struct sw_flow_mask mask;
 	struct sk_buff *reply = NULL;
 	struct datapath *dp;
 	struct sw_flow_actions *old_acts = NULL, *acts = NULL;
 	struct sw_flow_match match;
+	struct sw_flow_id ufid;
+	u32 ufid_flags;
 	int error;
 	bool log = !a[OVS_FLOW_ATTR_PROBE];
 
-	/* Extract key. */
-	error = -EINVAL;
-	if (!a[OVS_FLOW_ATTR_KEY]) {
-		OVS_NLERR(log, "Flow key attribute not present in set flow.");
+	/* Extract ufid/key. */
+	error = ovs_nla_get_ufid(a[OVS_FLOW_ATTR_UFID], &ufid,
+				 &ufid_flags);
+	if (error)
 		goto error;
+	if (a[OVS_FLOW_ATTR_KEY]) {
+		ovs_match_init(&match, &key, &mask);
+		error = ovs_nla_get_match(&match, a[OVS_FLOW_ATTR_KEY],
+					  a[OVS_FLOW_ATTR_MASK], log);
+	} else if (!ufid.ufid_len) {
+		OVS_NLERR(log, "Flow key attribute not present in set flow.\n");
+		error = -EINVAL;
 	}
-
-	ovs_match_init(&match, &key, &mask);
-	error = ovs_nla_get_match(&match, a[OVS_FLOW_ATTR_KEY],
-				  a[OVS_FLOW_ATTR_MASK], log);
 	if (error)
 		goto error;
 
 	/* Validate actions. */
-	if (a[OVS_FLOW_ATTR_ACTIONS]) {
+	if (a[OVS_FLOW_ATTR_ACTIONS] && a[OVS_FLOW_ATTR_KEY] &&
+	    a[OVS_FLOW_ATTR_MASK]) {
 		acts = get_flow_actions(a[OVS_FLOW_ATTR_ACTIONS], &key, &mask,
 					log);
 		if (IS_ERR(acts)) {
@@ -1050,7 +1126,7 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
 		}
 
 		/* Can allocate before locking if have acts. */
-		reply = ovs_flow_cmd_alloc_info(acts, info, false);
+		reply = ovs_flow_cmd_alloc_info(acts, &ufid, info, false);
 		if (IS_ERR(reply)) {
 			error = PTR_ERR(reply);
 			goto err_kfree_acts;
@@ -1064,7 +1140,10 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
 		goto err_unlock_ovs;
 	}
 	/* Check that the flow exists. */
-	flow = ovs_flow_tbl_lookup_exact(&dp->table, &match);
+	if (ufid.ufid_len)
+		flow = ovs_flow_tbl_lookup_ufid(&dp->table, &ufid);
+	else
+		flow = ovs_flow_tbl_lookup_exact(&dp->table, &match);
 	if (unlikely(!flow)) {
 		error = -ENOENT;
 		goto err_unlock_ovs;
@@ -1080,13 +1159,15 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
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
 		if (unlikely(IS_ERR(reply))) {
 			error = PTR_ERR(reply);
 			goto err_unlock_ovs;
@@ -1123,17 +1204,22 @@ static int ovs_flow_cmd_get(struct sk_buff *skb, struct genl_info *info)
 	struct sw_flow *flow;
 	struct datapath *dp;
 	struct sw_flow_match match;
+	struct sw_flow_id ufid;
+	u32 ufid_flags;
 	int err;
 	bool log = !a[OVS_FLOW_ATTR_PROBE];
 
-	if (!a[OVS_FLOW_ATTR_KEY]) {
+	err = ovs_nla_get_ufid(a[OVS_FLOW_ATTR_UFID], &ufid, &ufid_flags);
+	if (err)
+		return err;
+	if (a[OVS_FLOW_ATTR_KEY]) {
+		ovs_match_init(&match, &key, NULL);
+		err = ovs_nla_get_match(&match, a[OVS_FLOW_ATTR_KEY], NULL, log);
+	} else if (!ufid.ufid_len) {
 		OVS_NLERR(log,
-			  "Flow get message rejected, Key attribute missing.");
-		return -EINVAL;
+			  "Flow get message rejected, Key attribute missing.\n");
+		err = -EINVAL;
 	}
-
-	ovs_match_init(&match, &key, NULL);
-	err = ovs_nla_get_match(&match, a[OVS_FLOW_ATTR_KEY], NULL, log);
 	if (err)
 		return err;
 
@@ -1144,14 +1230,17 @@ static int ovs_flow_cmd_get(struct sk_buff *skb, struct genl_info *info)
 		goto unlock;
 	}
 
-	flow = ovs_flow_tbl_lookup_exact(&dp->table, &match);
+	if (ufid.ufid_len)
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
@@ -1170,13 +1259,18 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	struct ovs_header *ovs_header = info->userhdr;
 	struct sw_flow_key key;
 	struct sk_buff *reply;
-	struct sw_flow *flow;
+	struct sw_flow *flow = NULL;
 	struct datapath *dp;
 	struct sw_flow_match match;
+	struct sw_flow_id ufid;
+	u32 ufid_flags;
 	int err;
 	bool log = !a[OVS_FLOW_ATTR_PROBE];
 
-	if (likely(a[OVS_FLOW_ATTR_KEY])) {
+	err = ovs_nla_get_ufid(a[OVS_FLOW_ATTR_UFID], &ufid, &ufid_flags);
+	if (err)
+		return err;
+	if (a[OVS_FLOW_ATTR_KEY]) {
 		ovs_match_init(&match, &key, NULL);
 		err = ovs_nla_get_match(&match, a[OVS_FLOW_ATTR_KEY], NULL,
 					log);
@@ -1191,12 +1285,15 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 		goto unlock;
 	}
 
-	if (unlikely(!a[OVS_FLOW_ATTR_KEY])) {
+	if (unlikely(!a[OVS_FLOW_ATTR_KEY] && !ufid.ufid_len)) {
 		err = ovs_flow_tbl_flush(&dp->table);
 		goto unlock;
 	}
 
-	flow = ovs_flow_tbl_lookup_exact(&dp->table, &match);
+	if (ufid.ufid_len)
+		flow = ovs_flow_tbl_lookup_ufid(&dp->table, &ufid);
+	else
+		flow = ovs_flow_tbl_lookup_exact(&dp->table, &match);
 	if (unlikely(!flow)) {
 		err = -ENOENT;
 		goto unlock;
@@ -1206,7 +1303,7 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	ovs_unlock();
 
 	reply = ovs_flow_cmd_alloc_info(rcu_dereference_raw(flow->sf_acts),
-					info, false);
+					flow_get_ufid(flow), info, false);
 
 	if (likely(reply)) {
 		if (likely(!IS_ERR(reply))) {
@@ -1214,7 +1311,8 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 			err = ovs_flow_cmd_fill_info(flow, ovs_header->dp_ifindex,
 						     reply, info->snd_portid,
 						     info->snd_seq, 0,
-						     OVS_FLOW_CMD_DEL);
+						     OVS_FLOW_CMD_DEL,
+						     ufid_flags);
 			rcu_read_unlock();
 			BUG_ON(err < 0);
 			ovs_notify(&dp_flow_genl_family, &ovs_dp_flow_multicast_group, reply, info);
@@ -1235,8 +1333,15 @@ unlock:
 static int ovs_flow_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct ovs_header *ovs_header = genlmsg_data(nlmsg_data(cb->nlh));
+	struct nlattr *nla, *ufid;
 	struct table_instance *ti;
 	struct datapath *dp;
+	u32 ufid_flags = 0;
+
+	nla = nlmsg_attrdata(cb->nlh, sizeof(*ovs_header));
+	ufid = nla_find_nested(nla, OVS_FLOW_ATTR_UFID);
+	if (ufid && ovs_nla_get_ufid(ufid, NULL, &ufid_flags))
+		OVS_NLERR(true, "Error occurred parsing UFID flags on dump");
 
 	rcu_read_lock();
 	dp = get_dp_rcu(sock_net(skb->sk), ovs_header->dp_ifindex);
@@ -1259,7 +1364,7 @@ static int ovs_flow_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
 		if (ovs_flow_cmd_fill_info(flow, ovs_header->dp_ifindex, skb,
 					   NETLINK_CB(cb->skb).portid,
 					   cb->nlh->nlmsg_seq, NLM_F_MULTI,
-					   OVS_FLOW_CMD_NEW) < 0)
+					   OVS_FLOW_CMD_NEW, ufid_flags) < 0)
 			break;
 
 		cb->args[0] = bucket;
@@ -1275,6 +1380,7 @@ static const struct nla_policy flow_policy[OVS_FLOW_ATTR_MAX + 1] = {
 	[OVS_FLOW_ATTR_ACTIONS] = { .type = NLA_NESTED },
 	[OVS_FLOW_ATTR_CLEAR] = { .type = NLA_FLAG },
 	[OVS_FLOW_ATTR_PROBE] = { .type = NLA_FLAG },
+	[OVS_FLOW_ATTR_UFID] = { .type = NLA_NESTED },
 };
 
 static struct genl_ops dp_flow_genl_ops[] = {
diff --git a/datapath/flow.h b/datapath/flow.h
index 2bbf789..736e0eb 100644
--- a/datapath/flow.h
+++ b/datapath/flow.h
@@ -196,6 +196,13 @@ struct sw_flow_match {
 	struct sw_flow_mask *mask;
 };
 
+struct sw_flow_id {
+	struct hlist_node node[2];
+	u32 hash;
+	u8 *ufid;
+	u8 ufid_len;
+};
+
 struct sw_flow_actions {
 	struct rcu_head rcu;
 	u32 actions_len;
@@ -212,13 +219,20 @@ struct flow_stats {
 
 struct sw_flow {
 	struct rcu_head rcu;
-	struct hlist_node hash_node[2];
-	u32 hash;
+	struct {
+		struct hlist_node node[2];
+		u32 hash;
+	} flow_hash;
 	int stats_last_writer;		/* NUMA-node id of the last writer on
 					 * 'stats[0]'.
 					 */
 	struct sw_flow_key key;
-	struct sw_flow_key unmasked_key;
+	bool index_by_ufid;		/* Which of the below that userspace
+					   uses to index this flow. */
+	union {
+		struct sw_flow_key unmasked_key;
+		struct sw_flow_id ufid;
+	} index;
 	struct sw_flow_mask *mask;
 	struct sw_flow_actions __rcu *sf_acts;
 	struct flow_stats __rcu *stats[]; /* One for each NUMA node.  First one
diff --git a/datapath/flow_netlink.c b/datapath/flow_netlink.c
index c1c29f5..7927462 100644
--- a/datapath/flow_netlink.c
+++ b/datapath/flow_netlink.c
@@ -1094,6 +1094,41 @@ free_newmask:
 	return err;
 }
 
+int ovs_nla_get_ufid(const struct nlattr *attr, struct sw_flow_id *sfid,
+		     u32 *flags)
+{
+	static const struct nla_policy ovs_ufid_policy[OVS_UFID_ATTR_MAX + 1] = {
+		[OVS_UFID_ATTR_FLAGS] = { .type = NLA_U32 },
+		[OVS_UFID_ATTR_ID] = { .len = sizeof(u32) },
+	};
+	const struct nlattr *a[OVS_UFID_ATTR_MAX + 1];
+	int err;
+
+	if (sfid) {
+		sfid->ufid = NULL;
+		sfid->ufid_len = 0;
+	}
+	if (flags)
+		*flags = 0;
+	if (!attr)
+		return 0;
+
+	err = nla_parse_nested((struct nlattr **)a, OVS_UFID_ATTR_MAX, attr,
+			       ovs_ufid_policy);
+	if (err)
+		return err;
+
+	if (sfid && a[OVS_UFID_ATTR_ID]) {
+		sfid->ufid = nla_data(a[OVS_UFID_ATTR_ID]);
+		sfid->ufid_len = nla_len(a[OVS_UFID_ATTR_ID]);
+	}
+
+	if (flags && a[OVS_UFID_ATTR_FLAGS])
+		*flags = nla_get_u32(a[OVS_UFID_ATTR_FLAGS]);
+
+	return 0;
+}
+
 /**
  * ovs_nla_get_flow_metadata - parses Netlink attributes into a flow key.
  * @key: Receives extracted in_port, priority, tun_key and skb_mark.
diff --git a/datapath/flow_netlink.h b/datapath/flow_netlink.h
index fde7616..9a14ad9 100644
--- a/datapath/flow_netlink.h
+++ b/datapath/flow_netlink.h
@@ -52,6 +52,7 @@ int ovs_nla_get_match(struct sw_flow_match *, const struct nlattr *key,
 		      const struct nlattr *mask, bool log);
 int ovs_nla_put_egress_tunnel_key(struct sk_buff *,
 				  const struct ovs_tunnel_info *);
+int ovs_nla_get_ufid(const struct nlattr *, struct sw_flow_id *, u32 *flags);
 
 int ovs_nla_copy_actions(const struct nlattr *attr,
 			 const struct sw_flow_key *key,
diff --git a/datapath/flow_table.c b/datapath/flow_table.c
index ad410fd..03e7040 100644
--- a/datapath/flow_table.c
+++ b/datapath/flow_table.c
@@ -92,6 +92,7 @@ struct sw_flow *ovs_flow_alloc(void)
 
 	flow->sf_acts = NULL;
 	flow->mask = NULL;
+	flow->index_by_ufid = false;
 	flow->stats_last_writer = NUMA_NO_NODE;
 
 	/* Initialize the default stat node. */
@@ -146,6 +147,8 @@ static void flow_free(struct sw_flow *flow)
 {
 	int node;
 
+	if (flow->index_by_ufid)
+		kfree(flow->index.ufid.ufid);
 	kfree(rcu_dereference_raw(flow->sf_acts));
 	for_each_node(node)
 		if (flow->stats[node])
@@ -265,7 +268,7 @@ static int tbl_mask_array_realloc(struct flow_table *tbl, int size)
 
 int ovs_flow_tbl_init(struct flow_table *table)
 {
-	struct table_instance *ti;
+	struct table_instance *ti, *ufid_ti;
 	struct mask_array *ma;
 
 	table->mask_cache = __alloc_percpu(sizeof(struct mask_cache_entry) *
@@ -277,16 +280,24 @@ int ovs_flow_tbl_init(struct flow_table *table)
 	if (!ma)
 		goto free_mask_cache;
 
+	ufid_ti = table_instance_alloc(TBL_MIN_BUCKETS);
+	if (!ufid_ti)
+		goto free_mask_array;
+
 	ti = table_instance_alloc(TBL_MIN_BUCKETS);
 	if (!ti)
-		goto free_mask_array;
+		goto free_ti;
 
 	rcu_assign_pointer(table->ti, ti);
+	rcu_assign_pointer(table->ufid_ti, ufid_ti);
 	rcu_assign_pointer(table->mask_array, ma);
-	table->last_rehash = jiffies;
 	table->count = 0;
+	table->ufid_count = 0;
+	table->last_rehash = jiffies;
 	return 0;
 
+free_ti:
+	__table_instance_destroy(ufid_ti);
 free_mask_array:
 	kfree(ma);
 free_mask_cache:
@@ -301,13 +312,16 @@ static void flow_tbl_destroy_rcu_cb(struct rcu_head *rcu)
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
 
@@ -316,18 +330,24 @@ static void table_instance_destroy(struct table_instance *ti, bool deferred)
 		struct hlist_head *head = flex_array_get(ti->buckets, i);
 		struct hlist_node *n;
 		int ver = ti->node_ver;
+		int ufid_ver = ufid_ti->node_ver;
 
-		hlist_for_each_entry_safe(flow, n, head, hash_node[ver]) {
-			hlist_del_rcu(&flow->hash_node[ver]);
+		hlist_for_each_entry_safe(flow, n, head, flow_hash.node[ver]) {
+			hlist_del_rcu(&flow->flow_hash.node[ver]);
+			if (flow->index_by_ufid)
+				hlist_del_rcu(&flow->index.ufid.node[ufid_ver]);
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
@@ -336,10 +356,11 @@ skip_flows:
 void ovs_flow_tbl_destroy(struct flow_table *table)
 {
 	struct table_instance *ti = rcu_dereference_raw(table->ti);
+	struct table_instance *ufid_ti = rcu_dereference_raw(table->ufid_ti);
 
 	free_percpu(table->mask_cache);
-	kfree(rcu_dereference_raw(table->mask_array));
-	table_instance_destroy(ti, false);
+	kfree((struct mask_array __force *)table->mask_array);
+	table_instance_destroy(ti, ufid_ti, false);
 }
 
 struct sw_flow *ovs_flow_tbl_dump_next(struct table_instance *ti,
@@ -354,7 +375,7 @@ struct sw_flow *ovs_flow_tbl_dump_next(struct table_instance *ti,
 	while (*bucket < ti->n_buckets) {
 		i = 0;
 		head = flex_array_get(ti->buckets, *bucket);
-		hlist_for_each_entry_rcu(flow, head, hash_node[ver]) {
+		hlist_for_each_entry_rcu(flow, head, flow_hash.node[ver]) {
 			if (i < *last) {
 				i++;
 				continue;
@@ -380,12 +401,21 @@ static void table_instance_insert(struct table_instance *ti, struct sw_flow *flo
 {
 	struct hlist_head *head;
 
-	head = find_bucket(ti, flow->hash);
-	hlist_add_head_rcu(&flow->hash_node[ti->node_ver], head);
+	head = find_bucket(ti, flow->flow_hash.hash);
+	hlist_add_head_rcu(&flow->flow_hash.node[ti->node_ver], head);
+}
+
+static void ufid_table_instance_insert(struct table_instance *ti,
+				       struct sw_flow *flow)
+{
+	struct hlist_head *head;
+
+	head = find_bucket(ti, flow->index.ufid.hash);
+	hlist_add_head_rcu(&flow->index.ufid.node[ti->node_ver], head);
 }
 
 static void flow_table_copy_flows(struct table_instance *old,
-				  struct table_instance *new)
+				  struct table_instance *new, bool ufid)
 {
 	int old_ver;
 	int i;
@@ -400,42 +430,69 @@ static void flow_table_copy_flows(struct table_instance *old,
 
 		head = flex_array_get(old->buckets, i);
 
-		hlist_for_each_entry(flow, head, hash_node[old_ver])
-			table_instance_insert(new, flow);
+		if (ufid)
+			hlist_for_each_entry(flow, head,
+					     index.ufid.node[old_ver])
+				ufid_table_instance_insert(new, flow);
+		else
+			hlist_for_each_entry(flow, head, flow_hash.node[old_ver])
+				table_instance_insert(new, flow);
 	}
 
 	old->keep_flows = true;
 }
 
-static struct table_instance *table_instance_rehash(struct table_instance *ti,
-					    int n_buckets)
+static int flow_table_instance_alloc(struct table_instance **ti,
+				     int n_buckets)
 {
 	struct table_instance *new_ti;
 
 	new_ti = table_instance_alloc(n_buckets);
 	if (!new_ti)
-		return NULL;
+		return -ENOMEM;
 
-	flow_table_copy_flows(ti, new_ti);
+	*ti = new_ti;
+	return 0;
+}
+
+static struct table_instance *flow_table_rehash(struct table_instance *old_ti,
+						int n_buckets, bool ufid)
+{
+	struct table_instance *new_ti;
+	int err;
+
+	err = flow_table_instance_alloc(&new_ti, n_buckets);
+	if (err)
+		return NULL;
+	flow_table_copy_flows(old_ti, new_ti, ufid);
 
 	return new_ti;
 }
 
 int ovs_flow_tbl_flush(struct flow_table *flow_table)
 {
-	struct table_instance *old_ti;
-	struct table_instance *new_ti;
+	struct table_instance *old_ti, *new_ti, *old_ufid_ti;
+	struct table_instance *new_ufid_ti = NULL;
+	int err;
 
 	old_ti = ovsl_dereference(flow_table->ti);
-	new_ti = table_instance_alloc(TBL_MIN_BUCKETS);
-	if (!new_ti)
-		return -ENOMEM;
+	old_ufid_ti = ovsl_dereference(flow_table->ufid_ti);
+	err = flow_table_instance_alloc(&new_ti, TBL_MIN_BUCKETS);
+	if (err)
+		return err;
+	err = flow_table_instance_alloc(&new_ufid_ti, TBL_MIN_BUCKETS);
+	if (err) {
+		__table_instance_destroy(new_ti);
+		return err;
+	}
 
 	rcu_assign_pointer(flow_table->ti, new_ti);
+	rcu_assign_pointer(flow_table->ufid_ti, new_ufid_ti);
 	flow_table->last_rehash = jiffies;
 	flow_table->count = 0;
+	flow_table->ufid_count = 0;
 
-	table_instance_destroy(old_ti, true);
+	table_instance_destroy(old_ti, old_ufid_ti, true);
 	return 0;
 }
 
@@ -489,7 +546,8 @@ bool ovs_flow_cmp_unmasked_key(const struct sw_flow *flow,
 	int key_start = flow_key_start(key);
 	int key_end = match->range.end;
 
-	return cmp_key(&flow->unmasked_key, key, key_start, key_end);
+	BUG_ON(flow->index_by_ufid);
+	return cmp_key(&flow->index.unmasked_key, key, key_start, key_end);
 }
 
 static struct sw_flow *masked_flow_lookup(struct table_instance *ti,
@@ -508,10 +566,9 @@ static struct sw_flow *masked_flow_lookup(struct table_instance *ti,
 	hash = flow_hash(&masked_key, key_start, key_end);
 	head = find_bucket(ti, hash);
 	(*n_mask_hit)++;
-	hlist_for_each_entry_rcu(flow, head, hash_node[ti->node_ver]) {
-		if (flow->mask == mask && flow->hash == hash &&
-		    flow_cmp_masked_key(flow, &masked_key,
-					  key_start, key_end))
+	hlist_for_each_entry_rcu(flow, head, flow_hash.node[ti->node_ver]) {
+		if (flow->mask == mask && flow->flow_hash.hash == hash &&
+		    flow_cmp_masked_key(flow, &masked_key, key_start, key_end))
 			return flow;
 	}
 	return NULL;
@@ -644,7 +701,40 @@ struct sw_flow *ovs_flow_tbl_lookup_exact(struct flow_table *tbl,
 		if (!mask)
 			continue;
 		flow = masked_flow_lookup(ti, match->key, mask, &n_mask_hit);
-		if (flow && ovs_flow_cmp_unmasked_key(flow, match))
+		if (flow && !flow->index_by_ufid &&
+		    ovs_flow_cmp_unmasked_key(flow, match))
+			return flow;
+	}
+	return NULL;
+}
+
+static u32 ufid_hash(const struct sw_flow_id *sfid)
+{
+	return arch_fast_hash(sfid->ufid, sfid->ufid_len, 0);
+}
+
+bool ovs_flow_cmp_ufid(const struct sw_flow *flow,
+		       const struct sw_flow_id *sfid)
+{
+	if (flow->index.ufid.ufid_len != sfid->ufid_len)
+		return false;
+
+	return !memcmp(flow->index.ufid.ufid, sfid->ufid, sfid->ufid_len);
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
+	hlist_for_each_entry_rcu(flow, head, index.ufid.node[ti->node_ver]) {
+		if (flow->index.ufid.hash == hash &&
+		    ovs_flow_cmp_ufid(flow, ufid))
 			return flow;
 	}
 	return NULL;
@@ -658,9 +748,10 @@ int ovs_flow_tbl_num_masks(const struct flow_table *table)
 	return ma->count;
 }
 
-static struct table_instance *table_instance_expand(struct table_instance *ti)
+static struct table_instance *flow_table_expand(struct table_instance *old_ti,
+						bool ufid)
 {
-	return table_instance_rehash(ti, ti->n_buckets * 2);
+	return flow_table_rehash(old_ti, old_ti->n_buckets * 2, ufid);
 }
 
 static void tbl_mask_array_delete_mask(struct mask_array *ma,
@@ -710,10 +801,15 @@ static void flow_mask_remove(struct flow_table *tbl, struct sw_flow_mask *mask)
 void ovs_flow_tbl_remove(struct flow_table *table, struct sw_flow *flow)
 {
 	struct table_instance *ti = ovsl_dereference(table->ti);
+	struct table_instance *ufid_ti = ovsl_dereference(table->ufid_ti);
 
 	BUG_ON(table->count == 0);
-	hlist_del_rcu(&flow->hash_node[ti->node_ver]);
+	hlist_del_rcu(&flow->flow_hash.node[ti->node_ver]);
 	table->count--;
+	if (flow->index_by_ufid) {
+		hlist_del_rcu(&flow->index.ufid.node[ufid_ti->node_ver]);
+		table->ufid_count--;
+	}
 
 	/* RCU delete the mask. 'flow->mask' is not NULLed, as it should be
 	 * accessible as long as the RCU read lock is held.
@@ -818,31 +914,65 @@ static int flow_mask_insert(struct flow_table *tbl, struct sw_flow *flow,
 int ovs_flow_tbl_insert(struct flow_table *table, struct sw_flow *flow,
 			const struct sw_flow_mask *mask)
 {
-	struct table_instance *new_ti = NULL;
-	struct table_instance *ti;
+	struct table_instance *new_ti = NULL, *new_ufid_ti = NULL;
+	struct table_instance *ti, *ufid_ti = NULL;
 	int err;
 
 	err = flow_mask_insert(table, flow, mask);
 	if (err)
 		return err;
 
-	flow->hash = flow_hash(&flow->key, flow->mask->range.start,
-			flow->mask->range.end);
+	flow->flow_hash.hash = flow_hash(&flow->key, flow->mask->range.start,
+					 flow->mask->range.end);
 	ti = ovsl_dereference(table->ti);
 	table_instance_insert(ti, flow);
 	table->count++;
+	if (flow->index_by_ufid) {
+		flow->index.ufid.hash = ufid_hash(&flow->index.ufid);
+		ufid_ti = ovsl_dereference(table->ufid_ti);
+		ufid_table_instance_insert(ufid_ti, flow);
+		table->ufid_count++;
+	}
 
 	/* Expand table, if necessary, to make room. */
 	if (table->count > ti->n_buckets)
-		new_ti = table_instance_expand(ti);
+		new_ti = flow_table_expand(ti, false);
 	else if (time_after(jiffies, table->last_rehash + REHASH_INTERVAL))
-		new_ti = table_instance_rehash(ti, ti->n_buckets);
+		new_ti = flow_table_rehash(ti, ti->n_buckets, false);
+	if (ufid_ti && table->ufid_count > ufid_ti->n_buckets)
+		new_ufid_ti = flow_table_expand(ufid_ti, true);
 
 	if (new_ti) {
 		rcu_assign_pointer(table->ti, new_ti);
-		table_instance_destroy(ti, true);
+		call_rcu(&ti->rcu, flow_tbl_destroy_rcu_cb);
 		table->last_rehash = jiffies;
 	}
+	if (new_ufid_ti) {
+		rcu_assign_pointer(table->ufid_ti, new_ufid_ti);
+		call_rcu(&ufid_ti->rcu, flow_tbl_destroy_rcu_cb);
+	}
+	return 0;
+}
+
+/* Initializes 'flow->ufid'. */
+int ovs_flow_ufid(struct sw_flow *flow, const struct sw_flow_id *src)
+{
+	if (src->ufid_len) {
+		struct sw_flow_id *dst = &flow->index.ufid;
+
+		/* Use userspace-specified flow-id. */
+		dst->ufid = kmalloc(src->ufid_len, GFP_KERNEL);
+		if (!dst->ufid)
+			return -ENOMEM;
+
+		memcpy(dst->ufid, src->ufid, src->ufid_len);
+		dst->ufid_len = src->ufid_len;
+		flow->index_by_ufid = true;
+	} else {
+		/* Don't index by UFID. */
+		flow->index_by_ufid = false;
+	}
+
 	return 0;
 }
 
diff --git a/datapath/flow_table.h b/datapath/flow_table.h
index 80c01a3..e05b59c 100644
--- a/datapath/flow_table.h
+++ b/datapath/flow_table.h
@@ -60,8 +60,10 @@ struct flow_table {
 	struct table_instance __rcu *ti;
 	struct mask_cache_entry __percpu *mask_cache;
 	struct mask_array __rcu *mask_array;
+	struct table_instance __rcu *ufid_ti;
 	unsigned long last_rehash;
 	unsigned int count;
+	unsigned int ufid_count;
 };
 
 extern struct kmem_cache *flow_stats_cache;
@@ -91,9 +93,15 @@ struct sw_flow *ovs_flow_tbl_lookup(struct flow_table *,
 				    const struct sw_flow_key *);
 struct sw_flow *ovs_flow_tbl_lookup_exact(struct flow_table *tbl,
 					  const struct sw_flow_match *match);
+struct sw_flow *ovs_flow_tbl_lookup_ufid(struct flow_table *,
+					 const struct sw_flow_id *);
+
 bool ovs_flow_cmp_unmasked_key(const struct sw_flow *flow,
 			       const struct sw_flow_match *match);
+bool ovs_flow_cmp_ufid(const struct sw_flow *flow,
+		       const struct sw_flow_id *sfid);
 
 void ovs_flow_mask_key(struct sw_flow_key *dst, const struct sw_flow_key *src,
 		       const struct sw_flow_mask *mask);
+int ovs_flow_ufid(struct sw_flow *flow, const struct sw_flow_id *src);
 #endif /* flow_table.h */
diff --git a/datapath/linux/compat/include/linux/openvswitch.h b/datapath/linux/compat/include/linux/openvswitch.h
index c8fa66e..7d759a4 100644
--- a/datapath/linux/compat/include/linux/openvswitch.h
+++ b/datapath/linux/compat/include/linux/openvswitch.h
@@ -471,6 +471,9 @@ struct ovs_key_nd {
  * a wildcarded match. Omitting attribute is treated as wildcarding all
  * corresponding fields. Optional for all requests. If not present,
  * all flow key bits are exact match bits.
+ * @OVS_FLOW_ATTR_UFID: Nested %OVS_UFID_ATTR_* attributes specifying unique
+ * identifiers for flows and providing alternative semantics for flow
+ * installation and retrieval.
  *
  * These attributes follow the &struct ovs_header within the Generic Netlink
  * payload for %OVS_FLOW_* commands.
@@ -486,12 +489,39 @@ enum ovs_flow_attr {
 	OVS_FLOW_ATTR_MASK,      /* Sequence of OVS_KEY_ATTR_* attributes. */
 	OVS_FLOW_ATTR_PROBE,     /* Flow operation is a feature probe, error
 				  * logging should be suppressed. */
+	OVS_FLOW_ATTR_UFID,      /* Unique flow identifier. */
 	__OVS_FLOW_ATTR_MAX
 };
 
 #define OVS_FLOW_ATTR_MAX (__OVS_FLOW_ATTR_MAX - 1)
 
 /**
+ * enum ovs_ufid_attr - Unique identifier types.
+ *
+ * @OVS_UFID_ATTR_FLAGS: A 32-bit value specifying changes to the behaviour of
+ * the current %OVS_FLOW_CMD_* request. Optional for all requests.
+ * @OVS_UFID_ATTR_ID: A unique identifier for a flow.
+ */
+enum ovs_ufid_attr {
+	OVS_UFID_ATTR_UNSPEC,
+	OVS_UFID_ATTR_FLAGS,     /* u32 of OVS_UFID_F_* */
+	OVS_UFID_ATTR_ID,        /* variable length identifier. */
+	__OVS_UFID_ATTR_MAX
+};
+
+#define OVS_UFID_ATTR_MAX (__OVS_UFID_ATTR_MAX - 1)
+
+/**
+ * Omit attributes for notifications.
+ *
+ * If a datapath request contains an OVS_UFID_F_OMIT_* flag, then the datapath
+ * may omit the corresponding 'ovs_flow_attr' from the response.
+ */
+#define OVS_UFID_F_OMIT_KEY      (1 << 0)
+#define OVS_UFID_F_OMIT_MASK     (1 << 1)
+#define OVS_UFID_F_OMIT_ACTIONS  (1 << 2)
+
+/**
  * enum ovs_sample_attr - Attributes for %OVS_ACTION_ATTR_SAMPLE action.
  * @OVS_SAMPLE_ATTR_PROBABILITY: 32-bit fraction of packets to sample with
  * @OVS_ACTION_ATTR_SAMPLE.  A value of 0 samples no packets, a value of
-- 
1.7.10.4
