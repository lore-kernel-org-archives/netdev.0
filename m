From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 059/115] sysctl: no-child: manually register fs/epoll
Date: Mon,  9 May 2011 00:39:11 +0200
Message-ID: <1304894407-32201-60-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 fs/eventpoll.c       |   22 +++++++++++++++++++---
 include/linux/poll.h |    2 --
 kernel/sysctl.c      |   10 ----------
 3 files changed, 19 insertions(+), 15 deletions(-)

diff --git a/fs/eventpoll.c b/fs/eventpoll.c
index f9cfd16..2dbcd0c 100644
--- a/fs/eventpoll.c
+++ b/fs/eventpoll.c
@@ -246,14 +246,14 @@ static struct kmem_cache *epi_cache __read_mostly;
 /* Slab cache used to allocate "struct eppoll_entry" */
 static struct kmem_cache *pwq_cache __read_mostly;
 
-#ifdef CONFIG_SYSCTL
+#if defined(CONFIG_SYSCTL) && defined (CONFIG_MMU)
 
 #include <linux/sysctl.h>
 
 static long zero;
 static long long_max = LONG_MAX;
 
-ctl_table epoll_table[] = {
+static struct ctl_table epoll_table[] = {
 	{
 		.procname	= "max_user_watches",
 		.data		= &max_user_watches,
@@ -265,7 +265,22 @@ ctl_table epoll_table[] = {
 	},
 	{ }
 };
-#endif /* CONFIG_SYSCTL */
+static const __initdata struct ctl_path epoll_path[] = {
+	{ .procname = "fs" },
+	{ .procname = "epoll" },
+	{ }
+};
+static struct ctl_table_header *epoll_header;
+static int __init register_epoll_sysctls(void)
+{
+	epoll_header = register_sysctl_paths(epoll_path, epoll_table);
+	if (epoll_header == NULL)
+		return -ENOMEM;
+	return 0;
+}
+#else  /* CONFIG_SYSCTL && CONFIG_MMU */
+static int __init register_epoll_sysctls(void) { return 0; }
+#endif /* CONFIG_SYSCTL && CONFIG_MMU */
 
 
 /* Setup the structure that is used as key for the RB tree */
@@ -1586,6 +1601,7 @@ static int __init eventpoll_init(void)
 	pwq_cache = kmem_cache_create("eventpoll_pwq",
 			sizeof(struct eppoll_entry), 0, SLAB_PANIC, NULL);
 
+	register_epoll_sysctls();
 	return 0;
 }
 fs_initcall(eventpoll_init);
diff --git a/include/linux/poll.h b/include/linux/poll.h
index cf40010..314331c 100644
--- a/include/linux/poll.h
+++ b/include/linux/poll.h
@@ -10,10 +10,8 @@
 #include <linux/wait.h>
 #include <linux/string.h>
 #include <linux/fs.h>
-#include <linux/sysctl.h>
 #include <asm/uaccess.h>
 
-extern struct ctl_table epoll_table[]; /* for sysctl */
 /* ~832 bytes of stack space used max in sys_select/sys_poll before allocating
    additional memory. */
 #define MAX_STACK_ALLOC 832
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 9520e2b..1797c01 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -216,9 +216,6 @@ static struct ctl_table vm_table[];
 static struct ctl_table fs_table[];
 static struct ctl_table debug_table[];
 static struct ctl_table dev_table[];
-#ifdef CONFIG_EPOLL
-extern struct ctl_table epoll_table[];
-#endif
 
 #ifdef HAVE_ARCH_PICK_MMAP_LAYOUT
 int sysctl_legacy_va_layout;
@@ -1439,13 +1436,6 @@ static struct ctl_table fs_table[] = {
 		.proc_handler	= proc_doulongvec_minmax,
 	},
 #endif /* CONFIG_AIO */
-#ifdef CONFIG_EPOLL
-	{
-		.procname	= "epoll",
-		.mode		= 0555,
-		.child		= epoll_table,
-	},
-#endif
 #endif
 	{
 		.procname	= "suid_dumpable",
-- 
1.7.5.134.g1c08b
