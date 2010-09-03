From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 2/4] tipc: Ensure outgoing messages on Ethernet have sufficient headroom
Date: Fri,  3 Sep 2010 14:33:40 -0400
Message-ID: <1283538822-25718-2-git-send-email-paul.gortmaker@windriver.com>
References: <1283538822-25718-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:54531 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753915Ab0ICSdp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 14:33:45 -0400
In-Reply-To: <1283538822-25718-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Add code to expand the headroom of an outgoing TIPC message if the
sk_buff has insufficient room to hold the header for the associated
Ethernet device.  This change is necessary to ensure that messages
TIPC does not create itself (eg. incoming messages that are being
routed to another node) do not cause problems, since TIPC has no
control over the amount of headroom available in such messages.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/eth_media.c |   25 +++++++++++++++++--------
 1 files changed, 17 insertions(+), 8 deletions(-)

diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index 6230d16..81253d0 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -72,17 +72,26 @@ static int send_msg(struct sk_buff *buf, struct tipc_bearer *tb_ptr,
 {
 	struct sk_buff *clone;
 	struct net_device *dev;
+	int delta;
 
 	clone = skb_clone(buf, GFP_ATOMIC);
-	if (clone) {
-		skb_reset_network_header(clone);
-		dev = ((struct eth_bearer *)(tb_ptr->usr_handle))->dev;
-		clone->dev = dev;
-		dev_hard_header(clone, dev, ETH_P_TIPC,
-				 &dest->dev_addr.eth_addr,
-				 dev->dev_addr, clone->len);
-		dev_queue_xmit(clone);
+	if (!clone)
+		return 0;
+
+	dev = ((struct eth_bearer *)(tb_ptr->usr_handle))->dev;
+	delta = dev->hard_header_len - skb_headroom(buf);
+
+	if ((delta > 0) &&
+	    pskb_expand_head(clone, SKB_DATA_ALIGN(delta), 0, GFP_ATOMIC)) {
+		kfree_skb(clone);
+		return 0;
 	}
+
+	skb_reset_network_header(clone);
+	clone->dev = dev;
+	dev_hard_header(clone, dev, ETH_P_TIPC, &dest->dev_addr.eth_addr,
+			dev->dev_addr, clone->len);
+	dev_queue_xmit(clone);
 	return 0;
 }
 
-- 
1.7.2.1

