From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [RFC] taking advantage of sk_{add,del}_node
Date: Tue, 17 Jun 2003 22:32:15 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030618013214.GC17694@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Networking Development Mailing List <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

	While doing the hlist work I noticed that it may be a good idea to have
the sock_{hold,put} done automatically in most (all?) sk_{add,del}_node, as
we're adding the sock to a list, we must hold a reference, so take a look at
this (untested, with some issues) patch and please give comments about it.

	Doing this we'll have some protocols that doesn't do any refcounting
at all suck less, and make it easier to fill the gap, as I have an idea for
the next step for a sk_search(list, callback_cmp_func), done as a macro
and using the callback_cmp_func as an inline, that would do the sock_hold on
finding the sock when callback_cmp_func returns true (think about a variation
on bsearch(3) idea...).

	With those thingies in place writing a protocol will be a piece of
cake and we'll have less differences among network families implementations 8)

Thanks,

- Arnaldo

===== include/net/sock.h 1.45 vs edited =====
--- 1.45/include/net/sock.h	Tue Jun 17 13:35:27 2003
+++ edited/include/net/sock.h	Tue Jun 17 22:01:57 2003
@@ -289,7 +289,7 @@
 	node->pprev = NULL;
 }
 
-static __inline__ int sk_del_node_init(struct sock *sk)
+static __inline__ int __sk_del_node_init(struct sock *sk)
 {
 	if (sk_hashed(sk)) {
 		__hlist_del(&sk->sk_node);
@@ -299,8 +299,23 @@
 	return 0;
 }
 
+static __inline__ int sk_del_node_init(struct sock *sk)
+{
+	int rc = __sk_del_node_init(sk);
+
+	if (rc)
+		__sock_put(sk);
+	return rc;
+}
+
+static __inline__ void __sk_add_node(struct sock *sk, struct hlist_head *list)
+{
+	hlist_add_head(&sk->sk_node, list);
+}
+
 static __inline__ void sk_add_node(struct sock *sk, struct hlist_head *list)
 {
+	sock_hold(sk);
 	hlist_add_head(&sk->sk_node, list);
 }
 
===== net/bluetooth/af_bluetooth.c 1.20 vs edited =====
--- 1.20/net/bluetooth/af_bluetooth.c	Mon Jun 16 12:11:36 2003
+++ edited/net/bluetooth/af_bluetooth.c	Tue Jun 17 22:03:33 2003
@@ -143,15 +143,13 @@
 {
 	write_lock_bh(&l->lock);
 	sk_add_node(sk, &l->head);
-	sock_hold(sk);
 	write_unlock_bh(&l->lock);
 }
 
 void bt_sock_unlink(struct bt_sock_list *l, struct sock *sk)
 {
 	write_lock_bh(&l->lock);
-	if (sk_del_node_init(sk))
-		__sock_put(sk);
+	sk_del_node_init(sk)
 	write_unlock_bh(&l->lock);
 }
 
===== net/decnet/af_decnet.c 1.29 vs edited =====
--- 1.29/net/decnet/af_decnet.c	Mon Jun 16 12:11:36 2003
+++ edited/net/decnet/af_decnet.c	Tue Jun 17 22:04:17 2003
@@ -276,7 +276,7 @@
 		return;
 
 	write_lock_bh(&dn_hash_lock);
-	hlist_del(&sk->sk_node);
+	sk_del_node_init(&sk->sk_node);
 	DN_SK(sk)->addrloc = 0;
 	list = listen_hash(&DN_SK(sk)->addr);
 	sk_add_node(sk, list);
===== net/econet/af_econet.c 1.21 vs edited =====
--- 1.21/net/econet/af_econet.c	Mon Jun 16 12:11:36 2003
+++ edited/net/econet/af_econet.c	Tue Jun 17 22:04:31 2003
@@ -96,8 +96,7 @@
 static void econet_remove_socket(struct hlist_head *list, struct sock *sk)
 {
 	write_lock_bh(&econet_lock);
-	if (sk_del_node_init(sk))
-		sock_put(sk);
+	sk_del_node_init(sk)
 	write_unlock_bh(&econet_lock);
 }
 
@@ -105,7 +104,6 @@
 {
 	write_lock_bh(&econet_lock);
 	sk_add_node(sk, list);
-	sock_hold(sk);
 	write_unlock_bh(&econet_lock);
 }
 
===== net/ipv4/raw.c 1.34 vs edited =====
--- 1.34/net/ipv4/raw.c	Mon Jun 16 12:11:36 2003
+++ edited/net/ipv4/raw.c	Tue Jun 17 22:04:38 2003
@@ -91,17 +91,14 @@
 	write_lock_bh(&raw_v4_lock);
 	sk_add_node(sk, head);
 	sock_prot_inc_use(sk->sk_prot);
- 	sock_hold(sk);
 	write_unlock_bh(&raw_v4_lock);
 }
 
 static void raw_v4_unhash(struct sock *sk)
 {
  	write_lock_bh(&raw_v4_lock);
-	if (sk_del_node_init(sk)) {
+	if (sk_del_node_init(sk))
 		sock_prot_dec_use(sk->sk_prot);
-		__sock_put(sk);
-	}
 	write_unlock_bh(&raw_v4_lock);
 }
 
