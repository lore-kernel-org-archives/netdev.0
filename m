From: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 04/12] gre: export gre_handle_offloads()
	function.
Date: Thu, 13 Jun 2013 11:24:33 -0700
Message-ID: <1371147873-9245-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
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

This is required for OVS GRE offloading.

Signed-off-by: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 include/net/gre.h |    1 +
 net/ipv4/gre.c    |   29 +++++++++++++++++++++++++++++
 net/ipv4/ip_gre.c |   34 ++--------------------------------
 3 files changed, 32 insertions(+), 32 deletions(-)

diff --git a/include/net/gre.h b/include/net/gre.h
index cbb9d51..a5a4ddf 100644
--- a/include/net/gre.h
+++ b/include/net/gre.h
@@ -34,6 +34,7 @@ int gre_cisco_register(struct gre_cisco_protocol *proto);
 int gre_cisco_unregister(struct gre_cisco_protocol *proto);
 void gre_build_header(struct sk_buff *skb, const struct tnl_ptk_info *tpi,
 		      int hdr_len);
+struct sk_buff *gre_handle_offloads(struct sk_buff *skb, bool gre_csum);
 
 static inline int ip_gre_calc_hlen(__be16 o_flags)
 {
diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
index 1cbc465..5ecc9c4 100644
--- a/net/ipv4/gre.c
+++ b/net/ipv4/gre.c
@@ -93,6 +93,35 @@ void gre_build_header(struct sk_buff *skb, const struct tnl_ptk_info *tpi,
 }
 EXPORT_SYMBOL_GPL(gre_build_header);
 
+struct sk_buff *gre_handle_offloads(struct sk_buff *skb, bool gre_csum)
+{
+	int err;
+
+	if (likely(!skb->encapsulation)) {
+		skb_reset_inner_headers(skb);
+		skb->encapsulation = 1;
+	}
+
+	if (skb_is_gso(skb)) {
+		err = skb_unclone(skb, GFP_ATOMIC);
+		if (unlikely(err))
+			goto error;
+		skb_shinfo(skb)->gso_type |= SKB_GSO_GRE;
+		return skb;
+	} else if (skb->ip_summed == CHECKSUM_PARTIAL && gre_csum) {
+		err = skb_checksum_help(skb);
+		if (unlikely(err))
+			goto error;
+	} else if (skb->ip_summed != CHECKSUM_PARTIAL)
+		skb->ip_summed = CHECKSUM_NONE;
+
+	return skb;
+error:
+	kfree_skb(skb);
+	return ERR_PTR(err);
+}
+EXPORT_SYMBOL_GPL(gre_handle_offloads);
+
 static __sum16 check_checksum(struct sk_buff *skb)
 {
 	__sum16 csum = 0;
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 362c7c4..c326e86 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -223,31 +223,6 @@ static int ipgre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi)
 	return PACKET_REJECT;
 }
 
-static struct sk_buff *handle_offloads(struct ip_tunnel *tunnel, struct sk_buff *skb)
-{
-	int err;
-
-	if (skb_is_gso(skb)) {
-		err = skb_unclone(skb, GFP_ATOMIC);
-		if (unlikely(err))
-			goto error;
-		skb_shinfo(skb)->gso_type |= SKB_GSO_GRE;
-		return skb;
-	} else if (skb->ip_summed == CHECKSUM_PARTIAL &&
-		   tunnel->parms.o_flags&TUNNEL_CSUM) {
-		err = skb_checksum_help(skb);
-		if (unlikely(err))
-			goto error;
-	} else if (skb->ip_summed != CHECKSUM_PARTIAL)
-		skb->ip_summed = CHECKSUM_NONE;
-
-	return skb;
-
-error:
-	kfree_skb(skb);
-	return ERR_PTR(err);
-}
-
 static void __gre_xmit(struct sk_buff *skb, struct net_device *dev,
 		       const struct iphdr *tnl_params,
 		       __be16 proto)
@@ -255,11 +230,6 @@ static void __gre_xmit(struct sk_buff *skb, struct net_device *dev,
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	struct tnl_ptk_info tpi;
 
-	if (likely(!skb->encapsulation)) {
-		skb_reset_inner_headers(skb);
-		skb->encapsulation = 1;
-	}
-
 	tpi.flags = tunnel->parms.o_flags;
 	tpi.proto = proto;
 	tpi.key = tunnel->parms.o_key;
@@ -279,7 +249,7 @@ static netdev_tx_t ipgre_xmit(struct sk_buff *skb,
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	const struct iphdr *tnl_params;
 
-	skb = handle_offloads(tunnel, skb);
+	skb = gre_handle_offloads(skb, !!(tunnel->parms.o_flags&TUNNEL_CSUM));
 	if (IS_ERR(skb))
 		goto out;
 
@@ -318,7 +288,7 @@ static netdev_tx_t gre_tap_xmit(struct sk_buff *skb,
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 
-	skb = handle_offloads(tunnel, skb);
+	skb = gre_handle_offloads(skb, !!(tunnel->parms.o_flags&TUNNEL_CSUM));
 	if (IS_ERR(skb))
 		goto out;
 
-- 
1.7.1
