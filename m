From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 04/10] net: Store checksum result for offloaded GSO
 checksums
Date: Fri, 05 Feb 2016 15:27:49 -0800
Message-ID: <20160205232749.18529.44992.stgit@localhost.localdomain>
References: <20160205232109.18529.99816.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: ecree@solarflare.com, tom@herbertland.com, davem@davemloft.net
To: netdev@vger.kernel.org, alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34217 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750735AbcBEX1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 18:27:51 -0500
Received: by mail-pa0-f51.google.com with SMTP id uo6so42124296pac.1
        for <netdev@vger.kernel.org>; Fri, 05 Feb 2016 15:27:51 -0800 (PST)
In-Reply-To: <20160205232109.18529.99816.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes it so that we can offload the checksums for a packet up
to a certain point and then begin computing the checksums via software.
Setting this up is fairly straight forward as all we need to do is reset
the values stored in csum and csum_start for the GSO context block.

One complication for this is remote checksum offload.  In order to allow
the inner checksums to be offloaded while computing the outer checksum
manually we needed to have some way of indicating that the offload wasn't
real.  In order to do that I replaced CHECKSUM_PARTIAL with
CHECKSUM_UNNECESSARY in the case of us computing checksums for the outer
header while skipping computing checksums for the inner headers.  We clean
up the ip_summed flag and set it to either CHECKSUM_PARTIAL or
CHECKSUM_NONE once we hand the packet off to the next lower level.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 include/linux/skbuff.h |   15 +++++++++++++++
 net/ipv4/tcp_offload.c |    8 ++++++--
 2 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 33c3807b618a..77ebb61e2352 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2161,6 +2161,11 @@ static inline int skb_checksum_start_offset(const struct sk_buff *skb)
 	return skb->csum_start - skb_headroom(skb);
 }
 
+static inline unsigned char *skb_checksum_start(const struct sk_buff *skb)
+{
+	return skb->head + skb->csum_start;
+}
+
 static inline int skb_transport_offset(const struct sk_buff *skb)
 {
 	return skb_transport_header(skb) - skb->data;
@@ -3576,6 +3581,16 @@ static inline int gso_pskb_expand_head(struct sk_buff *skb, int extra)
 	return 0;
 }
 
+static inline void gso_reset_checksum(struct sk_buff *skb, __wsum res)
+{
+	/* Do not update partial checksums if remote checksum is enabled. */
+	if (skb->remcsum_offload)
+		return;
+
+	SKB_GSO_CB(skb)->csum = res;
+	SKB_GSO_CB(skb)->csum_start = skb_checksum_start(skb) - skb->head;
+}
+
 /* Compute the checksum for a gso segment. First compute the checksum value
  * from the start of transport header to SKB_GSO_CB(skb)->csum_start, and
  * then add in skb->csum (checksum from csum_start to end of packet).
diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index 9864a2dbadce..773083b7f1e9 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -135,7 +135,9 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 		th->fin = th->psh = 0;
 		th->check = newcheck;
 
-		if (skb->ip_summed != CHECKSUM_PARTIAL)
+		if (skb->ip_summed == CHECKSUM_PARTIAL)
+			gso_reset_checksum(skb, ~th->check);
+		else
 			th->check = gso_make_checksum(skb, ~th->check);
 
 		seq += mss;
@@ -169,7 +171,9 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 		      skb->data_len);
 	th->check = ~csum_fold((__force __wsum)((__force u32)th->check +
 				(__force u32)delta));
-	if (skb->ip_summed != CHECKSUM_PARTIAL)
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
+		gso_reset_checksum(skb, ~th->check);
+	else
 		th->check = gso_make_checksum(skb, ~th->check);
 out:
 	return segs;
