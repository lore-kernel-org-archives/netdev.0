From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 03/17] sysctl: Pass useful parameters to sysctl
	permissions
Date: Fri, 16 Nov 2012 05:02:58 -0800
Message-ID: <1353070992-5552-3-git-send-email-ebiederm@xmission.com>
References: <87d2zd8zwn.fsf@xmission.com>
	<1353070992-5552-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353070992-5552-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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

- Current is implicitly avaiable so passing current->nsproxy isn't useful.
- The ctl_table_header is needed to find how the sysctl table is connected
  to the rest of sysctl.
- ctl_table_root is avaiable in the ctl_table_header so no need to it.

With these changes it becomes possible to write a version of
net_sysctl_permission that takes into account the network namespace of
the sysctl table, an important feature in extending the user namespace.

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/proc/proc_sysctl.c  |    9 +++++----
 include/linux/sysctl.h |    3 +--
 net/sysctl_net.c       |    3 +--
 3 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index a781bdf..701580d 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -378,12 +378,13 @@ static int test_perm(int mode, int op)
 	return -EACCES;
 }
 
-static int sysctl_perm(struct ctl_table_root *root, struct ctl_table *table, int op)
+static int sysctl_perm(struct ctl_table_header *head, struct ctl_table *table, int op)
 {
+	struct ctl_table_root *root = head->root;
 	int mode;
 
 	if (root->permissions)
-		mode = root->permissions(root, current->nsproxy, table);
+		mode = root->permissions(head, table);
 	else
 		mode = table->mode;
 
@@ -491,7 +492,7 @@ static ssize_t proc_sys_call_handler(struct file *filp, void __user *buf,
 	 * and won't be until we finish.
 	 */
 	error = -EPERM;
-	if (sysctl_perm(head->root, table, write ? MAY_WRITE : MAY_READ))
+	if (sysctl_perm(head, table, write ? MAY_WRITE : MAY_READ))
 		goto out;
 
 	/* if that can happen at all, it should be -EINVAL, not -EISDIR */
@@ -717,7 +718,7 @@ static int proc_sys_permission(struct inode *inode, int mask)
 	if (!table) /* global root - r-xr-xr-x */
 		error = mask & MAY_WRITE ? -EACCES : 0;
 	else /* Use the permissions on the sysctl table entry */
-		error = sysctl_perm(head->root, table, mask & ~MAY_NOT_BLOCK);
+		error = sysctl_perm(head, table, mask & ~MAY_NOT_BLOCK);
 
 	sysctl_head_finish(head);
 	return error;
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index cd844a6..14a8ff2 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -158,8 +158,7 @@ struct ctl_table_root {
 	struct ctl_table_set default_set;
 	struct ctl_table_set *(*lookup)(struct ctl_table_root *root,
 					   struct nsproxy *namespaces);
-	int (*permissions)(struct ctl_table_root *root,
-			struct nsproxy *namespaces, struct ctl_table *table);
+	int (*permissions)(struct ctl_table_header *head, struct ctl_table *table);
 };
 
 /* struct ctl_path describes where in the hierarchy a table is added */
diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index e3a6e37..e98f393 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -38,8 +38,7 @@ static int is_seen(struct ctl_table_set *set)
 }
 
 /* Return standard mode bits for table entry. */
-static int net_ctl_permissions(struct ctl_table_root *root,
-			       struct nsproxy *nsproxy,
+static int net_ctl_permissions(struct ctl_table_header *head,
 			       struct ctl_table *table)
 {
 	/* Allow network administrator to have same access as root. */
-- 
1.7.5.4
