From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH] net: Optimize local checksum offload
Date: Wed, 17 Feb 2016 11:23:55 -0800
Message-ID: <20160217192355.11040.3502.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33132 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030384AbcBQTX5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 14:23:57 -0500
Received: by mail-pa0-f54.google.com with SMTP id fl4so16218930pad.0
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 11:23:57 -0800 (PST)
Received: from localhost.localdomain (static-50-53-29-36.bvtn.or.frontiernet.net. [50.53.29.36])
        by smtp.gmail.com with ESMTPSA id 85sm4545279pfl.18.2016.02.17.11.23.56
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Feb 2016 11:23:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch takes advantage of several assumptions we can make about the
headers of the frame in order to reduce overall processing overhead for
computing the outer header checksum.

First we can assume the entire header is in the region pointed to by
skb->head as this is what csum_start is based on.

Second, as a result of our first assumption, we can just call csum_partial
instead of making a call to skb_checksum which would end up having to
configure things so that we could walk through the frags list.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 include/linux/skbuff.h |   17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 39206751463e..89b536796e53 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3713,19 +3713,18 @@ static inline unsigned int skb_gso_network_seglen(const struct sk_buff *skb)
  */
 static inline __wsum lco_csum(struct sk_buff *skb)
 {
-	char *inner_csum_field;
-	__wsum csum;
+	unsigned char *csum_start = skb_checksum_start(skb);
+	unsigned char *l4_hdr = skb_transport_header(skb);
+	__wsum partial;
 
 	/* Start with complement of inner checksum adjustment */
-	inner_csum_field = skb->data + skb_checksum_start_offset(skb) +
-				skb->csum_offset;
-	csum = ~csum_unfold(*(__force __sum16 *)inner_csum_field);
+	partial = ~csum_unfold(*(__force __sum16 *)(csum_start +
+						    skb->csum_offset));
+
 	/* Add in checksum of our headers (incl. outer checksum
-	 * adjustment filled in by caller)
+	 * adjustment filled in by caller) and return result.
 	 */
-	csum = skb_checksum(skb, 0, skb_checksum_start_offset(skb), csum);
-	/* The result is the checksum from skb->data to end of packet */
-	return csum;
+	return csum_partial(l4_hdr, csum_start - l4_hdr, partial);
 }
 
 #endif	/* __KERNEL__ */
