From: linzhang <xiaolou4617@gmail.com>
Subject: [PATCH] net: ieee802154: fix net_device reference release too early
Date: Thu, 18 May 2017 15:50:07 +0800
Message-ID: <1495093807-11000-1-git-send-email-xiaolou4617@gmail.com>
Cc: linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linzhang <xiaolou4617@gmail.com>
To: aar@pengutronix.de, stefan@osg.samsung.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36054 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754670AbdERHuO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 03:50:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the kernel oops when release net_device reference in 
advance. In function raw_sendmsg(i think the dgram_sendmsg has the same 
problem), there is a race condition between dev_put and dev_queue_xmit
when the device is gong that maybe lead to dev_queue_ximt to see
an illegal net_device pointer.

So i think that dev_put should be behind of the dev_queue_xmit.

Also, explicit set skb->sk is needless, sock_alloc_send_skb is
already set it.

Signed-off-by: linzhang <xiaolou4617@gmail.com>
---
 net/ieee802154/socket.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/ieee802154/socket.c b/net/ieee802154/socket.c
index eedba76..a60658c 100644
--- a/net/ieee802154/socket.c
+++ b/net/ieee802154/socket.c
@@ -301,15 +301,14 @@ static int raw_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 		goto out_skb;
 
 	skb->dev = dev;
-	skb->sk  = sk;
 	skb->protocol = htons(ETH_P_IEEE802154);
 
-	dev_put(dev);
-
 	err = dev_queue_xmit(skb);
 	if (err > 0)
 		err = net_xmit_errno(err);
 
+	dev_put(dev);
+
 	return err ?: size;
 
 out_skb:
@@ -690,15 +689,14 @@ static int dgram_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 		goto out_skb;
 
 	skb->dev = dev;
-	skb->sk  = sk;
 	skb->protocol = htons(ETH_P_IEEE802154);
 
-	dev_put(dev);
-
 	err = dev_queue_xmit(skb);
 	if (err > 0)
 		err = net_xmit_errno(err);
 
+	dev_put(dev);
+
 	return err ?: size;
 
 out_skb:
-- 
1.8.3.1
