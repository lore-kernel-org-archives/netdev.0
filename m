From: Tom Herbert <therbert@google.com>
Subject: [PATCH 1/5] net: skb_gro_checksum_* functions
Date: Fri, 20 Jun 2014 16:37:36 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406201630550.12976@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f73.google.com ([209.85.219.73]:33112 "EHLO
	mail-oa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752788AbaFTXhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 19:37:37 -0400
Received: by mail-oa0-f73.google.com with SMTP id eb12so1104979oac.0
        for <netdev@vger.kernel.org>; Fri, 20 Jun 2014 16:37:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add skb_gro_checksum_validate, skb_gro_checksum_validate_zero_check,
and skb_gro_checksum_simple_validate, and __skb_gro_checksum_complete.
These are the cognates of the normal checksum functions but are used
in the gro_receive path and operate on GRO related fields in sk_buffs.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/netdevice.h | 54 ++++++++++++++++++++++++++++++++++++++++++++++-
 net/core/dev.c            | 31 +++++++++++++++++++++++++++
 net/ipv4/udp_offload.c    |  2 ++
 3 files changed, 86 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 66f9a04..63d8bbc 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1760,7 +1760,10 @@ struct napi_gro_cb {
 	u16	proto;
 
 	/* Used in udp_gro_receive */
-	u16	udp_mark;
+	u8	udp_mark;
+
+	/* Crossed encapsulation boundary */
+	u8	encapsulation;
 
 	/* used to support CHECKSUM_COMPLETE for tunneling protocols */
 	__wsum	csum;
@@ -2035,6 +2038,55 @@ static inline void skb_gro_postpull_rcsum(struct sk_buff *skb,
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
+		 (!skb->encapsulation && NAPI_GRO_CB(skb)->encapsulation)) &&
+		(!zero_okay || check));
+}
+
+static inline __sum16 __skb_gro_checksum_validate_complete(struct sk_buff *skb,
+							   __wsum psum)
+{
+	if (skb->ip_summed == CHECKSUM_COMPLETE &&
+	    !csum_fold(csum_add(psum, NAPI_GRO_CB(skb)->csum)))
+		return 0;
+
+	NAPI_GRO_CB(skb)->csum = psum;
+
+	return __skb_gro_checksum_complete(skb);
+}
+
+#define __skb_gro_checksum_validate(skb, proto, zero_okay, check,	\
+				    compute_pseudo)			\
+({									\
+	__sum16 __ret = 0;						\
+	if (__skb_gro_checksum_validate_needed(skb, zero_okay, check))	\
+		__ret = __skb_gro_checksum_validate_complete(skb,	\
+				compute_pseudo(skb, proto));		\
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
index a04b12f..fe38c2a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3955,6 +3955,7 @@ static enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff
 		NAPI_GRO_CB(skb)->flush = 0;
 		NAPI_GRO_CB(skb)->free = 0;
 		NAPI_GRO_CB(skb)->udp_mark = 0;
+		NAPI_GRO_CB(skb)->encapsulation = 0;
 
 		pp = ptype->callbacks.gro_receive(&napi->gro_list, skb);
 		break;
@@ -4183,6 +4184,36 @@ gro_result_t napi_gro_frags(struct napi_struct *napi)
 }
 EXPORT_SYMBOL(napi_gro_frags);
 
+/* Compute the checksum from gro_offset and return the folded value
+ * after adding in any pseudo checksum. Also, compute the checksum
+ * for bytes preceeding the gro_offset and add that to the GRO checksum
+ * to derive and save checksum for the whole packet.
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
+	/* Save result in checksum complete */
+	skb->csum = skb_checksum(skb, 0, skb_gro_offset(skb), wsum);
+	skb->ip_summed = CHECKSUM_COMPLETE;
+	skb->csum_complete_sw = 1;
+	NAPI_GRO_CB(skb)->csum = wsum;
+
+	return sum;
+}
+EXPORT_SYMBOL(__skb_gro_checksum_complete);
+
 /*
  * net_rps_action_and_irq_enable sends any pending IPI's for rps.
  * Note: called with local irq disabled, but exits with local irq enabled.
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 546d2d4..fb8e6ba 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -176,6 +176,8 @@ static struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *s
 			goto out;
 	}
 
+	NAPI_GRO_CB(skb)->encapsulation = 1;
+
 	rcu_read_lock();
 	uo_priv = rcu_dereference(udp_offload_base);
 	for (; uo_priv != NULL; uo_priv = rcu_dereference(uo_priv->next)) {
-- 
2.0.0.526.g5318336
