From: Jarno Rajahalme <jrajahalme@nicira.com>
Subject: [RFC PATCH net-next v2 7/8] openvswitch: Delay conntrack helper call for new connections.
Date: Fri,  6 Nov 2015 16:06:07 -0800
Message-ID: <1446854768-38299-8-git-send-email-jrajahalme@nicira.com>
References: <1446854768-38299-1-git-send-email-jrajahalme@nicira.com>
Cc: netfilter-devel@vger.kernel.org, dev@openvswitch.org,
	jrajahalme@nicira.com
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1446854768-38299-1-git-send-email-jrajahalme@nicira.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no need to help connections that are not confirmed, so we can
delay helping new connections to the time when they are confirmed.
This change is needed for NAT support, and having this as a separate
patch will make the following NAT patch a bit easier to review.

Signed-off-by: Jarno Rajahalme <jrajahalme@nicira.com>
---
 net/openvswitch/conntrack.c | 20 +++++++++++++++-----
 1 file changed, 15 insertions(+), 5 deletions(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 7aa38fa..ba44287 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -458,6 +458,7 @@ static bool skb_nfct_cached(struct net *net,
 /* Pass 'skb' through conntrack in 'net', using zone configured in 'info', if
  * not done already.  Update key with new CT state after passing the packet
  * through conntrack.
+ * Note that invalid packets are accepted while the skb->nfct remains unset!
  */
 static int __ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
 			   const struct ovs_conntrack_info *info,
@@ -468,7 +469,11 @@ static int __ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
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
 
@@ -491,11 +496,16 @@ static int __ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
 			return -ENOENT;
 
 		ovs_ct_update_key(skb, key, true);
+	}
 
-		if (ovs_ct_helper(skb, info->family) != NF_ACCEPT) {
-			WARN_ONCE(1, "helper rejected packet");
-			return -EINVAL;
-		}
+	/* Call the helper right after nf_conntrack_in() for confirmed
+	 * connections, but only when commiting for unconfirmed connections.
+	 */
+	ct = nf_ct_get(skb, &ctinfo);
+	if (ct && (nf_ct_is_confirmed(ct) ? !cached : info->commit)
+	    && ovs_ct_helper(skb, info->family) != NF_ACCEPT) {
+		WARN_ONCE(1, "helper rejected packet");
+		return -EINVAL;
 	}
 
 	return 0;
-- 
2.1.4

