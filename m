From: Patrick McHardy <kaber@trash.net>
Subject: Re: 2.6.11 on AMD64 traps
Date: Thu, 10 Mar 2005 00:27:05 +0100
Message-ID: <422F8649.8050707@trash.net>
References: <200503081900.18686.vanco@satro.sk> <200503092142.50027.vanco@satro.sk> <422F6517.6070301@trash.net> <200503092217.01106.vanco@satro.sk>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030903050501090506050905"
Cc: netdev@oss.sgi.com
To: Michal Vanco <vanco@satro.sk>
In-Reply-To: <200503092217.01106.vanco@satro.sk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030903050501090506050905
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Michal Vanco wrote:
> On Wednesday 09 March 2005 22:05, Patrick McHardy wrote:
> 
>>>Sure. Can (or will) this ever be fixed to any usable state also with
>>>netstat? Is this problem related only to AMD64?
>>
>>Maybe. To start dumping entries of an open hashed hash-table at a
>>specific position we need to skip all entries before that position by
>>walking over them. This results in quadratic time complexity. It might
>>be possible to improve this by cacheing the last position in
>>fib_iter_state even between ->stop() and ->start() calls and using
>>generation IDs for invalidation.

And here it is. Could you redo your timing-test with this patch please?

Thanks
Patrick


--------------030903050501090506050905
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/10 00:07:21+01:00 kaber@coreworks.de 
#   [IPV4]: Speed up sequential reading of /proc/net/route
#   
#   Cacheing the current position reduces complexity from O(n^2)
#   to O(n).
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/ipv4/fib_hash.c
#   2005/03/10 00:07:11+01:00 kaber@coreworks.de +22 -1
#   [IPV4]: Speed up sequential reading of /proc/net/route
#   
#   Cacheing the current position reduces complexity from O(n^2)
#   to O(n).
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
--- a/net/ipv4/fib_hash.c	2005-03-10 00:07:43 +01:00
+++ b/net/ipv4/fib_hash.c	2005-03-10 00:07:43 +01:00
@@ -93,6 +93,7 @@
 }
 
 static DEFINE_RWLOCK(fib_hash_lock);
+static unsigned int fib_hash_genid;
 
 #define FZ_MAX_DIVISOR ((PAGE_SIZE<<MAX_ORDER) / sizeof(struct hlist_head))
 
@@ -181,6 +182,7 @@
 		fz->fz_hashmask = new_hashmask;
 		fz->fz_divisor = new_divisor;
 		fn_rebuild_zone(fz, old_ht, old_divisor);
+		fib_hash_genid++;
 		write_unlock_bh(&fib_hash_lock);
 
 		fz_hash_free(old_ht, old_divisor);
@@ -236,6 +238,7 @@
 		table->fn_zones[i]->fz_next = fz;
 	}
 	table->fn_zones[z] = fz;
+	fib_hash_genid++;
 	write_unlock_bh(&fib_hash_lock);
 	return fz;
 }
@@ -451,6 +454,7 @@
 			fa->fa_scope = r->rtm_scope;
 			state = fa->fa_state;
 			fa->fa_state &= ~FA_S_ACCESSED;
+			fib_hash_genid++;
 			write_unlock_bh(&fib_hash_lock);
 
 			fib_release_info(fi_drop);
@@ -515,6 +519,7 @@
 		fib_insert_node(fz, new_f);
 	list_add_tail(&new_fa->fa_list,
 		 (fa ? &fa->fa_list : &f->fn_alias));
+	fib_hash_genid++;
 	write_unlock_bh(&fib_hash_lock);
 
 	if (new_f)
@@ -600,6 +605,7 @@
 			hlist_del(&f->fn_hash);
 			kill_fn = 1;
 		}
+		fib_hash_genid++;
 		write_unlock_bh(&fib_hash_lock);
 
 		if (fa->fa_state & FA_S_ACCESSED)
@@ -637,6 +643,7 @@
 					hlist_del(&f->fn_hash);
 					kill_f = 1;
 				}
+				fib_hash_genid++;
 				write_unlock_bh(&fib_hash_lock);
 
 				fn_free_alias(fa);
@@ -801,6 +808,9 @@
 	struct hlist_head *hash_head;
 	struct fib_node *fn;
 	struct fib_alias *fa;
+	loff_t pos;
+	unsigned int genid;
+	int valid;
 };
 
 static struct fib_alias *fib_get_first(struct seq_file *seq)
@@ -812,6 +822,9 @@
 	iter->hash_head = NULL;
 	iter->fn        = NULL;
 	iter->fa        = NULL;
+	iter->pos	= 0;
+	iter->genid	= fib_hash_genid;
+	iter->valid	= 1;
 
 	for (iter->zone = table->fn_zone_list; iter->zone;
 	     iter->zone = iter->zone->fz_next) {
@@ -916,12 +929,20 @@
 		}
 	}
 out:
+	iter->pos++;
 	return fa;
 }
 
 static struct fib_alias *fib_get_idx(struct seq_file *seq, loff_t pos)
 {
-	struct fib_alias *fa = fib_get_first(seq);
+	struct fib_iter_state *iter = seq->private;
+	struct fib_alias *fa;
+	
+	if (iter->valid && pos >= iter->pos && iter->genid == fib_hash_genid) {
+		fa   = iter->fa;
+		pos -= iter->pos;
+	} else
+		fa = fib_get_first(seq);
 
 	if (fa)
 		while (pos && (fa = fib_get_next(seq)))

--------------030903050501090506050905--
