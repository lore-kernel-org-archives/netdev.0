From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH net-next] Phonet: use rwlock for sockets list
Date: Fri,  6 Nov 2009 15:41:31 +0200
Message-ID: <1257514891-18917-1-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:45540 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757160AbZKFNl2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Nov 2009 08:41:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/socket.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index 0412beb..ecb5f20 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -47,10 +47,10 @@ static int pn_socket_release(struct socket *sock)
=20
 static struct  {
 	struct hlist_head hlist;
-	spinlock_t lock;
+	rwlock_t lock;
 } pnsocks =3D {
 	.hlist =3D HLIST_HEAD_INIT,
-	.lock =3D __SPIN_LOCK_UNLOCKED(pnsocks.lock),
+	.lock =3D __RW_LOCK_UNLOCKED(pnsocks.lock),
 };
=20
 /*
@@ -65,7 +65,7 @@ struct sock *pn_find_sock_by_sa(struct net *net, cons=
t struct sockaddr_pn *spn)
 	u16 obj =3D pn_sockaddr_get_object(spn);
 	u8 res =3D spn->spn_resource;
=20
-	spin_lock_bh(&pnsocks.lock);
+	read_lock_bh(&pnsocks.lock);
=20
 	sk_for_each(sknode, node, &pnsocks.hlist) {
 		struct pn_sock *pn =3D pn_sk(sknode);
@@ -91,7 +91,7 @@ struct sock *pn_find_sock_by_sa(struct net *net, cons=
t struct sockaddr_pn *spn)
 		break;
 	}
=20
-	spin_unlock_bh(&pnsocks.lock);
+	read_unlock_bh(&pnsocks.lock);
=20
 	return rval;
 }
@@ -102,7 +102,7 @@ void pn_deliver_sock_broadcast(struct net *net, str=
uct sk_buff *skb)
 	struct hlist_node *node;
 	struct sock *sknode;
=20
-	spin_lock(&pnsocks.lock);
+	read_lock(&pnsocks.lock);
 	sk_for_each(sknode, node, &pnsocks.hlist) {
 		struct sk_buff *clone;
=20
@@ -117,22 +117,22 @@ void pn_deliver_sock_broadcast(struct net *net, s=
truct sk_buff *skb)
 			sk_receive_skb(sknode, clone, 0);
 		}
 	}
-	spin_unlock(&pnsocks.lock);
+	read_unlock(&pnsocks.lock);
 }
=20
 void pn_sock_hash(struct sock *sk)
 {
-	spin_lock_bh(&pnsocks.lock);
+	write_lock_bh(&pnsocks.lock);
 	sk_add_node(sk, &pnsocks.hlist);
-	spin_unlock_bh(&pnsocks.lock);
+	write_unlock_bh(&pnsocks.lock);
 }
 EXPORT_SYMBOL(pn_sock_hash);
=20
 void pn_sock_unhash(struct sock *sk)
 {
-	spin_lock_bh(&pnsocks.lock);
+	write_lock_bh(&pnsocks.lock);
 	sk_del_node_init(sk);
-	spin_unlock_bh(&pnsocks.lock);
+	write_unlock_bh(&pnsocks.lock);
 }
 EXPORT_SYMBOL(pn_sock_unhash);
=20
@@ -466,7 +466,7 @@ static struct sock *pn_sock_get_next(struct seq_fil=
e *seq, struct sock *sk)
 static void *pn_sock_seq_start(struct seq_file *seq, loff_t *pos)
 	__acquires(pnsocks.lock)
 {
-	spin_lock_bh(&pnsocks.lock);
+	read_lock_bh(&pnsocks.lock);
 	return *pos ? pn_sock_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
 }
=20
@@ -485,7 +485,7 @@ static void *pn_sock_seq_next(struct seq_file *seq,=
 void *v, loff_t *pos)
 static void pn_sock_seq_stop(struct seq_file *seq, void *v)
 	__releases(pnsocks.lock)
 {
-	spin_unlock_bh(&pnsocks.lock);
+	read_unlock_bh(&pnsocks.lock);
 }
=20
 static int pn_sock_seq_show(struct seq_file *seq, void *v)
--=20
1.6.3.3

