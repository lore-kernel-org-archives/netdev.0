From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: [PATCH v2.36 1/6] odp: Only pass vlan_tci to
	commit_vlan_action()
Date: Fri,  9 Aug 2013 17:25:16 +0900
Message-ID: <1376036721-29156-2-git-send-email-horms@verge.net.au>
References: <1376036721-29156-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Isaku Yamahata <yamahata-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
To: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1376036721-29156-1-git-send-email-horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
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

From: Joe Stringer <joe-Q1GJJQv1iO6lP80pJB477g@public.gmane.org>

This allows for future patches to pass different tci values to
commit_vlan_action() without passing an entire flow structure.

Signed-off-by: Joe Stringer <joe-Q1GJJQv1iO6lP80pJB477g@public.gmane.org>
Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
---
 lib/odp-util.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/odp-util.c b/lib/odp-util.c
index 78d5a1b..8823041 100644
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
1.8.3.2
