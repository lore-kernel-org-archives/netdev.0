From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH v2 01/10] sysctl: Stop implicitly passing current into
	sysctl_table_root.lookup
Date: Thu, 21 Jul 2016 11:40:05 -0500
Message-ID: <20160721164014.17534-1-ebiederm@xmission.com>
References: <87d1m754jc.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87d1m754jc.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Passing nsproxy into sysctl_table_root.lookup was a premature
optimization in attempt to avoid depending on current.  The
directory /proc/self/sys has not appeared and if and when
it does this code will need to be reviewed closely and reworked
anyway.  So remove the premature optimization.

Acked-by: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/proc/proc_sysctl.c  | 14 +++++++-------
 include/linux/sysctl.h |  3 +--
 net/sysctl_net.c       |  4 ++--
 3 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 5e57c3e46e1d..534630687489 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -72,7 +72,7 @@ static DEFINE_SPINLOCK(sysctl_lock);
 
 static void drop_sysctl_table(struct ctl_table_header *header);
 static int sysctl_follow_link(struct ctl_table_header **phead,
-	struct ctl_table **pentry, struct nsproxy *namespaces);
+	struct ctl_table **pentry);
 static int insert_links(struct ctl_table_header *head);
 static void put_links(struct ctl_table_header *header);
 
@@ -319,11 +319,11 @@ static void sysctl_head_finish(struct ctl_table_header *head)
 }
 
 static struct ctl_table_set *
-lookup_header_set(struct ctl_table_root *root, struct nsproxy *namespaces)
+lookup_header_set(struct ctl_table_root *root)
 {
 	struct ctl_table_set *set = &root->default_set;
 	if (root->lookup)
-		set = root->lookup(root, namespaces);
+		set = root->lookup(root);
 	return set;
 }
 
@@ -491,7 +491,7 @@ static struct dentry *proc_sys_lookup(struct inode *dir, struct dentry *dentry,
 		goto out;
 
 	if (S_ISLNK(p->mode)) {
-		ret = sysctl_follow_link(&h, &p, current->nsproxy);
+		ret = sysctl_follow_link(&h, &p);
 		err = ERR_PTR(ret);
 		if (ret)
 			goto out;
@@ -659,7 +659,7 @@ static bool proc_sys_link_fill_cache(struct file *file,
 
 	if (S_ISLNK(table->mode)) {
 		/* It is not an error if we can not follow the link ignore it */
-		int err = sysctl_follow_link(&head, &table, current->nsproxy);
+		int err = sysctl_follow_link(&head, &table);
 		if (err)
 			goto out;
 	}
@@ -976,7 +976,7 @@ static struct ctl_dir *xlate_dir(struct ctl_table_set *set, struct ctl_dir *dir)
 }
 
 static int sysctl_follow_link(struct ctl_table_header **phead,
-	struct ctl_table **pentry, struct nsproxy *namespaces)
+	struct ctl_table **pentry)
 {
 	struct ctl_table_header *head;
 	struct ctl_table_root *root;
@@ -988,7 +988,7 @@ static int sysctl_follow_link(struct ctl_table_header **phead,
 	ret = 0;
 	spin_lock(&sysctl_lock);
 	root = (*pentry)->data;
-	set = lookup_header_set(root, namespaces);
+	set = lookup_header_set(root);
 	dir = xlate_dir(set, (*phead)->parent);
 	if (IS_ERR(dir))
 		ret = PTR_ERR(dir);
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index fa7bc29925c9..6385b331f2b9 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -154,8 +154,7 @@ struct ctl_table_set {
 
 struct ctl_table_root {
 	struct ctl_table_set default_set;
-	struct ctl_table_set *(*lookup)(struct ctl_table_root *root,
-					   struct nsproxy *namespaces);
+	struct ctl_table_set *(*lookup)(struct ctl_table_root *root);
 	int (*permissions)(struct ctl_table_header *head, struct ctl_table *table);
 };
 
diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index ed98c1fc3de1..2951f229a855 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -27,9 +27,9 @@
 #endif
 
 static struct ctl_table_set *
-net_ctl_header_lookup(struct ctl_table_root *root, struct nsproxy *namespaces)
+net_ctl_header_lookup(struct ctl_table_root *root)
 {
-	return &namespaces->net_ns->sysctls;
+	return &current->nsproxy->net_ns->sysctls;
 }
 
 static int is_seen(struct ctl_table_set *set)
-- 
2.8.3
