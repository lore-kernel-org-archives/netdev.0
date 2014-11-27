From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net] bpf: x86: fix epilogue generation for eBPF programs
Date: Wed, 26 Nov 2014 21:02:26 -0800
Message-ID: <1417064546-4129-1-git-send-email-ast@plumgrid.com>
Cc: Zi Shen Lim <zlim.lnx@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@kernel.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

classic BPF has a restriction that last insn is always BPF_RET.
eBPF doesn't have BPF_RET instruction and this restriction.
It has BPF_EXIT insn which can appear anywhere in the program
one or more times and it doesn't have to be last insn.
Fix eBPF JIT to emit epilogue when first BPF_EXIT is seen
and all other BPF_EXIT instructions will be emitted as jump.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
Note, this bug is applicable only to native eBPF programs
which first were introduced in 3.18, so no need to send it
to stable and therefore no 'Fixes' tag.

arm64 JIT has the same problem, but the fix is not as trivial,
so will be done as separate patch.

Since 3.18 can only load eBPF programs and cannot execute them,
this patch can even be done in net-next only, but I think it's worth
to apply it to 3.18(net), so that JITed output for native eBPF
programs is correct when bpf syscall loads it with net.core.bpf_jit_enable=2

 arch/x86/net/bpf_jit_comp.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 3f62734..7e90244 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -178,7 +178,7 @@ static void jit_fill_hole(void *area, unsigned int size)
 }
 
 struct jit_context {
-	unsigned int cleanup_addr; /* epilogue code offset */
+	int cleanup_addr; /* epilogue code offset */
 	bool seen_ld_abs;
 };
 
@@ -192,6 +192,7 @@ static int do_jit(struct bpf_prog *bpf_prog, int *addrs, u8 *image,
 	struct bpf_insn *insn = bpf_prog->insnsi;
 	int insn_cnt = bpf_prog->len;
 	bool seen_ld_abs = ctx->seen_ld_abs | (oldproglen == 0);
+	bool seen_exit = false;
 	u8 temp[BPF_MAX_INSN_SIZE + BPF_INSN_SAFETY];
 	int i;
 	int proglen = 0;
@@ -854,10 +855,11 @@ common_load:
 			goto common_load;
 
 		case BPF_JMP | BPF_EXIT:
-			if (i != insn_cnt - 1) {
+			if (seen_exit) {
 				jmp_offset = ctx->cleanup_addr - addrs[i];
 				goto emit_jmp;
 			}
+			seen_exit = true;
 			/* update cleanup_addr */
 			ctx->cleanup_addr = proglen;
 			/* mov rbx, qword ptr [rbp-X] */
-- 
1.7.9.5
