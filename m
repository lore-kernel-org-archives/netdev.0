From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH v2 net-next 3/9] openvswitch: Simplify labels length logic.
Date: Wed,  8 Feb 2017 11:32:04 -0800
Message-ID: <1486582330-31152-4-git-send-email-jarno@ovn.org>
References: <1486582330-31152-1-git-send-email-jarno@ovn.org>
Cc: jarno@ovn.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:55180 "EHLO
        slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751058AbdBHTeE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 14:34:04 -0500
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net [217.70.183.195])
        by slow1-d.mail.gandi.net (Postfix) with ESMTP id 76B5647EB03
        for <netdev@vger.kernel.org>; Wed,  8 Feb 2017 20:33:30 +0100 (CET)
In-Reply-To: <1486582330-31152-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since 23014011ba42 ("netfilter: conntrack: support a fixed size of 128
distinct labels"), the size of conntrack labels extension has fixed to
128 bits, so we do not need to check for labels sizes shorter than 128
at run-time.  This patch simplifies labels length logic accordingly,
but allows the conntrack labels size to be increased in the future
without breaking the build.  In the event of conntrack labels
increasing in size OVS would still be able to deal with the 128 first
label bits.

Suggested-by: Joe Stringer <joe@ovn.org>
Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
---
 net/openvswitch/conntrack.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 6730f09..a07e5cd 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -129,22 +129,22 @@ static u32 ovs_ct_get_mark(const struct nf_conn *ct)
 #endif
 }
 
+/* Guard against conntrack labels max size shrinking below 128 bits. */
+#if NF_CT_LABELS_MAX_SIZE < 16
+#error NF_CT_LABELS_MAX_SIZE must be at least 16 bytes
+#endif
+
 static void ovs_ct_get_labels(const struct nf_conn *ct,
 			      struct ovs_key_ct_labels *labels)
 {
 	struct nf_conn_labels *cl = ct ? nf_ct_labels_find(ct) : NULL;
 
-	if (cl) {
-		size_t len = sizeof(cl->bits);
-
-		if (len > OVS_CT_LABELS_LEN)
-			len = OVS_CT_LABELS_LEN;
-		else if (len < OVS_CT_LABELS_LEN)
-			memset(labels, 0, OVS_CT_LABELS_LEN);
-		memcpy(labels, cl->bits, len);
-	} else {
+	if (cl)
+		memcpy(labels, cl->bits,
+		       sizeof(cl->bits) > OVS_CT_LABELS_LEN
+		       ? OVS_CT_LABELS_LEN : sizeof(cl->bits));
+	else
 		memset(labels, 0, OVS_CT_LABELS_LEN);
-	}
 }
 
 static void __ovs_ct_update_key(struct sw_flow_key *key, u8 state,
@@ -274,7 +274,7 @@ static int ovs_ct_set_labels(struct sk_buff *skb, struct sw_flow_key *key,
 		nf_ct_labels_ext_add(ct);
 		cl = nf_ct_labels_find(ct);
 	}
-	if (!cl || sizeof(cl->bits) < OVS_CT_LABELS_LEN)
+	if (!cl)
 		return -ENOSPC;
 
 	err = nf_connlabels_replace(ct, labels->ct_labels_32,
-- 
2.1.4
