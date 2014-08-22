From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 net-next 1/6] net: skb_gro_checksum_* functions
Date: Fri, 22 Aug 2014 13:33:47 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1408221315390.1355@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f74.google.com ([209.85.219.74]:46335 "EHLO
	mail-oa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751894AbaHVUds (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 16:33:48 -0400
Received: by mail-oa0-f74.google.com with SMTP id eb12so2285879oac.1
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2014 13:33:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add skb_gro_checksum_validate, skb_gro_checksum_validate_zero_check,
and skb_gro_checksum_simple_validate, and __skb_gro_checksum_complete.
These are the cognates of the normal checksum functions but are used
in the gro_receive path and operate on GRO related fields in sk_buffs.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/netdevice.h | 76 +++++++++++++++++++++++++++++++++++++++++++++--
 net/core/dev.c            | 34 ++++++++++++++++++++-
 2 files changed, 107 insertions(+), 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3837739..0fac884 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1883,7 +1883,13 @@ struct napi_gro_cb {
 	u16	proto;
 
 	/* Used in udp_gro_receive */
-	u16	udp_mark;
+	u8	udp_mark:1;
+
+	/* GRO checksum is valid */
+	u8	csum_valid:1;
+
+	/* Number encapsulation layers crossed */
+	u8	encapsulation;
 
 	/* used to support CHECKSUM_COMPLETE for tunneling protocols */
 	__wsum	csum;
@@ -2153,11 +2159,77 @@ static inline void *skb_gro_network_header(struct sk_buff *skb)
 static inline void skb_gro_postpull_rcsum(struct sk_buff *skb,
 					const void *start, unsigned int len)
 {
-	if (skb->ip_summed == CHECKSUM_COMPLETE)
+	if (NAPI_GRO_CB(skb)->csum_valid)
 		NAPI_GRO_CB(skb)->csum = csum_sub(NAPI_GRO_CB(skb)->csum,
 						  csum_partial(start, len, 0));
 }
 
+/* GRO checksum functions. These are logical equivalents of the normal
+ * checksum functions (in skbuff.h) except that they operate on the GRO
+ * offsets and fields in sk_buff.
+ */
+
+__sum16 __skb_gro_checksum_complete(struct sk_buff *skb);
+
+static inline bool __skb_gro_checksum_validate_needed(struct sk_buff *skb,
+						      bool zero_okay,
+						      __sum16 check)
+{
+	return (skb->ip_summed != CHECKSUM_PARTIAL &&
+		(skb->ip_summed != CHECKSUM_UNNECESSARY ||
+		 (NAPI_GRO_CB(skb)->encapsulation > skb->encapsulation)) &&
+		(!zero_okay || check));
+}
+
+static inline __sum16 __skb_gro_checksum_validate_complete(struct sk_buff *skb,
+							   __wsum psum)
+{
+	if (NAPI_GRO_CB(skb)->csum_valid &&
+	    !csum_fold(csum_add(psum, NAPI_GRO_CB(skb)->csum)))
+		return 0;
+
+	NAPI_GRO_CB(skb)->csum = psum;
+
+	return __skb_gro_checksum_complete(skb);
+}
+
+/* Update skb for CHECKSUM_UNNECESSARY when we verified a top level
+ * checksum or an encapsulated one during GRO. This saves work
+ * if we fallback to normal path with the packet.
+ */
+static inline void skb_gro_incr_csum_unnecessary(struct sk_buff *skb)
+{
+	if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
+		if (NAPI_GRO_CB(skb)->encapsulation)
+			skb->encapsulation = 1;
+	} else if (skb->ip_summed != CHECKSUM_PARTIAL) {
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+		skb->encapsulation = 0;
+	}
+}
+
+#define __skb_gro_checksum_validate(skb, proto, zero_okay, check,	\
+				    compute_pseudo)			\
+({									\
+	__sum16 __ret = 0;						\
+	if (__skb_gro_checksum_validate_needed(skb, zero_okay, check))	\
+		__ret = __skb_gro_checksum_validate_complete(skb,	\
+				compute_pseudo(skb, proto));		\
+	if (!__ret)							\
+		skb_gro_incr_csum_unnecessary(skb);			\
+	__ret;								\
+})
+
+#define skb_gro_checksum_validate(skb, proto, compute_pseudo)		\
+	__skb_gro_checksum_validate(skb, proto, false, 0, compute_pseudo)
+
+#define skb_gro_checksum_validate_zero_check(skb, proto, check,		\
+					     compute_pseudo)		\
+	__skb_gro_checksum_validate(skb, proto, true, check, compute_pseudo)
+
+#define skb_gro_checksum_simple_validate(skb)				\
+	__skb_gro_checksum_validate(skb, 0, false, 0, null_compute_pseudo)
+
 static inline int dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 				  unsigned short type,
 				  const void *daddr, const void *saddr,
diff --git a/net/core/dev.c b/net/core/dev.c
index b65a505..2a0d416 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3963,7 +3963,13 @@ static enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff
 		goto normal;
 
 	gro_list_prepare(napi, skb);
-	NAPI_GRO_CB(skb)->csum = skb->csum; /* Needed for CHECKSUM_COMPLETE */
+
+	if (skb->ip_summed == CHECKSUM_COMPLETE) {
+		NAPI_GRO_CB(skb)->csum = skb->csum;
+		NAPI_GRO_CB(skb)->csum_valid = 1;
+	} else {
+		NAPI_GRO_CB(skb)->csum_valid = 0;
+	}
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(ptype, head, list) {
@@ -3976,6 +3982,7 @@ static enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff
 		NAPI_GRO_CB(skb)->flush = 0;
 		NAPI_GRO_CB(skb)->free = 0;
 		NAPI_GRO_CB(skb)->udp_mark = 0;
+		NAPI_GRO_CB(skb)->encapsulation = 0;
 
 		pp = ptype->callbacks.gro_receive(&napi->gro_list, skb);
 		break;
@@ -4206,6 +4213,31 @@ gro_result_t napi_gro_frags(struct napi_struct *napi)
 }
 EXPORT_SYMBOL(napi_gro_frags);
 
+/* Compute the checksum from gro_offset and return the folded value
+ * after adding in any pseudo checksum.
+ */
+__sum16 __skb_gro_checksum_complete(struct sk_buff *skb)
+{
+	__wsum wsum;
+	__sum16 sum;
+
+	wsum = skb_checksum(skb, skb_gro_offset(skb), skb_gro_len(skb), 0);
+
+	/* NAPI_GRO_CB(skb)->csum holds pseudo checksum */
+	sum = csum_fold(csum_add(NAPI_GRO_CB(skb)->csum, wsum));
+	if (likely(!sum)) {
+		if (unlikely(skb->ip_summed == CHECKSUM_COMPLETE) &&
+		    !skb->csum_complete_sw)
+			netdev_rx_csum_fault(skb->dev);
+	}
+
+	NAPI_GRO_CB(skb)->csum = wsum;
+	NAPI_GRO_CB(skb)->csum_valid = 1;
+
+	return sum;
+}
+EXPORT_SYMBOL(__skb_gro_checksum_complete);
+
 /*
  * net_rps_action_and_irq_enable sends any pending IPI's for rps.
  * Note: called with local irq disabled, but exits with local irq enabled.
-- 
2.1.0.rc2.206.gedb03e5
