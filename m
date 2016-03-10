From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH nf-next v10 7/8] openvswitch: Delay conntrack helper call for new connections.
Date: Thu, 10 Mar 2016 10:54:22 -0800
Message-ID: <1457636063-92746-8-git-send-email-jarno@ovn.org>
References: <1457636063-92746-1-git-send-email-jarno@ovn.org>
Cc: netdev@vger.kernel.org, dev@openvswitch.org, jarno@ovn.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:42123 "EHLO
	relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752517AbcCJSzC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 13:55:02 -0500
In-Reply-To: <1457636063-92746-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to help connections that are not confirmed, so we can
delay helping new connections to the time when they are confirmed.
This change is needed for NAT support, and having this as a separate
patch will make the following NAT patch a bit easier to review.

Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
---
 net/openvswitch/conntrack.c | 21 ++++++++++++++++-----
 1 file changed, 16 insertions(+), 5 deletions(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 85256b3..f718b72 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -483,7 +483,11 @@ static int __ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
 	 * actually run the packet through conntrack twice unless it's for a
 	 * different zone.
 	 */
-	if (!skb_nfct_cached(net, key, info, skb)) {
+	bool cached = skb_nfct_cached(net, key, info, skb);
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn *ct;
+
+	if (!cached) {
 		struct nf_conn *tmpl = info->ct;
 		int err;
 
@@ -506,11 +510,18 @@ static int __ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
 			return -ENOENT;
 
 		ovs_ct_update_key(skb, info, key, true);
+	}
 
-		if (ovs_ct_helper(skb, info->family) != NF_ACCEPT) {
-			WARN_ONCE(1, "helper rejected packet");
-			return -EINVAL;
-		}
+	/* Call the helper only if:
+	 * - nf_conntrack_in() was executed above ("!cached") for a confirmed
+	 *   connection, or
+	 * - When committing an unconfirmed connection.
+	 */
+	ct = nf_ct_get(skb, &ctinfo);
+	if (ct && (nf_ct_is_confirmed(ct) ? !cached : info->commit) &&
+	    ovs_ct_helper(skb, info->family) != NF_ACCEPT) {
+		WARN_ONCE(1, "helper rejected packet");
+		return -EINVAL;
 	}
 
 	return 0;
-- 
2.1.4
