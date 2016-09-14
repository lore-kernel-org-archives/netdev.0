From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [RFC v3 20/22] landlock: Add update and debug access flags
Date: Wed, 14 Sep 2016 09:24:13 +0200
Message-ID: <20160914072415.26021-21-mic@digikod.net>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160914072415.26021-1-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
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
 security/landlock/lsm.c  | 54 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 57 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 3cc52e51357f..8cfc2de2ab76 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -584,7 +584,9 @@ enum landlock_hook_id {
 #define _LANDLOCK_FLAG_ORIGIN_MASK	((1 << 3) - 1)
 
 /* context of function access flags */
-#define _LANDLOCK_FLAG_ACCESS_MASK	((1ULL << 0) - 1)
+#define LANDLOCK_FLAG_ACCESS_UPDATE	(1 << 0)
+#define LANDLOCK_FLAG_ACCESS_DEBUG	(1 << 1)
+#define _LANDLOCK_FLAG_ACCESS_MASK	((1ULL << 2) - 1)
 
 /* Handle check flags */
 #define LANDLOCK_FLAG_FS_DENTRY		(1 << 0)
diff --git a/security/landlock/lsm.c b/security/landlock/lsm.c
index 2a15839a08c8..56c45abe979c 100644
--- a/security/landlock/lsm.c
+++ b/security/landlock/lsm.c
@@ -202,11 +202,57 @@ static int landlock_run_prog(enum landlock_hook_id hook_id, __u64 args[6])
 static const struct bpf_func_proto *bpf_landlock_func_proto(
 		enum bpf_func_id func_id, union bpf_prog_subtype *prog_subtype)
 {
+	bool access_update = !!(prog_subtype->landlock_hook.access &
+			LANDLOCK_FLAG_ACCESS_UPDATE);
+	bool access_debug = !!(prog_subtype->landlock_hook.access &
+			LANDLOCK_FLAG_ACCESS_DEBUG);
+
 	switch (func_id) {
 	case BPF_FUNC_landlock_cmp_fs_prop_with_struct_file:
 		return &bpf_landlock_cmp_fs_prop_with_struct_file_proto;
 	case BPF_FUNC_landlock_cmp_fs_beneath_with_struct_file:
 		return &bpf_landlock_cmp_fs_beneath_with_struct_file_proto;
+
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
@@ -348,6 +394,14 @@ static inline bool bpf_landlock_is_valid_subtype(
 	if (prog_subtype->landlock_hook.access & ~_LANDLOCK_FLAG_ACCESS_MASK)
 		return false;
 
+	/* check access flags */
+	if (prog_subtype->landlock_hook.access & LANDLOCK_FLAG_ACCESS_UPDATE &&
+			!capable(CAP_SYS_ADMIN))
+		return false;
+	if (prog_subtype->landlock_hook.access & LANDLOCK_FLAG_ACCESS_DEBUG &&
+			!capable(CAP_SYS_ADMIN))
+		return false;
+
 	return true;
 }
 
-- 
2.9.3
