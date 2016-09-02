From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v3 net-next 1/6] bpf: support 8-byte metafield access
Date: Thu, 1 Sep 2016 18:37:21 -0700
Message-ID: <1472780246-323814-2-git-send-email-ast@fb.com>
References: <1472780246-323814-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Zijlstra <peterz@infradead.org>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Arnaldo Carvalho de Melo <acme@infradead.org>,
        Wang Nan <wangnan0@huawei.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:60137 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752172AbcIBBh3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 21:37:29 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
        by m0089730.ppops.net (8.16.0.17/8.16.0.17) with SMTP id u821XSqg026926
        for <netdev@vger.kernel.org>; Thu, 1 Sep 2016 18:37:28 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0089730.ppops.net with ESMTP id 2564m064kb-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 18:37:28 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.102.107.99) with ESMTP id
 ce2f81e870ad11e681540002c99293a0-b0bfda50 for <netdev@vger.kernel.org>;        Thu,
 01 Sep 2016 18:37:27 -0700
In-Reply-To: <1472780246-323814-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The verifier supported only 4-byte metafields in
struct __sk_buff and struct xdp_md. The metafields in upcoming
struct bpf_perf_event are 8-byte to match register width in struct pt_regs.
Teach verifier to recognize 8-byte metafield access.
The patch doesn't affect safety of sockets and xdp programs.
They check for 4-byte only ctx access before these conditions are hit.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/verifier.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index abb61f3f6900..c1c9e441f0f5 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -2333,7 +2333,8 @@ static int do_check(struct verifier_env *env)
 			if (err)
 				return err;
 
-			if (BPF_SIZE(insn->code) != BPF_W) {
+			if (BPF_SIZE(insn->code) != BPF_W &&
+			    BPF_SIZE(insn->code) != BPF_DW) {
 				insn_idx++;
 				continue;
 			}
@@ -2642,9 +2643,11 @@ static int convert_ctx_accesses(struct verifier_env *env)
 	for (i = 0; i < insn_cnt; i++, insn++) {
 		u32 insn_delta, cnt;
 
-		if (insn->code == (BPF_LDX | BPF_MEM | BPF_W))
+		if (insn->code == (BPF_LDX | BPF_MEM | BPF_W) ||
+		    insn->code == (BPF_LDX | BPF_MEM | BPF_DW))
 			type = BPF_READ;
-		else if (insn->code == (BPF_STX | BPF_MEM | BPF_W))
+		else if (insn->code == (BPF_STX | BPF_MEM | BPF_W) ||
+			 insn->code == (BPF_STX | BPF_MEM | BPF_DW))
 			type = BPF_WRITE;
 		else
 			continue;
-- 
2.8.0
