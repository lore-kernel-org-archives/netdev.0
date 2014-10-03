From: Andy Zhou <azhou@nicira.com>
Subject: [net-next v2 5/6] openvswitch: Factor out allocation and verification of actions.
Date: Fri,  3 Oct 2014 15:35:32 -0700
Message-ID: <1412375733-30981-6-git-send-email-azhou@nicira.com>
References: <1412375733-30981-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Jesse Gross <jesse@nicira.com>,
	Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog117.obsmtp.com ([74.125.149.242]:54350 "HELO
	na3sys009aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756262AbaJCWmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 18:42:33 -0400
Received: by mail-pd0-f176.google.com with SMTP id fp1so298146pdb.7
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 15:42:33 -0700 (PDT)
In-Reply-To: <1412375733-30981-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>

As the size of the flow key grows, it can put some pressure on the
stack. This is particularly true in ovs_flow_cmd_set(), which needs several
copies of the key on the stack. One of those uses is logically separate,
so this factors it out to reduce stack pressure and improve readibility.

Signed-off-by: Jesse Gross <jesse@nicira.com>
Signed-off-by: Andy Zhou <azhou@nicira.com>
Acked-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/datapath.c |   38 +++++++++++++++++++++++++++-----------
 1 file changed, 27 insertions(+), 11 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index f6bd93d..010125c 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -933,11 +933,34 @@ error:
 	return error;
 }
 
+static struct sw_flow_actions *get_flow_actions(const struct nlattr *a,
+						const struct sw_flow_key *key,
+						const struct sw_flow_mask *mask)
+{
+	struct sw_flow_actions *acts;
+	struct sw_flow_key masked_key;
+	int error;
+
+	acts = ovs_nla_alloc_flow_actions(nla_len(a));
+	if (IS_ERR(acts))
+		return acts;
+
+	ovs_flow_mask_key(&masked_key, key, mask);
+	error = ovs_nla_copy_actions(a, &masked_key, 0, &acts);
+	if (error) {
+		OVS_NLERR("Flow actions may not be safe on all matching packets.\n");
+		kfree(acts);
+		return ERR_PTR(error);
+	}
+
+	return acts;
+}
+
 static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
 {
 	struct nlattr **a = info->attrs;
 	struct ovs_header *ovs_header = info->userhdr;
-	struct sw_flow_key key, masked_key;
+	struct sw_flow_key key;
 	struct sw_flow *flow;
 	struct sw_flow_mask mask;
 	struct sk_buff *reply = NULL;
@@ -959,17 +982,10 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
 
 	/* Validate actions. */
 	if (a[OVS_FLOW_ATTR_ACTIONS]) {
-		acts = ovs_nla_alloc_flow_actions(nla_len(a[OVS_FLOW_ATTR_ACTIONS]));
-		error = PTR_ERR(acts);
-		if (IS_ERR(acts))
+		acts = get_flow_actions(a[OVS_FLOW_ATTR_ACTIONS], &key, &mask);
+		if (IS_ERR(acts)) {
+			error = PTR_ERR(acts);
 			goto error;
-
-		ovs_flow_mask_key(&masked_key, &key, &mask);
-		error = ovs_nla_copy_actions(a[OVS_FLOW_ATTR_ACTIONS],
-					     &masked_key, 0, &acts);
-		if (error) {
-			OVS_NLERR("Flow actions may not be safe on all matching packets.\n");
-			goto err_kfree_acts;
 		}
 	}
 
-- 
1.7.9.5
