From: Xi Wang <xi.wang@gmail.com>
Subject: [PATCH v2 net-next 2/3] x86: bpf_jit_comp: support BPF_S_ANC_SECCOMP_LD_W instruction
Date: Fri, 26 Apr 2013 22:17:26 -0400
Message-ID: <1367029047-14830-3-git-send-email-xi.wang@gmail.com>
References: <1367029047-14830-1-git-send-email-xi.wang@gmail.com>
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Will Drewry <wad@chromium.org>,
	Eric Dumazet <edumazet@google.com>,
	Russell King <linux@arm.linux.org.uk>,
	David Laight <david.laight@aculab.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nicolas Schichan <nschichan@freebox.fr>,
	Xi Wang <xi.wang@gmail.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1367029047-14830-1-git-send-email-xi.wang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch implements the seccomp BPF_S_ANC_SECCOMP_LD_W instruction
in x86 JIT.

Signed-off-by: Xi Wang <xi.wang@gmail.com>
Cc: Daniel Borkmann <dborkman@redhat.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Will Drewry <wad@chromium.org>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Russell King <linux@arm.linux.org.uk>
Cc: David Laight <david.laight@aculab.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Nicolas Schichan <nschichan@freebox.fr>
---
 arch/x86/net/bpf_jit_comp.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 8898680..5f1dafb 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -683,6 +683,17 @@ cond_branch:			f_offset = addrs[i + filter[i].jf] - addrs[i];
 				}
 				EMIT_COND_JMP(f_op, f_offset);
 				break;
+#ifdef CONFIG_SECCOMP_FILTER
+			case BPF_S_ANC_SECCOMP_LD_W:
+				func = (u8 *)seccomp_bpf_load;
+				t_offset = func - (image + addrs[i]);
+				/* seccomp filters don't use %rdi, %r8, %r9
+				 * it is safe to not save these registers
+				 */
+				EMIT1_off32(0xbf, K); /* mov imm32,%edi */
+				EMIT1_off32(0xe8, t_offset); /* call seccomp_bpf_load */
+				break;
+#endif
 			default:
 				/* hmm, too complex filter, give up with jit compiler */
 				goto out;
-- 
1.8.1.2
