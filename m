From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH RFC 31/48] Audit: pass proper user namespace to audit_filter_syscall
Date: Tue, 7 May 2013 10:20:52 +0800
Message-ID: <1367893269-9308-32-git-send-email-gaofeng@cn.fujitsu.com>
References: <1367893269-9308-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-audit@redhat.com,
	Gao feng <gaofeng@cn.fujitsu.com>
To: viro@zeniv.linux.org.uk, eparis@redhat.com, ebiederm@xmission.com,
	sgrubb@redhat.com, akpm@linux-foundation.org,
	serge.hallyn@ubuntu.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59645 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S933352Ab3EGCTf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 May 2013 22:19:35 -0400
In-Reply-To: <1367893269-9308-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should use the proper user namespace to filter the syscall.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 kernel/auditsc.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/kernel/auditsc.c b/kernel/auditsc.c
index 29c3e05..5401d21 100644
--- a/kernel/auditsc.c
+++ b/kernel/auditsc.c
@@ -866,14 +866,15 @@ static enum audit_state audit_filter_task(struct task_struct *tsk, char **key)
  * also not high enough that we already know we have to write an audit
  * record (i.e., the state is AUDIT_SETUP_CONTEXT or AUDIT_BUILD_CONTEXT).
  */
-static enum audit_state audit_filter_syscall(struct task_struct *tsk,
+static enum audit_state audit_filter_syscall(struct user_namespace *ns,
+					     struct task_struct *tsk,
 					     struct audit_context *ctx,
 					     struct list_head *list)
 {
 	struct audit_entry *e;
 	enum audit_state state;
 
-	if (init_user_ns.audit.pid && tsk->tgid == init_user_ns.audit.pid)
+	if (ns->audit.pid && tsk->tgid == ns->audit.pid)
 		return AUDIT_DISABLED;
 
 	rcu_read_lock();
@@ -976,7 +977,7 @@ static inline struct audit_context *audit_get_context(struct task_struct *tsk,
 		context->return_code  = return_code;
 
 	if (context->in_syscall && !context->dummy) {
-		audit_filter_syscall(tsk, context,
+		audit_filter_syscall(ns, tsk, context,
 				&ns->audit.filter_list[AUDIT_FILTER_EXIT]);
 		audit_filter_inodes(tsk, context);
 	}
@@ -1784,7 +1785,7 @@ void __audit_syscall_entry(int arch, int major,
 	context->dummy = !audit_n_rules;
 	if (!context->dummy && state == AUDIT_BUILD_CONTEXT) {
 		context->prio = 0;
-		state = audit_filter_syscall(tsk, context,
+		state = audit_filter_syscall(ns, tsk, context,
 			&ns->audit.filter_list[AUDIT_FILTER_ENTRY]);
 	}
 	if (state == AUDIT_DISABLED)
-- 
1.8.1.4
