From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH nf-next v8 4/8] openvswitch: Update the CT state key only after nf_conntrack_in().
Date: Tue,  8 Mar 2016 16:24:40 -0800
Message-ID: <1457483084-13944-4-git-send-email-jarno@ovn.org>
References: <1457483084-13944-1-git-send-email-jarno@ovn.org>
Cc: netdev@vger.kernel.org, dev@openvswitch.org, jarno@ovn.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1457483084-13944-1-git-send-email-jarno@ovn.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Only a successful nf_conntrack_in() call can effect a connection state
change, so if suffices to update the key only after the
nf_conntrack_in() returns.

This change is needed for the later NAT patches.

Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
---
 net/openvswitch/conntrack.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 8cd0110..da804d3 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -382,7 +382,8 @@ static bool skb_nfct_cached(const struct net *net, const struct sk_buff *skb,
 }
 
 /* Pass 'skb' through conntrack in 'net', using zone configured in 'info', if
- * not done already.  Update key with new CT state.
+ * not done already.  Update key with new CT state after passing the packet
+ * through conntrack.
  * Note that if the packet is deemed invalid by conntrack, skb->nfct will be
  * set to NULL and 0 will be returned.
  */
@@ -411,14 +412,14 @@ static int __ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
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

