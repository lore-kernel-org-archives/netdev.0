From: David Miller <davem@davemloft.net>
Subject: [PATCH v2 3/7] bpf: Add strict alignment flag for BPF_PROG_LOAD.
Date: Thu, 11 May 2017 12:05:40 -0400 (EDT)
Message-ID: <20170511.120540.405652687533650995.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51554 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933695AbdEKQFm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 12:05:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Add a new field, "prog_flags", and an initial flag value
BPF_F_STRCIT_ALIGNMENT.

When set, the verifier will enforce strict pointer alignment
regardless of the setting of CONFIG_EFFICIENT_UNALIGNED_ACCESS.

The verifier, in this mode, will also use a fixed value of "2" in
place of NET_IP_ALIGN.

This facilitates test cases that will exercise and validate this part
of the verifier even when run on architectures where alignment doesn't
matter.

Signed-off-by: David S. Miller <davem@davemloft.net>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/bpf_verifier.h   |  1 +
 include/uapi/linux/bpf.h       |  8 ++++++++
 kernel/bpf/syscall.c           |  5 ++++-
 kernel/bpf/verifier.c          | 23 +++++++++++++++++------
 tools/build/feature/test-bpf.c |  1 +
 tools/include/uapi/linux/bpf.h | 11 +++++++++--
 6 files changed, 40 insertions(+), 9 deletions(-)

