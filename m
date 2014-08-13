From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH RFC v4 net-next 12/26] bpf: verifier (add branch/goto checks)
Date: Wed, 13 Aug 2014 00:57:23 -0700
Message-ID: <1407916658-8731-13-git-send-email-ast@plumgrid.com>
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

check that control flow graph of eBPF program is a directed acyclic graph

check_cfg() does:
- detect loops
- detect unreachable instructions
- check that program terminates with BPF_EXIT insn
- check that all branches are within program boundary

Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
---
 kernel/bpf/verifier.c |  183 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 183 insertions(+)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index f71d4c494aec..19c853f68c30 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -331,6 +331,185 @@ static struct bpf_map *ld_imm64_to_map_ptr(struct bpf_insn *insn)
 	return (struct bpf_map *) (unsigned long) imm64;
 }
 
+/* non-recursive DFS pseudo code
+ * 1  procedure DFS-iterative(G,v):
+ * 2      label v as discovered
+ * 3      let S be a stack
+ * 4      S.push(v)
+ * 5      while S is not empty
+ * 6            t <- S.pop()
+ * 7            if t is what we're looking for:
+ * 8                return t
+ * 9            for all edges e in G.adjacentEdges(t) do
+ * 10               if edge e is already labelled
+ * 11                   continue with the next edge
+ * 12               w <- G.adjacentVertex(t,e)
+ * 13               if vertex w is not discovered and not explored
+ * 14                   label e as tree-edge
+ * 15                   label w as discovered
+ * 16                   S.push(w)
+ * 17                   continue at 5
+ * 18               else if vertex w is discovered
+ * 19                   label e as back-edge
+ * 20               else
+ * 21                   // vertex w is explored
+ * 22                   label e as forward- or cross-edge
+ * 23           label t as explored
+ * 24           S.pop()
+ *
+ * convention:
+ * 0x10 - discovered
+ * 0x11 - discovered and fall-through edge labelled
+ * 0x12 - discovered and fall-through and branch edges labelled
+ * 0x20 - explored
+ */
+
+enum {
+	DISCOVERED = 0x10,
+	EXPLORED = 0x20,
+	FALLTHROUGH = 1,
+	BRANCH = 2,
+};
+
+#define PUSH_INT(I) \
+	do { \
+		if (cur_stack >= insn_cnt) { \
+			ret = -E2BIG; \
+			goto free_st; \
+		} \
+		stack[cur_stack++] = I; \
+	} while (0)
+
+#define PEEK_INT() \
+	({ \
+		int _ret; \
+		if (cur_stack == 0) \
+			_ret = -1; \
+		else \
+			_ret = stack[cur_stack - 1]; \
+		_ret; \
+	 })
+
+#define POP_INT() \
+	({ \
+		int _ret; \
+		if (cur_stack == 0) \
+			_ret = -1; \
+		else \
+			_ret = stack[--cur_stack]; \
+		_ret; \
+	 })
+
+#define PUSH_INSN(T, W, E) \
+	do { \
+		int w = W; \
+		if (E == FALLTHROUGH && st[T] >= (DISCOVERED | FALLTHROUGH)) \
+			break; \
+		if (E == BRANCH && st[T] >= (DISCOVERED | BRANCH)) \
+			break; \
+		if (w < 0 || w >= insn_cnt) { \
+			verbose("jump out of range from insn %d to %d\n", T, w); \
+			ret = -EINVAL; \
+			goto free_st; \
+		} \
+		if (st[w] == 0) { \
+			/* tree-edge */ \
+			st[T] = DISCOVERED | E; \
+			st[w] = DISCOVERED; \
+			PUSH_INT(w); \
+			goto peek_stack; \
+		} else if ((st[w] & 0xF0) == DISCOVERED) { \
+			verbose("back-edge from insn %d to %d\n", T, w); \
+			ret = -EINVAL; \
+			goto free_st; \
+		} else if (st[w] == EXPLORED) { \
+			/* forward- or cross-edge */ \
+			st[T] = DISCOVERED | E; \
+		} else { \
+			verbose("insn state internal bug\n"); \
+			ret = -EFAULT; \
+			goto free_st; \
+		} \
+	} while (0)
+
+/* non-recursive depth-first-search to detect loops in BPF program
+ * loop == back-edge in directed graph
+ */
+static int check_cfg(struct verifier_env *env)
+{
+	struct bpf_insn *insns = env->prog->insnsi;
+	int insn_cnt = env->prog->len;
+	int cur_stack = 0;
+	int *stack;
+	int ret = 0;
+	int *st;
+	int i, t;
+
+	st = kzalloc(sizeof(int) * insn_cnt, GFP_KERNEL);
+	if (!st)
+		return -ENOMEM;
+
+	stack = kzalloc(sizeof(int) * insn_cnt, GFP_KERNEL);
+	if (!stack) {
+		kfree(st);
+		return -ENOMEM;
+	}
+
+	st[0] = DISCOVERED; /* mark 1st insn as discovered */
+	PUSH_INT(0);
+
+peek_stack:
+	while ((t = PEEK_INT()) != -1) {
+		if (BPF_CLASS(insns[t].code) == BPF_JMP) {
+			u8 opcode = BPF_OP(insns[t].code);
+
+			if (opcode == BPF_EXIT) {
+				goto mark_explored;
+			} else if (opcode == BPF_CALL) {
+				PUSH_INSN(t, t + 1, FALLTHROUGH);
+			} else if (opcode == BPF_JA) {
+				if (BPF_SRC(insns[t].code) != BPF_K) {
+					ret = -EINVAL;
+					goto free_st;
+				}
+				/* unconditional jump with single edge */
+				PUSH_INSN(t, t + insns[t].off + 1, FALLTHROUGH);
+			} else {
+				/* conditional jump with two edges */
+				PUSH_INSN(t, t + 1, FALLTHROUGH);
+				PUSH_INSN(t, t + insns[t].off + 1, BRANCH);
+			}
+		} else {
+			/* all other non-branch instructions with single
+			 * fall-through edge
+			 */
+			PUSH_INSN(t, t + 1, FALLTHROUGH);
+		}
+
+mark_explored:
+		st[t] = EXPLORED;
+		if (POP_INT() == -1) {
+			verbose("pop_int internal bug\n");
+			ret = -EFAULT;
+			goto free_st;
+		}
+	}
+
+
+	for (i = 0; i < insn_cnt; i++) {
+		if (st[i] != EXPLORED) {
+			verbose("unreachable insn %d\n", i);
+			ret = -EINVAL;
+			goto free_st;
+		}
+	}
+
+free_st:
+	kfree(st);
+	kfree(stack);
+	return ret;
+}
+
 /* look for pseudo eBPF instructions that access map FDs and
  * replace them with actual map pointers
  */
@@ -480,6 +659,10 @@ int bpf_check(struct bpf_prog *prog, struct nlattr *tb[BPF_PROG_ATTR_MAX + 1])
 	if (ret < 0)
 		goto skip_full_check;
 
+	ret = check_cfg(env);
+	if (ret < 0)
+		goto skip_full_check;
+
 	/* ret = do_check(env); */
 
 skip_full_check:
-- 
1.7.9.5
