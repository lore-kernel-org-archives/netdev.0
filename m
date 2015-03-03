From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCH net-next] openvswitch: Fix serialization of non-masked set actions.
Date: Mon,  2 Mar 2015 18:49:56 -0800
Message-ID: <1425350996-2930-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, jrajahalme@nicira.com
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Set actions consist of a regular OVS_KEY_ATTR_* attribute nested inside
of a OVS_ACTION_ATTR_SET action attribute. When converting masked actions
back to regular set actions, the inner attribute length was not changed,
ie, double the length being serialized. This patch fixes the bug.

Fixes: 83d2b9b ("net: openvswitch: Support masked set actions.")
Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
This fix needs to be applied to net as well; it applies cleanly.
---
 net/openvswitch/flow_netlink.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 216f20b..22b18c1 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -2253,14 +2253,20 @@ static int masked_set_action_to_set_action_attr(const struct nlattr *a,
 						struct sk_buff *skb)
 {
 	const struct nlattr *ovs_key = nla_data(a);
+	struct nlattr *nla;
 	size_t key_len = nla_len(ovs_key) / 2;
 
 	/* Revert the conversion we did from a non-masked set action to
 	 * masked set action.
 	 */
-	if (nla_put(skb, OVS_ACTION_ATTR_SET, nla_len(a) - key_len, ovs_key))
+	nla = nla_nest_start(skb, OVS_ACTION_ATTR_SET);
+	if (!nla)
 		return -EMSGSIZE;
 
+	if (nla_put(skb, nla_type(ovs_key), key_len, nla_data(ovs_key)))
+		return -EMSGSIZE;
+
+	nla_nest_end(skb, nla);
 	return 0;
 }
 
-- 
1.7.10.4
