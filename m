From: Richard Weinberger <richard@nod.at>
Subject: [PATCH 3/3] bpf: Make sure that ->comm does not change under us.
Date: Mon, 16 Oct 2017 20:18:56 +0200
Message-ID: <20171016181856.12497-3-richard@nod.at>
References: <20171016181856.12497-1-richard@nod.at>
Cc: linux-kernel@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org,
        Richard Weinberger <richard@nod.at>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171016181856.12497-1-richard@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sadly we cannot use get_task_comm() since bpf_get_current_comm()
allows truncation.

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 kernel/bpf/helpers.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/kernel/bpf/helpers.c b/kernel/bpf/helpers.c
index 511c9d522cfc..4b042b24524d 100644
--- a/kernel/bpf/helpers.c
+++ b/kernel/bpf/helpers.c
@@ -18,6 +18,7 @@
 #include <linux/sched.h>
 #include <linux/uidgid.h>
 #include <linux/filter.h>
+#include <linux/sched/task.h>
 
 /* If kernel subsystem is allowing eBPF programs to call this function,
  * inside its own verifier_ops->get_func_proto() callback it should return
@@ -149,7 +150,9 @@ BPF_CALL_2(bpf_get_current_comm, char *, buf, u32, size)
 {
 	struct task_struct *task = current;
 
+	task_lock(task);
 	strncpy(buf, task->comm, size);
+	task_unlock(task);
 
 	/* Verifier guarantees that size > 0. For task->comm exceeding
 	 * size, guarantee that buf is %NUL-terminated. Unconditionally
-- 
2.13.6
