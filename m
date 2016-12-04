From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 3/3] bpf: add prog_digest and expose it via fdinfo/netlink
Date: Sun,  4 Dec 2016 23:19:41 +0100
Message-ID: <7ecb27155763e91529bc94ee60e35d6ac94b9469.1480889473.git.daniel@iogearbox.net>
References: <cover.1480889473.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40046 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751241AbcLDWTp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 17:19:45 -0500
In-Reply-To: <cover.1480889473.git.daniel@iogearbox.net>
In-Reply-To: <cover.1480889473.git.daniel@iogearbox.net>
References: <cover.1480889473.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When loading a BPF program via bpf(2), calculate the digest over
the program's instruction stream and store it in struct bpf_prog's
digest member. This is done at a point in time before any instructions
are rewritten by the verifier. Any unstable map file descriptor
number part of the imm field will be zeroed for the hash.

fdinfo example output for progs:

  # cat /proc/1590/fdinfo/5
  pos:          0
  flags:        02000002
  mnt_id:       11
  prog_type:    1
  prog_jited:   1
  prog_digest:  b27e8b06da22707513aa97363dfb11c7c3675d28
  memlock:      4096

When programs are pinned and retrieved by an ELF loader, the loader
can check the program's digest through fdinfo and compare it against
one that was generated over the ELF file's program section to see
if the program needs to be reloaded. Furthermore, this can also be
exposed through other means such as netlink in case of a tc cls/act
dump (or xdp in future), but also through tracepoints or other
facilities to identify the program. Other than that, the digest can
also serve as a base name for the work in progress kallsyms support
of programs. The digest doesn't depend/select the crypto layer, since
we need to keep dependencies to a minimum. iproute2 will get support
for this facility.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/bpf.h                |  1 +
 include/linux/filter.h             |  7 +++-
 include/uapi/linux/pkt_cls.h       |  1 +
 include/uapi/linux/tc_act/tc_bpf.h |  1 +
 kernel/bpf/core.c                  | 65 ++++++++++++++++++++++++++++++++++++++
 kernel/bpf/syscall.c               | 24 +++++++++++++-
 kernel/bpf/verifier.c              |  2 ++
 net/sched/act_bpf.c                |  9 ++++++
 net/sched/cls_bpf.c                |  8 +++++
 9 files changed, 116 insertions(+), 2 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 69d0a7f..8796ff0 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -216,6 +216,7 @@ struct bpf_event_entry {
 u64 bpf_get_stackid(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
 
 bool bpf_prog_array_compatible(struct bpf_array *array, const struct bpf_prog *fp);
+void bpf_prog_calc_digest(struct bpf_prog *fp);
 
 const struct bpf_func_proto *bpf_get_trace_printk_proto(void);
 
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 9733813..f078d2b 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -14,6 +14,7 @@
 #include <linux/workqueue.h>
 #include <linux/sched.h>
 #include <linux/capability.h>
+#include <linux/cryptohash.h>
 
 #include <net/sch_generic.h>
 
@@ -56,6 +57,9 @@
 /* BPF program can access up to 512 bytes of stack space. */
 #define MAX_BPF_STACK	512
 
+/* Maximum BPF program size in bytes. */
+#define MAX_BPF_SIZE	(BPF_MAXINSNS * sizeof(struct bpf_insn))
+
 /* Helper macros for filter block array initializers. */
 
 /* ALU ops on registers, bpf_add|sub|...: dst_reg += src_reg */
@@ -404,8 +408,9 @@ struct bpf_prog {
 				cb_access:1,	/* Is control block accessed? */
 				dst_needed:1;	/* Do we need dst entry? */
 	kmemcheck_bitfield_end(meta);
-	u32			len;		/* Number of filter blocks */
 	enum bpf_prog_type	type;		/* Type of BPF program */
+	u32			len;		/* Number of filter blocks */
+	u32			digest[SHA_DIGEST_WORDS]; /* Program digest */
 	struct bpf_prog_aux	*aux;		/* Auxiliary fields */
 	struct sock_fprog_kern	*orig_prog;	/* Original BPF program */
 	unsigned int		(*bpf_func)(const void *ctx,
diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index 86786d4..1adc0b6 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -397,6 +397,7 @@ enum {
 	TCA_BPF_NAME,
 	TCA_BPF_FLAGS,
 	TCA_BPF_FLAGS_GEN,
+	TCA_BPF_DIGEST,
 	__TCA_BPF_MAX,
 };
 
diff --git a/include/uapi/linux/tc_act/tc_bpf.h b/include/uapi/linux/tc_act/tc_bpf.h
index 063d9d4..a6b88a6 100644
--- a/include/uapi/linux/tc_act/tc_bpf.h
+++ b/include/uapi/linux/tc_act/tc_bpf.h
@@ -27,6 +27,7 @@ enum {
 	TCA_ACT_BPF_FD,
 	TCA_ACT_BPF_NAME,
 	TCA_ACT_BPF_PAD,
+	TCA_ACT_BPF_DIGEST,
 	__TCA_ACT_BPF_MAX,
 };
 #define TCA_ACT_BPF_MAX (__TCA_ACT_BPF_MAX - 1)
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 82a0414..bdcc9f4 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -136,6 +136,71 @@ void __bpf_prog_free(struct bpf_prog *fp)
 	vfree(fp);
 }
 
+#define SHA_BPF_RAW_SIZE						\
+	round_up(MAX_BPF_SIZE + sizeof(__be64) + 1, SHA_MESSAGE_BYTES)
+
+/* Called under verifier mutex. */
+void bpf_prog_calc_digest(struct bpf_prog *fp)
+{
+	const u32 bits_offset = SHA_MESSAGE_BYTES - sizeof(__be64);
+	static u32 ws[SHA_WORKSPACE_WORDS];
+	static u8 raw[SHA_BPF_RAW_SIZE];
+	struct bpf_insn *dst = (void *)raw;
+	u32 i, bsize, psize, blocks;
+	bool was_ld_map;
+	u8 *todo = raw;
+	__be32 *result;
+	__be64 *bits;
+
+	sha_init(fp->digest);
+	memset(ws, 0, sizeof(ws));
+
+	/* We need to take out the map fd for the digest calculation
+	 * since they are unstable from user space side.
+	 */
+	for (i = 0, was_ld_map = false; i < fp->len; i++) {
+		dst[i] = fp->insnsi[i];
+		if (!was_ld_map &&
+		    dst[i].code == (BPF_LD | BPF_IMM | BPF_DW) &&
+		    dst[i].src_reg == BPF_PSEUDO_MAP_FD) {
+			was_ld_map = true;
+			dst[i].imm = 0;
+		} else if (was_ld_map &&
+			   dst[i].code == 0 &&
+			   dst[i].dst_reg == 0 &&
+			   dst[i].src_reg == 0 &&
+			   dst[i].off == 0) {
+			was_ld_map = false;
+			dst[i].imm = 0;
+		} else {
+			was_ld_map = false;
+		}
+	}
+
+	psize = fp->len * sizeof(struct bpf_insn);
+	memset(&raw[psize], 0, sizeof(raw) - psize);
+	raw[psize++] = 0x80;
+
+	bsize  = round_up(psize, SHA_MESSAGE_BYTES);
+	blocks = bsize / SHA_MESSAGE_BYTES;
+	if (bsize - psize >= sizeof(__be64)) {
+		bits = (__be64 *)(todo + bsize - sizeof(__be64));
+	} else {
+		bits = (__be64 *)(todo + bsize + bits_offset);
+		blocks++;
+	}
+	*bits = cpu_to_be64((psize - 1) << 3);
+
+	while (blocks--) {
+		sha_transform(fp->digest, todo, ws);
+		todo += SHA_MESSAGE_BYTES;
+	}
+
+	result = (__force __be32 *)fp->digest;
+	for (i = 0; i < SHA_DIGEST_WORDS; i++)
+		result[i] = cpu_to_be32(fp->digest[i]);
+}
+
 static bool bpf_is_jmp_and_has_target(const struct bpf_insn *insn)
 {
 	return BPF_CLASS(insn->code) == BPF_JMP  &&
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 85af86c..c0d2b42 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -662,8 +662,30 @@ static int bpf_prog_release(struct inode *inode, struct file *filp)
 	return 0;
 }
 
+#ifdef CONFIG_PROC_FS
+static void bpf_prog_show_fdinfo(struct seq_file *m, struct file *filp)
+{
+	const struct bpf_prog *prog = filp->private_data;
+	char prog_digest[sizeof(prog->digest) * 2 + 1] = { };
+
+	bin2hex(prog_digest, prog->digest, sizeof(prog->digest));
+	seq_printf(m,
+		   "prog_type:\t%u\n"
+		   "prog_jited:\t%u\n"
+		   "prog_digest:\t%s\n"
+		   "memlock:\t%llu\n",
+		   prog->type,
+		   prog->jited,
+		   prog_digest,
+		   prog->pages * 1ULL << PAGE_SHIFT);
+}
+#endif
+
 static const struct file_operations bpf_prog_fops = {
-        .release = bpf_prog_release,
+#ifdef CONFIG_PROC_FS
+	.show_fdinfo	= bpf_prog_show_fdinfo,
+#endif
+	.release	= bpf_prog_release,
 };
 
 int bpf_prog_new_fd(struct bpf_prog *prog)
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 0e74221..16ad38b 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -3171,6 +3171,8 @@ int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
 		log_level = 0;
 	}
 
+	bpf_prog_calc_digest(env->prog);
+
 	ret = replace_map_fd_with_map_ptr(env);
 	if (ret < 0)
 		goto skip_full_check;
diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
index 84c1d2d..1c60317 100644
--- a/net/sched/act_bpf.c
+++ b/net/sched/act_bpf.c
@@ -117,10 +117,19 @@ static int tcf_bpf_dump_bpf_info(const struct tcf_bpf *prog,
 static int tcf_bpf_dump_ebpf_info(const struct tcf_bpf *prog,
 				  struct sk_buff *skb)
 {
+	struct nlattr *nla;
+
 	if (prog->bpf_name &&
 	    nla_put_string(skb, TCA_ACT_BPF_NAME, prog->bpf_name))
 		return -EMSGSIZE;
 
+	nla = nla_reserve(skb, TCA_ACT_BPF_DIGEST,
+			  sizeof(prog->filter->digest));
+	if (nla == NULL)
+		return -EMSGSIZE;
+
+	memcpy(nla_data(nla), prog->filter->digest, nla_len(nla));
+
 	return 0;
 }
 
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index f70e03d..adc7760 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -549,10 +549,18 @@ static int cls_bpf_dump_bpf_info(const struct cls_bpf_prog *prog,
 static int cls_bpf_dump_ebpf_info(const struct cls_bpf_prog *prog,
 				  struct sk_buff *skb)
 {
+	struct nlattr *nla;
+
 	if (prog->bpf_name &&
 	    nla_put_string(skb, TCA_BPF_NAME, prog->bpf_name))
 		return -EMSGSIZE;
 
+	nla = nla_reserve(skb, TCA_BPF_DIGEST, sizeof(prog->filter->digest));
+	if (nla == NULL)
+		return -EMSGSIZE;
+
+	memcpy(nla_data(nla), prog->filter->digest, nla_len(nla));
+
 	return 0;
 }
 
-- 
1.9.3
