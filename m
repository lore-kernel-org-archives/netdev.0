From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: [PATCH 18/21] dataptah: remove ttl and tos from
	tnl_mutable_config
Date: Thu, 24 May 2012 18:09:11 +0900
Message-ID: <1337850554-10339-19-git-send-email-horms@verge.net.au>
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

tun_key should always be present and correct in ovs_tnl_send()

It ought to be possible to handle the ttl entirely
in user-space. This is not implemented yet. However, the
TNL_F_TOS_INHERIT is currently never set.

Cc: Kyle Mestery <kmestery-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
---
 datapath/tunnel.c | 10 ++--------
 datapath/tunnel.h |  4 ----
 2 files changed, 2 insertions(+), 12 deletions(-)

diff --git a/datapath/tunnel.c b/datapath/tunnel.c
index ba18055..39aa2af 100644
--- a/datapath/tunnel.c
+++ b/datapath/tunnel.c
@@ -900,10 +900,8 @@ int ovs_tnl_send(struct vport *vport, struct sk_buff *skb)
 
 	if (mutable->flags & TNL_F_TOS_INHERIT)
 		tos = inner_tos;
-	else if (OVS_CB(skb)->tun_key)
-		tos = OVS_CB(skb)->tun_key->ipv4_tos;
 	else
-		tos = mutable->tos;
+		tos = OVS_CB(skb)->tun_key->ipv4_tos;
 
 	/* Route lookup */
 	rt = find_route(vport, port_key_get_net(&mutable->key),
@@ -940,11 +938,7 @@ int ovs_tnl_send(struct vport *vport, struct sk_buff *skb)
 		dst_hold(unattached_dst);
 	}
 
-	/* TTL */
-	if (OVS_CB(skb)->tun_key)
-		ttl = OVS_CB(skb)->tun_key->ipv4_ttl;
-	else
-		ttl = mutable->ttl;
+	ttl = OVS_CB(skb)->tun_key->ipv4_ttl;
 	if (!ttl)
 		ttl = ip4_dst_hoplimit(&rt_dst(rt));
 	if (mutable->flags & TNL_F_TTL_INHERIT) {
diff --git a/datapath/tunnel.h b/datapath/tunnel.h
index ed3b4ec..330df27 100644
--- a/datapath/tunnel.h
+++ b/datapath/tunnel.h
@@ -99,8 +99,6 @@ static inline void port_key_set_net(struct port_lookup_key *key, struct net *net
  * (e.g. ICMP fragmentation needed messages).
  * @out_key: Key to use on output, 0 if this tunnel has no fixed output key.
  * @flags: TNL_F_* flags.
- * @tos: IPv4 TOS value to use for tunnel, 0 if no fixed TOS.
- * @ttl: IPv4 TTL value to use for tunnel, 0 if no fixed TTL.
  */
 struct tnl_mutable_config {
 	struct port_lookup_key key;
@@ -115,8 +113,6 @@ struct tnl_mutable_config {
 	/* Configured via OVS_TUNNEL_ATTR_* attributes. */
 	__be64	out_key;
 	u32	flags;
-	u8	tos;
-	u8	ttl;
 };
 
 struct tnl_ops {
-- 
1.7.10.2.484.gcd07cc5
