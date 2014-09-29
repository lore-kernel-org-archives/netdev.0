From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 31/34] netfilter: bridge: nf_bridge_copy_header as static inline in header
Date: Mon, 29 Sep 2014 14:39:20 +0200
Message-ID: <1411994363-8451-32-git-send-email-pablo@netfilter.org>
References: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34385 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754293AbaI2MjA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2014 08:39:00 -0400
In-Reply-To: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move nf_bridge_copy_header() as static inline in netfilter_bridge.h
header file. This patch prepares the modularization of the br_netfilter
code.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter_bridge.h |   48 ++++++++++++++++++++++++++++++--------
 net/bridge/br_netfilter.c        |   28 ----------------------
 2 files changed, 38 insertions(+), 38 deletions(-)

diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index 8ab1c27..fe996d5 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -24,16 +24,6 @@ enum nf_br_hook_priorities {
 #define BRNF_8021Q			0x10
 #define BRNF_PPPoE			0x20
 
-/* Only used in br_forward.c */
-int nf_bridge_copy_header(struct sk_buff *skb);
-static inline int nf_bridge_maybe_copy_header(struct sk_buff *skb)
-{
-	if (skb->nf_bridge &&
-	    skb->nf_bridge->mask & (BRNF_BRIDGED | BRNF_BRIDGED_DNAT))
-		return nf_bridge_copy_header(skb);
-  	return 0;
-}
-
 static inline unsigned int nf_bridge_encap_header_len(const struct sk_buff *skb)
 {
 	switch (skb->protocol) {
@@ -46,6 +36,44 @@ static inline unsigned int nf_bridge_encap_header_len(const struct sk_buff *skb)
 	}
 }
 
+static inline void nf_bridge_update_protocol(struct sk_buff *skb)
+{
+	if (skb->nf_bridge->mask & BRNF_8021Q)
+		skb->protocol = htons(ETH_P_8021Q);
+	else if (skb->nf_bridge->mask & BRNF_PPPoE)
+		skb->protocol = htons(ETH_P_PPP_SES);
+}
+
+/* Fill in the header for fragmented IP packets handled by
+ * the IPv4 connection tracking code.
+ *
+ * Only used in br_forward.c
+ */
+static inline int nf_bridge_copy_header(struct sk_buff *skb)
+{
+	int err;
+	unsigned int header_size;
+
+	nf_bridge_update_protocol(skb);
+	header_size = ETH_HLEN + nf_bridge_encap_header_len(skb);
+	err = skb_cow_head(skb, header_size);
+	if (err)
+		return err;
+
+	skb_copy_to_linear_data_offset(skb, -header_size,
+				       skb->nf_bridge->data, header_size);
+	__skb_push(skb, nf_bridge_encap_header_len(skb));
+	return 0;
+}
+
+static inline int nf_bridge_maybe_copy_header(struct sk_buff *skb)
+{
+	if (skb->nf_bridge &&
+	    skb->nf_bridge->mask & (BRNF_BRIDGED | BRNF_BRIDGED_DNAT))
+		return nf_bridge_copy_header(skb);
+  	return 0;
+}
+
 static inline unsigned int nf_bridge_mtu_reduction(const struct sk_buff *skb)
 {
 	if (unlikely(skb->nf_bridge->mask & BRNF_PPPoE))
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index a615264..61929a7 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -245,14 +245,6 @@ static inline void nf_bridge_save_header(struct sk_buff *skb)
 					 skb->nf_bridge->data, header_size);
 }
 
-static inline void nf_bridge_update_protocol(struct sk_buff *skb)
-{
-	if (skb->nf_bridge->mask & BRNF_8021Q)
-		skb->protocol = htons(ETH_P_8021Q);
-	else if (skb->nf_bridge->mask & BRNF_PPPoE)
-		skb->protocol = htons(ETH_P_PPP_SES);
-}
-
 /* When handing a packet over to the IP layer
  * check whether we have a skb that is in the
  * expected format
@@ -320,26 +312,6 @@ drop:
 	return -1;
 }
 
-/* Fill in the header for fragmented IP packets handled by
- * the IPv4 connection tracking code.
- */
-int nf_bridge_copy_header(struct sk_buff *skb)
-{
-	int err;
-	unsigned int header_size;
-
-	nf_bridge_update_protocol(skb);
-	header_size = ETH_HLEN + nf_bridge_encap_header_len(skb);
-	err = skb_cow_head(skb, header_size);
-	if (err)
-		return err;
-
-	skb_copy_to_linear_data_offset(skb, -header_size,
-				       skb->nf_bridge->data, header_size);
-	__skb_push(skb, nf_bridge_encap_header_len(skb));
-	return 0;
-}
-
 /* PF_BRIDGE/PRE_ROUTING *********************************************/
 /* Undo the changes made for ip6tables PREROUTING and continue the
  * bridge PRE_ROUTING hook. */
-- 
1.7.10.4
