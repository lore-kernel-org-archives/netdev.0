From: Samuel Gauthier <samuel.gauthier@6wind.com>
Subject: [PATCH v2 net-next] ovs: allow nl 'flow set' to use ufid without flow key
Date: Thu, 10 Mar 2016 17:14:59 +0100
Message-ID: <1457626499-26585-1-git-send-email-samuel.gauthier@6wind.com>
References: <CAMEOZhK0kBpdS8uOqYqzQs+6LyWh5K3MWL__CRoThmNRnBN2MQ@mail.gmail.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Samuel Gauthier <samuel.gauthier@6wind.com>
To: Pravin Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:57557 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752942AbcCJQRc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 11:17:32 -0500
In-Reply-To: <CAMEOZhK0kBpdS8uOqYqzQs+6LyWh5K3MWL__CRoThmNRnBN2MQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we want to change a flow using netlink, we have to identify it to
be able to perform a lookup. Both the flow key and unique flow ID
(ufid) are valid identifiers, but we always have to specify the flow
key in the netlink message. When both attributes are there, the ufid
is used. The flow key is used to validate the actions provided by
the userland.

This commit allows to use the ufid without having to provide the flow
key, as it is already done in the netlink 'flow get' and 'flow del'
path. The flow key remains mandatory when an action is provided.

Signed-off-by: Samuel Gauthier <samuel.gauthier@6wind.com>
---
v2:
 - Restore mask init and parsing
 - Keep the flow key mandatory when an action is provided

 net/openvswitch/datapath.c | 28 +++++++++++++++++-----------
 1 file changed, 17 insertions(+), 11 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index deadfdab1bc3..db6858f2f67a 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1100,26 +1100,32 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
 	struct sw_flow_match match;
 	struct sw_flow_id sfid;
 	u32 ufid_flags = ovs_nla_get_ufid_flags(a[OVS_FLOW_ATTR_UFID_FLAGS]);
-	int error;
+	int error = 0;
 	bool log = !a[OVS_FLOW_ATTR_PROBE];
 	bool ufid_present;
 
-	/* Extract key. */
-	error = -EINVAL;
-	if (!a[OVS_FLOW_ATTR_KEY]) {
-		OVS_NLERR(log, "Flow key attribute not present in set flow.");
-		goto error;
-	}
-
 	ufid_present = ovs_nla_get_ufid(&sfid, a[OVS_FLOW_ATTR_UFID], log);
-	ovs_match_init(&match, &key, &mask);
-	error = ovs_nla_get_match(net, &match, a[OVS_FLOW_ATTR_KEY],
-				  a[OVS_FLOW_ATTR_MASK], log);
+	if (a[OVS_FLOW_ATTR_KEY]) {
+		ovs_match_init(&match, &key, &mask);
+		error = ovs_nla_get_match(net, &match, a[OVS_FLOW_ATTR_KEY],
+					  a[OVS_FLOW_ATTR_MASK], log);
+	} else if (!ufid_present) {
+		OVS_NLERR(log,
+			  "Flow set message rejected, Key attribute missing.");
+		error = -EINVAL;
+	}
 	if (error)
 		goto error;
 
 	/* Validate actions. */
 	if (a[OVS_FLOW_ATTR_ACTIONS]) {
+		if (!a[OVS_FLOW_ATTR_KEY]) {
+			OVS_NLERR(log,
+				  "Flow key attribute not present in set flow.");
+			error = -EINVAL;
+			goto error;
+		}
+
 		acts = get_flow_actions(net, a[OVS_FLOW_ATTR_ACTIONS], &key,
 					&mask, log);
 		if (IS_ERR(acts)) {
-- 
2.2.1.62.g3f15098
