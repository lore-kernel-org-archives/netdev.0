From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 3/7] net: Support for multiple checksums with gso
Date: Sun, 1 Jun 2014 21:01:20 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406012048030.9338@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f74.google.com ([209.85.220.74]:38846 "EHLO
	mail-pa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbaFBEBV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 00:01:21 -0400
Received: by mail-pa0-f74.google.com with SMTP id bj1so99802pad.1
        for <netdev@vger.kernel.org>; Sun, 01 Jun 2014 21:01:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When creating a GSO packet segment we may need to set more than
one checksum in the packet (for instance a TCP checksum and
UDP checksum for VXLAN encapsulation). To be efficient, we want
to do checksum calculation for any part of the packet at most once.

This patch adds csum_start offset to skb_gso_cb. This tracks the
starting offset for skb->csum which is initially set in skb_segment.
When a protocol needs to compute a transport checksum it calls
gso_make_checksum which computes the checksum value from the start
of transport header to csum_start and then adds in skb->csum to get
the full checksum. skb->csum and csum_start are then updated to reflect
the checksum of the resultant packet starting from the transport header.

This patch also adds a flag to skbuff, encap_hdr_csum, which is set
in *gso_segment fucntions to indicate that a tunnel protocol needs
checksum calculation

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/skbuff.h    | 26 +++++++++++++++++++++++++-
 net/core/skbuff.c         |  8 +++++++-
 net/ipv4/ip_tunnel_core.c |  8 ++++++++
 3 files changed, 40 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 7a9beeb..d8d397a 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -567,7 +567,8 @@ struct sk_buff {
 	 * headers if needed
 	 */
 	__u8			encapsulation:1;
-	/* 6/8 bit hole (depending on ndisc_nodetype presence) */
+	__u8			encap_hdr_csum:1;
+	/* 5/7 bit hole (depending on ndisc_nodetype presence) */
 	kmemcheck_bitfield_end(flags2);
 
 #if defined CONFIG_NET_DMA || defined CONFIG_NET_RX_BUSY_POLL
@@ -2988,6 +2989,7 @@ static inline struct sec_path *skb_sec_path(struct sk_buff *skb)
 struct skb_gso_cb {
 	int	mac_offset;
 	int	encap_level;
+	__u16	csum_start;
 };
 #define SKB_GSO_CB(skb) ((struct skb_gso_cb *)(skb)->cb)
 
@@ -3012,6 +3014,28 @@ static inline int gso_pskb_expand_head(struct sk_buff *skb, int extra)
 	return 0;
 }
 
+/* Compute the checksum for a gso segment. First compute the checksum value
+ * from the start of transport header to SKB_GSO_CB(skb)->csum_start, and
+ * then add in skb->csum (checksum from csum_start to end of packet).
+ * skb->csum and csum_start are then updated to reflect the checksum of the
+ * resultant packet starting from the transport header-- the resultant checksum
+ * is in the res argument (i.e. normally zero or ~ of checksum of a pseudo
+ * header.
+ */
+static inline __sum16 gso_make_checksum(struct sk_buff *skb, __wsum res)
+{
+	int plen = SKB_GSO_CB(skb)->csum_start - skb_headroom(skb) -
+	    skb_transport_offset(skb);
+	__u16 csum;
+
+	csum = csum_fold(csum_partial(skb_transport_header(skb),
+				      plen, skb->csum));
+	skb->csum = res;
+	SKB_GSO_CB(skb)->csum_start -= plen;
+
+	return csum;
+}
+
 static inline bool skb_is_gso(const struct sk_buff *skb)
 {
 	return skb_shinfo(skb)->gso_size;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3f6c7e8..05f4bef 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2885,7 +2885,9 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 	if (unlikely(!proto))
 		return ERR_PTR(-EINVAL);
 
-	csum = !!can_checksum_protocol(features, proto);
+	csum = !head_skb->encap_hdr_csum &&
+	    !!can_checksum_protocol(features, proto);
+
 	__skb_push(head_skb, doffset);
 	headroom = skb_headroom(head_skb);
 	pos = skb_headlen(head_skb);
@@ -2983,6 +2985,8 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 			nskb->csum = skb_copy_and_csum_bits(head_skb, offset,
 							    skb_put(nskb, len),
 							    len, 0);
+			SKB_GSO_CB(nskb)->csum_start =
+			    skb_headroom(nskb) + offset;
 			continue;
 		}
 
@@ -3052,6 +3056,8 @@ perform_csum_check:
 			nskb->csum = skb_checksum(nskb, doffset,
 						  nskb->len - doffset, 0);
 			nskb->ip_summed = CHECKSUM_NONE;
+			SKB_GSO_CB(nskb)->csum_start =
+			    skb_headroom(nskb) + doffset;
 		}
 	} while ((offset += len) < head_skb->len);
 
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index bcf206c..ec57660 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -135,6 +135,14 @@ struct sk_buff *iptunnel_handle_offloads(struct sk_buff *skb,
 		return skb;
 	}
 
+	/* If packet is not gso and we are resolving any partial checksum,
+	 * clear encapsulation flag. This allows setting CHECKSUM_PARTIAL
+	 * on the outer header without confusing devices that implement
+	 * NETIF_F_IP_CSUM with encapsulation.
+	 */
+	if (csum_help)
+		skb->encapsulation = 0;
+
 	if (skb->ip_summed == CHECKSUM_PARTIAL && csum_help) {
 		err = skb_checksum_help(skb);
 		if (unlikely(err))
-- 
1.9.1.423.g4596e3a
