From: Andy Zhou <azhou@nicira.com>
Subject: [net-next 09/10] openvswitch: Factor out allocation and verification of actions.
Date: Tue, 22 Jul 2014 03:19:52 -0700
Message-ID: <1406024393-6778-10-git-send-email-azhou@nicira.com>
References: <1406024393-6778-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Jesse Gross <jesse@nicira.com>,
	Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog104.obsmtp.com ([74.125.149.73]:40105 "HELO
	na3sys009aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754504AbaGVKcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 06:32:33 -0400
Received: by mail-pd0-f172.google.com with SMTP id ft15so10940978pdb.17
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 03:32:33 -0700 (PDT)
In-Reply-To: <1406024393-6778-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>

As the size of the flow key grows, it can put some pressure on the
stack. This is particularly true in ovs_flow_cmd_set(), which needs several
copies of the key on the stack. One of those uses is logically separate,
so this factors it out to reduce stack pressure and improve readibility.

Signed-off-by: Jesse Gross <jesse@nicira.com>
Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 net/openvswitch/datapath.c |   38 +++++++++++++++++++++++++++-----------
 1 file changed, 27 insertions(+), 11 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 0ddb189..daa935f 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -929,11 +929,34 @@ error:
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
@@ -955,17 +978,10 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
 
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
