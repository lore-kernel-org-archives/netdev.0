From: David Howells <dhowells@redhat.com>
Subject: [PATCH 02/11] rxrpc: Do procfs lists through objcache
Date: Mon, 07 Mar 2016 14:38:13 +0000
Message-ID: <20160307143813.18567.5819.stgit@warthog.procyon.org.uk>
References: <20160307143759.18567.8234.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-afs@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54887 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753226AbcCGOiP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2016 09:38:15 -0500
In-Reply-To: <20160307143759.18567.8234.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the object cache primary hash to provide lists of RxRPC objects through
/proc/net/ for all caches where desired.  Each user of the cache just needs
to provide a show function in its objcache struct and register the proc
file with objcache_seq_fops as its file operations.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/objcache.c |  104 ++++++++++++++++++++++++++++++++++++++++++++++++++
 net/rxrpc/objcache.h |    8 ++++
 2 files changed, 112 insertions(+)

diff --git a/net/rxrpc/objcache.c b/net/rxrpc/objcache.c
index 74eed8ce5894..e74f8c3c4119 100644
--- a/net/rxrpc/objcache.c
+++ b/net/rxrpc/objcache.c
@@ -11,6 +11,8 @@
 
 #include <linux/sched.h>
 #include <linux/hash.h>
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include "ar-internal.h"
 #include "objcache.h"
 
@@ -475,3 +477,105 @@ void objcache_clear(struct objcache *cache)
 
 	_leave("");
 }
+
+/*
+ * Generate a list of cached objects in /proc/net/x
+ */
+static void *objcache_seq_start(struct seq_file *seq, loff_t *_pos)
+	__acquires(rcu)
+{
+	struct objcache *cache = seq->private;
+	struct hlist_head *hash;
+	loff_t pos_l = *_pos;
+	unsigned pos = pos_l, bucket;
+	void *ret;
+
+	if (*_pos > UINT_MAX)
+		return NULL;
+	bucket = pos >> 16;
+	pos &= 0xffff;
+
+	rcu_read_lock();
+
+	do {
+		hash = &cache->hash_table[bucket];
+		if (bucket == 0)
+			ret = seq_hlist_start_head(hash, pos);
+		else
+			ret = seq_hlist_start(hash, pos);
+	} while (!ret && (bucket++,
+			  *_pos = bucket << 16,
+			  bucket < cache->nr_buckets));
+
+	return ret;
+}
+
+static void *objcache_seq_next(struct seq_file *seq, void *v, loff_t *_pos)
+{
+	struct objcache *cache = seq->private;
+	struct hlist_head *hash;
+	unsigned bucket;
+	void *ret;
+
+	if (*_pos > UINT_MAX)
+		return NULL;
+	bucket = *_pos >> 16;
+	hash = &cache->hash_table[bucket];
+	ret = seq_hlist_next(v, hash, _pos);
+	if (ret)
+		return ret;
+
+	while (bucket++,
+	       *_pos = bucket << 16,
+	       bucket < cache->nr_buckets
+	       ) {
+		hash = &cache->hash_table[bucket];
+		ret = seq_hlist_start(hash, 0);
+		if (ret)
+			break;
+	}
+	return ret;
+}
+
+static void objcache_seq_stop(struct seq_file *seq, void *v)
+	__releases(rcu)
+{
+	rcu_read_unlock();
+}
+
+static int objcache_seq_show(struct seq_file *seq, void *v)
+{
+	struct objcache *cache = seq->private;
+	struct obj_node *obj = v;
+
+	return cache->seq_show(seq, obj);
+}
+
+static const struct seq_operations objcache_seq_ops = {
+	.start  = objcache_seq_start,
+	.next   = objcache_seq_next,
+	.stop   = objcache_seq_stop,
+	.show   = objcache_seq_show,
+};
+
+static int objcache_seq_open(struct inode *inode, struct file *file)
+{
+	struct objcache *cache = PDE_DATA(inode);
+	struct seq_file *seq;
+	int ret;
+
+	ret = seq_open(file, &objcache_seq_ops);
+	if (ret == 0) {
+		seq = file->private_data;
+		seq->private = cache;
+	}
+	return ret;
+}
+
+const struct file_operations objcache_seq_fops = {
+	.owner		= THIS_MODULE,
+	.open		= objcache_seq_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
diff --git a/net/rxrpc/objcache.h b/net/rxrpc/objcache.h
index 770ec924a6d2..a3799eb4c857 100644
--- a/net/rxrpc/objcache.h
+++ b/net/rxrpc/objcache.h
@@ -52,6 +52,11 @@ struct objcache {
 	unsigned long (*hash_key_2)(const void *);
 	int (*cmp_key_2)(const struct obj_node *, const void *);
 
+	/* If the cache should be visible through /proc, the following
+	 * should be implemented.
+	 */
+	int (*seq_show)(struct seq_file *, void *);
+
 	/* Internal data */
 	spinlock_t		lock;
 	atomic_t		count;
@@ -64,6 +69,7 @@ struct objcache {
 	time64_t		gc_next_run;
 	unsigned		gc_bucket;
 	unsigned		gc_last_bucket;
+	struct seq_operations	seq_ops;
 };
 
 static inline bool objcache_get_maybe(struct obj_node *obj)
@@ -86,4 +92,6 @@ extern void objcache_put(struct objcache *, struct obj_node *);
 extern void objcache_obj_rcu_done(struct objcache *);
 extern void objcache_clear(struct objcache *);
 
+extern const struct file_operations objcache_seq_fops;
+
 #endif /* _OBJCACHE_H */
