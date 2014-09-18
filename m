From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC repost 6/8] datapath: validation of select group action
Date: Thu, 18 Sep 2014 10:55:09 +0900
Message-ID: <1411005311-11752-7-git-send-email-simon.horman@netronome.com>
References: <1411005311-11752-1-git-send-email-simon.horman@netronome.com>
Cc: Pravin Shelar <pshelar@nicira.com>, Jesse Gross <jesse@nicira.com>,
	Thomas Graf <tgraf@suug.ch>,
	Simon Horman <simon.horman@netronome.com>
To: dev@openvswitch.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:47121 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757052AbaIRB5y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 21:57:54 -0400
Received: by mail-pd0-f177.google.com with SMTP id r10so321296pdi.36
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 18:57:53 -0700 (PDT)
In-Reply-To: <1411005311-11752-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow validation and copying of select group actions.
This completes the prototype select group action implementation
in the datapath. Subsequent patches will add support to ovs-vswtichd.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 datapath/flow_netlink.c | 102 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 102 insertions(+)

diff --git a/datapath/flow_netlink.c b/datapath/flow_netlink.c
index 6c74841..90eddba 100644
--- a/datapath/flow_netlink.c
+++ b/datapath/flow_netlink.c
@@ -1497,6 +1497,94 @@ static int validate_and_copy_sample(const struct nlattr *attr,
 	return 0;
 }
 
+static int validate_and_copy_bucket(const struct nlattr *attr,
+				    const struct sw_flow_key *key, int depth,
+				    struct sw_flow_actions **sfa,
+				    __be16 eth_type, __be16 vlan_tci)
+{
+	const struct nlattr *attrs[OVS_BUCKET_ATTR_MAX + 1];
+	const struct nlattr *weight, *actions;
+	const struct nlattr *a;
+	int rem, start, err, st_acts;
+
+	memset(attrs, 0, sizeof(attrs));
+	nla_for_each_nested(a, attr, rem) {
+		int type = nla_type(a);
+		if (!type || type > OVS_BUCKET_ATTR_MAX || attrs[type])
+			return -EINVAL;
+		attrs[type] = a;
+	}
+	if (rem)
+		return -EINVAL;
+
+	weight = attrs[OVS_BUCKET_ATTR_WEIGHT];
+	if (!weight || nla_len(weight) != sizeof(u16))
+		return -EINVAL;
+
+	actions = attrs[OVS_BUCKET_ATTR_ACTIONS];
+	if (!actions || (nla_len(actions) && nla_len(actions) < NLA_HDRLEN))
+		return -EINVAL;
+
+	/* validation done, copy sample action. */
+	start = add_nested_action_start(sfa, OVS_SELECT_GROUP_ATTR_BUCKET);
+	if (start < 0)
+		return start;
+	err = add_action(sfa, OVS_BUCKET_ATTR_WEIGHT,
+			 nla_data(weight), sizeof(u16));
+	if (err)
+		return err;
+	st_acts = add_nested_action_start(sfa, OVS_SAMPLE_ATTR_ACTIONS);
+	if (st_acts < 0)
+		return st_acts;
+
+	err = __ovs_nla_copy_actions(actions, key, depth + 1, sfa,
+				     eth_type, vlan_tci);
+	if (err)
+		return err;
+
+	add_nested_action_end(*sfa, st_acts);
+	add_nested_action_end(*sfa, start);
+
+	return 0;
+}
+
+static int validate_and_copy_select_group(const struct nlattr *attr,
+					  const struct sw_flow_key *key,
+					  int depth,
+					  struct sw_flow_actions **sfa,
+					  __be16 eth_type, __be16 vlan_tci)
+{
+	bool have_bucket = false;
+	const struct nlattr *a;
+	int rem, start, err;
+
+	start = add_nested_action_start(sfa, OVS_ACTION_ATTR_SELECT_GROUP);
+	if (start < 0)
+		return start;
+
+	nla_for_each_nested(a, attr, rem) {
+		int type = nla_type(a);
+
+		if (!type || type > OVS_SAMPLE_ATTR_MAX)
+			return -EINVAL;
+
+		/* Only possible type is OVS_SELECT_GROUP_ATTR_BUCKET */
+		if ((nla_len(a) && nla_len(a) < NLA_HDRLEN))
+			return -EINVAL;
+		err = validate_and_copy_bucket(a, key, depth, sfa,
+					       eth_type, vlan_tci);
+		if (err < 0)
+			return err;
+		have_bucket = true;
+	}
+	if (rem || !have_bucket)
+		return -EINVAL;
+
+	add_nested_action_end(*sfa, start);
+
+	return 0;
+}
+
 static int validate_tp_port(const struct sw_flow_key *flow_key,
 			    __be16 eth_type)
 {
@@ -1750,6 +1838,7 @@ static int __ovs_nla_copy_actions(const struct nlattr *attr,
 			[OVS_ACTION_ATTR_POP_VLAN] = 0,
 			[OVS_ACTION_ATTR_SET] = (u32)-1,
 			[OVS_ACTION_ATTR_SAMPLE] = (u32)-1,
+			[OVS_ACTION_ATTR_SELECT_GROUP] = (u32)-1,
 			[OVS_ACTION_ATTR_HASH] = sizeof(struct ovs_action_hash)
 		};
 		const struct ovs_action_push_vlan *vlan;
@@ -1856,6 +1945,19 @@ static int __ovs_nla_copy_actions(const struct nlattr *attr,
 			skip_copy = true;
 			break;
 
+		case OVS_ACTION_ATTR_SELECT_GROUP:
+			/* Nothing may come after a select group */
+			if (!last_action(a, rem))
+				return -EINVAL;
+
+			err = validate_and_copy_select_group(a, key, depth,
+							     sfa, eth_type,
+							     vlan_tci);
+			if (err)
+				return err;
+			skip_copy = true;
+			break;
+
 		default:
 			return -EINVAL;
 		}
-- 
2.0.1
