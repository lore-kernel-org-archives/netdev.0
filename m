From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 2/3] net: factor out skb_mac_gso_segment() from skb_gso_segment()
Date: Thu, 14 Feb 2013 11:44:55 -0800
Message-ID: <1360871095-2053-1-git-send-email-pshelar@nicira.com>
Cc: edumazet@google.com, jesse@nicira.com, bhutchings@solarflare.com,
	mirqus@gmail.com, Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog117.obsmtp.com ([74.125.149.242]:59801 "HELO
	na3sys009aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S935136Ab3BOADx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 19:03:53 -0500
Received: by mail-ie0-f199.google.com with SMTP id c13so14723605ieb.2
        for <netdev@vger.kernel.org>; Thu, 14 Feb 2013 16:03:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function will be used in next GRE_GSO patch. This patch does
not change any functionality. It only exports skb_mac_gso_segment()
function.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 include/linux/netdevice.h |    2 +
 net/core/dev.c            |   79 +++++++++++++++++++++++++++-----------------
 2 files changed, 50 insertions(+), 31 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9deb672..920361b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2671,6 +2671,8 @@ extern void netdev_upper_dev_unlink(struct net_device *dev,
 extern int skb_checksum_help(struct sk_buff *skb);
 extern struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
 	netdev_features_t features, bool tx_path);
+extern struct sk_buff *skb_mac_gso_segment(struct sk_buff *skb,
+					  netdev_features_t features);
 
 static inline
 struct sk_buff *skb_gso_segment(struct sk_buff *skb, netdev_features_t features)
diff --git a/net/core/dev.c b/net/core/dev.c
index 2f31bf9..5425e41 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2327,37 +2327,20 @@ out:
 }
 EXPORT_SYMBOL(skb_checksum_help);
 
-/* openvswitch calls this on rx path, so we need a different check.
- */
-static inline bool skb_needs_check(struct sk_buff *skb, bool tx_path)
-{
-	if (tx_path)
-		return skb->ip_summed != CHECKSUM_PARTIAL;
-	else
-		return skb->ip_summed == CHECKSUM_NONE;
-}
-
 /**
- *	__skb_gso_segment - Perform segmentation on skb.
+ *	skb_mac_gso_segment - mac layer segmentation handler.
  *	@skb: buffer to segment
  *	@features: features for the output path (see dev->features)
- *	@tx_path: whether it is called in TX path
- *
- *	This function segments the given skb and returns a list of segments.
- *
- *	It may return NULL if the skb requires no segmentation.  This is
- *	only possible when GSO is used for verifying header integrity.
  */
-struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
-				  netdev_features_t features, bool tx_path)
+struct sk_buff *skb_mac_gso_segment(struct sk_buff *skb,
+				    netdev_features_t features)
 {
 	struct sk_buff *segs = ERR_PTR(-EPROTONOSUPPORT);
 	struct packet_offload *ptype;
 	__be16 type = skb->protocol;
-	int vlan_depth = ETH_HLEN;
-	int err;
 
 	while (type == htons(ETH_P_8021Q)) {
+		int vlan_depth = ETH_HLEN;
 		struct vlan_hdr *vh;
 
 		if (unlikely(!pskb_may_pull(skb, vlan_depth + VLAN_HLEN)))
@@ -2368,22 +2351,14 @@ struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
 		vlan_depth += VLAN_HLEN;
 	}
 
-	skb_reset_mac_header(skb);
-	skb->mac_len = skb->network_header - skb->mac_header;
 	__skb_pull(skb, skb->mac_len);
 
-	if (unlikely(skb_needs_check(skb, tx_path))) {
-		skb_warn_bad_offload(skb);
-
-		if (skb_header_cloned(skb) &&
-		    (err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
-			return ERR_PTR(err);
-	}
-
 	rcu_read_lock();
 	list_for_each_entry_rcu(ptype, &offload_base, list) {
 		if (ptype->type == type && ptype->callbacks.gso_segment) {
 			if (unlikely(skb->ip_summed != CHECKSUM_PARTIAL)) {
+				int err;
+
 				err = ptype->callbacks.gso_send_check(skb);
 				segs = ERR_PTR(err);
 				if (err || skb_gso_ok(skb, features))
@@ -2401,6 +2376,48 @@ struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
 
 	return segs;
 }
+EXPORT_SYMBOL(skb_mac_gso_segment);
+
+
+/* openvswitch calls this on rx path, so we need a different check.
+ */
+static inline bool skb_needs_check(struct sk_buff *skb, bool tx_path)
+{
+	if (tx_path)
+		return skb->ip_summed != CHECKSUM_PARTIAL;
+	else
+		return skb->ip_summed == CHECKSUM_NONE;
+}
+
+/**
+ *	__skb_gso_segment - Perform segmentation on skb.
+ *	@skb: buffer to segment
+ *	@features: features for the output path (see dev->features)
+ *	@tx_path: whether it is called in TX path
+ *
+ *	This function segments the given skb and returns a list of segments.
+ *
+ *	It may return NULL if the skb requires no segmentation.  This is
+ *	only possible when GSO is used for verifying header integrity.
+ */
+struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
+				  netdev_features_t features, bool tx_path)
+{
+	if (unlikely(skb_needs_check(skb, tx_path))) {
+		int err;
+
+		skb_warn_bad_offload(skb);
+
+		if (skb_header_cloned(skb) &&
+		    (err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
+			return ERR_PTR(err);
+	}
+
+	skb_reset_mac_header(skb);
+	skb->mac_len = skb->network_header - skb->mac_header;
+
+	return skb_mac_gso_segment(skb, features);
+}
 EXPORT_SYMBOL(__skb_gso_segment);
 
 /* Take action when hardware reception checksum errors are detected. */
-- 
1.7.1
