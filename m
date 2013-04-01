From: roy.qing.li@gmail.com
Subject: [PATCH Resend] core: should call pskb_expand_head if skb header is cloned in skb_gso_segment in rx path
Date: Mon,  1 Apr 2013 10:37:41 +0800
Message-ID: <1364783861-3363-1-git-send-email-roy.qing.li@gmail.com>
Cc: amwang@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f53.google.com ([209.85.210.53]:55115 "EHLO
	mail-da0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756236Ab3DACht (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Mar 2013 22:37:49 -0400
Received: by mail-da0-f53.google.com with SMTP id n34so874332dal.12
        for <netdev@vger.kernel.org>; Sun, 31 Mar 2013 19:37:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

12b0004d1d1 (adjust skb_gso_segment() for calling in rx path) tries to kill warnings
by checking if ip_summed is CHECK_NONE or not in rx path, since if skb_gso_segment()
is called on rx path, and ->ip_summed has different meaning.

but this maybe break skb if skb header is cloned, and not expand the header, since when
step into skb_mac_gso_segment(), which will still check ip_summed with CHECKSUM_PARTIAL,
then do gso_send_check(). and after __skb_gso_segment() in queue_gso_packets() of
openvswitch, queue_userspace_packet() still checks ip_summed with CHECKSUM_PARTIAL,
and do checksum.

so I think it is enough to ignore the warning in rx path.

Cc: Cong Wang <amwang@redhat.com>
Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/core/dev.c |   16 +++-------------
 1 file changed, 3 insertions(+), 13 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index de930b7..bf0e586 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2269,17 +2269,6 @@ struct sk_buff *skb_mac_gso_segment(struct sk_buff *skb,
 }
 EXPORT_SYMBOL(skb_mac_gso_segment);
 
-
-/* openvswitch calls this on rx path, so we need a different check.
- */
-static inline bool skb_needs_check(struct sk_buff *skb, bool tx_path)
-{
-	if (tx_path)
-		return skb->ip_summed != CHECKSUM_PARTIAL;
-	else
-		return skb->ip_summed == CHECKSUM_NONE;
-}
-
 /**
  *	__skb_gso_segment - Perform segmentation on skb.
  *	@skb: buffer to segment
@@ -2294,10 +2283,11 @@ static inline bool skb_needs_check(struct sk_buff *skb, bool tx_path)
 struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
 				  netdev_features_t features, bool tx_path)
 {
-	if (unlikely(skb_needs_check(skb, tx_path))) {
+	if (unlikely(skb->ip_summed != CHECKSUM_PARTIAL)) {
 		int err;
 
-		skb_warn_bad_offload(skb);
+		if (tx_path)
+			skb_warn_bad_offload(skb);
 
 		if (skb_header_cloned(skb) &&
 		    (err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
-- 
1.7.10.4
