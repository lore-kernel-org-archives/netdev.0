From: Tom Herbert <therbert@google.com>
Subject: [PATCH 3/4 v3] net: Add function to set the rxhash
Date: Sun, 15 Dec 2013 22:16:19 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1312152213370.20516@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f201.google.com ([209.85.214.201]:65466 "EHLO
	mail-ob0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750781Ab3LPGQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 01:16:20 -0500
Received: by mail-ob0-f201.google.com with SMTP id wp4so868784obc.0
        for <netdev@vger.kernel.org>; Sun, 15 Dec 2013 22:16:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function skb_set_rxash was added for drivers to call to set
the rxhash in an skb. The type of hash is also specified as
a parameter (L2, L3, L4, or unknown type).

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/skbuff.h | 40 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 40 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 7deb7ad..9984695 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -703,6 +703,46 @@ unsigned int skb_find_text(struct sk_buff *skb, unsigned int from,
 			   unsigned int to, struct ts_config *config,
 			   struct ts_state *state);
 
+/*
+ * Packet hash types specify the type of hash in skb_set_hash.
+ *
+ * Hash types refer to the protocol layer addresses which are used to
+ * construct a packet's hash. The hashes are used to differentiate or identify
+ * flows of the protocol layer for the hash type. Hash types are either
+ * layer-2 (L2), layer-3 (L3), or layer-4 (L4).
+ *
+ * Properties of hashes:
+ *
+ * 1) Two packets in different flows have different hash values
+ * 2) Two packets in the same flow should have the same hash value
+ *
+ * A hash at a higher layer is considered to be more specific. A driver should
+ * set the most specific hash possible.
+ *
+ * A driver cannot indicate a more specific hash than the layer at which a hash
+ * was computed. For instance an L3 hash cannot be set as an L4 hash.
+ *
+ * A driver may indicate a hash level which is less specific than the
+ * actual layer the hash was computed on. For instance, a hash computed
+ * at L4 may be considered an L3 hash. This should only be done if the
+ * driver can't unambiguously determine that the HW computed the hash at
+ * the higher layer. Note that the "should" in the second property above
+ * permits this.
+ */
+enum pkt_hash_types {
+	PKT_HASH_TYPE_NONE,	/* Undefined type */
+	PKT_HASH_TYPE_L2,	/* Input: src_MAC, dest_MAC */
+	PKT_HASH_TYPE_L3,	/* Input: src_IP, dst_IP */
+	PKT_HASH_TYPE_L4,	/* Input: src_IP, dst_IP, src_port, dst_port */
+};
+
+static inline void
+skb_set_hash(struct sk_buff *skb, __u32 hash, enum pkt_hash_types type)
+{
+	skb->l4_rxhash = (type == PKT_HASH_TYPE_L4);
+	skb->rxhash = hash;
+}
+
 void __skb_get_hash(struct sk_buff *skb);
 static inline __u32 skb_get_hash(struct sk_buff *skb)
 {
-- 
1.8.5.1
