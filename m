From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH 1/5] Phonet: deliver broadcast packets to broadcast sockets
Date: Wed, 14 Oct 2009 13:48:27 +0300
Message-ID: <1255517311-19527-1-git-send-email-remi@remlab.net>
References: <06dcdf33b2a0132b2a05c3220735a81e@chewa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:36521 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932848AbZJNKtI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2009 06:49:08 -0400
In-Reply-To: <06dcdf33b2a0132b2a05c3220735a81e@chewa.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/net/phonet/phonet.h |    1 +
 net/phonet/af_phonet.c      |    6 ++++++
 net/phonet/socket.c         |   21 +++++++++++++++++++++
 3 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/include/net/phonet/phonet.h b/include/net/phonet/phonet.h
index d43f71b..fdb05fa 100644
--- a/include/net/phonet/phonet.h
+++ b/include/net/phonet/phonet.h
@@ -47,6 +47,7 @@ static inline struct pn_sock *pn_sk(struct sock *sk)
 extern const struct proto_ops phonet_dgram_ops;
=20
 struct sock *pn_find_sock_by_sa(struct net *net, const struct sockaddr=
_pn *sa);
+void pn_deliver_sock_broadcast(struct net *net, struct sk_buff *skb);
 void phonet_get_local_port_range(int *min, int *max);
 void pn_sock_hash(struct sock *sk);
 void pn_sock_unhash(struct sock *sk);
diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index c711d58..b113fe0 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -369,6 +369,12 @@ static int phonet_rcv(struct sk_buff *skb, struct =
net_device *dev,
=20
 	pn_skb_get_dst_sockaddr(skb, &sa);
=20
+	/* check if this is broadcasted */
+	if (pn_sockaddr_get_addr(&sa) =3D=3D PNADDR_BROADCAST) {
+		pn_deliver_sock_broadcast(net, skb);
+		goto out;
+	}
+
 	/* check if we are the destination */
 	if (phonet_address_lookup(net, pn_sockaddr_get_addr(&sa)) =3D=3D 0) {
 		/* Phonet packet input */
diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index aa5b5a9..8c84190 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -94,7 +94,28 @@ struct sock *pn_find_sock_by_sa(struct net *net, con=
st struct sockaddr_pn *spn)
 	spin_unlock_bh(&pnsocks.lock);
=20
 	return rval;
+}
+
+/* Deliver a broadcast packet (only in bottom-half) */
+void pn_deliver_sock_broadcast(struct net *net, struct sk_buff *skb)
+{
+	struct hlist_node *node;
+	struct sock *sknode;
+
+	spin_lock(&pnsocks.lock);
+	sk_for_each(sknode, node, &pnsocks.hlist) {
+		struct sk_buff *clone;
+
+		if (!net_eq(sock_net(sknode), net))
+			continue;
+		if (!sock_flag(sknode, SOCK_BROADCAST))
+			continue;
=20
+		clone =3D skb_clone(skb, GFP_ATOMIC);
+		if (clone)
+			sk_receive_skb(sknode, clone, 0);
+	}
+	spin_unlock(&pnsocks.lock);
 }
=20
 void pn_sock_hash(struct sock *sk)
--=20
1.6.0.4

