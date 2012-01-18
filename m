From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: bpf_jit: fix divide by 0 generation
Date: Wed, 18 Jan 2012 08:58:53 +0100
Message-ID: <1326873533.2606.46.camel@edumazet-laptop>
References: <20120118022709.GA4167@linuxace.com>
	 <1326867428.2606.39.camel@edumazet-laptop>
	 <1326871835.2606.40.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Oester <kernel@linuxace.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:35041 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753023Ab2ARH65 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 02:58:57 -0500
Received: by wgbdq11 with SMTP id dq11so2889977wgb.1
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2012 23:58:56 -0800 (PST)
In-Reply-To: <1326871835.2606.40.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Target of the conditional jump in case a divide by 0 is performed by a
bpf is wrong.

Also change the wrong length detection at the end of code generation to
issue a more explicit message and abort the compilation.

Reported-by: Phil Oester <kernel@linuxace.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
Please Phil test following fix, thanks !

 arch/x86/net/bpf_jit_comp.c |   22 ++++++++++++++++------
 1 file changed, 16 insertions(+), 6 deletions(-)

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 7b65f75..5dfa72c 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -260,9 +260,14 @@ void bpf_jit_compile(struct sk_filter *fp)
 			case BPF_S_ALU_DIV_X: /* A /= X; */
 				seen |= SEEN_XREG;
 				EMIT2(0x85, 0xdb);	/* test %ebx,%ebx */
-				if (pc_ret0 != -1)
-					EMIT_COND_JMP(X86_JE, addrs[pc_ret0] - (addrs[i] - 4));
-				else {
+				if (pc_ret0 > 0) {
+					/* addrs[pc_ret0 - 1] is start address of target
+					 * (addrs[i] - 4) is the address following this jmp
+					 * ("xor %edx,%edx; div %ebx" being 4 bytes long)
+					 */
+					EMIT_COND_JMP(X86_JE, addrs[pc_ret0 - 1] -
+								(addrs[i] - 4));
+				} else {
 					EMIT_COND_JMP(X86_JNE, 2 + 5);
 					CLEAR_A();
 					EMIT1_off32(0xe9, cleanup_addr - (addrs[i] - 4)); /* jmp .+off32 */
@@ -483,8 +488,9 @@ common_load:			seen |= SEEN_DATAREF;
 				goto common_load;
 			case BPF_S_LDX_B_MSH:
 				if ((int)K < 0) {
-					if (pc_ret0 != -1) {
-						EMIT_JMP(addrs[pc_ret0] - addrs[i]);
+					if (pc_ret0 > 0) {
+						/* addrs[pc_ret0 - 1] is the start address */
+						EMIT_JMP(addrs[pc_ret0 - 1] - addrs[i]);
 						break;
 					}
 					CLEAR_A();
@@ -584,6 +590,7 @@ cond_branch:			f_offset = addrs[i + filter[i].jf] - addrs[i];
 			ilen = prog - temp;
 			if (image) {
 				if (unlikely(proglen + ilen > oldproglen)) {
+bpf_fatal_error:
 					pr_err("bpb_jit_compile fatal error\n");
 					kfree(addrs);
 					module_free(NULL, image);
@@ -605,7 +612,10 @@ cond_branch:			f_offset = addrs[i + filter[i].jf] - addrs[i];
 			cleanup_addr -= 4; /* mov  -8(%rbp),%rbx */
 
 		if (image) {
-			WARN_ON(proglen != oldproglen);
+			if (proglen != oldproglen) {
+				pr_err("proglen=%u != oldproglen=%u\n", proglen, oldproglen);
+				goto bpf_fatal_error;
+			}
 			break;
 		}
 		if (proglen == oldproglen) {
