From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH 5/12][ECONET] stop using sk_protinfo
Date: Fri, 21 Jan 2005 01:19:14 -0200
Message-ID: <41F074B2.6010609@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070606090704060308020104"
Cc: Networking Team <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070606090704060308020104
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

David,

	Subject says it all.

Regards,

- Arnaldo


--------------070606090704060308020104
Content-Type: text/plain;
 name="5-econet.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="5-econet.patch"

===================================================================


ChangeSet@1.2003, 2005-01-20 20:44:56-02:00, acme@toy.ghostprotocols.net
  [ECONET] stop using sk_protinfo
  
  Required to introduce struct connection_sock.
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@davemloft.net>


 include/linux/if_ec.h  |   10 +++++++---
 net/econet/af_econet.c |   21 ++++++++-------------
 2 files changed, 15 insertions(+), 16 deletions(-)


diff -Nru a/include/linux/if_ec.h b/include/linux/if_ec.h
--- a/include/linux/if_ec.h	2005-01-21 00:23:17 -02:00
+++ b/include/linux/if_ec.h	2005-01-21 00:23:17 -02:00
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
--- a/net/econet/af_econet.c	2005-01-21 00:23:17 -02:00
+++ b/net/econet/af_econet.c	2005-01-21 00:23:17 -02:00
@@ -184,7 +184,7 @@
 {
 	struct sockaddr_ec *sec = (struct sockaddr_ec *)uaddr;
 	struct sock *sk=sock->sk;
-	struct econet_opt *eo = ec_sk(sk);
+	struct econet_sock *eo = ec_sk(sk);
 	
 	/*
 	 *	Check legality
@@ -284,7 +284,7 @@
 	 */
 	 
 	if (saddr == NULL) {
-		struct econet_opt *eo = ec_sk(sk);
+		struct econet_sock *eo = ec_sk(sk);
 
 		addr.station = eo->station;
 		addr.net     = eo->net;
@@ -485,7 +485,7 @@
 			  int *uaddr_len, int peer)
 {
 	struct sock *sk = sock->sk;
-	struct econet_opt *eo = ec_sk(sk);
+	struct econet_sock *eo = ec_sk(sk);
 	struct sockaddr_ec *sec = (struct sockaddr_ec *)uaddr;
 
 	if (peer)
@@ -562,7 +562,7 @@
 static int econet_create(struct socket *sock, int protocol)
 {
 	struct sock *sk;
-	struct econet_opt *eo;
+	struct econet_sock *eo;
 	int err;
 
 	/* Econet only provides datagram services. */
@@ -572,7 +572,8 @@
 	sock->state = SS_UNCONNECTED;
 
 	err = -ENOBUFS;
-	sk = sk_alloc(PF_ECONET, GFP_KERNEL, 1, NULL);
+	sk = sk_alloc(PF_ECONET, GFP_KERNEL,
+		      sizeof(struct econet_sock), NULL);
 	if (sk == NULL)
 		goto out;
 
@@ -581,19 +582,13 @@
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
@@ -735,7 +730,7 @@
 	struct hlist_node *node;
 
 	sk_for_each(sk, node, &econet_sklist) {
-		struct econet_opt *opt = ec_sk(sk);
+		struct econet_sock *opt = ec_sk(sk);
 		if ((opt->port == port || opt->port == 0) && 
 		    (opt->station == station || opt->station == 0) &&
 		    (opt->net == net || opt->net == 0))



--------------070606090704060308020104--
