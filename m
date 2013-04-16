From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: [PATCH 1/5] Add execute_actions
Date: Tue, 16 Apr 2013 17:14:07 +0900
Message-ID: <1366100051-14772-2-git-send-email-horms@verge.net.au>
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

This moves generic action execution code out of lib/dpif-netedev.c
and into a new file, lib/execute-actions.c.

This is in preparation for using execute_set_action()
in lib/odp-util.c to handle recirculation/

Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>

---

v6
* As suggested by Jesse Gross
  - Create a new file for these functions
  - Rename dp_netdev_set_dl as eth_set_src_and_dst.
    I have not moved it to packet.c as its eth_key parameter
    is struct ovs_key_ethernet which is defined in linux/openvswtich.h
    and I am unsure if it is desirable to add that include to packet.c
    Furthermore, eth_set_src_and_dst() is currently only
    used inside lib/execute-actions.c.
  - Move much more code out of lib/dpif-netedev.c, creating execute_actions()
* Rename patch
  "Move execute_set_action to lib/odp-util.c"
  -> "Add execute_actions"
* Reorder patch to before any recirculation changes
  and thus don't include skb mark code in execute_set_action()

v5
* No change

rfc4
* make use of skb_mark

rfc2 - rfc3
* omitted

rfc1
* Initial post

Conflicts:
	lib/dpif-netdev.c

execute_actions
---
 lib/automake.mk       |    2 +
 lib/dpif-netdev.c     |  166 ++---------------------------------------
 lib/execute-actions.c |  196 +++++++++++++++++++++++++++++++++++++++++++++++++
 lib/execute-actions.h |   32 ++++++++
 4 files changed, 237 insertions(+), 159 deletions(-)
 create mode 100644 lib/execute-actions.c
 create mode 100644 lib/execute-actions.h

diff --git a/lib/automake.mk b/lib/automake.mk
index 1d58604..922ceda 100644
--- a/lib/automake.mk
+++ b/lib/automake.mk
@@ -43,6 +43,8 @@ lib_libopenvswitch_a_SOURCES = \
 	lib/dpif-provider.h \
 	lib/dpif.c \
 	lib/dpif.h \
+	lib/execute-actions.c \
+	lib/execute-actions.h \
 	lib/heap.c \
 	lib/heap.h \
 	lib/dynamic-string.c \
diff --git a/lib/dpif-netdev.c b/lib/dpif-netdev.c
index e4a2f75..ecdc486 100644
--- a/lib/dpif-netdev.c
+++ b/lib/dpif-netdev.c
@@ -37,6 +37,7 @@
 #include "dummy.h"
 #include "dynamic-string.h"
 #include "flow.h"
+#include "execute-actions.h"
 #include "hmap.h"
 #include "list.h"
 #include "netdev.h"
@@ -1088,19 +1089,10 @@ dpif_netdev_wait(struct dpif *dpif)
 }
 
 static void
