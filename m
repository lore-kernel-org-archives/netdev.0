From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 05/21] userns: Make seq_file's user namespace accessible
Date: Mon, 13 Aug 2012 13:18:19 -0700
Message-ID: <1344889115-21610-5-git-send-email-ebiederm@xmission.com>
References: <87ehnav9n5.fsf@xmission.com>
	<1344889115-21610-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1344889115-21610-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

struct file already has a user namespace associated with it
in file->f_cred->user_ns, unfortunately because struct
seq_file has no struct file backpointer associated with
it, it is difficult to get at the user namespace in seq_file
context.  Therefore add a helper function seq_user_ns to return
the associated user namespace and a user_ns field to struct
seq_file to be used in implementing seq_user_ns.

Cc: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/seq_file.c            |    4 ++++
 include/linux/seq_file.h |   14 ++++++++++++++
 2 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/fs/seq_file.c b/fs/seq_file.c
index 14cf9de..99dffab 100644
--- a/fs/seq_file.c
+++ b/fs/seq_file.c
@@ -9,6 +9,7 @@
 #include <linux/export.h>
 #include <linux/seq_file.h>
 #include <linux/slab.h>
+#include <linux/cred.h>
 
 #include <asm/uaccess.h>
 #include <asm/page.h>
@@ -56,6 +57,9 @@ int seq_open(struct file *file, const struct seq_operations *op)
 	memset(p, 0, sizeof(*p));
 	mutex_init(&p->lock);
 	p->op = op;
+#ifdef CONFIG_USER_NS
+	p->user_ns = file->f_cred->user_ns;
+#endif
 
 	/*
 	 * Wrappers around seq_open(e.g. swaps_open) need to be
diff --git a/include/linux/seq_file.h b/include/linux/seq_file.h
index 83c44ee..68a04a3 100644
--- a/include/linux/seq_file.h
+++ b/include/linux/seq_file.h
@@ -13,6 +13,7 @@ struct file;
 struct path;
 struct inode;
 struct dentry;
+struct user_namespace;
 
 struct seq_file {
 	char *buf;
@@ -25,6 +26,9 @@ struct seq_file {
 	struct mutex lock;
 	const struct seq_operations *op;
 	int poll_event;
+#ifdef CONFIG_USER_NS
+	struct user_namespace *user_ns;
+#endif
 	void *private;
 };
 
@@ -128,6 +132,16 @@ int seq_put_decimal_ull(struct seq_file *m, char delimiter,
 int seq_put_decimal_ll(struct seq_file *m, char delimiter,
 			long long num);
 
+static inline struct user_namespace *seq_user_ns(struct seq_file *seq)
+{
+#ifdef CONFIG_USER_NS
+	return seq->user_ns;
+#else
+	extern struct user_namespace init_user_ns;
+	return &init_user_ns;
+#endif
+}
+
 #define SEQ_START_TOKEN ((void *)1)
 /*
  * Helpers for iteration over list_head-s in seq_files
-- 
1.7.5.4
