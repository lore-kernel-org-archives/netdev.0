From: Joe Stringer <joe@ovn.org>
Subject: [PATCH net 2/2] openvswitch: Respect conntrack zone even if invalid
Date: Wed,  9 Dec 2015 14:07:40 -0800
Message-ID: <1449698860-20685-2-git-send-email-joe@ovn.org>
References: <1449698860-20685-1-git-send-email-joe@ovn.org>
Cc: Joe Stringer <joe@ovn.org>, pshelar@nicira.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:37140 "EHLO
	relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751303AbbLIWH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 17:07:56 -0500
In-Reply-To: <1449698860-20685-1-git-send-email-joe@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If userspace executes ct(zone=1), and the connection tracker determines
that the packet is invalid, then the ct_zone flow key field is populated
with the default zone rather than the zone that was specified. Even
though connection tracking failed, this field should be updated with the
value that the action specified. Fix the issue.

Fixes: 7f8a436eaa2c ("openvswitch: Add conntrack action")
Signed-off-by: Joe Stringer <joe@ovn.org>
---
 net/openvswitch/conntrack.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 585a5aa81f89..3e8892216f94 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -143,6 +143,7 @@ static void __ovs_ct_update_key(struct sw_flow_key *key, u8 state,
  * previously sent the packet to conntrack via the ct action.
  */
 static void ovs_ct_update_key(const struct sk_buff *skb,
+			      const struct ovs_conntrack_info *info,
 			      struct sw_flow_key *key, bool post_ct)
 {
 	const struct nf_conntrack_zone *zone = &nf_ct_zone_dflt;
@@ -160,13 +161,15 @@ static void ovs_ct_update_key(const struct sk_buff *skb,
 		zone = nf_ct_zone(ct);
 	} else if (post_ct) {
 		state = OVS_CS_F_TRACKED | OVS_CS_F_INVALID;
+		if (info)
+			zone = &info->zone;
 	}
 	__ovs_ct_update_key(key, state, zone, ct);
 }
 
 void ovs_ct_fill_key(const struct sk_buff *skb, struct sw_flow_key *key)
 {
-	ovs_ct_update_key(skb, key, false);
+	ovs_ct_update_key(skb, NULL, key, false);
 }
 
 int ovs_ct_put_key(const struct sw_flow_key *key, struct sk_buff *skb)
@@ -420,7 +423,7 @@ static int __ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
 		}
 	}
 
-	ovs_ct_update_key(skb, key, true);
+	ovs_ct_update_key(skb, info, key, true);
 
 	return 0;
 }
-- 
2.1.4
