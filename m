From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: [PATCH 2/4] Move execute_set_action to lib/odp-util.c
Date: Mon,  8 Apr 2013 15:43:49 +0900
Message-ID: <1365403431-18102-3-git-send-email-horms@verge.net.au>
References: <1365403431-18102-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Isaku Yamahata <yamahata-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1365403431-18102-1-git-send-email-horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
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

Move execute_set_action from lib/dpif-netedev.c to lib/odp-util.c

This is in preparation for using execute_set_action()
in lib/odp-util.c to handle recirculation/

Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>

---

packet.c might be a better place for execute_set_action()
but I'm unsure if accessing struct ovs_key_ethernet would
lead to a layering violation.

This patch depends on the patch "Add packet recirculation"

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
---
 lib/dpif-netdev.c |   76 -----------------------------------------------------
 lib/odp-util.c    |   76 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 lib/odp-util.h    |    3 +++
 3 files changed, 79 insertions(+), 76 deletions(-)

diff --git a/lib/dpif-netdev.c b/lib/dpif-netdev.c
index 31255f6..e698e1e 100644
--- a/lib/dpif-netdev.c
+++ b/lib/dpif-netdev.c
@@ -1115,15 +1115,6 @@ dpif_netdev_wait(struct dpif *dpif)
 }
 
 static void
-dp_netdev_set_dl(struct ofpbuf *packet, const struct ovs_key_ethernet *eth_key)
-{
-    struct eth_header *eh = packet->l2;
-
-    memcpy(eh->eth_src, eth_key->eth_src, sizeof eh->eth_src);
-    memcpy(eh->eth_dst, eth_key->eth_dst, sizeof eh->eth_dst);
-}
-
-static void
 dp_netdev_output_port(struct dp_netdev *dp, struct ofpbuf *packet,
                       uint32_t out_port)
 {
@@ -1228,73 +1219,6 @@ dp_netdev_action_userspace(struct dp_netdev *dp,
     dp_netdev_output_userspace(dp, packet, DPIF_UC_ACTION, key, userdata);
 }
 
-static void
-execute_set_action(struct ofpbuf *packet, const struct nlattr *a,
-                   uint32_t *skb_mark)
-{
-    enum ovs_key_attr type = nl_attr_type(a);
-    const struct ovs_key_ipv4 *ipv4_key;
-    const struct ovs_key_ipv6 *ipv6_key;
-    const struct ovs_key_tcp *tcp_key;
-    const struct ovs_key_udp *udp_key;
-
-    switch (type) {
-    case OVS_KEY_ATTR_PRIORITY:
-    case OVS_KEY_ATTR_TUNNEL:
-        /* not implemented */
-        break;
-
-    case OVS_KEY_ATTR_SKB_MARK:
-        *skb_mark = nl_attr_get_u32(a);
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
 static bool
 dp_netdev_execute_actions(struct dp_netdev *dp,
                           struct ofpbuf *packet, struct flow *key,
diff --git a/lib/odp-util.c b/lib/odp-util.c
index e18e109..ad5873c 100644
--- a/lib/odp-util.c
+++ b/lib/odp-util.c
@@ -2420,3 +2420,79 @@ commit_odp_actions(const struct flow *flow, struct flow *base,
     commit_set_priority_action(flow, base, odp_actions);
     commit_set_skb_mark_action(flow, base, odp_actions);
 }
+
+static void
+dp_netdev_set_dl(struct ofpbuf *packet, const struct ovs_key_ethernet *eth_key)
+{
+    struct eth_header *eh = packet->l2;
+
+    memcpy(eh->eth_src, eth_key->eth_src, sizeof eh->eth_src);
+    memcpy(eh->eth_dst, eth_key->eth_dst, sizeof eh->eth_dst);
+}
+
+void
+execute_set_action(struct ofpbuf *packet, const struct nlattr *a,
+                   uint32_t *skb_mark)
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
+        /* not implemented */
+        break;
+
+    case OVS_KEY_ATTR_SKB_MARK:
+        *skb_mark = nl_attr_get_u32(a);
+        break;
+
+    case OVS_KEY_ATTR_ETHERNET:
+        dp_netdev_set_dl(packet,
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
diff --git a/lib/odp-util.h b/lib/odp-util.h
index da62aa5..637d6a5 100644
--- a/lib/odp-util.h
+++ b/lib/odp-util.h
@@ -159,6 +159,9 @@ void odp_put_tunnel_action(const struct flow_tnl *tunnel,
 void odp_put_skb_mark_action(const uint32_t skb_mark,
                              struct ofpbuf *odp_actions);
 
+void execute_set_action(struct ofpbuf *packet, const struct nlattr *a,
+                        uint32_t *skb_mark);
+
 /* Reasons why a subfacet might not be fast-pathable. */
 enum slow_path_reason {
     /* These reasons are mutually exclusive. */
-- 
1.7.10.4
