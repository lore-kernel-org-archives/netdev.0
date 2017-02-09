From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH v4 net-next 04/10] openvswitch: Unionize ovs_key_ct_label with a u32 array.
Date: Thu,  9 Feb 2017 11:21:55 -0800
Message-ID: <1486668121-45709-5-git-send-email-jarno@ovn.org>
References: <1486668121-45709-1-git-send-email-jarno@ovn.org>
Cc: jarno@ovn.org, davem@davemloft.net, joe@ovn.org, pshelar@ovn.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:51796 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753304AbdBITW2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 14:22:28 -0500
In-Reply-To: <1486668121-45709-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the array of labels in struct ovs_key_ct_label an union, adding a
u32 array of the same byte size as the existing u8 array.  It is
faster to loop through the labels 32 bits at the time, which is also
the alignment of netlink attributes.

Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
Acked-by: Joe Stringer <joe@ovn.org>
Acked-by: Pravin B Shelar <pshelar@ovn.org>
---
 include/uapi/linux/openvswitch.h |  8 ++++++--
 net/openvswitch/conntrack.c      | 15 ++++++++-------
 2 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 375d812..96aee34 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -446,9 +446,13 @@ struct ovs_key_nd {
 	__u8	nd_tll[ETH_ALEN];
 };
 
-#define OVS_CT_LABELS_LEN	16
+#define OVS_CT_LABELS_LEN_32	4
+#define OVS_CT_LABELS_LEN	(OVS_CT_LABELS_LEN_32 * sizeof(__u32))
 struct ovs_key_ct_labels {
-	__u8	ct_labels[OVS_CT_LABELS_LEN];
+	union {
+		__u8	ct_labels[OVS_CT_LABELS_LEN];
+		__u32	ct_labels_32[OVS_CT_LABELS_LEN_32];
+	};
 };
 
 /* OVS_KEY_ATTR_CT_STATE flags */
diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index a6ff374..f23934c 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -281,20 +281,21 @@ static int ovs_ct_set_labels(struct sk_buff *skb, struct sw_flow_key *key,
 		/* Triggers a change event, which makes sense only for
 		 * confirmed connections.
 		 */
-		int err = nf_connlabels_replace(ct, (u32 *)labels, (u32 *)mask,
-						OVS_CT_LABELS_LEN / sizeof(u32));
+		int err = nf_connlabels_replace(ct, labels->ct_labels_32,
+						mask->ct_labels_32,
+						OVS_CT_LABELS_LEN_32);
 		if (err)
 			return err;
 	} else {
 		u32 *dst = (u32 *)cl->bits;
-		const u32 *msk = (const u32 *)mask->ct_labels;
-		const u32 *lbl = (const u32 *)labels->ct_labels;
+		const u32 *msk = mask->ct_labels_32;
+		const u32 *lbl = labels->ct_labels_32;
 		int i;
 
 		/* No-one else has access to the non-confirmed entry, copy
 		 * labels over, keeping any bits we are not explicitly setting.
 		 */
-		for (i = 0; i < OVS_CT_LABELS_LEN / sizeof(u32); i++)
+		for (i = 0; i < OVS_CT_LABELS_LEN_32; i++)
 			dst[i] = (dst[i] & ~msk[i]) | (lbl[i] & msk[i]);
 	}
 
@@ -866,8 +867,8 @@ static bool labels_nonzero(const struct ovs_key_ct_labels *labels)
 {
 	size_t i;
 
-	for (i = 0; i < sizeof(*labels); i++)
-		if (labels->ct_labels[i])
+	for (i = 0; i < OVS_CT_LABELS_LEN_32; i++)
+		if (labels->ct_labels_32[i])
 			return true;
 
 	return false;
-- 
2.1.4
