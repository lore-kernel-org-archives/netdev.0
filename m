From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v2 13/14] openvswitch: Refactor action alloc and copy api.
Date: Thu,  6 Nov 2014 01:19:49 -0800
Message-ID: <1415265589-1901-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog114.obsmtp.com ([74.125.149.211]:48107 "HELO
	na3sys009aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752022AbaKFJTv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 04:19:51 -0500
Received: by mail-pa0-f46.google.com with SMTP id lf10so888601pab.19
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2014 01:19:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two separate API to allocate and copy actions list. Anytime
OVS needs to copy action list, it needs to call both functions.
Following patch moves action allocation to copy function to avoid
code duplication.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Acked-by: Jarno Rajahalme <jrajahalme@nicira.com>
---
 net/openvswitch/datapath.c     | 25 ++++---------------------
 net/openvswitch/flow_netlink.c | 24 +++++++++++++++++-------
 net/openvswitch/flow_netlink.h |  1 -
 3 files changed, 21 insertions(+), 29 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 5101780..014485e 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -543,18 +543,12 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	if (err)
 		goto err_flow_free;
 
-	acts = ovs_nla_alloc_flow_actions(nla_len(a[OVS_PACKET_ATTR_ACTIONS]));
-	err = PTR_ERR(acts);
-	if (IS_ERR(acts))
-		goto err_flow_free;
-
 	err = ovs_nla_copy_actions(a[OVS_PACKET_ATTR_ACTIONS],
 				   &flow->key, &acts);
 	if (err)
 		goto err_flow_free;
 
 	rcu_assign_pointer(flow->sf_acts, acts);
-
 	OVS_CB(packet)->egress_tun_info = NULL;
 	packet->priority = flow->key.phy.priority;
 	packet->mark = flow->key.phy.skb_mark;
@@ -872,16 +866,11 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	ovs_flow_mask_key(&new_flow->key, &new_flow->unmasked_key, &mask);
 
 	/* Validate actions. */
-	acts = ovs_nla_alloc_flow_actions(nla_len(a[OVS_FLOW_ATTR_ACTIONS]));
-	error = PTR_ERR(acts);
-	if (IS_ERR(acts))
-		goto err_kfree_flow;
-
 	error = ovs_nla_copy_actions(a[OVS_FLOW_ATTR_ACTIONS], &new_flow->key,
 				     &acts);
 	if (error) {
 		OVS_NLERR("Flow actions may not be safe on all matching packets.\n");
-		goto err_kfree_acts;
+		goto err_kfree_flow;
 	}
 
 	reply = ovs_flow_cmd_alloc_info(acts, info, false);
@@ -972,6 +961,7 @@ error:
 	return error;
 }
 
+/* Factor out action copy to avoid "Wframe-larger-than=1024" warning. */
 static struct sw_flow_actions *get_flow_actions(const struct nlattr *a,
 						const struct sw_flow_key *key,
 						const struct sw_flow_mask *mask)
@@ -980,15 +970,10 @@ static struct sw_flow_actions *get_flow_actions(const struct nlattr *a,
 	struct sw_flow_key masked_key;
 	int error;
 
-	acts = ovs_nla_alloc_flow_actions(nla_len(a));
-	if (IS_ERR(acts))
-		return acts;
-
 	ovs_flow_mask_key(&masked_key, key, mask);
 	error = ovs_nla_copy_actions(a, &masked_key, &acts);
 	if (error) {
-		OVS_NLERR("Flow actions may not be safe on all matching packets.\n");
-		kfree(acts);
+		OVS_NLERR("Actions may not be safe on all matching packets.\n");
 		return ERR_PTR(error);
 	}
 
@@ -1028,10 +1013,8 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
 			error = PTR_ERR(acts);
 			goto error;
 		}
-	}
 
