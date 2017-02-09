From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH v4 net-next 07/10] openvswitch: Inherit master's labels.
Date: Thu,  9 Feb 2017 11:21:58 -0800
Message-ID: <1486668121-45709-8-git-send-email-jarno@ovn.org>
References: <1486668121-45709-1-git-send-email-jarno@ovn.org>
Cc: jarno@ovn.org, davem@davemloft.net, joe@ovn.org, pshelar@ovn.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:38061 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754090AbdBITW3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 14:22:29 -0500
In-Reply-To: <1486668121-45709-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We avoid calling into nf_conntrack_in() for expected connections, as
that would remove the expectation that we want to stick around until
we are ready to commit the connection.  Instead, we do a lookup in the
expectation table directly.  However, after a successful expectation
lookup we have set the flow key label field from the master
connection, whereas nf_conntrack_in() does not do this.  This leads to
master's labels being inherited after an expectation lookup, but those
labels not being inherited after the corresponding conntrack action
with a commit flag.

This patch resolves the problem by changing the commit code path to
also inherit the master's labels to the expected connection.
Resolving this conflict in favor of inheriting the labels allows more
information be passed from the master connection to related
connections, which would otherwise be much harder if the 32 bits in
the connmark are not enough.  Labels can still be set explicitly, so
this change only affects the default values of the labels in presense
of a master connection.

Fixes: 7f8a436eaa2c ("openvswitch: Add conntrack action")
Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
Acked-by: Pravin B Shelar <pshelar@ovn.org>
---
 net/openvswitch/conntrack.c | 45 +++++++++++++++++++++++++++++++--------------
 1 file changed, 31 insertions(+), 14 deletions(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 7c5bb98..f989ccf 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -73,6 +73,8 @@ struct ovs_conntrack_info {
 #endif
 };
 
+static bool labels_nonzero(const struct ovs_key_ct_labels *labels);
+
 static void __ovs_ct_free_action(struct ovs_conntrack_info *ct_info);
 
 static u16 key_to_nfproto(const struct sw_flow_key *key)
@@ -270,18 +272,32 @@ static int ovs_ct_init_labels(struct nf_conn *ct, struct sw_flow_key *key,
 			      const struct ovs_key_ct_labels *labels,
 			      const struct ovs_key_ct_labels *mask)
 {
-	struct nf_conn_labels *cl;
-	u32 *dst;
-	int i;
+	struct nf_conn_labels *cl, *master_cl;
+	bool have_mask = labels_nonzero(mask);
+
+	/* Inherit master's labels to the related connection? */
+	master_cl = ct->master ? nf_ct_labels_find(ct->master) : NULL;
+
+	if (!master_cl && !have_mask)
+		return 0;   /* Nothing to do. */
 
 	cl = ovs_ct_get_conn_labels(ct);
 	if (!cl)
 		return -ENOSPC;
 
-	dst = (u32 *)cl->bits;
-	for (i = 0; i < OVS_CT_LABELS_LEN_32; i++)
-		dst[i] = (dst[i] & ~mask->ct_labels_32[i]) |
-			(labels->ct_labels_32[i] & mask->ct_labels_32[i]);
+	/* Inherit the master's labels, if any. */
+	if (master_cl)
+		*cl = *master_cl;
+
+	if (have_mask) {
+		u32 *dst = (u32 *)cl->bits;
+		int i;
+
+		for (i = 0; i < OVS_CT_LABELS_LEN_32; i++)
+			dst[i] = (dst[i] & ~mask->ct_labels_32[i]) |
+				(labels->ct_labels_32[i]
+				 & mask->ct_labels_32[i]);
+	}
 
 	memcpy(&key->ct.labels, cl->bits, OVS_CT_LABELS_LEN);
 
@@ -909,13 +925,14 @@ static int ovs_ct_commit(struct net *net, struct sw_flow_key *key,
 		if (err)
 			return err;
 	}
-	if (labels_nonzero(&info->labels.mask)) {
-		if (!nf_ct_is_confirmed(ct))
-			err = ovs_ct_init_labels(ct, key, &info->labels.value,
-						 &info->labels.mask);
-		else
-			err = ovs_ct_set_labels(ct, key, &info->labels.value,
-						&info->labels.mask);
+	if (!nf_ct_is_confirmed(ct)) {
+		err = ovs_ct_init_labels(ct, key, &info->labels.value,
+					 &info->labels.mask);
+		if (err)
+			return err;
+	} else if (labels_nonzero(&info->labels.mask)) {
+		err = ovs_ct_set_labels(ct, key, &info->labels.value,
+					&info->labels.mask);
 		if (err)
 			return err;
 	}
-- 
2.1.4
