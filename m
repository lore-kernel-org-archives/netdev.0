From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH 2/12][APPLETALK] stop using sk_protinfo
Date: Fri, 21 Jan 2005 01:18:59 -0200
Message-ID: <41F074A3.7090307@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080601000101060104000700"
Cc: Networking Team <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080601000101060104000700
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David,

	Subject says it all.

Regards,

- Arnaldo


--------------080601000101060104000700
Content-Type: text/plain;
 name="2-appletalk.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="2-appletalk.patch"

===================================================================


ChangeSet@1.2000, 2005-01-20 20:32:38-02:00, acme@toy.ghostprotocols.net
  [APPLETALK] stop using sk_protinfo
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@davemloft.net>


 include/linux/atalk.h |    9 +++++++--
 net/appletalk/ddp.c   |   11 ++---------
 2 files changed, 9 insertions(+), 11 deletions(-)


diff -Nru a/include/linux/atalk.h b/include/linux/atalk.h
--- a/include/linux/atalk.h	2005-01-21 00:23:51 -02:00
+++ b/include/linux/atalk.h	2005-01-21 00:23:51 -02:00
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
--- a/net/appletalk/ddp.c	2005-01-21 00:23:51 -02:00
+++ b/net/appletalk/ddp.c	2005-01-21 00:23:51 -02:00
@@ -1022,7 +1022,6 @@
 static int atalk_create(struct socket *sock, int protocol)
 {
 	struct sock *sk;
-	struct atalk_sock *at;
 	int rc = -ESOCKTNOSUPPORT;
 
 	/*
@@ -1032,13 +1031,10 @@
 	if (sock->type != SOCK_RAW && sock->type != SOCK_DGRAM)
 		goto out;
 	rc = -ENOMEM;
-	sk = sk_alloc(PF_APPLETALK, GFP_KERNEL, 1, NULL);
+	sk = sk_alloc(PF_APPLETALK, GFP_KERNEL,
+		      sizeof(struct atalk_sock), NULL);
 	if (!sk)
 		goto out;
-	at = sk->sk_protinfo = kmalloc(sizeof(*at), GFP_KERNEL);
-	if (!at)
-		goto outsk;
-	memset(at, 0, sizeof(*at));
 	rc = 0;
 	sock->ops = &atalk_dgram_ops;
 	sock_init_data(sock, sk);
@@ -1048,9 +1044,6 @@
 	sk->sk_zapped = 1;
 out:
 	return rc;
-outsk:
-	sk_free(sk);
-	goto out;
 }
 
 /* Free a socket. No work needed */



--------------080601000101060104000700--
