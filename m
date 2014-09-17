From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net] sparc: bpf_jit: fix support for ldx/stx mem and SKF_AD_VLAN_TAG
Date: Tue, 16 Sep 2014 18:32:58 -0700
Message-ID: <1410917578-5122-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:49091 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754724AbaIQBdH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 21:33:07 -0400
Received: by mail-pd0-f174.google.com with SMTP id v10so962348pde.19
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 18:33:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix several issues in sparc BPF JIT compiler.

ldx/stx related:
. classic BPF instructions that access mem[] slots were not setting
  SEEN_MEM flag, so stack wasn't allocated. Fix that by advertising
  correct flags

. LDX/STX instructions were missing SEEN_XREG, so register value
  could have leaked to user space. Fix it.

. since stack for mem[] slots is allocated with 'sub %sp' instead
  of 'save %sp', use %sp as base register instead of %fp.

. ldx mem[0] means first slot in classic BPF which should have
  -4 offset instead of 0.

. sparc64 needs 2047 stack bias as per ABI to access stack

. emit_stmem() was using LD32I macro instead of ST32I

SKF_AD_VLAN_TAG* related:
. SKF_AD_VLAN_TAG_PRESENT must return 1 or 0 instead of '> 0' or 0
  as per classic BPF de facto standard

. SKF_AD_VLAN_TAG needs to mask the field correctly

Fixes: 2809a2087cc4 ("net: filter: Just In Time compiler for sparc")
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---

tested on sparc64 qemu with test_bpf, compile tested only on sparc32

After these fixes, test_bpf w/JIT fails only two tests:
LD_ABS_LL and LD_ABS_NET. I'm still debugging what's wrong there.

 arch/sparc/net/bpf_jit_comp.c |   25 ++++++++++++++++++-------
 1 file changed, 18 insertions(+), 7 deletions(-)

diff --git a/arch/sparc/net/bpf_jit_comp.c b/arch/sparc/net/bpf_jit_comp.c
index 1f76c22..51ae87b 100644
--- a/arch/sparc/net/bpf_jit_comp.c
+++ b/arch/sparc/net/bpf_jit_comp.c
@@ -234,12 +234,18 @@ do {	BUILD_BUG_ON(FIELD_SIZEOF(STRUCT, FIELD) != sizeof(u8));	\
 	__emit_load8(BASE, STRUCT, FIELD, DEST);			\
 } while (0)
 
-#define emit_ldmem(OFF, DEST)					\
-do {	*prog++ = LD32I | RS1(FP) | S13(-(OFF)) | RD(DEST);	\
+#ifdef CONFIG_SPARC64
+#define BIAS (STACK_BIAS - 4)
+#else
+#define BIAS (-4)
+#endif
+
+#define emit_ldmem(OFF, DEST)						\
+do {	*prog++ = LD32I | RS1(SP) | S13(BIAS - (OFF)) | RD(DEST);	\
 } while (0)
 
-#define emit_stmem(OFF, SRC)					\
-do {	*prog++ = LD32I | RS1(FP) | S13(-(OFF)) | RD(SRC);	\
+#define emit_stmem(OFF, SRC)						\
+do {	*prog++ = ST32I | RS1(SP) | S13(BIAS - (OFF)) | RD(SRC);	\
 } while (0)
 
 #ifdef CONFIG_SMP
@@ -615,10 +621,11 @@ void bpf_jit_compile(struct bpf_prog *fp)
 			case BPF_ANC | SKF_AD_VLAN_TAG:
 			case BPF_ANC | SKF_AD_VLAN_TAG_PRESENT:
 				emit_skb_load16(vlan_tci, r_A);
-				if (code == (BPF_ANC | SKF_AD_VLAN_TAG)) {
-					emit_andi(r_A, VLAN_VID_MASK, r_A);
+				if (code != (BPF_ANC | SKF_AD_VLAN_TAG)) {
+					emit_alu_K(SRL, 12);
+					emit_andi(r_A, 1, r_A);
 				} else {
-					emit_loadimm(VLAN_TAG_PRESENT, r_TMP);
+					emit_loadimm(~VLAN_TAG_PRESENT, r_TMP);
 					emit_and(r_A, r_TMP, r_A);
 				}
 				break;
@@ -630,15 +637,19 @@ void bpf_jit_compile(struct bpf_prog *fp)
 				emit_loadimm(K, r_X);
 				break;
 			case BPF_LD | BPF_MEM:
+				seen |= SEEN_MEM;
 				emit_ldmem(K * 4, r_A);
 				break;
 			case BPF_LDX | BPF_MEM:
+				seen |= SEEN_MEM | SEEN_XREG;
 				emit_ldmem(K * 4, r_X);
 				break;
 			case BPF_ST:
+				seen |= SEEN_MEM;
 				emit_stmem(K * 4, r_A);
 				break;
 			case BPF_STX:
+				seen |= SEEN_MEM | SEEN_XREG;
 				emit_stmem(K * 4, r_X);
 				break;
 
-- 
1.7.9.5
