From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH 1/12][SOCK] make sk_alloc use kmalloc for non performance
 critical families
Date: Fri, 21 Jan 2005 01:18:55 -0200
Message-ID: <41F0749F.1020004@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020501040803020306020406"
Cc: Networking Team <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020501040803020306020406
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David,

	Please see the log in the patch.

Regards,

- Arnaldo


--------------020501040803020306020406
Content-Type: text/plain;
 name="1-sk_alloc.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="1-sk_alloc.patch"

===================================================================


ChangeSet@1.1999, 2005-01-20 20:25:41-02:00, acme@toy.ghostprotocols.net
  [SOCK] make sk_alloc use kmalloc for non performance critical families
  
  With this we can have aggregate protocol specific struct proto_sock
  allocated for non performance critical protocols.
  
  We still check for slab == NULL && zero_it == 1 to allocate from the
  generic "sock" slab cache, but this will be removed when all the
  network families stop using sk_protinfo, when the generic "sock"
  slab cache will be removed.
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@davemloft.net>


 sock.c |   17 ++++++++++++++---
 1 files changed, 14 insertions(+), 3 deletions(-)


diff -Nru a/net/core/sock.c b/net/core/sock.c
--- a/net/core/sock.c	2005-01-21 00:24:03 -02:00
+++ b/net/core/sock.c	2005-01-21 00:24:03 -02:00
@@ -621,9 +621,17 @@
 {
 	struct sock *sk = NULL;
 
-	if (!slab)
+	/*
+	 * Transitional, this test will be removed when sk_cachep is killed
+	 */
+	if (slab == NULL && zero_it == 1)
 		slab = sk_cachep;
-	sk = kmem_cache_alloc(slab, priority);
+
+	if (slab != NULL)
+		sk = kmem_cache_alloc(slab, priority);
+	else
+		sk = kmalloc(zero_it, priority);
+
 	if (sk) {
 		if (zero_it) {
 			memset(sk, 0,
@@ -662,7 +670,10 @@
 		       __FUNCTION__, atomic_read(&sk->sk_omem_alloc));
 
 	security_sk_free(sk);
-	kmem_cache_free(sk->sk_slab, sk);
+	if (sk->sk_slab != NULL)
+		kmem_cache_free(sk->sk_slab, sk);
+	else
+		kfree(sk);
 	module_put(owner);
 }
 



--------------020501040803020306020406--
