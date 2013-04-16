From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 3/5] Add set skb_priority support to execute_set_action
Date: Tue, 16 Apr 2013 17:14:09 +0900
Message-ID: <1366100051-14772-4-git-send-email-horms@verge.net.au>
References: <1366100051-14772-1-git-send-email-horms@verge.net.au>
Cc: Ravi K <rkerur@gmail.com>, Isaku Yamahata <yamahata@valinux.co.jp>,
	Jesse Gross <jesse@nicira.com>, Ben Pfaff <blp@nicira.com>
To: dev@openvswitch.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:49570 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752138Ab3DPIOR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 04:14:17 -0400
In-Reply-To: <1366100051-14772-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add set skb_priority support to execute_set_action.
This also adds support for the user-space datapath
to honour such actions if they occur before recirculation,
which will be added by a subsequent patch.

This is in preparation for using execute_set_action()
to handle recirculation.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 lib/dpif-netdev.c     |   19 +++++++++++++------
 lib/execute-actions.c |   20 +++++++++++++-------
 lib/execute-actions.h |    2 +-
 3 files changed, 27 insertions(+), 14 deletions(-)

diff --git a/lib/dpif-netdev.c b/lib/dpif-netdev.c
index 2ad65e3..d505b10 100644
--- a/lib/dpif-netdev.c
+++ b/lib/dpif-netdev.c
@@ -156,7 +156,9 @@ static int dp_netdev_output_userspace(struct dp_netdev *, const struct ofpbuf *,
 static void dp_netdev_execute_actions(struct dp_netdev *,
                                       struct ofpbuf *, struct flow *,
                                       const struct nlattr *actions,
-                                      size_t actions_len, uint32_t *skb_mark);
+                                      size_t actions_len,
+                                      uint32_t *skb_priority,
+                                      uint32_t *skb_mark);
 
 static struct dpif_netdev *
 dpif_netdev_cast(const struct dpif *dpif)
@@ -941,11 +943,12 @@ dpif_netdev_execute(struct dpif *dpif, const struct dpif_execute *execute)
     error = dpif_netdev_flow_from_nlattrs(execute->key, execute->key_len,
                                           &key);
     if (!error) {
+        uint32_t skb_priority = 0;
         uint32_t skb_mark = 0;
 
         dp_netdev_execute_actions(dp, &copy, &key,
                                   execute->actions, execute->actions_len,
-                                  &skb_mark);
+                                  &skb_priority, &skb_mark);
     }
 
     ofpbuf_uninit(&copy);
