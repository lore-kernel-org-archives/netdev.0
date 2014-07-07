From: Andrey Utkin <andrey.krieger.utkin@gmail.com>
Subject: [PATCH] appletalk: Fix socket referencing in skb
Date: Mon,  7 Jul 2014 23:22:50 +0300
Message-ID: <1404764570-24120-1-git-send-email-andrey.krieger.utkin@gmail.com>
Cc: acme@ghostprotocols.net, davem@davemloft.net,
	eric.dumazet@gmail.com,
	Andrey Utkin <andrey.krieger.utkin@gmail.com>
To: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Setting just skb->sk without taking its reference and setting a
destructor is invalid. However, in the places where this was done, skb
is used in a way not requiring skb->sk setting. So dropping the setting
of skb->sk.
Thanks to Eric Dumazet <eric.dumazet@gmail.com> for correct solution.

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=79441
Reported-by: Ed Martin <edman007@edman007.com>
Signed-off-by: Andrey Utkin <andrey.krieger.utkin@gmail.com>
---
 net/appletalk/ddp.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 01a1082..bfcf6be 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1489,8 +1489,6 @@ static int atalk_rcv(struct sk_buff *skb, struct net_device *dev,
 		goto drop;
 
 	/* Queue packet (standard) */
-	skb->sk = sock;
-
 	if (sock_queue_rcv_skb(sock, skb) < 0)
 		goto drop;
 
@@ -1644,7 +1642,6 @@ static int atalk_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr
 	if (!skb)
 		goto out;
 
-	skb->sk = sk;
 	skb_reserve(skb, ddp_dl->header_length);
 	skb_reserve(skb, dev->hard_header_len);
 	skb->dev = dev;
-- 
1.8.3.2
