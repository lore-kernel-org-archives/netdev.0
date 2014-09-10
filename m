From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v11 net-next 08/12] bpf: handle pseudo BPF_LD_IMM64 insn
Date: Tue,  9 Sep 2014 22:10:04 -0700
Message-ID: <1410325808-3657-9-git-send-email-ast@plumgrid.com>
References: <1410325808-3657-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linuxfoundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1410325808-3657-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

eBPF programs passed from userspace are using pseudo BPF_LD_IMM64 instructions
to refer to process-local map_fd. Scan the program for such instructions and
if FDs are valid, convert them to 'struct bpf_map' pointers which will be used
by verifier to check access to maps in bpf_map_lookup/update() calls.
If program passes verifier, convert pseudo BPF_LD_IMM64 into generic by dropping
BPF_PSEUDO_MAP_FD flag.

Note that eBPF interpreter is generic and knows nothing about pseudo insns.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/linux/filter.h |    6 ++
 kernel/bpf/verifier.c  |  147 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 153 insertions(+)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 9727616693e5..c105af7420a8 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -139,6 +139,12 @@ struct bpf_prog_info;
 		.off   = 0,					\
 		.imm   = ((__u64) (IMM)) >> 32 })
 
+#define BPF_PSEUDO_MAP_FD	1
+
+/* pseudo BPF_LD_IMM64 insn used to refer to process-local map_fd */
+#define BPF_LD_MAP_FD(DST, MAP_FD)				\
+	BPF_LD_IMM64_RAW(DST, BPF_PSEUDO_MAP_FD, MAP_FD)
+
 /* Short form of mov based on type, BPF_X: dst_reg = src_reg, BPF_K: dst_reg = imm32 */
 
 #define BPF_MOV64_RAW(TYPE, DST, SRC, IMM)			\
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 5c88cf54bb3b..df4eb58f7f0a 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -125,10 +125,15 @@
  * are set to NOT_INIT to indicate that they are no longer readable.
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
@@ -300,6 +305,115 @@ static void print_bpf_insn(struct bpf_insn *insn)
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
+			if (i == insn_cnt - 1 || insn[1].code != 0 ||
+			    insn[1].dst_reg != 0 || insn[1].src_reg != 0 ||
+			    insn[1].off != 0) {
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
 int bpf_check(struct bpf_prog *prog, union bpf_attr *attr)
 {
 	void __user *log_ubuf = NULL;
@@ -316,6 +430,8 @@ int bpf_check(struct bpf_prog *prog, union bpf_attr *attr)
 	if (!env)
 		return -ENOMEM;
 
+	env->prog = prog;
+
 	/* grab the mutex to protect few globals used by verifier */
 	mutex_lock(&bpf_verifier_lock);
 
@@ -342,8 +458,14 @@ int bpf_check(struct bpf_prog *prog, union bpf_attr *attr)
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
@@ -357,11 +479,36 @@ int bpf_check(struct bpf_prog *prog, union bpf_attr *attr)
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
