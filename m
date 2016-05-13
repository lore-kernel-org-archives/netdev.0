From: Zi Shen Lim <zlim.lnx@gmail.com>
Subject: [PATCH] arm64: bpf: jit JMP_JSET_{X,K}
Date: Thu, 12 May 2016 23:37:58 -0700
Message-ID: <1463121478-18484-1-git-send-email-zlim.lnx@gmail.com>
Cc: Zi Shen Lim <zlim.lnx@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Yang Shi <yang.shi@linaro.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Will Deacon <will.deacon@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33761 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750961AbcEMGiD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 02:38:03 -0400
Received: by mail-pf0-f193.google.com with SMTP id y7so8585332pfb.0
        for <netdev@vger.kernel.org>; Thu, 12 May 2016 23:38:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Original implementation commit e54bcde3d69d ("arm64: eBPF JIT compiler")
had the relevant code paths, but due to an oversight always fail jiting.

As a result, we had been falling back to BPF interpreter whenever a BPF
program has JMP_JSET_{X,K} instructions.

With this fix, we confirm that the corresponding tests in lib/test_bpf
continue to pass, and also jited.

...
[    2.784553] test_bpf: #30 JSET jited:1 188 192 197 PASS
[    2.791373] test_bpf: #31 tcpdump port 22 jited:1 325 677 625 PASS
[    2.808800] test_bpf: #32 tcpdump complex jited:1 323 731 991 PASS
...
[    3.190759] test_bpf: #237 JMP_JSET_K: if (0x3 & 0x2) return 1 jited:1 110 PASS
[    3.192524] test_bpf: #238 JMP_JSET_K: if (0x3 & 0xffffffff) return 1 jited:1 98 PASS
[    3.211014] test_bpf: #249 JMP_JSET_X: if (0x3 & 0x2) return 1 jited:1 120 PASS
[    3.212973] test_bpf: #250 JMP_JSET_X: if (0x3 & 0xffffffff) return 1 jited:1 89 PASS
...

Fixes: e54bcde3d69d ("arm64: eBPF JIT compiler")
Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
---
 arch/arm64/net/bpf_jit_comp.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm64/net/bpf_jit_comp.c b/arch/arm64/net/bpf_jit_comp.c
index 031ed08..d0d5190 100644
--- a/arch/arm64/net/bpf_jit_comp.c
+++ b/arch/arm64/net/bpf_jit_comp.c
@@ -478,6 +478,7 @@ emit_cond_jmp:
 		case BPF_JGE:
 			jmp_cond = A64_COND_CS;
 			break;
+		case BPF_JSET:
 		case BPF_JNE:
 			jmp_cond = A64_COND_NE;
 			break;
-- 
1.9.1
