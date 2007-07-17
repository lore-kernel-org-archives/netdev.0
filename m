From: Patrick McHardy <kaber@trash.net>
Subject: [PPPOL2TP 1/2]: Fix use-after-free
Date: Tue, 17 Jul 2007 14:19:45 +0200
Message-ID: <469CB3E1.5060901@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080007020500090801050808"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	James Chapman <jchapman@katalix.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43223 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755993AbXGQMTt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2007 08:19:49 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080007020500090801050808
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------080007020500090801050808
Content-Type: text/x-diff;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

[PPPOL2TP]: Fix use-after-free

Don't use skb->len after passing it to ip_queue_xmit.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 86394ab99d7a4532cf23f8d456aecfa6e3085dfd
tree 704cfbb8d9c06f79c21a54f189608db1d1b06915
parent 2e27afb300b56d83bb03fbfa68852b9c1e2920c6
author Patrick McHardy <kaber@trash.net> Tue, 17 Jul 2007 14:11:37 +0200
committer Patrick McHardy <kaber@trash.net> Tue, 17 Jul 2007 14:11:37 +0200

 drivers/net/pppol2tp.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/pppol2tp.c b/drivers/net/pppol2tp.c
index 5891a0f..856610f 100644
--- a/drivers/net/pppol2tp.c
+++ b/drivers/net/pppol2tp.c
@@ -824,6 +824,7 @@ static int pppol2tp_sendmsg(struct kiocb *iocb, struct socket *sock, struct msgh
 	struct pppol2tp_session *session;
 	struct pppol2tp_tunnel *tunnel;
 	struct udphdr *uh;
+	unsigned int len;
 
 	error = -ENOTCONN;
 	if (sock_flag(sk, SOCK_DEAD) || !(sk->sk_state & PPPOX_CONNECTED))
@@ -912,14 +913,15 @@ static int pppol2tp_sendmsg(struct kiocb *iocb, struct socket *sock, struct msgh
 	}
 
 	/* Queue the packet to IP for output */
+	len = skb->len;
 	error = ip_queue_xmit(skb, 1);
 
 	/* Update stats */
 	if (error >= 0) {
 		tunnel->stats.tx_packets++;
-		tunnel->stats.tx_bytes += skb->len;
+		tunnel->stats.tx_bytes += len;
 		session->stats.tx_packets++;
-		session->stats.tx_bytes += skb->len;
+		session->stats.tx_bytes += len;
 	} else {
 		tunnel->stats.tx_errors++;
 		session->stats.tx_errors++;
@@ -958,6 +960,7 @@ static int pppol2tp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 	__wsum csum = 0;
 	struct sk_buff *skb2 = NULL;
 	struct udphdr *uh;
+	unsigned int len;
 
 	if (sock_flag(sk, SOCK_DEAD) || !(sk->sk_state & PPPOX_CONNECTED))
 		goto abort;
@@ -1050,14 +1053,15 @@ static int pppol2tp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 	skb2->dst = sk_dst_get(sk_tun);
 
 	/* Queue the packet to IP for output */
+	len = skb2->len;
 	rc = ip_queue_xmit(skb2, 1);
 
 	/* Update stats */
 	if (rc >= 0) {
 		tunnel->stats.tx_packets++;
-		tunnel->stats.tx_bytes += skb2->len;
+		tunnel->stats.tx_bytes += len;
 		session->stats.tx_packets++;
-		session->stats.tx_bytes += skb2->len;
+		session->stats.tx_bytes += len;
 	} else {
 		tunnel->stats.tx_errors++;
 		session->stats.tx_errors++;

--------------080007020500090801050808--
