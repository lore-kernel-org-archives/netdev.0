From: Vladimir Murzin <murzin.v@gmail.com>
Subject: [PATCH 2/3] net: bpf jit: x86: optimize choose_load_func error path
Date: Sun, 13 Oct 2013 16:54:25 +0200
Message-ID: <1381676065-2373-2-git-send-email-murzin.v@gmail.com>
References: <1381249910-17338-2-git-send-email-murzin.v@gmail.com>
 <1381676065-2373-1-git-send-email-murzin.v@gmail.com>
Cc: davem@davemloft.net, edumazet@google.com, av1474@comtv.ru,
	Vladimir Murzin <murzin.v@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:41497 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754968Ab3JMOz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Oct 2013 10:55:57 -0400
Received: by mail-lb0-f171.google.com with SMTP id u14so4859179lbd.2
        for <netdev@vger.kernel.org>; Sun, 13 Oct 2013 07:55:55 -0700 (PDT)
In-Reply-To: <1381676065-2373-1-git-send-email-murzin.v@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Macro CHOOSE_LOAD_FUNC returns handler for "any offset" if checks for K
were not passed. At the same time handlers for "any offset" cases make
the same checks against r_addr at run-time, that will always lead to
bpf_error.

Run-time checks are still necessary for indirect load operations, but
error path for absolute and mesh loads are worth to optimize during bpf
compile time.

Signed-off-by: Vladimir Murzin <murzin.v@gmail.com>
---

David pointed at inability to merge mesh load with common load code. This
patch is updated according to this note.

 arch/x86/net/bpf_jit_comp.c | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 79c216a..92128fe 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -123,7 +123,7 @@ static inline void bpf_flush_icache(void *start, void *end)
 }
 
 #define CHOOSE_LOAD_FUNC(K, func) \
-	((int)K < 0 ? ((int)K >= SKF_LL_OFF ? func##_negative_offset : func) : func##_positive_offset)
+	((int)K < 0 ? ((int)K >= SKF_LL_OFF ? func##_negative_offset : NULL) : func##_positive_offset)
 
 /* Helper to find the offset of pkt_type in sk_buff
  * We want to make sure its still a 3bit field starting at a byte boundary.
@@ -611,7 +611,14 @@ void bpf_jit_compile(struct sk_filter *fp)
 			}
 			case BPF_S_LD_W_ABS:
 				func = CHOOSE_LOAD_FUNC(K, sk_load_word);
-common_load:			seen |= SEEN_DATAREF;
+common_load:
+				if (!func) {
+					CLEAR_A();
+					EMIT_JMP(cleanup_addr - addrs[i]);
+					break;
+				}
+
+				seen |= SEEN_DATAREF;
 				t_offset = func - (image + addrs[i]);
 				EMIT1_off32(0xbe, K); /* mov imm32,%esi */
 				EMIT1_off32(0xe8, t_offset); /* call */
@@ -624,6 +631,13 @@ common_load:			seen |= SEEN_DATAREF;
 				goto common_load;
 			case BPF_S_LDX_B_MSH:
 				func = CHOOSE_LOAD_FUNC(K, sk_load_byte_msh);
+
+				if (!func) {
+					CLEAR_A();
+					EMIT_JMP(cleanup_addr - addrs[i]);
+					break;
+				}
+
 				seen |= SEEN_DATAREF | SEEN_XREG;
 				t_offset = func - (image + addrs[i]);
 				EMIT1_off32(0xbe, K);	/* mov imm32,%esi */
-- 
1.8.1.5
