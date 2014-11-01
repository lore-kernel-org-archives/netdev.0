From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 7/7] gue: Receive side of remote checksum offload
Date: Sat,  1 Nov 2014 15:58:03 -0700
Message-ID: <1414882683-25484-8-git-send-email-therbert@google.com>
References: <1414882683-25484-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:48986 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752479AbaKAW6h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Nov 2014 18:58:37 -0400
Received: by mail-ig0-f180.google.com with SMTP id h3so2827192igd.13
        for <netdev@vger.kernel.org>; Sat, 01 Nov 2014 15:58:36 -0700 (PDT)
In-Reply-To: <1414882683-25484-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add processing of the remote checksum offload option in both the normal
path as well as the GRO path. The implements patching the affected
checksum to derive the offloaded checksum.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/fou.c | 170 ++++++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 161 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index fb0db99..740ae09 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -63,6 +63,59 @@ static int fou_udp_recv(struct sock *sk, struct sk_buff *skb)
 	return -fou->protocol;
 }
 
+static struct guehdr *gue_remcsum(struct sk_buff *skb, struct guehdr *guehdr,
+				  void *data, int hdrlen, u8 ipproto)
+{
+	__be16 *pd = data;
+	u16 start = ntohs(pd[0]);
+	u16 offset = ntohs(pd[1]);
+	u16 poffset = 0;
+	u16 plen;
+	__wsum csum, delta;
+	__sum16 *psum;
+
+	if (skb->remcsum_offload) {
+		/* Already processed in GRO path */
+		skb->remcsum_offload = 0;
+		return guehdr;
+	}
+
+	if (start > skb->len - hdrlen ||
+	    offset > skb->len - hdrlen - sizeof(u16))
+		return NULL;
+
+	if (unlikely(skb->ip_summed != CHECKSUM_COMPLETE))
+		__skb_checksum_complete(skb);
+
+	plen = hdrlen + offset + sizeof(u16);
+	if (!pskb_may_pull(skb, plen))
+		return NULL;
+	guehdr = (struct guehdr *)&udp_hdr(skb)[1];
+
+	if (ipproto == IPPROTO_IP && sizeof(struct iphdr) < plen) {
+		struct iphdr *ip = (struct iphdr *)(skb->data + hdrlen);
+
+		/* If next header happens to be IP we can skip that for the
+		 * checksum calculation since the IP header checksum is zero
+		 * if correct.
+		 */
+		poffset = ip->ihl * 4;
+	}
+
+	csum = csum_sub(skb->csum, skb_checksum(skb, poffset + hdrlen,
+						start - poffset - hdrlen, 0));
+
+	/* Set derived checksum in packet */
+	psum = (__sum16 *)(skb->data + hdrlen + offset);
+	delta = csum_sub(csum_fold(csum), *psum);
+	*psum = csum_fold(csum);
+
+	/* Adjust skb->csum since we changed the packet */
+	skb->csum = csum_add(skb->csum, delta);
+
+	return guehdr;
+}
+
 static int gue_control_message(struct sk_buff *skb, struct guehdr *guehdr)
 {
 	/* No support yet */
@@ -76,6 +129,7 @@ static int gue_udp_recv(struct sock *sk, struct sk_buff *skb)
 	size_t len, optlen, hdrlen;
 	struct guehdr *guehdr;
 	void *data;
+	u16 doffset = 0;
 
 	if (!fou)
 		return 1;
@@ -100,20 +154,43 @@ static int gue_udp_recv(struct sock *sk, struct sk_buff *skb)
 	if (guehdr->version != 0 || validate_gue_flags(guehdr, optlen))
 		goto drop;
 
-	/* Pull UDP and GUE headers */
-	fou_recv_pull(skb, len);
+	hdrlen = sizeof(struct guehdr) + optlen;
+
+	ip_hdr(skb)->tot_len = htons(ntohs(ip_hdr(skb)->tot_len) - len);
+
+	/* Pull UDP header now, skb->data points to guehdr */
+	__skb_pull(skb, sizeof(struct udphdr));
+
+	/* Pull csum through the guehdr now . This can be used if
+	 * there is a remote checksum offload.
+	 */
+	skb_postpull_rcsum(skb, udp_hdr(skb), len);
 
 	data = &guehdr[1];
 
 	if (guehdr->flags & GUE_FLAG_PRIV) {
-		data += GUE_LEN_PRIV;
+		__be32 flags = *(__be32 *)(data + doffset);
+
+		doffset += GUE_LEN_PRIV;
 
-		/* Process private flags */
+		if (flags & GUE_PFLAG_REMCSUM) {
+			guehdr = gue_remcsum(skb, guehdr, data + doffset,
+					     hdrlen, guehdr->proto_ctype);
+			if (!guehdr)
+				goto drop;
+
+			data = &guehdr[1];
+
+			doffset += GUE_PLEN_REMCSUM;
+		}
 	}
 
 	if (unlikely(guehdr->control))
 		return gue_control_message(skb, guehdr);
 
+	__skb_pull(skb, hdrlen);
+	skb_reset_transport_header(skb);
+
 	return -guehdr->proto_ctype;
 
 drop:
@@ -164,6 +241,66 @@ out_unlock:
 	return err;
 }
 