@@ -1034,6 +1037,7 @@ dp_netdev_port_input(struct dp_netdev *dp, struct dp_netdev_port *port,
 {
     struct dp_netdev_flow *flow;
     struct flow key;
+    uint32_t skb_priority = 0;
     uint32_t skb_mark = 0;
 
     if (packet->size < ETH_HEADER_LEN) {
@@ -1044,7 +1048,8 @@ dp_netdev_port_input(struct dp_netdev *dp, struct dp_netdev_port *port,
     if (flow) {
         dp_netdev_flow_used(flow, packet);
         dp_netdev_execute_actions(dp, packet, &key,
-                                  flow->actions, flow->actions_len, &skb_mark);
+                                  flow->actions, flow->actions_len,
+                                  &skb_priority, &skb_mark);
         dp->n_hit++;
     } else {
         dp->n_missed++;
@@ -1165,10 +1170,12 @@ static void
 dp_netdev_execute_actions(struct dp_netdev *dp,
                           struct ofpbuf *packet, struct flow *key,
                           const struct nlattr *actions,
-                          size_t actions_len, uint32_t *skb_mark)
+                          size_t actions_len, uint32_t *skb_priority,
+                          uint32_t *skb_mark)
 {
-    execute_actions(dp, packet, key, actions, actions_len, skb_mark,
-                    dp_netdev_output_port, dp_netdev_action_userspace);
+    execute_actions(dp, packet, key, actions, actions_len, skb_priority,
+                    skb_mark, dp_netdev_output_port,
+                    dp_netdev_action_userspace);
 }
 
 const struct dpif_class dpif_netdev_class = {
diff --git a/lib/execute-actions.c b/lib/execute-actions.c
index c334b42..7f8f468 100644
--- a/lib/execute-actions.c
+++ b/lib/execute-actions.c
@@ -37,7 +37,7 @@ eth_set_src_and_dst(struct ofpbuf *packet,
 
 static void
 execute_set_action(struct ofpbuf *packet, const struct nlattr *a,
-                   uint32_t *skb_mark)
+                   uint32_t *skb_priority, uint32_t *skb_mark)
 {
     enum ovs_key_attr type = nl_attr_type(a);
     const struct ovs_key_ipv4 *ipv4_key;
@@ -46,11 +46,14 @@ execute_set_action(struct ofpbuf *packet, const struct nlattr *a,
     const struct ovs_key_udp *udp_key;
 
     switch (type) {
-    case OVS_KEY_ATTR_PRIORITY:
     case OVS_KEY_ATTR_TUNNEL:
         /* not implemented */
         break;
 
+    case OVS_KEY_ATTR_PRIORITY:
+        *skb_priority = nl_attr_get_u32(a);
+        break;
+
     case OVS_KEY_ATTR_SKB_MARK:
         *skb_mark = nl_attr_get_u32(a);
         break;
@@ -104,7 +107,8 @@ execute_set_action(struct ofpbuf *packet, const struct nlattr *a,
 
 static void
 execute_sample(void *dp, struct ofpbuf *packet, struct flow *key,
-               const struct nlattr *action, uint32_t *skb_mark,
+               const struct nlattr *action, uint32_t *skb_priority,
+               uint32_t *skb_mark,
                void (*output)(void *dp, struct ofpbuf *packet,
                               uint32_t out_port),
                void (*userspace)(void *dp, struct ofpbuf *packet,
@@ -136,13 +140,14 @@ execute_sample(void *dp, struct ofpbuf *packet, struct flow *key,
     }
 
     execute_actions(dp, packet, key, nl_attr_get(subactions),
-                    nl_attr_get_size(subactions), skb_mark, output, userspace);
+                    nl_attr_get_size(subactions), skb_priority, skb_mark,
+                    output, userspace);
 }
 
 void
 execute_actions(void *dp, struct ofpbuf *packet, struct flow *key,
                 const struct nlattr *actions, size_t actions_len,
-                uint32_t *skb_mark,
+                uint32_t *skb_priority, uint32_t *skb_mark,
                 void (*output)(void *dp, struct ofpbuf *packet,
                                uint32_t out_port),
                 void (*userspace)(void *dp, struct ofpbuf *packet,
@@ -186,11 +191,12 @@ execute_actions(void *dp, struct ofpbuf *packet, struct flow *key,
             break;
 
         case OVS_ACTION_ATTR_SET:
-            execute_set_action(packet, nl_attr_get(a), skb_mark);
+            execute_set_action(packet, nl_attr_get(a), skb_priority, skb_mark);
             break;
 
         case OVS_ACTION_ATTR_SAMPLE:
-            execute_sample(dp, packet, key, a, skb_mark, output, userspace);
+            execute_sample(dp, packet, key, a, skb_priority, skb_mark,
+                           output, userspace);
             break;
 
         case OVS_ACTION_ATTR_UNSPEC:
diff --git a/lib/execute-actions.h b/lib/execute-actions.h
index 0e350cb..2dd4741 100644
--- a/lib/execute-actions.h
+++ b/lib/execute-actions.h
@@ -25,7 +25,7 @@
 void
 execute_actions(void *dp, struct ofpbuf *packet, struct flow *key,
                 const struct nlattr *actions, size_t actions_len,
-                uint32_t *skb_mark,
+                uint32_t *skb_priority, uint32_t *skb_mark,
                 void (*output)(void *dp, struct ofpbuf *packet,
                                uint32_t out_port),
                 void (*userspace)(void *dp, struct ofpbuf *packet,
-- 
1.7.10.4
