From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: [PATCH 4/5] Add set tunnel support to execute_set_action
Date: Tue, 16 Apr 2013 17:14:10 +0900
Message-ID: <1366100051-14772-5-git-send-email-horms@verge.net.au>
References: <1366100051-14772-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Isaku Yamahata <yamahata-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1366100051-14772-1-git-send-email-horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
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

Add set tunnel support to execute_set_action.
This also adds support for the user-space datapath
to honour such actions if they occur before recirculation,
which will be added by a subsequent patch.

This is in preparation for using execute_set_action()
to handle recirculation.

Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
---
 lib/dpif-netdev.c     |   15 ++++++++++-----
 lib/execute-actions.c |   25 +++++++++++++++++++------
 lib/execute-actions.h |    1 +
 lib/odp-util.c        |    2 +-
 lib/odp-util.h        |    3 +++
 5 files changed, 34 insertions(+), 12 deletions(-)

diff --git a/lib/dpif-netdev.c b/lib/dpif-netdev.c
index d505b10..0acecdb 100644
--- a/lib/dpif-netdev.c
+++ b/lib/dpif-netdev.c
@@ -158,7 +158,8 @@ static void dp_netdev_execute_actions(struct dp_netdev *,
                                       const struct nlattr *actions,
                                       size_t actions_len,
                                       uint32_t *skb_priority,
-                                      uint32_t *skb_mark);
+                                      uint32_t *skb_mark,
+                                      struct flow_tnl *tun_key);
 
 static struct dpif_netdev *
 dpif_netdev_cast(const struct dpif *dpif)
@@ -945,10 +946,12 @@ dpif_netdev_execute(struct dpif *dpif, const struct dpif_execute *execute)
     if (!error) {
         uint32_t skb_priority = 0;
         uint32_t skb_mark = 0;
+        struct flow_tnl tun_key;
 
+        memset(&tun_key, 0, sizeof tun_key);
         dp_netdev_execute_actions(dp, &copy, &key,
                                   execute->actions, execute->actions_len,
-                                  &skb_priority, &skb_mark);
+                                  &skb_priority, &skb_mark, &tun_key);
     }
 
     ofpbuf_uninit(&copy);
