From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 1/7] net: Fix remcsum in GRO path to not change packet
Date: Tue, 10 Feb 2015 16:30:27 -0800
Message-ID: <1423614633-25042-2-git-send-email-therbert@google.com>
References: <1423614633-25042-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:54620 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752071AbbBKAaq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 19:30:46 -0500
Received: by mail-ig0-f179.google.com with SMTP id l13so1317644iga.0
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2015 16:30:45 -0800 (PST)
In-Reply-To: <1423614633-25042-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remote checksum offload processing is currently the same for both
the GRO and non-GRO path. When the remote checksum offload option
is encountered, the checksum field referred to is modified in
the packet. So in the GRO case, the packet is modified in the
GRO path and then the operation is skipped when the packet goes
through the normal path based on skb->remcsum_offload. There is
a problem in that the packet may be modified in the GRO path, but
then forwarded off host still containing the remote checksum option.
A remote host will again perform RCO but now the checksum verification
will fail since GRO RCO already modified the checksum.

To fix this, we ensure that GRO restores a packet to it's original
state before returning. In this model, when GRO processes a remote
checksum option it still changes the checksum per the algorithm
but on return from lower layer processing the checksum is restored
to its original value.

In this patch we add define gro_remcsum structure which is passed
to skb_gro_remcsum_process to save offset and delta for the checksum
being changed. After lower layer processing, skb_gro_remcsum_cleanup
is called to restore the checksum before returning from GRO.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/vxlan.c       | 19 +++++++++----------
 include/linux/netdevice.h | 25 +++++++++++++++++++++++--
 include/net/checksum.h    |  5 +++++
 net/ipv4/fou.c            | 20 ++++++++++----------
 4 files changed, 47 insertions(+), 22 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 0e57e86..30310a6 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -555,12 +555,12 @@ static int vxlan_fdb_append(struct vxlan_fdb *f,
 static struct vxlanhdr *vxlan_gro_remcsum(struct sk_buff *skb,
 					  unsigned int off,
 					  struct vxlanhdr *vh, size_t hdrlen,
-					  u32 data)
+					  u32 data, struct gro_remcsum *grc)
 {
 	size_t start, offset, plen;
 
 	if (skb->remcsum_offload)
-		return vh;
+		return NULL;
 
 	if (!NAPI_GRO_CB(skb)->csum_valid)
 		return NULL;
@@ -579,7 +579,8 @@ static struct vxlanhdr *vxlan_gro_remcsum(struct sk_buff *skb,
 			return NULL;
 	}
 
-	skb_gro_remcsum_process(skb, (void *)vh + hdrlen, start, offset);
+	skb_gro_remcsum_process(skb, (void *)vh + hdrlen,
+				start, offset, grc);
 
 	skb->remcsum_offload = 1;
 
@@ -597,6 +598,9 @@ static struct sk_buff **vxlan_gro_receive(struct sk_buff **head,
 	struct vxlan_sock *vs = container_of(uoff, struct vxlan_sock,
 					     udp_offloads);
 	u32 flags;
+	struct gro_remcsum grc;
+
+	skb_gro_remcsum_init(&grc);
 
 	off_vx = skb_gro_offset(skb);
 	hlen = off_vx + sizeof(*vh);
@@ -614,7 +618,7 @@ static struct sk_buff **vxlan_gro_receive(struct sk_buff **head,
 
 	if ((flags & VXLAN_HF_RCO) && (vs->flags & VXLAN_F_REMCSUM_RX)) {
 		vh = vxlan_gro_remcsum(skb, off_vx, vh, sizeof(struct vxlanhdr),
-				       ntohl(vh->vx_vni));
+				       ntohl(vh->vx_vni), &grc);
 
 		if (!vh)
 			goto out;
@@ -637,6 +641,7 @@ static struct sk_buff **vxlan_gro_receive(struct sk_buff **head,
 	pp = eth_gro_receive(head, skb);
 
 out:
+	skb_gro_remcsum_cleanup(skb, &grc);
 	NAPI_GRO_CB(skb)->flush |= flush;
 
 	return pp;
@@ -1154,12 +1159,6 @@ static struct vxlanhdr *vxlan_remcsum(struct sk_buff *skb, struct vxlanhdr *vh,
 {
 	size_t start, offset, plen;
 
-	if (skb->remcsum_offload) {
-		/* Already processed in GRO path */
-		skb->remcsum_offload = 0;
-		return vh;
-	}
-
 	start = (data & VXLAN_RCO_MASK) << VXLAN_RCO_SHIFT;
 	offset = start + ((data & VXLAN_RCO_UDP) ?
 			  offsetof(struct udphdr, check) :
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d115256..3aa0245 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2321,8 +2321,19 @@ do {									\
 					   compute_pseudo(skb, proto));	\
 } while (0)
 
+struct gro_remcsum {
+	int offset;
+	__wsum delta;
+};
+
+static inline void skb_gro_remcsum_init(struct gro_remcsum *grc)
+{
+	grc->delta = 0;
+}
+
 static inline void skb_gro_remcsum_process(struct sk_buff *skb, void *ptr,
-					   int start, int offset)
+					   int start, int offset,
+					   struct gro_remcsum *grc)
 {
 	__wsum delta;
 
@@ -2331,10 +2342,20 @@ static inline void skb_gro_remcsum_process(struct sk_buff *skb, void *ptr,
 	delta = remcsum_adjust(ptr, NAPI_GRO_CB(skb)->csum, start, offset);
 
 	/* Adjust skb->csum since we changed the packet */
-	skb->csum = csum_add(skb->csum, delta);
 	NAPI_GRO_CB(skb)->csum = csum_add(NAPI_GRO_CB(skb)->csum, delta);
+
+	grc->offset = (ptr + offset) - (void *)skb->head;
+	grc->delta = delta;
 }
 
+static inline void skb_gro_remcsum_cleanup(struct sk_buff *skb,
+					   struct gro_remcsum *grc)
+{
+	if (!grc->delta)
+		return;
+
+	remcsum_unadjust((__sum16 *)(skb->head + grc->offset), grc->delta);
+}
 
 static inline int dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 				  unsigned short type,
diff --git a/include/net/checksum.h b/include/net/checksum.h
index e339a95..0a55ac7 100644
--- a/include/net/checksum.h
+++ b/include/net/checksum.h
@@ -167,4 +167,9 @@ static inline __wsum remcsum_adjust(void *ptr, __wsum csum,
 	return delta;
 }
 
+static inline void remcsum_unadjust(__sum16 *psum, __wsum delta)
+{
+	*psum = csum_fold(csum_sub(delta, *psum));
+}
+
 #endif
diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index 92ddea1..7fa8d36 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -71,12 +71,6 @@ static struct guehdr *gue_remcsum(struct sk_buff *skb, struct guehdr *guehdr,
 	size_t offset = ntohs(pd[1]);
 	size_t plen = hdrlen + max_t(size_t, offset + sizeof(u16), start);
 
-	if (skb->remcsum_offload) {
-		/* Already processed in GRO path */
-		skb->remcsum_offload = 0;
-		return guehdr;
-	}
-
 	if (!pskb_may_pull(skb, plen))
 		return NULL;
 	guehdr = (struct guehdr *)&udp_hdr(skb)[1];
@@ -214,7 +208,8 @@ out_unlock:
 
 static struct guehdr *gue_gro_remcsum(struct sk_buff *skb, unsigned int off,
 				      struct guehdr *guehdr, void *data,
-				      size_t hdrlen, u8 ipproto)
+				      size_t hdrlen, u8 ipproto,
+				      struct gro_remcsum *grc)
 {
 	__be16 *pd = data;
 	size_t start = ntohs(pd[0]);
@@ -222,7 +217,7 @@ static struct guehdr *gue_gro_remcsum(struct sk_buff *skb, unsigned int off,
 	size_t plen = hdrlen + max_t(size_t, offset + sizeof(u16), start);
 
 	if (skb->remcsum_offload)
-		return guehdr;
+		return NULL;
 
 	if (!NAPI_GRO_CB(skb)->csum_valid)
 		return NULL;
@@ -234,7 +229,8 @@ static struct guehdr *gue_gro_remcsum(struct sk_buff *skb, unsigned int off,
 			return NULL;
 	}
 
-	skb_gro_remcsum_process(skb, (void *)guehdr + hdrlen, start, offset);
+	skb_gro_remcsum_process(skb, (void *)guehdr + hdrlen,
+				start, offset, grc);
 
 	skb->remcsum_offload = 1;
 
@@ -254,6 +250,9 @@ static struct sk_buff **gue_gro_receive(struct sk_buff **head,
 	void *data;
 	u16 doffset = 0;
 	int flush = 1;
+	struct gro_remcsum grc;
+
+	skb_gro_remcsum_init(&grc);
 
 	off = skb_gro_offset(skb);
 	len = off + sizeof(*guehdr);
@@ -295,7 +294,7 @@ static struct sk_buff **gue_gro_receive(struct sk_buff **head,
 		if (flags & GUE_PFLAG_REMCSUM) {
 			guehdr = gue_gro_remcsum(skb, off, guehdr,
 						 data + doffset, hdrlen,
-						 guehdr->proto_ctype);
+						 guehdr->proto_ctype, &grc);
 			if (!guehdr)
 				goto out;
 
@@ -345,6 +344,7 @@ out_unlock:
 	rcu_read_unlock();
 out:
 	NAPI_GRO_CB(skb)->flush |= flush;
+	skb_gro_remcsum_cleanup(skb, &grc);
 
 	return pp;
 }
-- 
2.2.0.rc0.207.ga3a616c
