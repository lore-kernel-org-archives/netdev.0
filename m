From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [RFC v3 19/22] landlock: Add interrupted origin
Date: Wed, 14 Sep 2016 09:24:12 +0200
Message-ID: <20160914072415.26021-20-mic@digikod.net>
References: <20160914072415.26021-1-mic@digikod.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>, Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>, David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Will Drewry <wad@chromium.org>, kernel-hardening@lists.openwall.com,
        linux-api@vger.kernel.org, linux-security-module@vger.
To: linux-kernel@vger.kernel.org
Return-path: <kernel-hardening-return-4603-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20160914072415.26021-1-mic@digikod.net>
List-Id: netdev.vger.kernel.org

This third origin of hook call should cover all possible trigger paths
(e.g. page fault). Landlock eBPF programs can then take decisions
accordingly.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Kees Cook <keescook@chromium.org>
---
 include/uapi/linux/bpf.h |  3 ++-
 security/landlock/lsm.c  | 17 +++++++++++++++--
 2 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 12e61508f879..3cc52e51357f 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -580,7 +580,8 @@ enum landlock_hook_id {
 /* Trigger type */
 #define LANDLOCK_FLAG_ORIGIN_SYSCALL	(1 << 0)
 #define LANDLOCK_FLAG_ORIGIN_SECCOMP	(1 << 1)
-#define _LANDLOCK_FLAG_ORIGIN_MASK	((1 << 2) - 1)
+#define LANDLOCK_FLAG_ORIGIN_INTERRUPT	(1 << 2)
+#define _LANDLOCK_FLAG_ORIGIN_MASK	((1 << 3) - 1)
 
 /* context of function access flags */
 #define _LANDLOCK_FLAG_ACCESS_MASK	((1ULL << 0) - 1)
diff --git a/security/landlock/lsm.c b/security/landlock/lsm.c
index 000dd0c7ec3d..2a15839a08c8 100644
--- a/security/landlock/lsm.c
+++ b/security/landlock/lsm.c
@@ -17,6 +17,7 @@
 #include <linux/kernel.h> /* FIELD_SIZEOF() */
 #include <linux/landlock.h>
 #include <linux/lsm_hooks.h>
+#include <linux/preempt.h> /* in_interrupt() */
 #include <linux/seccomp.h> /* struct seccomp_* */
 #include <linux/types.h> /* uintptr_t */
 
@@ -109,6 +110,7 @@ static int landlock_run_prog(enum landlock_hook_id hook_id, __u64 args[6])
 #endif /* CONFIG_CGROUP_BPF */
 	struct landlock_rule *rule;
 	u32 hook_idx = get_index(hook_id);
+	u16 current_call;
 
 	struct landlock_data ctx = {
 		.hook = hook_id,
@@ -128,6 +130,16 @@ static int landlock_run_prog(enum landlock_hook_id hook_id, __u64 args[6])
 	 * prioritize fine-grained policies (i.e. per thread), and return early.
 	 */
 
+	if (unlikely(in_interrupt())) {
+		current_call = LANDLOCK_FLAG_ORIGIN_INTERRUPT;
+#ifdef CONFIG_SECCOMP_FILTER
+		/* bypass landlock_ret evaluation */
+		goto seccomp_int;
+#endif /* CONFIG_SECCOMP_FILTER */
+	} else {
+		current_call = LANDLOCK_FLAG_ORIGIN_SYSCALL;
+	}
+
 #ifdef CONFIG_SECCOMP_FILTER
 	/* seccomp triggers and landlock_ret cleanup */
 	ctx.origin = LANDLOCK_FLAG_ORIGIN_SECCOMP;
@@ -164,8 +176,9 @@ static int landlock_run_prog(enum landlock_hook_id hook_id, __u64 args[6])
 		return -ret;
 	ctx.cookie = 0;
 
+seccomp_int:
 	/* syscall trigger */
-	ctx.origin = LANDLOCK_FLAG_ORIGIN_SYSCALL;
+	ctx.origin = current_call;
 	ret = landlock_run_prog_for_syscall(hook_idx, &ctx,
 			current->seccomp.landlock_hooks);
 	if (ret)
@@ -175,7 +188,7 @@ static int landlock_run_prog(enum landlock_hook_id hook_id, __u64 args[6])
 #ifdef CONFIG_CGROUP_BPF
 	/* syscall trigger */
 	if (cgroup_bpf_enabled) {
-		ctx.origin = LANDLOCK_FLAG_ORIGIN_SYSCALL;
+		ctx.origin = current_call;
 		/* get the default cgroup associated with the current thread */
 		cgrp = task_css_set(current)->dfl_cgrp;
 		ret = landlock_run_prog_for_syscall(hook_idx, &ctx,
-- 
2.9.3
