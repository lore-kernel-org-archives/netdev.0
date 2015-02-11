From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 5/7] net: Infrastructure for CHECKSUM_PARTIAL with remote checsum offload
Date: Tue, 10 Feb 2015 16:30:31 -0800
Message-ID: <1423614633-25042-6-git-send-email-therbert@google.com>
References: <1423614633-25042-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:33568 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752323AbbBKAax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 19:30:53 -0500
Received: by iecar1 with SMTP id ar1so515914iec.0
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2015 16:30:53 -0800 (PST)
In-Reply-To: <1423614633-25042-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds infrastructure so that remote checksum offload can
set CHECKSUM_PARTIAL instead of calling csum_partial and writing
the modfied checksum field.

Add skb_remcsum_adjust_partial function to set an skb for using
CHECKSUM_PARTIAL with remote checksum offload.  Changed
skb_remcsum_process and skb_gro_remcsum_process to take a boolean
argument to indicate if checksum partial can be set or the
checksum needs to be modified using the normal algorithm.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/vxlan.c       |  4 ++--
 include/linux/netdevice.h | 19 ++++++++++++++++++-
 include/linux/skbuff.h    | 15 ++++++++++++++-
 net/core/dev.c            |  1 +
 net/ipv4/fou.c            |  4 ++--
 5 files changed, 37 insertions(+), 6 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 30310a6..4f04443 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -580,7 +580,7 @@ static struct vxlanhdr *vxlan_gro_remcsum(struct sk_buff *skb,
 	}
 
 	skb_gro_remcsum_process(skb, (void *)vh + hdrlen,
-				start, offset, grc);
+				start, offset, grc, true);
 
 	skb->remcsum_offload = 1;
 
@@ -1171,7 +1171,7 @@ static struct vxlanhdr *vxlan_remcsum(struct sk_buff *skb, struct vxlanhdr *vh,
 
 	vh = (struct vxlanhdr *)(udp_hdr(skb) + 1);
 
-	skb_remcsum_process(skb, (void *)vh + hdrlen, start, offset);
+	skb_remcsum_process(skb, (void *)vh + hdrlen, start, offset, true);
 
 	return vh;
 }
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 43fd0a4..5897b4e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1923,6 +1923,9 @@ struct napi_gro_cb {
 	/* Number of segments aggregated. */
 	u16	count;
 
+	/* Start offset for remote checksum offload */
+	u16	gro_remcsum_start;
+
 	/* jiffies when first packet was created/queued */
 	unsigned long age;
 
@@ -2244,6 +2247,12 @@ static inline void skb_gro_postpull_rcsum(struct sk_buff *skb,
 
 __sum16 __skb_gro_checksum_complete(struct sk_buff *skb);
 
+static inline bool skb_at_gro_remcsum_start(struct sk_buff *skb)
+{
+	return (NAPI_GRO_CB(skb)->gro_remcsum_start - skb_headroom(skb) ==
+		skb_gro_offset(skb));
+}
+
 static inline bool __skb_gro_checksum_validate_needed(struct sk_buff *skb,
 						      bool zero_okay,
 						      __sum16 check)
@@ -2251,6 +2260,7 @@ static inline bool __skb_gro_checksum_validate_needed(struct sk_buff *skb,
 	return ((skb->ip_summed != CHECKSUM_PARTIAL ||
 		skb_checksum_start_offset(skb) <
 		 skb_gro_offset(skb)) &&
+		!skb_at_gro_remcsum_start(skb) &&
 		NAPI_GRO_CB(skb)->csum_cnt == 0 &&
 		(!zero_okay || check));
 }
@@ -2337,12 +2347,19 @@ static inline void skb_gro_remcsum_init(struct gro_remcsum *grc)
 
 static inline void skb_gro_remcsum_process(struct sk_buff *skb, void *ptr,
 					   int start, int offset,
-					   struct gro_remcsum *grc)
+					   struct gro_remcsum *grc,
+					   bool nopartial)
 {
 	__wsum delta;
 
 	BUG_ON(!NAPI_GRO_CB(skb)->csum_valid);
 
+	if (!nopartial) {
+		NAPI_GRO_CB(skb)->gro_remcsum_start =
+		    ((unsigned char *)ptr + start) - skb->head;
+		return;
+	}
+
 	delta = remcsum_adjust(ptr, NAPI_GRO_CB(skb)->csum, start, offset);
 
 	/* Adjust skb->csum since we changed the packet */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index da6028a..30007af 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3104,16 +3104,29 @@ do {									\
 				       compute_pseudo(skb, proto));	\
 } while (0)
 
+static inline void skb_remcsum_adjust_partial(struct sk_buff *skb, void *ptr,
+					      u16 start, u16 offset)
+{
+	skb->ip_summed = CHECKSUM_PARTIAL;
+	skb->csum_start = ((unsigned char *)ptr + start) - skb->head;
+	skb->csum_offset = offset - start;
+}
+
 /* Update skbuf and packet to reflect the remote checksum offload operation.
  * When called, ptr indicates the starting point for skb->csum when
  * ip_summed is CHECKSUM_COMPLETE. If we need create checksum complete
  * here, skb_postpull_rcsum is done so skb->csum start is ptr.
  */
 static inline void skb_remcsum_process(struct sk_buff *skb, void *ptr,
-				       int start, int offset)
+				       int start, int offset, bool nopartial)
 {
 	__wsum delta;
 
+	if (!nopartial) {
+		skb_remcsum_adjust_partial(skb, ptr, start, offset);
+		return;
+	}
+
 	 if (unlikely(skb->ip_summed != CHECKSUM_COMPLETE)) {
 		__skb_checksum_complete(skb);
 		skb_postpull_rcsum(skb, skb->data, ptr - (void *)skb->data);
diff --git a/net/core/dev.c b/net/core/dev.c
index d030575..48c6ecb 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4024,6 +4024,7 @@ static enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff
 		NAPI_GRO_CB(skb)->flush = 0;
 		NAPI_GRO_CB(skb)->free = 0;
 		NAPI_GRO_CB(skb)->udp_mark = 0;
+		NAPI_GRO_CB(skb)->gro_remcsum_start = 0;
 
 		/* Setup for GRO checksum validation */
 		switch (skb->ip_summed) {
diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index 7fa8d36..d320f57 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -75,7 +75,7 @@ static struct guehdr *gue_remcsum(struct sk_buff *skb, struct guehdr *guehdr,
 		return NULL;
 	guehdr = (struct guehdr *)&udp_hdr(skb)[1];
 
-	skb_remcsum_process(skb, (void *)guehdr + hdrlen, start, offset);
+	skb_remcsum_process(skb, (void *)guehdr + hdrlen, start, offset, true);
 
 	return guehdr;
 }
@@ -230,7 +230,7 @@ static struct guehdr *gue_gro_remcsum(struct sk_buff *skb, unsigned int off,
 	}
 
 	skb_gro_remcsum_process(skb, (void *)guehdr + hdrlen,
-				start, offset, grc);
+				start, offset, grc, true);
 
 	skb->remcsum_offload = 1;
 
-- 
2.2.0.rc0.207.ga3a616c
