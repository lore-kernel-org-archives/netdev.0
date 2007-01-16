From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 57/59] sysctl: allow sysctl_perm to be called from outside of sysctl.c
Date: Tue, 16 Jan 2007 09:40:02 -0700
Message-ID: <11689657031417-git-send-email-ebiederm@xmission.com>
References: <m1ac0jc4no.fsf@ebiederm.dsl.xmission.com>
Cc: <linux-kernel@vger.kernel.org>, <containers@lists.osdl.org>,
	<netdev@vger.kernel.org>, xfs-masters@oss.sgi.com, xfs@oss.sgi.com,
	linux-scsi@vger.kernel.org, James.Bottomley@SteelEye.com,
	minyard@acm.org, openipmi-developer@lists.sourceforge.net,
	<tony.luck@intel.com>, linux-mips@linux-mips.org,
	ralf@linux-mips.org, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, linux390@de.ibm.com,
	linux-390@vm.marist.edu, paulus@samba.org, linuxppc-dev@ozlabs.org,
	lethal@linux-sh.org, linuxsh-shmedia-dev@lists.sourceforge.net,
	<ak@suse.de>, vojtech@suse.cz, clemens@ladisch.de,
	a.zummo@towertech.it, rtc-linux@googlegroups.com,
	linux-parport@lists.infradead.org, andrea@suse.de,
	tim@cyberelk.net, philb@gnu.org, aharkes@cs.cmu.edu,
	coda@cs.cmu.edu, codalist@TELEMANN.coda.cs.cmu.edu,
	aia21@cantab.net, linux-ntfs-dev@lists.sourceforge.net,
	mark.fasheh@oracle.com, kurt.hackel@oracle.com,
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751743AbXAPQxL@vger.kernel.org>
To: "<Andrew Morton" <akpm@osdl.org>
In-Reply-To: <m1ac0jc4no.fsf@ebiederm.dsl.xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric W. Biederman <ebiederm@xmission.com> - unquoted

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/sysctl.h |    2 ++
 kernel/sysctl.c        |   10 +++++-----
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 81ee9ea..20c23b5 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -924,8 +924,10 @@ enum
 #include <linux/list.h>
 
 /* For the /proc/sys support */
+struct ctl_table;
 extern struct ctl_table_header *sysctl_head_next(struct ctl_table_header *prev);
 extern void sysctl_head_finish(struct ctl_table_header *prev);
+extern int sysctl_perm(struct ctl_table *table, int op);
 
 extern void sysctl_init(void);
 
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index ca2831a..ec5e4a1 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1154,7 +1154,7 @@ asmlinkage long sys_sysctl(struct __sysctl_args __user *args)
 #endif /* CONFIG_SYSCTL_SYSCALL */
 
 /*
- * ctl_perm does NOT grant the superuser all rights automatically, because
+ * sysctl_perm does NOT grant the superuser all rights automatically, because
  * some sysctl variables are readonly even to root.
  */
 
@@ -1169,7 +1169,7 @@ static int test_perm(int mode, int op)
 	return -EACCES;
 }
 
-static inline int ctl_perm(ctl_table *table, int op)
+int sysctl_perm(ctl_table *table, int op)
 {
 	int error;
 	error = security_sysctl(table, op);
@@ -1196,7 +1196,7 @@ repeat:
 		if (n == table->ctl_name) {
 			int error;
 			if (table->child) {
-				if (ctl_perm(table, 001))
+				if (sysctl_perm(table, 001))
 					return -EPERM;
 				name++;
 				nlen--;
@@ -1225,7 +1225,7 @@ int do_sysctl_strategy (ctl_table *table,
 		op |= 004;
 	if (newval) 
 		op |= 002;
-	if (ctl_perm(table, op))
+	if (sysctl_perm(table, op))
 		return -EPERM;
 
 	if (table->strategy) {
@@ -1495,7 +1495,7 @@ static ssize_t do_rw_proc(int write, struct file * file, char __user * buf,
 			goto out;
 		error = -EPERM;
 		op = (write ? 002 : 004);
-		if (ctl_perm(table, op))
+		if (sysctl_perm(table, op))
 			goto out;
 		
 		/* careful: calling conventions are nasty here */
-- 
1.4.4.1.g278f
