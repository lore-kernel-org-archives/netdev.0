From: Andrey Utkin <andrey.krieger.utkin@gmail.com>
Subject: [PATCH] appletalk: Set skb with destructor
Date: Sun,  6 Jul 2014 14:56:56 +0300
Message-ID: <1404647816-7564-1-git-send-email-andrey.krieger.utkin@gmail.com>
References: <20140705202821.GA25880@mwanda>
Cc: davem@davemloft.net, Andrey Utkin <andrey.krieger.utkin@gmail.com>
To: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	acme@ghostprotocols.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:59381 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750978AbaGFL6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2014 07:58:10 -0400
In-Reply-To: <20140705202821.GA25880@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sock ref counting is off so there is a kernel panic when you run
`atalkd`.  See https://bugzilla.kernel.org/show_bug.cgi?id=79441
This fix is similar to 0ae89beb283a ('can: add destructor for self
generated skbs')

Reported-by: Ed Martin <edman007@edman007.com>
Signed-off-by: Andrey Utkin <andrey.krieger.utkin@gmail.com>
---
 net/appletalk/ddp.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 01a1082..3d8ab34 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1399,6 +1399,11 @@ drop:
 	return NET_RX_DROP;
 }
 
+static inline void atalk_skb_destructor(struct sk_buff *skb)
+{
+	sock_put(skb->sk);
+}
+
 /**
  *	atalk_rcv - Receive a packet (in skb) from device dev
  *	@skb - packet received
@@ -1489,6 +1494,8 @@ static int atalk_rcv(struct sk_buff *skb, struct net_device *dev,
 		goto drop;
 
 	/* Queue packet (standard) */
+	sock_hold(sock);
+	skb->destructor = atalk_skb_destructor;
 	skb->sk = sock;
 
 	if (sock_queue_rcv_skb(sock, skb) < 0)
@@ -1644,6 +1651,8 @@ static int atalk_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr
 	if (!skb)
 		goto out;
 
+	sock_hold(sk);
+	skb->destructor = atalk_skb_destructor;
 	skb->sk = sk;
 	skb_reserve(skb, ddp_dl->header_length);
 	skb_reserve(skb, dev->hard_header_len);
-- 
1.8.3.2
