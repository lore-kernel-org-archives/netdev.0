From: maximilian attems <janitor@sternwelten.at>
Subject: [patch-kj]  net/ipv4/fib_hash.c: check kmem_cache_create()
Date: Mon, 21 Jun 2004 19:18:32 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040621171832.GE1545@sputnik.stro.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




From: Francois Romieu <romieu@fr.zoreil.com>

kmem_cache_create leak.

Note: fib_hash_init() can be called many times.

Signed-off-by: Maximilian Attems <janitor@sternwelten.at>



---

 linux-2.6.7-max/net/ipv4/fib_hash.c |   19 ++++++++++++++-----
 1 files changed, 14 insertions(+), 5 deletions(-)

diff -puN net/ipv4/fib_hash.c~ipv4_fib_hash_check net/ipv4/fib_hash.c
--- linux-2.6.7/net/ipv4/fib_hash.c~ipv4_fib_hash_check	2004-06-18 09:10:27.000000000 +0200
+++ linux-2.6.7-max/net/ipv4/fib_hash.c	2004-06-18 09:10:27.000000000 +0200
@@ -871,15 +871,18 @@ struct fib_table * __init fib_hash_init(
 {
 	struct fib_table *tb;
 
-	if (fn_hash_kmem == NULL)
+	tb = kmalloc(sizeof(struct fib_table) + sizeof(struct fn_hash), GFP_KERNEL);
+	if (!tb)
+		goto err_out;
+
+	if (!fn_hash_kmem) {
 		fn_hash_kmem = kmem_cache_create("ip_fib_hash",
 						 sizeof(struct fib_node),
 						 0, SLAB_HWCACHE_ALIGN,
 						 NULL, NULL);
-
-	tb = kmalloc(sizeof(struct fib_table) + sizeof(struct fn_hash), GFP_KERNEL);
-	if (tb == NULL)
-		return NULL;
+		if (!fn_hash_kmem)
+			goto err_free;
+	}
 
 	tb->tb_id = id;
 	tb->tb_lookup = fn_hash_lookup;
@@ -889,7 +892,13 @@ struct fib_table * __init fib_hash_init(
 	tb->tb_select_default = fn_hash_select_default;
 	tb->tb_dump = fn_hash_dump;
 	memset(tb->tb_data, 0, sizeof(struct fn_hash));
+err_out:
 	return tb;
+
+err_free:
+	kfree(tb);
+	tb = NULL;
+	goto err_out;
 }
 
 /* ------------------------------------------------------------------------ */

_
