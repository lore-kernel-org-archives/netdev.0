From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [PATCH] proc_sysctl: use rcu_dereference before accessing proc_inode->sysctl->* members
Date: Fri, 15 Apr 2011 17:52:16 +0200
Message-ID: <1302882736-30157-1-git-send-email-lucian.grijincu@gmail.com>
Cc: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Nick Piggin <npiggin@kernel.dk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:53729 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751289Ab1DOPwd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 11:52:33 -0400
Received: by wwa36 with SMTP id 36so3375890wwa.1
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2011 08:52:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rcu_dereference/rcu_assign_pointer were added to protect some accesses
to ->sysctl in:

    commit dfef6dcd35cb4a251f6322ca9b2c06f0bb1aa1f4
    Author: Al Viro <viro@zeniv.linux.org.uk>
    Date:   Tue Mar 8 01:25:28 2011 -0500

      unfuck proc_sysctl ->d_compare()

This patch puts rcu_dereference where it's missing.

I'm not sure that this patch is needed. I may have misunderstood
Documentation/RCU/checklist.txt

Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Nick Piggin <npiggin@kernel.dk>
Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 fs/proc/proc_sysctl.c   |    9 +++++----
 include/linux/proc_fs.h |    2 +-
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index f50133c..0f5a063 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -70,8 +70,9 @@ static struct ctl_table *find_in_table(struct ctl_table *p, struct qstr *name)
 
 static struct ctl_table_header *grab_header(struct inode *inode)
 {
-	if (PROC_I(inode)->sysctl)
-		return sysctl_head_grab(PROC_I(inode)->sysctl);
+	struct ctl_table_header *head = rcu_dereference(PROC_I(inode)->sysctl);
+	if (head)
+		return sysctl_head_grab(head);
 	else
 		return sysctl_head_next(NULL);
 }
@@ -394,12 +395,12 @@ static int proc_sys_revalidate(struct dentry *dentry, struct nameidata *nd)
 {
 	if (nd->flags & LOOKUP_RCU)
 		return -ECHILD;
-	return !PROC_I(dentry->d_inode)->sysctl->unregistering;
+	return !rcu_dereference(PROC_I(dentry->d_inode)->sysctl)->unregistering;
 }
 
 static int proc_sys_delete(const struct dentry *dentry)
 {
-	return !!PROC_I(dentry->d_inode)->sysctl->unregistering;
+	return !!rcu_dereference(PROC_I(dentry->d_inode)->sysctl)->unregistering;
 }
 
 static int proc_sys_compare(const struct dentry *parent,
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 838c114..a38cb74 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -266,7 +266,7 @@ struct proc_inode {
 	int fd;
 	union proc_op op;
 	struct proc_dir_entry *pde;
-	struct ctl_table_header *sysctl;
+	struct ctl_table_header *__rcu sysctl;
 	struct ctl_table *sysctl_entry;
 	struct inode vfs_inode;
 };
-- 
1.7.5.rc0

