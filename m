From: Zi Shen Lim <zlim.lnx@gmail.com>
Subject: [PATCH 2/2] arm64: bpf: add extra pass to handle faulty codegen
Date: Wed, 13 Jan 2016 23:33:22 -0800
Message-ID: <1452756802-16511-2-git-send-email-zlim.lnx@gmail.com>
References: <1452756802-16511-1-git-send-email-zlim.lnx@gmail.com>
Cc: Zi Shen Lim <zlim.lnx@gmail.com>, Rabin Vincent <rabin@rab.in>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Alexei Starovoitov <ast@kernel.org>,
	Will Deacon <will.deacon@arm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Catalin Marinas <catalin.marinas@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36089 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808AbcANHd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2016 02:33:57 -0500
Received: by mail-pf0-f193.google.com with SMTP id n128so7023922pfn.3
        for <netdev@vger.kernel.org>; Wed, 13 Jan 2016 23:33:57 -0800 (PST)
In-Reply-To: <1452756802-16511-1-git-send-email-zlim.lnx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Code generation functions in arch/arm64/kernel/insn.c previously
BUG_ON invalid parameters. Following change of that behavior, now we
need to handle the error case where AARCH64_BREAK_FAULT is returned.

Instead of error-handling on every emit() in JIT, we add a new
validation pass at the end of JIT compilation. There's no point in
running JITed code at run-time only to trap due to AARCH64_BREAK_FAULT.
Instead, we drop this failed JIT compilation and allow the system to
gracefully fallback on the BPF interpreter.

Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
Suggested-by: Alexei Starovoitov <ast@kernel.org>
---
Per discussion here: http://www.spinics.net/lists/arm-kernel/msg474179.html

arch/arm64/net/bpf_jit_comp.c | 22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/arch/arm64/net/bpf_jit_comp.c b/arch/arm64/net/bpf_jit_comp.c
index d6a53ef..d66bc1f 100644
--- a/arch/arm64/net/bpf_jit_comp.c
+++ b/arch/arm64/net/bpf_jit_comp.c
@@ -1,7 +1,7 @@
 /*
  * BPF JIT compiler for ARM64
  *
- * Copyright (C) 2014-2015 Zi Shen Lim <zlim.lnx@gmail.com>
+ * Copyright (C) 2014-2016 Zi Shen Lim <zlim.lnx@gmail.com>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -726,6 +726,20 @@ static int build_body(struct jit_ctx *ctx)
 	return 0;
 }
 
+static int validate_code(struct jit_ctx *ctx)
+{
+	int i;
+
+	for (i = 0; i < ctx->idx; i++) {
+		u32 a64_insn = le32_to_cpu(ctx->image[i]);
+
+		if (a64_insn == AARCH64_BREAK_FAULT)
+			return -1;
+	}
+
+	return 0;
+}
+
 static inline void bpf_flush_icache(void *start, void *end)
 {
 	flush_icache_range((unsigned long)start, (unsigned long)end);
@@ -788,6 +802,12 @@ void bpf_int_jit_compile(struct bpf_prog *prog)
 
 	build_epilogue(&ctx);
 
+	/* 3. Extra pass to validate JITed code. */
+	if (validate_code(&ctx)) {
+		bpf_jit_binary_free(header);
+		goto out;
+	}
+
 	/* And we're done. */
 	if (bpf_jit_enable > 1)
 		bpf_jit_dump(prog->len, image_size, 2, ctx.image);
-- 
1.9.1
