From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH 4/9]  econet: use sock slab cache
Date: Thu, 20 Jan 2005 00:04:18 -0200
Message-ID: <41EF11A2.1010009@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080204050504020308020602"
Cc: Networking Team <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, Philip Blundell <philb@gnu.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080204050504020308020602
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

David,

	See log in the patch.

Regards,

- Arnaldo


--------------080204050504020308020602
Content-Type: text/plain;
 name="econet_sock.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="econet_sock.patch"

===================================================================


ChangeSet@1.2340, 2005-01-19 23:03:32-02:00, acme@toy.ghostprotocols.net
  [ECONET] use a private slab cache for socks
  
  Required to get rid of sk_protinfo and to introduce struct connection_sock,
  also for consistency with other protocol families implementations.
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@davemloft.net>


 include/linux/if_ec.h  |   10 +++++++---
 net/econet/af_econet.c |   35 ++++++++++++++++++++++-------------
 2 files changed, 29 insertions(+), 16 deletions(-)


diff -Nru a/include/linux/if_ec.h b/include/linux/if_ec.h
--- a/include/linux/if_ec.h	2005-01-19 23:37:25 -02:00
+++ b/include/linux/if_ec.h	2005-01-19 23:37:25 -02:00
@@ -47,8 +47,9 @@
   unsigned char port;
 };
 
-struct econet_opt
-{
+struct econet_sock {
+  /* struct sock has to be the first member of econet_sock */
+  struct sock	sk;
   unsigned char cb;
   unsigned char port;
   unsigned char station;
@@ -56,7 +57,10 @@
   unsigned short num;
 };
 
-#define ec_sk(__sk) ((struct econet_opt *)(__sk)->sk_protinfo)
+static inline struct econet_sock *ec_sk(const struct sock *sk)
+{
+	return (struct econet_sock *)sk;
+}
 
 struct ec_device
 {
diff -Nru a/net/econet/af_econet.c b/net/econet/af_econet.c
--- a/net/econet/af_econet.c	2005-01-19 23:37:25 -02:00
+++ b/net/econet/af_econet.c	2005-01-19 23:37:25 -02:00
@@ -49,6 +49,8 @@
 static struct hlist_head econet_sklist;
 static DEFINE_RWLOCK(econet_lock);
 
+static kmem_cache_t *econet_sk_slab;
+
 /* Since there are only 256 possible network numbers (or fewer, depends
    how you count) it makes sense to use a simple lookup table. */
 static struct net_device *net2dev_map[256];
@@ -184,7 +186,7 @@
 {
 	struct sockaddr_ec *sec = (struct sockaddr_ec *)uaddr;
 	struct sock *sk=sock->sk;
-	struct econet_opt *eo = ec_sk(sk);
+	struct econet_sock *eo = ec_sk(sk);
 	
 	/*
 	 *	Check legality
@@ -284,7 +286,7 @@
 	 */
 	 
 	if (saddr == NULL) {
-		struct econet_opt *eo = ec_sk(sk);
+		struct econet_sock *eo = ec_sk(sk);
 
 		addr.station = eo->station;
 		addr.net     = eo->net;
@@ -485,7 +487,7 @@
 			  int *uaddr_len, int peer)
 {
 	struct sock *sk = sock->sk;
-	struct econet_opt *eo = ec_sk(sk);
+	struct econet_sock *eo = ec_sk(sk);
 	struct sockaddr_ec *sec = (struct sockaddr_ec *)uaddr;
 
 	if (peer)
@@ -562,7 +564,7 @@
 static int econet_create(struct socket *sock, int protocol)
 {
 	struct sock *sk;
-	struct econet_opt *eo;
+	struct econet_sock *eo;
 	int err;
 
 	/* Econet only provides datagram services. */
@@ -572,7 +574,8 @@
 	sock->state = SS_UNCONNECTED;
 
 	err = -ENOBUFS;
-	sk = sk_alloc(PF_ECONET, GFP_KERNEL, 1, NULL);
+	sk = sk_alloc(PF_ECONET, GFP_KERNEL,
+		      sizeof(struct econet_sock), econet_sk_slab);
 	if (sk == NULL)
 		goto out;
 
@@ -581,19 +584,13 @@
 	sock_init_data(sock,sk);
 	sk_set_owner(sk, THIS_MODULE);
 
-	eo = sk->sk_protinfo = kmalloc(sizeof(*eo), GFP_KERNEL);
-	if (!eo)
-		goto out_free;
-	memset(eo, 0, sizeof(*eo));
+	eo = ec_sk(sk);
 	sk->sk_zapped = 0;
 	sk->sk_family = PF_ECONET;
 	eo->num = protocol;
 
 	econet_insert_socket(&econet_sklist, sk);
 	return(0);
-
-out_free:
-	sk_free(sk);
 out:
 	return err;
 }
@@ -735,7 +732,7 @@
 	struct hlist_node *node;
 
 	sk_for_each(sk, node, &econet_sklist) {
-		struct econet_opt *opt = ec_sk(sk);
+		struct econet_sock *opt = ec_sk(sk);
 		if ((opt->port == port || opt->port == 0) && 
 		    (opt->station == station || opt->station == 0) &&
 		    (opt->net == net || opt->net == 0))
@@ -1101,10 +1098,22 @@
 #endif
 	unregister_netdevice_notifier(&econet_netdev_notifier);
 	sock_unregister(econet_family_ops.family);
+
+	if (econet_sk_slab != NULL) {
+		kmem_cache_destroy(econet_sk_slab);
+		econet_sk_slab = NULL;
+	}
 }
 
 static int __init econet_proto_init(void)
 {
+	econet_sk_slab = kmem_cache_create("econet_sock",
+					   sizeof(struct econet_sock), 0,
+					   SLAB_HWCACHE_ALIGN, NULL, NULL);
+
+	if (econet_sk_slab == NULL)
+		return -ENOMEM;
+
 	sock_register(&econet_family_ops);
 #ifdef CONFIG_ECONET_AUNUDP
 	spin_lock_init(&aun_queue_lock);



--------------080204050504020308020602--
