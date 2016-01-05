From: Rabin Vincent <rabin@rab.in>
Subject: [PATCH] ARM: net: bpf: fix zero right shift
Date: Tue,  5 Jan 2016 18:34:04 +0100
Message-ID: <1452015244-1230-1-git-send-email-rabin@rab.in>
Cc: netdev@vger.kernel.org, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, Rabin Vincent <rabin@rab.in>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:33811 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752487AbcAEReb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 12:34:31 -0500
Received: by mail-wm0-f54.google.com with SMTP id u188so31967576wmu.1
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 09:34:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The LSR instruction cannot be used to perform a zero right shift since a
0 as the immediate value (imm5) in the LSR instruction encoding means
that a shift of 32 is perfomed.  See DecodeIMMShift() in the ARM ARM.

Make the JIT skip generation of the LSR if a zero-shift is requested.

This was found using american fuzzy lop.

Signed-off-by: Rabin Vincent <rabin@rab.in>
---
 arch/arm/net/bpf_jit_32.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
index e153eb065fe4..93d0b6d0b63e 100644
--- a/arch/arm/net/bpf_jit_32.c
+++ b/arch/arm/net/bpf_jit_32.c
@@ -756,7 +756,8 @@ load_ind:
 		case BPF_ALU | BPF_RSH | BPF_K:
 			if (unlikely(k > 31))
 				return -1;
-			emit(ARM_LSR_I(r_A, r_A, k), ctx);
+			if (k)
+				emit(ARM_LSR_I(r_A, r_A, k), ctx);
 			break;
 		case BPF_ALU | BPF_RSH | BPF_X:
 			update_on_xread(ctx);
-- 
2.6.4
