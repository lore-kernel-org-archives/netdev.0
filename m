From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH 1/9] appletalk: use sock slab cache
Date: Thu, 20 Jan 2005 00:04:05 -0200
Message-ID: <41EF1195.40302@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030908010103020604090602"
Cc: Networking Team <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030908010103020604090602
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

David,

	Subject says it all.

Regards,

- Arnaldo


--------------030908010103020604090602
Content-Type: text/plain;
 name="appletalk_sock.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="appletalk_sock.patch"

===================================================================


ChangeSet@1.2337, 2005-01-19 23:01:48-02:00, acme@toy.ghostprotocols.net
  [APPLETALK] use a private slab cache for socks
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@davemloft.net>


 include/linux/atalk.h |    9 +++++++--
 net/appletalk/ddp.c   |   25 ++++++++++++++++---------
 2 files changed, 23 insertions(+), 11 deletions(-)


diff -Nru a/include/linux/atalk.h b/include/linux/atalk.h
--- a/include/linux/atalk.h	2005-01-19 23:13:41 -02:00
+++ b/include/linux/atalk.h	2005-01-19 23:13:41 -02:00
@@ -63,6 +63,8 @@
 };
 	
 struct atalk_sock {
+	/* struct sock has to be the first member of atalk_sock */
+	struct sock	sk;
 	unsigned short	dest_net;
 	unsigned short	src_net;
 	unsigned char	dest_node;
@@ -71,6 +73,11 @@
 	unsigned char	src_port;
 };
 
+static inline struct atalk_sock *at_sk(struct sock *sk)
+{
+	return (struct atalk_sock *)sk;
+}
+
 #ifdef __KERNEL__
 
 #include <asm/byteorder.h>
@@ -196,8 +203,6 @@
 					   struct atalk_addr *sa);
 
 extern void		aarp_cleanup_module(void);
-
-#define at_sk(__sk) ((struct atalk_sock *)(__sk)->sk_protinfo)
 
 extern struct hlist_head atalk_sockets;
 extern rwlock_t atalk_sockets_lock;
diff -Nru a/net/appletalk/ddp.c b/net/appletalk/ddp.c
--- a/net/appletalk/ddp.c	2005-01-19 23:13:41 -02:00
+++ b/net/appletalk/ddp.c	2005-01-19 23:13:41 -02:00
@@ -74,6 +74,8 @@
 HLIST_HEAD(atalk_sockets);
 DEFINE_RWLOCK(atalk_sockets_lock);
 
+static kmem_cache_t *atalk_sk_slab;
+
 static inline void __atalk_insert_socket(struct sock *sk)
 {
 	sk_add_node(sk, &atalk_sockets);
@@ -1022,7 +1024,6 @@
 static int atalk_create(struct socket *sock, int protocol)
 {
 	struct sock *sk;
-	struct atalk_sock *at;
 	int rc = -ESOCKTNOSUPPORT;
 
 	/*
@@ -1032,13 +1033,10 @@
 	if (sock->type != SOCK_RAW && sock->type != SOCK_DGRAM)
 		goto out;
 	rc = -ENOMEM;
-	sk = sk_alloc(PF_APPLETALK, GFP_KERNEL, 1, NULL);
+	sk = sk_alloc(PF_APPLETALK, GFP_KERNEL,
+		      sizeof(struct atalk_sock), atalk_sk_slab);
 	if (!sk)
 		goto out;
-	at = sk->sk_protinfo = kmalloc(sizeof(*at), GFP_KERNEL);
-	if (!at)
-		goto outsk;
-	memset(at, 0, sizeof(*at));
 	rc = 0;
 	sock->ops = &atalk_dgram_ops;
 	sock_init_data(sock, sk);
@@ -1048,9 +1046,6 @@
 	sk->sk_zapped = 1;
 out:
 	return rc;
-outsk:
-	sk_free(sk);
-	goto out;
 }
 
 /* Free a socket. No work needed */
@@ -1880,6 +1875,13 @@
 /* Called by proto.c on kernel start up */
 static int __init atalk_init(void)
 {
+	atalk_sk_slab = kmem_cache_create("appletalk_sock",
+					  sizeof(struct atalk_sock), 0,
+					  SLAB_HWCACHE_ALIGN, NULL, NULL);
+
+	if (atalk_sk_slab == NULL)
+		return -ENOMEM;
+
 	(void)sock_register(&atalk_family_ops);
 	ddp_dl = register_snap_client(ddp_snap_id, atalk_rcv);
 	if (!ddp_dl)
@@ -1917,6 +1919,11 @@
 	dev_remove_pack(&ppptalk_packet_type);
 	unregister_snap_client(ddp_dl);
 	sock_unregister(PF_APPLETALK);
+
+	if (atalk_sk_slab != NULL) {
+		kmem_cache_destroy(atalk_sk_slab);
+		atalk_sk_slab = NULL;
+	}
 }
 module_exit(atalk_exit);
 



--------------030908010103020604090602--
