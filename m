From: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 08/12] openvswitch: Copy individual
	actions.
Date: Thu, 13 Jun 2013 11:24:54 -0700
Message-ID: <1371147894-9401-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Rather than validating actions and then copying all actiaons
in one block, following patch does same operation in single pass.
This validate and copy action one by one. This is required for
ovs tunneling patch.

This patch does not change any functionality.

Signed-off-by: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/datapath.c |  271 +++++++++++++++++++++++++++++++++++--------
 net/openvswitch/flow.c     |   10 +-
 net/openvswitch/flow.h     |    2 +-
 3 files changed, 225 insertions(+), 58 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 38d221d..ae1e8fe 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -464,16 +464,89 @@ static int flush_flows(struct datapath *dp)
 	return 0;
 }
 
-static int validate_actions(const struct nlattr *attr,
-				const struct sw_flow_key *key, int depth);
+static struct nlattr *reserve_sfa_size(struct sw_flow_actions **sfa, int attr_len)
+{
+
+	struct sw_flow_actions *acts;
+	int new_acts_size;
+	int req_size = NLA_ALIGN(attr_len);
+	int next_offset = offsetof(struct sw_flow_actions, actions) +
+					(*sfa)->actions_len;
+
+	if (req_size <= (ksize(*sfa) - next_offset))
+		goto out;
+
+	new_acts_size = ksize(*sfa) * 2;
+
+	if (new_acts_size > MAX_ACTIONS_BUFSIZE) {
+		if ((MAX_ACTIONS_BUFSIZE - next_offset) < req_size)
+			return ERR_PTR(-EMSGSIZE);
+		new_acts_size = MAX_ACTIONS_BUFSIZE;
+	}
+
+	acts = ovs_flow_actions_alloc(new_acts_size);
+	if (IS_ERR(acts))
+		return (void *)acts;
+
+	memcpy(acts->actions, (*sfa)->actions, (*sfa)->actions_len);
+	acts->actions_len = (*sfa)->actions_len;
+	kfree(*sfa);
+	*sfa = acts;
+
+out:
+	(*sfa)->actions_len += req_size;
+	return  (struct nlattr *) ((unsigned char *)(*sfa) + next_offset);
+}
+
+static int add_action(struct sw_flow_actions **sfa, int attrtype, void *data, int len)
+{
+	struct nlattr *a;
+
+	a = reserve_sfa_size(sfa, nla_attr_size(len));
+	if (IS_ERR(a))
+		return PTR_ERR(a);
+
+	a->nla_type = attrtype;
+	a->nla_len = nla_attr_size(len);
+
+	if (data)
+		memcpy(nla_data(a), data, len);
+	memset((unsigned char *) a + a->nla_len, 0, nla_padlen(len));
+
+	return 0;
+}
+
+static inline int add_nested_action_start(struct sw_flow_actions **sfa, int attrtype)
+{
+	int used = (*sfa)->actions_len;
+	int err;
+
+	err = add_action(sfa, attrtype, NULL, 0);
+	if (err)
+		return err;
+
+	return used;
+}
 
