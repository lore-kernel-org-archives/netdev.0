From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: [PATCH 12/21] lib: Replace commit_set_tun_id_action()
	with commit_set_tunnel_action()
Date: Thu, 24 May 2012 18:09:05 +0900
Message-ID: <1337850554-10339-13-git-send-email-horms@verge.net.au>
References: <1337850554-10339-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1337850554-10339-1-git-send-email-horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
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

Cc: Kyle Mestery <kmestery-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
---
 include/linux/openvswitch.h | 11 +++++++++++
 lib/odp-util.c              | 12 ++++++------
 2 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/include/linux/openvswitch.h b/include/linux/openvswitch.h
index 87a3e22..f2d56ec 100644
--- a/include/linux/openvswitch.h
+++ b/include/linux/openvswitch.h
@@ -372,6 +372,17 @@ struct ovs_key_ipv4_tunnel {
 	__u8   pad[2];
 };
 
+static inline int
+ovs_key_ipv4_tunnel_equal(const struct ovs_key_ipv4_tunnel *a,
+                          const struct ovs_key_ipv4_tunnel *b)
+{
+	return a->ipv4_dst == b->ipv4_dst &&
+		a->tun_id == b->tun_id &&
+		a->ipv4_src == b->ipv4_src &&
+		a->ipv4_tos == b->ipv4_tos &&
+		a->ipv4_ttl == b->ipv4_ttl;
+}
+
 /**
  * enum ovs_flow_attr - attributes for %OVS_FLOW_* commands.
  * @OVS_FLOW_ATTR_KEY: Nested %OVS_KEY_ATTR_* attributes specifying the flow
diff --git a/lib/odp-util.c b/lib/odp-util.c
index 5f76f5e..11b7a1b 100644
--- a/lib/odp-util.c
+++ b/lib/odp-util.c
@@ -1892,16 +1892,16 @@ commit_set_action(struct ofpbuf *odp_actions, enum ovs_key_attr key_type,
 }
 
 static void
-commit_set_tun_id_action(const struct flow *flow, struct flow *base,
+commit_set_tunnel_action(const struct flow *flow, struct flow *base,
                          struct ofpbuf *odp_actions)
 {
-    if (base->tun_key.tun_id == flow->tun_key.tun_id) {
+    if (ovs_key_ipv4_tunnel_equal(&base->tun_key, &flow->tun_key)) {
         return;
     }
-    base->tun_key.tun_id = flow->tun_key.tun_id;
+    base->tun_key = flow->tun_key;
 
-    commit_set_action(odp_actions, OVS_KEY_ATTR_TUN_ID,
-                      &base->tun_key.tun_id, sizeof(base->tun_key.tun_id));
+    commit_set_action(odp_actions, OVS_KEY_ATTR_IPV4_TUNNEL,
+                      &base->tun_key, sizeof(base->tun_key));
 }
 
 static void
@@ -2072,7 +2072,7 @@ void
 commit_odp_actions(const struct flow *flow, struct flow *base,
                    struct ofpbuf *odp_actions)
 {
-    commit_set_tun_id_action(flow, base, odp_actions);
+    commit_set_tunnel_action(flow, base, odp_actions);
     commit_set_ether_addr_action(flow, base, odp_actions);
     commit_vlan_action(flow, base, odp_actions);
     commit_set_nw_action(flow, base, odp_actions);
-- 
1.7.10.2.484.gcd07cc5
