From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 2/2] bonding: COW before overwriting the destination MAC address
Date: Thu,  3 Mar 2011 12:25:21 +0800
Message-ID: <1299126321-9300-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:40804 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756041Ab1CCE0G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 23:26:06 -0500
Received: by pwi15 with SMTP id 15so140621pwi.19
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2011 20:26:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When there is a ptype handler holding a clone of this skb, whose
destination MAC addresse is overwritten, the owner of this handler may
get a corrupted packet.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 drivers/net/bonding/bond_main.c |    5 +++++
 1 file changed, 5 insertions(+)
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 912b416..211be52 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1513,6 +1513,11 @@ static struct sk_buff *bond_handle_frame(struct sk_buff *skb)
 	    skb->pkt_type == PACKET_HOST) {
 		u16 *dest = (u16 *) eth_hdr(skb)->h_dest;
 
+		if (unlikely(skb_cow_head(skb,
+					  skb->data - skb_mac_header(skb)))) {
+			kfree_skb(skb);
+			return NULL;
+		}
 		memcpy(dest, bond_dev->dev_addr, ETH_ALEN);
 	}
 
