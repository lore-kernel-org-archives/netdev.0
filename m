From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 4/6] bpf: track if the bpf program was loaded with SYS_ADMIN capabilities
Date: Wed, 26 Apr 2017 20:24:17 +0200
Message-ID: <20170426182419.14574-5-hannes@stressinduktion.org>
References: <20170426182419.14574-1-hannes@stressinduktion.org>
Cc: ast@kernel.org, daniel@iogearbox.com, jbenc@redhat.com,
        aconole@bytheb.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:38085 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933327AbdDZSYn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 14:24:43 -0400
In-Reply-To: <20170426182419.14574-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/linux/filter.h | 6 ++++--
 kernel/bpf/core.c      | 4 +++-
 kernel/bpf/syscall.c   | 7 ++++---
 kernel/bpf/verifier.c  | 4 ++--
 net/core/filter.c      | 6 +++---
 5 files changed, 16 insertions(+), 11 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 63624c619e371b..635311f57bf24f 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -413,7 +413,8 @@ struct bpf_prog {
 				locked:1,	/* Program image locked? */
 				gpl_compatible:1, /* Is filter GPL compatible? */
 				cb_access:1,	/* Is control block accessed? */
-				dst_needed:1;	/* Do we need dst entry? */
+				dst_needed:1,	/* Do we need dst entry? */
+				priv_cap_sys_admin:1; /* Where we loaded as sys_admin? */
 	kmemcheck_bitfield_end(meta);
 	enum bpf_prog_type	type;		/* Type of BPF program */
 	u32			len;		/* Number of filter blocks */
@@ -615,7 +616,8 @@ static inline int sk_filter(struct sock *sk, struct sk_buff *skb)
 struct bpf_prog *bpf_prog_select_runtime(struct bpf_prog *fp, int *err);
 void bpf_prog_free(struct bpf_prog *fp);
 
-struct bpf_prog *bpf_prog_alloc(unsigned int size, gfp_t gfp_extra_flags);
+struct bpf_prog *bpf_prog_alloc(unsigned int size, gfp_t gfp_extra_flags,
+				bool cap_sys_admin);
 struct bpf_prog *bpf_prog_realloc(struct bpf_prog *fp_old, unsigned int size,
 				  gfp_t gfp_extra_flags);
 void __bpf_prog_free(struct bpf_prog *fp);
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 2139118258cdf8..048e2d79718a16 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -74,7 +74,8 @@ void *bpf_internal_load_pointer_neg_helper(const struct sk_buff *skb, int k, uns
 	return NULL;
 }
 
-struct bpf_prog *bpf_prog_alloc(unsigned int size, gfp_t gfp_extra_flags)
+struct bpf_prog *bpf_prog_alloc(unsigned int size, gfp_t gfp_extra_flags,
+				bool cap_sys_admin)
 {
 	gfp_t gfp_flags = GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO |
 			  gfp_extra_flags;
@@ -94,6 +95,7 @@ struct bpf_prog *bpf_prog_alloc(unsigned int size, gfp_t gfp_extra_flags)
 		return NULL;
 	}
 
+	fp->priv_cap_sys_admin = cap_sys_admin;
 	fp->pages = size / PAGE_SIZE;
 	fp->aux = aux;
 	fp->aux->prog = fp;
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index d61d1bd3e6fee6..ed698c17578a49 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -786,7 +786,7 @@ EXPORT_SYMBOL_GPL(bpf_prog_get_type);
 /* last field in 'union bpf_attr' used by this command */
 #define	BPF_PROG_LOAD_LAST_FIELD kern_version
 
-static int bpf_prog_load(union bpf_attr *attr)
+static int bpf_prog_load(union bpf_attr *attr, bool cap_sys_admin)
 {
 	enum bpf_prog_type type = attr->prog_type;
 	struct bpf_prog *prog;
@@ -817,7 +817,8 @@ static int bpf_prog_load(union bpf_attr *attr)
 		return -EPERM;
 
 	/* plain bpf_prog allocation */
-	prog = bpf_prog_alloc(bpf_prog_size(attr->insn_cnt), GFP_USER);
+	prog = bpf_prog_alloc(bpf_prog_size(attr->insn_cnt), GFP_USER,
+			      cap_sys_admin);
 	if (!prog)
 		return -ENOMEM;
 
@@ -1053,7 +1054,7 @@ SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, siz
 		err = map_get_next_key(&attr);
 		break;
 	case BPF_PROG_LOAD:
-		err = bpf_prog_load(&attr);
+		err = bpf_prog_load(&attr, capable(CAP_SYS_ADMIN));
 		break;
 	case BPF_OBJ_PIN:
 		err = bpf_obj_pin(&attr);
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 6f8b6ed690be93..24c9dac374770f 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -3488,7 +3488,7 @@ int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
 	if (ret < 0)
 		goto skip_full_check;
 
-	env->allow_ptr_leaks = capable(CAP_SYS_ADMIN);
+	env->allow_ptr_leaks = env->prog->priv_cap_sys_admin;
 
 	ret = do_check(env);
 
@@ -3589,7 +3589,7 @@ int bpf_analyzer(struct bpf_prog *prog, const struct bpf_ext_analyzer_ops *ops,
 	if (ret < 0)
 		goto skip_full_check;
 
-	env->allow_ptr_leaks = capable(CAP_SYS_ADMIN);
+	env->allow_ptr_leaks = prog->priv_cap_sys_admin;
 
 	ret = do_check(env);
 
diff --git a/net/core/filter.c b/net/core/filter.c
index 9a37860a80fc78..dc020d40bb770a 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1100,7 +1100,7 @@ int bpf_prog_create(struct bpf_prog **pfp, struct sock_fprog_kern *fprog)
 	if (!bpf_check_basics_ok(fprog->filter, fprog->len))
 		return -EINVAL;
 
-	fp = bpf_prog_alloc(bpf_prog_size(fprog->len), 0);
+	fp = bpf_prog_alloc(bpf_prog_size(fprog->len), 0, false);
 	if (!fp)
 		return -ENOMEM;
 
@@ -1147,7 +1147,7 @@ int bpf_prog_create_from_user(struct bpf_prog **pfp, struct sock_fprog *fprog,
 	if (!bpf_check_basics_ok(fprog->filter, fprog->len))
 		return -EINVAL;
 
-	fp = bpf_prog_alloc(bpf_prog_size(fprog->len), 0);
+	fp = bpf_prog_alloc(bpf_prog_size(fprog->len), 0, false);
 	if (!fp)
 		return -ENOMEM;
 
@@ -1249,7 +1249,7 @@ struct bpf_prog *__get_filter(struct sock_fprog *fprog, struct sock *sk)
 	if (!bpf_check_basics_ok(fprog->filter, fprog->len))
 		return ERR_PTR(-EINVAL);
 
-	prog = bpf_prog_alloc(bpf_prog_size(fprog->len), 0);
+	prog = bpf_prog_alloc(bpf_prog_size(fprog->len), 0, false);
 	if (!prog)
 		return ERR_PTR(-ENOMEM);
 
-- 
2.9.3
