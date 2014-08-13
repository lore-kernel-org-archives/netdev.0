From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH RFC v4 net-next 11/26] bpf: handle pseudo BPF_LD_IMM64 insn
Date: Wed, 13 Aug 2014 00:57:22 -0700
Message-ID: <1407916658-8731-12-git-send-email-ast@plumgrid.com>
References: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1407916658-8731-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

eBPF programs passed from userspace are using pseudo BPF_LD_IMM64 instructions
to refer to process-local map_fd. Scan the program for such instructions and
if FDs are valid, convert them to 'struct bpf_map' pointers which will be used
by verifier to check access to maps in bpf_map_lookup/update() calls.
If program passes verifier, convert pseudo BPF_LD_IMM64 into generic by dropping
BPF_PSEUDO_MAP_FD flag.

Note that eBPF interpreter is generic and knows nothing about pseudo insns.

Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
---
 include/uapi/linux/bpf.h |   12 ++++
 kernel/bpf/verifier.c    |  146 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 158 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 72bed3950bf1..68822671ab5e 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -169,6 +169,18 @@ enum {
 		.off   = 0,					\
 		.imm   = IMM })
 
+#define BPF_PSEUDO_MAP_FD	1
+
+/* pseudo BPF_LD_IMM64 insn used to refer to process-local map_fd */
+#define BPF_LD_MAP_FD(DST, MAP_FD)				\
+	((struct bpf_insn) {					\
+		.code  = BPF_LD | BPF_DW | BPF_IMM,		\
+		.dst_reg = DST,					\
+		.src_reg = BPF_PSEUDO_MAP_FD,			\
+		.off   = 0,					\
+		.imm   = MAP_FD }),				\
+	BPF_LD_IMM64(DST, 0)
+
 /* Short form of mov based on type, BPF_X: dst_reg = src_reg, BPF_K: dst_reg = imm32 */
 
 #define BPF_MOV64_RAW(TYPE, DST, SRC, IMM)			\
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 27b34e1c8fbf..f71d4c494aec 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -143,10 +143,15 @@
  * load/store to bpf_context are checked against known fields
  */
 
