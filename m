From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH][BLUETOOTH] kill bt_sock_alloc
Date: Tue, 8 Mar 2005 06:52:09 -0300
Message-ID: <20050308095209.GB9468@conectiva.com.br>
References: <20050308094937.GA9468@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="XsQoSWH+UP9D9v3l"
Cc: netdev@oss.sgi.com
To: marcel@holtmann.org, maxk@qualcomm.com, davem@davemloft.net
Content-Disposition: inline
In-Reply-To: <20050308094937.GA9468@conectiva.com.br>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--XsQoSWH+UP9D9v3l
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Em Tue, Mar 08, 2005 at 06:49:37AM -0300, Arnaldo Carvalho de Melo escreveu:
> Hi,
> 
> 	Please take a look and if acceptable pull from:
> 
> bk://kernel.bkbits.net/acme/connection_sock-2.6

Sorry, now with the patch attached.

- Arnaldo

--XsQoSWH+UP9D9v3l
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="bt_sock_alloc.patch"

===================================================================


ChangeSet@1.1995, 2005-03-08 04:50:51-03:00, acme@toy.ghostprotocols.net
  [BLUETOOTH] kill bt_sock_alloc
  
  And make the derived socks have a struct bt_sock as its first member, so that
  the _pi() functions can just cast the struct sock pointer to its respective
  types, taking advantage of the fact that sk_alloc now use kmalloc when no
  slab is passed.
  
  This is another step, close to the final one, to kill sk_protinfo and make
  further planed channges possible.
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@davemloft.net>


 include/net/bluetooth/bluetooth.h |    1 
 include/net/bluetooth/hci_core.h  |    3 +-
 include/net/bluetooth/l2cap.h     |    3 +-
 include/net/bluetooth/rfcomm.h    |    3 +-
 include/net/bluetooth/sco.h       |    3 +-
 net/bluetooth/af_bluetooth.c      |   43 --------------------------------------
 net/bluetooth/bnep/sock.c         |    8 +++++--
 net/bluetooth/hci_sock.c          |    7 +++++-
 net/bluetooth/hidp/sock.c         |    6 +++--
 net/bluetooth/l2cap.c             |    6 ++++-
 net/bluetooth/rfcomm/sock.c       |    7 ++++--
 net/bluetooth/sco.c               |    7 +++++-
 12 files changed, 40 insertions(+), 57 deletions(-)


diff -Nru a/include/net/bluetooth/bluetooth.h b/include/net/bluetooth/bluetooth.h
--- a/include/net/bluetooth/bluetooth.h	2005-03-08 06:44:10 -03:00
+++ b/include/net/bluetooth/bluetooth.h	2005-03-08 06:44:10 -03:00
@@ -125,7 +125,6 @@
 
 int  bt_sock_register(int proto, struct net_proto_family *ops);
 int  bt_sock_unregister(int proto);
-struct sock *bt_sock_alloc(struct socket *sock, int proto, int pi_size, int prio);
 void bt_sock_link(struct bt_sock_list *l, struct sock *s);
 void bt_sock_unlink(struct bt_sock_list *l, struct sock *s);
 int  bt_sock_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg, size_t len, int flags);
diff -Nru a/include/net/bluetooth/hci_core.h b/include/net/bluetooth/hci_core.h
--- a/include/net/bluetooth/hci_core.h	2005-03-08 06:44:10 -03:00
+++ b/include/net/bluetooth/hci_core.h	2005-03-08 06:44:10 -03:00
@@ -595,8 +595,9 @@
 void hci_send_to_sock(struct hci_dev *hdev, struct sk_buff *skb);
 
 /* HCI info for socket */
