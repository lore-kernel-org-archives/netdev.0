From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCHv2 net 2/2] l2tp: fix userspace reception on plain L2TP sockets
Date: Thu, 6 Mar 2014 11:15:10 +0100
Message-ID: <bf7ad9b2fdf97c35d2c07488eea09e5280627b74.1394100210.git.g.nault@alphalink.fr>
References: <cover.1393966618.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:53520 "EHLO
	mail-2-cbv2.admin.alphalink.fr" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751095AbaCFKPO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 05:15:14 -0500
Content-Disposition: inline
In-Reply-To: <cover.1393966618.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As pppol2tp_recv() never queues up packets to plain L2TP sockets,
pppol2tp_recvmsg() never returns data to userspace, thus making
the recv*() system calls unusable.

Instead of dropping packets when the L2TP socket isn't bound to a PPP
channel, this patch adds them to its reception queue.

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 net/l2tp/l2tp_ppp.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 6bfeaa7..5990919 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -254,12 +254,14 @@ static void pppol2tp_recv(struct l2tp_session *session, struct sk_buff *skb, int
 		po = pppox_sk(sk);
 		ppp_input(&po->chan, skb);
 	} else {
-		l2tp_info(session, PPPOL2TP_MSG_DATA, "%s: socket not bound\n",
-			  session->name);
+		l2tp_dbg(session, PPPOL2TP_MSG_DATA,
+			 "%s: recv %d byte data frame, passing to L2TP socket\n",
+			 session->name, data_len);
 
-		/* Not bound. Nothing we can do, so discard. */
-		atomic_long_inc(&session->stats.rx_errors);
-		kfree_skb(skb);
+		if (sock_queue_rcv_skb(sk, skb) < 0) {
+			atomic_long_inc(&session->stats.rx_errors);
+			kfree_skb(skb);
+		}
 	}
 
 	return;
-- 
1.9.0
