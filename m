From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/3] [PPP] L2TP: Disallow non-UDP datagram sockets
Date: Tue, 18 Sep 2007 20:08:09 +0800
Message-ID: <E1IXbs9-0002Pd-00@gondolin.me.apana.org.au>
References: <20070918120438.GA9121@gondor.apana.org.au>
To: James Chapman <jchapman@katalix.com>,
	"David S. Miller" <davem@davemloft.net>,
	Michal Ostrowski <mostrows@speakeasy.net>,
	Paul Mackerras <paulus@samba.org>,
	Herbert Xu <herbert@gondo
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1028 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751740AbXIRMIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 08:08:12 -0400
Received: from gondolin.me.apana.org.au ([192.168.0.6] ident=mail)
	by arnor.apana.org.au with esmtp (Exim 4.50 #1 (Debian))
	id 1IXbs9-0002XB-Ha
	for <netdev@vger.kernel.org>; Tue, 18 Sep 2007 22:08:09 +1000
Received: from herbert by gondolin.me.apana.org.au with local (Exim 3.36 #1 (Debian))
	id 1IXbs9-0002Pd-00
	for <netdev@vger.kernel.org>; Tue, 18 Sep 2007 20:08:09 +0800
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PPP] L2TP: Disallow non-UDP datagram sockets

With the addition of UDP-Lite we need to refine the socket check so that
only genuine UDP sockets are allowed through.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 drivers/net/pppol2tp.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/pppol2tp.c b/drivers/net/pppol2tp.c
index 266e8b3..ed8ead4 100644
--- a/drivers/net/pppol2tp.c
+++ b/drivers/net/pppol2tp.c
@@ -1326,12 +1326,14 @@ static struct sock *pppol2tp_prepare_tunnel_socket(int fd, u16 tunnel_id,
 		goto err;
 	}
 
+	sk = sock->sk;
+
 	/* Quick sanity checks */
-	err = -ESOCKTNOSUPPORT;
-	if (sock->type != SOCK_DGRAM) {
+	err = -EPROTONOSUPPORT;
+	if (sk->sk_protocol != IPPROTO_UDP) {
 		PRINTK(-1, PPPOL2TP_MSG_CONTROL, KERN_ERR,
-		       "tunl %hu: fd %d wrong type, got %d, expected %d\n",
-		       tunnel_id, fd, sock->type, SOCK_DGRAM);
+		       "tunl %hu: fd %d wrong protocol, got %d, expected %d\n",
+		       tunnel_id, fd, sk->sk_protocol, IPPROTO_UDP);
 		goto err;
 	}
 	err = -EAFNOSUPPORT;
@@ -1343,7 +1345,6 @@ static struct sock *pppol2tp_prepare_tunnel_socket(int fd, u16 tunnel_id,
 	}
 
 	err = -ENOTCONN;
-	sk = sock->sk;
 
 	/* Check if this socket has already been prepped */
 	tunnel = (struct pppol2tp_tunnel *)sk->sk_user_data;
