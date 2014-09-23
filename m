From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net] sparc: bpf_jit: fix loads from negative offsets
Date: Tue, 23 Sep 2014 13:50:10 -0700
Message-ID: <1411505410-25215-1-git-send-email-ast@plumgrid.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:41607 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753947AbaIWUuV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 16:50:21 -0400
Received: by mail-pd0-f181.google.com with SMTP id r10so7205910pdi.40
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2014 13:50:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- fix BPF_LD|ABS|IND from negative offsets:
  make sure to sign extend lower 32 bits in 64-bit register
  before calling C helpers from JITed code, otherwise 'int k'
  argument of bpf_internal_load_pointer_neg_helper() function
  will be added as large unsigned integer, causing packet size
  check to trigger and abort the program.

  It's worth noting that JITed code for 'A = A op K' will affect
  upper 32 bits differently depending whether K is simm13 or not.
  Since small constants are sign extended, whereas large constants
  are stored in temp register and zero extended.
  That is ok and we don't have to pay a penalty of sign extension
  for every sethi, since all classic BPF instructions have 32-bit
  semantics and we only need to set correct upper bits when
  transitioning from JITed code into C.

- though instructions 'A &= 0' and 'A *= 0' are odd, JIT compiler
  should not optimize them out

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---

More detailed explanation of 1st bug:
  BPF_STMT(BPF_LD | BPF_B | BPF_ABS, SKF_LL_OFF)
will be JITed as:
  sethi	%hi(0xffe00000), %g3
  or	%g3, 0, %g3
  call	bpf_jit_load_byte_negative_offset
which will do:
  mov	%g3, %o1
  call	bpf_internal_load_pointer_neg_helper
  mov	1, %o2

void *bpf_internal_load_pointer_neg_helper(const struct sk_buff *skb, int k, unsigned int size)
{
  ...
  ptr = skb_mac_header(skb) + k - SKF_LL_OFF;
  here 'k' will be added as 0xffe00000 instead of SKF_LL_OFF == -0x200000

After these fixes, test_bpf is now clean on sparc64.
Compile tested only on sparc32

 arch/sparc/net/bpf_jit_asm.S  |    3 +++
 arch/sparc/net/bpf_jit_comp.c |    2 +-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/arch/sparc/net/bpf_jit_asm.S b/arch/sparc/net/bpf_jit_asm.S
index 9d016c7..8c83f4b 100644
--- a/arch/sparc/net/bpf_jit_asm.S
+++ b/arch/sparc/net/bpf_jit_asm.S
@@ -6,10 +6,12 @@
 #define SAVE_SZ		176
 #define SCRATCH_OFF	STACK_BIAS + 128
 #define BE_PTR(label)	be,pn %xcc, label
+#define SIGN_EXTEND(reg)	sra reg, 0, reg
 #else
 #define SAVE_SZ		96
 #define SCRATCH_OFF	72
 #define BE_PTR(label)	be label
+#define SIGN_EXTEND(reg)
 #endif
 
 #define SKF_MAX_NEG_OFF	(-0x200000) /* SKF_LL_OFF from filter.h */
@@ -135,6 +137,7 @@ bpf_slow_path_byte_msh:
 	save	%sp, -SAVE_SZ, %sp;			\
 	mov	%i0, %o0;				\
 	mov	r_OFF, %o1;				\
+	SIGN_EXTEND(%o1);				\
 	call	bpf_internal_load_pointer_neg_helper;	\
 	 mov	(LEN), %o2;				\
 	mov	%o0, r_TMP;				\
diff --git a/arch/sparc/net/bpf_jit_comp.c b/arch/sparc/net/bpf_jit_comp.c
index 51ae87b..ece4af0 100644
--- a/arch/sparc/net/bpf_jit_comp.c
+++ b/arch/sparc/net/bpf_jit_comp.c
@@ -184,7 +184,7 @@ do {								\
 	 */
 #define emit_alu_K(OPCODE, K)					\
 do {								\
-	if (K) {						\
+	if (K || OPCODE == AND || OPCODE == MUL) {		\
 		unsigned int _insn = OPCODE;			\
 		_insn |= RS1(r_A) | RD(r_A);			\
 		if (is_simm13(K)) {				\
-- 
1.7.9.5
