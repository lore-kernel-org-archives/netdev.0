From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH nf-next v9 6/8] openvswitch: Handle NF_REPEAT in conntrack action.
Date: Wed,  9 Mar 2016 15:10:22 -0800
Message-ID: <1457565024-27300-6-git-send-email-jarno@ovn.org>
References: <1457565024-27300-1-git-send-email-jarno@ovn.org>
Cc: netdev@vger.kernel.org, dev@openvswitch.org, jarno@ovn.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:53379 "EHLO
	relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754228AbcCIXKn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 18:10:43 -0500
In-Reply-To: <1457565024-27300-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Repeat the nf_conntrack_in() call when it returns NF_REPEAT.  This
avoids dropping a SYN packet re-opening an existing TCP connection.

Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
Acked-by: Joe Stringer <joe@ovn.org>
---
 net/openvswitch/conntrack.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index b838536..92613de 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -485,6 +485,7 @@ static int __ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
 	 */
 	if (!skb_nfct_cached(net, key, info, skb)) {
 		struct nf_conn *tmpl = info->ct;
+		int err;
 
 		/* Associate skb with specified zone. */
 		if (tmpl) {
@@ -495,8 +496,13 @@ static int __ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
 			skb->nfctinfo = IP_CT_NEW;
 		}
 
-		if (nf_conntrack_in(net, info->family, NF_INET_PRE_ROUTING,
-				    skb) != NF_ACCEPT)
+		/* Repeat if requested, see nf_iterate(). */
+		do {
+			err = nf_conntrack_in(net, info->family,
+					      NF_INET_PRE_ROUTING, skb);
+		} while (err == NF_REPEAT);
+
+		if (err != NF_ACCEPT)
 			return -ENOENT;
 
 		ovs_ct_update_key(skb, info, key, true);
-- 
2.1.4
