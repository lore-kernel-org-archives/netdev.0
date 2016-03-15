From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 13/18] openvswitch: Update the CT state key only after nf_conntrack_in().
Date: Tue, 15 Mar 2016 02:27:57 +0100
Message-ID: <1458005282-24665-14-git-send-email-pablo@netfilter.org>
References: <1458005282-24665-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33250 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933335AbcCOB2f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2016 21:28:35 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 1F696114F46
	for <netdev@vger.kernel.org>; Tue, 15 Mar 2016 02:28:34 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 08D62DA8F8
	for <netdev@vger.kernel.org>; Tue, 15 Mar 2016 02:28:34 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id B9CA2DA8F8
	for <netdev@vger.kernel.org>; Tue, 15 Mar 2016 02:28:29 +0100 (CET)
In-Reply-To: <1458005282-24665-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarno Rajahalme <jarno@ovn.org>

Only a successful nf_conntrack_in() call can effect a connection state
change, so it suffices to update the key only after the
nf_conntrack_in() returns.

This change is needed for the later NAT patches.

Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
Acked-by: Joe Stringer <joe@ovn.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/openvswitch/conntrack.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 2c2bf07..a487bb3 100644
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
