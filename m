From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH net-next] Phonet: put sockets in a hash table
Date: Mon,  9 Nov 2009 14:17:01 +0200
Message-ID: <1257769021-521-1-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:54559 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750840AbZKIMQ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Nov 2009 07:16:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/net/phonet/phonet.h |    1 +
 net/phonet/af_phonet.c      |    1 +
 net/phonet/socket.c         |   79 +++++++++++++++++++++++++++++------=
-------
 3 files changed, 56 insertions(+), 25 deletions(-)

diff --git a/include/net/phonet/phonet.h b/include/net/phonet/phonet.h
index fdb05fa..7b11407 100644
--- a/include/net/phonet/phonet.h
+++ b/include/net/phonet/phonet.h
@@ -46,6 +46,7 @@ static inline struct pn_sock *pn_sk(struct sock *sk)
=20
 extern const struct proto_ops phonet_dgram_ops;
=20
+void pn_sock_init(void);
 struct sock *pn_find_sock_by_sa(struct net *net, const struct sockaddr=
_pn *sa);
 void pn_deliver_sock_broadcast(struct net *net, struct sk_buff *skb);
 void phonet_get_local_port_range(int *min, int *max);
diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index 3bd1be6..8d3a55b 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -481,6 +481,7 @@ static int __init phonet_init(void)
 	if (err)
 		return err;
=20
+	pn_sock_init();
 	err =3D sock_register(&phonet_proto_family);
 	if (err) {
 		printk(KERN_ALERT
diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index 0412beb..4112b6e 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -45,13 +45,28 @@ static int pn_socket_release(struct socket *sock)
 	return 0;
 }
=20
+#define PN_HASHSIZE	16
+#define PN_HASHMASK	(PN_HASHSIZE-1)
+
+
 static struct  {
-	struct hlist_head hlist;
+	struct hlist_head hlist[PN_HASHSIZE];
 	spinlock_t lock;
-} pnsocks =3D {
-	.hlist =3D HLIST_HEAD_INIT,
-	.lock =3D __SPIN_LOCK_UNLOCKED(pnsocks.lock),
-};
+} pnsocks;
+
+void __init pn_sock_init(void)
+{
+	unsigned i;
+
+	for (i =3D 0; i < PN_HASHSIZE; i++)
+		INIT_HLIST_HEAD(pnsocks.hlist + i);
+	spin_lock_init(&pnsocks.lock);
+}
+
+static struct hlist_head *pn_hash_list(u16 obj)
+{
+	return pnsocks.hlist + (obj & PN_HASHMASK);
+}
=20
 /*
  * Find address based on socket address, match only certain fields.
@@ -64,10 +79,11 @@ struct sock *pn_find_sock_by_sa(struct net *net, co=
nst struct sockaddr_pn *spn)
 	struct sock *rval =3D NULL;
 	u16 obj =3D pn_sockaddr_get_object(spn);
 	u8 res =3D spn->spn_resource;
+	struct hlist_head *hlist =3D pn_hash_list(obj);
=20
 	spin_lock_bh(&pnsocks.lock);
=20
-	sk_for_each(sknode, node, &pnsocks.hlist) {
+	sk_for_each(sknode, node, hlist) {
 		struct pn_sock *pn =3D pn_sk(sknode);
 		BUG_ON(!pn->sobject); /* unbound socket */
=20
@@ -99,31 +115,39 @@ struct sock *pn_find_sock_by_sa(struct net *net, c=
onst struct sockaddr_pn *spn)
 /* Deliver a broadcast packet (only in bottom-half) */
 void pn_deliver_sock_broadcast(struct net *net, struct sk_buff *skb)
 {
-	struct hlist_node *node;
-	struct sock *sknode;
+	struct hlist_head *hlist =3D pnsocks.hlist;
+	unsigned h;
=20
 	spin_lock(&pnsocks.lock);
-	sk_for_each(sknode, node, &pnsocks.hlist) {
-		struct sk_buff *clone;
+	for (h =3D 0; h < PN_HASHSIZE; h++) {
+		struct hlist_node *node;
+		struct sock *sknode;
=20
-		if (!net_eq(sock_net(sknode), net))
-			continue;
-		if (!sock_flag(sknode, SOCK_BROADCAST))
-			continue;
+		sk_for_each(sknode, node, hlist) {
+			struct sk_buff *clone;
=20
-		clone =3D skb_clone(skb, GFP_ATOMIC);
-		if (clone) {
-			sock_hold(sknode);
-			sk_receive_skb(sknode, clone, 0);
+			if (!net_eq(sock_net(sknode), net))
+				continue;
+			if (!sock_flag(sknode, SOCK_BROADCAST))
+				continue;
+
+			clone =3D skb_clone(skb, GFP_ATOMIC);
+			if (clone) {
+				sock_hold(sknode);
+				sk_receive_skb(sknode, clone, 0);
+			}
 		}
+		hlist++;
 	}
 	spin_unlock(&pnsocks.lock);
 }
=20
 void pn_sock_hash(struct sock *sk)
 {
+	struct hlist_head *hlist =3D pn_hash_list(pn_sk(sk)->sobject);
+
 	spin_lock_bh(&pnsocks.lock);
-	sk_add_node(sk, &pnsocks.hlist);
+	sk_add_node(sk, hlist);
 	spin_unlock_bh(&pnsocks.lock);
 }
 EXPORT_SYMBOL(pn_sock_hash);
@@ -439,15 +463,20 @@ EXPORT_SYMBOL(pn_sock_get_port);
 static struct sock *pn_sock_get_idx(struct seq_file *seq, loff_t pos)
 {
 	struct net *net =3D seq_file_net(seq);
+	struct hlist_head *hlist =3D pnsocks.hlist;
 	struct hlist_node *node;
 	struct sock *sknode;
+	unsigned h;
=20
-	sk_for_each(sknode, node, &pnsocks.hlist) {
-		if (!net_eq(net, sock_net(sknode)))
-			continue;
-		if (!pos)
-			return sknode;
-		pos--;
+	for (h =3D 0; h < PN_HASHSIZE; h++) {
+		sk_for_each(sknode, node, hlist) {
+			if (!net_eq(net, sock_net(sknode)))
+				continue;
+			if (!pos)
+				return sknode;
+			pos--;
+		}
+		hlist++;
 	}
 	return NULL;
 }
--=20
1.6.3.3

