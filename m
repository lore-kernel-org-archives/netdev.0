From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][IRDA]: Sock leak on error path in irda_create.
Date: Thu, 15 May 2008 21:58:41 +0400
Message-ID: <482C79D1.8000601@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Samuel Ortiz <samuel@sortiz.org>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:58111 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751003AbYEOSDp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2008 14:03:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bad type/protocol specified result in sk leak.

Fix is simple - release the sk if bad values are given,
but to make it possible just to call sk_free(), I move
some sk initialization a bit lower.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index ae54b20..3eb5bcc 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -1093,11 +1093,6 @@ static int irda_create(struct net *net, struct socket *sock, int protocol)
 
 	init_waitqueue_head(&self->query_wait);
 
-	/* Initialise networking socket struct */
-	sock_init_data(sock, sk);	/* Note : set sk->sk_refcnt to 1 */
-	sk->sk_family = PF_IRDA;
-	sk->sk_protocol = protocol;
-
 	switch (sock->type) {
 	case SOCK_STREAM:
 		sock->ops = &irda_stream_ops;
@@ -1124,13 +1119,20 @@ static int irda_create(struct net *net, struct socket *sock, int protocol)
 			self->max_sdu_size_rx = TTP_SAR_UNBOUND;
 			break;
 		default:
+			sk_free(sk);
 			return -ESOCKTNOSUPPORT;
 		}
 		break;
 	default:
+		sk_free(sk);
 		return -ESOCKTNOSUPPORT;
 	}
 
+	/* Initialise networking socket struct */
+	sock_init_data(sock, sk);	/* Note : set sk->sk_refcnt to 1 */
+	sk->sk_family = PF_IRDA;
+	sk->sk_protocol = protocol;
+
 	/* Register as a client with IrLMP */
 	self->ckey = irlmp_register_client(0, NULL, NULL, NULL);
 	self->mask.word = 0xffff;
