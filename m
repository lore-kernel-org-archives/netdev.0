From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v2 net-next 1/6] bpf: support 8-byte metafield access
Date: Wed, 31 Aug 2016 14:50:38 -0700
Message-ID: <1472680243-1326608-2-git-send-email-ast@fb.com>
References: <1472680243-1326608-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Zijlstra <peterz@infradead.org>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Arnaldo Carvalho de Melo <acme@infradead.org>,
        Wang Nan <wangnan0@huawei.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472680243-1326608-1-git-send-email-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
