From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: [PATCH net-next v5 1/2] net: Use 16bits for *_headers
	fields of struct skbuff
Date: Fri, 24 May 2013 16:02:51 +0900
Message-ID: <1369378972-22728-2-git-send-email-horms@verge.net.au>
References: <1369378972-22728-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
To: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1369378972-22728-1-git-send-email-horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

In order to mitigate ongoing incresase in the size of struct skbuff
use 16 bit integer offsets rather than pointers for inner_*_headers.

This appears to reduce the size of struct skbuff from 0xd0 to 0xc0
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

Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
---
 include/linux/skbuff.h | 119 +++----------------------------------------------
 1 file changed, 6 insertions(+), 113 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 2e0ced1..5663e35 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -509,12 +509,12 @@ struct sk_buff {
 		__u32		reserved_tailroom;
 	};
 
-	sk_buff_data_t		inner_transport_header;
-	sk_buff_data_t		inner_network_header;
-	sk_buff_data_t		inner_mac_header;
-	sk_buff_data_t		transport_header;
-	sk_buff_data_t		network_header;
-	sk_buff_data_t		mac_header;
+	__u16			inner_transport_header;
+	__u16			inner_network_header;
+	__u16			inner_mac_header;
+	__u16			transport_header;
+	__u16			network_header;
+	__u16			mac_header;
 	/* These elements must be at the end, see alloc_skb() for details.  */
 	sk_buff_data_t		tail;
 	sk_buff_data_t		end;
@@ -1527,7 +1527,6 @@ static inline void skb_reset_mac_len(struct sk_buff *skb)
 	skb->mac_len = skb->network_header - skb->mac_header;
 }
 
-#ifdef NET_SKBUFF_DATA_USES_OFFSET
 static inline unsigned char *skb_inner_transport_header(const struct sk_buff
 							*skb)
 {
@@ -1638,112 +1637,6 @@ static inline void skb_set_mac_header(struct sk_buff *skb, const int offset)
 	skb->mac_header += offset;
 }
 
-#else /* NET_SKBUFF_DATA_USES_OFFSET */
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
-static inline bool skb_transport_header_was_set(const struct sk_buff *skb)
-{
-	return skb->transport_header != NULL;
-}
-
-static inline unsigned char *skb_transport_header(const struct sk_buff *skb)
-{
-	return skb->transport_header;
-}
-
-static inline void skb_reset_transport_header(struct sk_buff *skb)
-{
-	skb->transport_header = skb->data;
-}
-
-static inline void skb_set_transport_header(struct sk_buff *skb,
-					    const int offset)
-{
-	skb->transport_header = skb->data + offset;
-}
-
-static inline unsigned char *skb_network_header(const struct sk_buff *skb)
-{
-	return skb->network_header;
-}
-
-static inline void skb_reset_network_header(struct sk_buff *skb)
-{
-	skb->network_header = skb->data;
-}
-
-static inline void skb_set_network_header(struct sk_buff *skb, const int offset)
-{
-	skb->network_header = skb->data + offset;
-}
-
-static inline unsigned char *skb_mac_header(const struct sk_buff *skb)
-{
-	return skb->mac_header;
-}
-
-static inline int skb_mac_header_was_set(const struct sk_buff *skb)
-{
-	return skb->mac_header != NULL;
-}
-
-static inline void skb_reset_mac_header(struct sk_buff *skb)
-{
-	skb->mac_header = skb->data;
-}
-
-static inline void skb_set_mac_header(struct sk_buff *skb, const int offset)
-{
-	skb->mac_header = skb->data + offset;
-}
-#endif /* NET_SKBUFF_DATA_USES_OFFSET */
-
 static inline void skb_probe_transport_header(struct sk_buff *skb,
 					      const int offset_hint)
 {
-- 
1.8.2.1
