From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 05/10] net: Move skb_has_shared_frag check out of
 GRE code and into segmentation
Date: Fri, 05 Feb 2016 15:27:55 -0800
Message-ID: <20160205232755.18529.37175.stgit@localhost.localdomain>
References: <20160205232109.18529.99816.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: ecree@solarflare.com, tom@herbertland.com, davem@davemloft.net
To: netdev@vger.kernel.org, alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34253 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750735AbcBEX15 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 18:27:57 -0500
Received: by mail-pa0-f47.google.com with SMTP id uo6so42125224pac.1
        for <netdev@vger.kernel.org>; Fri, 05 Feb 2016 15:27:57 -0800 (PST)
In-Reply-To: <20160205232109.18529.99816.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The call skb_has_shared_frag is used in the GRE path and skb_checksum_help
to verify that no frags can be modified by an external entity.  This check
really doesn't belong in the GRE path but in the skb_segment function
itself.  This way any protocol that might be segmented will be performing
this check before attempting to offload a checksum to software.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 net/core/skbuff.c      |    5 +++++
 net/ipv4/gre_offload.c |   11 -----------
 2 files changed, 5 insertions(+), 11 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 9c065ac72e87..88262c82b96a 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3173,6 +3173,11 @@ skip_fraglist:
 
 perform_csum_check:
 		if (!csum) {
+			if (skb_has_shared_frag(nskb)) {
+				err = __skb_linearize(nskb);
+				if (err)
+					goto err;
+			}
 			if (!nskb->remcsum_offload)
 				nskb->ip_summed = CHECKSUM_NONE;
 			SKB_GSO_CB(nskb)->csum =
diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index 02cb1a416c7d..35a8dd35ed4e 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -83,17 +83,6 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 		if (csum) {
 			__be32 *pcsum;
 
-			if (skb_has_shared_frag(skb)) {
-				int err;
-
-				err = __skb_linearize(skb);
-				if (err) {
-					kfree_skb_list(segs);
-					segs = ERR_PTR(err);
-					goto out;
-				}
-			}
-
 			skb_reset_transport_header(skb);
 
 			greh = (struct gre_base_hdr *)
