From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 16/18] openvswitch: Delay conntrack helper call for new connections.
Date: Tue, 15 Mar 2016 02:28:00 +0100
Message-ID: <1458005282-24665-17-git-send-email-pablo@netfilter.org>
References: <1458005282-24665-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1458005282-24665-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarno Rajahalme <jarno@ovn.org>

There is no need to help connections that are not confirmed, so we can
delay helping new connections to the time when they are confirmed.
This change is needed for NAT support, and having this as a separate
patch will make the following NAT patch a bit easier to review.

Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
Acked-by: Joe Stringer <joe@ovn.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
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

