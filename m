From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 2/5] Add set skb_mark support to execute_set_action
Date: Tue, 16 Apr 2013 17:14:08 +0900
Message-ID: <1366100051-14772-3-git-send-email-horms@verge.net.au>
References: <1366100051-14772-1-git-send-email-horms@verge.net.au>
Cc: Ravi K <rkerur@gmail.com>, Isaku Yamahata <yamahata@valinux.co.jp>,
	Jesse Gross <jesse@nicira.com>, Ben Pfaff <blp@nicira.com>
To: dev@openvswitch.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:49571 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752466Ab3DPIOR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 04:14:17 -0400
In-Reply-To: <1366100051-14772-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add set skb_mark support to execute_set_action.
This also adds support for the user-space datapath
to honour such actions if they occur before recirculation,
which will be added by a subsequent patch.

This is in preparation for using execute_set_action()
to handle recirculation.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 lib/dpif-netdev.c     |   14 +++++++++-----
 lib/execute-actions.c |   17 +++++++++++------
 lib/execute-actions.h |    1 +
 3 files changed, 21 insertions(+), 11 deletions(-)

diff --git a/lib/dpif-netdev.c b/lib/dpif-netdev.c
index ecdc486..2ad65e3 100644
--- a/lib/dpif-netdev.c
+++ b/lib/dpif-netdev.c
@@ -156,7 +156,7 @@ static int dp_netdev_output_userspace(struct dp_netdev *, const struct ofpbuf *,
 static void dp_netdev_execute_actions(struct dp_netdev *,
                                       struct ofpbuf *, struct flow *,
                                       const struct nlattr *actions,
-                                      size_t actions_len);
+                                      size_t actions_len, uint32_t *skb_mark);
 
 static struct dpif_netdev *
 dpif_netdev_cast(const struct dpif *dpif)
@@ -941,8 +941,11 @@ dpif_netdev_execute(struct dpif *dpif, const struct dpif_execute *execute)
     error = dpif_netdev_flow_from_nlattrs(execute->key, execute->key_len,
                                           &key);
     if (!error) {
+        uint32_t skb_mark = 0;
+
         dp_netdev_execute_actions(dp, &copy, &key,
-                                  execute->actions, execute->actions_len);
+                                  execute->actions, execute->actions_len,
+                                  &skb_mark);
     }
 
     ofpbuf_uninit(&copy);
@@ -1031,6 +1034,7 @@ dp_netdev_port_input(struct dp_netdev *dp, struct dp_netdev_port *port,
 {
     struct dp_netdev_flow *flow;
     struct flow key;
+    uint32_t skb_mark = 0;
 
     if (packet->size < ETH_HEADER_LEN) {
         return;
@@ -1040,7 +1044,7 @@ dp_netdev_port_input(struct dp_netdev *dp, struct dp_netdev_port *port,
     if (flow) {
         dp_netdev_flow_used(flow, packet);
         dp_netdev_execute_actions(dp, packet, &key,
-                                  flow->actions, flow->actions_len);
+                                  flow->actions, flow->actions_len, &skb_mark);
         dp->n_hit++;
     } else {
         dp->n_missed++;
@@ -1161,9 +1165,9 @@ static void
 dp_netdev_execute_actions(struct dp_netdev *dp,
                           struct ofpbuf *packet, struct flow *key,
                           const struct nlattr *actions,
-                          size_t actions_len)
+                          size_t actions_len, uint32_t *skb_mark)
 {
-    execute_actions(dp, packet, key, actions, actions_len,
+    execute_actions(dp, packet, key, actions, actions_len, skb_mark,
                     dp_netdev_output_port, dp_netdev_action_userspace);
 }
 
diff --git a/lib/execute-actions.c b/lib/execute-actions.c
index db57900..c334b42 100644
--- a/lib/execute-actions.c
+++ b/lib/execute-actions.c
@@ -36,7 +36,8 @@ eth_set_src_and_dst(struct ofpbuf *packet,
 }
 
 static void
-execute_set_action(struct ofpbuf *packet, const struct nlattr *a)
+execute_set_action(struct ofpbuf *packet, const struct nlattr *a,
+                   uint32_t *skb_mark)
 {
     enum ovs_key_attr type = nl_attr_type(a);
     const struct ovs_key_ipv4 *ipv4_key;
@@ -47,10 +48,13 @@ execute_set_action(struct ofpbuf *packet, const struct nlattr *a)
     switch (type) {
     case OVS_KEY_ATTR_PRIORITY:
     case OVS_KEY_ATTR_TUNNEL:
-    case OVS_KEY_ATTR_SKB_MARK:
         /* not implemented */
         break;
 
+    case OVS_KEY_ATTR_SKB_MARK:
+        *skb_mark = nl_attr_get_u32(a);
+        break;
+
     case OVS_KEY_ATTR_ETHERNET:
         eth_set_src_and_dst(packet,
                    nl_attr_get_unspec(a, sizeof(struct ovs_key_ethernet)));
@@ -100,7 +104,7 @@ execute_set_action(struct ofpbuf *packet, const struct nlattr *a)
 
 static void
 execute_sample(void *dp, struct ofpbuf *packet, struct flow *key,
-               const struct nlattr *action,
+               const struct nlattr *action, uint32_t *skb_mark,
                void (*output)(void *dp, struct ofpbuf *packet,
                               uint32_t out_port),
                void (*userspace)(void *dp, struct ofpbuf *packet,
@@ -132,12 +136,13 @@ execute_sample(void *dp, struct ofpbuf *packet, struct flow *key,
     }
 
     execute_actions(dp, packet, key, nl_attr_get(subactions),
-                    nl_attr_get_size(subactions), output, userspace);
+                    nl_attr_get_size(subactions), skb_mark, output, userspace);
 }
 
 void
 execute_actions(void *dp, struct ofpbuf *packet, struct flow *key,
                 const struct nlattr *actions, size_t actions_len,
+                uint32_t *skb_mark,
                 void (*output)(void *dp, struct ofpbuf *packet,
                                uint32_t out_port),
                 void (*userspace)(void *dp, struct ofpbuf *packet,
@@ -181,11 +186,11 @@ execute_actions(void *dp, struct ofpbuf *packet, struct flow *key,
             break;
 
         case OVS_ACTION_ATTR_SET:
-            execute_set_action(packet, nl_attr_get(a));
+            execute_set_action(packet, nl_attr_get(a), skb_mark);
             break;
 
         case OVS_ACTION_ATTR_SAMPLE:
-            execute_sample(dp, packet, key, a, output, userspace);
+            execute_sample(dp, packet, key, a, skb_mark, output, userspace);
             break;
 
         case OVS_ACTION_ATTR_UNSPEC:
diff --git a/lib/execute-actions.h b/lib/execute-actions.h
index 7a62269..0e350cb 100644
--- a/lib/execute-actions.h
+++ b/lib/execute-actions.h
@@ -25,6 +25,7 @@
 void
 execute_actions(void *dp, struct ofpbuf *packet, struct flow *key,
                 const struct nlattr *actions, size_t actions_len,
+                uint32_t *skb_mark,
                 void (*output)(void *dp, struct ofpbuf *packet,
                                uint32_t out_port),
                 void (*userspace)(void *dp, struct ofpbuf *packet,
-- 
1.7.10.4
