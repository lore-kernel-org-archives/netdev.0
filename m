From: Pravin B Shelar <pshelar@ovn.org>
Subject: [PATCH net-next 1/2] openvswitch: Fix Frame-size larger than 1024 bytes warning.
Date: Mon, 19 Sep 2016 13:50:59 -0700
Message-ID: <1474318260-16988-1-git-send-email-pshelar@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Pravin B Shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:42293 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750997AbcISUvN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 16:51:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to declare separate key on stack,
we can just use sw_flow->key to store the key directly.

This commit fixes following warning:

net/openvswitch/datapath.c: In function ‘ovs_flow_cmd_new’:
net/openvswitch/datapath.c:1080:1: warning: the frame size of 1040 bytes
is larger than 1024 bytes [-Wframe-larger-than=]

Signed-off-by: Pravin B Shelar <pshelar@ovn.org>
---
 net/openvswitch/datapath.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 0536ab3..474e7a6 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -928,7 +928,6 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	struct sw_flow_mask mask;
 	struct sk_buff *reply;
 	struct datapath *dp;
-	struct sw_flow_key key;
 	struct sw_flow_actions *acts;
 	struct sw_flow_match match;
 	u32 ufid_flags = ovs_nla_get_ufid_flags(a[OVS_FLOW_ATTR_UFID_FLAGS]);
@@ -956,20 +955,24 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	}
 
 	/* Extract key. */
-	ovs_match_init(&match, &key, &mask);
+	ovs_match_init(&match, &new_flow->key, &mask);
 	error = ovs_nla_get_match(net, &match, a[OVS_FLOW_ATTR_KEY],
 				  a[OVS_FLOW_ATTR_MASK], log);
 	if (error)
 		goto err_kfree_flow;
 
-	ovs_flow_mask_key(&new_flow->key, &key, true, &mask);
-
 	/* Extract flow identifier. */
 	error = ovs_nla_get_identifier(&new_flow->id, a[OVS_FLOW_ATTR_UFID],
-				       &key, log);
+				       &new_flow->key, log);
 	if (error)
 		goto err_kfree_flow;
 
+	/* unmasked key is needed to match when ufid is not used. */
+	if (ovs_identifier_is_key(&new_flow->id))
+		match.key = new_flow->id.unmasked_key;
+
+	ovs_flow_mask_key(&new_flow->key, &new_flow->key, true, &mask);
+
 	/* Validate actions. */
 	error = ovs_nla_copy_actions(net, a[OVS_FLOW_ATTR_ACTIONS],
 				     &new_flow->key, &acts, log);
@@ -996,7 +999,7 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	if (ovs_identifier_is_ufid(&new_flow->id))
 		flow = ovs_flow_tbl_lookup_ufid(&dp->table, &new_flow->id);
 	if (!flow)
-		flow = ovs_flow_tbl_lookup(&dp->table, &key);
+		flow = ovs_flow_tbl_lookup(&dp->table, &new_flow->key);
 	if (likely(!flow)) {
 		rcu_assign_pointer(new_flow->sf_acts, acts);
 
-- 
1.9.1
