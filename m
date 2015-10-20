From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv3 net 3/4] openvswitch: Mark connections new when not confirmed.
Date: Mon, 19 Oct 2015 19:18:59 -0700
Message-ID: <1445307540-6786-3-git-send-email-joestringer@nicira.com>
References: <1445307540-6786-1-git-send-email-joestringer@nicira.com>
Cc: tgraf@suug.ch, jrajahalme@nicira.com
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36217 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750787AbbJTCTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 22:19:10 -0400
Received: by pacfv9 with SMTP id fv9so5000224pac.3
        for <netdev@vger.kernel.org>; Mon, 19 Oct 2015 19:19:10 -0700 (PDT)
In-Reply-To: <1445307540-6786-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New, related connections are marked as such as part of ovs_ct_lookup(),
but they are not marked as "new" if the commit flag is used. Make this
consistent by setting the "new" flag whenever !nf_ct_is_confirmed(ct).

Reported-by: Jarno Rajahalme <jrajahalme@nicira.com>
Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
v2: Acked.
v3: Took a different approach to fixing the issue.
---
 net/openvswitch/conntrack.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 80bf702715bb..8ad121871834 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -151,6 +151,8 @@ static void ovs_ct_update_key(const struct sk_buff *skb,
 	ct = nf_ct_get(skb, &ctinfo);
 	if (ct) {
 		state = ovs_ct_get_state(ctinfo);
+		if (!nf_ct_is_confirmed(ct))
+			state |= OVS_CS_F_NEW;
 		if (ct->master)
 			state |= OVS_CS_F_RELATED;
 		zone = nf_ct_zone(ct);
@@ -377,7 +379,7 @@ static bool skb_nfct_cached(const struct net *net, const struct sk_buff *skb,
 	return true;
 }
 
-static int __ovs_ct_lookup(struct net *net, const struct sw_flow_key *key,
+static int __ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
 			   const struct ovs_conntrack_info *info,
 			   struct sk_buff *skb)
 {
@@ -408,6 +410,8 @@ static int __ovs_ct_lookup(struct net *net, const struct sw_flow_key *key,
 		}
 	}
 
+	ovs_ct_update_key(skb, key, true);
+
 	return 0;
 }
 
@@ -430,8 +434,6 @@ static int ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
 		err = __ovs_ct_lookup(net, key, info, skb);
 		if (err)
 			return err;
-
-		ovs_ct_update_key(skb, key, true);
 	}
 
 	return 0;
@@ -460,8 +462,6 @@ static int ovs_ct_commit(struct net *net, struct sw_flow_key *key,
 	if (nf_conntrack_confirm(skb) != NF_ACCEPT)
 		return -EINVAL;
 
-	ovs_ct_update_key(skb, key, true);
-
 	return 0;
 }
 
-- 
2.1.4
