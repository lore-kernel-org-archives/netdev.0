From: Vishakha Narvekar <Vishakha.Narvekar@dell.com>
Subject: [PATCH] net: 8021q: skip packets if the vlan is down
Date: Tue,  3 Oct 2017 16:13:29 -0400
Message-ID: <1507061609-11972-1-git-send-email-Vishakha.Narvekar@dell.com>
Cc: allen.hubbe@dell.com, andrew.boyer@dell.com,
        Vishakha Narvekar <Vishakha.Narvekar@dell.com>,
        "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa2.dell-outbound.iphmx.com ([68.232.149.220]:32108 "EHLO
        esa2.dell-outbound.iphmx.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751756AbdJCUNy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 16:13:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the vlan is down, free the packet instead of proceeding with other
processing, or counting it as received.  If vlan interfaces are used
as slaves for bonding, with arp monitoring for connectivity, if the rx
counter is seen to be incrementing, then the bond device will not
observe that the interface is down.

CC: David S. Miller <davem@davemloft.net>
Signed-off-by: Vishakha Narvekar <Vishakha.Narvekar@dell.com>
---
I don't know if this is the appropriate change, or if it is supposed to
work as before.  This change seemed to fix the behavior for bonding.

 net/8021q/vlan_core.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index e2ed698..0bc31de 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -21,6 +21,12 @@ bool vlan_do_receive(struct sk_buff **skbp)
 	if (unlikely(!skb))
 		return false;
 
+	if (unlikely(!(vlan_dev->flags & IFF_UP))) {
+		kfree_skb(skb);
+		*skbp = NULL;
+		return false;
+	}
+
 	skb->dev = vlan_dev;
 	if (unlikely(skb->pkt_type == PACKET_OTHERHOST)) {
 		/* Our lower layer thinks this is not local, let's make sure.
-- 
1.8.3.1