-static int validate_sample(const struct nlattr *attr,
-				const struct sw_flow_key *key, int depth)
+static inline void add_nested_action_end(struct sw_flow_actions *sfa, int st_offset)
+{
+	struct nlattr *a = (struct nlattr *) ((unsigned char *)sfa->actions + st_offset);
+
+	a->nla_len = sfa->actions_len - st_offset;
+}
+
+static int validate_and_copy_actions(const struct nlattr *attr,
+				     const struct sw_flow_key *key, int depth,
+				     struct sw_flow_actions **sfa);
+
+static int validate_and_copy_sample(const struct nlattr *attr,
+				    const struct sw_flow_key *key, int depth,
+				    struct sw_flow_actions **sfa)
 {
 	const struct nlattr *attrs[OVS_SAMPLE_ATTR_MAX + 1];
 	const struct nlattr *probability, *actions;
 	const struct nlattr *a;
-	int rem;
+	int rem, start, err, st_acts;
 
 	memset(attrs, 0, sizeof(attrs));
 	nla_for_each_nested(a, attr, rem) {
@@ -492,7 +565,26 @@ static int validate_sample(const struct nlattr *attr,
 	actions = attrs[OVS_SAMPLE_ATTR_ACTIONS];
 	if (!actions || (nla_len(actions) && nla_len(actions) < NLA_HDRLEN))
 		return -EINVAL;
-	return validate_actions(actions, key, depth + 1);
+
+	/* validation done, copy sample action. */
+	start = add_nested_action_start(sfa, OVS_ACTION_ATTR_SAMPLE);
+	if (start < 0)
+		return start;
+	err = add_action(sfa, OVS_SAMPLE_ATTR_PROBABILITY, nla_data(probability), sizeof(u32));
+	if (err)
+		return err;
+	st_acts = add_nested_action_start(sfa, OVS_SAMPLE_ATTR_ACTIONS);
+	if (st_acts < 0)
+		return st_acts;
+
+	err = validate_and_copy_actions(actions, key, depth + 1, sfa);
+	if (err)
+		return err;
+
+	add_nested_action_end(*sfa, st_acts);
+	add_nested_action_end(*sfa, start);
+
+	return 0;
 }
 
 static int validate_tp_port(const struct sw_flow_key *flow_key)
@@ -606,8 +698,24 @@ static int validate_userspace(const struct nlattr *attr)
 	return 0;
 }
 
-static int validate_actions(const struct nlattr *attr,
-				const struct sw_flow_key *key,  int depth)
+static int copy_action(const struct nlattr *from,
+		       struct sw_flow_actions **sfa)
+{
+	int totlen = NLA_ALIGN(from->nla_len);
+	struct nlattr *to;
+
+	to = reserve_sfa_size(sfa, from->nla_len);
+	if (IS_ERR(to))
+		return PTR_ERR(to);
+
+	memcpy(to, from, totlen);
+	return 0;
+}
+
+static int validate_and_copy_actions(const struct nlattr *attr,
+				     const struct sw_flow_key *key,
+				     int depth,
+				     struct sw_flow_actions **sfa)
 {
 	const struct nlattr *a;
 	int rem, err;
@@ -627,12 +735,14 @@ static int validate_actions(const struct nlattr *attr,
 		};
 		const struct ovs_action_push_vlan *vlan;
 		int type = nla_type(a);
+		bool skip_copy;
 
 		if (type > OVS_ACTION_ATTR_MAX ||
 		    (action_lens[type] != nla_len(a) &&
 		     action_lens[type] != (u32)-1))
 			return -EINVAL;
 
+		skip_copy = false;
 		switch (type) {
 		case OVS_ACTION_ATTR_UNSPEC:
 			return -EINVAL;
@@ -667,14 +777,20 @@ static int validate_actions(const struct nlattr *attr,
 			break;
 
 		case OVS_ACTION_ATTR_SAMPLE:
-			err = validate_sample(a, key, depth);
+			err = validate_and_copy_sample(a, key, depth, sfa);
 			if (err)
 				return err;
+			skip_copy = true;
 			break;
 
 		default:
 			return -EINVAL;
 		}
+		if (!skip_copy) {
+			err = copy_action(a, sfa);
+			if (err)
+				return err;
+		}
 	}
 
 	if (rem > 0)
@@ -742,18 +858,16 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	err = ovs_flow_metadata_from_nlattrs(flow, a[OVS_PACKET_ATTR_KEY]);
 	if (err)
 		goto err_flow_free;
-
-	err = validate_actions(a[OVS_PACKET_ATTR_ACTIONS], &flow->key, 0);
-	if (err)
-		goto err_flow_free;
-
 	flow->hash = ovs_flow_hash(&flow->key, key_len);
-
-	acts = ovs_flow_actions_alloc(a[OVS_PACKET_ATTR_ACTIONS]);
+	acts = ovs_flow_actions_alloc(nla_len(a[OVS_PACKET_ATTR_ACTIONS]));
 	err = PTR_ERR(acts);
 	if (IS_ERR(acts))
 		goto err_flow_free;
+
+	err = validate_and_copy_actions(a[OVS_PACKET_ATTR_ACTIONS], &flow->key, 0, &acts);
 	rcu_assign_pointer(flow->sf_acts, acts);
+	if (err)
+		goto err_flow_free;
 
 	OVS_CB(packet)->flow = flow;
 	packet->priority = flow->key.phy.priority;
@@ -843,6 +957,66 @@ static struct genl_multicast_group ovs_dp_flow_multicast_group = {
 	.name = OVS_FLOW_MCGROUP
 };
 
+static int actions_to_attr(const struct nlattr *attr, int len, struct sk_buff *skb);
+static int sample_action_to_attr(const struct nlattr *attr, struct sk_buff *skb)
+{
+	const struct nlattr *a;
+	struct nlattr *start;
+	int err = 0, rem;
+
+	start = nla_nest_start(skb, OVS_ACTION_ATTR_SAMPLE);
+	if (!start)
+		return -EMSGSIZE;
+
+	nla_for_each_nested(a, attr, rem) {
+		int type = nla_type(a);
+		struct nlattr *st_sample;
+
+		switch (type) {
+		case OVS_SAMPLE_ATTR_PROBABILITY:
+			if (nla_put(skb, OVS_SAMPLE_ATTR_PROBABILITY, sizeof(u32), nla_data(a)))
+				return -EMSGSIZE;
+			break;
+		case OVS_SAMPLE_ATTR_ACTIONS:
+			st_sample = nla_nest_start(skb, OVS_SAMPLE_ATTR_ACTIONS);
+			if (!st_sample)
+				return -EMSGSIZE;
+			err = actions_to_attr(nla_data(a), nla_len(a), skb);
+			if (err)
+				return err;
+			nla_nest_end(skb, st_sample);
+			break;
+		}
+	}
+
+	nla_nest_end(skb, start);
+	return err;
+}
+
+static int actions_to_attr(const struct nlattr *attr, int len, struct sk_buff *skb)
+{
+	const struct nlattr *a;
+	int rem, err;
+
+	nla_for_each_attr(a, attr, len, rem) {
+		int type = nla_type(a);
+
+		switch (type) {
+		case OVS_ACTION_ATTR_SAMPLE:
+			err = sample_action_to_attr(a, skb);
+			if (err)
+				return err;
+			break;
+		default:
+			if (nla_put(skb, type, nla_len(a), nla_data(a)))
+				return -EMSGSIZE;
+			break;
+		}
+	}
+
+	return 0;
+}
+
 static size_t ovs_flow_cmd_msg_size(const struct sw_flow_actions *acts)
 {
 	return NLMSG_ALIGN(sizeof(struct ovs_header))
@@ -860,6 +1034,7 @@ static int ovs_flow_cmd_fill_info(struct sw_flow *flow, struct datapath *dp,
 {
 	const int skb_orig_len = skb->len;
 	const struct sw_flow_actions *sf_acts;
+	struct nlattr *start;
 	struct ovs_flow_stats stats;
 	struct ovs_header *ovs_header;
 	struct nlattr *nla;
@@ -913,10 +1088,19 @@ static int ovs_flow_cmd_fill_info(struct sw_flow *flow, struct datapath *dp,
 	 * This can only fail for dump operations because the skb is always
 	 * properly sized for single flows.
 	 */
-	err = nla_put(skb, OVS_FLOW_ATTR_ACTIONS, sf_acts->actions_len,
-		      sf_acts->actions);
-	if (err < 0 && skb_orig_len)
-		goto error;
+	start = nla_nest_start(skb, OVS_FLOW_ATTR_ACTIONS);
+	if (start) {
+		err = actions_to_attr(sf_acts->actions, sf_acts->actions_len, skb);
+		if (!err)
+			nla_nest_end(skb, start);
+		else {
+			if (skb_orig_len)
+				goto error;
+
+			nla_nest_cancel(skb, start);
+		}
+	} else if (skb_orig_len)
+		goto nla_put_failure;
 
 	return genlmsg_end(skb, ovs_header);
 
@@ -961,6 +1145,7 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 	struct sk_buff *reply;
 	struct datapath *dp;
 	struct flow_table *table;
+	struct sw_flow_actions *acts = NULL;
 	int error;
 	int key_len;
 
@@ -974,9 +1159,14 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 
 	/* Validate actions. */
 	if (a[OVS_FLOW_ATTR_ACTIONS]) {
-		error = validate_actions(a[OVS_FLOW_ATTR_ACTIONS], &key,  0);
-		if (error)
+		acts = ovs_flow_actions_alloc(nla_len(a[OVS_FLOW_ATTR_ACTIONS]));
+		error = PTR_ERR(acts);
+		if (IS_ERR(acts))
 			goto error;
+
+		error = validate_and_copy_actions(a[OVS_FLOW_ATTR_ACTIONS], &key,  0, &acts);
+		if (error)
+			goto err_kfree;
 	} else if (info->genlhdr->cmd == OVS_FLOW_CMD_NEW) {
 		error = -EINVAL;
 		goto error;
@@ -991,8 +1181,6 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 	table = ovsl_dereference(dp->table);
 	flow = ovs_flow_tbl_lookup(table, &key, key_len);
 	if (!flow) {
-		struct sw_flow_actions *acts;
-
 		/* Bail out if we're not allowed to create a new flow. */
 		error = -ENOENT;
 		if (info->genlhdr->cmd == OVS_FLOW_CMD_SET)
@@ -1019,11 +1207,6 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 		flow->key = key;
 		clear_stats(flow);
 
-		/* Obtain actions. */
-		acts = ovs_flow_actions_alloc(a[OVS_FLOW_ATTR_ACTIONS]);
-		error = PTR_ERR(acts);
-		if (IS_ERR(acts))
-			goto error_free_flow;
 		rcu_assign_pointer(flow->sf_acts, acts);
 
 		/* Put flow in bucket. */
@@ -1036,7 +1219,6 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 	} else {
 		/* We found a matching flow. */
 		struct sw_flow_actions *old_acts;
-		struct nlattr *acts_attrs;
 
 		/* Bail out if we're not allowed to modify an existing flow.
 		 * We accept NLM_F_CREATE in place of the intended NLM_F_EXCL
@@ -1051,21 +1233,8 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 
 		/* Update actions. */
 		old_acts = ovsl_dereference(flow->sf_acts);
-		acts_attrs = a[OVS_FLOW_ATTR_ACTIONS];
-		if (acts_attrs &&
-		   (old_acts->actions_len != nla_len(acts_attrs) ||
-		   memcmp(old_acts->actions, nla_data(acts_attrs),
-			  old_acts->actions_len))) {
-			struct sw_flow_actions *new_acts;
-
-			new_acts = ovs_flow_actions_alloc(acts_attrs);
-			error = PTR_ERR(new_acts);
-			if (IS_ERR(new_acts))
-				goto err_unlock_ovs;
-
-			rcu_assign_pointer(flow->sf_acts, new_acts);
-			ovs_flow_deferred_free_acts(old_acts);
-		}
+		rcu_assign_pointer(flow->sf_acts, acts);
+		ovs_flow_deferred_free_acts(old_acts);
 
 		reply = ovs_flow_cmd_build_info(flow, dp, info->snd_portid,
 					       info->snd_seq, OVS_FLOW_CMD_NEW);
@@ -1086,10 +1255,10 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 				ovs_dp_flow_multicast_group.id, PTR_ERR(reply));
 	return 0;
 
-error_free_flow:
-	ovs_flow_free(flow);
 err_unlock_ovs:
 	ovs_unlock();
+err_kfree:
+	kfree(acts);
 error:
 	return error;
 }
@@ -1864,8 +2033,8 @@ static int ovs_vport_cmd_del(struct sk_buff *skb, struct genl_info *info)
 		goto exit_unlock;
 	}
 
-	reply = ovs_vport_cmd_build_info(vport, info->snd_portid, info->snd_seq,
-					 OVS_VPORT_CMD_DEL);
+	reply = ovs_vport_cmd_build_info(vport, info->snd_portid,
+					 info->snd_seq, OVS_VPORT_CMD_DEL);
 	err = PTR_ERR(reply);
 	if (IS_ERR(reply))
 		goto exit_unlock;
@@ -1894,8 +2063,8 @@ static int ovs_vport_cmd_get(struct sk_buff *skb, struct genl_info *info)
 	if (IS_ERR(vport))
 		goto exit_unlock;
 
-	reply = ovs_vport_cmd_build_info(vport, info->snd_portid, info->snd_seq,
-					 OVS_VPORT_CMD_NEW);
+	reply = ovs_vport_cmd_build_info(vport, info->snd_portid,
+					 info->snd_seq, OVS_VPORT_CMD_NEW);
 	err = PTR_ERR(reply);
 	if (IS_ERR(reply))
 		goto exit_unlock;
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index fab4ba6..fba57a0 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -198,20 +198,18 @@ void ovs_flow_used(struct sw_flow *flow, struct sk_buff *skb)
 	spin_unlock(&flow->lock);
 }
 
-struct sw_flow_actions *ovs_flow_actions_alloc(const struct nlattr *actions)
+struct sw_flow_actions *ovs_flow_actions_alloc(int size)
 {
-	int actions_len = nla_len(actions);
 	struct sw_flow_actions *sfa;
 
-	if (actions_len > MAX_ACTIONS_BUFSIZE)
+	if (size > MAX_ACTIONS_BUFSIZE)
 		return ERR_PTR(-EINVAL);
 
-	sfa = kmalloc(sizeof(*sfa) + actions_len, GFP_KERNEL);
+	sfa = kmalloc(sizeof(*sfa) + size, GFP_KERNEL);
 	if (!sfa)
 		return ERR_PTR(-ENOMEM);
 
-	sfa->actions_len = actions_len;
-	nla_memcpy(sfa->actions, actions, actions_len);
+	sfa->actions_len = 0;
 	return sfa;
 }
 
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 2a83e21..e370f62 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -130,7 +130,7 @@ struct sw_flow *ovs_flow_alloc(void);
 void ovs_flow_deferred_free(struct sw_flow *);
 void ovs_flow_free(struct sw_flow *flow);
 
-struct sw_flow_actions *ovs_flow_actions_alloc(const struct nlattr *);
+struct sw_flow_actions *ovs_flow_actions_alloc(int actions_len);
 void ovs_flow_deferred_free_acts(struct sw_flow_actions *);
 
 int ovs_flow_extract(struct sk_buff *, u16 in_port, struct sw_flow_key *,
-- 
1.7.1
