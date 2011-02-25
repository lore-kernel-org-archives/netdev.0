From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [PATCH 2/9] sysctl: use ctl_header_cookie in proc_handler
Date: Fri, 25 Feb 2011 20:52:34 +0200
Message-ID: <1298659961-23863-3-git-send-email-lucian.grijincu@gmail.com>
References: <1298659961-23863-1-git-send-email-lucian.grijincu@gmail.com>
Cc: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Octavian Purdila <tavi@cs.pub.ro>, netdev@vger.kernel.org,
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298659961-23863-1-git-send-email-lucian.grijincu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

TODO: if this patch series gets a positive feedback this patch will be
extended with a kernel-wide change of each proc_handler to add a
'cookie' argument.

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 fs/proc/proc_sysctl.c  |   11 ++++++++++-
 include/linux/sysctl.h |    3 +++
 2 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 09a1f92..85b6b75 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -135,6 +135,7 @@ static ssize_t proc_sys_call_handler(struct file *filp, void __user *buf,
 	struct inode *inode = filp->f_path.dentry->d_inode;
 	struct ctl_table_header *head = grab_header(inode);
 	struct ctl_table *table = PROC_I(inode)->sysctl_entry;
+	proc_handler_cookie *phc = (proc_handler_cookie *) table->proc_handler;
 	ssize_t error;
 	size_t res;
 
@@ -156,7 +157,15 @@ static ssize_t proc_sys_call_handler(struct file *filp, void __user *buf,
 
 	/* careful: calling conventions are nasty here */
 	res = count;
-	error = table->proc_handler(table, write, buf, &res, ppos);
+	/*XXX Most handlers only use the first 5 arguments (without
+	 *XXX @cookie). Changing all handlers is too much of work,
+	 *XXX as this is only a RFC patch at the moment.
+	 *XXX
+	 *XXX This is just a HACK for now, I did this this way to not
+	 *XXX waste time changing all the handlers, in the final version
+	 *XXX I'll change all the handlers if there's not other solution.
+	 */
+	error = phc(table, write, buf, &res, ppos, head->ctl_header_cookie);
 	if (!error)
 		error = res;
 out:
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 43fed29..3d21832 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -963,6 +963,9 @@ typedef struct ctl_table ctl_table;
 
 typedef int proc_handler (struct ctl_table *ctl, int write,
 			  void __user *buffer, size_t *lenp, loff_t *ppos);
+typedef int proc_handler_cookie(struct ctl_table *ctl, int write,
+				void __user *buffer, size_t *lenp,
+				loff_t *ppos, void *ctl_header_cookie);
 
 extern int proc_dostring(struct ctl_table *, int,
 			 void __user *, size_t *, loff_t *);
-- 
1.7.4.rc1.7.g2cf08.dirty
