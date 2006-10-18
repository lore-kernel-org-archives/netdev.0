From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] netpoll: retry memory leak
Date: Wed, 18 Oct 2006 12:38:46 -0700
Message-ID: <20061018123846.6dd1ab83@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:65436 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161323AbWJRTiq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 15:38:46 -0400
To: Linus Torvalds <torvalds@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If netpoll uses up it's retries, it should drop the skb
not leak memory.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 net/core/netpoll.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index ead5920..c375fde 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -273,10 +273,8 @@ static void netpoll_send_skb(struct netp
 	int status;
 	struct netpoll_info *npinfo;
 
-	if (!np || !np->dev || !netif_running(np->dev)) {
-		__kfree_skb(skb);
-		return;
-	}
+	if (!np || !np->dev || !netif_running(np->dev))
+		goto free_skb;
 
 	npinfo = np->dev->npinfo;
 
@@ -314,6 +312,8 @@ static void netpoll_send_skb(struct netp
 		netpoll_poll(np);
 		udelay(50);
 	} while (npinfo->tries > 0);
+free_skb:
+	__kfree_skb(skb);
 }
 
 void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
-- 
1.4.2.3