+static struct guehdr *gue_gro_remcsum(struct sk_buff *skb, unsigned int off,
+				      struct guehdr *guehdr, void *data,
+				      size_t hdrlen, u8 ipproto)
+{
+	__be16 *pd = data;
+	u16 start = ntohs(pd[0]);
+	u16 offset = ntohs(pd[1]);
+	u16 poffset = 0;
+	u16 plen;
+	void *ptr;
+	__wsum csum, delta;
+	__sum16 *psum;
+
+	if (skb->remcsum_offload)
+		return guehdr;
+
+	if (start > skb_gro_len(skb) - hdrlen ||
+	    offset > skb_gro_len(skb) - hdrlen - sizeof(u16) ||
+	    !NAPI_GRO_CB(skb)->csum_valid || skb->remcsum_offload)
+		return NULL;
+
+	plen = hdrlen + offset + sizeof(u16);
+
+	/* Pull checksum that will be written */
+	if (skb_gro_header_hard(skb, off + plen)) {
+		guehdr = skb_gro_header_slow(skb, off + plen, off);
+		if (!guehdr)
+			return NULL;
+	}
+
+	ptr = (void *)guehdr + hdrlen;
+
+	if (ipproto == IPPROTO_IP &&
+	    (hdrlen + sizeof(struct iphdr) < plen)) {
+		struct iphdr *ip = (struct iphdr *)(ptr + hdrlen);
+
+		/* If next header happens to be IP we can skip
+		 * that for the checksum calculation since the
+		 * IP header checksum is zero if correct.
+		 */
+		poffset = ip->ihl * 4;
+	}
+
+	csum = csum_sub(NAPI_GRO_CB(skb)->csum,
+			csum_partial(ptr + poffset, start - poffset, 0));
+
+	/* Set derived checksum in packet */
+	psum = (__sum16 *)(ptr + offset);
+	delta = csum_sub(csum_fold(csum), *psum);
+	*psum = csum_fold(csum);
+
+	/* Adjust skb->csum since we changed the packet */
+	skb->csum = csum_add(skb->csum, delta);
+	NAPI_GRO_CB(skb)->csum = csum_add(NAPI_GRO_CB(skb)->csum, delta);
+
+	skb->remcsum_offload = 1;
+
+	return guehdr;
+}
+
 static struct sk_buff **gue_gro_receive(struct sk_buff **head,
 					struct sk_buff *skb)
 {
@@ -174,6 +311,7 @@ static struct sk_buff **gue_gro_receive(struct sk_buff **head,
 	struct guehdr *guehdr;
 	size_t len, optlen, hdrlen, off;
 	void *data;
+	u16 doffset = 0;
 	int flush = 1;
 
 	off = skb_gro_offset(skb);
@@ -201,19 +339,33 @@ static struct sk_buff **gue_gro_receive(struct sk_buff **head,
 
 	hdrlen = sizeof(*guehdr) + optlen;
 
-	skb_gro_pull(skb, hdrlen);
-
-	/* Adjusted NAPI_GRO_CB(skb)->csum after skb_gro_pull()*/
+	/* Adjust NAPI_GRO_CB(skb)->csum to account for guehdr,
+	 * this is needed if there is a remote checkcsum offload.
+	 */
 	skb_gro_postpull_rcsum(skb, guehdr, hdrlen);
 
 	data = &guehdr[1];
 
 	if (guehdr->flags & GUE_FLAG_PRIV) {
-		data += GUE_LEN_PRIV;
+		__be32 flags = *(__be32 *)(data + doffset);
 
-		/* Process private flags */
+		doffset += GUE_LEN_PRIV;
+
+		if (flags & GUE_PFLAG_REMCSUM) {
+			guehdr = gue_gro_remcsum(skb, off, guehdr,
+						 data + doffset, hdrlen,
+						 guehdr->proto_ctype);
+			if (!guehdr)
+				goto out;
+
+			data = &guehdr[1];
+
+			doffset += GUE_PLEN_REMCSUM;
+		}
 	}
 
+	skb_gro_pull(skb, hdrlen);
+
 	flush = 0;
 
 	for (p = *head; p; p = p->next) {
-- 
2.1.0.rc2.206.gedb03e5
