From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH][NET] make all protos partially use sk_prot
Date: Sat, 26 Mar 2005 17:22:20 +0100
Message-ID: <1111854140.9195.199.camel@pegasus>
References: <20050326144516.GA21949@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-qi6vU9HfmBaFNAJkOXX2"
Cc: "David S. Miller" <davem@davemloft.net>,
        Network Development Mailing List <netdev@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
In-Reply-To: <20050326144516.GA21949@conectiva.com.br>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-qi6vU9HfmBaFNAJkOXX2
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Arnaldo,

> 	Here is an updated patch, taking, I hope, all of Marcel
> considerations into account and also fixing a bug in proto_register,
> I was returning on error without dropping the lock.

the error path of some init function in the Bluetooth subsystem is still
wrong. And I don't really like your way of using the labels, because
this twists my brain too much. I fixed all of these and while we are at
it, I cleaned up the init functions. Please use the attached patch
instead of your changes to the Bluetooth subsystem.

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Regards

Marcel


--=-qi6vU9HfmBaFNAJkOXX2
Content-Disposition: attachment; filename=patch
Content-Type: text/plain; name=patch; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

===== net/bluetooth/l2cap.c 1.53 vs edited =====
--- 1.53/net/bluetooth/l2cap.c	2005-03-18 15:07:25 +01:00
+++ edited/net/bluetooth/l2cap.c	2005-03-26 17:07:04 +01:00
@@ -370,19 +370,23 @@
 	pi->flush_to = L2CAP_DEFAULT_FLUSH_TO;
 }
 
