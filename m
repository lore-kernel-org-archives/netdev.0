From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v12 net-next 05/11] bpf: handle pseudo BPF_CALL insn
Date: Mon, 15 Sep 2014 12:18:35 -0700
Message-ID: <1410808721-27493-6-git-send-email-ast@plumgrid.com>
References: <1410808721-27493-1-git-send-email-ast@plumgrid.com>
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
Received: from mail-pa0-f52.google.com ([209.85.220.52]:56878 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754528AbaIOTTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 15:19:09 -0400
Received: by mail-pa0-f52.google.com with SMTP id kq14so6950335pab.25
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 12:19:09 -0700 (PDT)
In-Reply-To: <1410808721-27493-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in native eBPF programs userspace is using pseudo BPF_CALL instructions
which encode one of 'enum bpf_func_id' inside insn->imm field.
Verifier checks that program using correct function arguments to given func_id.
If all checks passed, kernel needs to fixup BPF_CALL->imm fields by
replacing func_id with in-kernel function pointer.
eBPF interpreter just calls the function.

In-kernel eBPF users continue to use generic BPF_CALL.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 kernel/bpf/syscall.c |   37 +++++++++++++++++++++++++++++++++++++
 1 file changed, 37 insertions(+)

diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index c3aa3264e235..158d3aca29e4 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -351,6 +351,40 @@ void bpf_register_prog_type(struct bpf_prog_type_list *tl)
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
+			BUG_ON(!prog->aux->ops->get_func_proto);
+
+			fn = prog->aux->ops->get_func_proto(insn->imm);
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
 static void free_used_maps(struct bpf_prog_aux *aux)
 {
@@ -471,6 +505,9 @@ static int bpf_prog_load(union bpf_attr *attr)
 	if (err < 0)
 		goto free_used_maps;
 
+	/* fixup BPF_CALL->imm field */
+	fixup_bpf_calls(prog);
+
 	/* eBPF program is ready to be JITed */
 	bpf_prog_select_runtime(prog);
 
-- 
1.7.9.5
