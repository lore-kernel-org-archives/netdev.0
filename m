From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 3/9] bpf: teach verifier to track stack depth
Date: Tue, 30 May 2017 13:31:29 -0700
Message-ID: <20170530203135.3642768-4-ast@fb.com>
References: <20170530203135.3642768-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:41232 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750928AbdE3Ubi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 16:31:38 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.20/8.16.0.20) with SMTP id v4UKQMlq005930
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 13:31:37 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 2asap7s4gj-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 13:31:37 -0700
Received: from facebook.com (2401:db00:11:d082:face:0:5:0)      by
 mx-out.facebook.com (10.103.99.99) with ESMTP  id
 fa2e28f0457611e7b3fb0002c9dfb610-9213d8f0 for <netdev@vger.kernel.org>;        Tue,
 30 May 2017 13:31:36 -0700
In-Reply-To: <20170530203135.3642768-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

teach verifier to track bpf program stack depth

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/bpf.h   |  1 +
 kernel/bpf/verifier.c | 10 +++++++++-
 2 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 6bb38d76faf4..fcc80ca11045 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -171,6 +171,7 @@ struct bpf_prog_aux {
 	atomic_t refcnt;
 	u32 used_map_cnt;
 	u32 max_ctx_offset;
+	u32 stack_depth;
 	struct latch_tree_node ksym_tnode;
 	struct list_head ksym_lnode;
 	const struct bpf_verifier_ops *ops;
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 28113d0e8e92..d96f27ff9f6f 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -926,6 +926,10 @@ static int check_mem_access(struct bpf_verifier_env *env, u32 regno, int off,
 			verbose("invalid stack off=%d size=%d\n", off, size);
 			return -EACCES;
 		}
+
+		if (env->prog->aux->stack_depth < -off)
+			env->prog->aux->stack_depth = -off;
+
 		if (t == BPF_WRITE) {
 			if (!env->allow_ptr_leaks &&
 			    state->stack_slot_type[MAX_BPF_STACK + off] == STACK_SPILL &&
@@ -1032,6 +1036,9 @@ static int check_stack_boundary(struct bpf_verifier_env *env, int regno,
 		return -EACCES;
 	}
 
+	if (env->prog->aux->stack_depth < -off)
+		env->prog->aux->stack_depth = -off;
+
 	if (meta && meta->raw_mode) {
 		meta->access_size = access_size;
 		meta->regno = regno;
@@ -3167,7 +3174,8 @@ static int do_check(struct bpf_verifier_env *env)
 		insn_idx++;
 	}
 
-	verbose("processed %d insns\n", insn_processed);
+	verbose("processed %d insns, stack depth %d\n",
+		insn_processed, env->prog->aux->stack_depth);
 	return 0;
 }
 
-- 
2.9.3