+#define MAX_USED_MAPS 64 /* max number of maps accessed by one eBPF program */
+
 /* single container for all structs
  * one verifier_env per bpf_check() call
  */
 struct verifier_env {
+	struct bpf_prog *prog;		/* eBPF program being verified */
+	struct bpf_map *used_maps[MAX_USED_MAPS]; /* array of map's used by eBPF program */
+	u32 used_map_cnt;		/* number of used maps */
 };
 
 /* verbose verifier prints what it's seeing
@@ -318,6 +323,114 @@ static void print_bpf_insn(struct bpf_insn *insn)
 	}
 }
 
+/* return the map pointer stored inside BPF_LD_IMM64 instruction */
+static struct bpf_map *ld_imm64_to_map_ptr(struct bpf_insn *insn)
+{
+	u64 imm64 = ((u64) (u32) insn[0].imm) | ((u64) (u32) insn[1].imm) << 32;
+
+	return (struct bpf_map *) (unsigned long) imm64;
+}
+
+/* look for pseudo eBPF instructions that access map FDs and
+ * replace them with actual map pointers
+ */
+static int replace_map_fd_with_map_ptr(struct verifier_env *env)
+{
+	struct bpf_insn *insn = env->prog->insnsi;
+	int insn_cnt = env->prog->len;
+	int i, j;
+
+	for (i = 0; i < insn_cnt; i++, insn++) {
+		if (insn[0].code == (BPF_LD | BPF_IMM | BPF_DW)) {
+			struct bpf_map *map;
+			struct fd f;
+
+			if (i == insn_cnt - 1 ||
+			    insn[1].code != (BPF_LD | BPF_IMM | BPF_DW)) {
+				verbose("invalid bpf_ld_imm64 insn\n");
+				return -EINVAL;
+			}
+
+			if (insn->src_reg == 0)
+				/* valid generic load 64-bit imm */
+				goto next_insn;
+
+			if (insn->src_reg != BPF_PSEUDO_MAP_FD) {
+				verbose("unrecognized bpf_ld_imm64 insn\n");
+				return -EINVAL;
+			}
+
+			f = fdget(insn->imm);
+
+			map = bpf_map_get(f);
+			if (IS_ERR(map)) {
+				verbose("fd %d is not pointing to valid bpf_map\n",
+					insn->imm);
+				fdput(f);
+				return PTR_ERR(map);
+			}
+
+			/* store map pointer inside BPF_LD_IMM64 instruction */
+			insn[0].imm = (u32) (unsigned long) map;
+			insn[1].imm = ((u64) (unsigned long) map) >> 32;
+
+			/* check whether we recorded this map already */
+			for (j = 0; j < env->used_map_cnt; j++)
+				if (env->used_maps[j] == map) {
+					fdput(f);
+					goto next_insn;
+				}
+
+			if (env->used_map_cnt >= MAX_USED_MAPS) {
+				fdput(f);
+				return -E2BIG;
+			}
+
+			/* remember this map */
+			env->used_maps[env->used_map_cnt++] = map;
+
+			/* hold the map. If the program is rejected by verifier,
+			 * the map will be released by release_maps() or it
+			 * will be used by the valid program until it's unloaded
+			 * and all maps are released in free_bpf_prog_info()
+			 */
+			atomic_inc(&map->refcnt);
+
+			fdput(f);
+next_insn:
+			insn++;
+			i++;
+		}
+	}
+
+	/* now all pseudo BPF_LD_IMM64 instructions load valid
+	 * 'struct bpf_map *' into a register instead of user map_fd.
+	 * These pointers will be used later by verifier to validate map access.
+	 */
+	return 0;
+}
+
+/* drop refcnt of maps used by the rejected program */
+static void release_maps(struct verifier_env *env)
+{
+	int i;
+
+	for (i = 0; i < env->used_map_cnt; i++)
+		bpf_map_put(env->used_maps[i]);
+}
+
+/* convert pseudo BPF_LD_IMM64 into generic BPF_LD_IMM64 */
+static void convert_pseudo_ld_imm64(struct verifier_env *env)
+{
+	struct bpf_insn *insn = env->prog->insnsi;
+	int insn_cnt = env->prog->len;
+	int i;
+
+	for (i = 0; i < insn_cnt; i++, insn++)
+		if (insn->code == (BPF_LD | BPF_IMM | BPF_DW))
+			insn->src_reg = 0;
+}
+
 int bpf_check(struct bpf_prog *prog, struct nlattr *tb[BPF_PROG_ATTR_MAX + 1])
 {
 	void __user *log_ubuf = NULL;
@@ -334,6 +447,8 @@ int bpf_check(struct bpf_prog *prog, struct nlattr *tb[BPF_PROG_ATTR_MAX + 1])
 	if (!env)
 		return -ENOMEM;
 
+	env->prog = prog;
+
 	/* grab the mutex to protect few globals used by verifier */
 	mutex_lock(&bpf_verifier_lock);
 
@@ -361,8 +476,14 @@ int bpf_check(struct bpf_prog *prog, struct nlattr *tb[BPF_PROG_ATTR_MAX + 1])
 		log_level = 0;
 	}
 
+	ret = replace_map_fd_with_map_ptr(env);
+	if (ret < 0)
+		goto skip_full_check;
+
 	/* ret = do_check(env); */
 
+skip_full_check:
+
 	if (log_level && log_len >= log_size - 1) {
 		BUG_ON(log_len >= log_size);
 		/* verifier log exceeded user supplied buffer */
@@ -376,11 +497,36 @@ int bpf_check(struct bpf_prog *prog, struct nlattr *tb[BPF_PROG_ATTR_MAX + 1])
 		goto free_log_buf;
 	}
 
+	if (ret == 0 && env->used_map_cnt) {
+		/* if program passed verifier, update used_maps in bpf_prog_info */
+		prog->info->used_maps = kmalloc_array(env->used_map_cnt,
+						      sizeof(env->used_maps[0]),
+						      GFP_KERNEL);
+
+		if (!prog->info->used_maps) {
+			ret = -ENOMEM;
+			goto free_log_buf;
+		}
+
+		memcpy(prog->info->used_maps, env->used_maps,
+		       sizeof(env->used_maps[0]) * env->used_map_cnt);
+		prog->info->used_map_cnt = env->used_map_cnt;
+
+		/* program is valid. Convert pseudo bpf_ld_imm64 into generic
+		 * bpf_ld_imm64 instructions
+		 */
+		convert_pseudo_ld_imm64(env);
+	}
 
 free_log_buf:
 	if (log_level)
 		vfree(log_buf);
 free_env:
+	if (!prog->info->used_maps)
+		/* if we didn't copy map pointers into bpf_prog_info, release
+		 * them now. Otherwise free_bpf_prog_info() will release them.
+		 */
+		release_maps(env);
 	kfree(env);
 	mutex_unlock(&bpf_verifier_lock);
 	return ret;
-- 
1.7.9.5
