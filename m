From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next] net: add skb functions to process remote checksum offload
Date: Mon,  2 Feb 2015 16:07:34 -0800
Message-ID: <1422922054-22996-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:43106 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755489AbbBCAHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 19:07:43 -0500
Received: by mail-ie0-f181.google.com with SMTP id rd18so12271948iec.12
        for <netdev@vger.kernel.org>; Mon, 02 Feb 2015 16:07:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds skb_remcsum_process and skb_gro_remcsum_process to
perform the appropriate adjustments to the skb when receiving
remote checksum offload.

Updated vxlan and gue to use these functions.

Tested: Ran TCP_RR and TCP_STREAM netperf for VXLAN and GUE, did
not see any change in performance.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/vxlan.c       | 18 ++----------------
 include/linux/netdevice.h | 15 +++++++++++++++
 include/linux/skbuff.h    | 21 +++++++++++++++++++++
 net/ipv4/fou.c            | 18 ++----------------
 4 files changed, 40 insertions(+), 32 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 19d3664..ffea961 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -556,7 +556,6 @@ static struct vxlanhdr *vxlan_gro_remcsum(struct sk_buff *skb,
 					  u32 data)
 {
 	size_t start, offset, plen;
-	__wsum delta;
 
 	if (skb->remcsum_offload)
 		return vh;
@@ -578,12 +577,7 @@ static struct vxlanhdr *vxlan_gro_remcsum(struct sk_buff *skb,
 			return NULL;
 	}
 
-	delta = remcsum_adjust((void *)vh + hdrlen,
-			       NAPI_GRO_CB(skb)->csum, start, offset);
-
-	/* Adjust skb->csum since we changed the packet */
-	skb->csum = csum_add(skb->csum, delta);
-	NAPI_GRO_CB(skb)->csum = csum_add(NAPI_GRO_CB(skb)->csum, delta);
+	skb_gro_remcsum_process(skb, (void *)vh + hdrlen, start, offset);
 
 	skb->remcsum_offload = 1;
 
@@ -1157,7 +1151,6 @@ static struct vxlanhdr *vxlan_remcsum(struct sk_buff *skb, struct vxlanhdr *vh,
 				      size_t hdrlen, u32 data)
 {
 	size_t start, offset, plen;
-	__wsum delta;
 
 	if (skb->remcsum_offload) {
 		/* Already processed in GRO path */
@@ -1177,14 +1170,7 @@ static struct vxlanhdr *vxlan_remcsum(struct sk_buff *skb, struct vxlanhdr *vh,
 
 	vh = (struct vxlanhdr *)(udp_hdr(skb) + 1);
 
-	if (unlikely(skb->ip_summed != CHECKSUM_COMPLETE))
-		__skb_checksum_complete(skb);
-
-	delta = remcsum_adjust((void *)vh + hdrlen,
-			       skb->csum, start, offset);
-
-	/* Adjust skb->csum since we changed the packet */
-	skb->csum = csum_add(skb->csum, delta);
+	skb_remcsum_process(skb, (void *)vh + hdrlen, start, offset);
 
 	return vh;
 }
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 642d426..38af7b3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2314,6 +2314,21 @@ do {									\
 					   compute_pseudo(skb, proto));	\
 } while (0)
 
+static inline void skb_gro_remcsum_process(struct sk_buff *skb, void *ptr,
+					   int start, int offset)
+{
+	__wsum delta;
+
+	BUG_ON(!NAPI_GRO_CB(skb)->csum_valid);
+
+	delta = remcsum_adjust(ptr, NAPI_GRO_CB(skb)->csum, start, offset);
+
+	/* Adjust skb->csum since we changed the packet */
+	skb->csum = csum_add(skb->csum, delta);
+	NAPI_GRO_CB(skb)->csum = csum_add(NAPI_GRO_CB(skb)->csum, delta);
+}
+
+
 static inline int dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 				  unsigned short type,
 				  const void *daddr, const void *saddr,
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 85ab7d7..67f8b76 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3096,6 +3096,27 @@ do {									\
 				       compute_pseudo(skb, proto));	\
 } while (0)
 
+/* Update skbuf and packet to reflect the remote checksum offload operation.
+ * When called, ptr indicates the starting point for skb->csum when
+ * ip_summed is CHECKSUM_COMPLETE. If we need create checksum complete
+ * here, skb_postpull_rcsum is done so skb->csum start is ptr.
+ */
+static inline void skb_remcsum_process(struct sk_buff *skb, void *ptr,
+				       int start, int offset)
+{
+	__wsum delta;
+
+	 if (unlikely(skb->ip_summed != CHECKSUM_COMPLETE)) {
+		__skb_checksum_complete(skb);
+		skb_postpull_rcsum(skb, skb->data, ptr - (void *)skb->data);
+	}
+
+	delta = remcsum_adjust(ptr, skb->csum, start, offset);
+
+	/* Adjust skb->csum since we changed the packet */
+	skb->csum = csum_add(skb->csum, delta);
+}
+
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 void nf_conntrack_destroy(struct nf_conntrack *nfct);
 static inline void nf_conntrack_put(struct nf_conntrack *nfct)
diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index 3bc0cf0..92ddea1 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -70,7 +70,6 @@ static struct guehdr *gue_remcsum(struct sk_buff *skb, struct guehdr *guehdr,
 	size_t start = ntohs(pd[0]);
 	size_t offset = ntohs(pd[1]);
 	size_t plen = hdrlen + max_t(size_t, offset + sizeof(u16), start);
-	__wsum delta;
 
 	if (skb->remcsum_offload) {
 		/* Already processed in GRO path */
@@ -82,14 +81,7 @@ static struct guehdr *gue_remcsum(struct sk_buff *skb, struct guehdr *guehdr,
 		return NULL;
 	guehdr = (struct guehdr *)&udp_hdr(skb)[1];
 
-	if (unlikely(skb->ip_summed != CHECKSUM_COMPLETE))
-		__skb_checksum_complete(skb);
-
-	delta = remcsum_adjust((void *)guehdr + hdrlen,
-			       skb->csum, start, offset);
-
-	/* Adjust skb->csum since we changed the packet */
-	skb->csum = csum_add(skb->csum, delta);
+	skb_remcsum_process(skb, (void *)guehdr + hdrlen, start, offset);
 
 	return guehdr;
 }
@@ -228,7 +220,6 @@ static struct guehdr *gue_gro_remcsum(struct sk_buff *skb, unsigned int off,
 	size_t start = ntohs(pd[0]);
 	size_t offset = ntohs(pd[1]);
 	size_t plen = hdrlen + max_t(size_t, offset + sizeof(u16), start);
-	__wsum delta;
 
 	if (skb->remcsum_offload)
 		return guehdr;
@@ -243,12 +234,7 @@ static struct guehdr *gue_gro_remcsum(struct sk_buff *skb, unsigned int off,
 			return NULL;
 	}
 
-	delta = remcsum_adjust((void *)guehdr + hdrlen,
-			       NAPI_GRO_CB(skb)->csum, start, offset);
-
-	/* Adjust skb->csum since we changed the packet */
-	skb->csum = csum_add(skb->csum, delta);
-	NAPI_GRO_CB(skb)->csum = csum_add(NAPI_GRO_CB(skb)->csum, delta);
+	skb_gro_remcsum_process(skb, (void *)guehdr + hdrlen, start, offset);
 
 	skb->remcsum_offload = 1;
 
-- 
2.2.0.rc0.207.ga3a616c
