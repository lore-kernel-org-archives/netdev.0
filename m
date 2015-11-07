From: Jarno Rajahalme <jrajahalme@nicira.com>
Subject: [RFC PATCH net-next v2 6/8] openvswitch: Handle NF_REPEAT in conntrack action.
Date: Fri,  6 Nov 2015 16:06:06 -0800
Message-ID: <1446854768-38299-7-git-send-email-jrajahalme@nicira.com>
References: <1446854768-38299-1-git-send-email-jrajahalme@nicira.com>
Cc: netfilter-devel@vger.kernel.org, dev@openvswitch.org,
	jrajahalme@nicira.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36479 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757826AbbKGAGV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2015 19:06:21 -0500
Received: by pacdm15 with SMTP id dm15so112938181pac.3
        for <netdev@vger.kernel.org>; Fri, 06 Nov 2015 16:06:21 -0800 (PST)
In-Reply-To: <1446854768-38299-1-git-send-email-jrajahalme@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Repeat the nf_conntrack_in() call when it returns NF_REPEAT.  This
avoids dropping a SYN packet re-opening an existing TCP connection.

Signed-off-by: Jarno Rajahalme <jrajahalme@nicira.com>
---
 net/openvswitch/conntrack.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 0c371d0..7aa38fa 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -470,6 +470,7 @@ static int __ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
 	 */
 	if (!skb_nfct_cached(net, key, info, skb)) {
 		struct nf_conn *tmpl = info->ct;
+		int err;
 
 		/* Associate skb with specified zone. */
 		if (tmpl) {
@@ -480,8 +481,13 @@ static int __ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
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
 
 		ovs_ct_update_key(skb, key, true);
-- 
2.1.4
