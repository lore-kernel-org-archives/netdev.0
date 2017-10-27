From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next] net: qualcomm: rmnet: Support recycling frames to real device
Date: Fri, 27 Oct 2017 14:30:08 -0600
Message-ID: <1509136208-14768-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:35726 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932686AbdJ0UbM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 16:31:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For deaggregation, the real device receives a large linear skb and
passes it on to rmnet. rmnet creates new skbs from this large frame.

If the real device supports recycling, it does not need to allocate
the large skbs during packet reception and can instead reuse them.

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
index 29842cc..7869fcf 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
@@ -108,7 +108,10 @@ static void rmnet_set_skb_proto(struct sk_buff *skb)
 		while ((skbn = rmnet_map_deaggregate(skb)) != NULL)
 			__rmnet_map_ingress_handler(skbn, port);
 
-		consume_skb(skb);
+		if (skb->destructor)
+			skb->destructor(skb);
+		else
+			consume_skb(skb);
 	} else {
 		__rmnet_map_ingress_handler(skb, port);
 	}
-- 
1.9.1
