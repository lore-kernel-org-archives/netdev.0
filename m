From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH v9 net-next 1/7] net: add skb_vlan_deaccel helper
Date: Wed,  4 May 2016 16:36:27 +0900
Message-ID: <1462347393-22354-2-git-send-email-simon.horman@netronome.com>
References: <1462347393-22354-1-git-send-email-simon.horman@netronome.com>
Cc: Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35940 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757240AbcEDHgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 03:36:53 -0400
Received: by mail-pa0-f46.google.com with SMTP id bt5so20904323pac.3
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 00:36:53 -0700 (PDT)
In-Reply-To: <1462347393-22354-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This breaks out the bulk of skb_vlan_push into a separate helper.
This new helper moves any vlan tag present in metadata into packet data.
The existing skb_vlan_push uses this new helper and then pushes a new
vlan tag (into metadata).

The motivation is to allow deaccelerating VLAN tags without adding a new
one. This is in preparation for a push ethernet header support in Open
vSwitch.

Signed-off-by: Simon Horman <simon.horman@netronome.com>

---
v9 [Simon Horman]
* New patch
---
 include/linux/skbuff.h |  1 +
 net/core/skbuff.c      | 50 ++++++++++++++++++++++++++++++++------------------
 2 files changed, 33 insertions(+), 18 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index c413c588a24f..fa504d28c7e4 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2994,6 +2994,7 @@ int skb_vlan_pop(struct sk_buff *skb);
 int skb_vlan_push(struct sk_buff *skb, __be16 vlan_proto, u16 vlan_tci);
 struct sk_buff *pskb_extract(struct sk_buff *skb, int off, int to_copy,
 			     gfp_t gfp);
+int skb_vlan_deaccel(struct sk_buff *skb);
 
 static inline int memcpy_from_msg(void *data, struct msghdr *msg, int len)
 {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 7a1d48983f81..84a3f8cc4b0a 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4516,30 +4516,44 @@ int skb_vlan_pop(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(skb_vlan_pop);
 
-int skb_vlan_push(struct sk_buff *skb, __be16 vlan_proto, u16 vlan_tci)
+int skb_vlan_deaccel(struct sk_buff *skb)
 {
-	if (skb_vlan_tag_present(skb)) {
-		unsigned int offset = skb->data - skb_mac_header(skb);
-		int err;
+	unsigned int offset;
+	int err;
 
-		/* __vlan_insert_tag expect skb->data pointing to mac header.
-		 * So change skb->data before calling it and change back to
-		 * original position later
-		 */
-		__skb_push(skb, offset);
-		err = __vlan_insert_tag(skb, skb->vlan_proto,
-					skb_vlan_tag_get(skb));
-		if (err) {
-			__skb_pull(skb, offset);
-			return err;
-		}
+	if (!skb_vlan_tag_present(skb))
+		return 0;
 
-		skb->protocol = skb->vlan_proto;
-		skb->mac_len += VLAN_HLEN;
+	offset = skb->data - skb_mac_header(skb);
 
-		skb_postpush_rcsum(skb, skb->data + (2 * ETH_ALEN), VLAN_HLEN);
+	/* __vlan_insert_tag expect skb->data pointing to mac header.
+	 * So change skb->data before calling it and change back to
+	 * original position later
+	 */
+	__skb_push(skb, offset);
+	err = __vlan_insert_tag(skb, skb->vlan_proto, skb_vlan_tag_get(skb));
+	if (err) {
 		__skb_pull(skb, offset);
+		return err;
 	}
+
+	skb->protocol = skb->vlan_proto;
+	skb->mac_len += VLAN_HLEN;
+
+	skb_postpush_rcsum(skb, skb->data + (2 * ETH_ALEN), VLAN_HLEN);
+	__skb_pull(skb, offset);
+
+	return 0;
+}
+EXPORT_SYMBOL(skb_vlan_deaccel);
+
+int skb_vlan_push(struct sk_buff *skb, __be16 vlan_proto, u16 vlan_tci)
+{
+	int err;
+
+	err = skb_vlan_deaccel(skb);
+	if (err)
+		return err;
 	__vlan_hwaccel_put_tag(skb, vlan_proto, vlan_tci);
 	return 0;
 }
-- 
2.7.0.rc3.207.g0ac5344
