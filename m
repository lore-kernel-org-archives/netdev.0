From: Wangyufen <wangyufen@huawei.com>
Subject: [PATCH v2 3/8] Add file_ns_capable() helper function for open-time capability checking
Date: Fri, 25 Jul 2014 16:22:24 +0800
Message-ID: <1406276549-6616-4-git-send-email-wangyufen@huawei.com>
References: <1406276549-6616-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Wang Yufen <wangyufen@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:35750 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759918AbaGYIYg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 04:24:36 -0400
In-Reply-To: <1406276549-6616-1-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>

Nothing is using it yet, but this will allow us to delay the open-time
checks to use time, without breaking the normal UNIX permission
semantics where permissions are determined by the opener (and the file
descriptor can then be passed to a different process, or the process can
drop capabilities).

Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Wang Yufen <wangyufen@huawei.com>
---
 include/linux/capability.h |  3 ++-
 kernel/capability.c        | 24 ++++++++++++++++++++++++
 2 files changed, 26 insertions(+), 1 deletion(-)

diff --git a/include/linux/capability.h b/include/linux/capability.h
index 12d52de..7273027 100644
--- a/include/linux/capability.h
+++ b/include/linux/capability.h
@@ -373,7 +373,7 @@ struct cpu_vfs_cap_data {
 #define CAP_TO_MASK(x)      (1 << ((x) & 31)) /* mask for indexed __u32 */
 
 #ifdef __KERNEL__
-
+struct file;
 struct dentry;
 struct user_namespace;
 
@@ -548,6 +548,7 @@ extern bool has_ns_capability_noaudit(struct task_struct *t,
 extern bool capable(int cap);
 extern bool ns_capable(struct user_namespace *ns, int cap);
 extern bool nsown_capable(int cap);
+extern bool file_ns_capable(const struct file *file, struct user_namespace *ns, int cap);
 
 /* audit system wants to get cap info from files as well */
 extern int get_vfs_caps_from_disk(const struct dentry *dentry, struct cpu_vfs_cap_data *cpu_caps);
diff --git a/kernel/capability.c b/kernel/capability.c
index 3f1adb6..cc8c4845 100644
--- a/kernel/capability.c
+++ b/kernel/capability.c
@@ -393,6 +393,30 @@ bool ns_capable(struct user_namespace *ns, int cap)
 EXPORT_SYMBOL(ns_capable);
 
 /**
+ * file_ns_capable - Determine if the file's opener had a capability in effect
+ * @file:  The file we want to check
+ * @ns:  The usernamespace we want the capability in
+ * @cap: The capability to be tested for
+ *
+ * Return true if task that opened the file had a capability in effect
+ * when the file was opened.
+ *
+ * This does not set PF_SUPERPRIV because the caller may not
+ * actually be privileged.
+ */
+bool file_ns_capable(const struct file *file, struct user_namespace *ns, int cap)
+{
+	if (WARN_ON_ONCE(!cap_valid(cap)))
+		return false;
+
+	if (security_capable(file->f_cred, ns, cap) == 0)
+		return true;
+
+	return false;
+}
+EXPORT_SYMBOL(file_ns_capable);
+
+/**
  * capable - Determine if the current task has a superior capability in effect
  * @cap: The capability to be tested for
  *
-- 
1.8.0
