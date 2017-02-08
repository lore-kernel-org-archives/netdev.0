From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH v2 net-next 4/9] openvswitch: Do not trigger events for unconfirmed connections.
Date: Wed,  8 Feb 2017 11:32:05 -0800
Message-ID: <1486582330-31152-5-git-send-email-jarno@ovn.org>
References: <1486582330-31152-1-git-send-email-jarno@ovn.org>
Cc: jarno@ovn.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:50402 "EHLO
        slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751060AbdBHTeE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 14:34:04 -0500
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net [217.70.183.195])
        by slow1-d.mail.gandi.net (Postfix) with ESMTP id 5E7B8486389
        for <netdev@vger.kernel.org>; Wed,  8 Feb 2017 20:33:31 +0100 (CET)
In-Reply-To: <1486582330-31152-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Receiving change events before the 'new' event for the connection has
been received can be confusing.  Avoid triggering change events for
setting conntrack mark or labels before the conntrack entry has been
confirmed.

Fixes: 182e3042e15d ("openvswitch: Allow matching on conntrack mark")
Fixes: c2ac66735870 ("openvswitch: Allow matching on conntrack label")
Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
---
 net/openvswitch/conntrack.c | 30 +++++++++++++++++++++++-------
 1 file changed, 23 insertions(+), 7 deletions(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index a07e5cd..6e3e5e7 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -245,7 +245,8 @@ static int ovs_ct_set_mark(struct sk_buff *skb, struct sw_flow_key *key,
 	new_mark = ct_mark | (ct->mark & ~(mask));
 	if (ct->mark != new_mark) {
 		ct->mark = new_mark;
-		nf_conntrack_event_cache(IPCT_MARK, ct);
+		if (nf_ct_is_confirmed(ct))
+			nf_conntrack_event_cache(IPCT_MARK, ct);
 		key->ct.mark = new_mark;
 	}
 
@@ -262,7 +263,6 @@ static int ovs_ct_set_labels(struct sk_buff *skb, struct sw_flow_key *key,
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn_labels *cl;
 	struct nf_conn *ct;
-	int err;
 
 	/* The connection could be invalid, in which case set_label is no-op.*/
 	ct = nf_ct_get(skb, &ctinfo);
@@ -277,11 +277,27 @@ static int ovs_ct_set_labels(struct sk_buff *skb, struct sw_flow_key *key,
 	if (!cl)
 		return -ENOSPC;
 
-	err = nf_connlabels_replace(ct, labels->ct_labels_32,
-				    mask->ct_labels_32,
-				    OVS_CT_LABELS_LEN_32);
-	if (err)
-		return err;
+	if (nf_ct_is_confirmed(ct)) {
+		/* Triggers a change event, which makes sense only for
+		 * confirmed connections.
+		 */
+		int err = nf_connlabels_replace(ct, labels->ct_labels_32,
+						mask->ct_labels_32,
+						OVS_CT_LABELS_LEN_32);
+		if (err)
+			return err;
+	} else {
+		u32 *dst = (u32 *)cl->bits;
+		int i;
+
+		/* No-one else has access to the non-confirmed entry, copy
+		 * labels over, keeping any bits we are not explicitly setting.
+		 */
+		for (i = 0; i < OVS_CT_LABELS_LEN_32; i++)
+			dst[i] = (dst[i] & ~mask->ct_labels_32[i]) |
+				(labels->ct_labels_32[i] &
+				 mask->ct_labels_32[i]);
+	}
 
 	ovs_ct_get_labels(ct, &key->ct.labels);
 	return 0;
-- 
2.1.4
