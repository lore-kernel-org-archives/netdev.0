From: luciano.coelho@nokia.com
Subject: [PATCH 2/2] netfilter: xt_condition: change the value from boolean to u32
Date: Thu,  5 Aug 2010 17:41:09 +0300
Message-ID: <1281019269-30985-3-git-send-email-luciano.coelho@nokia.com>
References: <1281019269-30985-1-git-send-email-luciano.coelho@nokia.com>
Cc: netdev@vger.kernel.org, kaber@trash.net, jengelh@medozas.de,
	sameo@linux.intel.com
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1281019269-30985-1-git-send-email-luciano.coelho@nokia.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Luciano Coelho <luciano.coelho@nokia.com>

Previously the condition match was using boolean values for the condition,
which is a bit limited, so this patch changes the value to a u32.

This is not a problem at the moment, since only userspace can set the
condition and it can do more advanced checks before setting the value.  But
when the condition target gets implemented, having a u32 value will make it
much more flexible.

Signed-off-by: Luciano Coelho <luciano.coelho@nokia.com>
---
 include/linux/netfilter/xt_condition.h |    3 +-
 net/netfilter/xt_condition.c           |   51 +++++++++++++++++---------------
 2 files changed, 29 insertions(+), 25 deletions(-)

diff --git a/include/linux/netfilter/xt_condition.h b/include/linux/netfilter/xt_condition.h
index 4faf3ca..c4fe899 100644
--- a/include/linux/netfilter/xt_condition.h
+++ b/include/linux/netfilter/xt_condition.h
@@ -4,8 +4,9 @@
 #include <linux/types.h>
 
 struct xt_condition_mtinfo {
-	char name[31];
+	char name[27];
 	__u8 invert;
+	__u32 value;
 
 	/* Used internally by the kernel */
 	void *condvar __attribute__((aligned(8)));
diff --git a/net/netfilter/xt_condition.c b/net/netfilter/xt_condition.c
index a78d832..08dfb67 100644
--- a/net/netfilter/xt_condition.c
+++ b/net/netfilter/xt_condition.c
@@ -48,7 +48,7 @@ struct condition_variable {
 	struct list_head list;
 	struct proc_dir_entry *status_proc;
 	unsigned int refcount;
-	bool enabled;
+	u32 value;
 };
 
 struct condition_net {
@@ -71,32 +71,35 @@ static int condition_proc_read(char __user *buffer, char **start, off_t offset,
 {
 	const struct condition_variable *var = data;
 
-	buffer[0] = var->enabled ? '1' : '0';
-	buffer[1] = '\n';
-	if (length >= 2)
-		*eof = true;
-	return 2;
+	return snprintf(buffer, length, "%u\n", var->value);
 }
 
-static int condition_proc_write(struct file *file, const char __user *buffer,
+static int condition_proc_write(struct file *file, const char __user *input,
 				unsigned long length, void *data)
 {
 	struct condition_variable *var = data;
-	char newval;
-
-	if (length > 0) {
-		if (get_user(newval, buffer) != 0)
-			return -EFAULT;
-		/* Match only on the first character */
-		switch (newval) {
-		case '0':
-			var->enabled = false;
-			break;
-		case '1':
-			var->enabled = true;
-			break;
-		}
-	}
+	char buf[14];
+	unsigned long long value;
+
+	if (length == 0)
+		return 0;
+
+	if (length > sizeof(buf))
+		return -EINVAL;
+
+	if (copy_from_user(buf, input, length) != 0)
+		return -EFAULT;
+
+	buf[length - 1] = '\0';
+
+	if (strict_strtoull(buf, 0, &value) != 0)
+		return -EINVAL;
+
+	if (value > (u32) value)
+		return -EINVAL;
+
+	var->value = value;
+
 	return length;
 }
 
@@ -106,7 +109,7 @@ condition_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	const struct xt_condition_mtinfo *info = par->matchinfo;
 	const struct condition_variable *var   = info->condvar;
 
-	return var->enabled ^ info->invert;
+	return (var->value == info->value) ^ info->invert;
 }
 
 static int condition_mt_check(const struct xt_mtchk_param *par)
@@ -156,7 +159,7 @@ static int condition_mt_check(const struct xt_mtchk_param *par)
 	}
 
 	var->refcount = 1;
-	var->enabled  = false;
+	var->value = 0;
 	var->status_proc->data       = var;
 	var->status_proc->read_proc  = condition_proc_read;
 	var->status_proc->write_proc = condition_proc_write;
-- 
1.7.0.4

