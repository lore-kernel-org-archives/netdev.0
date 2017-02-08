From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH v2 net-next 2/9] openvswitch: Unionize ovs_key_ct_label with a u32 array.
Date: Wed,  8 Feb 2017 11:32:03 -0800
Message-ID: <1486582330-31152-3-git-send-email-jarno@ovn.org>
References: <1486582330-31152-1-git-send-email-jarno@ovn.org>
Cc: jarno@ovn.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:49926 "EHLO
        slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751045AbdBHTeE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 14:34:04 -0500
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net [217.70.183.195])
        by slow1-d.mail.gandi.net (Postfix) with ESMTP id 01A0A486745
        for <netdev@vger.kernel.org>; Wed,  8 Feb 2017 20:33:28 +0100 (CET)
In-Reply-To: <1486582330-31152-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the array of labels in struct ovs_key_ct_label an union, adding a
u32 array of the same byte size as the existing u8 array.  It is
faster to loop through the labels 32 bits at the time, which is also
the alignment of netlink attributes.

Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
---
 include/uapi/linux/openvswitch.h | 8 ++++++--
 net/openvswitch/conntrack.c      | 9 +++++----
 2 files changed, 11 insertions(+), 6 deletions(-)

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
index b91baa2..6730f09 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -277,8 +277,9 @@ static int ovs_ct_set_labels(struct sk_buff *skb, struct sw_flow_key *key,
 	if (!cl || sizeof(cl->bits) < OVS_CT_LABELS_LEN)
 		return -ENOSPC;
 
-	err = nf_connlabels_replace(ct, (u32 *)labels, (u32 *)mask,
-				    OVS_CT_LABELS_LEN / sizeof(u32));
+	err = nf_connlabels_replace(ct, labels->ct_labels_32,
+				    mask->ct_labels_32,
+				    OVS_CT_LABELS_LEN_32);
 	if (err)
 		return err;
 
@@ -852,8 +853,8 @@ static bool labels_nonzero(const struct ovs_key_ct_labels *labels)
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
