From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 1/6] bpf: support 8-byte metafield access
Date: Fri, 26 Aug 2016 19:31:19 -0700
Message-ID: <1472265084-1767670-2-git-send-email-ast@fb.com>
References: <1472265084-1767670-1-git-send-email-ast@fb.com>
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
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:57950 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754679AbcH0Cbk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 22:31:40 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u7R2VMlW020778
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 19:31:27 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2530hrgeu9-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 19:31:27 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.223.100.97) with ESMTP id
 5999a5a66bfe11e697f724be0593f280-72af3aa0 for <netdev@vger.kernel.org>;        Fri,
 26 Aug 2016 19:31:25 -0700
In-Reply-To: <1472265084-1767670-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The verifier supported only 4-byte metafields in
struct __sk_buff and struct xdp_md. The metafields in upcoming
struct bpf_perf_event are 8-byte to match register width in struct pt_regs.
Teach verifier to recognize 8-byte metafield access.
The patch doesn't affect safety of sockets and xdp programs.
They check for 4-byte only ctx access before these conditions are hit.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
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
