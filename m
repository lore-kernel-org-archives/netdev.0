From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next v10 1/5] net: add skb_vlan_accel helper
Date: Thu,  2 Jun 2016 15:24:42 +0900
Message-ID: <1464848686-7656-2-git-send-email-simon.horman@netronome.com>
References: <1464848686-7656-1-git-send-email-simon.horman@netronome.com>
Cc: dev@openvswitch.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36754 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751730AbcFBGY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 02:24:57 -0400
Received: by mail-pf0-f181.google.com with SMTP id f144so27501388pfa.3
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 23:24:57 -0700 (PDT)
In-Reply-To: <1464848686-7656-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This breaks out some of of skb_vlan_pop into a separate helper.
This new helper moves the outer-most vlan tag present in packet data
into metadata.

The motivation is to allow acceleration VLAN tags without adding a new
one. This is in preparation for a push ethernet header support in Open
vSwitch.

Signed-off-by: Simon Horman <simon.horman@netronome.com>

---
v10 [Simon Horman]
* New patch
---
 include/linux/skbuff.h |  1 +
 net/core/skbuff.c      | 28 +++++++++++++++++++---------
 2 files changed, 20 insertions(+), 9 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index ee38a4127475..5a7eb1c6f211 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2994,6 +2994,7 @@ int skb_vlan_pop(struct sk_buff *skb);
 int skb_vlan_push(struct sk_buff *skb, __be16 vlan_proto, u16 vlan_tci);
 struct sk_buff *pskb_extract(struct sk_buff *skb, int off, int to_copy,
 			     gfp_t gfp);
+int skb_vlan_accel(struct sk_buff *skb);
 
 static inline int memcpy_from_msg(void *data, struct msghdr *msg, int len)
 {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index f2b77e549c03..99bd231e3bf5 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4485,12 +4485,28 @@ pull:
 	return err;
 }
 
-int skb_vlan_pop(struct sk_buff *skb)
+/* Move vlan tag from packet to hw accel tag */
+int skb_vlan_accel(struct sk_buff *skb)
 {
 	u16 vlan_tci;
 	__be16 vlan_proto;
 	int err;
 
+	vlan_proto = skb->protocol;
+	err = __skb_vlan_pop(skb, &vlan_tci);
+	if (unlikely(err))
+		return err;
+
+	__vlan_hwaccel_put_tag(skb, vlan_proto, vlan_tci);
+	return 0;
+}
+EXPORT_SYMBOL(skb_vlan_accel);
+
+int skb_vlan_pop(struct sk_buff *skb)
+{
+	u16 vlan_tci;
+	int err;
+
 	if (likely(skb_vlan_tag_present(skb))) {
 		skb->vlan_tci = 0;
 	} else {
@@ -4503,19 +4519,13 @@ int skb_vlan_pop(struct sk_buff *skb)
 		if (err)
 			return err;
 	}
-	/* move next vlan tag to hw accel tag */
+
 	if (likely((skb->protocol != htons(ETH_P_8021Q) &&
 		    skb->protocol != htons(ETH_P_8021AD)) ||
 		   skb->len < VLAN_ETH_HLEN))
 		return 0;
 
-	vlan_proto = skb->protocol;
-	err = __skb_vlan_pop(skb, &vlan_tci);
-	if (unlikely(err))
-		return err;
-
-	__vlan_hwaccel_put_tag(skb, vlan_proto, vlan_tci);
-	return 0;
+	return skb_vlan_accel(skb);
 }
 EXPORT_SYMBOL(skb_vlan_pop);
 
-- 
2.1.4