+static struct proto l2cap_proto = {
+	.name		= "L2CAP",
+	.owner		= THIS_MODULE,
+	.obj_size	= sizeof(struct l2cap_pinfo)
+};
+
 static struct sock *l2cap_sock_alloc(struct socket *sock, int proto, int prio)
 {
 	struct sock *sk;
 
-	sk = sk_alloc(PF_BLUETOOTH, prio, sizeof(struct l2cap_pinfo), NULL);
+	sk = sk_alloc(PF_BLUETOOTH, prio, &l2cap_proto, 1);
 	if (!sk)
 		return NULL;
 
 	sock_init_data(sock, sk);
 	INIT_LIST_HEAD(&bt_sk(sk)->accept_q);
 
-	sk_set_owner(sk, THIS_MODULE);
-
 	sk->sk_destruct = l2cap_sock_destruct;
 	sk->sk_sndtimeo = L2CAP_CONN_TIMEOUT;
 
@@ -2266,15 +2270,22 @@
 static int __init l2cap_init(void)
 {
 	int err;
+	
+	err = proto_register(&l2cap_proto, 0);
+	if (err < 0)
+		return err;
 
-	if ((err = bt_sock_register(BTPROTO_L2CAP, &l2cap_sock_family_ops))) {
+	err = bt_sock_register(BTPROTO_L2CAP, &l2cap_sock_family_ops);
+	if (err < 0) {
 		BT_ERR("L2CAP socket registration failed");
-		return err;
+		goto error;
 	}
 
-	if ((err = hci_register_proto(&l2cap_hci_proto))) {
+	err = hci_register_proto(&l2cap_hci_proto);
+	if (err < 0) {
 		BT_ERR("L2CAP protocol registration failed");
-		return err;
+		bt_sock_unregister(BTPROTO_L2CAP);
+		goto error;
 	}
 
 	l2cap_proc_init();
@@ -2283,18 +2294,23 @@
 	BT_INFO("L2CAP socket layer initialized");
 
 	return 0;
+
+error:
+	proto_unregister(&l2cap_proto);
+	return err;
 }
 
 static void __exit l2cap_exit(void)
 {
 	l2cap_proc_cleanup();
 
-	/* Unregister socket and protocol */
-	if (bt_sock_unregister(BTPROTO_L2CAP))
+	if (bt_sock_unregister(BTPROTO_L2CAP) < 0)
 		BT_ERR("L2CAP socket unregistration failed");
 
-	if (hci_unregister_proto(&l2cap_hci_proto))
+	if (hci_unregister_proto(&l2cap_hci_proto) < 0)
 		BT_ERR("L2CAP protocol unregistration failed");
+
+	proto_unregister(&l2cap_proto);
 }
 
 void l2cap_load(void)
===== net/bluetooth/sco.c 1.32 vs edited =====
--- 1.32/net/bluetooth/sco.c	2005-03-18 15:07:26 +01:00
+++ edited/net/bluetooth/sco.c	2005-03-26 17:06:46 +01:00
@@ -416,19 +416,23 @@
 		sk->sk_type = parent->sk_type;
 }
 
+static struct proto sco_proto = {
+	.name		= "SCO",
+	.owner		= THIS_MODULE,
+	.obj_size	= sizeof(struct sco_pinfo)
+};
+
 static struct sock *sco_sock_alloc(struct socket *sock, int proto, int prio)
 {
 	struct sock *sk;
 
-	sk = sk_alloc(PF_BLUETOOTH, prio, sizeof(struct sco_pinfo), NULL);
+	sk = sk_alloc(PF_BLUETOOTH, prio, &sco_proto, 1);
 	if (!sk)
 		return NULL;
 
 	sock_init_data(sock, sk);
 	INIT_LIST_HEAD(&bt_sk(sk)->accept_q);
 
-	sk_set_owner(sk, THIS_MODULE);
-
 	sk->sk_destruct = sco_sock_destruct;
 	sk->sk_sndtimeo = SCO_CONN_TIMEOUT;
 
@@ -1018,14 +1022,21 @@
 {
 	int err;
 
-	if ((err = bt_sock_register(BTPROTO_SCO, &sco_sock_family_ops))) {
-		BT_ERR("SCO socket registration failed");
+	err = proto_register(&sco_proto, 0);
+	if (err < 0)
 		return err;
+
+	err = bt_sock_register(BTPROTO_SCO, &sco_sock_family_ops);
+	if (err < 0) {
+		BT_ERR("SCO socket registration failed");
+		goto error;
 	}
 
-	if ((err = hci_register_proto(&sco_hci_proto))) {
+	err = hci_register_proto(&sco_hci_proto);
+	if (err < 0) {
 		BT_ERR("SCO protocol registration failed");
-		return err;
+		bt_sock_unregister(BTPROTO_SCO);
+		goto error;
 	}
 
 	sco_proc_init();
@@ -1034,20 +1045,23 @@
 	BT_INFO("SCO socket layer initialized");
 
 	return 0;
+
+error:
+	proto_unregister(&sco_proto);
+	return err;
 }
 
 static void __exit sco_exit(void)
 {
-	int err;
-
 	sco_proc_cleanup();
 
-	/* Unregister socket, protocol and notifier */
-	if ((err = bt_sock_unregister(BTPROTO_SCO)))
-		BT_ERR("SCO socket unregistration failed. %d", err);
+	if (bt_sock_unregister(BTPROTO_SCO) < 0)
+		BT_ERR("SCO socket unregistration failed");
+
+	if (hci_unregister_proto(&sco_hci_proto) < 0)
+		BT_ERR("SCO protocol unregistration failed");
 
-	if ((err = hci_unregister_proto(&sco_hci_proto)))
-		BT_ERR("SCO protocol unregistration failed. %d", err);
+	proto_unregister(&sco_proto);
 }
 
 module_init(sco_init);
===== net/bluetooth/rfcomm/sock.c 1.35 vs edited =====
--- 1.35/net/bluetooth/rfcomm/sock.c	2005-03-18 15:07:27 +01:00
+++ edited/net/bluetooth/rfcomm/sock.c	2005-03-26 17:06:02 +01:00
@@ -282,20 +282,24 @@
 	pi->dlc->link_mode = pi->link_mode;
 }
 
+static struct proto rfcomm_proto = {
+	.name		= "RFCOMM",
+	.owner		= THIS_MODULE,
+	.obj_size	= sizeof(struct rfcomm_pinfo)
+};
+
 static struct sock *rfcomm_sock_alloc(struct socket *sock, int proto, int prio)
 {
 	struct rfcomm_dlc *d;
 	struct sock *sk;
 
-	sk = sk_alloc(PF_BLUETOOTH, prio, sizeof(struct rfcomm_pinfo), NULL);
+	sk = sk_alloc(PF_BLUETOOTH, prio, &rfcomm_proto, 1);
 	if (!sk)
 		return NULL;
 
 	sock_init_data(sock, sk);
 	INIT_LIST_HEAD(&bt_sk(sk)->accept_q);
 
-	sk_set_owner(sk, THIS_MODULE);
-
 	d = rfcomm_dlc_alloc(prio);
 	if (!d) {
 		sk_free(sk);
@@ -978,24 +982,32 @@
 {
 	int err;
 
-	if ((err = bt_sock_register(BTPROTO_RFCOMM, &rfcomm_sock_family_ops))) {
-		BT_ERR("RFCOMM socket layer registration failed. %d", err);
+	err = proto_register(&rfcomm_proto, 0);
+	if (err < 0)
 		return err;
-	}
+
+	err = bt_sock_register(BTPROTO_RFCOMM, &rfcomm_sock_family_ops);
+	if (err < 0)
+		goto error;
 
 	rfcomm_sock_proc_init();
 
 	BT_INFO("RFCOMM socket layer initialized");
+
 	return 0;
+
+error:
+	BT_ERR("RFCOMM socket layer registration failed");
+	proto_unregister(&rfcomm_proto);
+	return err;
 }
 
 void __exit rfcomm_cleanup_sockets(void)
 {
-	int err;
-
 	rfcomm_sock_proc_cleanup();
 
-	/* Unregister socket, protocol and notifier */
-	if ((err = bt_sock_unregister(BTPROTO_RFCOMM)))
-		BT_ERR("RFCOMM socket layer unregistration failed. %d", err);
+	if (bt_sock_unregister(BTPROTO_RFCOMM) < 0)
+		BT_ERR("RFCOMM socket layer unregistration failed");
+
+	proto_unregister(&rfcomm_proto);
 }
===== net/bluetooth/bnep/sock.c 1.17 vs edited =====
--- 1.17/net/bluetooth/bnep/sock.c	2005-03-18 15:07:28 +01:00
+++ edited/net/bluetooth/bnep/sock.c	2005-03-26 17:10:25 +01:00
@@ -167,6 +167,12 @@
 	.mmap       = sock_no_mmap
 };
 
+static struct proto bnep_proto = {
+	.name		= "BNEP",
+	.owner		= THIS_MODULE,
+	.obj_size	= sizeof(struct bt_sock)
+};
+
 static int bnep_sock_create(struct socket *sock, int protocol)
 {
 	struct sock *sk;
@@ -176,13 +182,12 @@
 	if (sock->type != SOCK_RAW)
 		return -ESOCKTNOSUPPORT;
 
-	if (!(sk = sk_alloc(PF_BLUETOOTH, GFP_KERNEL, sizeof(struct bt_sock), NULL)))
+	sk = sk_alloc(PF_BLUETOOTH, GFP_KERNEL, &bnep_proto, 1);
+	if (!sk)
 		return -ENOMEM;
 
 	sock_init_data(sock, sk);
 
-	sk_set_owner(sk, THIS_MODULE);
-
 	sock->ops = &bnep_sock_ops;
 
 	sock->state = SS_UNCONNECTED;
@@ -203,13 +208,30 @@
 
 int __init bnep_sock_init(void)
 {
-	bt_sock_register(BTPROTO_BNEP, &bnep_sock_family_ops);
+	int err;
+
+	err = proto_register(&bnep_proto, 0);
+	if (err < 0)
+		return err;
+
+	err = bt_sock_register(BTPROTO_BNEP, &bnep_sock_family_ops);
+	if (err < 0)
+		goto error;
+
 	return 0;
+
+error:
+	BT_ERR("Can't register BNEP socket");
+	proto_unregister(&bnep_proto);
+	return err;
 }
 
 int __exit bnep_sock_cleanup(void)
 {
-	if (bt_sock_unregister(BTPROTO_BNEP))
+	if (bt_sock_unregister(BTPROTO_BNEP) < 0)
 		BT_ERR("Can't unregister BNEP socket");
+
+	proto_unregister(&bnep_proto);
+
 	return 0;
 }
===== net/bluetooth/cmtp/sock.c 1.5 vs edited =====
--- 1.5/net/bluetooth/cmtp/sock.c	2005-03-18 15:07:29 +01:00
+++ edited/net/bluetooth/cmtp/sock.c	2005-03-26 17:10:48 +01:00
@@ -158,6 +158,12 @@
 	.mmap		= sock_no_mmap
 };
 
+static struct proto cmtp_proto = {
+	.name		= "CMTP",
+	.owner		= THIS_MODULE,
+	.obj_size	= sizeof(struct bt_sock)
+};
+
 static int cmtp_sock_create(struct socket *sock, int protocol)
 {
 	struct sock *sk;
@@ -167,13 +173,12 @@
 	if (sock->type != SOCK_RAW)
 		return -ESOCKTNOSUPPORT;
 
-	if (!(sk = sk_alloc(PF_BLUETOOTH, GFP_KERNEL, sizeof(struct bt_sock), NULL)))
+	sk = sk_alloc(PF_BLUETOOTH, GFP_KERNEL, &cmtp_proto, 1);
+	if (!sk)
 		return -ENOMEM;
 
 	sock_init_data(sock, sk);
 
-	sk_set_owner(sk, THIS_MODULE);
-
 	sock->ops = &cmtp_sock_ops;
 
 	sock->state = SS_UNCONNECTED;
@@ -194,13 +199,28 @@
 
 int cmtp_init_sockets(void)
 {
-	bt_sock_register(BTPROTO_CMTP, &cmtp_sock_family_ops);
+	int err;
+
+	err = proto_register(&cmtp_proto, 0);
+	if (err < 0)
+		return err;
+
+	err = bt_sock_register(BTPROTO_CMTP, &cmtp_sock_family_ops);
+	if (err < 0)
+		goto error;
 
 	return 0;
+
+error:
+	BT_ERR("Can't register CMTP socket");
+	proto_unregister(&cmtp_proto);
+	return err;
 }
 
 void cmtp_cleanup_sockets(void)
 {
-	if (bt_sock_unregister(BTPROTO_CMTP))
+	if (bt_sock_unregister(BTPROTO_CMTP) < 0)
 		BT_ERR("Can't unregister CMTP socket");
+
+	proto_unregister(&cmtp_proto);
 }
===== net/bluetooth/hidp/sock.c 1.2 vs edited =====
--- 1.2/net/bluetooth/hidp/sock.c	2005-03-18 15:07:31 +01:00
+++ edited/net/bluetooth/hidp/sock.c	2005-03-26 17:11:42 +01:00
@@ -164,6 +164,12 @@
 	.mmap		= sock_no_mmap
 };
 
+static struct proto hidp_proto = {
+	.name		= "HIDP",
+	.owner		= THIS_MODULE,
+	.obj_size	= sizeof(struct bt_sock)
+};
+
 static int hidp_sock_create(struct socket *sock, int protocol)
 {
 	struct sock *sk;
@@ -173,13 +179,12 @@
 	if (sock->type != SOCK_RAW)
 		return -ESOCKTNOSUPPORT;
 
-	if (!(sk = sk_alloc(PF_BLUETOOTH, GFP_KERNEL, sizeof(struct bt_sock), NULL)))
+	sk = sk_alloc(PF_BLUETOOTH, GFP_KERNEL, &hidp_proto, 1);
+	if (!sk)
 		return -ENOMEM;
 
 	sock_init_data(sock, sk);
 
-	sk_set_owner(sk, THIS_MODULE);
-
 	sock->ops = &hidp_sock_ops;
 
 	sock->state = SS_UNCONNECTED;
@@ -202,10 +207,19 @@
 {
 	int err;
 
+	err = proto_register(&hidp_proto, 0);
+	if (err < 0)
+		return err;
+
 	err = bt_sock_register(BTPROTO_HIDP, &hidp_sock_family_ops);
 	if (err < 0)
-		BT_ERR("Can't register HIDP socket");
+		goto error;
+
+	return 0;
 
+error:
+	BT_ERR("Can't register HIDP socket");
+	proto_unregister(&hidp_proto);
 	return err;
 }
 
@@ -213,4 +227,6 @@
 {
 	if (bt_sock_unregister(BTPROTO_HIDP) < 0)
 		BT_ERR("Can't unregister HIDP socket");
+
+	proto_unregister(&hidp_proto);
 }

--=-qi6vU9HfmBaFNAJkOXX2--
