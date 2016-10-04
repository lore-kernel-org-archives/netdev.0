From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 2/2] openvswitch: fix vlan subtraction from packet length
Date: Tue,  4 Oct 2016 14:30:02 +0200
Message-ID: <d998778ac99025ce3a703223903c294a2bb9be26.1475583870.git.jbenc@redhat.com>
References: <cover.1475583870.git.jbenc@redhat.com>
Cc: pravin shelar <pshelar@ovn.org>, Eric Garver <e@erig.me>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54222 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753923AbcJDMaS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Oct 2016 08:30:18 -0400
In-Reply-To: <cover.1475583870.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the packet has its vlan tag in skb->vlan_tci, the length of the VLAN
header is not counted in skb->len. It doesn't make sense to subtract it.

In addition, to honor the comment below the code, the VLAN header length
should not be subtracted if there's a vlan tag in skb->vlan_tci. This leads
to the code simply subtracting the Ethernet header length.

Fixes: 018c1dda5ff1 ("openvswitch: 802.1AD Flow handling, actions, vlan parsing, netlink attributes")
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 net/openvswitch/vport.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 8f198437c724..210bafc09bd8 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -483,17 +483,13 @@ EXPORT_SYMBOL_GPL(ovs_vport_deferred_free);
 
 static unsigned int packet_length(const struct sk_buff *skb)
 {
-	unsigned int length = skb->len - ETH_HLEN;
-
-	if (skb_vlan_tagged(skb))
-		length -= VLAN_HLEN;
-
 	/* Don't subtract for multiple VLAN tags. Most (all?) drivers allow
 	 * (ETH_LEN + VLAN_HLEN) in addition to the mtu value, but almost none
 	 * account for 802.1ad. e.g. is_skb_forwardable().
+	 * Note that the first VLAN tag is always in skb->vlan_tci, thus not
+	 * accounted for in skb->len.
 	 */
-
-	return length;
+	return skb->len - ETH_HLEN;
 }
 
 void ovs_vport_send(struct vport *vport, struct sk_buff *skb)
-- 
1.8.3.1
