From: Simon Horman <horms@verge.net.au>
Subject: [PATCH v2.37 1/6] odp: Only pass vlan_tci to commit_vlan_action()
Date: Tue, 20 Aug 2013 12:15:59 +1000
Message-ID: <1376964964-18151-2-git-send-email-horms@verge.net.au>
References: <1376964964-18151-1-git-send-email-horms@verge.net.au>
Cc: Ravi K <rkerur@gmail.com>, Isaku Yamahata <yamahata@valinux.co.jp>,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Joe Stringer <joe@wand.net.nz>
To: dev@openvswitch.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:54712 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751309Ab3HTCOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 22:14:31 -0400
In-Reply-To: <1376964964-18151-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joe@wand.net.nz>

This allows for future patches to pass different tci values to
commit_vlan_action() without passing an entire flow structure.

Signed-off-by: Joe Stringer <joe@wand.net.nz>
Signed-off-by: Simon Horman <horms@verge.net.au>

---

v2.36 - v2.37
* No change

v2.35
* First post
---
 lib/odp-util.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/odp-util.c b/lib/odp-util.c
index a09042e..d0c9bbe 100644
--- a/lib/odp-util.c
+++ b/lib/odp-util.c
@@ -3097,10 +3097,10 @@ commit_set_ether_addr_action(const struct flow *flow, struct flow *base,
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
 
@@ -3110,15 +3110,15 @@ commit_vlan_action(const struct flow *flow, struct flow *base,
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
@@ -3330,7 +3330,7 @@ commit_odp_actions(const struct flow *flow, struct flow *base,
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
