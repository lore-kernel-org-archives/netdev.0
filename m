From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 4/4] sysctl: Don't call sysctl_follow_link unless we are a link.
Date: Wed, 01 Feb 2012 19:30:04 -0800
Message-ID: <m1liolvrnn.fsf_-_@fess.ebiederm.org>
References: <m1pqe5ah3z.fsf@fess.ebiederm.org>
	<m139atx6bs.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <linux-fsdevel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>,
	Damien Millescamps <damien.millescamps@6wind.com>,
	Dan Carpenter <dan.carpenter@oracle.com>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m139atx6bs.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Wed, 01 Feb 2012 19:27:51 -0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


There are no functional changes.  Just code motion to make it
clear that we don't follow a link between sysctl roots unless the
directory entry actually is a link.

Suggested-by:  Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/proc/proc_sysctl.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index e5601dc..a7708b7 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -451,10 +451,12 @@ static struct dentry *proc_sys_lookup(struct inode *dir, struct dentry *dentry,
 	if (!p)
 		goto out;
 
-	ret = sysctl_follow_link(&h, &p, current->nsproxy);
-	err = ERR_PTR(ret);
-	if (ret)
-		goto out;
+	if (S_ISLNK(p->mode)) {
+		ret = sysctl_follow_link(&h, &p, current->nsproxy);
+		err = ERR_PTR(ret);
+		if (ret)
+			goto out;
+	}
 
 	err = ERR_PTR(-ENOMEM);
 	inode = proc_sys_make_inode(dir->i_sb, h ? h : head, p);
@@ -601,10 +603,12 @@ static int proc_sys_link_fill_cache(struct file *filp, void *dirent,
 	int err, ret = 0;
 	head = sysctl_head_grab(head);
 
-	/* It is not an error if we can not follow the link ignore it */
-	err = sysctl_follow_link(&head, &table, current->nsproxy);
-	if (err)
-		goto out;
+	if (S_ISLNK(table->mode)) {
+		/* It is not an error if we can not follow the link ignore it */
+		err = sysctl_follow_link(&head, &table, current->nsproxy);
+		if (err)
+			goto out;
+	}
 
 	ret = proc_sys_fill_cache(filp, dirent, filldir, head, table);
 out:
@@ -950,10 +954,6 @@ static int sysctl_follow_link(struct ctl_table_header **phead,
 	struct ctl_dir *dir;
 	int ret;
 
-	/* Get out quickly if not a link */
-	if (!S_ISLNK((*pentry)->mode))
-		return 0;
-
 	ret = 0;
 	spin_lock(&sysctl_lock);
 	root = (*pentry)->data;
-- 
1.7.2.5
