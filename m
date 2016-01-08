From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH net-next v6 5/7] openvswitch: Handle NF_REPEAT in conntrack action.
Date: Fri,  8 Jan 2016 10:29:58 -0800
Message-ID: <1452277800-46541-6-git-send-email-jarno@ovn.org>
References: <1452277800-46541-1-git-send-email-jarno@ovn.org>
Cc: netfilter-devel@vger.kernel.org, dev@openvswitch.org, jarno@ovn.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:43990 "EHLO
	relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754125AbcAHSaq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 13:30:46 -0500
In-Reply-To: <1452277800-46541-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Repeat the nf_conntrack_in() call when it returns NF_REPEAT.  This
avoids dropping a SYN packet re-opening an existing TCP connection.

Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
---
 net/openvswitch/conntrack.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index c49e171..fa9ab25 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -476,6 +476,7 @@ static int __ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
 	 */
 	if (!skb_nfct_cached(net, key, info, skb)) {
 		struct nf_conn *tmpl = info->ct;
+		int err;
 
 		/* Associate skb with specified zone. */
 		if (tmpl) {
@@ -486,8 +487,13 @@ static int __ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
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
