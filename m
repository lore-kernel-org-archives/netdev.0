From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [PATCH net-next 1/4] flow_dissector: Get vlan info from skb->vlan_tci instead of skb->data
Date: Wed, 10 Aug 2016 16:32:20 +0300
Message-ID: <1470835943-9042-2-git-send-email-hadarh@mellanox.com>
References: <1470835943-9042-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
	Tom Herbert <tom@herbertland.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:45346 "EHLO
	mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933540AbcHJT14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2016 15:27:56 -0400
In-Reply-To: <1470835943-9042-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Early in the datapath skb_vlan_untag function is called, stripped
the vlan from the skb and set skb->vlan_tci and skb->vlan_proto fields.

The current dissection doesn't handle vlan packets correctly.  Vlan
doesn't exist in skb->data anymore when applying flow dissection on the
skb, fix that.

Fixes: 0744dd00c1b1 ('net: introduce skb_flow_dissect()')
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
---
 net/core/flow_dissector.c | 13 +++----------
 1 file changed, 3 insertions(+), 10 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 61ad43f..6060fc2 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -122,7 +122,8 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 
 	if (!data) {
 		data = skb->data;
-		proto = skb->protocol;
+		proto = skb_vlan_tag_present(skb) ?
+			 skb->vlan_proto : skb->protocol;
 		nhoff = skb_network_offset(skb);
 		hlen = skb_headlen(skb);
 	}
@@ -240,13 +241,6 @@ ipv6:
 	}
 	case htons(ETH_P_8021AD):
 	case htons(ETH_P_8021Q): {
-		const struct vlan_hdr *vlan;
-		struct vlan_hdr _vlan;
-
-		vlan = __skb_header_pointer(skb, nhoff, sizeof(_vlan), data, hlen, &_vlan);
-		if (!vlan)
-			goto out_bad;
-
 		if (dissector_uses_key(flow_dissector,
 				       FLOW_DISSECTOR_KEY_VLANID)) {
 			key_tags = skb_flow_dissector_target(flow_dissector,
@@ -256,8 +250,7 @@ ipv6:
 			key_tags->vlan_id = skb_vlan_tag_get_id(skb);
 		}
 
-		proto = vlan->h_vlan_encapsulated_proto;
-		nhoff += sizeof(*vlan);
+		proto = skb->protocol;
 		goto again;
 	}
 	case htons(ETH_P_PPP_SES): {
-- 
1.8.3.1
