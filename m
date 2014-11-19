From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 6/9] vlan: introduce __vlan_insert_tag helper which does not free skb
Date: Wed, 19 Nov 2014 14:05:00 +0100
Message-ID: <1416402303-25341-7-git-send-email-jiri@resnulli.us>
References: <1416402303-25341-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, pshelar@nicira.com,
	therbert@google.com, edumazet@google.com, willemb@google.com,
	dborkman@redhat.com, mst@redhat.com, fw@strlen.de,
	Paul.Durrant@citrix.com, tgraf@suug.ch, cwang@twopensource.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:38814 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753964AbaKSNFM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 08:05:12 -0500
Received: by mail-wg0-f45.google.com with SMTP id b13so771810wgh.32
        for <netdev@vger.kernel.org>; Wed, 19 Nov 2014 05:05:11 -0800 (PST)
In-Reply-To: <1416402303-25341-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's a need for helper which inserts vlan tag but does not free the
skb in case of an error.

Suggested-by: Pravin Shelar <pshelar@nicira.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
Acked-by: Pravin B Shelar <pshelar@nicira.com>
---
 include/linux/if_vlan.h | 45 ++++++++++++++++++++++++++++++++++-----------
 1 file changed, 34 insertions(+), 11 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 291e670..515a35e 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -282,28 +282,24 @@ static inline bool vlan_hw_offload_capable(netdev_features_t features,
 }
 
 /**
- * vlan_insert_tag - regular VLAN tag inserting
+ * __vlan_insert_tag - regular VLAN tag inserting
  * @skb: skbuff to tag
  * @vlan_proto: VLAN encapsulation protocol
  * @vlan_tci: VLAN TCI to insert
  *
  * Inserts the VLAN tag into @skb as part of the payload
- * Returns a VLAN tagged skb. If a new skb is created, @skb is freed.
- *
- * Following the skb_unshare() example, in case of error, the calling function
- * doesn't have to worry about freeing the original skb.
+ * Returns error if skb_cow_head failes.
  *
  * Does not change skb->protocol so this function can be used during receive.
  */
-static inline struct sk_buff *vlan_insert_tag(struct sk_buff *skb,
-					      __be16 vlan_proto, u16 vlan_tci)
+static inline int __vlan_insert_tag(struct sk_buff *skb,
+				    __be16 vlan_proto, u16 vlan_tci)
 {
 	struct vlan_ethhdr *veth;
 
-	if (skb_cow_head(skb, VLAN_HLEN) < 0) {
-		dev_kfree_skb_any(skb);
-		return NULL;
-	}
+	if (skb_cow_head(skb, VLAN_HLEN) < 0)
+		return -ENOMEM;
+
 	veth = (struct vlan_ethhdr *)skb_push(skb, VLAN_HLEN);
 
 	/* Move the mac addresses to the beginning of the new header. */
@@ -316,6 +312,33 @@ static inline struct sk_buff *vlan_insert_tag(struct sk_buff *skb,
 	/* now, the TCI */
 	veth->h_vlan_TCI = htons(vlan_tci);
 
+	return 0;
+}
+
+/**
+ * vlan_insert_tag - regular VLAN tag inserting
+ * @skb: skbuff to tag
+ * @vlan_proto: VLAN encapsulation protocol
+ * @vlan_tci: VLAN TCI to insert
+ *
+ * Inserts the VLAN tag into @skb as part of the payload
+ * Returns a VLAN tagged skb. If a new skb is created, @skb is freed.
+ *
+ * Following the skb_unshare() example, in case of error, the calling function
+ * doesn't have to worry about freeing the original skb.
+ *
+ * Does not change skb->protocol so this function can be used during receive.
+ */
+static inline struct sk_buff *vlan_insert_tag(struct sk_buff *skb,
+					      __be16 vlan_proto, u16 vlan_tci)
+{
+	int err;
+
+	err = __vlan_insert_tag(skb, vlan_proto, vlan_tci);
+	if (err) {
+		dev_kfree_skb_any(skb);
+		return NULL;
+	}
 	return skb;
 }
 
-- 
1.9.3
