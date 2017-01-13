From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] bpf: rework prog_digest into prog_tag
Date: Fri, 13 Jan 2017 23:38:15 +0100
Message-ID: <384476e29f6a378766c4052187b9b5f840f4030e.1484346362.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, luto@kernel.org,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46741 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751232AbdAMWiW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 17:38:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 7bd509e311f4 ("bpf: add prog_digest and expose it via
fdinfo/netlink") was recently discussed, partially due to
admittedly suboptimal name of "prog_digest" in combination
with sha1 hash usage, thus inevitably and rightfully concerns
about its security in terms of collision resistance were
raised with regards to use-cases.

The intended use cases are for debugging resp. introspection
only for providing a stable "tag" over the instruction sequence
that both kernel and user space can calculate independently.
It's not usable at all for making a security relevant decision.
So collisions where two different instruction sequences generate
the same tag can happen, but ideally at a rather low rate. The
"tag" will be dumped in hex and is short enough to introspect
in tracepoints or kallsyms output along with other data such
as stack trace, etc. Thus, this patch performs a rename into
prog_tag and truncates the tag to a short output (64 bits) to
make it obvious it's not collision-free.

Should in future a hash or facility be needed with a security
relevant focus, then we can think about requirements, constraints,
etc that would fit to that situation. For now, rework the exposed
parts for the current use cases as long as nothing has been
released yet. Tested on x86_64 and s390x.

Fixes: 7bd509e311f4 ("bpf: add prog_digest and expose it via fdinfo/netlink")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
Cc: Andy Lutomirski <luto@kernel.org>
---
 include/linux/bpf.h                |  2 +-
 include/linux/filter.h             |  6 ++++--
 include/uapi/linux/pkt_cls.h       |  2 +-
 include/uapi/linux/tc_act/tc_bpf.h |  2 +-
 kernel/bpf/core.c                  | 14 ++++++++------
 kernel/bpf/syscall.c               |  8 ++++----
 kernel/bpf/verifier.c              |  2 +-
 net/sched/act_bpf.c                |  5 ++---
 net/sched/cls_bpf.c                |  4 ++--
 9 files changed, 24 insertions(+), 21 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index f74ae68..05cf951 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -216,7 +216,7 @@ struct bpf_event_entry {
 u64 bpf_get_stackid(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
 
 bool bpf_prog_array_compatible(struct bpf_array *array, const struct bpf_prog *fp);
-int bpf_prog_calc_digest(struct bpf_prog *fp);
+int bpf_prog_calc_tag(struct bpf_prog *fp);
 
 const struct bpf_func_proto *bpf_get_trace_printk_proto(void);
 
diff --git a/include/linux/filter.h b/include/linux/filter.h
index a0934e6..e4eb254 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -57,6 +57,8 @@
 /* BPF program can access up to 512 bytes of stack space. */
 #define MAX_BPF_STACK	512
 
+#define BPF_TAG_SIZE	8
+
 /* Helper macros for filter block array initializers. */
 
 /* ALU ops on registers, bpf_add|sub|...: dst_reg += src_reg */
@@ -408,7 +410,7 @@ struct bpf_prog {
 	kmemcheck_bitfield_end(meta);
 	enum bpf_prog_type	type;		/* Type of BPF program */
 	u32			len;		/* Number of filter blocks */
-	u32			digest[SHA_DIGEST_WORDS]; /* Program digest */
+	u8			tag[BPF_TAG_SIZE];
 	struct bpf_prog_aux	*aux;		/* Auxiliary fields */
 	struct sock_fprog_kern	*orig_prog;	/* Original BPF program */
 	unsigned int		(*bpf_func)(const void *ctx,
@@ -519,7 +521,7 @@ static inline u32 bpf_prog_insn_size(const struct bpf_prog *prog)
 	return prog->len * sizeof(struct bpf_insn);
 }
 
-static inline u32 bpf_prog_digest_scratch_size(const struct bpf_prog *prog)
+static inline u32 bpf_prog_tag_scratch_size(const struct bpf_prog *prog)
 {
 	return round_up(bpf_prog_insn_size(prog) +
 			sizeof(__be64) + 1, SHA_MESSAGE_BYTES);
diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index cb4bcdc..a4dcd88 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -397,7 +397,7 @@ enum {
 	TCA_BPF_NAME,
 	TCA_BPF_FLAGS,
 	TCA_BPF_FLAGS_GEN,
-	TCA_BPF_DIGEST,
+	TCA_BPF_TAG,
 	__TCA_BPF_MAX,
 };
 
diff --git a/include/uapi/linux/tc_act/tc_bpf.h b/include/uapi/linux/tc_act/tc_bpf.h
index a6b88a6..975b50d 100644
--- a/include/uapi/linux/tc_act/tc_bpf.h
+++ b/include/uapi/linux/tc_act/tc_bpf.h
@@ -27,7 +27,7 @@ enum {
 	TCA_ACT_BPF_FD,
 	TCA_ACT_BPF_NAME,
 	TCA_ACT_BPF_PAD,
-	TCA_ACT_BPF_DIGEST,
+	TCA_ACT_BPF_TAG,
 	__TCA_ACT_BPF_MAX,
 };
 #define TCA_ACT_BPF_MAX (__TCA_ACT_BPF_MAX - 1)
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 1eb4f13..503d421 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -146,10 +146,11 @@ void __bpf_prog_free(struct bpf_prog *fp)
 	vfree(fp);
 }
 
-int bpf_prog_calc_digest(struct bpf_prog *fp)
+int bpf_prog_calc_tag(struct bpf_prog *fp)
 {
 	const u32 bits_offset = SHA_MESSAGE_BYTES - sizeof(__be64);
-	u32 raw_size = bpf_prog_digest_scratch_size(fp);
+	u32 raw_size = bpf_prog_tag_scratch_size(fp);
+	u32 digest[SHA_DIGEST_WORDS];
 	u32 ws[SHA_WORKSPACE_WORDS];
 	u32 i, bsize, psize, blocks;
 	struct bpf_insn *dst;
@@ -162,7 +163,7 @@ int bpf_prog_calc_digest(struct bpf_prog *fp)
 	if (!raw)
 		return -ENOMEM;
 
-	sha_init(fp->digest);
+	sha_init(digest);
 	memset(ws, 0, sizeof(ws));
 
 	/* We need to take out the map fd for the digest calculation
@@ -204,13 +205,14 @@ int bpf_prog_calc_digest(struct bpf_prog *fp)
 	*bits = cpu_to_be64((psize - 1) << 3);
 
 	while (blocks--) {
-		sha_transform(fp->digest, todo, ws);
+		sha_transform(digest, todo, ws);
 		todo += SHA_MESSAGE_BYTES;
 	}
 
-	result = (__force __be32 *)fp->digest;
+	result = (__force __be32 *)digest;
 	for (i = 0; i < SHA_DIGEST_WORDS; i++)
-		result[i] = cpu_to_be32(fp->digest[i]);
+		result[i] = cpu_to_be32(digest[i]);
+	memcpy(fp->tag, result, sizeof(fp->tag));
 
 	vfree(raw);
 	return 0;
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index e89acea..1d6b29e 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -688,17 +688,17 @@ static int bpf_prog_release(struct inode *inode, struct file *filp)
 static void bpf_prog_show_fdinfo(struct seq_file *m, struct file *filp)
 {
 	const struct bpf_prog *prog = filp->private_data;
-	char prog_digest[sizeof(prog->digest) * 2 + 1] = { };
+	char prog_tag[sizeof(prog->tag) * 2 + 1] = { };
 
-	bin2hex(prog_digest, prog->digest, sizeof(prog->digest));
+	bin2hex(prog_tag, prog->tag, sizeof(prog->tag));
 	seq_printf(m,
 		   "prog_type:\t%u\n"
 		   "prog_jited:\t%u\n"
-		   "prog_digest:\t%s\n"
+		   "prog_tag:\t%s\n"
 		   "memlock:\t%llu\n",
 		   prog->type,
 		   prog->jited,
-		   prog_digest,
+		   prog_tag,
 		   prog->pages * 1ULL << PAGE_SHIFT);
 }
 #endif
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 83ed2f8..cdc43b8 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -2936,7 +2936,7 @@ static int replace_map_fd_with_map_ptr(struct bpf_verifier_env *env)
 	int insn_cnt = env->prog->len;
 	int i, j, err;
 
-	err = bpf_prog_calc_digest(env->prog);
+	err = bpf_prog_calc_tag(env->prog);
 	if (err)
 		return err;
 
diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
index 1c60317..520baa41 100644
--- a/net/sched/act_bpf.c
+++ b/net/sched/act_bpf.c
@@ -123,12 +123,11 @@ static int tcf_bpf_dump_ebpf_info(const struct tcf_bpf *prog,
 	    nla_put_string(skb, TCA_ACT_BPF_NAME, prog->bpf_name))
 		return -EMSGSIZE;
 
-	nla = nla_reserve(skb, TCA_ACT_BPF_DIGEST,
-			  sizeof(prog->filter->digest));
+	nla = nla_reserve(skb, TCA_ACT_BPF_TAG, sizeof(prog->filter->tag));
 	if (nla == NULL)
 		return -EMSGSIZE;
 
-	memcpy(nla_data(nla), prog->filter->digest, nla_len(nla));
+	memcpy(nla_data(nla), prog->filter->tag, nla_len(nla));
 
 	return 0;
 }
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index adc7760..d9c9701 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -555,11 +555,11 @@ static int cls_bpf_dump_ebpf_info(const struct cls_bpf_prog *prog,
 	    nla_put_string(skb, TCA_BPF_NAME, prog->bpf_name))
 		return -EMSGSIZE;
 
-	nla = nla_reserve(skb, TCA_BPF_DIGEST, sizeof(prog->filter->digest));
+	nla = nla_reserve(skb, TCA_BPF_TAG, sizeof(prog->filter->tag));
 	if (nla == NULL)
 		return -EMSGSIZE;
 
-	memcpy(nla_data(nla), prog->filter->digest, nla_len(nla));
+	memcpy(nla_data(nla), prog->filter->tag, nla_len(nla));
 
 	return 0;
 }
-- 
1.9.3
