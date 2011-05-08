From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 057/115] sysctl: no-child: manually register kernel/keys
Date: Mon,  9 May 2011 00:39:09 +0200
Message-ID: <1304894407-32201-58-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49055 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932489Ab1EHWle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:41:34 -0400
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 include/linux/key.h    |    4 +++-
 kernel/sysctl.c        |    7 -------
 security/keys/key.c    |    1 +
 security/keys/sysctl.c |   18 +++++++++++++++++-
 4 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/include/linux/key.h b/include/linux/key.h
index b2bb017..9b3df18 100644
--- a/include/linux/key.h
+++ b/include/linux/key.h
@@ -281,7 +281,9 @@ static inline key_serial_t key_serial(struct key *key)
 				   rwsem_is_locked(&((struct key *)(KEY))->sem)))
 
 #ifdef CONFIG_SYSCTL
-extern ctl_table key_sysctls[];
+extern int __init key_register_sysctls(void);
+#else
+static int __init key_register_sysctls(void) { return 0; }
 #endif
 
 extern void key_replace_session_keyring(void);
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index b020156..33d5e2e 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -905,13 +905,6 @@ static struct ctl_table kern_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dostring,
 	},
-#ifdef CONFIG_KEYS
-	{
-		.procname	= "keys",
-		.mode		= 0555,
-		.child		= key_sysctls,
-	},
-#endif
 #ifdef CONFIG_RCU_TORTURE_TEST
 	{
 		.procname       = "rcutorture_runnable",
diff --git a/security/keys/key.c b/security/keys/key.c
index f7f9d93..33903c2 100644
--- a/security/keys/key.c
+++ b/security/keys/key.c
@@ -1099,6 +1099,7 @@ EXPORT_SYMBOL(unregister_key_type);
  */
 void __init key_init(void)
 {
+	key_register_sysctls();
 	/* allocate a slab in which we can store keys */
 	key_jar = kmem_cache_create("key_jar", sizeof(struct key),
 			0, SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
diff --git a/security/keys/sysctl.c b/security/keys/sysctl.c
index ee32d18..e079223 100644
--- a/security/keys/sysctl.c
+++ b/security/keys/sysctl.c
@@ -15,7 +15,7 @@
 
 static const int zero, one = 1, max = INT_MAX;
 
-ctl_table key_sysctls[] = {
+static struct ctl_table key_table[] = {
 	{
 		.procname = "maxkeys",
 		.data = &key_quota_maxkeys,
@@ -63,3 +63,19 @@ ctl_table key_sysctls[] = {
 	},
 	{ }
 };
+
+static const __initdata struct ctl_path key_path[] = {
+	{ .procname = "kernel" },
+	{ .procname = "keys" },
+	{ }
+};
+
+static struct ctl_table_header *key_header;
+
+int __init key_register_sysctls(void)
+{
+	key_header = register_sysctl_paths(key_path, key_table);
+	if (key_header == NULL)
+		return -ENOMEM;
+	return 0;
+}
-- 
1.7.5.134.g1c08b

