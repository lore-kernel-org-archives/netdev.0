From: Vladimir Murzin <murzin.v@gmail.com>
Subject: [PATCH 1/3] net: bpf jit: ppc: optimize choose_load_func error path
Date: Tue,  8 Oct 2013 20:31:48 +0400
Message-ID: <1381249910-17338-1-git-send-email-murzin.v@gmail.com>
Cc: av1474@comtv.ru, Vladimir Murzin <murzin.v@gmail.com>,
	Jan Seiffert <kaffeemonster@googlemail.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Matt Evans <matt@ozlabs.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:44114 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753013Ab3JHR5P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 13:57:15 -0400
Received: by mail-la0-f46.google.com with SMTP id eh20so7249041lab.33
        for <netdev@vger.kernel.org>; Tue, 08 Oct 2013 10:57:14 -0700 (PDT)
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

Cc: Jan Seiffert <kaffeemonster@googlemail.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Daniel Borkmann <dborkman@redhat.com>
Cc: Matt Evans <matt@ozlabs.org>

---
 arch/powerpc/net/bpf_jit_comp.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
index bf56e33..754320a 100644
--- a/arch/powerpc/net/bpf_jit_comp.c
+++ b/arch/powerpc/net/bpf_jit_comp.c
@@ -132,7 +132,7 @@ static void bpf_jit_build_epilogue(u32 *image, struct codegen_context *ctx)
 }
 
 #define CHOOSE_LOAD_FUNC(K, func) \
-	((int)K < 0 ? ((int)K >= SKF_LL_OFF ? func##_negative_offset : func) : func##_positive_offset)
+	((int)K < 0 ? ((int)K >= SKF_LL_OFF ? func##_negative_offset : NULL) : func##_positive_offset)
 
 /* Assemble the body code between the prologue & epilogue. */
 static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
@@ -427,6 +427,11 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 		case BPF_S_LD_B_ABS:
 			func = CHOOSE_LOAD_FUNC(K, sk_load_byte);
 		common_load:
+			if (!func) {
+				PPC_LI(r_ret, 0);
+				PPC_JMP(exit_addr);
+				break;
+			}
 			/* Load from [K]. */
 			ctx->seen |= SEEN_DATAREF;
 			PPC_LI64(r_scratch1, func);
-- 
1.7.10.4
