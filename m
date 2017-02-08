From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH v2 net-next 5/9] openvswitch: Refactor labels initialization.
Date: Wed,  8 Feb 2017 11:32:06 -0800
Message-ID: <1486582330-31152-6-git-send-email-jarno@ovn.org>
References: <1486582330-31152-1-git-send-email-jarno@ovn.org>
Cc: jarno@ovn.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:48556 "EHLO
        slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751064AbdBHTeG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 14:34:06 -0500
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net [217.70.183.195])
        by slow1-d.mail.gandi.net (Postfix) with ESMTP id C20A147EB80
        for <netdev@vger.kernel.org>; Wed,  8 Feb 2017 20:33:32 +0100 (CET)
In-Reply-To: <1486582330-31152-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactoring conntrack labels initialization makes chenges in later
patches easier to review.

Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
---
 net/openvswitch/conntrack.c | 104 ++++++++++++++++++++++++++------------------
 1 file changed, 62 insertions(+), 42 deletions(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 6e3e5e7..026f4a9 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -229,19 +229,12 @@ int ovs_ct_put_key(const struct sw_flow_key *key, struct sk_buff *skb)
 	return 0;
 }
 
-static int ovs_ct_set_mark(struct sk_buff *skb, struct sw_flow_key *key,
+static int ovs_ct_set_mark(struct nf_conn *ct, struct sw_flow_key *key,
 			   u32 ct_mark, u32 mask)
 {
 #if IS_ENABLED(CONFIG_NF_CONNTRACK_MARK)
-	enum ip_conntrack_info ctinfo;
-	struct nf_conn *ct;
 	u32 new_mark;
 
-	/* The connection could be invalid, in which case set_mark is no-op. */
-	ct = nf_ct_get(skb, &ctinfo);
-	if (!ct)
-		return 0;
-
 	new_mark = ct_mark | (ct->mark & ~(mask));
 	if (ct->mark != new_mark) {
 		ct->mark = new_mark;
@@ -256,50 +249,66 @@ static int ovs_ct_set_mark(struct sk_buff *skb, struct sw_flow_key *key,
 #endif
 }
 
-static int ovs_ct_set_labels(struct sk_buff *skb, struct sw_flow_key *key,
-			     const struct ovs_key_ct_labels *labels,
-			     const struct ovs_key_ct_labels *mask)
+static struct nf_conn_labels *ovs_ct_get_conn_labels(struct nf_conn *ct)
 {
-	enum ip_conntrack_info ctinfo;
 	struct nf_conn_labels *cl;
-	struct nf_conn *ct;
-
-	/* The connection could be invalid, in which case set_label is no-op.*/
-	ct = nf_ct_get(skb, &ctinfo);
-	if (!ct)
-		return 0;
 
 	cl = nf_ct_labels_find(ct);
 	if (!cl) {
 		nf_ct_labels_ext_add(ct);
 		cl = nf_ct_labels_find(ct);
 	}
+
+	return cl;
+}
+
+/* Initialize labels for a new, to be committed conntrack entry.  Note that
+ * since the new connection is not yet confirmed, and thus no-one else has
+ * access to it's labels, we simply write them over.  Also, we refrain from
+ * triggering events, as receiving change events before the create event would
+ * be confusing.
+ */
+static int ovs_ct_init_labels(struct nf_conn *ct, struct sw_flow_key *key,
+			      const struct ovs_key_ct_labels *labels,
+			      const struct ovs_key_ct_labels *mask)
+{
+	struct nf_conn_labels *cl;
+	u32 *dst;
+	int i;
+
+	cl = ovs_ct_get_conn_labels(ct);
 	if (!cl)
 		return -ENOSPC;
 
-	if (nf_ct_is_confirmed(ct)) {
-		/* Triggers a change event, which makes sense only for
-		 * confirmed connections.
-		 */
-		int err = nf_connlabels_replace(ct, labels->ct_labels_32,
-						mask->ct_labels_32,
-						OVS_CT_LABELS_LEN_32);
-		if (err)
-			return err;
-	} else {
-		u32 *dst = (u32 *)cl->bits;
-		int i;
+	dst = (u32 *)cl->bits;
+	for (i = 0; i < OVS_CT_LABELS_LEN_32; i++)
+		dst[i] = (dst[i] & ~mask->ct_labels_32[i]) |
+			(labels->ct_labels_32[i] & mask->ct_labels_32[i]);
 
-		/* No-one else has access to the non-confirmed entry, copy
-		 * labels over, keeping any bits we are not explicitly setting.
-		 */
-		for (i = 0; i < OVS_CT_LABELS_LEN_32; i++)
-			dst[i] = (dst[i] & ~mask->ct_labels_32[i]) |
-				(labels->ct_labels_32[i] &
-				 mask->ct_labels_32[i]);
-	}
+	memcpy(&key->ct.labels, cl->bits, OVS_CT_LABELS_LEN);
+
+	return 0;
+}
+
+static int ovs_ct_set_labels(struct nf_conn *ct, struct sw_flow_key *key,
+			     const struct ovs_key_ct_labels *labels,
+			     const struct ovs_key_ct_labels *mask)
+{
+	struct nf_conn_labels *cl;
+	int err;
+
+	cl = ovs_ct_get_conn_labels(ct);
+	if (!cl)
+		return -ENOSPC;
+
+	err = nf_connlabels_replace(ct, labels->ct_labels_32,
+				    mask->ct_labels_32,
+				    OVS_CT_LABELS_LEN_32);
+	if (err)
+		return err;
+
+	memcpy(&key->ct.labels, cl->bits, OVS_CT_LABELS_LEN);
 
-	ovs_ct_get_labels(ct, &key->ct.labels);
 	return 0;
 }
 
@@ -881,25 +890,36 @@ static int ovs_ct_commit(struct net *net, struct sw_flow_key *key,
 			 const struct ovs_conntrack_info *info,
 			 struct sk_buff *skb)
 {
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn *ct;
 	int err;
 
 	err = __ovs_ct_lookup(net, key, info, skb);
 	if (err)
 		return err;
 
+	/* The connection could be invalid, in which case this is a no-op.*/
+	ct = nf_ct_get(skb, &ctinfo);
+	if (!ct)
+		return 0;
+
 	/* Apply changes before confirming the connection so that the initial
 	 * conntrack NEW netlink event carries the values given in the CT
 	 * action.
 	 */
 	if (info->mark.mask) {
-		err = ovs_ct_set_mark(skb, key, info->mark.value,
+		err = ovs_ct_set_mark(ct, key, info->mark.value,
 				      info->mark.mask);
 		if (err)
 			return err;
 	}
 	if (labels_nonzero(&info->labels.mask)) {
-		err = ovs_ct_set_labels(skb, key, &info->labels.value,
-					&info->labels.mask);
+		if (!nf_ct_is_confirmed(ct))
+			err = ovs_ct_init_labels(ct, key, &info->labels.value,
+						 &info->labels.mask);
+		else
+			err = ovs_ct_set_labels(ct, key, &info->labels.value,
+						&info->labels.mask);
 		if (err)
 			return err;
 	}
-- 
2.1.4
