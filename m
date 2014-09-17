From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v13 net-next 04/11] bpf: expand BPF syscall with program load/unload
Date: Tue, 16 Sep 2014 17:39:23 -0700
Message-ID: <1410914370-29883-5-git-send-email-ast@plumgrid.com>
References: <1410914370-29883-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1410914370-29883-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

eBPF programs are similar to kernel modules. They are loaded by the user
process and automatically unloaded when process exits. Each eBPF program is
a safe run-to-completion set of instructions. eBPF verifier statically
determines that the program terminates and is safe to execute.

The following syscall wrapper can be used to load the program:
int bpf_prog_load(enum bpf_prog_type prog_type,
                  const struct bpf_insn *insns, int insn_cnt,
                  const char *license)
{
    union bpf_attr attr = {
        .prog_type = prog_type,
        .insns = ptr_to_u64(insns),
        .insn_cnt = insn_cnt,
        .license = ptr_to_u64(license),
    };

    return bpf(BPF_PROG_LOAD, &attr, sizeof(attr));
}
where 'insns' is an array of eBPF instructions and 'license' is a string
that must be GPL compatible to call helper functions marked gpl_only

Upon succesful load the syscall returns prog_fd.
Use close(prog_fd) to unload the program.

User space tests and examples follow in the later patches

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/linux/bpf.h      |   38 +++++++++++
 include/linux/filter.h   |    8 +--
 include/uapi/linux/bpf.h |   26 ++++++++
 kernel/bpf/core.c        |   29 ++++----
 kernel/bpf/syscall.c     |  165 ++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 246 insertions(+), 20 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 2887f3f9da59..92979182be81 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -46,4 +46,42 @@ void bpf_register_map_type(struct bpf_map_type_list *tl);
 void bpf_map_put(struct bpf_map *map);
 struct bpf_map *bpf_map_get(struct fd f);
 
