From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 9/9] bpf: take advantage of stack_depth tracking in x64 JIT
Date: Tue, 30 May 2017 13:31:35 -0700
Message-ID: <20170530203135.3642768-10-ast@fb.com>
References: <20170530203135.3642768-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:58114 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751025AbdE3Ubj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 16:31:39 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4UKQlWg009076
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 13:31:38 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 2asegy08ce-5
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 13:31:38 -0700
Received: from facebook.com (2401:db00:11:d082:face:0:5:0)      by
 mx-out.facebook.com (10.103.99.99) with ESMTP  id
 fa5c70ca457611e7b3fb0002c9dfb610-9213d8f0 for <netdev@vger.kernel.org>;        Tue,
 30 May 2017 13:31:36 -0700
In-Reply-To: <20170530203135.3642768-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Take advantage of stack_depth tracking in x64 JIT.
Round up allocated stack by 8 bytes to make sure it stays aligned
for functions called from JITed bpf program.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 arch/x86/net/bpf_jit_comp.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index c96dac838f3e..617eac9c4511 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -206,7 +206,7 @@ struct jit_context {
 /* emit x64 prologue code for BPF program and check it's size.
  * bpf_tail_call helper will skip it while jumping into another program
  */
-static void emit_prologue(u8 **pprog)
+static void emit_prologue(u8 **pprog, u32 stack_depth)
 {
 	u8 *prog = *pprog;
 	int cnt = 0;
@@ -214,8 +214,9 @@ static void emit_prologue(u8 **pprog)
 	EMIT1(0x55); /* push rbp */
 	EMIT3(0x48, 0x89, 0xE5); /* mov rbp,rsp */
 
-	/* sub rsp, MAX_BPF_STACK + AUX_STACK_SPACE */
-	EMIT3_off32(0x48, 0x81, 0xEC, MAX_BPF_STACK + AUX_STACK_SPACE);
+	/* sub rsp, rounded_stack_depth + AUX_STACK_SPACE */
+	EMIT3_off32(0x48, 0x81, 0xEC,
+		    round_up(stack_depth, 8) + AUX_STACK_SPACE);
 
 	/* sub rbp, AUX_STACK_SPACE */
 	EMIT4(0x48, 0x83, 0xED, AUX_STACK_SPACE);
@@ -363,7 +364,7 @@ static int do_jit(struct bpf_prog *bpf_prog, int *addrs, u8 *image,
 	int proglen = 0;
 	u8 *prog = temp;
 
-	emit_prologue(&prog);
+	emit_prologue(&prog, bpf_prog->aux->stack_depth);
 
 	if (seen_ld_abs)
 		emit_load_skb_data_hlen(&prog);
-- 
2.9.3
