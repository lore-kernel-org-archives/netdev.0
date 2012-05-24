From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 08/21] ofproto: Add realdev_to_txdev()
Date: Thu, 24 May 2012 18:09:01 +0900
Message-ID: <1337850554-10339-9-git-send-email-horms@verge.net.au>
References: <1337850554-10339-1-git-send-email-horms@verge.net.au>
Cc: netdev@vger.kernel.org, Kyle Mestery <kmestery@cisco.com>,
	Simon Horman <horms@verge.net.au>
To: dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:46690 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754338Ab2EXJJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2012 05:09:25 -0400
In-Reply-To: <1337850554-10339-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is used to map a tunnel or VLAN realdevs to
tundev and vlandevs respectively. This is used
on transmit to map fromt the interface used
in user-space to the interface used in the datapath.

In the case where an interface is not a tunnel
and does not have VLAN splinters configured
a identity map is made.

Cc: Kyle Mestery <kmestery@cisco.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 ofproto/ofproto-dpif.c | 31 +++++++++++++++++++++++--------
 1 file changed, 23 insertions(+), 8 deletions(-)

diff --git a/ofproto/ofproto-dpif.c b/ofproto/ofproto-dpif.c
index 642b508..c7ea391 100644
--- a/ofproto/ofproto-dpif.c
+++ b/ofproto/ofproto-dpif.c
@@ -539,8 +539,6 @@ struct vlan_splinter {
     int vid;
 };
 
-static uint32_t vsp_realdev_to_vlandev(const struct ofproto_dpif *,
-                                       uint32_t realdev, ovs_be16 vlan_tci);
 static bool vsp_adjust_flow(const struct ofproto_dpif *, struct flow *);
 static void vsp_remove(struct ofport_dpif *);
 static void vsp_add(struct ofport_dpif *, uint16_t realdev_ofp_port, int vid);
@@ -555,6 +553,10 @@ static unsigned multicast_ports;
 static int set_tunnelling(struct ofport *ofport_, uint16_t realdev_ofp_port,
                           const struct tunnel_settings *s);
 
+static uint32_t
+realdev_to_txdev(const struct ofproto_dpif *ofproto,
+                 const struct ofport_dpif *ofport, ovs_be16 vlan_tci);
+
 static struct ofport_dpif *
 ofport_dpif_cast(const struct ofport *ofport)
 {
@@ -4700,9 +4702,8 @@ send_packet(const struct ofport_dpif *ofport, struct ofpbuf *packet)
     int error;
 
     flow_extract((struct ofpbuf *) packet, 0, 0, 0, &flow);
-    odp_port = vsp_realdev_to_vlandev(ofproto, ofport->odp_port,
-                                      flow.vlan_tci);
-    if (odp_port != ofport->odp_port) {
+    odp_port = realdev_to_txdev(ofproto, ofport, flow.vlan_tci);
+    if (odp_port != ofport->odp_port && !ofport->tun) {
         eth_pop_vlan(packet);
         flow.vlan_tci = htons(0);
     }
@@ -4909,9 +4910,8 @@ compose_output_action__(struct action_xlate_ctx *ctx, uint16_t ofp_port,
          * later and we're pre-populating the flow table.  */
     }
 
-    out_port = vsp_realdev_to_vlandev(ctx->ofproto, odp_port,
-                                      ctx->flow.vlan_tci);
-    if (out_port != odp_port) {
+    out_port = realdev_to_txdev(ctx->ofproto, ofport, ctx->flow.vlan_tci);
+    if (out_port != odp_port && !ofport->tun) {
         ctx->flow.vlan_tci = htons(0);
     }
     commit_odp_actions(&ctx->flow, &ctx->base_flow, ctx->odp_actions);
@@ -7211,6 +7211,21 @@ set_tunnelling(struct ofport *ofport_, uint16_t tundev_ofp_port,
 
     return 0;
 }
+
+/* Maps a port to the port that it should be transmitted on.
+ * If tunneling is enabled then the associated tunnel port is returned.
+ * If VLAN splintering is enabled then the ofp_port of the vlandev is
+ * returned.
+ * Otherwise no mapping is in effect and ofport->odp_port is returned. */
+static uint32_t
+realdev_to_txdev(const struct ofproto_dpif *ofproto,
+                 const struct ofport_dpif *ofport, ovs_be16 vlan_tci)
+{
+    if (ofport->tun) {
+        return ofp_port_to_odp_port(ofport->tun->tundev_ofp_port);
+    }
+    return vsp_realdev_to_vlandev(ofproto, ofport->odp_port, vlan_tci);
+}
 
 const struct ofproto_class ofproto_dpif_class = {
     enumerate_types,
-- 
1.7.10.2.484.gcd07cc5
