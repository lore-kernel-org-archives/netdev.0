From: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [RFC] [PATCH net-next 1/1] Phonet: convert bound sockets hash list to RCU
Date: Wed, 13 Apr 2011 12:27:36 +0300
Message-ID: <1302686856-7742-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([147.243.1.48]:18237 "EHLO mgw-sa02.nokia.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758001Ab1DMJ1X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 05:27:23 -0400
Received: from leon.remlab.com (helruo-dhcp021238.ntc.nokia.com [172.21.21.238])
	by mgw-sa02.nokia.com (Switch-3.4.3/Switch-3.4.3) with ESMTP id p3D9RLGJ021483
	for <netdev@vger.kernel.org>; Wed, 13 Apr 2011 12:27:21 +0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This gets rid of the last spinlock in the Phonet stack proper.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/socket.c |   45 +++++++++++++++++++++----------------------=
--
 1 files changed, 21 insertions(+), 24 deletions(-)

diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index b1adafa..8c5bfce 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -52,7 +52,7 @@ static int pn_socket_release(struct socket *sock)
=20
 static struct  {
 	struct hlist_head hlist[PN_HASHSIZE];
-	spinlock_t lock;
+	struct mutex lock;
 } pnsocks;
=20
 void __init pn_sock_init(void)
@@ -61,7 +61,7 @@ void __init pn_sock_init(void)
=20
 	for (i =3D 0; i < PN_HASHSIZE; i++)
 		INIT_HLIST_HEAD(pnsocks.hlist + i);
-	spin_lock_init(&pnsocks.lock);
+	mutex_init(&pnsocks.lock);
 }
=20
 static struct hlist_head *pn_hash_list(u16 obj)
@@ -82,9 +82,8 @@ struct sock *pn_find_sock_by_sa(struct net *net, cons=
t struct sockaddr_pn *spn)
 	u8 res =3D spn->spn_resource;
 	struct hlist_head *hlist =3D pn_hash_list(obj);
=20
-	spin_lock_bh(&pnsocks.lock);
-
-	sk_for_each(sknode, node, hlist) {
+	rcu_read_lock();
+	sk_for_each_rcu(sknode, node, hlist) {
 		struct pn_sock *pn =3D pn_sk(sknode);
 		BUG_ON(!pn->sobject); /* unbound socket */
=20
@@ -107,8 +106,7 @@ struct sock *pn_find_sock_by_sa(struct net *net, co=
nst struct sockaddr_pn *spn)
 		sock_hold(sknode);
 		break;
 	}
-
-	spin_unlock_bh(&pnsocks.lock);
+	rcu_read_unlock();
=20
 	return rval;
 }
@@ -119,7 +117,7 @@ void pn_deliver_sock_broadcast(struct net *net, str=
uct sk_buff *skb)
 	struct hlist_head *hlist =3D pnsocks.hlist;
 	unsigned h;
=20
-	spin_lock(&pnsocks.lock);
+	rcu_read_lock();
 	for (h =3D 0; h < PN_HASHSIZE; h++) {
 		struct hlist_node *node;
 		struct sock *sknode;
@@ -140,25 +138,26 @@ void pn_deliver_sock_broadcast(struct net *net, s=
truct sk_buff *skb)
 		}
 		hlist++;
 	}
-	spin_unlock(&pnsocks.lock);
+	rcu_read_unlock();
 }
=20
 void pn_sock_hash(struct sock *sk)
 {
 	struct hlist_head *hlist =3D pn_hash_list(pn_sk(sk)->sobject);
=20
-	spin_lock_bh(&pnsocks.lock);
-	sk_add_node(sk, hlist);
-	spin_unlock_bh(&pnsocks.lock);
+	mutex_lock(&pnsocks.lock);
+	sk_add_node_rcu(sk, hlist);
+	mutex_unlock(&pnsocks.lock);
 }
 EXPORT_SYMBOL(pn_sock_hash);
=20
 void pn_sock_unhash(struct sock *sk)
 {
-	spin_lock_bh(&pnsocks.lock);
-	sk_del_node_init(sk);
-	spin_unlock_bh(&pnsocks.lock);
+	mutex_lock(&pnsocks.lock);
+	sk_del_node_init_rcu(sk);
+	mutex_unlock(&pnsocks.lock);
 	pn_sock_unbind_all_res(sk);
+	synchronize_rcu();
 }
 EXPORT_SYMBOL(pn_sock_unhash);
=20
@@ -548,7 +547,7 @@ static struct sock *pn_sock_get_idx(struct seq_file=
 *seq, loff_t pos)
 	unsigned h;
=20
 	for (h =3D 0; h < PN_HASHSIZE; h++) {
-		sk_for_each(sknode, node, hlist) {
+		sk_for_each_rcu(sknode, node, hlist) {
 			if (!net_eq(net, sock_net(sknode)))
 				continue;
 			if (!pos)
@@ -572,9 +571,9 @@ static struct sock *pn_sock_get_next(struct seq_fil=
e *seq, struct sock *sk)
 }
=20
 static void *pn_sock_seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(pnsocks.lock)
+	__acquires(rcu)
 {
-	spin_lock_bh(&pnsocks.lock);
+	rcu_read_lock();
 	return *pos ? pn_sock_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
 }
=20
@@ -591,9 +590,9 @@ static void *pn_sock_seq_next(struct seq_file *seq,=
 void *v, loff_t *pos)
 }
=20
 static void pn_sock_seq_stop(struct seq_file *seq, void *v)
-	__releases(pnsocks.lock)
+	__releases(rcu)
 {
-	spin_unlock_bh(&pnsocks.lock);
+	rcu_read_unlock();
 }
=20
 static int pn_sock_seq_show(struct seq_file *seq, void *v)
@@ -721,13 +720,11 @@ void pn_sock_unbind_all_res(struct sock *sk)
 	}
 	mutex_unlock(&resource_mutex);
=20
-	if (match =3D=3D 0)
-		return;
-	synchronize_rcu();
 	while (match > 0) {
-		sock_put(sk);
+		__sock_put(sk);
 		match--;
 	}
+	/* Caller is responsible for RCU sync before final sock_put() */
 }
=20
 #ifdef CONFIG_PROC_FS
--=20
1.7.4.1

