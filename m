From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] net: reorganize sk_buff for faster
 __copy_skb_header()
Date: Sun, 28 Sep 2014 22:18:47 -0700
Message-ID: <1411967927.30721.10.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411654669.16953.17.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140925164333.7cba128a@redhat.com>
	 <1411657615.16953.21.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411659380.16953.29.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411678046.16953.45.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411680004.16953.57.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:47939 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936AbaI2FSt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 01:18:49 -0400
Received: by mail-pd0-f170.google.com with SMTP id ft15so870349pdb.29
        for <netdev@vger.kernel.org>; Sun, 28 Sep 2014 22:18:48 -0700 (PDT)
In-Reply-To: <1411680004.16953.57.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

With proliferation of bit fields in sk_buff, __copy_skb_header() became
quite expensive, showing as the most expensive function in a GSO
workload.

__copy_skb_header() performance is also critical for non GSO TCP
operations, as it is used from skb_clone()

This patch carefully moves all the fields that were not copied in a
separate zone : cloned, nohdr, fclone, peeked, head_frag, xmit_more

Then I moved all other fields and all other copied fields in a section
delimited by headers_start[0]/headers_end[0] section so that we
can use a single memcpy() call, inlined by compiler using long
word load/stores.

I also tried to make all copies in the natural orders of sk_buff,
to help hardware prefetching.

