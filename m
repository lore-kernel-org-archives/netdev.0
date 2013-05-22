From: Simon Horman <horms@verge.net.au>
Subject: [PATCH next-next v4 1/2] net: Use 16bits for inner_*_headers fields of struct skbuff
Date: Wed, 22 May 2013 15:57:15 +0900
Message-ID: <1369205836-9407-2-git-send-email-horms@verge.net.au>
References: <1369205836-9407-1-git-send-email-horms@verge.net.au>
Cc: Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	jarno.rajahalme@nsn.com, Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	Simon Horman <horms@verge.net.au>
To: dev@openvswitch.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:40743 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754845Ab3EVG5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 02:57:21 -0400
In-Reply-To: <1369205836-9407-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to reduce the size of struct skbuff use 16 bit integer
offsets rather than pointers for inner_*_headers.

The implication of this is that the behaviour of
is that of other _headers when NET_SKBUFF_DATA_USES_OFFSET is set.

This appears to reduce the size of struct skbuff from 0xd0 to 0xc8
bytes on x86_64 with the following all unset.

	CONFIG_XFRM
	CONFIG_NF_CONNTRACK
	CONFIG_NF_CONNTRACK_MODULE
	NET_SKBUFF_NF_DEFRAG_NEEDED
	CONFIG_BRIDGE_NETFILTER
	CONFIG_NET_SCHED
	CONFIG_IPV6_NDISC_NODETYPE
	CONFIG_NET_DMA
	CONFIG_NETWORK_SECMARK

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/linux/skbuff.h | 63 +++++++-------------------------------------------
 1 file changed, 8 insertions(+), 55 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 2e0ced1..3791615 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -509,9 +509,9 @@ struct sk_buff {
 		__u32		reserved_tailroom;
 	};
 
-	sk_buff_data_t		inner_transport_header;
-	sk_buff_data_t		inner_network_header;
-	sk_buff_data_t		inner_mac_header;
+	__u16			inner_transport_header;
+	__u16			inner_network_header;
+	__u16			inner_mac_header;
 	sk_buff_data_t		transport_header;
 	sk_buff_data_t		network_header;
 	sk_buff_data_t		mac_header;
@@ -1517,9 +1517,9 @@ static inline void skb_reserve(struct sk_buff *skb, int len)
 
 static inline void skb_reset_inner_headers(struct sk_buff *skb)
 {
-	skb->inner_mac_header = skb->mac_header;
-	skb->inner_network_header = skb->network_header;
-	skb->inner_transport_header = skb->transport_header;
+	skb->inner_mac_header = 0;
+	skb->inner_network_header = 0;
+	skb->inner_transport_header = 0;
 }
 
 static inline void skb_reset_mac_len(struct sk_buff *skb)
@@ -1527,7 +1527,6 @@ static inline void skb_reset_mac_len(struct sk_buff *skb)
 	skb->mac_len = skb->network_header - skb->mac_header;
 }
 
-#ifdef NET_SKBUFF_DATA_USES_OFFSET
 static inline unsigned char *skb_inner_transport_header(const struct sk_buff
 							*skb)
 {
@@ -1579,6 +1578,8 @@ static inline void skb_set_inner_mac_header(struct sk_buff *skb,
 	skb_reset_inner_mac_header(skb);
 	skb->inner_mac_header += offset;
 }
+
+#ifdef NET_SKBUFF_DATA_USES_OFFSET
 static inline bool skb_transport_header_was_set(const struct sk_buff *skb)
 {
 	return skb->transport_header != ~0U;
@@ -1639,54 +1640,6 @@ static inline void skb_set_mac_header(struct sk_buff *skb, const int offset)
 }
 
 #else /* NET_SKBUFF_DATA_USES_OFFSET */
-static inline unsigned char *skb_inner_transport_header(const struct sk_buff
-							*skb)
-{
-	return skb->inner_transport_header;
-}
-
-static inline void skb_reset_inner_transport_header(struct sk_buff *skb)
-{
-	skb->inner_transport_header = skb->data;
-}
-
-static inline void skb_set_inner_transport_header(struct sk_buff *skb,
-						   const int offset)
-{
-	skb->inner_transport_header = skb->data + offset;
-}
-
-static inline unsigned char *skb_inner_network_header(const struct sk_buff *skb)
-{
-	return skb->inner_network_header;
-}
-
-static inline void skb_reset_inner_network_header(struct sk_buff *skb)
-{
-	skb->inner_network_header = skb->data;
-}
-
-static inline void skb_set_inner_network_header(struct sk_buff *skb,
-						const int offset)
-{
-	skb->inner_network_header = skb->data + offset;
-}
-
-static inline unsigned char *skb_inner_mac_header(const struct sk_buff *skb)
-{
-	return skb->inner_mac_header;
-}
-
-static inline void skb_reset_inner_mac_header(struct sk_buff *skb)
-{
-	skb->inner_mac_header = skb->data;
-}
-
-static inline void skb_set_inner_mac_header(struct sk_buff *skb,
-						const int offset)
-{
-	skb->inner_mac_header = skb->data + offset;
-}
 static inline bool skb_transport_header_was_set(const struct sk_buff *skb)
 {
 	return skb->transport_header != NULL;
-- 
1.8.2.1
