From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH net-next v6 3/7] openvswitch: Update the CT state key only after nf_conntrack_in().
Date: Fri,  8 Jan 2016 10:29:56 -0800
Message-ID: <1452277800-46541-4-git-send-email-jarno@ovn.org>
References: <1452277800-46541-1-git-send-email-jarno@ovn.org>
Cc: netfilter-devel@vger.kernel.org, dev@openvswitch.org, jarno@ovn.org
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1452277800-46541-1-git-send-email-jarno@ovn.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Only a successful nf_conntrack_in() call can effect a connection state
change, so if suffices to update the key only after the
nf_conntrack_in() returns.

This change is needed for the later NAT patches.

Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
---
 net/openvswitch/conntrack.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 3045290..51df4eb 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -199,7 +199,6 @@ static int ovs_ct_set_mark(struct sk_buff *skb, struct sw_flow_key *key,
 	struct nf_conn *ct;
 	u32 new_mark;
 
-
 	/* The connection could be invalid, in which case set_mark is no-op. */
 	ct = nf_ct_get(skb, &ctinfo);
 	if (!ct)
@@ -375,6 +374,10 @@ static bool skb_nfct_cached(const struct net *net, const struct sk_buff *skb,
 	return true;
 }
 
+/* Pass 'skb' through conntrack in 'net', using zone configured in 'info', if
+ * not done already.  Update key with new CT state after passing the packet
+ * through conntrack.
+ */
 static int __ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
 			   const struct ovs_conntrack_info *info,
 			   struct sk_buff *skb)
@@ -400,14 +403,14 @@ static int __ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
 				    skb) != NF_ACCEPT)
 			return -ENOENT;
 
+		ovs_ct_update_key(skb, info, key, true);
+
 		if (ovs_ct_helper(skb, info->family) != NF_ACCEPT) {
 			WARN_ONCE(1, "helper rejected packet");
 			return -EINVAL;
 		}
 	}
 
-	ovs_ct_update_key(skb, info, key, true);
-
 	return 0;
 }
 
-- 
2.1.4

