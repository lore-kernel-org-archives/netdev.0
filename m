From: Xi Wang <xi.wang@gmail.com>
Subject: [PATCH v2 net-next 3/3] ARM: net: bpf_jit_32: support BPF_S_ANC_SECCOMP_LD_W instruction
Date: Fri, 26 Apr 2013 22:17:27 -0400
Message-ID: <1367029047-14830-4-git-send-email-xi.wang@gmail.com>
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
in ARM JIT.

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
 arch/arm/net/bpf_jit_32.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
index 073b085..9bfce464 100644
--- a/arch/arm/net/bpf_jit_32.c
+++ b/arch/arm/net/bpf_jit_32.c
@@ -19,6 +19,7 @@
 #include <linux/if_vlan.h>
 #include <asm/cacheflush.h>
 #include <asm/hwcap.h>
+#include <asm/syscall.h>
 
 #include "bpf_jit_32.h"
 
@@ -845,6 +846,19 @@ b_epilogue:
 			off = offsetof(struct sk_buff, queue_mapping);
 			emit(ARM_LDRH_I(r_A, r_skb, off), ctx);
 			break;
+#ifdef CONFIG_SECCOMP_FILTER
+		case BPF_S_ANC_SECCOMP_LD_W:
+			if (k == offsetof(struct seccomp_data, arch)) {
+				emit_mov_i(r_A, AUDIT_ARCH_ARM, ctx);
+				break;
+			}
+			ctx->seen |= SEEN_CALL;
+			emit_mov_i(ARM_R3, (u32)seccomp_bpf_load, ctx);
+			emit_mov_i(ARM_R0, k, ctx);
+			emit_blx_r(ARM_R3, ctx);
+			emit(ARM_MOV_R(r_A, ARM_R0), ctx);
+			break;
+#endif
 		default:
 			return -1;
 		}
-- 
1.8.1.2
