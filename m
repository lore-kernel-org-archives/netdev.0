From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net v2 1/3] bpf: dynamically allocate digest scratch buffer
Date: Sun, 18 Dec 2016 01:52:57 +0100
Message-ID: <7ba3d0babbb2a8dee0a7ae0f1a104570d7a3995f.1482019225.git.daniel@iogearbox.net>
References: <cover.1482019225.git.daniel@iogearbox.net>
Cc: ast@fb.com, kafai@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60748 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754763AbcLRAxQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2016 19:53:16 -0500
In-Reply-To: <cover.1482019225.git.daniel@iogearbox.net>
In-Reply-To: <cover.1482019225.git.daniel@iogearbox.net>
References: <cover.1482019225.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Geert rightfully complained that 7bd509e311f4 ("bpf: add prog_digest
and expose it via fdinfo/netlink") added a too large allocation of
variable 'raw' from bss section, and should instead be done dynamically:

  # ./scripts/bloat-o-meter kernel/bpf/core.o.1 kernel/bpf/core.o.2
  add/remove: 3/0 grow/shrink: 0/0 up/down: 33291/0 (33291)
  function                                     old     new   delta
  raw                                            -   32832  +32832
  [...]

Since this is only relevant during program creation path, which can be
considered slow-path anyway, lets allocate that dynamically and be not
implicitly dependent on verifier mutex. Move bpf_prog_calc_digest() at
the beginning of replace_map_fd_with_map_ptr() and also error handling
stays straight forward.

Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/bpf.h    |  2 +-
 include/linux/filter.h | 14 +++++++++++---
 kernel/bpf/core.c      | 27 ++++++++++++++++-----------
 kernel/bpf/syscall.c   |  2 +-
 kernel/bpf/verifier.c  |  6 ++++--
 5 files changed, 33 insertions(+), 18 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 8796ff0..201eb48 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -216,7 +216,7 @@ struct bpf_event_entry {
 u64 bpf_get_stackid(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
 
 bool bpf_prog_array_compatible(struct bpf_array *array, const struct bpf_prog *fp);
-void bpf_prog_calc_digest(struct bpf_prog *fp);
+int bpf_prog_calc_digest(struct bpf_prog *fp);
 
 const struct bpf_func_proto *bpf_get_trace_printk_proto(void);
 
diff --git a/include/linux/filter.h b/include/linux/filter.h
index af8a180..7023142 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -57,9 +57,6 @@
 /* BPF program can access up to 512 bytes of stack space. */
 #define MAX_BPF_STACK	512
 
-/* Maximum BPF program size in bytes. */
-#define MAX_BPF_SIZE	(BPF_MAXINSNS * sizeof(struct bpf_insn))
-
 /* Helper macros for filter block array initializers. */
 
 /* ALU ops on registers, bpf_add|sub|...: dst_reg += src_reg */
@@ -517,6 +514,17 @@ static __always_inline u32 bpf_prog_run_xdp(const struct bpf_prog *prog,
 	return BPF_PROG_RUN(prog, xdp);
 }
 
+static inline u32 bpf_prog_insn_size(const struct bpf_prog *prog)
+{
+	return prog->len * sizeof(struct bpf_insn);
+}
+
+static inline u32 bpf_prog_digest_scratch_size(const struct bpf_prog *prog)
+{
+	return round_up(bpf_prog_insn_size(prog) +
+			sizeof(__be64) + 1, SHA_MESSAGE_BYTES);
+}
+
 static inline unsigned int bpf_prog_size(unsigned int proglen)
 {
 	return max(sizeof(struct bpf_prog),
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 83e0d15..75c08b8 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -136,28 +136,29 @@ void __bpf_prog_free(struct bpf_prog *fp)
 	vfree(fp);
 }
 
-#define SHA_BPF_RAW_SIZE						\
-	round_up(MAX_BPF_SIZE + sizeof(__be64) + 1, SHA_MESSAGE_BYTES)
-
-/* Called under verifier mutex. */
-void bpf_prog_calc_digest(struct bpf_prog *fp)
+int bpf_prog_calc_digest(struct bpf_prog *fp)
 {
 	const u32 bits_offset = SHA_MESSAGE_BYTES - sizeof(__be64);
-	static u32 ws[SHA_WORKSPACE_WORDS];
-	static u8 raw[SHA_BPF_RAW_SIZE];
-	struct bpf_insn *dst = (void *)raw;
+	u32 raw_size = bpf_prog_digest_scratch_size(fp);
+	u32 ws[SHA_WORKSPACE_WORDS];
 	u32 i, bsize, psize, blocks;
+	struct bpf_insn *dst;
 	bool was_ld_map;
-	u8 *todo = raw;
+	u8 *raw, *todo;
 	__be32 *result;
 	__be64 *bits;
 
+	raw = vmalloc(raw_size);
+	if (!raw)
+		return -ENOMEM;
+
 	sha_init(fp->digest);
 	memset(ws, 0, sizeof(ws));
 
 	/* We need to take out the map fd for the digest calculation
 	 * since they are unstable from user space side.
 	 */
+	dst = (void *)raw;
 	for (i = 0, was_ld_map = false; i < fp->len; i++) {
 		dst[i] = fp->insnsi[i];
 		if (!was_ld_map &&
@@ -177,12 +178,13 @@ void bpf_prog_calc_digest(struct bpf_prog *fp)
 		}
 	}
 
-	psize = fp->len * sizeof(struct bpf_insn);
-	memset(&raw[psize], 0, sizeof(raw) - psize);
+	psize = bpf_prog_insn_size(fp);
+	memset(&raw[psize], 0, raw_size - psize);
 	raw[psize++] = 0x80;
 
 	bsize  = round_up(psize, SHA_MESSAGE_BYTES);
 	blocks = bsize / SHA_MESSAGE_BYTES;
+	todo   = raw;
 	if (bsize - psize >= sizeof(__be64)) {
 		bits = (__be64 *)(todo + bsize - sizeof(__be64));
 	} else {
@@ -199,6 +201,9 @@ void bpf_prog_calc_digest(struct bpf_prog *fp)
 	result = (__force __be32 *)fp->digest;
 	for (i = 0; i < SHA_DIGEST_WORDS; i++)
 		result[i] = cpu_to_be32(fp->digest[i]);
+
+	vfree(raw);
+	return 0;
 }
 
 static bool bpf_is_jmp_and_has_target(const struct bpf_insn *insn)
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 4819ec9..35d674c 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -811,7 +811,7 @@ static int bpf_prog_load(union bpf_attr *attr)
 
 	err = -EFAULT;
 	if (copy_from_user(prog->insns, u64_to_user_ptr(attr->insns),
-			   prog->len * sizeof(struct bpf_insn)) != 0)
+			   bpf_prog_insn_size(prog)) != 0)
 		goto free_prog;
 
 	prog->orig_prog = NULL;
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 81e267b..64b7b1a 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -2931,6 +2931,10 @@ static int replace_map_fd_with_map_ptr(struct bpf_verifier_env *env)
 	int insn_cnt = env->prog->len;
 	int i, j, err;
 
+	err = bpf_prog_calc_digest(env->prog);
+	if (err)
+		return err;
+
 	for (i = 0; i < insn_cnt; i++, insn++) {
 		if (BPF_CLASS(insn->code) == BPF_LDX &&
 		    (BPF_MODE(insn->code) != BPF_MEM || insn->imm != 0)) {
@@ -3178,8 +3182,6 @@ int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
 		log_level = 0;
 	}
 
-	bpf_prog_calc_digest(env->prog);
-
 	ret = replace_map_fd_with_map_ptr(env);
 	if (ret < 0)
 		goto skip_full_check;
-- 
1.9.3
