From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 2/6] net: Infrastructure for checksum unnecessary conversions
Date: Sun, 31 Aug 2014 15:12:42 -0700
Message-ID: <1409523166-9215-3-git-send-email-therbert@google.com>
References: <1409523166-9215-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:41350 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752031AbaHaWNO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Aug 2014 18:13:14 -0400
Received: by mail-pa0-f49.google.com with SMTP id kq14so10681109pab.36
        for <netdev@vger.kernel.org>; Sun, 31 Aug 2014 15:13:13 -0700 (PDT)
In-Reply-To: <1409523166-9215-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For normal path, added skb_checksum_try_convert which is called
to attempt to convert CHECKSUM_UNNECESSARY to CHECKSUM_COMPLETE. The
primary condition to allow this is that ip_summed is CHECKSUM_NONE
and csum_valid is true, which will be the state after consuming
a CHECKSUM_UNNECESSARY.

For GRO path, added skb_gro_checksum_try_convert which is the GRO
analogue of skb_checksum_try_convert. The primary condition to allow
this is that NAPI_GRO_CB(skb)->csum_cnt == 0 and
NAPI_GRO_CB(skb)->csum_valid is set. This implies that we have consumed
all available CHECKSUM_UNNECESSARY checksums in the GRO path.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/netdevice.h | 20 ++++++++++++++++++++
 include/linux/skbuff.h    | 20 ++++++++++++++++++++
 2 files changed, 40 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 024d8c1..9d4ab3e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2233,6 +2233,26 @@ static inline void skb_gro_incr_csum_unnecessary(struct sk_buff *skb)
 #define skb_gro_checksum_simple_validate(skb)				\
 	__skb_gro_checksum_validate(skb, 0, false, 0, null_compute_pseudo)
 
+static inline bool __skb_gro_checksum_convert_check(struct sk_buff *skb)
+{
+	return (NAPI_GRO_CB(skb)->csum_cnt == 0 &&
+		!NAPI_GRO_CB(skb)->csum_valid);
+}
+
+static inline void __skb_gro_checksum_convert(struct sk_buff *skb,
+					      __sum16 check, __wsum pseudo)
+{
+	NAPI_GRO_CB(skb)->csum = ~pseudo;
+	NAPI_GRO_CB(skb)->csum_valid = 1;
+}
+
+#define skb_gro_checksum_try_convert(skb, proto, check, compute_pseudo)	\
+do {									\
+	if (__skb_gro_checksum_convert_check(skb))			\
+		__skb_gro_checksum_convert(skb, check,			\
+					   compute_pseudo(skb, proto));	\
+} while (0)
+
 static inline int dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 				  unsigned short type,
 				  const void *daddr, const void *saddr,
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 23710a2..02529fc 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2942,6 +2942,26 @@ static inline __wsum null_compute_pseudo(struct sk_buff *skb, int proto)
 #define skb_checksum_simple_validate(skb)				\
 	__skb_checksum_validate(skb, 0, true, false, 0, null_compute_pseudo)
 
+static inline bool __skb_checksum_convert_check(struct sk_buff *skb)
+{
+	return (skb->ip_summed == CHECKSUM_NONE &&
+		skb->csum_valid && !skb->csum_bad);
+}
+
+static inline void __skb_checksum_convert(struct sk_buff *skb,
+					  __sum16 check, __wsum pseudo)
+{
+	skb->csum = ~pseudo;
+	skb->ip_summed = CHECKSUM_COMPLETE;
+}
+
+#define skb_checksum_try_convert(skb, proto, check, compute_pseudo)	\
+do {									\
+	if (__skb_checksum_convert_check(skb))				\
+		__skb_checksum_convert(skb, check,			\
+				       compute_pseudo(skb, proto));	\
+} while (0)
+
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 void nf_conntrack_destroy(struct nf_conntrack *nfct);
 static inline void nf_conntrack_put(struct nf_conntrack *nfct)
-- 
2.1.0.rc2.206.gedb03e5