-#define hci_pi(sk)	((struct hci_pinfo *)sk->sk_protinfo)
+#define hci_pi(sk)	((struct hci_pinfo *)sk)
 struct hci_pinfo {
+	struct bt_sock    bt;
 	struct hci_dev    *hdev;
 	struct hci_filter filter;
 	__u32             cmsg_mask;
diff -Nru a/include/net/bluetooth/l2cap.h b/include/net/bluetooth/l2cap.h
--- a/include/net/bluetooth/l2cap.h	2005-03-08 06:44:10 -03:00
+++ b/include/net/bluetooth/l2cap.h	2005-03-08 06:44:10 -03:00
@@ -201,9 +201,10 @@
 };
 
 /* ----- L2CAP channel and socket info ----- */
-#define l2cap_pi(sk)   ((struct l2cap_pinfo *)sk->sk_protinfo)
+#define l2cap_pi(sk)   ((struct l2cap_pinfo *)sk)
 
 struct l2cap_pinfo {
+	struct bt_sock	bt;
 	__u16		psm;
 	__u16		dcid;
 	__u16		scid;
diff -Nru a/include/net/bluetooth/rfcomm.h b/include/net/bluetooth/rfcomm.h
--- a/include/net/bluetooth/rfcomm.h	2005-03-08 06:44:10 -03:00
+++ b/include/net/bluetooth/rfcomm.h	2005-03-08 06:44:10 -03:00
@@ -293,9 +293,10 @@
 #define RFCOMM_LM_RELIABLE	0x0010
 #define RFCOMM_LM_SECURE	0x0020
 
-#define rfcomm_pi(sk)   ((struct rfcomm_pinfo *)sk->sk_protinfo)
+#define rfcomm_pi(sk)   ((struct rfcomm_pinfo *)sk)
 
 struct rfcomm_pinfo {
+	struct bt_sock bt;
 	struct rfcomm_dlc   *dlc;
 	u8     channel;
 	u32    link_mode;
diff -Nru a/include/net/bluetooth/sco.h b/include/net/bluetooth/sco.h
--- a/include/net/bluetooth/sco.h	2005-03-08 06:44:10 -03:00
+++ b/include/net/bluetooth/sco.h	2005-03-08 06:44:10 -03:00
@@ -68,9 +68,10 @@
 #define sco_conn_unlock(c)	spin_unlock(&c->lock);
 
 /* ----- SCO socket info ----- */
-#define sco_pi(sk)   ((struct sco_pinfo *)sk->sk_protinfo)
+#define sco_pi(sk)   ((struct sco_pinfo *)sk)
 
 struct sco_pinfo {
+	struct bt_sock	bt;
 	__u32		flags;
 	struct sco_conn	*conn;
 };
diff -Nru a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
--- a/net/bluetooth/af_bluetooth.c	2005-03-08 06:44:10 -03:00
+++ b/net/bluetooth/af_bluetooth.c	2005-03-08 06:44:10 -03:00
@@ -60,8 +60,6 @@
 #define BT_MAX_PROTO	8
 static struct net_proto_family *bt_proto[BT_MAX_PROTO];
 
-static kmem_cache_t *bt_sock_cache;
-
 int bt_sock_register(int proto, struct net_proto_family *ops)
 {
 	if (proto >= BT_MAX_PROTO)
@@ -108,36 +106,6 @@
 	return err; 
 }
 
-struct sock *bt_sock_alloc(struct socket *sock, int proto, int pi_size, int prio)
-{
-	struct sock *sk;
-	void *pi;
-
-	sk = sk_alloc(PF_BLUETOOTH, prio, sizeof(struct bt_sock), bt_sock_cache);
-	if (!sk)
-		return NULL;
-
-	if (pi_size) {
-		pi = kmalloc(pi_size, prio);
-		if (!pi) {
-			sk_free(sk);
-			return NULL;
-		}
-		memset(pi, 0, pi_size);
-		sk->sk_protinfo = pi;
-	}
-
-	sock_init_data(sock, sk);
-	INIT_LIST_HEAD(&bt_sk(sk)->accept_q);
-
-	sk->sk_zapped   = 0;
-	sk->sk_protocol = proto;
-	sk->sk_state    = BT_OPEN;
-
-	return sk;
-}
-EXPORT_SYMBOL(bt_sock_alloc);
-
 void bt_sock_link(struct bt_sock_list *l, struct sock *sk)
 {
 	write_lock_bh(&l->lock);
@@ -355,16 +323,6 @@
 	if (proc_bt)
 		proc_bt->owner = THIS_MODULE;
 
-	/* Init socket cache */
-	bt_sock_cache = kmem_cache_create("bt_sock",
-			sizeof(struct bt_sock), 0,
-			SLAB_HWCACHE_ALIGN, NULL, NULL);
-
-	if (!bt_sock_cache) {
-		BT_ERR("Socket cache creation failed");
-		return -ENOMEM;
-	}
-
 	sock_register(&bt_sock_family_ops);
 
 	BT_INFO("HCI device and connection manager initialized");
@@ -383,7 +341,6 @@
 	bt_sysfs_cleanup();
 
 	sock_unregister(PF_BLUETOOTH);
-	kmem_cache_destroy(bt_sock_cache);
 
 	remove_proc_entry("bluetooth", NULL);
 }
diff -Nru a/net/bluetooth/bnep/sock.c b/net/bluetooth/bnep/sock.c
--- a/net/bluetooth/bnep/sock.c	2005-03-08 06:44:10 -03:00
+++ b/net/bluetooth/bnep/sock.c	2005-03-08 06:44:10 -03:00
@@ -176,17 +176,21 @@
 	if (sock->type != SOCK_RAW)
 		return -ESOCKTNOSUPPORT;
 
-	if (!(sk = bt_sock_alloc(sock, PF_BLUETOOTH, 0, GFP_KERNEL)))
+	if (!(sk = sk_alloc(PF_BLUETOOTH, GFP_KERNEL, sizeof(struct bt_sock), NULL)))
 		return -ENOMEM;
 
+	sock_init_data(sock, sk);
+	INIT_LIST_HEAD(&bt_sk(sk)->accept_q);
+
 	sk_set_owner(sk, THIS_MODULE);
 
 	sock->ops = &bnep_sock_ops;
 
 	sock->state  = SS_UNCONNECTED;
 
-	sk->sk_destruct = NULL;
+	sk->sk_zapped	= 0;
 	sk->sk_protocol = protocol;
+	sk->sk_state	= BT_OPEN;
 	return 0;
 }
 
diff -Nru a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
--- a/net/bluetooth/hci_sock.c	2005-03-08 06:44:10 -03:00
+++ b/net/bluetooth/hci_sock.c	2005-03-08 06:44:10 -03:00
@@ -601,9 +601,14 @@
 
 	sock->ops = &hci_sock_ops;
 
-	sk = bt_sock_alloc(sock, protocol, sizeof(struct hci_pinfo), GFP_KERNEL);
+	sk = sk_alloc(PF_BLUETOOTH, GFP_KERNEL, sizeof(struct hci_pinfo), NULL);
 	if (!sk)
 		return -ENOMEM;
+
+	sock_init_data(sock, sk);
+
+	sk->sk_zapped   = 0;
+	sk->sk_protocol = protocol;
 
 	sk_set_owner(sk, THIS_MODULE);
 
diff -Nru a/net/bluetooth/hidp/sock.c b/net/bluetooth/hidp/sock.c
--- a/net/bluetooth/hidp/sock.c	2005-03-08 06:44:10 -03:00
+++ b/net/bluetooth/hidp/sock.c	2005-03-08 06:44:10 -03:00
@@ -173,17 +173,19 @@
 	if (sock->type != SOCK_RAW)
 		return -ESOCKTNOSUPPORT;
 
-	if (!(sk = bt_sock_alloc(sock, PF_BLUETOOTH, 0, GFP_KERNEL)))
+	if (!(sk = sk_alloc(PF_BLUETOOTH, GFP_KERNEL, sizeof(struct bt_sock), NULL)))
 		return -ENOMEM;
 
+	sock_init_data(sock, sk);
 	sk_set_owner(sk, THIS_MODULE);
 
 	sock->ops = &hidp_sock_ops;
 
 	sock->state = SS_UNCONNECTED;
 
-	sk->sk_destruct = NULL;
 	sk->sk_protocol = protocol;
+	sk->sk_zapped	= 0;
+	sk->sk_state	= BT_OPEN;
 
 	return 0;
 }