diff --git a/include/linux/bpf_verifier.h b/include/linux/bpf_verifier.h
index 7c6a519..d5093b5 100644
--- a/include/linux/bpf_verifier.h
+++ b/include/linux/bpf_verifier.h
@@ -90,6 +90,7 @@ struct bpf_verifier_env {
 	struct bpf_prog *prog;		/* eBPF program being verified */
 	struct bpf_verifier_stack_elem *head; /* stack of verifier states to be processed */
 	int stack_size;			/* number of states to be processed */
+	bool strict_alignment;		/* perform strict pointer alignment checks */
 	struct bpf_verifier_state cur_state; /* current verifier state */
 	struct bpf_verifier_state_list **explored_states; /* search pruning optimization */
 	const struct bpf_ext_analyzer_ops *analyzer_ops; /* external analyzer ops */
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 945a1f5..94dfa9d 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -132,6 +132,13 @@ enum bpf_attach_type {
  */
 #define BPF_F_ALLOW_OVERRIDE	(1U << 0)
 
+/* If BPF_F_STRICT_ALIGNMENT is used in BPF_PROG_LOAD command, the
+ * verifier will perform strict alignment checking as if the kernel
+ * has been built with CONFIG_EFFICIENT_UNALIGNED_ACCESS not set,
+ * and NET_IP_ALIGN defined to 2.
+ */
+#define BPF_F_STRICT_ALIGNMENT	(1U << 0)
+
 #define BPF_PSEUDO_MAP_FD	1
 
 /* flags for BPF_MAP_UPDATE_ELEM command */
@@ -177,6 +184,7 @@ union bpf_attr {
 		__u32		log_size;	/* size of user buffer */
 		__aligned_u64	log_buf;	/* user supplied buffer */
 		__u32		kern_version;	/* checked when prog_type=kprobe */
+		__u32		prog_flags;
 	};
 
 	struct { /* anonymous struct used by BPF_OBJ_* commands */
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index fd2411f..265a0d8 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -783,7 +783,7 @@ struct bpf_prog *bpf_prog_get_type(u32 ufd, enum bpf_prog_type type)
 EXPORT_SYMBOL_GPL(bpf_prog_get_type);
 
 /* last field in 'union bpf_attr' used by this command */
-#define	BPF_PROG_LOAD_LAST_FIELD kern_version
+#define	BPF_PROG_LOAD_LAST_FIELD prog_flags
 
 static int bpf_prog_load(union bpf_attr *attr)
 {
@@ -796,6 +796,9 @@ static int bpf_prog_load(union bpf_attr *attr)
 	if (CHECK_ATTR(BPF_PROG_LOAD))
 		return -EINVAL;
 
+	if (attr->prog_flags & ~BPF_F_STRICT_ALIGNMENT)
+		return -EINVAL;
+
 	/* copy eBPF program license from user space */
 	if (strncpy_from_user(license, u64_to_user_ptr(attr->license),
 			      sizeof(license) - 1) < 0)
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index ff2bfe1..e74fb1b 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -791,6 +791,7 @@ static bool is_pointer_value(struct bpf_verifier_env *env, int regno)
 static int check_pkt_ptr_alignment(const struct bpf_reg_state *reg,
 				   int off, int size, bool strict)
 {
+	int ip_align;
 	int reg_off;
 
 	/* Byte size accesses are always allowed. */
@@ -807,10 +808,14 @@ static int check_pkt_ptr_alignment(const struct bpf_reg_state *reg,
 		reg_off += reg->aux_off;
 	}
 
-	/* skb->data is NET_IP_ALIGN-ed */
-	if ((NET_IP_ALIGN + reg_off + off) % size != 0) {
+	/* skb->data is NET_IP_ALIGN-ed, but for strict alignment checking
+	 * we force this to 2 which is universally what architectures use
+	 * when they don't set CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS.
+	 */
+	ip_align = strict ? 2 : NET_IP_ALIGN;
+	if ((ip_align + reg_off + off) % size != 0) {
 		verbose("misaligned packet access off %d+%d+%d size %d\n",
-			NET_IP_ALIGN, reg_off, off, size);
+			ip_align, reg_off, off, size);
 		return -EACCES;
 	}
 
@@ -828,10 +833,11 @@ static int check_val_ptr_alignment(const struct bpf_reg_state *reg,
 	return 0;
 }
 
-static int check_ptr_alignment(const struct bpf_reg_state *reg,
+static int check_ptr_alignment(struct bpf_verifier_env *env,
+			       const struct bpf_reg_state *reg,
 			       int off, int size)
 {
-	bool strict = false;
+	bool strict = env->strict_alignment;
 
 	if (!IS_ENABLED(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS))
 		strict = true;
@@ -873,7 +879,7 @@ static int check_mem_access(struct bpf_verifier_env *env, u32 regno, int off,
 	if (size < 0)
 		return size;
 
-	err = check_ptr_alignment(reg, off, size);
+	err = check_ptr_alignment(env, reg, off, size);
 	if (err)
 		return err;
 
@@ -3568,6 +3574,10 @@ int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
 	} else {
 		log_level = 0;
 	}
+	if (attr->prog_flags & BPF_F_STRICT_ALIGNMENT)
+		env->strict_alignment = true;
+	else
+		env->strict_alignment = false;
 
 	ret = replace_map_fd_with_map_ptr(env);
 	if (ret < 0)
@@ -3673,6 +3683,7 @@ int bpf_analyzer(struct bpf_prog *prog, const struct bpf_ext_analyzer_ops *ops,
 	mutex_lock(&bpf_verifier_lock);
 
 	log_level = 0;
+	env->strict_alignment = false;
 
 	env->explored_states = kcalloc(env->prog->len,
 				       sizeof(struct bpf_verifier_state_list *),
diff --git a/tools/build/feature/test-bpf.c b/tools/build/feature/test-bpf.c
index ebc6dce..7598361 100644
--- a/tools/build/feature/test-bpf.c
+++ b/tools/build/feature/test-bpf.c
@@ -29,6 +29,7 @@ int main(void)
 	attr.log_size = 0;
 	attr.log_level = 0;
 	attr.kern_version = 0;
+	attr.prog_flags = 0;
 
 	/*
 	 * Test existence of __NR_bpf and BPF_PROG_LOAD.
diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index e553529..94dfa9d 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -132,6 +132,13 @@ enum bpf_attach_type {
  */
 #define BPF_F_ALLOW_OVERRIDE	(1U << 0)
 
+/* If BPF_F_STRICT_ALIGNMENT is used in BPF_PROG_LOAD command, the
+ * verifier will perform strict alignment checking as if the kernel
+ * has been built with CONFIG_EFFICIENT_UNALIGNED_ACCESS not set,
+ * and NET_IP_ALIGN defined to 2.
+ */
+#define BPF_F_STRICT_ALIGNMENT	(1U << 0)
+
 #define BPF_PSEUDO_MAP_FD	1
 
 /* flags for BPF_MAP_UPDATE_ELEM command */
@@ -177,6 +184,7 @@ union bpf_attr {
 		__u32		log_size;	/* size of user buffer */
 		__aligned_u64	log_buf;	/* user supplied buffer */
 		__u32		kern_version;	/* checked when prog_type=kprobe */
+		__u32		prog_flags;
 	};
 
 	struct { /* anonymous struct used by BPF_OBJ_* commands */
@@ -481,8 +489,7 @@ union bpf_attr {
  * u32 bpf_get_socket_uid(skb)
  *     Get the owner uid of the socket stored inside sk_buff.
  *     @skb: pointer to skb
- *     Return: uid of the socket owner on success or 0 if the socket pointer
- *     inside sk_buff is NULL
+ *     Return: uid of the socket owner on success or overflowuid if failed.
  */
 #define __BPF_FUNC_MAPPER(FN)		\
 	FN(unspec),			\
-- 
2.7.4
