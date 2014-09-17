From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v13 net-next 09/11] bpf: verifier (add branch/goto checks)
Date: Tue, 16 Sep 2014 17:39:28 -0700
Message-ID: <1410914370-29883-10-git-send-email-ast@plumgrid.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:44727 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754588AbaIQAkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 20:40:07 -0400
Received: by mail-pa0-f48.google.com with SMTP id hz1so907738pad.21
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 17:40:07 -0700 (PDT)
In-Reply-To: <1410914370-29883-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

check that control flow graph of eBPF program is a directed acyclic graph

check_cfg() does:
- detect loops
- detect unreachable instructions
- check that program terminates with BPF_EXIT insn
- check that all branches are within program boundary

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 kernel/bpf/verifier.c |  183 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 183 insertions(+)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 7227543e474b..effab7d1c7e8 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -313,6 +313,185 @@ static struct bpf_map *ld_imm64_to_map_ptr(struct bpf_insn *insn)
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
@@ -462,6 +641,10 @@ int bpf_check(struct bpf_prog *prog, union bpf_attr *attr)
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
