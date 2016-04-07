From: David Howells <dhowells@redhat.com>
Subject: [PATCH 8/9] rxrpc: Absorb the rxkad security module
Date: Thu, 07 Apr 2016 17:23:51 +0100
Message-ID: <20160407162351.21283.3398.stgit@warthog.procyon.org.uk>
References: <20160407162256.21283.47849.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-afs@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160407162256.21283.47849.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Absorb the rxkad security module into the af_rxrpc module so that there's
only one module file.  This avoids a circular dependency whereby rxkad pins
af_rxrpc and cached connections pin rxkad but can't be manually evicted
(they will expire eventually and cease pinning).

With this change, af_rxrpc can just be unloaded, despite having cached
connections.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/Kconfig       |    2 -
 net/rxrpc/Makefile      |    3 -
 net/rxrpc/af_rxrpc.c    |    9 +++
 net/rxrpc/ar-internal.h |   21 ++++++--
 net/rxrpc/ar-security.c |  123 +++++++++++++----------------------------------
 net/rxrpc/rxkad.c       |   61 ++++++++++-------------
 6 files changed, 85 insertions(+), 134 deletions(-)

diff --git a/net/rxrpc/Kconfig b/net/rxrpc/Kconfig
index 23dcef12b986..784c53163b7b 100644
--- a/net/rxrpc/Kconfig
+++ b/net/rxrpc/Kconfig
@@ -30,7 +30,7 @@ config AF_RXRPC_DEBUG
 
 
 config RXKAD
-	tristate "RxRPC Kerberos security"
+	bool "RxRPC Kerberos security"
 	depends on AF_RXRPC
 	select CRYPTO
 	select CRYPTO_MANAGER
diff --git a/net/rxrpc/Makefile b/net/rxrpc/Makefile
index 5b98c1640d6d..fa09cb55bfce 100644
--- a/net/rxrpc/Makefile
+++ b/net/rxrpc/Makefile
@@ -22,8 +22,7 @@ af-rxrpc-y := \
 	misc.o
 
 af-rxrpc-$(CONFIG_PROC_FS) += ar-proc.o
+af-rxrpc-$(CONFIG_RXKAD) += rxkad.o
 af-rxrpc-$(CONFIG_SYSCTL) += sysctl.o
 
 obj-$(CONFIG_AF_RXRPC) += af-rxrpc.o
-
-obj-$(CONFIG_RXKAD) += rxkad.o
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 9d935fa5a2a9..f4a88bc30bce 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -806,6 +806,12 @@ static int __init af_rxrpc_init(void)
 		goto error_work_queue;
 	}
 