===== net/ipv4/tcp_ipv4.c 1.63 vs edited =====
--- 1.63/net/ipv4/tcp_ipv4.c	Tue Jun 17 13:35:27 2003
+++ edited/net/ipv4/tcp_ipv4.c	Tue Jun 17 22:05:38 2003
@@ -359,7 +359,7 @@
 		lock = &tcp_ehash[sk->sk_hashent].lock;
 		write_lock(lock);
 	}
-	sk_add_node(sk, list);
+	__sk_add_node(sk, list);
 	sock_prot_inc_use(sk->sk_prot);
 	write_unlock(lock);
 	if (listen_possible && sk->sk_state == TCP_LISTEN)
@@ -392,7 +392,7 @@
 		write_lock_bh(&head->lock);
 	}
 
-	if (sk_del_node_init(sk))
+	if (__sk_del_node_init(sk))
 		sock_prot_dec_use(sk->sk_prot);
 	write_unlock_bh(lock);
 
@@ -608,7 +608,7 @@
 	inet->sport = htons(lport);
 	sk->sk_hashent = hash;
 	BUG_TRAP(sk_unhashed(sk));
-	sk_add_node(sk, &head->chain);
+	__sk_add_node(sk, &head->chain);
 	sock_prot_inc_use(sk->sk_prot);
 	write_unlock(&head->lock);
 
===== net/ipv4/udp.c 1.43 vs edited =====
--- 1.43/net/ipv4/udp.c	Mon Jun 16 12:11:36 2003
+++ edited/net/ipv4/udp.c	Tue Jun 17 22:04:45 2003
@@ -189,7 +189,6 @@
 
 		sk_add_node(sk, h);
 		sock_prot_inc_use(sk->sk_prot);
-		sock_hold(sk);
 	}
 	write_unlock_bh(&udp_hash_lock);
 	return 0;
@@ -210,7 +209,6 @@
 	if (sk_del_node_init(sk)) {
 		inet_sk(sk)->num = 0;
 		sock_prot_dec_use(sk->sk_prot);
-		__sock_put(sk);
 	}
 	write_unlock_bh(&udp_hash_lock);
 }
===== net/ipv6/raw.c 1.31 vs edited =====
--- 1.31/net/ipv6/raw.c	Mon Jun 16 12:11:36 2003
+++ edited/net/ipv6/raw.c	Tue Jun 17 22:06:08 2003
@@ -64,17 +64,14 @@
 	write_lock_bh(&raw_v6_lock);
 	sk_add_node(sk, list);
 	sock_prot_inc_use(sk->sk_prot);
- 	sock_hold(sk);
  	write_unlock_bh(&raw_v6_lock);
 }
 
 static void raw_v6_unhash(struct sock *sk)
 {
  	write_lock_bh(&raw_v6_lock);
-	if (sk_del_node_init(sk)) {
+	if (sk_del_node_init(sk))
 		sock_prot_dec_use(sk->sk_prot);
-		__sock_put(sk);
-	}
 	write_unlock_bh(&raw_v6_lock);
 }
 