I made sure sk_buff size did not change.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
v2 : added back ipvs_property, oops ;)

 include/linux/skbuff.h |  133 +++++++++++++++++++++------------------
 net/core/skbuff.c      |   80 ++++++++++++-----------
 2 files changed, 113 insertions(+), 100 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 8eaa62400fca..b6cced304b26 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -527,27 +527,41 @@ struct sk_buff {
 	char			cb[48] __aligned(8);
 
 	unsigned long		_skb_refdst;
+	void			(*destructor)(struct sk_buff *skb);
 #ifdef CONFIG_XFRM
 	struct	sec_path	*sp;
 #endif
+#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
+	struct nf_conntrack	*nfct;
+#endif
+#ifdef CONFIG_BRIDGE_NETFILTER
+	struct nf_bridge_info	*nf_bridge;
+#endif
 	unsigned int		len,
 				data_len;
 	__u16			mac_len,
 				hdr_len;
-	union {
-		__wsum		csum;
-		struct {
-			__u16	csum_start;
-			__u16	csum_offset;
-		};
-	};
-	__u32			priority;
+
+	/* Following fields are _not_ copied in __copy_skb_header()
+	 * Note that queue_mapping is here mostly to fill a hole.
+	 */
 	kmemcheck_bitfield_begin(flags1);
-	__u8			ignore_df:1,
-				cloned:1,
-				ip_summed:2,
+	__u16			queue_mapping;
+	__u8			cloned:1,
 				nohdr:1,
-				nfctinfo:3;
+				fclone:2,
+				peeked:1,
+				head_frag:1,
+				xmit_more:1;
+	/* one bit hole */
+	kmemcheck_bitfield_end(flags1);
+
+
+
+	/* fields enclosed in headers_start/headers_end are copied
+	 * using a single memcpy() in __copy_skb_header()
+	 */
+	__u32			headers_start[0];
 
 /* if you move pkt_type around you also must adapt those constants */
 #ifdef __BIG_ENDIAN_BITFIELD
@@ -558,58 +572,53 @@ struct sk_buff {
 #define PKT_TYPE_OFFSET()	offsetof(struct sk_buff, __pkt_type_offset)
 
 	__u8			__pkt_type_offset[0];
-	__u8			pkt_type:3,
-				fclone:2,
-				ipvs_property:1,
-				peeked:1,
-				nf_trace:1;
-	kmemcheck_bitfield_end(flags1);
-	__be16			protocol;
-
-	void			(*destructor)(struct sk_buff *skb);
-#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
-	struct nf_conntrack	*nfct;
-#endif
-#ifdef CONFIG_BRIDGE_NETFILTER
-	struct nf_bridge_info	*nf_bridge;
-#endif
-
-	int			skb_iif;
-
-	__u32			hash;
-
-	__be16			vlan_proto;
-	__u16			vlan_tci;
-
-#ifdef CONFIG_NET_SCHED
-	__u16			tc_index;	/* traffic control index */
-#ifdef CONFIG_NET_CLS_ACT
-	__u16			tc_verd;	/* traffic control verdict */
-#endif
-#endif
-
-	__u16			queue_mapping;
-	kmemcheck_bitfield_begin(flags2);
-	__u8			xmit_more:1;
-#ifdef CONFIG_IPV6_NDISC_NODETYPE
-	__u8			ndisc_nodetype:2;
-#endif
+	__u8			pkt_type:3;
 	__u8			pfmemalloc:1;
+	__u8			ignore_df:1;
+	__u8			nfctinfo:3;
+
+	__u8			nf_trace:1;
+	__u8			ip_summed:2;
 	__u8			ooo_okay:1;
 	__u8			l4_hash:1;
 	__u8			sw_hash:1;
 	__u8			wifi_acked_valid:1;
 	__u8			wifi_acked:1;
+
 	__u8			no_fcs:1;
-	__u8			head_frag:1;
 	/* Indicates the inner headers are valid in the skbuff. */
 	__u8			encapsulation:1;
 	__u8			encap_hdr_csum:1;
 	__u8			csum_valid:1;
 	__u8			csum_complete_sw:1;
-	/* 1/3 bit hole (depending on ndisc_nodetype presence) */
-	kmemcheck_bitfield_end(flags2);
+	__u8			csum_level:2;
+	__u8			csum_bad:1;
 
+#ifdef CONFIG_IPV6_NDISC_NODETYPE
+	__u8			ndisc_nodetype:2;
+#endif
+	__u8			ipvs_property:1;
+	/* 5 or 7 bit hole */
+
+#ifdef CONFIG_NET_SCHED
+	__u16			tc_index;	/* traffic control index */
+#ifdef CONFIG_NET_CLS_ACT
+	__u16			tc_verd;	/* traffic control verdict */
+#endif
+#endif
+
+	union {
+		__wsum		csum;
+		struct {
+			__u16	csum_start;
+			__u16	csum_offset;
+		};
+	};
+	__u32			priority;
+	int			skb_iif;
+	__u32			hash;
+	__be16			vlan_proto;
+	__u16			vlan_tci;
 #if defined CONFIG_NET_DMA || defined CONFIG_NET_RX_BUSY_POLL
 	union {
 		unsigned int	napi_id;
@@ -625,19 +634,18 @@ struct sk_buff {
 		__u32		reserved_tailroom;
 	};
 
-	kmemcheck_bitfield_begin(flags3);
-	__u8			csum_level:2;
-	__u8			csum_bad:1;
-	/* 13 bit hole */
-	kmemcheck_bitfield_end(flags3);
-
 	__be16			inner_protocol;
 	__u16			inner_transport_header;
 	__u16			inner_network_header;
 	__u16			inner_mac_header;
+
+	__be16			protocol;
 	__u16			transport_header;
 	__u16			network_header;
 	__u16			mac_header;
+
+	__u32			headers_end[0];
+
 	/* These elements must be at the end, see alloc_skb() for details.  */
 	sk_buff_data_t		tail;
 	sk_buff_data_t		end;
@@ -3040,19 +3048,22 @@ static inline void nf_reset_trace(struct sk_buff *skb)
 }
 
 /* Note: This doesn't put any conntrack and bridge info in dst. */
-static inline void __nf_copy(struct sk_buff *dst, const struct sk_buff *src)
+static inline void __nf_copy(struct sk_buff *dst, const struct sk_buff *src,
+			     bool copy)
 {
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 	dst->nfct = src->nfct;
 	nf_conntrack_get(src->nfct);
-	dst->nfctinfo = src->nfctinfo;
+	if (copy)
+		dst->nfctinfo = src->nfctinfo;
 #endif
 #ifdef CONFIG_BRIDGE_NETFILTER
 	dst->nf_bridge  = src->nf_bridge;
 	nf_bridge_get(src->nf_bridge);
 #endif
 #if IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TRACE) || defined(CONFIG_NF_TABLES)
-	dst->nf_trace = src->nf_trace;
+	if (copy)
+		dst->nf_trace = src->nf_trace;
 #endif
 }
 
@@ -3064,7 +3075,7 @@ static inline void nf_copy(struct sk_buff *dst, const struct sk_buff *src)
 #ifdef CONFIG_BRIDGE_NETFILTER
 	nf_bridge_put(dst->nf_bridge);
 #endif
-	__nf_copy(dst, src);
+	__nf_copy(dst, src, true);
 }
 
 #ifdef CONFIG_NETWORK_SECMARK
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d4fdc649112c..4be570a4ab21 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -261,7 +261,6 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 		atomic_t *fclone_ref = (atomic_t *) (child + 1);
 
 		kmemcheck_annotate_bitfield(child, flags1);
-		kmemcheck_annotate_bitfield(child, flags2);
 		skb->fclone = SKB_FCLONE_ORIG;
 		atomic_set(fclone_ref, 1);
 
@@ -675,57 +674,61 @@ void consume_skb(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(consume_skb);
 
+/* Make sure a field is enclosed inside headers_start/headers_end section */
+#define CHECK_SKB_FIELD(field) \
+	BUILD_BUG_ON(offsetof(struct sk_buff, field) <		\
+		     offsetof(struct sk_buff, headers_start));	\
+	BUILD_BUG_ON(offsetof(struct sk_buff, field) >		\
+		     offsetof(struct sk_buff, headers_end));	\
+
 static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 {
 	new->tstamp		= old->tstamp;
+	/* We do not copy old->sk */
 	new->dev		= old->dev;
-	new->transport_header	= old->transport_header;
-	new->network_header	= old->network_header;
-	new->mac_header		= old->mac_header;
-	new->inner_protocol	= old->inner_protocol;
-	new->inner_transport_header = old->inner_transport_header;
-	new->inner_network_header = old->inner_network_header;
-	new->inner_mac_header = old->inner_mac_header;
+	memcpy(new->cb, old->cb, sizeof(old->cb));
 	skb_dst_copy(new, old);
-	skb_copy_hash(new, old);
-	new->ooo_okay		= old->ooo_okay;
-	new->no_fcs		= old->no_fcs;
-	new->encapsulation	= old->encapsulation;
-	new->encap_hdr_csum	= old->encap_hdr_csum;
-	new->csum_valid		= old->csum_valid;
-	new->csum_complete_sw	= old->csum_complete_sw;
 #ifdef CONFIG_XFRM
 	new->sp			= secpath_get(old->sp);
 #endif
-	memcpy(new->cb, old->cb, sizeof(old->cb));
-	new->csum		= old->csum;
-	new->ignore_df		= old->ignore_df;
-	new->pkt_type		= old->pkt_type;
-	new->ip_summed		= old->ip_summed;
-	skb_copy_queue_mapping(new, old);
-	new->priority		= old->priority;
-#if IS_ENABLED(CONFIG_IP_VS)
-	new->ipvs_property	= old->ipvs_property;
+	__nf_copy(new, old, false);
+
+	/* Note : this field could be in headers_start/headers_end section
+	 * It is not yet because we do not want to have a 16 bit hole
+	 */
+	new->queue_mapping = old->queue_mapping;
+
+	memcpy(&new->headers_start, &old->headers_start,
+	       offsetof(struct sk_buff, headers_end) -
+	       offsetof(struct sk_buff, headers_start));
+	CHECK_SKB_FIELD(protocol);
+	CHECK_SKB_FIELD(csum);
+	CHECK_SKB_FIELD(hash);
+	CHECK_SKB_FIELD(priority);
+	CHECK_SKB_FIELD(skb_iif);
+	CHECK_SKB_FIELD(vlan_proto);
+	CHECK_SKB_FIELD(vlan_tci);
+	CHECK_SKB_FIELD(transport_header);
+	CHECK_SKB_FIELD(network_header);
+	CHECK_SKB_FIELD(mac_header);
+	CHECK_SKB_FIELD(inner_protocol);
+	CHECK_SKB_FIELD(inner_transport_header);
+	CHECK_SKB_FIELD(inner_network_header);
+	CHECK_SKB_FIELD(inner_mac_header);
+	CHECK_SKB_FIELD(mark);
+#ifdef CONFIG_NETWORK_SECMARK
+	CHECK_SKB_FIELD(secmark);
+#endif
+#ifdef CONFIG_NET_RX_BUSY_POLL
+	CHECK_SKB_FIELD(napi_id);
 #endif
-	new->pfmemalloc		= old->pfmemalloc;
-	new->protocol		= old->protocol;
-	new->mark		= old->mark;
-	new->skb_iif		= old->skb_iif;
-	__nf_copy(new, old);
 #ifdef CONFIG_NET_SCHED
-	new->tc_index		= old->tc_index;
+	CHECK_SKB_FIELD(tc_index);
 #ifdef CONFIG_NET_CLS_ACT
-	new->tc_verd		= old->tc_verd;
+	CHECK_SKB_FIELD(tc_verd);
 #endif
 #endif
-	new->vlan_proto		= old->vlan_proto;
-	new->vlan_tci		= old->vlan_tci;
-
-	skb_copy_secmark(new, old);
 
-#ifdef CONFIG_NET_RX_BUSY_POLL
-	new->napi_id	= old->napi_id;
-#endif
 }
 
 /*
@@ -876,7 +879,6 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
 			return NULL;
 
 		kmemcheck_annotate_bitfield(n, flags1);
-		kmemcheck_annotate_bitfield(n, flags2);
 		n->fclone = SKB_FCLONE_UNAVAILABLE;
 	}
 
