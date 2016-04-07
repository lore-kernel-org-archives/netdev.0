From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next] bpf: simplify verifier register state assignments
Date: Wed, 6 Apr 2016 19:39:21 -0700
Message-ID: <1459996761-2926623-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:55038 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750923AbcDGCjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 22:39:24 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u372aUK7031060
	for <netdev@vger.kernel.org>; Wed, 6 Apr 2016 19:39:24 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2259grh8wh-1
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 19:39:24 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 ef22dffcfc6911e58f3524be05956610-e82c63f0 for <netdev@vger.kernel.org>;	Wed,
 06 Apr 2016 19:39:22 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

verifier is using the following structure to track the state of registers:
struct reg_state {
    enum bpf_reg_type type;
    union {
        int imm;
        struct bpf_map *map_ptr;
    };
};
and later on in states_equal() does memcmp(&old->regs[i], &cur->regs[i],..)
to find equivalent states.
Throughout the code of verifier there are assignements to 'imm' and 'map_ptr'
fields and it's not obvious that most of the assignments into 'imm' don't
need to clear extra 4 bytes (like mark_reg_unknown_value() does) to make sure
that memcmp doesn't go over junk left from 'map_ptr' assignment.

Simplify the code by converting 'int' into 'long'

Suggested-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/verifier.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 2e08f8e9b771..f4ffb2ce034a 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -142,7 +142,7 @@ struct reg_state {
 	enum bpf_reg_type type;
 	union {
 		/* valid when type == CONST_IMM | PTR_TO_STACK */
-		int imm;
+		long imm;
 
 		/* valid when type == CONST_PTR_TO_MAP | PTR_TO_MAP_VALUE |
 		 *   PTR_TO_MAP_VALUE_OR_NULL
@@ -260,7 +260,7 @@ static void print_verifier_state(struct verifier_env *env)
 			continue;
 		verbose(" R%d=%s", i, reg_type_str[t]);
 		if (t == CONST_IMM || t == PTR_TO_STACK)
-			verbose("%d", env->cur_state.regs[i].imm);
+			verbose("%ld", env->cur_state.regs[i].imm);
 		else if (t == CONST_PTR_TO_MAP || t == PTR_TO_MAP_VALUE ||
 			 t == PTR_TO_MAP_VALUE_OR_NULL)
 			verbose("(ks=%d,vs=%d)",
@@ -477,7 +477,6 @@ static void init_reg_state(struct reg_state *regs)
 	for (i = 0; i < MAX_BPF_REG; i++) {
 		regs[i].type = NOT_INIT;
 		regs[i].imm = 0;
-		regs[i].map_ptr = NULL;
 	}
 
 	/* frame pointer */
@@ -492,7 +491,6 @@ static void mark_reg_unknown_value(struct reg_state *regs, u32 regno)
 	BUG_ON(regno >= MAX_BPF_REG);
 	regs[regno].type = UNKNOWN_VALUE;
 	regs[regno].imm = 0;
-	regs[regno].map_ptr = NULL;
 }
 
 enum reg_arg_type {
-- 
2.8.0
