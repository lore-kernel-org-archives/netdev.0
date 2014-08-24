From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH v5 net-next 09/29] bpf: handle pseudo BPF_CALL insn
Date: Sun, 24 Aug 2014 13:21:10 -0700
Message-ID: <1408911690-7598-10-git-send-email-ast@plumgrid.com>
References: <1408911690-7598-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Brendan Gregg <brendan.d.gregg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1408911690-7598-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

in native eBPF programs userspace is using pseudo BPF_CALL instructions
which encode one of 'enum bpf_func_id' inside insn->imm field.
Verifier checks that program using correct function arguments to given func_id.
If all checks passed, kernel needs to fixup BPF_CALL->imm fields by
replacing func_id with in-kernel function pointer.
eBPF interpreter just calls the function.

In-kernel eBPF users continue to use generic BPF_CALL.

Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
---
 kernel/bpf/syscall.c |   37 +++++++++++++++++++++++++++++++++++++
 1 file changed, 37 insertions(+)

diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 4c5f5169f6fc..5a336af61858 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -338,6 +338,40 @@ void bpf_register_prog_type(struct bpf_prog_type_list *tl)
 	list_add(&tl->list_node, &bpf_prog_types);
 }
 
+/* fixup insn->imm field of bpf_call instructions:
+ * if (insn->imm == BPF_FUNC_map_lookup_elem)
+ *      insn->imm = bpf_map_lookup_elem - __bpf_call_base;
+ * else if (insn->imm == BPF_FUNC_map_update_elem)
+ *      insn->imm = bpf_map_update_elem - __bpf_call_base;
+ * else ...
+ *
+ * this function is called after eBPF program passed verification
+ */
+static void fixup_bpf_calls(struct bpf_prog *prog)
+{
+	const struct bpf_func_proto *fn;
+	int i;
+
+	for (i = 0; i < prog->len; i++) {
+		struct bpf_insn *insn = &prog->insnsi[i];
+
+		if (insn->code == (BPF_JMP | BPF_CALL)) {
+			/* we reach here when program has bpf_call instructions
+			 * and it passed bpf_check(), means that
+			 * ops->get_func_proto must have been supplied, check it
+			 */
+			BUG_ON(!prog->info->ops->get_func_proto);
+
+			fn = prog->info->ops->get_func_proto(insn->imm);
+			/* all functions that have prototype and verifier allowed
+			 * programs to call them, must be real in-kernel functions
+			 */
+			BUG_ON(!fn->func);
+			insn->imm = fn->func - __bpf_call_base;
+		}
+	}
+}
+
 /* drop refcnt on maps used by eBPF program and free auxilary data */
 static void free_bpf_prog_info(struct bpf_prog_info *info)
 {
@@ -485,6 +519,9 @@ static int bpf_prog_load(enum bpf_prog_type type, struct nlattr __user *uattr,
 	if (err < 0)
 		goto free_prog_info;
 
+	/* fixup BPF_CALL->imm field */
+	fixup_bpf_calls(prog);
+
 	/* eBPF program is ready to be JITed */
 	bpf_prog_select_runtime(prog);
 
-- 
1.7.9.5
