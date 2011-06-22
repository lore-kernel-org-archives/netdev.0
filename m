From: Amerigo Wang <amwang@redhat.com>
Subject: [PATCH 3/5] sys: move reboot notifiers into reboot.h
Date: Wed, 22 Jun 2011 14:35:20 +0800
Message-ID: <1308724522-32461-4-git-send-email-amwang@redhat.com>
References: <1308724522-32461-1-git-send-email-amwang@redhat.com>
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	Amerigo Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Josh Triplett <josh@joshtriplett.org>,
	Jiri Slaby <jslaby@suse.cz>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	David Howells <dhowells@redhat.com>,
	James Morris <jmorris@namei.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1308724522-32461-1-git-send-email-amwang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is not necessary to share the same notifier.h.
This patch already moves register_reboot_notifier()
and unregister_reboot_notifier() from kernel/notifier.c to
kernel/sys.c.

Signed-off-by: WANG Cong <amwang@redhat.com>

---
 include/linux/notifier.h |    5 +----
 include/linux/reboot.h   |    5 +++++
 kernel/notifier.c        |   31 -------------------------------
 kernel/sys.c             |   32 +++++++++++++++++++++++++++++++-
 4 files changed, 37 insertions(+), 36 deletions(-)

diff --git a/include/linux/notifier.h b/include/linux/notifier.h
index e8a858a..145c436 100644
--- a/include/linux/notifier.h
+++ b/include/linux/notifier.h
@@ -189,10 +189,7 @@ static inline int notifier_to_errno(int ret)
 
 /* netdevice notifiers are defined in include/linux/netdevice.h */
 
-#define SYS_DOWN	0x0001	/* Notify of system down */
-#define SYS_RESTART	SYS_DOWN
-#define SYS_HALT	0x0002	/* Notify of system halt */
-#define SYS_POWER_OFF	0x0003	/* Notify of system power off */
+/* reboot notifiers are defined in include/linux/reboot.h. */
 
 #define NETLINK_URELEASE	0x0001	/* Unicast netlink socket released */
 
diff --git a/include/linux/reboot.h b/include/linux/reboot.h
index 3005d5a..e0879a7 100644
--- a/include/linux/reboot.h
+++ b/include/linux/reboot.h
@@ -39,6 +39,11 @@
 
 #include <linux/notifier.h>
 
+#define SYS_DOWN	0x0001	/* Notify of system down */
+#define SYS_RESTART	SYS_DOWN
+#define SYS_HALT	0x0002	/* Notify of system halt */
+#define SYS_POWER_OFF	0x0003	/* Notify of system power off */
+
 extern int register_reboot_notifier(struct notifier_block *);
 extern int unregister_reboot_notifier(struct notifier_block *);
 
diff --git a/kernel/notifier.c b/kernel/notifier.c
index 2488ba7..8d7b435 100644
--- a/kernel/notifier.c
+++ b/kernel/notifier.c
@@ -525,37 +525,6 @@ void srcu_init_notifier_head(struct srcu_notifier_head *nh)
 }
 EXPORT_SYMBOL_GPL(srcu_init_notifier_head);
 
-/**
- *	register_reboot_notifier - Register function to be called at reboot time
- *	@nb: Info about notifier function to be called
- *
- *	Registers a function with the list of functions
- *	to be called at reboot time.
- *
- *	Currently always returns zero, as blocking_notifier_chain_register()
- *	always returns zero.
- */
-int register_reboot_notifier(struct notifier_block *nb)
-{
-	return blocking_notifier_chain_register(&reboot_notifier_list, nb);
-}
-EXPORT_SYMBOL(register_reboot_notifier);
-
-/**
- *	unregister_reboot_notifier - Unregister previously registered reboot notifier
- *	@nb: Hook to be unregistered
- *
- *	Unregisters a previously registered reboot
- *	notifier function.
- *
- *	Returns zero on success, or %-ENOENT on failure.
- */
-int unregister_reboot_notifier(struct notifier_block *nb)
-{
-	return blocking_notifier_chain_unregister(&reboot_notifier_list, nb);
-}
-EXPORT_SYMBOL(unregister_reboot_notifier);
-
 static ATOMIC_NOTIFIER_HEAD(die_chain);
 
 int notrace __kprobes notify_die(enum die_val val, const char *str,
diff --git a/kernel/sys.c b/kernel/sys.c
index e4128b2..a101ba3 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -8,7 +8,6 @@
 #include <linux/mm.h>
 #include <linux/utsname.h>
 #include <linux/mman.h>
-#include <linux/notifier.h>
 #include <linux/reboot.h>
 #include <linux/prctl.h>
 #include <linux/highuid.h>
@@ -320,6 +319,37 @@ void kernel_restart_prepare(char *cmd)
 }
 
 /**
+ *	register_reboot_notifier - Register function to be called at reboot time
+ *	@nb: Info about notifier function to be called
+ *
+ *	Registers a function with the list of functions
+ *	to be called at reboot time.
+ *
+ *	Currently always returns zero, as blocking_notifier_chain_register()
+ *	always returns zero.
+ */
+int register_reboot_notifier(struct notifier_block *nb)
+{
+	return blocking_notifier_chain_register(&reboot_notifier_list, nb);
+}
+EXPORT_SYMBOL(register_reboot_notifier);
+
+/**
+ *	unregister_reboot_notifier - Unregister previously registered reboot notifier
+ *	@nb: Hook to be unregistered
+ *
+ *	Unregisters a previously registered reboot
+ *	notifier function.
+ *
+ *	Returns zero on success, or %-ENOENT on failure.
+ */
+int unregister_reboot_notifier(struct notifier_block *nb)
+{
+	return blocking_notifier_chain_unregister(&reboot_notifier_list, nb);
+}
+EXPORT_SYMBOL(unregister_reboot_notifier);
+
+/**
  *	kernel_restart - reboot the system
  *	@cmd: pointer to buffer containing command to execute for restart
  *		or %NULL
-- 
1.7.4.4
