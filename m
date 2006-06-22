From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 1/32] [TIPC] Improved tolerance to promiscuous mode interface
Date: Thu, 22 Jun 2006 15:59:14 +0200
Message-ID: <11509847853769-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org, Jon Maloy <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:26262 "EHLO
	mailgw4.ericsson.se") by vger.kernel.org with ESMTP
	id S1030643AbWFVN7v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 09:59:51 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jon Maloy <jon.maloy@ericsson.com>

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/eth_media.c |   20 +++++++++++---------
 1 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index 7a25278..b646619 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -98,17 +98,19 @@ static int recv_msg(struct sk_buff *buf,
 	u32 size;
 
 	if (likely(eb_ptr->bearer)) {
-		size = msg_size((struct tipc_msg *)buf->data);
-		skb_trim(buf, size);
-		if (likely(buf->len == size)) {
-			buf->next = NULL;
-			tipc_recv_msg(buf, eb_ptr->bearer);
-		} else {
-			kfree_skb(buf);
+	       if (likely(!dev->promiscuity) ||
+	           !memcmp(buf->mac.raw,dev->dev_addr,ETH_ALEN) ||
+	           !memcmp(buf->mac.raw,dev->broadcast,ETH_ALEN)) {
+		        size = msg_size((struct tipc_msg *)buf->data);
+	                skb_trim(buf, size);
+	        	if (likely(buf->len == size)) {
+		        	buf->next = NULL;
+			        tipc_recv_msg(buf, eb_ptr->bearer);
+			        return TIPC_OK;
+			}
 		}
-	} else {
-		kfree_skb(buf);
 	}
+	kfree_skb(buf);
 	return TIPC_OK;
 }
 
-- 
1.4.0

