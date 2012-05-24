From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: [PATCH 14/21] ofproto: Set flow tun_key in
	compose_output_action()
Date: Thu, 24 May 2012 18:09:07 +0900
Message-ID: <1337850554-10339-15-git-send-email-horms@verge.net.au>
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

In essence this attached the tun_key, if any,
to the output processing of a packet. This allows
it the packet to be transmitted using flow-based
tunneling as necessary.

Cc: Kyle Mestery <kmestery-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>

---

v4
* Set tun_flags field of flow.tun_key
* Remove debugging message

v3
* Initial release

datapath: Add flags to ovs_key_ipv4_tunnel

Add flags to ovs_key_ipv4_tunnel and set from
the tunnel's realdev flags. This allows the datapath
to have access to flags on transmit which can be
used to effect the transmission - e.g. add a tunnel id.

Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
---
 ofproto/ofproto-dpif.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/ofproto/ofproto-dpif.c b/ofproto/ofproto-dpif.c
index 2a52f37..b1354a2 100644
--- a/ofproto/ofproto-dpif.c
+++ b/ofproto/ofproto-dpif.c
@@ -4919,8 +4919,17 @@ compose_output_action__(struct action_xlate_ctx *ctx, uint16_t ofp_port,
     }
 
     out_port = realdev_to_txdev(ctx->ofproto, ofport, ctx->flow.vlan_tci);
-    if (out_port != odp_port && !ofport->tun) {
-        ctx->flow.vlan_tci = htons(0);
+    if (out_port != odp_port) {
+        if (ofport->tun) {
+            ctx->flow.tun_key.tun_id = ofport->tun->s.out_key;
+            ctx->flow.tun_key.tun_flags = ofport->tun->s.flags;
+            ctx->flow.tun_key.ipv4_src = ofport->tun->s.saddr;
+            ctx->flow.tun_key.ipv4_dst = ofport->tun->s.daddr;
+            ctx->flow.tun_key.ipv4_tos = ofport->tun->s.tos;
+            ctx->flow.tun_key.ipv4_ttl = ofport->tun->s.ttl;
+        } else {
+            ctx->flow.vlan_tci = htons(0);
+        }
     }
     commit_odp_actions(&ctx->flow, &ctx->base_flow, ctx->odp_actions);
     nl_msg_put_u32(ctx->odp_actions, OVS_ACTION_ATTR_OUTPUT, out_port);
@@ -5576,7 +5585,7 @@ action_xlate_ctx_init(struct action_xlate_ctx *ctx,
     ctx->ofproto = ofproto;
     ctx->flow = *flow;
     ctx->base_flow = ctx->flow;
-    ctx->base_flow.tun_key.ipv4_src = 0;
+    ctx->base_flow.tun_key.ipv4_src = htonl(0);
     ctx->base_flow.vlan_tci = initial_tci;
     ctx->rule = rule;
     ctx->packet = packet;
-- 
1.7.10.2.484.gcd07cc5
