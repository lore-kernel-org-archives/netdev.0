From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 2/2 v2] bonding: COW before overwriting the destination MAC address
Date: Thu,  3 Mar 2011 15:07:14 +0800
Message-ID: <1299136034-5549-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:43957 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750923Ab1CCHIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 02:08:14 -0500
Received: by iwn34 with SMTP id 34so685306iwn.19
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2011 23:08:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When there is a ptype handler holding a clone of this skb, whose
destination MAC addresse is overwritten, the owner of this handler may
get a corrupted packet.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
v2: fix the bug in the previous one. Thank him.
 drivers/net/bonding/bond_main.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 912b416..7b7ca97 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1511,9 +1511,13 @@ static struct sk_buff *bond_handle_frame(struct sk_buff *skb)
 	if (bond_dev->priv_flags & IFF_MASTER_ALB &&
 	    bond_dev->priv_flags & IFF_BRIDGE_PORT &&
 	    skb->pkt_type == PACKET_HOST) {
-		u16 *dest = (u16 *) eth_hdr(skb)->h_dest;
 
-		memcpy(dest, bond_dev->dev_addr, ETH_ALEN);
+		if (unlikely(skb_cow_head(skb,
+					  skb->data - skb_mac_header(skb)))) {
+			kfree_skb(skb);
+			return NULL;
+		}
+		memcpy(eth_hdr(skb)->h_dest, bond_dev->dev_addr, ETH_ALEN);
 	}
 
 	return skb;
