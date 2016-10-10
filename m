From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net 2/3] openvswitch: fix vlan subtraction from packet length
Date: Mon, 10 Oct 2016 17:02:43 +0200
Message-ID: <310ec523056b4f4747e800333498ef27ad1248aa.1476111550.git.jbenc@redhat.com>
References: <cover.1476111550.git.jbenc@redhat.com>
Cc: pravin shelar <pshelar@ovn.org>, Eric Garver <e@erig.me>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49466 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753100AbcJJPDF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Oct 2016 11:03:05 -0400
In-Reply-To: <cover.1476111550.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the packet has its vlan tag in skb->vlan_tci, the length of the VLAN
header is not counted in skb->len. It doesn't make sense to subtract it.

Fixes: 018c1dda5ff1 ("openvswitch: 802.1AD Flow handling, actions, vlan parsing, netlink attributes")
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 net/openvswitch/vport.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 8f198437c724..7387418ac514 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -485,7 +485,8 @@ static unsigned int packet_length(const struct sk_buff *skb)
 {
 	unsigned int length = skb->len - ETH_HLEN;
 
-	if (skb_vlan_tagged(skb))
+	if (!skb_vlan_tag_present(skb) &&
+	    eth_type_vlan(skb->protocol))
 		length -= VLAN_HLEN;
 
 	/* Don't subtract for multiple VLAN tags. Most (all?) drivers allow
-- 
1.8.3.1
