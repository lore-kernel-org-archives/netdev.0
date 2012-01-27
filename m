From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 03/29] sysctl: Register the base sysctl table like any other sysctl table.
Date: Thu, 26 Jan 2012 20:51:39 -0800
Message-ID: <1327639925-12920-3-git-send-email-ebiederm@xmission.com>
References: <m1pqe5ah3z.fsf@fess.ebiederm.org>
Cc: <linux-fsdevel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>,
	Damien Millescamps <damien.millescamps@6wind.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <m1pqe5ah3z.fsf@fess.ebiederm.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simplify the code by treating the base sysctl table like any other
sysctl table and register it with register_sysctl_table.

To ensure this table is registered early enough to avoid problems
call sysctl_init from proc_sys_init.

Rename sysctl_net.c:sysctl_init() to net_sysctl_init() to avoid
name conflicts now that kernel/sysctl.c:sysctl_init() is no longer
static.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/proc/proc_sysctl.c  |    3 ++-
 include/linux/sysctl.h |    1 +
 kernel/sysctl.c        |   13 ++++---------
 net/sysctl_net.c       |    4 ++--
 4 files changed, 9 insertions(+), 12 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index d82f4a8..9d29d28 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -468,5 +468,6 @@ int __init proc_sys_init(void)
 	proc_sys_root->proc_iops = &proc_sys_dir_operations;
 	proc_sys_root->proc_fops = &proc_sys_dir_file_operations;
 	proc_sys_root->nlink = 0;
-	return 0;
+
+	return sysctl_init();
 }
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index cf3ee7f..5e3532e 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -1095,6 +1095,7 @@ struct ctl_table_header *register_sysctl_paths(const struct ctl_path *path,
 void unregister_sysctl_table(struct ctl_table_header * table);
 int sysctl_check_table(struct nsproxy *namespaces, struct ctl_table *table);
 
+extern int sysctl_init(void);
 #else /* CONFIG_SYSCTL */
 static inline struct ctl_table_header *register_sysctl_table(struct ctl_table * table)
 {
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index d5bbddd..ad46024 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -192,7 +192,7 @@ static int sysrq_sysctl_handler(ctl_table *table, int write,
 
 #endif
 
-static struct ctl_table root_table[];
+static struct ctl_table root_table[1];
 static struct ctl_table_root sysctl_table_root;
 static struct ctl_table_header root_table_header = {
 	{{.count = 1,
@@ -222,7 +222,7 @@ int sysctl_legacy_va_layout;
 
 /* The default sysctl tables: */
 
-static struct ctl_table root_table[] = {
+static struct ctl_table sysctl_base_table[] = {
 	{
 		.procname	= "kernel",
 		.mode		= 0555,
@@ -1747,17 +1747,12 @@ static void sysctl_set_parent(struct ctl_table *parent, struct ctl_table *table)
 	}
 }
 
-static __init int sysctl_init(void)
+int __init sysctl_init(void)
 {
-	sysctl_set_parent(NULL, root_table);
-#ifdef CONFIG_SYSCTL_SYSCALL_CHECK
-	sysctl_check_table(current->nsproxy, root_table);
-#endif
+	register_sysctl_table(sysctl_base_table);
 	return 0;
 }
 
-core_initcall(sysctl_init);
-
 static struct ctl_table *is_branch_in(struct ctl_table *branch,
 				      struct ctl_table *table)
 {
diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index e758139..a6bbee2 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -90,7 +90,7 @@ static struct pernet_operations sysctl_pernet_ops = {
 	.exit = sysctl_net_exit,
 };
 
-static __init int sysctl_init(void)
+static __init int net_sysctl_init(void)
 {
 	int ret;
 	ret = register_pernet_subsys(&sysctl_pernet_ops);
@@ -102,7 +102,7 @@ static __init int sysctl_init(void)
 out:
 	return ret;
 }
-subsys_initcall(sysctl_init);
+subsys_initcall(net_sysctl_init);
 
 struct ctl_table_header *register_net_sysctl_table(struct net *net,
 	const struct ctl_path *path, struct ctl_table *table)
-- 
1.7.2.5

