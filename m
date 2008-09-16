From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 09/14] Phonet: allocate and initialize new sockets
Date: Tue, 16 Sep 2008 18:08:09 +0300
Message-ID: <1221577694-4513-9-git-send-email-remi.denis-courmont@nokia.com>
References: <200809161757.38571.remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:52822 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753389AbYIPPI2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2008 11:08:28 -0400
Received: from esebh105.NOE.Nokia.com (esebh105.ntc.nokia.com [172.21.138.211])
	by mgw-mx03.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id m8GF8AVu031651
	for <netdev@vger.kernel.org>; Tue, 16 Sep 2008 18:08:26 +0300
In-Reply-To: <200809161757.38571.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/net/phonet/phonet.h |    1 +
 net/phonet/af_phonet.c      |   20 ++++++++++++++++++--
 2 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/include/net/phonet/phonet.h b/include/net/phonet/phonet.h
index 8e7e42d..1131833 100644
--- a/include/net/phonet/phonet.h
+++ b/include/net/phonet/phonet.h
@@ -81,6 +81,7 @@ void pn_skb_get_dst_sockaddr(struct sk_buff *skb, struct sockaddr_pn *sa)
 
 /* Protocols in Phonet protocol family. */
 struct phonet_protocol {
+	const struct proto_ops	*ops;
 	struct proto		*prot;
 	int			sock_type;
 };
diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index 317f30c..1628e7c 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -41,6 +41,8 @@ static inline void phonet_proto_put(struct phonet_protocol *pp);
 
 static int pn_socket_create(struct net *net, struct socket *sock, int protocol)
 {
+	struct sock *sk;
+	struct pn_sock *pn;
 	struct phonet_protocol *pnp;
 	int err;
 
@@ -71,8 +73,22 @@ static int pn_socket_create(struct net *net, struct socket *sock, int protocol)
 		goto out;
 	}
 
-	/* TODO: create and init the struct sock */
-	err = -EPROTONOSUPPORT;
+	sk = sk_alloc(net, PF_PHONET, GFP_KERNEL, pnp->prot);
+	if (sk == NULL) {
+		err = -ENOMEM;
+		goto out;
+	}
+
+	sock_init_data(sock, sk);
+	sock->state = SS_UNCONNECTED;
+	sock->ops = pnp->ops;
+	sk->sk_backlog_rcv = sk->sk_prot->backlog_rcv;
+	sk->sk_protocol = protocol;
+	pn = pn_sk(sk);
+	pn->sobject = 0;
+	pn->resource = 0;
+	sk->sk_prot->init(sk);
+	err = 0;
 
 out:
 	phonet_proto_put(pnp);
-- 
1.5.4.3

