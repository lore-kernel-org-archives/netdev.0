From: Tom Herbert <therbert@google.com>
Subject: [PATCH 8/8] net: Only do flow_dissector hash computation once per
 packet
Date: Tue, 1 Jul 2014 21:33:17 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1407012100500.20189@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f73.google.com ([209.85.213.73]:34742 "EHLO
	mail-yh0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753941AbaGBEdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 00:33:19 -0400
Received: by mail-yh0-f73.google.com with SMTP id f10so1170505yha.4
        for <netdev@vger.kernel.org>; Tue, 01 Jul 2014 21:33:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add sw_hash flag to skbuff to indicate that skb->hash was computed
from flow_dissector. This flag is checked in skb_get_hash to avoid
repeatedly trying to compute the hash (ie. in the case that no L4 hash
can be computed).

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/skbuff.h    | 9 +++++++--
 net/core/flow_dissector.c | 2 ++
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index b297af7..890fb33 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -455,6 +455,7 @@ static inline u32 skb_mstamp_us_delta(const struct skb_mstamp *t1,
  *	@ooo_okay: allow the mapping of a socket to a queue to be changed
  *	@l4_hash: indicate hash is a canonical 4-tuple hash over transport
  *		ports.
+ *	@sw_hash: indicates hash was computed in software stack
  *	@wifi_acked_valid: wifi_acked was set
  *	@wifi_acked: whether frame was acked on wifi or not
  *	@no_fcs:  Request NIC to treat last 4 bytes as Ethernet FCS
@@ -562,6 +563,7 @@ struct sk_buff {
 	__u8			pfmemalloc:1;
 	__u8			ooo_okay:1;
 	__u8			l4_hash:1;
+	__u8			sw_hash:1;
 	__u8			wifi_acked_valid:1;
 	__u8			wifi_acked:1;
 	__u8			no_fcs:1;
@@ -575,7 +577,7 @@ struct sk_buff {
 	__u8			encap_hdr_csum:1;
 	__u8			csum_valid:1;
 	__u8			csum_complete_sw:1;
-	/* 3/5 bit hole (depending on ndisc_nodetype presence) */
+	/* 2/4 bit hole (depending on ndisc_nodetype presence) */
 	kmemcheck_bitfield_end(flags2);
 
 #if defined CONFIG_NET_DMA || defined CONFIG_NET_RX_BUSY_POLL
@@ -830,13 +832,14 @@ static inline void
 skb_set_hash(struct sk_buff *skb, __u32 hash, enum pkt_hash_types type)
 {
 	skb->l4_hash = (type == PKT_HASH_TYPE_L4);
+	skb->sw_hash = 0;
 	skb->hash = hash;
 }
 
 void __skb_get_hash(struct sk_buff *skb);
 static inline __u32 skb_get_hash(struct sk_buff *skb)
 {
-	if (!skb->l4_hash)
+	if (!skb->l4_hash && !skb->sw_hash)
 		__skb_get_hash(skb);
 
 	return skb->hash;
@@ -850,6 +853,7 @@ static inline __u32 skb_get_hash_raw(const struct sk_buff *skb)
 static inline void skb_clear_hash(struct sk_buff *skb)
 {
 	skb->hash = 0;
+	skb->sw_hash = 0;
 	skb->l4_hash = 0;
 }
 
@@ -862,6 +866,7 @@ static inline void skb_clear_hash_if_not_l4(struct sk_buff *skb)
 static inline void skb_copy_hash(struct sk_buff *to, const struct sk_buff *from)
 {
 	to->hash = from->hash;
+	to->sw_hash = from->sw_hash;
 	to->l4_hash = from->l4_hash;
 };
 
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index c5f3912..5f362c1 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -256,6 +256,8 @@ void __skb_get_hash(struct sk_buff *skb)
 	if (keys.ports)
 		skb->l4_hash = 1;
 
+	skb->sw_hash = 1;
+
 	skb->hash = __flow_hash_from_keys(&keys);
 }
 EXPORT_SYMBOL(__skb_get_hash);
-- 
2.0.0.526.g5318336