+	ret = rxrpc_init_security();
+	if (ret < 0) {
+		printk(KERN_CRIT "RxRPC: Cannot initialise security\n");
+		goto error_security;
+	}
+	
 	ret = proto_register(&rxrpc_proto, 1);
 	if (ret < 0) {
 		printk(KERN_CRIT "RxRPC: Cannot register protocol\n");
@@ -853,6 +859,8 @@ error_sock:
 	proto_unregister(&rxrpc_proto);
 error_proto:
 	destroy_workqueue(rxrpc_workqueue);
+error_security:
+	rxrpc_exit_security();
 error_work_queue:
 	kmem_cache_destroy(rxrpc_call_jar);
 error_call_jar:
@@ -883,6 +891,7 @@ static void __exit af_rxrpc_exit(void)
 	remove_proc_entry("rxrpc_conns", init_net.proc_net);
 	remove_proc_entry("rxrpc_calls", init_net.proc_net);
 	destroy_workqueue(rxrpc_workqueue);
+	rxrpc_exit_security();
 	kmem_cache_destroy(rxrpc_call_jar);
 	_leave("");
 }
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index d38071b09f72..72fd675a891e 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -124,11 +124,15 @@ enum rxrpc_command {
  * RxRPC security module interface
  */
 struct rxrpc_security {
-	struct module		*owner;		/* providing module */
-	struct list_head	link;		/* link in master list */
 	const char		*name;		/* name of this service */
 	u8			security_index;	/* security type provided */
 
+	/* Initialise a security service */
+	int (*init)(void);
+
+	/* Clean up a security service */
+	void (*exit)(void);
+
 	/* initialise a connection's security */
 	int (*init_connection_security)(struct rxrpc_connection *);
 
@@ -268,7 +272,7 @@ struct rxrpc_connection {
 	struct rb_root		calls;		/* calls on this connection */
 	struct sk_buff_head	rx_queue;	/* received conn-level packets */
 	struct rxrpc_call	*channels[RXRPC_MAXCALLS]; /* channels (active calls) */
-	struct rxrpc_security	*security;	/* applied security module */
+	const struct rxrpc_security *security;	/* applied security module */
 	struct key		*key;		/* security for this connection (client) */
 	struct key		*server_key;	/* security for this service */
 	struct crypto_skcipher	*cipher;	/* encryption handle */
@@ -604,8 +608,8 @@ int rxrpc_recvmsg(struct socket *, struct msghdr *, size_t, int);
 /*
  * ar-security.c
  */
-int rxrpc_register_security(struct rxrpc_security *);
-void rxrpc_unregister_security(struct rxrpc_security *);
+int __init rxrpc_init_security(void);
+void rxrpc_exit_security(void);
 int rxrpc_init_client_conn_security(struct rxrpc_connection *);
 int rxrpc_init_server_conn_security(struct rxrpc_connection *);
 int rxrpc_secure_packet(const struct rxrpc_call *, struct sk_buff *, size_t,
@@ -646,6 +650,13 @@ extern const s8 rxrpc_ack_priority[];
 extern const char *rxrpc_acks(u8 reason);
 
 /*
+ * rxkad.c
+ */
+#ifdef CONFIG_RXKAD
+extern const struct rxrpc_security rxkad;
+#endif
+
+/*
  * sysctl.c
  */
 #ifdef CONFIG_SYSCTL
diff --git a/net/rxrpc/ar-security.c b/net/rxrpc/ar-security.c
index ceff6394a65f..6946aec7ab1f 100644
--- a/net/rxrpc/ar-security.c
+++ b/net/rxrpc/ar-security.c
@@ -22,109 +22,59 @@
 static LIST_HEAD(rxrpc_security_methods);
 static DECLARE_RWSEM(rxrpc_security_sem);
 
-/*
- * get an RxRPC security module
- */
-static struct rxrpc_security *rxrpc_security_get(struct rxrpc_security *sec)
-{
-	return try_module_get(sec->owner) ? sec : NULL;
-}
+static const struct rxrpc_security *rxrpc_security_types[] = {
+#ifdef CONFIG_RXKAD
+	[RXRPC_SECURITY_RXKAD]	= &rxkad,
+#endif
+};
 
-/*
- * release an RxRPC security module
- */
-static void rxrpc_security_put(struct rxrpc_security *sec)
+int __init rxrpc_init_security(void)
 {
-	module_put(sec->owner);
-}
+	int i, ret;
 
-/*
- * look up an rxrpc security module
- */
-static struct rxrpc_security *rxrpc_security_lookup(u8 security_index)
-{
-	struct rxrpc_security *sec = NULL;
-
-	_enter("");
-
-	down_read(&rxrpc_security_sem);
-
-	list_for_each_entry(sec, &rxrpc_security_methods, link) {
-		if (sec->security_index == security_index) {
-			if (unlikely(!rxrpc_security_get(sec)))
-				break;
-			goto out;
+	for (i = 0; i < ARRAY_SIZE(rxrpc_security_types); i++) {
+		if (rxrpc_security_types[i]) {
+			ret = rxrpc_security_types[i]->init();
+			if (ret < 0)
+				goto failed;
 		}
 	}
 
-	sec = NULL;
-out:
-	up_read(&rxrpc_security_sem);
-	_leave(" = %p [%s]", sec, sec ? sec->name : "");
-	return sec;
+	return 0;
+
+failed:
+	for (i--; i >= 0; i--)
+		if (rxrpc_security_types[i])
+			rxrpc_security_types[i]->exit();
+	return ret;
 }
 
-/**
- * rxrpc_register_security - register an RxRPC security handler
- * @sec: security module
- *
- * register an RxRPC security handler for use by RxRPC
- */
-int rxrpc_register_security(struct rxrpc_security *sec)
+void rxrpc_exit_security(void)
 {
-	struct rxrpc_security *psec;
-	int ret;
-
-	_enter("");
-	down_write(&rxrpc_security_sem);
-
-	ret = -EEXIST;
-	list_for_each_entry(psec, &rxrpc_security_methods, link) {
-		if (psec->security_index == sec->security_index)
-			goto out;
-	}
-
-	list_add(&sec->link, &rxrpc_security_methods);
-
-	printk(KERN_NOTICE "RxRPC: Registered security type %d '%s'\n",
-	       sec->security_index, sec->name);
-	ret = 0;
+	int i;
 
-out:
-	up_write(&rxrpc_security_sem);
-	_leave(" = %d", ret);
-	return ret;
+	for (i = 0; i < ARRAY_SIZE(rxrpc_security_types); i++)
+		if (rxrpc_security_types[i])
+			rxrpc_security_types[i]->exit();
 }
 
-EXPORT_SYMBOL_GPL(rxrpc_register_security);
-
-/**
- * rxrpc_unregister_security - unregister an RxRPC security handler
- * @sec: security module
- *
- * unregister an RxRPC security handler
+/*
+ * look up an rxrpc security module
  */
-void rxrpc_unregister_security(struct rxrpc_security *sec)
+static const struct rxrpc_security *rxrpc_security_lookup(u8 security_index)
 {
-
-	_enter("");
-	down_write(&rxrpc_security_sem);
-	list_del_init(&sec->link);
-	up_write(&rxrpc_security_sem);
-
-	printk(KERN_NOTICE "RxRPC: Unregistered security type %d '%s'\n",
-	       sec->security_index, sec->name);
+	if (security_index >= ARRAY_SIZE(rxrpc_security_types))
+		return NULL;
+	return rxrpc_security_types[security_index];
 }
 
-EXPORT_SYMBOL_GPL(rxrpc_unregister_security);
-
 /*
  * initialise the security on a client connection
  */
 int rxrpc_init_client_conn_security(struct rxrpc_connection *conn)
 {
+	const struct rxrpc_security *sec;
 	struct rxrpc_key_token *token;
-	struct rxrpc_security *sec;
 	struct key *key = conn->key;
 	int ret;
 
@@ -148,7 +98,6 @@ int rxrpc_init_client_conn_security(struct rxrpc_connection *conn)
 
 	ret = conn->security->init_connection_security(conn);
 	if (ret < 0) {
-		rxrpc_security_put(conn->security);
 		conn->security = NULL;
 		return ret;
 	}
@@ -162,7 +111,7 @@ int rxrpc_init_client_conn_security(struct rxrpc_connection *conn)
  */
 int rxrpc_init_server_conn_security(struct rxrpc_connection *conn)
 {
-	struct rxrpc_security *sec;
+	const struct rxrpc_security *sec;
 	struct rxrpc_local *local = conn->trans->local;
 	struct rxrpc_sock *rx;
 	struct key *key;
@@ -188,14 +137,12 @@ int rxrpc_init_server_conn_security(struct rxrpc_connection *conn)
 
 	/* the service appears to have died */
 	read_unlock_bh(&local->services_lock);
-	rxrpc_security_put(sec);
 	_leave(" = -ENOENT");
 	return -ENOENT;
 
 found_service:
 	if (!rx->securities) {
 		read_unlock_bh(&local->services_lock);
-		rxrpc_security_put(sec);
 		_leave(" = -ENOKEY");
 		return -ENOKEY;
 	}
@@ -205,7 +152,6 @@ found_service:
 			      &key_type_rxrpc_s, kdesc);
 	if (IS_ERR(kref)) {
 		read_unlock_bh(&local->services_lock);
-		rxrpc_security_put(sec);
 		_leave(" = %ld [search]", PTR_ERR(kref));
 		return PTR_ERR(kref);
 	}
@@ -253,11 +199,8 @@ void rxrpc_clear_conn_security(struct rxrpc_connection *conn)
 {
 	_enter("{%d}", conn->debug_id);
 
-	if (conn->security) {
+	if (conn->security)
 		conn->security->clear(conn);
-		rxrpc_security_put(conn->security);
-		conn->security = NULL;
-	}
 
 	key_put(conn->key);
 	key_put(conn->server_key);
diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index f0aeb8163688..6b726a046a7d 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -20,7 +20,6 @@
 #include <net/sock.h>
 #include <net/af_rxrpc.h>
 #include <keys/rxrpc-type.h>
-#define rxrpc_debug rxkad_debug
 #include "ar-internal.h"
 
 #define RXKAD_VERSION			2
@@ -31,10 +30,6 @@
 #define REALM_SZ			40	/* size of principal's auth domain */
 #define SNAME_SZ			40	/* size of service name */
 
-unsigned int rxrpc_debug;
-module_param_named(debug, rxrpc_debug, uint, S_IWUSR | S_IRUGO);
-MODULE_PARM_DESC(debug, "rxkad debugging mask");
-
 struct rxkad_level1_hdr {
 	__be32	data_size;	/* true data size (excluding padding) */
 };
@@ -44,10 +39,6 @@ struct rxkad_level2_hdr {
 	__be32	checksum;	/* decrypted data checksum */
 };
 
-MODULE_DESCRIPTION("RxRPC network protocol type-2 security (Kerberos 4)");
-MODULE_AUTHOR("Red Hat, Inc.");
-MODULE_LICENSE("GPL");
-
 /*
  * this holds a pinned cipher so that keventd doesn't get called by the cipher
  * alloc routine, but since we have it to hand, we use it to decrypt RESPONSE
@@ -1164,12 +1155,35 @@ static void rxkad_clear(struct rxrpc_connection *conn)
 }
 
 /*
+ * Initialise the rxkad security service.
+ */
+static int rxkad_init(void)
+{
+	/* pin the cipher we need so that the crypto layer doesn't invoke
+	 * keventd to go get it */
+	rxkad_ci = crypto_alloc_skcipher("pcbc(fcrypt)", 0, CRYPTO_ALG_ASYNC);
+	if (IS_ERR(rxkad_ci))
+		return PTR_ERR(rxkad_ci);
+	return 0;
+}
+
+/*
+ * Clean up the rxkad security service.
+ */
+static void rxkad_exit(void)
+{
+	if (rxkad_ci)
+		crypto_free_skcipher(rxkad_ci);
+}
+
+/*
  * RxRPC Kerberos-based security
  */
-static struct rxrpc_security rxkad = {
-	.owner				= THIS_MODULE,
+const struct rxrpc_security rxkad = {
 	.name				= "rxkad",
 	.security_index			= RXRPC_SECURITY_RXKAD,
+	.init				= rxkad_init,
+	.exit				= rxkad_exit,
 	.init_connection_security	= rxkad_init_connection_security,
 	.prime_packet_security		= rxkad_prime_packet_security,
 	.secure_packet			= rxkad_secure_packet,
@@ -1179,28 +1193,3 @@ static struct rxrpc_security rxkad = {
 	.verify_response		= rxkad_verify_response,
 	.clear				= rxkad_clear,
 };
-
-static __init int rxkad_init(void)
-{
-	_enter("");
-
-	/* pin the cipher we need so that the crypto layer doesn't invoke
-	 * keventd to go get it */
-	rxkad_ci = crypto_alloc_skcipher("pcbc(fcrypt)", 0, CRYPTO_ALG_ASYNC);
-	if (IS_ERR(rxkad_ci))
-		return PTR_ERR(rxkad_ci);
-
-	return rxrpc_register_security(&rxkad);
-}
-
-module_init(rxkad_init);
-
-static __exit void rxkad_exit(void)
-{
-	_enter("");
-
-	rxrpc_unregister_security(&rxkad);
-	crypto_free_skcipher(rxkad_ci);
-}
-
-module_exit(rxkad_exit);
