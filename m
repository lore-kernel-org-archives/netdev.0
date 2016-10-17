From: Eric Garver <e@erig.me>
Subject: [PATCH net v2] flow_dissector: Check skb for VLAN only if skb specified.
Date: Mon, 17 Oct 2016 16:30:12 -0400
Message-ID: <1476736212-21238-1-git-send-email-e@erig.me>
Cc: Hadar Hen Zion <hadarh@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51666 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758012AbcJQUaO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Oct 2016 16:30:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes a panic when calling eth_get_headlen(). Noticed on i40e driver.

Fixes: d5709f7ab776 ("flow_dissector: For stripped vlan, get vlan info from skb->vlan_tci")
Signed-off-by: Eric Garver <e@erig.me>
---
 net/core/flow_dissector.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 1a7b80f73376..44e6ba9d3a6b 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -247,12 +247,10 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 	case htons(ETH_P_8021Q): {
 		const struct vlan_hdr *vlan;
 
-		if (skb_vlan_tag_present(skb))
+		if (skb && skb_vlan_tag_present(skb))
 			proto = skb->protocol;
 
-		if (!skb_vlan_tag_present(skb) ||
-		    proto == cpu_to_be16(ETH_P_8021Q) ||
-		    proto == cpu_to_be16(ETH_P_8021AD)) {
+		if (eth_type_vlan(proto)) {
 			struct vlan_hdr _vlan;
 
 			vlan = __skb_header_pointer(skb, nhoff, sizeof(_vlan),
-- 
2.5.5
