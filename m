From: acme@ghostprotocols.net (Arnaldo Carvalho de Melo)
Subject: [PATCH][NET] Don't call kmem_cache_create with a spinlock held
Date: Tue, 5 Apr 2005 15:25:17 -0300
Message-ID: <20050405182517.GR640@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="T7mxYSe680VjQnyC"
Cc: marcel@holtmann.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--T7mxYSe680VjQnyC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi David,

	Please pull from:

bk://kernel.bkbits.net/acme/net-2.6

Best Regards,

                        - Arnaldo

--T7mxYSe680VjQnyC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="proto_register_lock_fix.patch"

===================================================================


ChangeSet@1.2245, 2005-04-05 14:52:51-03:00, acme@toy.ghostprotocols.net
  [NET] Don't call kmem_cache_create with a spinlock held
  
  This fixes the warning reported by Marcel Holtmann (Thanks!).
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@davemloft.net>


 sock.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)


diff -Nru a/net/core/sock.c b/net/core/sock.c
--- a/net/core/sock.c	2005-04-05 15:22:27 -03:00
+++ b/net/core/sock.c	2005-04-05 15:22:27 -03:00
@@ -1359,8 +1359,6 @@
 {
 	int rc = -ENOBUFS;
 
-	write_lock(&proto_list_lock);
-
 	if (alloc_slab) {
 		prot->slab = kmem_cache_create(prot->name, prot->obj_size, 0,
 					       SLAB_HWCACHE_ALIGN, NULL, NULL);
@@ -1368,14 +1366,15 @@
 		if (prot->slab == NULL) {
 			printk(KERN_CRIT "%s: Can't create sock SLAB cache!\n",
 			       prot->name);
-			goto out_unlock;
+			goto out;
 		}
 	}
 
+	write_lock(&proto_list_lock);
 	list_add(&prot->node, &proto_list);
-	rc = 0;
-out_unlock:
 	write_unlock(&proto_list_lock);
+	rc = 0;
+out:
 	return rc;
 }
 


--T7mxYSe680VjQnyC--
