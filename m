From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next] net: Fix remote checksum offload with GUE
Date: Tue, 22 Mar 2016 12:19:25 -0700
Message-ID: <1458674365-3944200-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <aduyck@mirantis.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:41143 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750899AbcCVTTr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 15:19:47 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u2MJGooo026504
	for <netdev@vger.kernel.org>; Tue, 22 Mar 2016 12:19:46 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 21s2k8y5bu-1
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 22 Mar 2016 12:19:46 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.103.99.97) with ESMTP	id
 04452394f06311e5b5a90002c9931860-bf6e93f0 for <netdev@vger.kernel.org>;	Tue,
 22 Mar 2016 12:19:36 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In skb_segment the check of whether or not to perform the checksum on
host was changed to not consider rather remote checksum offload is
in use. In the case that can_checksum_protocol fails the checksum
is computed regardless. __skb_udp_tunnel_segment was modified in a
related patch to add NETIF_F_HW_CSUM into features when grabbing
the enc_features and remote checksum offload is being done. The
problem is that this bit can be cleared in lower GSO layers that
are also doing tunneling (e.g. ipip, GRE when used with GUE),
so when we get to skb_segment that intent has been lost and
can_checksum_protocol fails.

This patch:

- Restores the check in skb_segment to look at remote checksum offload.
- Removes the code in __skb_udp_tunnel_segment to force the
  NETIF_F_HW_CSUM feature since this is no longer useful with above
  change.
- Removes check for remote checksum offload in gso_reset_checksum.
  A special case should not be needed here.

Tested: Single netperf STREAM over GUE-ipip

Before fix:
   5625 Mbps
After fix:
   6410 Mbps

Fixes: 76443456227097179c1482 ("net: Move GSO csum into SKB_GSO_CB")
Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/skbuff.h |  4 ----
 net/core/skbuff.c      |  5 ++---
 net/ipv4/udp_offload.c | 10 ----------
 3 files changed, 2 insertions(+), 17 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 15d0df9..f6fe8a5 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3615,10 +3615,6 @@ static inline int gso_pskb_expand_head(struct sk_buff *skb, int extra)
 
 static inline void gso_reset_checksum(struct sk_buff *skb, __wsum res)
 {
-	/* Do not update partial checksums if remote checksum is enabled. */
-	if (skb->remcsum_offload)
-		return;
-
 	SKB_GSO_CB(skb)->csum = res;
 	SKB_GSO_CB(skb)->csum_start = skb_checksum_start(skb) - skb->head;
 }
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index f044f97..e4eb78d 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3259,14 +3259,13 @@ skip_fraglist:
 		nskb->truesize += nskb->data_len;
 
 perform_csum_check:
-		if (!csum) {
+		if (!csum && !nskb->remcsum_offload) {
 			if (skb_has_shared_frag(nskb)) {
 				err = __skb_linearize(nskb);
 				if (err)
 					goto err;
 			}
-			if (!nskb->remcsum_offload)
-				nskb->ip_summed = CHECKSUM_NONE;
+			nskb->ip_summed = CHECKSUM_NONE;
 			SKB_GSO_CB(nskb)->csum =
 				skb_checksum(nskb, doffset,
 					     nskb->len - doffset, 0);
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 8a3405a..f86f1e1 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -78,16 +78,6 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 
 	features &= skb->dev->hw_enc_features;
 
-	/* The only checksum offload we care about from here on out is the
-	 * outer one so strip the existing checksum feature flags and
-	 * instead set the flag based on our outer checksum offload value.
-	 */
-	if (remcsum || ufo) {
-		features &= ~NETIF_F_CSUM_MASK;
-		if (!need_csum || offload_csum)
-			features |= NETIF_F_HW_CSUM;
-	}
-
 	/* segment inner packet. */
 	segs = gso_inner_segment(skb, features);
 	if (IS_ERR_OR_NULL(segs)) {
-- 
2.8.0.rc2
