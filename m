From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH 3/12][DECNET] Don't use sk_protinfo + private sock slab cache
Date: Fri, 21 Jan 2005 01:19:03 -0200
Message-ID: <41F074A7.4040000@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050508050002080607040404"
Cc: Networking Team <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>,
        Patrick Caulfield <patrick@tykepenguin.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050508050002080607040404
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David/Patrick,

	Please see the log in the patch.

Best Regards,

- Arnaldo


--------------050508050002080607040404
Content-Type: text/plain;
 name="3-decnet.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="3-decnet.patch"

===================================================================


ChangeSet@1.2001, 2005-01-20 20:36:07-02:00, acme@toy.ghostprotocols.net
  [DECNET] Don't use sk_protinfo + private sock slab cache
  
  DecNET already uses a private sock slab cache, but initializes sk->sk_protinfo,
  pointing to (sk + 1), this is wrong because at sk_free time we call
  sk->sk_destruct, that by default points to sock_def_destruct, that does a kfree
  on sk->sk_protinfo, since it was initialized at net_proto_family->create() time
  (dn_create), but in decnet sk_protinfo was not kmalloced, it was allocated
  piggybacked to struct sock.
  
  This doesn't causes problems because decnet sets sk->sk_destruct to a custom
  function that doesn't calls kfree(sk->sk_protinfo), but to reach a long time
  goal of killing sk_protinfo lets just make DN_SK return sk + 1.
  
  I left merging dn_scp with dn_sock for later, as the current state suits my
  needs to introduce connection_sock.
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@davemloft.net>


 include/net/dn.h       |    6 +++++-
 net/decnet/af_decnet.c |    3 +--
 2 files changed, 6 insertions(+), 3 deletions(-)


diff -Nru a/include/net/dn.h b/include/net/dn.h
--- a/include/net/dn.h	2005-01-21 00:23:40 -02:00
+++ b/include/net/dn.h	2005-01-21 00:23:40 -02:00
@@ -2,6 +2,7 @@
 #define _NET_DN_H
 
 #include <linux/dn.h>
+#include <net/sock.h>
 #include <asm/byteorder.h>
 
 typedef unsigned short dn_address;
@@ -133,7 +134,10 @@
 
 };
 
-#define DN_SK(__sk) ((struct dn_scp *)(__sk)->sk_protinfo)
+static inline struct dn_scp *DN_SK(struct sock *sk)
+{
+	return (struct dn_scp *)(sk + 1);
+}
 
 /*
  * src,dst : Source and Destination DECnet addresses
diff -Nru a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
--- a/net/decnet/af_decnet.c	2005-01-21 00:23:40 -02:00
+++ b/net/decnet/af_decnet.c	2005-01-21 00:23:40 -02:00
@@ -456,8 +456,6 @@
 	if  (!sk)
 		goto out;
 
-	sk->sk_protinfo = scp = (struct dn_scp *)(sk + 1);
-
 	if (sock)
 		sock->ops = &dn_proto_ops;
 	sock_init_data(sock, sk);
@@ -471,6 +469,7 @@
 	sk->sk_allocation  = gfp;
 
 	/* Initialization of DECnet Session Control Port		*/
+	scp = DN_SK(sk);
 	scp->state	= DN_O;		/* Open			*/
 	scp->numdat	= 1;		/* Next data seg to tx	*/
 	scp->numoth	= 1;		/* Next oth data to tx  */



--------------050508050002080607040404--
