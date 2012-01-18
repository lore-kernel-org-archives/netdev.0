From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2] net: bpf_jit: fix divide by 0 generation
Date: Wed, 18 Jan 2012 18:21:42 +0100
Message-ID: <1326907302.4910.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20120118022709.GA4167@linuxace.com>
	 <1326867428.2606.39.camel@edumazet-laptop>
	 <1326871835.2606.40.camel@edumazet-laptop>
	 <1326873533.2606.46.camel@edumazet-laptop>
	 <20120118155747.GA4991@linuxace.com>
	 <1326902511.2316.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Phil Oester <kernel@linuxace.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:61341 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932197Ab2ARRVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 12:21:46 -0500
Received: by wibhm6 with SMTP id hm6so2390885wib.19
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2012 09:21:45 -0800 (PST)
In-Reply-To: <1326902511.2316.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several problems fixed in this patch :

1) Target of the conditional jump in case a divide by 0 is performed
   by a bpf is wrong.

2) Must 'generate' the full function prologue/epilogue at pass=0,
   or else we can stop too early in pass=1 if the proglen doesnt change.
   (if the increase of prologue/epilogue equals decrease of all
    instructions length because some jumps are converted to near jumps)

3) Change the wrong length detection at the end of code generation to
   issue a more explicit message, no need for a full stack trace.

Reported-by: Phil Oester <kernel@linuxace.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
Please Phil test following fix, thanks !

 arch/x86/net/bpf_jit_comp.c |   36 ++++++++++++++++++++--------------
 1 file changed, 22 insertions(+), 14 deletions(-)

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 7b65f75..7c1b765 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -151,17 +151,18 @@ void bpf_jit_compile(struct sk_filter *fp)
 	cleanup_addr = proglen; /* epilogue address */
 
 	for (pass = 0; pass < 10; pass++) {
+		u8 seen_or_pass0 = (pass == 0) ? (SEEN_XREG | SEEN_DATAREF | SEEN_MEM) : seen;
 		/* no prologue/epilogue for trivial filters (RET something) */
 		proglen = 0;
 		prog = temp;
 
-		if (seen) {
+		if (seen_or_pass0) {
 			EMIT4(0x55, 0x48, 0x89, 0xe5); /* push %rbp; mov %rsp,%rbp */
 			EMIT4(0x48, 0x83, 0xec, 96);	/* subq  $96,%rsp	*/
 			/* note : must save %rbx in case bpf_error is hit */
-			if (seen & (SEEN_XREG | SEEN_DATAREF))
+			if (seen_or_pass0 & (SEEN_XREG | SEEN_DATAREF))
 				EMIT4(0x48, 0x89, 0x5d, 0xf8); /* mov %rbx, -8(%rbp) */
-			if (seen & SEEN_XREG)
+			if (seen_or_pass0 & SEEN_XREG)
 				CLEAR_X(); /* make sure we dont leek kernel memory */
 
 			/*
@@ -170,7 +171,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 			 *  r9 = skb->len - skb->data_len
 			 *  r8 = skb->data
 			 */
-			if (seen & SEEN_DATAREF) {
+			if (seen_or_pass0 & SEEN_DATAREF) {
 				if (offsetof(struct sk_buff, len) <= 127)
 					/* mov    off8(%rdi),%r9d */
 					EMIT4(0x44, 0x8b, 0x4f, offsetof(struct sk_buff, len));
@@ -260,9 +261,14 @@ void bpf_jit_compile(struct sk_filter *fp)
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
@@ -335,12 +341,12 @@ void bpf_jit_compile(struct sk_filter *fp)
 				}
 				/* fallinto */
 			case BPF_S_RET_A:
-				if (seen) {
+				if (seen_or_pass0) {
 					if (i != flen - 1) {
 						EMIT_JMP(cleanup_addr - addrs[i]);
 						break;
 					}
-					if (seen & SEEN_XREG)
+					if (seen_or_pass0 & SEEN_XREG)
 						EMIT4(0x48, 0x8b, 0x5d, 0xf8);  /* mov  -8(%rbp),%rbx */
 					EMIT1(0xc9);		/* leaveq */
 				}
@@ -483,8 +489,9 @@ common_load:			seen |= SEEN_DATAREF;
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
@@ -599,13 +606,14 @@ cond_branch:			f_offset = addrs[i + filter[i].jf] - addrs[i];
 		 * use it to give the cleanup instruction(s) addr
 		 */
 		cleanup_addr = proglen - 1; /* ret */
-		if (seen)
+		if (seen_or_pass0)
 			cleanup_addr -= 1; /* leaveq */
-		if (seen & SEEN_XREG)
+		if (seen_or_pass0 & SEEN_XREG)
 			cleanup_addr -= 4; /* mov  -8(%rbp),%rbx */
 
 		if (image) {
-			WARN_ON(proglen != oldproglen);
+			if (proglen != oldproglen)
+				pr_err("bpb_jit_compile proglen=%u != oldproglen=%u\n", proglen, oldproglen);
 			break;
 		}
 		if (proglen == oldproglen) {
