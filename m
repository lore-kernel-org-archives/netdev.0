From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [RFC v4 17/18] landlock: Add update and debug access flags
Date: Wed, 26 Oct 2016 08:56:53 +0200
Message-ID: <20161026065654.19166-18-mic@digikod.net>
References: <20161026065654.19166-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Jann Horn <jann@thejh.net>, Kees Cook <keescook@chromium.org>,
        Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Thomas Graf <tgraf@suug.ch>, Will Drewry <wad@chromium.org>,
        kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
        linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
        cgroups@v
To: linux-kernel@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20161026065654.19166-1-mic@digikod.net>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

For now, the update and debug accesses are only accessible to a process
with CAP_SYS_ADMIN. This could change in the future.

The capability check is statically done when loading an eBPF program,
according to the current process. If the process has enough rights and
set the appropriate access flags, then the dedicated functions or data
will be accessible.

With the update access, the following functions are available:
* bpf_map_lookup_elem
* bpf_map_update_elem
* bpf_map_delete_elem
* bpf_tail_call

With the debug access, the following functions are available:
* bpf_trace_printk
* bpf_get_prandom_u32
* bpf_get_current_pid_tgid
* bpf_get_current_uid_gid
* bpf_get_current_comm

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: David S. Miller <davem@davemloft.net>
Cc: Kees Cook <keescook@chromium.org>
Cc: Sargun Dhillon <sargun@sargun.me>
---
 include/uapi/linux/bpf.h |  4 +++-
 security/landlock/lsm.c  | 53 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 56 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 1d36f7d99288..013f661e27f8 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -607,7 +607,9 @@ enum landlock_hook {
 #define _LANDLOCK_HOOK_LAST LANDLOCK_HOOK_INODE_GETATTR
 
 /* eBPF context and functions allowed for a rule */
-#define _LANDLOCK_SUBTYPE_ACCESS_MASK		((1ULL << 0) - 1)
+#define LANDLOCK_SUBTYPE_ACCESS_UPDATE		(1 << 0)
+#define LANDLOCK_SUBTYPE_ACCESS_DEBUG		(1 << 1)
+#define _LANDLOCK_SUBTYPE_ACCESS_MASK		((1ULL << 2) - 1)
 
 /*
  * (future) options for a Landlock rule (e.g. run even if a previous rule
diff --git a/security/landlock/lsm.c b/security/landlock/lsm.c
index b5180aa7291f..1d924d2414f2 100644
--- a/security/landlock/lsm.c
+++ b/security/landlock/lsm.c
@@ -194,12 +194,57 @@ static int landlock_enforce(enum landlock_hook hook, __u64 args[6])
 static const struct bpf_func_proto *bpf_landlock_func_proto(
 		enum bpf_func_id func_id, union bpf_prog_subtype *prog_subtype)
 {
+	bool access_update = !!(prog_subtype->landlock_rule.access &
+			LANDLOCK_SUBTYPE_ACCESS_UPDATE);
+	bool access_debug = !!(prog_subtype->landlock_rule.access &
+			LANDLOCK_SUBTYPE_ACCESS_DEBUG);
+
 	switch (func_id) {
 	case BPF_FUNC_landlock_get_fs_mode:
 		return &bpf_landlock_get_fs_mode_proto;
 	case BPF_FUNC_landlock_cmp_fs_beneath:
 		return &bpf_landlock_cmp_fs_beneath_proto;
 
+	/* access_update */
+	case BPF_FUNC_map_lookup_elem:
+		if (access_update)
+			return &bpf_map_lookup_elem_proto;
+		return NULL;
+	case BPF_FUNC_map_update_elem:
+		if (access_update)
+			return &bpf_map_update_elem_proto;
+		return NULL;
+	case BPF_FUNC_map_delete_elem:
+		if (access_update)
+			return &bpf_map_delete_elem_proto;
+		return NULL;
+	case BPF_FUNC_tail_call:
+		if (access_update)
+			return &bpf_tail_call_proto;
+		return NULL;
+
+	/* access_debug */
+	case BPF_FUNC_trace_printk:
+		if (access_debug)
+			return bpf_get_trace_printk_proto();
+		return NULL;
+	case BPF_FUNC_get_prandom_u32:
+		if (access_debug)
+			return &bpf_get_prandom_u32_proto;
+		return NULL;
+	case BPF_FUNC_get_current_pid_tgid:
+		if (access_debug)
+			return &bpf_get_current_pid_tgid_proto;
+		return NULL;
+	case BPF_FUNC_get_current_uid_gid:
+		if (access_debug)
+			return &bpf_get_current_uid_gid_proto;
+		return NULL;
+	case BPF_FUNC_get_current_comm:
+		if (access_debug)
+			return &bpf_get_current_comm_proto;
+		return NULL;
+
 	default:
 		return NULL;
 	}
@@ -373,6 +418,14 @@ static inline bool bpf_landlock_is_valid_subtype(
 	if (prog_subtype->landlock_rule.option & ~_LANDLOCK_SUBTYPE_OPTION_MASK)
 		return false;
 
+	/* check access flags */
+	if (prog_subtype->landlock_rule.access & LANDLOCK_SUBTYPE_ACCESS_UPDATE &&
+			!capable(CAP_SYS_ADMIN))
+		return false;
+	if (prog_subtype->landlock_rule.access & LANDLOCK_SUBTYPE_ACCESS_DEBUG &&
+			!capable(CAP_SYS_ADMIN))
+		return false;
+
 	return true;
 }
 
-- 
2.9.3