+/* eBPF function prototype used by verifier to allow BPF_CALLs from eBPF programs
+ * to in-kernel helper functions and for adjusting imm32 field in BPF_CALL
+ * instructions after verifying
+ */
+struct bpf_func_proto {
+	u64 (*func)(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
+	bool gpl_only;
+};
+
+struct bpf_verifier_ops {
+	/* return eBPF function prototype for verification */
+	const struct bpf_func_proto *(*get_func_proto)(enum bpf_func_id func_id);
+};
+
+struct bpf_prog_type_list {
+	struct list_head list_node;
+	struct bpf_verifier_ops *ops;
+	enum bpf_prog_type type;
+};
+
+void bpf_register_prog_type(struct bpf_prog_type_list *tl);
+
+struct bpf_prog;
+
+struct bpf_prog_aux {
+	atomic_t refcnt;
+	bool is_gpl_compatible;
+	enum bpf_prog_type prog_type;
+	struct bpf_verifier_ops *ops;
+	struct bpf_map **used_maps;
+	u32 used_map_cnt;
+	struct bpf_prog *prog;
+	struct work_struct work;
+};
+
+void bpf_prog_put(struct bpf_prog *prog);
+struct bpf_prog *bpf_prog_get(u32 ufd);
+
 #endif /* _LINUX_BPF_H */
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 1a0bc6d134d7..4ffc0958d85e 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -21,6 +21,7 @@
 struct sk_buff;
 struct sock;
 struct seccomp_data;
+struct bpf_prog_aux;
 
 /* ArgX, context and stack frame pointer register positions. Note,
  * Arg1, Arg2, Arg3, etc are used as argument mappings of function
@@ -300,17 +301,12 @@ struct bpf_binary_header {
 	u8 image[];
 };
 
-struct bpf_work_struct {
-	struct bpf_prog *prog;
-	struct work_struct work;
-};
-
 struct bpf_prog {
 	u16			pages;		/* Number of allocated pages */
 	bool			jited;		/* Is our filter JIT'ed? */
 	u32			len;		/* Number of filter blocks */
 	struct sock_fprog_kern	*orig_prog;	/* Original BPF program */
-	struct bpf_work_struct	*work;		/* Deferred free work struct */
+	struct bpf_prog_aux	*aux;		/* Auxiliary fields */
 	unsigned int		(*bpf_func)(const struct sk_buff *skb,
 					    const struct bpf_insn *filter);
 	/* Instructions for interpreter */
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 395cabd2ca0a..424f442016e7 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -99,12 +99,23 @@ enum bpf_cmd {
 	 * returns zero and stores next key or negative error
 	 */
 	BPF_MAP_GET_NEXT_KEY,
+
+	/* verify and load eBPF program
+	 * prog_fd = bpf(BPF_PROG_LOAD, union bpf_attr *attr, u32 size)
+	 * Using attr->prog_type, attr->insns, attr->license
+	 * returns fd or negative error
+	 */
+	BPF_PROG_LOAD,
 };
 
 enum bpf_map_type {
 	BPF_MAP_TYPE_UNSPEC,
 };
 
+enum bpf_prog_type {
+	BPF_PROG_TYPE_UNSPEC,
+};
+
 union bpf_attr {
 	struct { /* anonymous struct used by BPF_MAP_CREATE command */
 		__u32	map_type;	/* one of enum bpf_map_type */
@@ -121,6 +132,21 @@ union bpf_attr {
 			__aligned_u64 next_key;
 		};
 	};
+
+	struct { /* anonymous struct used by BPF_PROG_LOAD command */
+		__u32		prog_type;	/* one of enum bpf_prog_type */
+		__u32		insn_cnt;
+		__aligned_u64	insns;
+		__aligned_u64	license;
+	};
 } __attribute__((aligned(8)));
 
+/* integer value in 'imm' field of BPF_CALL instruction selects which helper
+ * function eBPF program intends to call
+ */
+enum bpf_func_id {
+	BPF_FUNC_unspec,
+	__BPF_FUNC_MAX_ID,
+};
+
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 8b7002488251..f0c30c59b317 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -27,6 +27,7 @@
 #include <linux/random.h>
 #include <linux/moduleloader.h>
 #include <asm/unaligned.h>
+#include <linux/bpf.h>
 
 /* Registers */
 #define BPF_R0	regs[BPF_REG_0]
@@ -71,7 +72,7 @@ struct bpf_prog *bpf_prog_alloc(unsigned int size, gfp_t gfp_extra_flags)
 {
 	gfp_t gfp_flags = GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO |
 			  gfp_extra_flags;
-	struct bpf_work_struct *ws;
+	struct bpf_prog_aux *aux;
 	struct bpf_prog *fp;
 
 	size = round_up(size, PAGE_SIZE);
@@ -79,14 +80,14 @@ struct bpf_prog *bpf_prog_alloc(unsigned int size, gfp_t gfp_extra_flags)
 	if (fp == NULL)
 		return NULL;
 
-	ws = kmalloc(sizeof(*ws), GFP_KERNEL | gfp_extra_flags);
-	if (ws == NULL) {
+	aux = kzalloc(sizeof(*aux), GFP_KERNEL | gfp_extra_flags);
+	if (aux == NULL) {
 		vfree(fp);
 		return NULL;
 	}
 
 	fp->pages = size / PAGE_SIZE;
-	fp->work = ws;
+	fp->aux = aux;
 
 	return fp;
 }
@@ -110,10 +111,10 @@ struct bpf_prog *bpf_prog_realloc(struct bpf_prog *fp_old, unsigned int size,
 		memcpy(fp, fp_old, fp_old->pages * PAGE_SIZE);
 		fp->pages = size / PAGE_SIZE;
 
-		/* We keep fp->work from fp_old around in the new
+		/* We keep fp->aux from fp_old around in the new
 		 * reallocated structure.
 		 */
-		fp_old->work = NULL;
+		fp_old->aux = NULL;
 		__bpf_prog_free(fp_old);
 	}
 
@@ -123,7 +124,7 @@ EXPORT_SYMBOL_GPL(bpf_prog_realloc);
 
 void __bpf_prog_free(struct bpf_prog *fp)
 {
-	kfree(fp->work);
+	kfree(fp->aux);
 	vfree(fp);
 }
 EXPORT_SYMBOL_GPL(__bpf_prog_free);
@@ -638,19 +639,19 @@ EXPORT_SYMBOL_GPL(bpf_prog_select_runtime);
 
 static void bpf_prog_free_deferred(struct work_struct *work)
 {
-	struct bpf_work_struct *ws;
+	struct bpf_prog_aux *aux;
 
-	ws = container_of(work, struct bpf_work_struct, work);
-	bpf_jit_free(ws->prog);
+	aux = container_of(work, struct bpf_prog_aux, work);
+	bpf_jit_free(aux->prog);
 }
 
 /* Free internal BPF program */
 void bpf_prog_free(struct bpf_prog *fp)
 {
-	struct bpf_work_struct *ws = fp->work;
+	struct bpf_prog_aux *aux = fp->aux;
 
-	INIT_WORK(&ws->work, bpf_prog_free_deferred);
-	ws->prog = fp;
-	schedule_work(&ws->work);
+	INIT_WORK(&aux->work, bpf_prog_free_deferred);
+	aux->prog = fp;
+	schedule_work(&aux->work);
 }
 EXPORT_SYMBOL_GPL(bpf_prog_free);
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index d2d6491c21b5..a5b5c7ca0264 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -14,6 +14,8 @@
 #include <linux/slab.h>
 #include <linux/anon_inodes.h>
 #include <linux/file.h>
+#include <linux/license.h>
+#include <linux/filter.h>
 
 static LIST_HEAD(bpf_map_types);
 
@@ -334,6 +336,166 @@ err_put:
 	return err;
 }
 
+static LIST_HEAD(bpf_prog_types);
+
+static int find_prog_type(enum bpf_prog_type type, struct bpf_prog *prog)
+{
+	struct bpf_prog_type_list *tl;
+
+	list_for_each_entry(tl, &bpf_prog_types, list_node) {
+		if (tl->type == type) {
+			prog->aux->ops = tl->ops;
+			prog->aux->prog_type = type;
+			return 0;
+		}
+	}
+	return -EINVAL;
+}
+
+void bpf_register_prog_type(struct bpf_prog_type_list *tl)
+{
+	list_add(&tl->list_node, &bpf_prog_types);
+}
+
+/* drop refcnt on maps used by eBPF program and free auxilary data */
+static void free_used_maps(struct bpf_prog_aux *aux)
+{
+	int i;
+
+	for (i = 0; i < aux->used_map_cnt; i++)
+		bpf_map_put(aux->used_maps[i]);
+
+	kfree(aux->used_maps);
+}
+
+void bpf_prog_put(struct bpf_prog *prog)
+{
+	if (atomic_dec_and_test(&prog->aux->refcnt)) {
+		free_used_maps(prog->aux);
+		bpf_prog_free(prog);
+	}
+}
+
+static int bpf_prog_release(struct inode *inode, struct file *filp)
+{
+	struct bpf_prog *prog = filp->private_data;
+
+	bpf_prog_put(prog);
+	return 0;
+}
+
+static const struct file_operations bpf_prog_fops = {
+        .release = bpf_prog_release,
+};
+
+static struct bpf_prog *get_prog(struct fd f)
+{
+	struct bpf_prog *prog;
+
+	if (!f.file)
+		return ERR_PTR(-EBADF);
+
+	if (f.file->f_op != &bpf_prog_fops) {
+		fdput(f);
+		return ERR_PTR(-EINVAL);
+	}
+
+	prog = f.file->private_data;
+
+	return prog;
+}
+
+/* called by sockets/tracing/seccomp before attaching program to an event
+ * pairs with bpf_prog_put()
+ */
+struct bpf_prog *bpf_prog_get(u32 ufd)
+{
+	struct fd f = fdget(ufd);
+	struct bpf_prog *prog;
+
+	prog = get_prog(f);
+
+	if (IS_ERR(prog))
+		return prog;
+
+	atomic_inc(&prog->aux->refcnt);
+	fdput(f);
+	return prog;
+}
+
+/* last field in 'union bpf_attr' used by this command */
+#define	BPF_PROG_LOAD_LAST_FIELD license
+
+static int bpf_prog_load(union bpf_attr *attr)
+{
+	enum bpf_prog_type type = attr->prog_type;
+	struct bpf_prog *prog;
+	int err;
+	char license[128];
+	bool is_gpl;
+
+	if (CHECK_ATTR(BPF_PROG_LOAD))
+		return -EINVAL;
+
+	/* copy eBPF program license from user space */
+	if (strncpy_from_user(license, u64_to_ptr(attr->license),
+			      sizeof(license) - 1) < 0)
+		return -EFAULT;
+	license[sizeof(license) - 1] = 0;
+
+	/* eBPF programs must be GPL compatible to use GPL-ed functions */
+	is_gpl = license_is_gpl_compatible(license);
+
+	if (attr->insn_cnt >= BPF_MAXINSNS)
+		return -EINVAL;
+
+	/* plain bpf_prog allocation */
+	prog = bpf_prog_alloc(bpf_prog_size(attr->insn_cnt), GFP_USER);
+	if (!prog)
+		return -ENOMEM;
+
+	prog->len = attr->insn_cnt;
+
+	err = -EFAULT;
+	if (copy_from_user(prog->insns, u64_to_ptr(attr->insns),
+			   prog->len * sizeof(struct bpf_insn)) != 0)
+		goto free_prog;
+
+	prog->orig_prog = NULL;
+	prog->jited = false;
+
+	atomic_set(&prog->aux->refcnt, 1);
+	prog->aux->is_gpl_compatible = is_gpl;
+
+	/* find program type: socket_filter vs tracing_filter */
+	err = find_prog_type(type, prog);
+	if (err < 0)
+		goto free_prog;
+
+	/* run eBPF verifier */
+	/* err = bpf_check(prog, tb); */
+
+	if (err < 0)
+		goto free_used_maps;
+
+	/* eBPF program is ready to be JITed */
+	bpf_prog_select_runtime(prog);
+
+	err = anon_inode_getfd("bpf-prog", &bpf_prog_fops, prog, O_RDWR | O_CLOEXEC);
+
+	if (err < 0)
+		/* failed to allocate fd */
+		goto free_used_maps;
+
+	return err;
+
+free_used_maps:
+	free_used_maps(prog->aux);
+free_prog:
+	bpf_prog_free(prog);
+	return err;
+}
+
 SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, size)
 {
 	union bpf_attr attr = {};
@@ -370,6 +532,9 @@ SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, siz
 	case BPF_MAP_GET_NEXT_KEY:
 		err = map_get_next_key(&attr);
 		break;
+	case BPF_PROG_LOAD:
+		err = bpf_prog_load(&attr);
+		break;
 	default:
 		err = -EINVAL;
 		break;
-- 
1.7.9.5