@@ -1039,6 +1042,7 @@ dp_netdev_port_input(struct dp_netdev *dp, struct dp_netdev_port *port,
     struct flow key;
     uint32_t skb_priority = 0;
     uint32_t skb_mark = 0;
+    struct flow_tnl tun_key;
 
     if (packet->size < ETH_HEADER_LEN) {
         return;
@@ -1046,10 +1050,11 @@ dp_netdev_port_input(struct dp_netdev *dp, struct dp_netdev_port *port,
     flow_extract(packet, 0, 0, NULL, port->port_no, &key);
     flow = dp_netdev_lookup_flow(dp, &key);
     if (flow) {
+        memset(&tun_key, 0, sizeof tun_key);
         dp_netdev_flow_used(flow, packet);
         dp_netdev_execute_actions(dp, packet, &key,
                                   flow->actions, flow->actions_len,
-                                  &skb_priority, &skb_mark);
+                                  &skb_priority, &skb_mark, &tun_key);
         dp->n_hit++;
     } else {
         dp->n_missed++;
@@ -1171,10 +1176,10 @@ dp_netdev_execute_actions(struct dp_netdev *dp,
                           struct ofpbuf *packet, struct flow *key,
                           const struct nlattr *actions,
                           size_t actions_len, uint32_t *skb_priority,
-                          uint32_t *skb_mark)
+                          uint32_t *skb_mark, struct flow_tnl *tun_key)
 {
     execute_actions(dp, packet, key, actions, actions_len, skb_priority,
-                    skb_mark, dp_netdev_output_port,
+                    skb_mark, tun_key, dp_netdev_output_port,
                     dp_netdev_action_userspace);
 }
 
diff --git a/lib/execute-actions.c b/lib/execute-actions.c
index 7f8f468..ca9c3ca 100644
--- a/lib/execute-actions.c
+++ b/lib/execute-actions.c
@@ -22,6 +22,7 @@
 
 #include "execute-actions.h"
 #include "netlink.h"
+#include "odp-util.h"
 #include "packets.h"
 #include "util.h"
 
@@ -36,8 +37,18 @@ eth_set_src_and_dst(struct ofpbuf *packet,
 }
 
 static void
+set_tunnel_action(const struct nlattr *a, struct flow_tnl *tun_key)
+{
+    enum odp_key_fitness fitness = tun_key_from_attr(a, tun_key);
+
+    memset(&tun_key, 0, sizeof tun_key);
+    ovs_assert(fitness != ODP_FIT_ERROR);
+}
+
+static void
 execute_set_action(struct ofpbuf *packet, const struct nlattr *a,
-                   uint32_t *skb_priority, uint32_t *skb_mark)
+                   uint32_t *skb_priority, uint32_t *skb_mark,
+                   struct flow_tnl *tun_key)
 {
     enum ovs_key_attr type = nl_attr_type(a);
     const struct ovs_key_ipv4 *ipv4_key;
@@ -47,7 +58,7 @@ execute_set_action(struct ofpbuf *packet, const struct nlattr *a,
 
     switch (type) {
     case OVS_KEY_ATTR_TUNNEL:
-        /* not implemented */
+        set_tunnel_action(a, tun_key);
         break;
 
     case OVS_KEY_ATTR_PRIORITY:
@@ -108,7 +119,7 @@ execute_set_action(struct ofpbuf *packet, const struct nlattr *a,
 static void
 execute_sample(void *dp, struct ofpbuf *packet, struct flow *key,
                const struct nlattr *action, uint32_t *skb_priority,
-               uint32_t *skb_mark,
+               uint32_t *skb_mark, struct flow_tnl *tun_key,
                void (*output)(void *dp, struct ofpbuf *packet,
                               uint32_t out_port),
                void (*userspace)(void *dp, struct ofpbuf *packet,
@@ -141,13 +152,14 @@ execute_sample(void *dp, struct ofpbuf *packet, struct flow *key,
 
     execute_actions(dp, packet, key, nl_attr_get(subactions),
                     nl_attr_get_size(subactions), skb_priority, skb_mark,
-                    output, userspace);
+                    tun_key, output, userspace);
 }
 
 void
 execute_actions(void *dp, struct ofpbuf *packet, struct flow *key,
                 const struct nlattr *actions, size_t actions_len,
                 uint32_t *skb_priority, uint32_t *skb_mark,
+                struct flow_tnl *tun_key,
                 void (*output)(void *dp, struct ofpbuf *packet,
                                uint32_t out_port),
                 void (*userspace)(void *dp, struct ofpbuf *packet,
@@ -191,11 +203,12 @@ execute_actions(void *dp, struct ofpbuf *packet, struct flow *key,
             break;
 
         case OVS_ACTION_ATTR_SET:
-            execute_set_action(packet, nl_attr_get(a), skb_priority, skb_mark);
+            execute_set_action(packet, nl_attr_get(a), skb_priority, skb_mark,
+                               tun_key);
             break;
 
         case OVS_ACTION_ATTR_SAMPLE:
-            execute_sample(dp, packet, key, a, skb_priority, skb_mark,
+            execute_sample(dp, packet, key, a, skb_priority, skb_mark, tun_key,
                            output, userspace);
             break;
 
diff --git a/lib/execute-actions.h b/lib/execute-actions.h
index 2dd4741..2c36f27 100644
--- a/lib/execute-actions.h
+++ b/lib/execute-actions.h
@@ -26,6 +26,7 @@ void
 execute_actions(void *dp, struct ofpbuf *packet, struct flow *key,
                 const struct nlattr *actions, size_t actions_len,
                 uint32_t *skb_priority, uint32_t *skb_mark,
+                struct flow_tnl *tun_key,
                 void (*output)(void *dp, struct ofpbuf *packet,
                                uint32_t out_port),
                 void (*userspace)(void *dp, struct ofpbuf *packet,
diff --git a/lib/odp-util.c b/lib/odp-util.c
index 3206dc9..acecb78 100644
--- a/lib/odp-util.c
+++ b/lib/odp-util.c
@@ -737,7 +737,7 @@ tunnel_key_attr_len(int type)
     return -1;
 }
 
-static enum odp_key_fitness
+enum odp_key_fitness
 tun_key_from_attr(const struct nlattr *attr, struct flow_tnl *tun)
 {
     unsigned int left;
diff --git a/lib/odp-util.h b/lib/odp-util.h
index ad0fb30..df38ec0 100644
--- a/lib/odp-util.h
+++ b/lib/odp-util.h
@@ -87,6 +87,9 @@ struct odputil_keybuf {
     uint32_t keybuf[DIV_ROUND_UP(ODPUTIL_FLOW_KEY_BYTES, 4)];
 };
 
+enum odp_key_fitness
+tun_key_from_attr(const struct nlattr *attr, struct flow_tnl *tun);
+
 void odp_flow_key_format(const struct nlattr *, size_t, struct ds *);
 int odp_flow_key_from_string(const char *s, const struct simap *port_names,
                              struct ofpbuf *);
-- 
1.7.10.4
