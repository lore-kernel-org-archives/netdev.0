From: Alexander Duyck <aduyck@mirantis.com>
Subject: [RFC PATCH 2/4] net: Update remote checksum segmentation to support
 use of GSO checksum
Date: Wed, 13 Jan 2016 21:12:08 -0800
Message-ID: <20160114051208.5119.5576.stgit@localhost.localdomain>
References: <20160114045532.5119.56124.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: ecree@solarflare.com, netdev@vger.kernel.org, tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:33725 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754651AbcANFMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2016 00:12:10 -0500
Received: by mail-pf0-f175.google.com with SMTP id e65so93648867pfe.0
        for <netdev@vger.kernel.org>; Wed, 13 Jan 2016 21:12:09 -0800 (PST)
In-Reply-To: <20160114045532.5119.56124.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch addresses two main issues.

First in the case of remote checksum offload we were avoiding dealing with
scatter-gather issues.  As a result it would be possible to assemble a
series of frames that used frags instead of being linearized as they should
have if remote checksum offload was enabled.

Second I have updated the code so that we now let GSO take care of doing
the checksum on the data itself and drop the special case that was added
for remote checksum offload.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 net/core/skbuff.c      |   16 +++++++++-------
 net/ipv4/udp_offload.c |   12 ------------
 2 files changed, 9 insertions(+), 19 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 02c638a643ea..58ff3afdf79a 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2991,7 +2991,7 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 	unsigned int headroom;
 	unsigned int len;
 	__be16 proto;
-	bool csum;
+	bool csum = !head_skb->encap_hdr_csum;
 	int sg = !!(features & NETIF_F_SG);
 	int nfrags = skb_shinfo(head_skb)->nr_frags;
 	int err = -ENOMEM;
@@ -3004,8 +3004,8 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 	if (unlikely(!proto))
 		return ERR_PTR(-EINVAL);
 
-	csum = !head_skb->encap_hdr_csum &&
-	    !!can_checksum_protocol(features, proto);
+	if (!head_skb->remcsum_offload)
+		csum &= !!can_checksum_protocol(features, proto);
 
 	headroom = skb_headroom(head_skb);
 	pos = skb_headlen(head_skb);
@@ -3098,8 +3098,9 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 		if (nskb->len == len + doffset)
 			goto perform_csum_check;
 
-		if (!sg && !nskb->remcsum_offload) {
-			nskb->ip_summed = CHECKSUM_NONE;
+		if (!sg) {
+			if (!nskb->remcsum_offload)
+				nskb->ip_summed = CHECKSUM_NONE;
 			SKB_GSO_CB(nskb)->csum =
 				skb_copy_and_csum_bits(head_skb, offset,
 						       skb_put(nskb, len),
@@ -3171,8 +3172,9 @@ skip_fraglist:
 		nskb->truesize += nskb->data_len;
 
 perform_csum_check:
-		if (!csum && !nskb->remcsum_offload) {
-			nskb->ip_summed = CHECKSUM_NONE;
+		if (!csum) {
+			if (!nskb->remcsum_offload)
+				nskb->ip_summed = CHECKSUM_NONE;
 			SKB_GSO_CB(nskb)->csum =
 				skb_checksum(nskb, doffset,
 					     nskb->len - doffset, 0);
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 130042660181..ab7531b4dd24 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -115,18 +115,6 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 			skb->ip_summed = CHECKSUM_PARTIAL;
 			skb->csum_start = skb_transport_header(skb) - skb->head;
 			skb->csum_offset = offsetof(struct udphdr, check);
-		} else if (remcsum) {
-			/* Need to calculate checksum from scratch,
-			 * inner checksums are never when doing
-			 * remote_checksum_offload.
-			 */
-
-			skb->csum = skb_checksum(skb, udp_offset,
-						 skb->len - udp_offset,
-						 0);
-			uh->check = csum_fold(skb->csum);
-			if (uh->check == 0)
-				uh->check = CSUM_MANGLED_0;
 		} else {
 			uh->check = gso_make_checksum(skb, ~uh->check);
 
