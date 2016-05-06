From: Tyler Hicks <tyhicks@canonical.com>
Subject: [PATCH 1/2] kernel: Add noaudit variant of ns_capable()
Date: Fri,  6 May 2016 18:04:13 -0500
Message-ID: <1462575854-4301-2-git-send-email-tyhicks@canonical.com>
References: <1462575854-4301-1-git-send-email-tyhicks@canonical.com>
Cc: Serge Hallyn <serge.hallyn@canonical.com>,
	"David S . Miller" <davem@davemloft.net>
To: linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1462575854-4301-1-git-send-email-tyhicks@canonical.com>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

When checking the current cred for a capability in a specific user
namespace, it isn't always desirable to have the LSMs audit the check.
This patch adds a noaudit variant of ns_capable() for when those
situations arise.

The common logic between ns_capable() and the new ns_capable_noaudit()
is moved into a single, shared function to keep duplicated code to a
minimum and ease maintainability.

Signed-off-by: Tyler Hicks <tyhicks@canonical.com>
---
 include/linux/capability.h |  5 +++++
 kernel/capability.c        | 46 ++++++++++++++++++++++++++++++++++++----------
 2 files changed, 41 insertions(+), 10 deletions(-)

diff --git a/include/linux/capability.h b/include/linux/capability.h
index 00690ff..5f3c63d 100644
--- a/include/linux/capability.h
+++ b/include/linux/capability.h
@@ -206,6 +206,7 @@ extern bool has_ns_capability_noaudit(struct task_struct *t,
 				      struct user_namespace *ns, int cap);
 extern bool capable(int cap);
 extern bool ns_capable(struct user_namespace *ns, int cap);
+extern bool ns_capable_noaudit(struct user_namespace *ns, int cap);
 #else
 static inline bool has_capability(struct task_struct *t, int cap)
 {
@@ -233,6 +234,10 @@ static inline bool ns_capable(struct user_namespace *ns, int cap)
 {
 	return true;
 }
+static inline bool ns_capable_noaudit(struct user_namespace *ns, int cap)
+{
+	return true;
+}
 #endif /* CONFIG_MULTIUSER */
 extern bool capable_wrt_inode_uidgid(const struct inode *inode, int cap);
 extern bool file_ns_capable(const struct file *file, struct user_namespace *ns, int cap);
diff --git a/kernel/capability.c b/kernel/capability.c
index 45432b5..00411c8 100644
--- a/kernel/capability.c
+++ b/kernel/capability.c
@@ -361,6 +361,24 @@ bool has_capability_noaudit(struct task_struct *t, int cap)
 	return has_ns_capability_noaudit(t, &init_user_ns, cap);
 }
 
+static bool ns_capable_common(struct user_namespace *ns, int cap, bool audit)
+{
+	int capable;
+
+	if (unlikely(!cap_valid(cap))) {
+		pr_crit("capable() called with invalid cap=%u\n", cap);
+		BUG();
+	}
+
+	capable = audit ? security_capable(current_cred(), ns, cap) :
+			  security_capable_noaudit(current_cred(), ns, cap);
+	if (capable == 0) {
+		current->flags |= PF_SUPERPRIV;
+		return true;
+	}
+	return false;
+}
+
 /**
  * ns_capable - Determine if the current task has a superior capability in effect
  * @ns:  The usernamespace we want the capability in
@@ -374,19 +392,27 @@ bool has_capability_noaudit(struct task_struct *t, int cap)
  */
 bool ns_capable(struct user_namespace *ns, int cap)
 {
-	if (unlikely(!cap_valid(cap))) {
-		pr_crit("capable() called with invalid cap=%u\n", cap);
-		BUG();
-	}
-
-	if (security_capable(current_cred(), ns, cap) == 0) {
-		current->flags |= PF_SUPERPRIV;
-		return true;
-	}
-	return false;
+	return ns_capable_common(ns, cap, true);
 }
 EXPORT_SYMBOL(ns_capable);
 
+/**
+ * ns_capable_noaudit - Determine if the current task has a superior capability
+ * (unaudited) in effect
+ * @ns:  The usernamespace we want the capability in
+ * @cap: The capability to be tested for
+ *
+ * Return true if the current task has the given superior capability currently
+ * available for use, false if not.
+ *
+ * This sets PF_SUPERPRIV on the task if the capability is available on the
+ * assumption that it's about to be used.
+ */
+bool ns_capable_noaudit(struct user_namespace *ns, int cap)
+{
+	return ns_capable_common(ns, cap, false);
+}
+EXPORT_SYMBOL(ns_capable_noaudit);
 
 /**
  * capable - Determine if the current task has a superior capability in effect
-- 
2.7.4

