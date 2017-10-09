From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v2 2/7] bpf: encapsulate verifier log state into a structure
Date: Mon,  9 Oct 2017 10:30:10 -0700
Message-ID: <20171009173015.23520-3-jakub.kicinski@netronome.com>
References: <20171009173015.23520-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:50793 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754831AbdJIRa3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 13:30:29 -0400
Received: by mail-pf0-f173.google.com with SMTP id m63so14444581pfk.7
        for <netdev@vger.kernel.org>; Mon, 09 Oct 2017 10:30:28 -0700 (PDT)
In-Reply-To: <20171009173015.23520-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Put the loose log_* variables into a structure.  This will make
it simpler to remove the global verifier state in following patches.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
Acked-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/bpf_verifier.h | 13 ++++++++++
 kernel/bpf/verifier.c        | 57 +++++++++++++++++++++++---------------------
 2 files changed, 43 insertions(+), 27 deletions(-)

diff --git a/include/linux/bpf_verifier.h b/include/linux/bpf_verifier.h
index b8d200f60a40..163541ba70d9 100644
--- a/include/linux/bpf_verifier.h
+++ b/include/linux/bpf_verifier.h
@@ -115,6 +115,19 @@ struct bpf_insn_aux_data {
 
 #define MAX_USED_MAPS 64 /* max number of maps accessed by one eBPF program */
 
+struct bpf_verifer_log {
+	u32 level;
+	char *kbuf;
+	char __user *ubuf;
+	u32 len_used;
+	u32 len_total;
+};
+
+static inline bool bpf_verifier_log_full(const struct bpf_verifer_log *log)
+{
+	return log->len_used >= log->len_total - 1;
+}
+
 struct bpf_verifier_env;
 struct bpf_ext_analyzer_ops {
 	int (*insn_hook)(struct bpf_verifier_env *env,
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 590125e29161..4b95831dc409 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -156,8 +156,7 @@ struct bpf_call_arg_meta {
 /* verbose verifier prints what it's seeing
  * bpf_check() is called under lock, so no race to access these global vars
  */
-static u32 log_level, log_size, log_len;
-static char *log_buf;
+static struct bpf_verifer_log verifier_log;
 
 static DEFINE_MUTEX(bpf_verifier_lock);
 
@@ -167,13 +166,15 @@ static DEFINE_MUTEX(bpf_verifier_lock);
  */
 static __printf(1, 2) void verbose(const char *fmt, ...)
 {
+	struct bpf_verifer_log *log = &verifier_log;
 	va_list args;
 
-	if (log_level == 0 || log_len >= log_size - 1)
+	if (!log->level || bpf_verifier_log_full(log))
 		return;
 
 	va_start(args, fmt);
-	log_len += vscnprintf(log_buf + log_len, log_size - log_len, fmt, args);
+	log->len_used += vscnprintf(log->kbuf + log->len_used,
+				    log->len_total - log->len_used, fmt, args);
 	va_end(args);
 }
 
@@ -882,7 +883,7 @@ static int check_map_access(struct bpf_verifier_env *env, u32 regno,
 	 * need to try adding each of min_value and max_value to off
 	 * to make sure our theoretical access will be safe.
 	 */
-	if (log_level)
+	if (verifier_log.level)
 		print_verifier_state(state);
 	/* The minimum value is only important with signed
 	 * comparisons where we can't assume the floor of a
@@ -2951,7 +2952,7 @@ static int check_cond_jmp_op(struct bpf_verifier_env *env,
 		verbose("R%d pointer comparison prohibited\n", insn->dst_reg);
 		return -EACCES;
 	}
-	if (log_level)
+	if (verifier_log.level)
 		print_verifier_state(this_branch);
 	return 0;
 }
@@ -3707,7 +3708,7 @@ static int do_check(struct bpf_verifier_env *env)
 			return err;
 		if (err == 1) {
 			/* found equivalent state, can prune the search */
-			if (log_level) {
+			if (verifier_log.level) {
 				if (do_print_state)
 					verbose("\nfrom %d to %d: safe\n",
 						prev_insn_idx, insn_idx);
@@ -3720,8 +3721,9 @@ static int do_check(struct bpf_verifier_env *env)
 		if (need_resched())
 			cond_resched();
 
-		if (log_level > 1 || (log_level && do_print_state)) {
-			if (log_level > 1)
+		if (verifier_log.level > 1 ||
+		    (verifier_log.level && do_print_state)) {
+			if (verifier_log.level > 1)
 				verbose("%d:", insn_idx);
 			else
 				verbose("\nfrom %d to %d:",
@@ -3730,7 +3732,7 @@ static int do_check(struct bpf_verifier_env *env)
 			do_print_state = false;
 		}
 
-		if (log_level) {
+		if (verifier_log.level) {
 			verbose("%d: ", insn_idx);
 			print_bpf_insn(env, insn);
 		}
@@ -4384,7 +4386,7 @@ static void free_states(struct bpf_verifier_env *env)
 
 int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
 {
-	char __user *log_ubuf = NULL;
+	struct bpf_verifer_log *log = &verifier_log;
 	struct bpf_verifier_env *env;
 	int ret = -EINVAL;
 
@@ -4409,23 +4411,23 @@ int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
 		/* user requested verbose verifier output
 		 * and supplied buffer to store the verification trace
 		 */
-		log_level = attr->log_level;
-		log_ubuf = (char __user *) (unsigned long) attr->log_buf;
-		log_size = attr->log_size;
-		log_len = 0;
+		log->level = attr->log_level;
+		log->ubuf = (char __user *) (unsigned long) attr->log_buf;
+		log->len_total = attr->log_size;
+		log->len_used = 0;
 
 		ret = -EINVAL;
-		/* log_* values have to be sane */
-		if (log_size < 128 || log_size > UINT_MAX >> 8 ||
-		    log_level == 0 || log_ubuf == NULL)
+		/* log attributes have to be sane */
+		if (log->len_total < 128 || log->len_total > UINT_MAX >> 8 ||
+		    !log->level || !log->ubuf)
 			goto err_unlock;
 
 		ret = -ENOMEM;
-		log_buf = vmalloc(log_size);
-		if (!log_buf)
+		log->kbuf = vmalloc(log->len_total);
+		if (!log->kbuf)
 			goto err_unlock;
 	} else {
-		log_level = 0;
+		log->level = 0;
 	}
 
 	env->strict_alignment = !!(attr->prog_flags & BPF_F_STRICT_ALIGNMENT);
@@ -4462,15 +4464,16 @@ int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
 	if (ret == 0)
 		ret = fixup_bpf_calls(env);
 
-	if (log_level && log_len >= log_size - 1) {
-		BUG_ON(log_len >= log_size);
+	if (log->level && bpf_verifier_log_full(log)) {
+		BUG_ON(log->len_used >= log->len_total);
 		/* verifier log exceeded user supplied buffer */
 		ret = -ENOSPC;
 		/* fall through to return what was recorded */
 	}
 
 	/* copy verifier log back to user space including trailing zero */
-	if (log_level && copy_to_user(log_ubuf, log_buf, log_len + 1) != 0) {
+	if (log->level && copy_to_user(log->ubuf, log->kbuf,
+				       log->len_used + 1) != 0) {
 		ret = -EFAULT;
 		goto free_log_buf;
 	}
@@ -4497,8 +4500,8 @@ int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
 	}
 
 free_log_buf:
-	if (log_level)
-		vfree(log_buf);
+	if (log->level)
+		vfree(log->kbuf);
 	if (!env->prog->aux->used_maps)
 		/* if we didn't copy map pointers into bpf_prog_info, release
 		 * them now. Otherwise free_bpf_prog_info() will release them.
@@ -4535,7 +4538,7 @@ int bpf_analyzer(struct bpf_prog *prog, const struct bpf_ext_analyzer_ops *ops,
 	/* grab the mutex to protect few globals used by verifier */
 	mutex_lock(&bpf_verifier_lock);
 
-	log_level = 0;
+	verifier_log.level = 0;
 
 	env->strict_alignment = false;
 	if (!IS_ENABLED(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS))
-- 
2.14.1
