From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 2/5][SYSCTL]: Clean sysctls from unneeded extern
 and forward declarations.
Date: Tue, 19 Feb 2008 14:58:31 +0300
Message-ID: <47BAC467.9020405@openvz.org>
References: <47BAC38F.10100@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:45388 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751267AbYBSL6k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2008 06:58:40 -0500
In-Reply-To: <47BAC38F.10100@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The do_sysctl_strategy can be static since it's used in 
kernel/sysctl.c only.

Besides, move it and parse_table above their callers and 
drop the forward declarations.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 include/linux/sysctl.h |    5 --
 kernel/sysctl.c        |  144 +++++++++++++++++++++++-------------------------
 2 files changed, 68 insertions(+), 81 deletions(-)

diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 571f01d..8e50196 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -981,11 +981,6 @@ extern int do_sysctl (int __user *name, int nlen,
 		      void __user *oldval, size_t __user *oldlenp,
 		      void __user *newval, size_t newlen);
 
-extern int do_sysctl_strategy (struct ctl_table *table,
-			       int __user *name, int nlen,
-			       void __user *oldval, size_t __user *oldlenp,
-			       void __user *newval, size_t newlen);
-
 extern ctl_handler sysctl_data;
 extern ctl_handler sysctl_string;
 extern ctl_handler sysctl_intvec;
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 740e144..c224cc5 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -145,12 +145,6 @@ extern int no_unaligned_warning;
 extern int max_lock_depth;
 #endif
 
-#ifdef CONFIG_SYSCTL_SYSCALL
-static int parse_table(int __user *, int, void __user *, size_t __user *,
-		void __user *, size_t, struct ctl_table *);
-#endif
-
-
 #ifdef CONFIG_PROC_SYSCTL
 static int proc_do_cad_pid(struct ctl_table *table, int write, struct file *filp,
 		  void __user *buffer, size_t *lenp, loff_t *ppos);
@@ -1459,6 +1453,74 @@ void register_sysctl_root(struct ctl_table_root *root)
 }
 
 #ifdef CONFIG_SYSCTL_SYSCALL
+/* Perform the actual read/write of a sysctl table entry. */
+static int do_sysctl_strategy (struct ctl_table *table,
+			int __user *name, int nlen,
+			void __user *oldval, size_t __user *oldlenp,
+			void __user *newval, size_t newlen)
+{
+	int op = 0, rc;
+
+	if (oldval)
+		op |= 004;
+	if (newval) 
+		op |= 002;
+	if (sysctl_perm(table, op))
+		return -EPERM;
+
+	if (table->strategy) {
+		rc = table->strategy(table, name, nlen, oldval, oldlenp,
+				     newval, newlen);
+		if (rc < 0)
+			return rc;
+		if (rc > 0)
+			return 0;
+	}
+
+	/* If there is no strategy routine, or if the strategy returns
+	 * zero, proceed with automatic r/w */
+	if (table->data && table->maxlen) {
+		rc = sysctl_data(table, name, nlen, oldval, oldlenp,
+				 newval, newlen);
+		if (rc < 0)
+			return rc;
+	}
+	return 0;
+}
+
+static int parse_table(int __user *name, int nlen,
+		       void __user *oldval, size_t __user *oldlenp,
+		       void __user *newval, size_t newlen,
+		       struct ctl_table *table)
+{
+	int n;
+repeat:
+	if (!nlen)
+		return -ENOTDIR;
+	if (get_user(n, name))
+		return -EFAULT;
+	for ( ; table->ctl_name || table->procname; table++) {
+		if (!table->ctl_name)
+			continue;
+		if (n == table->ctl_name) {
+			int error;
+			if (table->child) {
+				if (sysctl_perm(table, 001))
+					return -EPERM;
+				name++;
+				nlen--;
+				table = table->child;
+				goto repeat;
+			}
+			error = do_sysctl_strategy(table, name, nlen,
+						   oldval, oldlenp,
+						   newval, newlen);
+			return error;
+		}
+	}
+	return -ENOTDIR;
+}
+
 int do_sysctl(int __user *name, int nlen, void __user *oldval, size_t __user *oldlenp,
 	       void __user *newval, size_t newlen)
 {
@@ -1531,76 +1593,6 @@ int sysctl_perm(struct ctl_table *table, int op)
 	return test_perm(table->mode, op);
 }
 
-#ifdef CONFIG_SYSCTL_SYSCALL
-static int parse_table(int __user *name, int nlen,
-		       void __user *oldval, size_t __user *oldlenp,
-		       void __user *newval, size_t newlen,
-		       struct ctl_table *table)
-{
-	int n;
-repeat:
-	if (!nlen)
-		return -ENOTDIR;
-	if (get_user(n, name))
-		return -EFAULT;
-	for ( ; table->ctl_name || table->procname; table++) {
-		if (!table->ctl_name)
-			continue;
-		if (n == table->ctl_name) {
-			int error;
-			if (table->child) {
-				if (sysctl_perm(table, 001))
-					return -EPERM;
-				name++;
-				nlen--;
-				table = table->child;
-				goto repeat;
-			}
-			error = do_sysctl_strategy(table, name, nlen,
-						   oldval, oldlenp,
-						   newval, newlen);
-			return error;
-		}
-	}
-	return -ENOTDIR;
-}
-
-/* Perform the actual read/write of a sysctl table entry. */
-int do_sysctl_strategy (struct ctl_table *table,
-			int __user *name, int nlen,
-			void __user *oldval, size_t __user *oldlenp,
-			void __user *newval, size_t newlen)
-{
-	int op = 0, rc;
-
-	if (oldval)
-		op |= 004;
-	if (newval) 
-		op |= 002;
-	if (sysctl_perm(table, op))
-		return -EPERM;
-
-	if (table->strategy) {
-		rc = table->strategy(table, name, nlen, oldval, oldlenp,
-				     newval, newlen);
-		if (rc < 0)
-			return rc;
-		if (rc > 0)
-			return 0;
-	}
-
-	/* If there is no strategy routine, or if the strategy returns
-	 * zero, proceed with automatic r/w */
-	if (table->data && table->maxlen) {
-		rc = sysctl_data(table, name, nlen, oldval, oldlenp,
-				 newval, newlen);
-		if (rc < 0)
-			return rc;
-	}
-	return 0;
-}
-#endif /* CONFIG_SYSCTL_SYSCALL */
-
 static void sysctl_set_parent(struct ctl_table *parent, struct ctl_table *table)
 {
 	for (; table->ctl_name || table->procname; table++) {
-- 
1.5.3.4

