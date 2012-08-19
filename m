From: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v2 13/16] lockd: use new hashtable implementation
Date: Sun, 19 Aug 2012 02:52:27 +0200
Message-ID: <1345337550-24304-15-git-send-email-levinsasha928@gmail.com>
References: <1345337550-24304-1-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
	paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org,
	ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org,
	ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org,
	lw-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org,
	Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ejt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1345337550-24304-1-git-send-email-levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Switch lockd to use the new hashtable implementation. This reduces the amount of
generic unrelated code in lockd.

Signed-off-by: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 fs/lockd/svcsubs.c |   66 ++++++++++++++++++++++++++++-----------------------
 1 files changed, 36 insertions(+), 30 deletions(-)

diff --git a/fs/lockd/svcsubs.c b/fs/lockd/svcsubs.c
index 0deb5f6..d223a1f 100644
--- a/fs/lockd/svcsubs.c
+++ b/fs/lockd/svcsubs.c
@@ -20,6 +20,7 @@
 #include <linux/lockd/share.h>
 #include <linux/module.h>
 #include <linux/mount.h>
+#include <linux/hashtable.h>
 
 #define NLMDBG_FACILITY		NLMDBG_SVCSUBS
 
@@ -28,8 +29,7 @@
  * Global file hash table
  */
 #define FILE_HASH_BITS		7
-#define FILE_NRHASH		(1<<FILE_HASH_BITS)
-static struct hlist_head	nlm_files[FILE_NRHASH];
+static DEFINE_HASHTABLE(nlm_files, FILE_HASH_BITS);
 static DEFINE_MUTEX(nlm_file_mutex);
 
 #ifdef NFSD_DEBUG
@@ -68,7 +68,7 @@ static inline unsigned int file_hash(struct nfs_fh *f)
 	int i;
 	for (i=0; i<NFS2_FHSIZE;i++)
 		tmp += f->data[i];
-	return tmp & (FILE_NRHASH - 1);
+	return tmp;
 }
 
 /*
@@ -86,17 +86,17 @@ nlm_lookup_file(struct svc_rqst *rqstp, struct nlm_file **result,
 {
 	struct hlist_node *pos;
 	struct nlm_file	*file;
-	unsigned int	hash;
+	unsigned int	key;
 	__be32		nfserr;
 
 	nlm_debug_print_fh("nlm_lookup_file", f);
 
-	hash = file_hash(f);
+	key = file_hash(f);
 
 	/* Lock file table */
 	mutex_lock(&nlm_file_mutex);
 
-	hlist_for_each_entry(file, pos, &nlm_files[hash], f_list)
+	hash_for_each_possible(nlm_files, file, pos, f_list, file_hash(f))
 		if (!nfs_compare_fh(&file->f_handle, f))
 			goto found;
 
@@ -123,7 +123,7 @@ nlm_lookup_file(struct svc_rqst *rqstp, struct nlm_file **result,
 		goto out_free;
 	}
 
-	hlist_add_head(&file->f_list, &nlm_files[hash]);
+	hash_add(nlm_files, &file->f_list, key);
 
 found:
 	dprintk("lockd: found file %p (count %d)\n", file, file->f_count);
@@ -147,8 +147,8 @@ static inline void
 nlm_delete_file(struct nlm_file *file)
 {
 	nlm_debug_print_file("closing file", file);
-	if (!hlist_unhashed(&file->f_list)) {
-		hlist_del(&file->f_list);
+	if (hash_hashed(&file->f_list)) {
+		hash_del(&file->f_list);
 		nlmsvc_ops->fclose(file->f_file);
 		kfree(file);
 	} else {
@@ -253,27 +253,25 @@ nlm_traverse_files(void *data, nlm_host_match_fn_t match,
 	int i, ret = 0;
 
 	mutex_lock(&nlm_file_mutex);
-	for (i = 0; i < FILE_NRHASH; i++) {
-		hlist_for_each_entry_safe(file, pos, next, &nlm_files[i], f_list) {
-			if (is_failover_file && !is_failover_file(data, file))
-				continue;
-			file->f_count++;
-			mutex_unlock(&nlm_file_mutex);
-
-			/* Traverse locks, blocks and shares of this file
-			 * and update file->f_locks count */
-			if (nlm_inspect_file(data, file, match))
-				ret = 1;
-
-			mutex_lock(&nlm_file_mutex);
-			file->f_count--;
-			/* No more references to this file. Let go of it. */
-			if (list_empty(&file->f_blocks) && !file->f_locks
-			 && !file->f_shares && !file->f_count) {
-				hlist_del(&file->f_list);
-				nlmsvc_ops->fclose(file->f_file);
-				kfree(file);
-			}
+	hash_for_each_safe(nlm_files, i, pos, next, file, f_list) {
+		if (is_failover_file && !is_failover_file(data, file))
+			continue;
+		file->f_count++;
+		mutex_unlock(&nlm_file_mutex);
+
+		/* Traverse locks, blocks and shares of this file
+		 * and update file->f_locks count */
+		if (nlm_inspect_file(data, file, match))
+			ret = 1;
+
+		mutex_lock(&nlm_file_mutex);
+		file->f_count--;
+		/* No more references to this file. Let go of it. */
+		if (list_empty(&file->f_blocks) && !file->f_locks
+		 && !file->f_shares && !file->f_count) {
+			hash_del(&file->f_list);
+			nlmsvc_ops->fclose(file->f_file);
+			kfree(file);
 		}
 	}
 	mutex_unlock(&nlm_file_mutex);
@@ -451,3 +449,11 @@ nlmsvc_unlock_all_by_ip(struct sockaddr *server_addr)
 	return ret ? -EIO : 0;
 }
 EXPORT_SYMBOL_GPL(nlmsvc_unlock_all_by_ip);
+
+static int __init nlm_init(void)
+{
+	hash_init(nlm_files);
+	return 0;
+}
+
+module_init(nlm_init);
-- 
1.7.8.6