diff -Nru a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
--- a/net/bluetooth/l2cap.c	2005-03-08 06:44:10 -03:00
+++ b/net/bluetooth/l2cap.c	2005-03-08 06:44:10 -03:00
@@ -374,10 +374,13 @@
 {
 	struct sock *sk;
 
-	sk = bt_sock_alloc(sock, proto, sizeof(struct l2cap_pinfo), prio);
+	sk = sk_alloc(PF_BLUETOOTH, prio, sizeof(struct l2cap_pinfo), NULL);
 	if (!sk)
 		return NULL;
 
+	sock_init_data(sock, sk);
+	INIT_LIST_HEAD(&bt_sk(sk)->accept_q);
+
 	sk_set_owner(sk, THIS_MODULE);
 
 	sk->sk_destruct = l2cap_sock_destruct;
@@ -385,6 +388,7 @@
 
 	sk->sk_protocol = proto;
 	sk->sk_state    = BT_OPEN;
+	sk->sk_zapped	= 0;
 
 	l2cap_sock_init_timer(sk);
 
diff -Nru a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
--- a/net/bluetooth/rfcomm/sock.c	2005-03-08 06:44:10 -03:00
+++ b/net/bluetooth/rfcomm/sock.c	2005-03-08 06:44:10 -03:00
@@ -287,11 +287,13 @@
 	struct rfcomm_dlc *d;
 	struct sock *sk;
 
-	sk = bt_sock_alloc(sock, BTPROTO_RFCOMM, sizeof(struct rfcomm_pinfo), prio);
+	sk = sk_alloc(PF_BLUETOOTH, prio, sizeof(struct rfcomm_pinfo), NULL);
 	if (!sk)
 		return NULL;
 
+	sock_init_data(sock, sk);
 	sk_set_owner(sk, THIS_MODULE);
+	INIT_LIST_HEAD(&bt_sk(sk)->accept_q);
 
 	d = rfcomm_dlc_alloc(prio);
 	if (!d) {
@@ -311,7 +313,8 @@
 	sk->sk_rcvbuf   = RFCOMM_MAX_CREDITS * RFCOMM_DEFAULT_MTU * 10;
 
 	sk->sk_protocol = proto;
-	sk->sk_state    = BT_OPEN;
+	sk->sk_state	= BT_OPEN;
+	sk->sk_zapped	= 0;
 
 	bt_sock_link(&rfcomm_sk_list, sk);
 
diff -Nru a/net/bluetooth/sco.c b/net/bluetooth/sco.c
--- a/net/bluetooth/sco.c	2005-03-08 06:44:10 -03:00
+++ b/net/bluetooth/sco.c	2005-03-08 06:44:10 -03:00
@@ -420,15 +420,20 @@
 {
 	struct sock *sk;
 
-	sk = bt_sock_alloc(sock, proto, sizeof(struct sco_pinfo), prio);
+	sk = sk_alloc(PF_BLUETOOTH, prio, sizeof(struct sco_pinfo), NULL);
 	if (!sk)
 		return NULL;
 
+	sock_init_data(sock, sk);
+	INIT_LIST_HEAD(&bt_sk(sk)->accept_q);
+
 	sk_set_owner(sk, THIS_MODULE);
 
 	sk->sk_destruct = sco_sock_destruct;
 	sk->sk_sndtimeo = SCO_CONN_TIMEOUT;
 	sk->sk_state    = BT_OPEN;
+	sk->sk_zapped   = 0;
+	sk->sk_protocol = proto;
 
 	sco_sock_init_timer(sk);
 


--XsQoSWH+UP9D9v3l--
