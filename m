From: Chema Gonzalez <chema@google.com>
Subject: [PATCH v6 net-next 4/4] net: filter: minor BPF cleanups
Date: Thu, 29 May 2014 11:56:11 -0700
Message-ID: <1401389771-13410-1-git-send-email-chema@google.com>
References: <1398882591-30422-1-git-send-email-chema@google.com>
Cc: netdev@vger.kernel.org, Chema Gonzalez <chema@google.com>
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f202.google.com ([209.85.192.202]:39809 "EHLO
	mail-pd0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752294AbaE2S4N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 14:56:13 -0400
Received: by mail-pd0-f202.google.com with SMTP id fp1so12321pdb.1
        for <netdev@vger.kernel.org>; Thu, 29 May 2014 11:56:12 -0700 (PDT)
In-Reply-To: <1398882591-30422-1-git-send-email-chema@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Includes:
 - 4th argument for BPF_CALLs is the FP register
 - unused fields in LD[X]/ST[X] insn should be zero
 - some typos

Signed-off-by: Chema Gonzalez <chema@google.com>
---
 net/core/filter.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index fcc2783..fd9c7bf 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -651,7 +651,7 @@ static u64 __skb_get_tra_protocol(u64 ctx, u64 a, u64 x, u64 fp, u64 r5)
 	return stack_layout->flow.ip_proto;
 }
 
-static u64 __skb_get_nlattr(u64 ctx, u64 a, u64 x, u64 r4, u64 r5)
+static u64 __skb_get_nlattr(u64 ctx, u64 a, u64 x, u64 fp, u64 r5)
 {
 	struct sk_buff *skb = (struct sk_buff *)(unsigned long) ctx;
 	struct nlattr *nla;
@@ -672,7 +672,7 @@ static u64 __skb_get_nlattr(u64 ctx, u64 a, u64 x, u64 r4, u64 r5)
 	return 0;
 }
 
-static u64 __skb_get_nlattr_nest(u64 ctx, u64 a, u64 x, u64 r4, u64 r5)
+static u64 __skb_get_nlattr_nest(u64 ctx, u64 a, u64 x, u64 fp, u64 r5)
 {
 	struct sk_buff *skb = (struct sk_buff *)(unsigned long) ctx;
 	struct nlattr *nla;
@@ -697,13 +697,13 @@ static u64 __skb_get_nlattr_nest(u64 ctx, u64 a, u64 x, u64 r4, u64 r5)
 	return 0;
 }
 
-static u64 __get_raw_cpu_id(u64 ctx, u64 a, u64 x, u64 r4, u64 r5)
+static u64 __get_raw_cpu_id(u64 ctx, u64 a, u64 x, u64 fp, u64 r5)
 {
 	return raw_smp_processor_id();
 }
 
 /* note that this only generates 32-bit random numbers */
-static u64 __get_random_u32(u64 ctx, u64 a, u64 x, u64 r4, u64 r5)
+static u64 __get_random_u32(u64 ctx, u64 a, u64 x, u64 fp, u64 r5)
 {
 	return prandom_u32();
 }
@@ -1094,7 +1094,7 @@ do_pass:
 			EMIT_JMP;
 			break;
 
-		/* ldxb 4 * ([14] & 0xf) is remaped into 6 insns. */
+		/* ldxb 4 * ([14] & 0xf) is remapped into 6 insns. */
 		case BPF_LDX | BPF_MSH | BPF_B:
 			/* tmp = A */
 			*insn = BPF_ALU64_REG(BPF_MOV, BPF_REG_TMP, BPF_REG_A);
@@ -1120,7 +1120,7 @@ do_pass:
 			*insn = BPF_ALU64_REG(BPF_MOV, BPF_REG_A, BPF_REG_TMP);
 			break;
 
-		/* RET_K, RET_A are remaped into 2 insns. */
+		/* RET_K, RET_A are remapped into 2 insns. */
 		case BPF_RET | BPF_A:
 		case BPF_RET | BPF_K:
 			insn->code = BPF_ALU | BPF_MOV |
@@ -1145,6 +1145,7 @@ do_pass:
 			    -sizeof(struct classic_bpf_stack_layout) +
 			    offsetof(struct classic_bpf_stack_layout,
 				     mem[fp->k]);
+			insn->imm = 0;
 			break;
 
 		/* Load from stack. */
@@ -1158,6 +1159,7 @@ do_pass:
 			    -sizeof(struct classic_bpf_stack_layout) +
 			    offsetof(struct classic_bpf_stack_layout,
 				     mem[fp->k]);
+			insn->imm = 0;
 			break;
 
 		/* A = K or X = K */
-- 
1.9.1.423.g4596e3a
