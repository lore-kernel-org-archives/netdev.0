From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 15/18] openvswitch: Handle NF_REPEAT in conntrack action.
Date: Tue, 15 Mar 2016 02:27:59 +0100
Message-ID: <1458005282-24665-16-git-send-email-pablo@netfilter.org>
References: <1458005282-24665-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33262 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754068AbcCOB2h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2016 21:28:37 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 49B99114F50
	for <netdev@vger.kernel.org>; Tue, 15 Mar 2016 02:28:34 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 2E894DA39E
	for <netdev@vger.kernel.org>; Tue, 15 Mar 2016 02:28:34 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 380FCDA386
	for <netdev@vger.kernel.org>; Tue, 15 Mar 2016 02:28:31 +0100 (CET)
In-Reply-To: <1458005282-24665-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarno Rajahalme <jarno@ovn.org>

Repeat the nf_conntrack_in() call when it returns NF_REPEAT.  This
avoids dropping a SYN packet re-opening an existing TCP connection.

Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
Acked-by: Joe Stringer <joe@ovn.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/openvswitch/conntrack.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index ae36fe2..85256b3 100644
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
