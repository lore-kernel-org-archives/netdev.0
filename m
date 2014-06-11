From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 1/3] net: Preserve CHECKSUM_COMPLETE at validation
Date: Tue, 10 Jun 2014 18:54:13 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406101849020.5825@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f201.google.com ([209.85.192.201]:50574 "EHLO
	mail-pd0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752718AbaFKByO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 21:54:14 -0400
Received: by mail-pd0-f201.google.com with SMTP id v10so162341pde.4
        for <netdev@vger.kernel.org>; Tue, 10 Jun 2014 18:54:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently when the first checksum in a packet is validated using
CHECKSUM_COMPLETE, ip_summed is overwritten to be CHECKSUM_UNNECESSARY
so that any subsequent checksums in the packet are not correctly
validated.

This patch adds csum_valid flag in sk_buff and uses that to indicate
validated checksum instead of setting CHECKSUM_UNNECESSARY. The bit
is set accordingly in the skb_checksum_validate_* functions. The flag
is checked in skb_checksum_complete, so that validation is communicated
between checksum_init and checksum_complete sequence in TCP and UDP.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/skbuff.h | 23 ++++++++++++++---------
 1 file changed, 14 insertions(+), 9 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index c705808..fb44d5f 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -572,7 +572,8 @@ struct sk_buff {
 	 */
 	__u8			encapsulation:1;
 	__u8			encap_hdr_csum:1;
-	/* 5/7 bit hole (depending on ndisc_nodetype presence) */
+	__u8			csum_valid:1;
+	/* 4/6 bit hole (depending on ndisc_nodetype presence) */
 	kmemcheck_bitfield_end(flags2);
 
 #if defined CONFIG_NET_DMA || defined CONFIG_NET_RX_BUSY_POLL
@@ -2721,7 +2722,7 @@ __sum16 __skb_checksum_complete(struct sk_buff *skb);
 
 static inline int skb_csum_unnecessary(const struct sk_buff *skb)
 {
-	return skb->ip_summed & CHECKSUM_UNNECESSARY;
+	return ((skb->ip_summed & CHECKSUM_UNNECESSARY) || skb->csum_valid);
 }
 
 /**
@@ -2755,10 +2756,8 @@ static inline bool __skb_checksum_validate_needed(struct sk_buff *skb,
 						  bool zero_okay,
 						  __sum16 check)
 {
-	if (skb_csum_unnecessary(skb)) {
-		return false;
-	} else if (zero_okay && !check) {
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
+	if (skb_csum_unnecessary(skb) || (zero_okay && !check)) {
+		skb->csum_valid = 1;
 		return false;
 	}
 
@@ -2785,15 +2784,20 @@ static inline __sum16 __skb_checksum_validate_complete(struct sk_buff *skb,
 {
 	if (skb->ip_summed == CHECKSUM_COMPLETE) {
 		if (!csum_fold(csum_add(psum, skb->csum))) {
-			skb->ip_summed = CHECKSUM_UNNECESSARY;
+			skb->csum_valid = 1;
 			return 0;
 		}
 	}
 
 	skb->csum = psum;
 
-	if (complete || skb->len <= CHECKSUM_BREAK)
-		return __skb_checksum_complete(skb);
+	if (complete || skb->len <= CHECKSUM_BREAK) {
+		__sum16 csum;
+
+		csum = __skb_checksum_complete(skb);
+		skb->csum_valid = !csum;
+		return csum;
+	}
 
 	return 0;
 }
@@ -2817,6 +2821,7 @@ static inline __wsum null_compute_pseudo(struct sk_buff *skb, int proto)
 				zero_okay, check, compute_pseudo)	\
 ({									\
 	__sum16 __ret = 0;						\
+	skb->csum_valid = 0;						\
 	if (__skb_checksum_validate_needed(skb, zero_okay, check))	\
 		__ret = __skb_checksum_validate_complete(skb,		\
 				complete, compute_pseudo(skb, proto));	\
-- 
2.0.0.526.g5318336
