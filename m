From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH net-next] openvswitch: Set event bit after initializing labels.
Date: Fri, 17 Feb 2017 18:11:58 -0800
Message-ID: <1487383918-17894-1-git-send-email-jarno@ovn.org>
Cc: jarno@ovn.org, pshelar@ovn.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:60095 "EHLO
        relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751608AbdBRCMm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 21:12:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Connlabels are included in conntrack netlink event messages only if
the IPCT_LABEL bit is set in the event cache (see
ctnetlink_conntrack_event()).  Set it after initializing labels for a
new connection.

Found upon further system testing, where it was noticed that labels
were missing from the conntrack events.

Fixes: 193e30967897 ("openvswitch: Do not trigger events for unconfirmed connections.")
Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
---
 net/openvswitch/conntrack.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index c2d452e..85cd595 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -339,9 +339,7 @@ static struct nf_conn_labels *ovs_ct_get_conn_labels(struct nf_conn *ct)
 
 /* Initialize labels for a new, yet to be committed conntrack entry.  Note that
  * since the new connection is not yet confirmed, and thus no-one else has
- * access to it's labels, we simply write them over.  Also, we refrain from
- * triggering events, as receiving change events before the create event would
- * be confusing.
+ * access to it's labels, we simply write them over.
  */
 static int ovs_ct_init_labels(struct nf_conn *ct, struct sw_flow_key *key,
 			      const struct ovs_key_ct_labels *labels,
@@ -374,6 +372,11 @@ static int ovs_ct_init_labels(struct nf_conn *ct, struct sw_flow_key *key,
 				 & mask->ct_labels_32[i]);
 	}
 
+	/* Labels are included in the IPCTNL_MSG_CT_NEW event only if the
+	 * IPCT_LABEL bit it set in the event cache.
+	 */
+	nf_conntrack_event_cache(IPCT_LABEL, ct);
+
 	memcpy(&key->ct.labels, cl->bits, OVS_CT_LABELS_LEN);
 
 	return 0;
-- 
2.1.4
