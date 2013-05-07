From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH RFC 45/48] Audit: user audit_enabled_ns to replace audit_enabled
Date: Tue, 7 May 2013 10:21:06 +0800
Message-ID: <1367893269-9308-46-git-send-email-gaofeng@cn.fujitsu.com>
References: <1367893269-9308-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-audit@redhat.com,
	Gao feng <gaofeng@cn.fujitsu.com>
To: viro@zeniv.linux.org.uk, eparis@redhat.com, ebiederm@xmission.com,
	sgrubb@redhat.com, akpm@linux-foundation.org,
	serge.hallyn@ubuntu.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1367893269-9308-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We should use the proper user namespace's audit.enabled,
not the init_user_ns's audit.enabled.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 drivers/tty/tty_audit.c | 4 ++--
 kernel/auditsc.c        | 2 +-
 net/core/dev.c          | 2 +-
 security/apparmor/lib.c | 2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/tty/tty_audit.c b/drivers/tty/tty_audit.c
index 7dfa931..f2d6811 100644
--- a/drivers/tty/tty_audit.c
+++ b/drivers/tty/tty_audit.c
@@ -99,7 +99,7 @@ static void tty_audit_buf_push(struct task_struct *tsk, kuid_t loginuid,
 {
 	if (buf->valid == 0)
 		return;
-	if (audit_enabled == 0) {
+	if (audit_enabled_ns(task_cred_xxx(tsk, user_ns)) == 0) {
 		buf->valid = 0;
 		return;
 	}
@@ -182,7 +182,7 @@ void tty_audit_tiocsti(struct tty_struct *tty, char ch)
 		tty_audit_buf_put(buf);
 	}
 
-	if (should_audit && audit_enabled) {
+	if (should_audit && audit_enabled_ns(current_user_ns())) {
 		kuid_t auid;
 		unsigned int sessionid;
 
diff --git a/kernel/auditsc.c b/kernel/auditsc.c
index a65020a..e579b75 100644
--- a/kernel/auditsc.c
+++ b/kernel/auditsc.c
@@ -1782,7 +1782,7 @@ void __audit_syscall_entry(int arch, int major,
 
 	BUG_ON(context->in_syscall || context->name_count);
 
-	if (!audit_enabled)
+	if (!audit_enabled_ns(ns))
 		return;
 
 	context->arch	    = arch;
diff --git a/net/core/dev.c b/net/core/dev.c
index 40b1fad..651ad69 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4458,7 +4458,7 @@ static int __dev_set_promiscuity(struct net_device *dev, int inc)
 		pr_info("device %s %s promiscuous mode\n",
 			dev->name,
 			dev->flags & IFF_PROMISC ? "entered" : "left");
-		if (audit_enabled) {
+		if (audit_enabled_ns(current_user_ns())) {
 			current_uid_gid(&uid, &gid);
 			audit_log(current->audit_context, GFP_ATOMIC,
 				AUDIT_ANOM_PROMISCUOUS,
diff --git a/security/apparmor/lib.c b/security/apparmor/lib.c
index 7430298..9cae5ce 100644
--- a/security/apparmor/lib.c
+++ b/security/apparmor/lib.c
@@ -63,7 +63,7 @@ char *aa_split_fqname(char *fqname, char **ns_name)
  */
 void aa_info_message(const char *str)
 {
-	if (audit_enabled) {
+	if (audit_enabled_ns(current_user_ns())) {
 		struct common_audit_data sa;
 		struct apparmor_audit_data aad = {0,};
 		sa.type = LSM_AUDIT_DATA_NONE;
-- 
1.8.1.4
