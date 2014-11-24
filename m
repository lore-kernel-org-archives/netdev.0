From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 2/3] gue: Call remcsum_adjust
Date: Mon, 24 Nov 2014 15:52:29 -0800
Message-ID: <1416873150-12260-3-git-send-email-therbert@google.com>
References: <1416873150-12260-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:63025 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305AbaKXXxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 18:53:03 -0500
Received: by mail-ie0-f176.google.com with SMTP id tr6so2293066ieb.21
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2014 15:53:03 -0800 (PST)
In-Reply-To: <1416873150-12260-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change remote checksum offload to call remcsum_adjust. This also
eliminates the optimization to skip an IP header as part of the
adjustment (really does not seem to be much of a win).

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/fou.c | 84 ++++++++++++----------------------------------------------
 1 file changed, 17 insertions(+), 67 deletions(-)

diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index 3dfe982..b986298 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -64,15 +64,13 @@ static int fou_udp_recv(struct sock *sk, struct sk_buff *skb)
 }
 
 static struct guehdr *gue_remcsum(struct sk_buff *skb, struct guehdr *guehdr,
-				  void *data, int hdrlen, u8 ipproto)
+				  void *data, size_t hdrlen, u8 ipproto)
 {
 	__be16 *pd = data;
-	u16 start = ntohs(pd[0]);
-	u16 offset = ntohs(pd[1]);
-	u16 poffset = 0;
-	u16 plen;
-	__wsum csum, delta;
-	__sum16 *psum;
+	size_t start = ntohs(pd[0]);
+	size_t offset = ntohs(pd[1]);
+	size_t plen = hdrlen + max_t(size_t, offset + sizeof(u16), start);
+	__wsum delta;
 
 	if (skb->remcsum_offload) {
 		/* Already processed in GRO path */
@@ -80,35 +78,15 @@ static struct guehdr *gue_remcsum(struct sk_buff *skb, struct guehdr *guehdr,
 		return guehdr;
 	}
 
-	if (start > skb->len - hdrlen ||
-	    offset > skb->len - hdrlen - sizeof(u16))
-		return NULL;
-
-	if (unlikely(skb->ip_summed != CHECKSUM_COMPLETE))
-		__skb_checksum_complete(skb);
-
-	plen = hdrlen + offset + sizeof(u16);
 	if (!pskb_may_pull(skb, plen))
 		return NULL;
 	guehdr = (struct guehdr *)&udp_hdr(skb)[1];
 
-	if (ipproto == IPPROTO_IP && sizeof(struct iphdr) < plen) {
-		struct iphdr *ip = (struct iphdr *)(skb->data + hdrlen);
-
-		/* If next header happens to be IP we can skip that for the
-		 * checksum calculation since the IP header checksum is zero
-		 * if correct.
-		 */
-		poffset = ip->ihl * 4;
-	}
-
-	csum = csum_sub(skb->csum, skb_checksum(skb, poffset + hdrlen,
-						start - poffset - hdrlen, 0));
+	if (unlikely(skb->ip_summed != CHECKSUM_COMPLETE))
+		__skb_checksum_complete(skb);
 
-	/* Set derived checksum in packet */
-	psum = (__sum16 *)(skb->data + hdrlen + offset);
-	delta = csum_sub(csum_fold(csum), *psum);
-	*psum = csum_fold(csum);
+	delta = remcsum_adjust((void *)guehdr + hdrlen,
+			       skb->csum, start, offset);
 
 	/* Adjust skb->csum since we changed the packet */
 	skb->csum = csum_add(skb->csum, delta);
@@ -158,9 +136,6 @@ static int gue_udp_recv(struct sock *sk, struct sk_buff *skb)
 
 	ip_hdr(skb)->tot_len = htons(ntohs(ip_hdr(skb)->tot_len) - len);
 
-	/* Pull UDP header now, skb->data points to guehdr */
-	__skb_pull(skb, sizeof(struct udphdr));
-
 	/* Pull csum through the guehdr now . This can be used if
 	 * there is a remote checksum offload.
 	 */
@@ -188,7 +163,7 @@ static int gue_udp_recv(struct sock *sk, struct sk_buff *skb)
 	if (unlikely(guehdr->control))
 		return gue_control_message(skb, guehdr);
 
-	__skb_pull(skb, hdrlen);
+	__skb_pull(skb, sizeof(struct udphdr) + hdrlen);
 	skb_reset_transport_header(skb);
 
 	return -guehdr->proto_ctype;
@@ -248,24 +223,17 @@ static struct guehdr *gue_gro_remcsum(struct sk_buff *skb, unsigned int off,
 				      size_t hdrlen, u8 ipproto)
 {
 	__be16 *pd = data;
-	u16 start = ntohs(pd[0]);
-	u16 offset = ntohs(pd[1]);
-	u16 poffset = 0;
-	u16 plen;
-	void *ptr;
-	__wsum csum, delta;
-	__sum16 *psum;
+	size_t start = ntohs(pd[0]);
+	size_t offset = ntohs(pd[1]);
+	size_t plen = hdrlen + max_t(size_t, offset + sizeof(u16), start);
+	__wsum delta;
 
 	if (skb->remcsum_offload)
 		return guehdr;
 
-	if (start > skb_gro_len(skb) - hdrlen ||
-	    offset > skb_gro_len(skb) - hdrlen - sizeof(u16) ||
-	    !NAPI_GRO_CB(skb)->csum_valid || skb->remcsum_offload)
+	if (!NAPI_GRO_CB(skb)->csum_valid)
 		return NULL;
 
-	plen = hdrlen + offset + sizeof(u16);
-
 	/* Pull checksum that will be written */
 	if (skb_gro_header_hard(skb, off + plen)) {
 		guehdr = skb_gro_header_slow(skb, off + plen, off);
@@ -273,26 +241,8 @@ static struct guehdr *gue_gro_remcsum(struct sk_buff *skb, unsigned int off,
 			return NULL;
 	}
 
-	ptr = (void *)guehdr + hdrlen;
-
-	if (ipproto == IPPROTO_IP &&
-	    (hdrlen + sizeof(struct iphdr) < plen)) {
-		struct iphdr *ip = (struct iphdr *)(ptr + hdrlen);
-
-		/* If next header happens to be IP we can skip
-		 * that for the checksum calculation since the
-		 * IP header checksum is zero if correct.
-		 */
-		poffset = ip->ihl * 4;
-	}
-
-	csum = csum_sub(NAPI_GRO_CB(skb)->csum,
-			csum_partial(ptr + poffset, start - poffset, 0));
-
-	/* Set derived checksum in packet */
-	psum = (__sum16 *)(ptr + offset);
-	delta = csum_sub(csum_fold(csum), *psum);
-	*psum = csum_fold(csum);
+	delta = remcsum_adjust((void *)guehdr + hdrlen,
+			       NAPI_GRO_CB(skb)->csum, start, offset);
 
 	/* Adjust skb->csum since we changed the packet */
 	skb->csum = csum_add(skb->csum, delta);
-- 
2.1.0.rc2.206.gedb03e5