-dp_netdev_set_dl(struct ofpbuf *packet, const struct ovs_key_ethernet *eth_key)
+dp_netdev_output_port(void *dp, struct ofpbuf *packet, uint32_t out_port)
 {
-    struct eth_header *eh = packet->l2;
-
-    memcpy(eh->eth_src, eth_key->eth_src, sizeof eh->eth_src);
-    memcpy(eh->eth_dst, eth_key->eth_dst, sizeof eh->eth_dst);
-}
-
-static void
-dp_netdev_output_port(struct dp_netdev *dp, struct ofpbuf *packet,
-                      uint32_t out_port)
-{
-    struct dp_netdev_port *p = dp->ports[out_port];
+    struct dp_netdev *dp_ = dp;
+    struct dp_netdev_port *p = dp_->ports[out_port];
     if (p) {
         netdev_send(p->netdev, packet);
     }
@@ -1156,42 +1148,7 @@ dp_netdev_output_userspace(struct dp_netdev *dp, const struct ofpbuf *packet,
 }
 
 static void
-dp_netdev_sample(struct dp_netdev *dp,
-                 struct ofpbuf *packet, struct flow *key,
-                 const struct nlattr *action)
-{
-    const struct nlattr *subactions = NULL;
-    const struct nlattr *a;
-    size_t left;
-
-    NL_NESTED_FOR_EACH_UNSAFE (a, left, action) {
-        int type = nl_attr_type(a);
-
-        switch ((enum ovs_sample_attr) type) {
-        case OVS_SAMPLE_ATTR_PROBABILITY:
-            if (random_uint32() >= nl_attr_get_u32(a)) {
-                return;
-            }
-            break;
-
-        case OVS_SAMPLE_ATTR_ACTIONS:
-            subactions = a;
-            break;
-
-        case OVS_SAMPLE_ATTR_UNSPEC:
-        case __OVS_SAMPLE_ATTR_MAX:
-        default:
-            NOT_REACHED();
-        }
-    }
-
-    dp_netdev_execute_actions(dp, packet, key, nl_attr_get(subactions),
-                              nl_attr_get_size(subactions));
-}
-
-static void
-dp_netdev_action_userspace(struct dp_netdev *dp,
-                          struct ofpbuf *packet, struct flow *key,
+dp_netdev_action_userspace(void *dp, struct ofpbuf *packet, struct flow *key,
                           const struct nlattr *a)
 {
     const struct nlattr *userdata;
@@ -1201,122 +1158,13 @@ dp_netdev_action_userspace(struct dp_netdev *dp,
 }
 
 static void
-execute_set_action(struct ofpbuf *packet, const struct nlattr *a)
-{
-    enum ovs_key_attr type = nl_attr_type(a);
-    const struct ovs_key_ipv4 *ipv4_key;
-    const struct ovs_key_ipv6 *ipv6_key;
-    const struct ovs_key_tcp *tcp_key;
-    const struct ovs_key_udp *udp_key;
-
-    switch (type) {
-    case OVS_KEY_ATTR_PRIORITY:
-    case OVS_KEY_ATTR_SKB_MARK:
-    case OVS_KEY_ATTR_TUNNEL:
-        /* not implemented */
-        break;
-
-    case OVS_KEY_ATTR_ETHERNET:
-        dp_netdev_set_dl(packet,
-                   nl_attr_get_unspec(a, sizeof(struct ovs_key_ethernet)));
-        break;
-
-    case OVS_KEY_ATTR_IPV4:
-        ipv4_key = nl_attr_get_unspec(a, sizeof(struct ovs_key_ipv4));
-        packet_set_ipv4(packet, ipv4_key->ipv4_src, ipv4_key->ipv4_dst,
-                        ipv4_key->ipv4_tos, ipv4_key->ipv4_ttl);
-        break;
-
-    case OVS_KEY_ATTR_IPV6:
-        ipv6_key = nl_attr_get_unspec(a, sizeof(struct ovs_key_ipv6));
-        packet_set_ipv6(packet, ipv6_key->ipv6_proto, ipv6_key->ipv6_src,
-                        ipv6_key->ipv6_dst, ipv6_key->ipv6_tclass,
-                        ipv6_key->ipv6_label, ipv6_key->ipv6_hlimit);
-        break;
-
-    case OVS_KEY_ATTR_TCP:
-        tcp_key = nl_attr_get_unspec(a, sizeof(struct ovs_key_tcp));
-        packet_set_tcp_port(packet, tcp_key->tcp_src, tcp_key->tcp_dst);
-        break;
-
-     case OVS_KEY_ATTR_UDP:
-        udp_key = nl_attr_get_unspec(a, sizeof(struct ovs_key_udp));
-        packet_set_udp_port(packet, udp_key->udp_src, udp_key->udp_dst);
-        break;
-
-     case OVS_KEY_ATTR_MPLS:
-         set_mpls_lse(packet, nl_attr_get_be32(a));
-         break;
-
-     case OVS_KEY_ATTR_UNSPEC:
-     case OVS_KEY_ATTR_ENCAP:
-     case OVS_KEY_ATTR_ETHERTYPE:
-     case OVS_KEY_ATTR_IN_PORT:
-     case OVS_KEY_ATTR_VLAN:
-     case OVS_KEY_ATTR_ICMP:
-     case OVS_KEY_ATTR_ICMPV6:
-     case OVS_KEY_ATTR_ARP:
-     case OVS_KEY_ATTR_ND:
-     case __OVS_KEY_ATTR_MAX:
-     default:
-        NOT_REACHED();
-    }
-}
-
-static void
 dp_netdev_execute_actions(struct dp_netdev *dp,
                           struct ofpbuf *packet, struct flow *key,
                           const struct nlattr *actions,
                           size_t actions_len)
 {
-    const struct nlattr *a;
-    unsigned int left;
-
-    NL_ATTR_FOR_EACH_UNSAFE (a, left, actions, actions_len) {
-        int type = nl_attr_type(a);
-
-        switch ((enum ovs_action_attr) type) {
-        case OVS_ACTION_ATTR_OUTPUT:
-            dp_netdev_output_port(dp, packet, nl_attr_get_u32(a));
-            break;
-
-        case OVS_ACTION_ATTR_USERSPACE:
-            dp_netdev_action_userspace(dp, packet, key, a);
-            break;
-
-        case OVS_ACTION_ATTR_PUSH_VLAN: {
-            const struct ovs_action_push_vlan *vlan = nl_attr_get(a);
-            eth_push_vlan(packet, vlan->vlan_tci);
-            break;
-        }
-
-        case OVS_ACTION_ATTR_POP_VLAN:
-            eth_pop_vlan(packet);
-            break;
-
-        case OVS_ACTION_ATTR_PUSH_MPLS: {
-            const struct ovs_action_push_mpls *mpls = nl_attr_get(a);
-            push_mpls(packet, mpls->mpls_ethertype, mpls->mpls_lse);
-            break;
-         }
-
-        case OVS_ACTION_ATTR_POP_MPLS:
-            pop_mpls(packet, nl_attr_get_be16(a));
-            break;
-
-        case OVS_ACTION_ATTR_SET:
-            execute_set_action(packet, nl_attr_get(a));
-            break;
-
-        case OVS_ACTION_ATTR_SAMPLE:
-            dp_netdev_sample(dp, packet, key, a);
-            break;
-
-        case OVS_ACTION_ATTR_UNSPEC:
-        case __OVS_ACTION_ATTR_MAX:
-            NOT_REACHED();
-        }
-    }
+    execute_actions(dp, packet, key, actions, actions_len,
+                    dp_netdev_output_port, dp_netdev_action_userspace);
 }
 
 const struct dpif_class dpif_netdev_class = {
diff --git a/lib/execute-actions.c b/lib/execute-actions.c
new file mode 100644
index 0000000..db57900
--- /dev/null
+++ b/lib/execute-actions.c
@@ -0,0 +1,196 @@
+/*
+ * Copyright (c) 2009, 2010, 2011, 2012, 2013 Nicira, Inc.
+ * Copyright (c) 2013 Simon Horman
+ *
+ * Licensed under the Apache License, Version 2.0 (the "License");
+ * you may not use this file except in compliance with the License.
+ * You may obtain a copy of the License at:
+ *
+ *     http://www.apache.org/licenses/LICENSE-2.0
+ *
+ * Unless required by applicable law or agreed to in writing, software
+ * distributed under the License is distributed on an "AS IS" BASIS,
+ * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
+ * See the License for the specific language governing permissions and
+ * limitations under the License.
+ */
+
+#include <config.h>
+#include <linux/openvswitch.h>
+#include <stdlib.h>
+#include <string.h>
+
+#include "execute-actions.h"
+#include "netlink.h"
+#include "packets.h"
+#include "util.h"
+
+static void
+eth_set_src_and_dst(struct ofpbuf *packet,
+                    const struct ovs_key_ethernet *eth_key)
+{
+    struct eth_header *eh = packet->l2;
+
+    memcpy(eh->eth_src, eth_key->eth_src, sizeof eh->eth_src);
+    memcpy(eh->eth_dst, eth_key->eth_dst, sizeof eh->eth_dst);
+}
+
+static void
+execute_set_action(struct ofpbuf *packet, const struct nlattr *a)
+{
+    enum ovs_key_attr type = nl_attr_type(a);
+    const struct ovs_key_ipv4 *ipv4_key;
+    const struct ovs_key_ipv6 *ipv6_key;
+    const struct ovs_key_tcp *tcp_key;
+    const struct ovs_key_udp *udp_key;
+
+    switch (type) {
+    case OVS_KEY_ATTR_PRIORITY:
+    case OVS_KEY_ATTR_TUNNEL:
+    case OVS_KEY_ATTR_SKB_MARK:
+        /* not implemented */
+        break;
+
+    case OVS_KEY_ATTR_ETHERNET:
+        eth_set_src_and_dst(packet,
+                   nl_attr_get_unspec(a, sizeof(struct ovs_key_ethernet)));
+        break;
+
+    case OVS_KEY_ATTR_IPV4:
+        ipv4_key = nl_attr_get_unspec(a, sizeof(struct ovs_key_ipv4));
+        packet_set_ipv4(packet, ipv4_key->ipv4_src, ipv4_key->ipv4_dst,
+                        ipv4_key->ipv4_tos, ipv4_key->ipv4_ttl);
+        break;
+
+    case OVS_KEY_ATTR_IPV6:
+        ipv6_key = nl_attr_get_unspec(a, sizeof(struct ovs_key_ipv6));
+        packet_set_ipv6(packet, ipv6_key->ipv6_proto, ipv6_key->ipv6_src,
+                        ipv6_key->ipv6_dst, ipv6_key->ipv6_tclass,
+                        ipv6_key->ipv6_label, ipv6_key->ipv6_hlimit);
+        break;
+
+    case OVS_KEY_ATTR_TCP:
+        tcp_key = nl_attr_get_unspec(a, sizeof(struct ovs_key_tcp));
+        packet_set_tcp_port(packet, tcp_key->tcp_src, tcp_key->tcp_dst);
+        break;
+
+     case OVS_KEY_ATTR_UDP:
+        udp_key = nl_attr_get_unspec(a, sizeof(struct ovs_key_udp));
+        packet_set_udp_port(packet, udp_key->udp_src, udp_key->udp_dst);
+        break;
+
+     case OVS_KEY_ATTR_MPLS:
+         set_mpls_lse(packet, nl_attr_get_be32(a));
+         break;
+
+     case OVS_KEY_ATTR_UNSPEC:
+     case OVS_KEY_ATTR_ENCAP:
+     case OVS_KEY_ATTR_ETHERTYPE:
+     case OVS_KEY_ATTR_IN_PORT:
+     case OVS_KEY_ATTR_VLAN:
+     case OVS_KEY_ATTR_ICMP:
+     case OVS_KEY_ATTR_ICMPV6:
+     case OVS_KEY_ATTR_ARP:
+     case OVS_KEY_ATTR_ND:
+     case __OVS_KEY_ATTR_MAX:
+     default:
+        NOT_REACHED();
+    }
+}
+
+static void
+execute_sample(void *dp, struct ofpbuf *packet, struct flow *key,
+               const struct nlattr *action,
+               void (*output)(void *dp, struct ofpbuf *packet,
+                              uint32_t out_port),
+               void (*userspace)(void *dp, struct ofpbuf *packet,
+                                 struct flow *key, const struct nlattr *a))
+{
+    const struct nlattr *subactions = NULL;
+    const struct nlattr *a;
+    size_t left;
+
+    NL_NESTED_FOR_EACH_UNSAFE (a, left, action) {
+        int type = nl_attr_type(a);
+
+        switch ((enum ovs_sample_attr) type) {
+        case OVS_SAMPLE_ATTR_PROBABILITY:
+            if (random_uint32() >= nl_attr_get_u32(a)) {
+                return;
+            }
+            break;
+
+        case OVS_SAMPLE_ATTR_ACTIONS:
+            subactions = a;
+            break;
+
+        case OVS_SAMPLE_ATTR_UNSPEC:
+        case __OVS_SAMPLE_ATTR_MAX:
+        default:
+            NOT_REACHED();
+        }
+    }
+
+    execute_actions(dp, packet, key, nl_attr_get(subactions),
+                    nl_attr_get_size(subactions), output, userspace);
+}
+
+void
+execute_actions(void *dp, struct ofpbuf *packet, struct flow *key,
+                const struct nlattr *actions, size_t actions_len,
+                void (*output)(void *dp, struct ofpbuf *packet,
+                               uint32_t out_port),
+                void (*userspace)(void *dp, struct ofpbuf *packet,
+                                  struct flow *key, const struct nlattr *a))
+{
+    const struct nlattr *a;
+    unsigned int left;
+
+    NL_ATTR_FOR_EACH_UNSAFE (a, left, actions, actions_len) {
+        int type = nl_attr_type(a);
+
+        switch ((enum ovs_action_attr) type) {
+        case OVS_ACTION_ATTR_OUTPUT:
+            ovs_assert(dp && output);
+            output(dp, packet, nl_attr_get_u32(a));
+            break;
+
+        case OVS_ACTION_ATTR_USERSPACE:
+            ovs_assert(dp && userspace && key);
+            userspace(dp, packet, key, a);
+            break;
+
+        case OVS_ACTION_ATTR_PUSH_VLAN: {
+            const struct ovs_action_push_vlan *vlan = nl_attr_get(a);
+            eth_push_vlan(packet, vlan->vlan_tci);
+            break;
+        }
+
+        case OVS_ACTION_ATTR_POP_VLAN:
+            eth_pop_vlan(packet);
+            break;
+
+        case OVS_ACTION_ATTR_PUSH_MPLS: {
+            const struct ovs_action_push_mpls *mpls = nl_attr_get(a);
+            push_mpls(packet, mpls->mpls_ethertype, mpls->mpls_lse);
+            break;
+         }
+
+        case OVS_ACTION_ATTR_POP_MPLS:
+            pop_mpls(packet, nl_attr_get_be16(a));
+            break;
+
+        case OVS_ACTION_ATTR_SET:
+            execute_set_action(packet, nl_attr_get(a));
+            break;
+
+        case OVS_ACTION_ATTR_SAMPLE:
+            execute_sample(dp, packet, key, a, output, userspace);
+            break;
+
+        case OVS_ACTION_ATTR_UNSPEC:
+        case __OVS_ACTION_ATTR_MAX:
+            NOT_REACHED();
+        }
+    }
+}
diff --git a/lib/execute-actions.h b/lib/execute-actions.h
new file mode 100644
index 0000000..7a62269
--- /dev/null
+++ b/lib/execute-actions.h
@@ -0,0 +1,32 @@
+/*
+ * Copyright (c) 2013 Nicira, Inc.
+ * Copyright (c) 2013 Simon Horman
+ *
+ * Licensed under the Apache License, Version 2.0 (the "License");
+ * you may not use this file except in compliance with the License.
+ * You may obtain a copy of the License at:
+ *
+ *     http://www.apache.org/licenses/LICENSE-2.0
+ *
+ * Unless required by applicable law or agreed to in writing, software
+ * distributed under the License is distributed on an "AS IS" BASIS,
+ * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
+ * See the License for the specific language governing permissions and
+ * limitations under the License.
+ */
+
+#ifndef EXECUTE_ACTIONS_H
+#define EXECUTE_ACTIONS_H 1
+
+#include "flow.h"
+#include "netlink-protocol.h"
+#include "ofpbuf.h"
+
+void
+execute_actions(void *dp, struct ofpbuf *packet, struct flow *key,
+                const struct nlattr *actions, size_t actions_len,
+                void (*output)(void *dp, struct ofpbuf *packet,
+                               uint32_t out_port),
+                void (*userspace)(void *dp, struct ofpbuf *packet,
+                                  struct flow *key, const struct nlattr *a));
+#endif
-- 
1.7.10.4
