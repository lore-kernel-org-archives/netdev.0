From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 5/5] bpf: write back the verifier log buffer as it gets filled
Date: Thu,  5 Oct 2017 08:34:22 -0700
Message-ID: <20171005153422.8947-6-jakub.kicinski@netronome.com>
References: <20171005153422.8947-1-jakub.kicinski@netronome.com>
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:47319 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751286AbdJEPek (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 11:34:40 -0400
Received: by mail-pg0-f50.google.com with SMTP id r25so6042702pgn.4
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 08:34:39 -0700 (PDT)
In-Reply-To: <20171005153422.8947-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Verifier log buffer can be quite large (up to 16MB currently).
As Eric Dumazet points out if we allow multiple verification
requests to proceed simultaneously, malicious user may use the
verifier as a way of allocating large amounts of unswappable
memory to OOM the host.

Switch to a strategy of allocating a smaller buffer (a page)
and writing it out into the user buffer whenever it fills up.
To simplify the code assume that prints will never be longer
than 1024 bytes.

This is in preparation of the global verifier lock removal.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 include/linux/bpf_verifier.h |  7 +++--
 kernel/bpf/verifier.c        | 64 +++++++++++++++++++++++++++++++-------------
 2 files changed, 50 insertions(+), 21 deletions(-)

diff --git a/include/linux/bpf_verifier.h b/include/linux/bpf_verifier.h
index 598802dd1897..c0f0e210c3f8 100644
--- a/include/linux/bpf_verifier.h
+++ b/include/linux/bpf_verifier.h
@@ -140,10 +140,13 @@ struct bpf_verifier_env {
 	bool seen_direct_write;
 	struct bpf_insn_aux_data *insn_aux_data; /* array of per-insn state */
 
-	u32 log_level;
+	char __user *log_ubuf;
+	u32 log_usize;
+	u32 log_ulen;
+	char *log_buf;
 	u32 log_size;
 	u32 log_len;
-	char *log_buf;
+	u32 log_level;
 };
 
 int bpf_analyzer(struct bpf_prog *prog, const struct bpf_ext_analyzer_ops *ops,
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 3c5b9fb33e06..89763ae3f33c 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -157,6 +157,19 @@ struct bpf_call_arg_meta {
 
 static DEFINE_MUTEX(bpf_verifier_lock);
 
+#define BFP_VERIFIER_MAX_MSG		1024
+
+static void bpf_write_back_user_log(struct bpf_verifier_env *env)
+{
+	unsigned int n = min(env->log_usize - env->log_ulen - 1, env->log_len);
+
+	if (!copy_to_user(env->log_ubuf + env->log_ulen, env->log_buf, n))
+		env->log_ulen += n;
+	else
+		env->log_ubuf = NULL;
+	env->log_len = 0;
+}
+
 /* log_level controls verbosity level of eBPF verifier.
  * verbose() is used to dump the verification trace to the log, so the user
  * can figure out what's wrong with the program
@@ -166,13 +179,19 @@ static __printf(2, 3) void verbose(struct bpf_verifier_env *env,
 {
 	va_list args;
 
-	if (env->log_level == 0 || env->log_len >= env->log_size - 1)
+	if (!env->log_level || !env->log_ubuf ||
+	    env->log_ulen >= env->log_usize - 1)
 		return;
 
 	va_start(args, fmt);
 	env->log_len += vscnprintf(env->log_buf + env->log_len,
 				   env->log_size - env->log_len, fmt, args);
 	va_end(args);
+
+	WARN_ON_ONCE(env->log_len >= env->log_size);
+
+	if (env->log_len + BFP_VERIFIER_MAX_MSG > env->log_size)
+		bpf_write_back_user_log(env);
 }
 
 static bool type_is_pkt_pointer(enum bpf_reg_type type)
@@ -4220,7 +4239,6 @@ static void free_states(struct bpf_verifier_env *env)
 
 int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
 {
-	char __user *log_ubuf = NULL;
 	struct bpf_verifier_env *env;
 	int ret = -EINVAL;
 
@@ -4246,19 +4264,20 @@ int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
 		 * and supplied buffer to store the verification trace
 		 */
 		env->log_level = attr->log_level;
-		log_ubuf = (char __user *) (unsigned long) attr->log_buf;
-		env->log_size = attr->log_size;
+		env->log_ubuf = (char __user *) (unsigned long) attr->log_buf;
+		env->log_usize = attr->log_size;
 
 		ret = -EINVAL;
 		/* log_* values have to be sane */
-		if (env->log_size < 128 || env->log_size > UINT_MAX >> 8 ||
-		    env->log_level == 0 || log_ubuf == NULL)
+		if (env->log_usize < 128 || env->log_usize > UINT_MAX >> 8 ||
+		    env->log_ubuf == NULL || env->log_level == 0)
 			goto err_unlock;
 
 		ret = -ENOMEM;
-		env->log_buf = vmalloc(env->log_size);
+		env->log_buf = page_address(alloc_page(GFP_USER));
 		if (!env->log_buf)
 			goto err_unlock;
+		env->log_size = PAGE_SIZE;
 	}
 
 	env->strict_alignment = !!(attr->prog_flags & BPF_F_STRICT_ALIGNMENT);
@@ -4295,18 +4314,25 @@ int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
 	if (ret == 0)
 		ret = fixup_bpf_calls(env);
 
-	if (env->log_level && env->log_len >= env->log_size - 1) {
-		BUG_ON(env->log_len >= env->log_size);
-		/* verifier log exceeded user supplied buffer */
-		ret = -ENOSPC;
-		/* fall through to return what was recorded */
-	}
+	if (env->log_level) {
+		if (env->log_ulen + env->log_len >= env->log_usize - 1) {
+			BUG_ON(env->log_ulen >= env->log_usize);
+			/* verifier log exceeded user supplied buffer */
+			env->log_len = env->log_usize - env->log_ulen - 1;
+			ret = -ENOSPC;
+			/* fall through to return what was recorded */
+		}
 
-	/* copy verifier log back to user space including trailing zero */
-	if (env->log_level &&
-	    copy_to_user(log_ubuf, env->log_buf, env->log_len + 1) != 0) {
-		ret = -EFAULT;
-		goto free_log_buf;
+		/* Note that we are guaranteed BFP_VERIFIER_MAX_MSG of space */
+		env->log_buf[env->log_len] = '\0';
+
+		/* copy the rest of log to user space including trailing zero */
+		if (!env->log_ubuf ||
+		    copy_to_user(env->log_ubuf + env->log_ulen,
+				 env->log_buf, env->log_len + 1)) {
+			ret = -EFAULT;
+			goto free_log_buf;
+		}
 	}
 
 	if (ret == 0 && env->used_map_cnt) {
@@ -4332,7 +4358,7 @@ int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
 
 free_log_buf:
 	if (env->log_level)
-		vfree(env->log_buf);
+		__free_page(virt_to_page(env->log_buf));
 	if (!env->prog->aux->used_maps)
 		/* if we didn't copy map pointers into bpf_prog_info, release
 		 * them now. Otherwise free_bpf_prog_info() will release them.
-- 
2.14.1
