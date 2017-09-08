From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH net] net: qualcomm: rmnet: Fix a double free
Date: Fri, 8 Sep 2017 13:23:57 +0300
Message-ID: <20170908102356.tzysh6qaiesd2umz@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:27227 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751548AbdIHKYY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 06:24:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is called from rmnet_map_ingress_handler().  When the
rmnet_map_deaggregate() returns NULL then the caller calls
consume_skb(skb) which frees the skb.  The kfree_skb() on this error
path leads to a double free.

Fixes: ceed73a2cf4a ("drivers: net: ethernet: qualcomm: rmnet: Initial implementation")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
This is from static analysis and not tested.

diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_data.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_data.c
index 557c9bf1a469..0335fce54201 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_data.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_data.c
@@ -95,10 +95,8 @@ struct sk_buff *rmnet_map_deaggregate(struct sk_buff *skb)
 	skb_pull(skb, packet_len);
 
 	/* Some hardware can send us empty frames. Catch them */
-	if (ntohs(maph->pkt_len) == 0) {
-		kfree_skb(skb);
+	if (ntohs(maph->pkt_len) == 0)
 		return NULL;
-	}
 
 	return skbn;
 }
