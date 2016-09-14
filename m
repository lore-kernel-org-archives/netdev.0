From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [RFC v3 21/22] bpf,landlock: Add optional skb pointer in the Landlock context
Date: Wed, 14 Sep 2016 09:24:14 +0200
Message-ID: <20160914072415.26021-22-mic@digikod.net>
References: <20160914072415.26021-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>,
        Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Will Drewry <wad@chromium.org>,
        kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-sh.infomaniak.ch ([128.65.195.4]:59211 "EHLO
        smtp-sh.infomaniak.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760588AbcINH0I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 03:26:08 -0400
In-Reply-To: <20160914072415.26021-1-mic@digikod.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a proof of concept to expose optional values that could depend
of the process access rights.

There is two dedicated flags: LANDLOCK_FLAG_ACCESS_SKB_READ and
LANDLOCK_FLAG_ACCESS_SKB_WRITE. Each of them can be activated to access
eBPF functions manipulating a skb in a read or write way.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: David S. Miller <davem@davemloft.net>
Cc: Kees Cook <keescook@chromium.org>
Cc: Sargun Dhillon <sargun@sargun.me>
---
 include/linux/bpf.h      |  2 ++
 include/uapi/linux/bpf.h |  7 ++++++-
 kernel/bpf/verifier.c    |  6 ++++++
 security/landlock/lsm.c  | 26 ++++++++++++++++++++++++++
 4 files changed, 40 insertions(+), 1 deletion(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index f7325c17f720..218973777612 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -88,6 +88,7 @@ enum bpf_arg_type {
 
 	ARG_PTR_TO_STRUCT_FILE,		/* pointer to struct file */
 	ARG_CONST_PTR_TO_LANDLOCK_HANDLE_FS,	/* pointer to Landlock FS handle */
+	ARG_PTR_TO_STRUCT_SKB,		/* pointer to struct skb */
 };
 
 /* type of values returned from helper functions */
@@ -150,6 +151,7 @@ enum bpf_reg_type {
 	/* Landlock */
 	PTR_TO_STRUCT_FILE,
 	CONST_PTR_TO_LANDLOCK_HANDLE_FS,
+	PTR_TO_STRUCT_SKB,
 };
 
 struct bpf_prog;
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 8cfc2de2ab76..7d9e56952ed9 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -586,7 +586,9 @@ enum landlock_hook_id {
 /* context of function access flags */
 #define LANDLOCK_FLAG_ACCESS_UPDATE	(1 << 0)
 #define LANDLOCK_FLAG_ACCESS_DEBUG	(1 << 1)
-#define _LANDLOCK_FLAG_ACCESS_MASK	((1ULL << 2) - 1)
+#define LANDLOCK_FLAG_ACCESS_SKB_READ	(1 << 2)
+#define LANDLOCK_FLAG_ACCESS_SKB_WRITE	(1 << 3)
+#define _LANDLOCK_FLAG_ACCESS_MASK	((1ULL << 4) - 1)
 
 /* Handle check flags */
 #define LANDLOCK_FLAG_FS_DENTRY		(1 << 0)
@@ -619,12 +621,15 @@ struct landlock_handle {
  * @args: LSM hook arguments, see include/linux/lsm_hooks.h for there
  *        description and the LANDLOCK_HOOK* definitions from
  *        security/landlock/lsm.c for their types.
+ * @opt_skb: optional skb pointer, accessible with the
+ *           LANDLOCK_FLAG_ACCESS_SKB_* flags for network-related hooks.
  */
 struct landlock_data {
 	__u32 hook; /* enum landlock_hook_id */
 	__u16 origin; /* LANDLOCK_FLAG_ORIGIN_* */
 	__u16 cookie; /* seccomp RET_LANDLOCK */
 	__u64 args[6];
+	__u64 opt_skb;
 };
 
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 8d7b18574f5a..a95154c1a60f 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -247,6 +247,7 @@ static const char * const reg_type_str[] = {
 	[PTR_TO_PACKET_END]	= "pkt_end",
 	[PTR_TO_STRUCT_FILE]	= "struct_file",
 	[CONST_PTR_TO_LANDLOCK_HANDLE_FS] = "landlock_handle_fs",
+	[PTR_TO_STRUCT_SKB]	= "struct_skb",
 };
 
 static void print_verifier_state(struct verifier_state *state)
@@ -559,6 +560,7 @@ static bool is_spillable_regtype(enum bpf_reg_type type)
 	case CONST_PTR_TO_MAP:
 	case PTR_TO_STRUCT_FILE:
 	case CONST_PTR_TO_LANDLOCK_HANDLE_FS:
+	case PTR_TO_STRUCT_SKB:
 		return true;
 	default:
 		return false;
@@ -984,6 +986,10 @@ static int check_func_arg(struct verifier_env *env, u32 regno,
 		expected_type = CONST_PTR_TO_LANDLOCK_HANDLE_FS;
 		if (type != expected_type)
 			goto err_type;
+	} else if (arg_type == ARG_PTR_TO_STRUCT_SKB) {
+		expected_type = PTR_TO_STRUCT_SKB;
+		if (type != expected_type)
+			goto err_type;
 	} else if (arg_type == ARG_PTR_TO_STACK ||
 		   arg_type == ARG_PTR_TO_RAW_STACK) {
 		expected_type = PTR_TO_STACK;
diff --git a/security/landlock/lsm.c b/security/landlock/lsm.c
index 56c45abe979c..8b0e6f0eb6b7 100644
--- a/security/landlock/lsm.c
+++ b/security/landlock/lsm.c
@@ -281,6 +281,7 @@ static bool __is_valid_access(int off, int size, enum bpf_access_type type,
 		break;
 	case offsetof(struct landlock_data, args[0]) ...
 			offsetof(struct landlock_data, args[5]):
+	case offsetof(struct landlock_data, opt_skb):
 		expected_size = sizeof(__u64);
 		break;
 	default:
@@ -299,6 +300,13 @@ static bool __is_valid_access(int off, int size, enum bpf_access_type type,
 		if (*reg_type == NOT_INIT)
 			return false;
 		break;
+	case offsetof(struct landlock_data, opt_skb):
+		if (!(prog_subtype->landlock_hook.access &
+				(LANDLOCK_FLAG_ACCESS_SKB_READ |
+				 LANDLOCK_FLAG_ACCESS_SKB_WRITE)))
+			return false;
+		*reg_type = PTR_TO_STRUCT_SKB;
+		break;
 	}
 
 	return true;
@@ -401,6 +409,24 @@ static inline bool bpf_landlock_is_valid_subtype(
 	if (prog_subtype->landlock_hook.access & LANDLOCK_FLAG_ACCESS_DEBUG &&
 			!capable(CAP_SYS_ADMIN))
 		return false;
+	/*
+	 * Capability checks must be enforced for every landlocked process.
+	 * To support user namespaces/capabilities, we must then check the
+	 * namespaces of a task before putting it in a landlocked cgroup.
+	 * This could be implemented in the future.
+	 */
+	if (prog_subtype->landlock_hook.access & LANDLOCK_FLAG_ACCESS_SKB_READ &&
+			!capable(CAP_NET_ADMIN))
+		return false;
+	/*
+	 * It is interesting to differentiate read and write access to be able
+	 * to securely delegate some work to unprivileged (and potentially
+	 * compromised/untrusted) processes. This different type of access can
+	 * be checked for function calls or context accesses.
+	 */
+	if (prog_subtype->landlock_hook.access & LANDLOCK_FLAG_ACCESS_SKB_WRITE &&
+			!capable(CAP_NET_ADMIN))
+		return false;
 
 	return true;
 }
-- 
2.9.3
