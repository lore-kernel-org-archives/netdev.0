From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 2/3] gro: Fix remcsum offload to deal with frags in GRO
Date: Thu, 2 Jul 2015 14:04:13 -0700
Message-ID: <1435871054-635096-3-git-send-email-tom@herbertland.com>
References: <1435871054-635096-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:33069 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754345AbbGBVEy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2015 17:04:54 -0400
Received: from pps.filterd (m0044008 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t62L0MTP013160
	for <netdev@vger.kernel.org>; Thu, 2 Jul 2015 14:04:53 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1vdbv684md-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 02 Jul 2015 14:04:53 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 fb79e8ba20fd11e5a53d0002c992ebde-e7fdb2b0 for <netdev@vger.kernel.org>;	Thu,
 02 Jul 2015 14:04:52 -0700
In-Reply-To: <1435871054-635096-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The remote checksum offload GRO did not consider the case that frag0
might be in use. This patch fixes that by accessing headers using the
skb_gro functions and not saving offsets relative to skb->head.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 drivers/net/vxlan.c       | 20 ++++++--------------
 include/linux/netdevice.h | 44 ++++++++++++++++++++++++++++++++------------
 net/ipv4/fou.c            | 25 +++++++++----------------
 3 files changed, 47 insertions(+), 42 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 34c519e..d41b482 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -552,10 +552,10 @@ static struct vxlanhdr *vxlan_gro_remcsum(struct sk_buff *skb,
 					  u32 data, struct gro_remcsum *grc,
 					  bool nopartial)
 {
-	size_t start, offset, plen;
+	size_t start, offset;
 
 	if (skb->remcsum_offload)
-		return NULL;
+		return vh;
 
 	if (!NAPI_GRO_CB(skb)->csum_valid)
 		return NULL;
@@ -565,17 +565,8 @@ static struct vxlanhdr *vxlan_gro_remcsum(struct sk_buff *skb,
 			  offsetof(struct udphdr, check) :
 			  offsetof(struct tcphdr, check));
 
-	plen = hdrlen + offset + sizeof(u16);
-
-	/* Pull checksum that will be written */
-	if (skb_gro_header_hard(skb, off + plen)) {
-		vh = skb_gro_header_slow(skb, off + plen, off);
-		if (!vh)
-			return NULL;
-	}
-
-	skb_gro_remcsum_process(skb, (void *)vh + hdrlen,
-				start, offset, grc, nopartial);
+	vh = skb_gro_remcsum_process(skb, (void *)vh, off, hdrlen,
+				     start, offset, grc, nopartial);
 
 	skb->remcsum_offload = 1;
 
@@ -606,7 +597,6 @@ static struct sk_buff **vxlan_gro_receive(struct sk_buff **head,
 			goto out;
 	}
 
-	skb_gro_pull(skb, sizeof(struct vxlanhdr)); /* pull vxlan header */
 	skb_gro_postpull_rcsum(skb, vh, sizeof(struct vxlanhdr));
 
 	flags = ntohl(vh->vx_flags);
@@ -621,6 +611,8 @@ static struct sk_buff **vxlan_gro_receive(struct sk_buff **head,
 			goto out;
 	}
 
+	skb_gro_pull(skb, sizeof(struct vxlanhdr)); /* pull vxlan header */
+
 	flush = 0;
 
 	for (p = *head; p; p = p->next) {
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e20979d..cef5cfc 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2277,8 +2277,7 @@ __sum16 __skb_gro_checksum_complete(struct sk_buff *skb);
 
 static inline bool skb_at_gro_remcsum_start(struct sk_buff *skb)
 {
-	return (NAPI_GRO_CB(skb)->gro_remcsum_start - skb_headroom(skb) ==
-		skb_gro_offset(skb));
+	return (NAPI_GRO_CB(skb)->gro_remcsum_start == skb_gro_offset(skb));
 }
 
 static inline bool __skb_gro_checksum_validate_needed(struct sk_buff *skb,
@@ -2374,37 +2373,58 @@ static inline void skb_gro_remcsum_init(struct gro_remcsum *grc)
 	grc->delta = 0;
 }
 
-static inline void skb_gro_remcsum_process(struct sk_buff *skb, void *ptr,
-					   int start, int offset,
-					   struct gro_remcsum *grc,
-					   bool nopartial)
+static inline void *skb_gro_remcsum_process(struct sk_buff *skb, void *ptr,
+					    unsigned int off, size_t hdrlen,
+					    int start, int offset,
+					    struct gro_remcsum *grc,
+					    bool nopartial)
 {
 	__wsum delta;
+	size_t plen = hdrlen + max_t(size_t, offset + sizeof(u16), start);
 
 	BUG_ON(!NAPI_GRO_CB(skb)->csum_valid);
 
 	if (!nopartial) {
-		NAPI_GRO_CB(skb)->gro_remcsum_start =
-		    ((unsigned char *)ptr + start) - skb->head;
-		return;
+		NAPI_GRO_CB(skb)->gro_remcsum_start = off + hdrlen + start;
+		return ptr;
+	}
+
+	ptr = skb_gro_header_fast(skb, off);
+	if (skb_gro_header_hard(skb, off + plen)) {
+		ptr = skb_gro_header_slow(skb, off + plen, off);
+		if (!ptr)
+			return NULL;
 	}
 
-	delta = remcsum_adjust(ptr, NAPI_GRO_CB(skb)->csum, start, offset);
+	delta = remcsum_adjust(ptr + hdrlen, NAPI_GRO_CB(skb)->csum,
+			       start, offset);
 
 	/* Adjust skb->csum since we changed the packet */
 	NAPI_GRO_CB(skb)->csum = csum_add(NAPI_GRO_CB(skb)->csum, delta);
 
-	grc->offset = (ptr + offset) - (void *)skb->head;
+	grc->offset = off + hdrlen + offset;
 	grc->delta = delta;
+
+	return ptr;
 }
 
 static inline void skb_gro_remcsum_cleanup(struct sk_buff *skb,
 					   struct gro_remcsum *grc)
 {
+	void *ptr;
+	size_t plen = grc->offset + sizeof(u16);
+
 	if (!grc->delta)
 		return;
 
-	remcsum_unadjust((__sum16 *)(skb->head + grc->offset), grc->delta);
+	ptr = skb_gro_header_fast(skb, grc->offset);
+	if (skb_gro_header_hard(skb, grc->offset + sizeof(u16))) {
+		ptr = skb_gro_header_slow(skb, plen, grc->offset);
+		if (!ptr)
+			return;
+	}
+
+	remcsum_unadjust((__sum16 *)ptr, grc->delta);
 }
 
 static inline int dev_hard_header(struct sk_buff *skb, struct net_device *dev,
diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index 34968cd..e61557f 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -79,7 +79,8 @@ static struct guehdr *gue_remcsum(struct sk_buff *skb, struct guehdr *guehdr,
 	__be16 *pd = data;
 	size_t start = ntohs(pd[0]);
 	size_t offset = ntohs(pd[1]);
-	size_t plen = hdrlen + max_t(size_t, offset + sizeof(u16), start);
+	size_t plen = sizeof(struct udphdr) + hdrlen +
+	    max_t(size_t, offset + sizeof(u16), start);
 
 	if (!pskb_may_pull(skb, plen))
 		return NULL;
@@ -221,29 +222,21 @@ out_unlock:
 
 static struct guehdr *gue_gro_remcsum(struct sk_buff *skb, unsigned int off,
 				      struct guehdr *guehdr, void *data,
-				      size_t hdrlen, u8 ipproto,
-				      struct gro_remcsum *grc, bool nopartial)
+				      size_t hdrlen, struct gro_remcsum *grc,
+				      bool nopartial)
 {
 	__be16 *pd = data;
 	size_t start = ntohs(pd[0]);
 	size_t offset = ntohs(pd[1]);
-	size_t plen = hdrlen + max_t(size_t, offset + sizeof(u16), start);
 
 	if (skb->remcsum_offload)
-		return NULL;
+		return guehdr;
 
 	if (!NAPI_GRO_CB(skb)->csum_valid)
 		return NULL;
 
-	/* Pull checksum that will be written */
-	if (skb_gro_header_hard(skb, off + plen)) {
-		guehdr = skb_gro_header_slow(skb, off + plen, off);
-		if (!guehdr)
-			return NULL;
-	}
-
-	skb_gro_remcsum_process(skb, (void *)guehdr + hdrlen,
-				start, offset, grc, nopartial);
+	guehdr = skb_gro_remcsum_process(skb, (void *)guehdr, off, hdrlen,
+					 start, offset, grc, nopartial);
 
 	skb->remcsum_offload = 1;
 
@@ -307,10 +300,10 @@ static struct sk_buff **gue_gro_receive(struct sk_buff **head,
 
 		if (flags & GUE_PFLAG_REMCSUM) {
 			guehdr = gue_gro_remcsum(skb, off, guehdr,
-						 data + doffset, hdrlen,
-						 guehdr->proto_ctype, &grc,
+						 data + doffset, hdrlen, &grc,
 						 !!(fou->flags &
 						    FOU_F_REMCSUM_NOPARTIAL));
+
 			if (!guehdr)
 				goto out;
 
-- 
1.8.1
