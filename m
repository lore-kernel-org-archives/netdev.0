From: Simon Horman <horms@verge.net.au>
Subject: [PATCH v2.35 1/6] odp: Only pass vlan_tci to commit_vlan_action()
Date: Sat, 20 Jul 2013 12:06:58 +0900
Message-ID: <1374289623-17056-2-git-send-email-horms@verge.net.au>
References: <1374289623-17056-1-git-send-email-horms@verge.net.au>
Cc: Ravi K <rkerur@gmail.com>, Isaku Yamahata <yamahata@valinux.co.jp>,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	jarno.rajahalme@nsn.com, Joe Stringer <joe@wand.net.nz>
To: dev@openvswitch.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:38074 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753539Ab3GTDGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 23:06:48 -0400
In-Reply-To: <1374289623-17056-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joe@wand.net.nz>

This allows for future patches to pass different tci values to
commit_vlan_action() without passing an entire flow structure.

Signed-off-by: Joe Stringer <joe@wand.net.nz>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 lib/odp-util.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/odp-util.c b/lib/odp-util.c
index 5a32221..1d09ddd 100644
--- a/lib/odp-util.c
+++ b/lib/odp-util.c
@@ -3066,10 +3066,10 @@ commit_set_ether_addr_action(const struct flow *flow, struct flow *base,
 }
 
 static void
-commit_vlan_action(const struct flow *flow, struct flow *base,
+commit_vlan_action(ovs_be16 vlan_tci, struct flow *base,
                    struct ofpbuf *odp_actions, struct flow_wildcards *wc)
 {
-    if (base->vlan_tci == flow->vlan_tci) {
+    if (base->vlan_tci == vlan_tci) {
         return;
     }
 
@@ -3079,15 +3079,15 @@ commit_vlan_action(const struct flow *flow, struct flow *base,
         nl_msg_put_flag(odp_actions, OVS_ACTION_ATTR_POP_VLAN);
     }
 
-    if (flow->vlan_tci & htons(VLAN_CFI)) {
+    if (vlan_tci & htons(VLAN_CFI)) {
         struct ovs_action_push_vlan vlan;
 
         vlan.vlan_tpid = htons(ETH_TYPE_VLAN);
-        vlan.vlan_tci = flow->vlan_tci;
+        vlan.vlan_tci = vlan_tci;
         nl_msg_put_unspec(odp_actions, OVS_ACTION_ATTR_PUSH_VLAN,
                           &vlan, sizeof vlan);
     }
-    base->vlan_tci = flow->vlan_tci;
+    base->vlan_tci = vlan_tci;
 }
 
 static void
@@ -3299,7 +3299,7 @@ commit_odp_actions(const struct flow *flow, struct flow *base,
                    struct ofpbuf *odp_actions, struct flow_wildcards *wc)
 {
     commit_set_ether_addr_action(flow, base, odp_actions, wc);
-    commit_vlan_action(flow, base, odp_actions, wc);
+    commit_vlan_action(flow->vlan_tci, base, odp_actions, wc);
     commit_set_nw_action(flow, base, odp_actions, wc);
     commit_set_port_action(flow, base, odp_actions, wc);
     /* Committing MPLS actions should occur after committing nw and port
-- 
1.7.10.4