===== net/ipv6/udp.c 1.41 vs edited =====
--- 1.41/net/ipv6/udp.c	Mon Jun 16 12:24:58 2003
+++ edited/net/ipv6/udp.c	Tue Jun 17 22:06:13 2003
@@ -160,7 +160,6 @@
 	if (sk_unhashed(sk)) {
 		sk_add_node(sk, &udp_hash[snum & (UDP_HTABLE_SIZE - 1)]);
 		sock_prot_inc_use(sk->sk_prot);
-		sock_hold(sk);
 	}
 	write_unlock_bh(&udp_hash_lock);
 	return 0;
@@ -181,7 +180,6 @@
 	if (sk_del_node_init(sk)) {
 		inet_sk(sk)->num = 0;
 		sock_prot_dec_use(sk->sk_prot);
-		__sock_put(sk);
 	}
 	write_unlock_bh(&udp_hash_lock);
 }
===== net/ipx/af_ipx.c 1.38 vs edited =====
--- 1.38/net/ipx/af_ipx.c	Tue Jun 17 14:11:58 2003
+++ edited/net/ipx/af_ipx.c	Tue Jun 17 22:06:30 2003
@@ -142,7 +142,6 @@
 	spin_lock_bh(&intrfc->if_sklist_lock);
 	sk_del_node_init(sk);
 	spin_unlock_bh(&intrfc->if_sklist_lock);
-	sock_put(sk);
 	ipxitf_put(intrfc);
 out:
 	return;
@@ -229,7 +228,6 @@
 static void ipxitf_insert_socket(struct ipx_interface *intrfc, struct sock *sk)
 {
 	ipxitf_hold(intrfc);
-	sock_hold(sk);
 	spin_lock_bh(&intrfc->if_sklist_lock);
 	ipx_sk(sk)->intrfc = intrfc;
 	sk_add_node(sk, &intrfc->if_sklist);
===== net/key/af_key.c 1.42 vs edited =====
--- 1.42/net/key/af_key.c	Mon Jun 16 12:11:36 2003
+++ edited/net/key/af_key.c	Tue Jun 17 22:06:34 2003
@@ -115,15 +115,13 @@
 {
 	pfkey_table_grab();
 	sk_add_node(sk, &pfkey_table);
-	sock_hold(sk);
 	pfkey_table_ungrab();
 }
 
 static void pfkey_remove(struct sock *sk)
 {
 	pfkey_table_grab();
-	if (sk_del_node_init(sk))
-		__sock_put(sk);
+	sk_del_node_init(sk);
 	pfkey_table_ungrab();
 }
 
===== net/llc/llc_sap.c 1.20 vs edited =====
--- 1.20/net/llc/llc_sap.c	Mon Jun 16 12:11:36 2003
+++ edited/net/llc/llc_sap.c	Tue Jun 17 22:06:40 2003
@@ -35,7 +35,6 @@
 	write_lock_bh(&sap->sk_list.lock);
 	llc_sk(sk)->sap = sap;
 	sk_add_node(sk, &sap->sk_list.list);
-	sock_hold(sk);
 	write_unlock_bh(&sap->sk_list.lock);
 }
 
@@ -50,8 +49,7 @@
 void llc_sap_unassign_sock(struct llc_sap *sap, struct sock *sk)
 {
 	write_lock_bh(&sap->sk_list.lock);
-	if (sk_del_node_init(sk))
-		sock_put(sk);
+	sk_del_node_init(sk);
 	write_unlock_bh(&sap->sk_list.lock);
 }
 
===== net/netlink/af_netlink.c 1.28 vs edited =====
--- 1.28/net/netlink/af_netlink.c	Mon Jun 16 12:11:36 2003
+++ edited/net/netlink/af_netlink.c	Tue Jun 17 22:06:45 2003
@@ -193,7 +193,6 @@
 		if (nlk_sk(sk)->pid == 0) {
 			nlk_sk(sk)->pid = pid;
 			sk_add_node(sk, &nl_table[sk->sk_protocol]);
-			sock_hold(sk);
 			err = 0;
 		}
 	}
@@ -204,8 +203,7 @@
 static void netlink_remove(struct sock *sk)
 {
 	netlink_table_grab();
-	if (sk_del_node_init(sk))
-		__sock_put(sk);
+	sk_del_node_init(sk);
 	netlink_table_ungrab();
 }
 
===== net/packet/af_packet.c 1.30 vs edited =====
--- 1.30/net/packet/af_packet.c	Mon Jun 16 12:11:36 2003
+++ edited/net/packet/af_packet.c	Tue Jun 17 22:06:51 2003
@@ -758,8 +758,7 @@
 		return 0;
 
 	write_lock_bh(&packet_sklist_lock);
