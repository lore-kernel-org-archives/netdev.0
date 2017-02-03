From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH net-next 3/7] openvswitch: Do not trigger events for unconfirmed connection.
Date: Thu,  2 Feb 2017 17:10:02 -0800
Message-ID: <1486084206-109903-3-git-send-email-jarno@ovn.org>
References: <1486084206-109903-1-git-send-email-jarno@ovn.org>
Cc: jarno@ovn.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:54053 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751867AbdBCBKp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 20:10:45 -0500
In-Reply-To: <1486084206-109903-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid triggering change events for setting conntrack mark or labels
before the conntrack entry has been confirmed.  Refactoring on this
patch also makes chenges in later patches easier to review.

Fixes: 182e3042e15d ("openvswitch: Allow matching on conntrack mark")
Fixes: c2ac66735870 ("openvswitch: Allow matching on conntrack label")
Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
---
 net/openvswitch/conntrack.c | 87 ++++++++++++++++++++++++++++++++-------------
 1 file changed, 63 insertions(+), 24 deletions(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 6730f09..a163c44 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -229,23 +229,17 @@ int ovs_ct_put_key(const struct sw_flow_key *key, struct sk_buff *skb)
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
-		nf_conntrack_event_cache(IPCT_MARK, ct);
+		if (nf_ct_is_confirmed(ct))
+			nf_conntrack_event_cache(IPCT_MARK, ct);
 		key->ct.mark = new_mark;
 	}
 
@@ -255,26 +249,59 @@ static int ovs_ct_set_mark(struct sk_buff *skb, struct sw_flow_key *key,
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
-	int err;
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
 	if (!cl || sizeof(cl->bits) < OVS_CT_LABELS_LEN)
+		return NULL;
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
+	if (!cl)
+		return -ENOSPC;
+
+	dst = (u32 *)cl->bits;
+	for (i = 0; i < OVS_CT_LABELS_LEN_32; i++)
+		dst[i] = (dst[i] & ~mask->ct_labels_32[i]) |
+			(labels->ct_labels_32[i] & mask->ct_labels_32[i]);
+
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
 		return -ENOSPC;
 
 	err = nf_connlabels_replace(ct, labels->ct_labels_32,
@@ -283,7 +310,8 @@ static int ovs_ct_set_labels(struct sk_buff *skb, struct sw_flow_key *key,
 	if (err)
 		return err;
 
-	ovs_ct_get_labels(ct, &key->ct.labels);
+	memcpy(&key->ct.labels, cl->bits, OVS_CT_LABELS_LEN);
+
 	return 0;
 }
 
@@ -865,25 +893,36 @@ static int ovs_ct_commit(struct net *net, struct sw_flow_key *key,
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