-	/* Can allocate before locking if have acts. */
-	if (acts) {
+		/* Can allocate before locking if have acts. */
 		reply = ovs_flow_cmd_alloc_info(acts, info, false);
 		if (IS_ERR(reply)) {
 			error = PTR_ERR(reply);
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 1050b28..482a0cb 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -1284,7 +1284,7 @@ nla_put_failure:
 
 #define MAX_ACTIONS_BUFSIZE	(32 * 1024)
 
-struct sw_flow_actions *ovs_nla_alloc_flow_actions(int size)
+static struct sw_flow_actions *nla_alloc_flow_actions(int size)
 {
 	struct sw_flow_actions *sfa;
 
@@ -1329,7 +1329,7 @@ static struct nlattr *reserve_sfa_size(struct sw_flow_actions **sfa,
 		new_acts_size = MAX_ACTIONS_BUFSIZE;
 	}
 
-	acts = ovs_nla_alloc_flow_actions(new_acts_size);
+	acts = nla_alloc_flow_actions(new_acts_size);
 	if (IS_ERR(acts))
 		return (void *)acts;
 
@@ -1396,7 +1396,7 @@ static inline void add_nested_action_end(struct sw_flow_actions *sfa,
 	a->nla_len = sfa->actions_len - st_offset;
 }
 
-static int ovs_nla_copy_actions__(const struct nlattr *attr,
+static int __ovs_nla_copy_actions(const struct nlattr *attr,
 				  const struct sw_flow_key *key,
 				  int depth, struct sw_flow_actions **sfa,
 				  __be16 eth_type, __be16 vlan_tci);
@@ -1441,7 +1441,7 @@ static int validate_and_copy_sample(const struct nlattr *attr,
 	if (st_acts < 0)
 		return st_acts;
 
-	err = ovs_nla_copy_actions__(actions, key, depth + 1, sfa,
+	err = __ovs_nla_copy_actions(actions, key, depth + 1, sfa,
 				     eth_type, vlan_tci);
 	if (err)
 		return err;
@@ -1684,7 +1684,7 @@ static int copy_action(const struct nlattr *from,
 	return 0;
 }
 
-static int ovs_nla_copy_actions__(const struct nlattr *attr,
+static int __ovs_nla_copy_actions(const struct nlattr *attr,
 				  const struct sw_flow_key *key,
 				  int depth, struct sw_flow_actions **sfa,
 				  __be16 eth_type, __be16 vlan_tci)
@@ -1846,8 +1846,18 @@ int ovs_nla_copy_actions(const struct nlattr *attr,
 			 const struct sw_flow_key *key,
 			 struct sw_flow_actions **sfa)
 {
-	return ovs_nla_copy_actions__(attr, key, 0, sfa, key->eth.type,
-				      key->eth.tci);
+	int err;
+
+	*sfa = nla_alloc_flow_actions(nla_len(attr));
+	if (IS_ERR(*sfa))
+		return PTR_ERR(*sfa);
+
+	err = __ovs_nla_copy_actions(attr, key, 0, sfa, key->eth.type,
+				     key->eth.tci);
+	if (err)
+		kfree(*sfa);
+
+	return err;
 }
 
 static int sample_action_to_attr(const struct nlattr *attr, struct sk_buff *skb)
diff --git a/net/openvswitch/flow_netlink.h b/net/openvswitch/flow_netlink.h
index 4f03706..eb0b177 100644
--- a/net/openvswitch/flow_netlink.h
+++ b/net/openvswitch/flow_netlink.h
@@ -56,7 +56,6 @@ int ovs_nla_copy_actions(const struct nlattr *attr,
 int ovs_nla_put_actions(const struct nlattr *attr,
 			int len, struct sk_buff *skb);
 
-struct sw_flow_actions *ovs_nla_alloc_flow_actions(int actions_len);
 void ovs_nla_free_flow_actions(struct sw_flow_actions *);
 
 #endif /* flow_netlink.h */
-- 
1.9.3