-	if (sk_del_node_init(sk))
-		__sock_put(sk);
+	sk_del_node_init(sk);
 	write_unlock_bh(&packet_sklist_lock);
 
 	/*
@@ -984,7 +983,6 @@
 
 	write_lock_bh(&packet_sklist_lock);
 	sk_add_node(sk, &packet_sklist);
-	sock_hold(sk);
 	write_unlock_bh(&packet_sklist_lock);
 	return(0);
 
===== net/unix/af_unix.c 1.48 vs edited =====
--- 1.48/net/unix/af_unix.c	Mon Jun 16 16:46:51 2003
+++ edited/net/unix/af_unix.c	Tue Jun 17 22:06:58 2003
@@ -211,15 +211,13 @@
 
 static void __unix_remove_socket(struct sock *sk)
 {
-	if (sk_del_node_init(sk))
-		__sock_put(sk);
+	sk_del_node_init(sk);
 }
 
 static void __unix_insert_socket(struct hlist_head *list, struct sock *sk)
 {
 	BUG_TRAP(sk_unhashed(sk));
 	sk_add_node(sk, list);
-	sock_hold(sk);
 }
 
 static inline void unix_remove_socket(struct sock *sk)
===== net/wanrouter/af_wanpipe.c 1.27 vs edited =====
--- 1.27/net/wanrouter/af_wanpipe.c	Mon Jun 16 12:11:36 2003
+++ edited/net/wanrouter/af_wanpipe.c	Tue Jun 17 22:07:04 2003
@@ -982,8 +982,7 @@
 
 	set_bit(1,&wanpipe_tx_critical);
 	write_lock(&wanpipe_sklist_lock);
-	if (sk_del_node_init(sk))
-		__sock_put(sk);
+	sk_del_node_init(sk);
 	write_unlock(&wanpipe_sklist_lock);
 	clear_bit(1,&wanpipe_tx_critical);
 
@@ -1143,8 +1142,7 @@
 	}
 	
 	write_lock(&wanpipe_sklist_lock);
-	if (sk_del_node_init(sk))
-		__sock_put(sk);
+	sk_del_node_init(sk);
 	write_unlock(&wanpipe_sklist_lock);
 
 
@@ -1206,8 +1204,7 @@
 	 * appropriate locks */
 	
 	write_lock(&wanpipe_sklist_lock);
-	if (sk_del_node_init(init))
-		__sock_put(sk);
+	sk_del_node_init(sk);
 	write_unlock(&wanpipe_sklist_lock);
 
 	sk->sk_socket = NULL;
@@ -1536,7 +1533,6 @@
 	set_bit(1,&wanpipe_tx_critical);
 	write_lock(&wanpipe_sklist_lock);
 	sk_add_node(sk, &wanpipe_sklist);
-	sock_hold(sk);
 	write_unlock(&wanpipe_sklist_lock);
 	clear_bit(1,&wanpipe_tx_critical);
 
@@ -2434,7 +2430,6 @@
 	set_bit(1,&wanpipe_tx_critical);
 	write_lock(&wanpipe_sklist_lock);
 	sk_add_node(newsk, &wanpipe_sklist);
-	sock_hold(sk);
 	write_unlock(&wanpipe_sklist_lock);
 	clear_bit(1,&wanpipe_tx_critical);
 
===== net/x25/af_x25.c 1.28 vs edited =====
--- 1.28/net/x25/af_x25.c	Mon Jun 16 12:11:36 2003
+++ edited/net/x25/af_x25.c	Tue Jun 17 22:07:26 2003
@@ -154,8 +154,7 @@
 static void x25_remove_socket(struct sock *sk)
 {
 	write_lock_bh(&x25_list_lock);
-	if (sk_del_node_init(sk))
-		sock_put(sk);
+	sk_del_node_init(sk);
 	write_unlock_bh(&x25_list_lock);
 }
 
@@ -219,7 +218,6 @@
 {
 	write_lock_bh(&x25_list_lock);
 	sk_add_node(sk, &x25_list);
-	sock_hold(sk);
 	write_unlock_bh(&x25_list_lock);
 }
 
