From: akpm@osdl.org
Subject: [patch 5/5] aes-586-asm: small optimizations
Date: Mon, 25 Oct 2004 12:38:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410251940.i9PJeQ910847@mail.osdl.org>
Cc: jmorris@redhat.com, netdev@oss.sgi.com, akpm@osdl.org,
        vda@port.imtp.ilyichevsk.odessa.ua
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>

- recode back-to-back fwd_rnd() pairs to avoid two register moves.

- ditto for inv_rnd().

- optimize out lea 0(%ebp),%ebp

- remove two stray insns

# size aes-i586-asm.o.org aes-i586-asm.o
   text    data     bss     dec     hex filename
   5971       0       0    5971    1753 aes-i586-asm.o.org
   5905       0       0    5905    1711 aes-i586-asm.o

Overall, patch does not add and does not modify any insns, only removes a
handful of them.  However, speed difference is way below noise level.

Run-tested with tcrypt module.

Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/arch/i386/crypto/aes-i586-asm.S |  168 +++++++++++++++++++-------------
 1 files changed, 103 insertions(+), 65 deletions(-)

diff -puN arch/i386/crypto/aes-i586-asm.S~aes-586-asm-small-optimizations arch/i386/crypto/aes-i586-asm.S
--- 25/arch/i386/crypto/aes-i586-asm.S~aes-586-asm-small-optimizations	2004-10-03 16:02:36.483762024 -0700
+++ 25-akpm/arch/i386/crypto/aes-i586-asm.S	2004-10-03 16:02:36.487761416 -0700
@@ -104,7 +104,8 @@
 	xor     table+3*tlen(,%idx,4),%a4;
 
 // initialise output registers from the key schedule
-// NB: original a3 is in idx on exit
+// NB1: original value of a3 is in idx on exit
+// NB2: original values of a1,a2,a4 aren't used
 #define do_fcol(table, a1,a2,a3,a4, idx, tmp, sched) \
 	mov     0 sched,%a1;			\
 	movzx   %l(idx),%tmp;			\
@@ -122,7 +123,8 @@
 	xor     table+2*tlen(,%tmp,4),%a3;
 
 // initialise output registers from the key schedule
-// NB: original a3 is in idx on exit
+// NB1: original value of a3 is in idx on exit
+// NB2: original values of a1,a2,a4 aren't used
 #define do_icol(table, a1,a2,a3,a4, idx, tmp, sched) \
 	mov     0 sched,%a1;			\
 	movzx   %l(idx),%tmp;			\
@@ -147,41 +149,75 @@
 #define restore(a1, a2)		\
 	mov     4*a2(%esp),%a1
 
-// This macro performs a forward encryption cycle. It is entered with
-// the first previous round column values in r0, r1, r4 and r5 and
-// exits with the final values in the same registers, using stack
+// These macros perform a forward encryption cycle. They are entered with
+// the first previous round column values in r0,r1,r4,r5 and
+// exit with the final values in the same registers, using stack
+// for temporary storage.
+
+// round column values
+// on entry: r0,r1,r4,r5
+// on exit:  r2,r1,r4,r5
+#define fwd_rnd1(arg, table)						\
+	save   (0,r1);							\
+	save   (1,r5);							\
+									\
+	/* compute new column values */					\
+	do_fcol(table, r2,r5,r4,r1, r0,r3, arg);	/* idx=r0 */	\
+	do_col (table, r4,r1,r2,r5, r0,r3);		/* idx=r4 */	\
+	restore(r0,0);							\
+	do_col (table, r1,r2,r5,r4, r0,r3);		/* idx=r1 */	\
+	restore(r0,1);							\
+	do_col (table, r5,r4,r1,r2, r0,r3);		/* idx=r5 */
+
+// round column values
+// on entry: r2,r1,r4,r5
+// on exit:  r0,r1,r4,r5
+#define fwd_rnd2(arg, table)						\
+	save   (0,r1);							\
+	save   (1,r5);							\
+									\
+	/* compute new column values */					\
+	do_fcol(table, r0,r5,r4,r1, r2,r3, arg);	/* idx=r2 */	\
+	do_col (table, r4,r1,r0,r5, r2,r3);		/* idx=r4 */	\
+	restore(r2,0);							\
+	do_col (table, r1,r0,r5,r4, r2,r3);		/* idx=r1 */	\
+	restore(r2,1);							\
+	do_col (table, r5,r4,r1,r0, r2,r3);		/* idx=r5 */
+
+// These macros performs an inverse encryption cycle. They are entered with
+// the first previous round column values in r0,r1,r4,r5 and
+// exit with the final values in the same registers, using stack
 // for temporary storage
 
-#define fwd_rnd(arg, table)					\
-	mov     %r0,%r2;					\
-	save   (0,r1);						\
-	save   (1,r5);						\
-								\
-	/* compute new column values */				\
-	do_fcol(table, r0,r5,r4,r1, r2,r3, arg);		\
-	do_col (table, r4,r1,r0,r5, r2,r3);			\
-	restore(r2,0);						\
-	do_col (table, r1,r0,r5,r4, r2,r3);			\
-	restore(r2,1);						\
-	do_col (table, r5,r4,r1,r0, r2,r3);
-
-// This macro performs an inverse encryption cycle. It is entered with
-// the first previous round column values in r0, r1, r4 and r5 and
-// exits with the final values in the same registers, using stack
-// for temporary storage
-
-#define inv_rnd(arg, table)					\
-	mov     %r0,%r2;					\
-	save    (0,r1);						\
-	save    (1,r5);						\
-								\
-	/* compute new column values */				\
-	do_icol(table, r0,r1,r4,r5, r2,r3, arg);		\
-	do_col (table, r4,r5,r0,r1, r2,r3);			\
-	restore(r2,0);						\
-	do_col (table, r1,r4,r5,r0, r2,r3);			\
-	restore(r2,1);						\
-	do_col (table, r5,r0,r1,r4, r2,r3);
+// round column values
+// on entry: r0,r1,r4,r5
+// on exit:  r2,r1,r4,r5
+#define inv_rnd1(arg, table)						\
+	save    (0,r1);							\
+	save    (1,r5);							\
+									\
+	/* compute new column values */					\
+	do_icol(table, r2,r1,r4,r5, r0,r3, arg);	/* idx=r0 */	\
+	do_col (table, r4,r5,r2,r1, r0,r3);		/* idx=r4 */	\
+	restore(r0,0);							\
+	do_col (table, r1,r4,r5,r2, r0,r3);		/* idx=r1 */	\
+	restore(r0,1);							\
+	do_col (table, r5,r2,r1,r4, r0,r3);		/* idx=r5 */
+
+// round column values
+// on entry: r2,r1,r4,r5
+// on exit:  r0,r1,r4,r5
+#define inv_rnd2(arg, table)						\
+	save    (0,r1);							\
+	save    (1,r5);							\
+									\
+	/* compute new column values */					\
+	do_icol(table, r0,r1,r4,r5, r2,r3, arg);	/* idx=r2 */	\
+	do_col (table, r4,r5,r0,r1, r2,r3);		/* idx=r4 */	\
+	restore(r2,0);							\
+	do_col (table, r1,r4,r5,r0, r2,r3);		/* idx=r1 */	\
+	restore(r2,1);							\
+	do_col (table, r5,r0,r1,r4, r2,r3);		/* idx=r5 */
 
 // AES (Rijndael) Encryption Subroutine
 
@@ -195,7 +231,6 @@
 aes_enc_blk:
 	push    %ebp
 	mov     ctx(%esp),%ebp      // pointer to context
-	xor     %eax,%eax
 
 // CAUTION: the order and the values used in these assigns 
 // rely on the register mappings
@@ -205,7 +240,9 @@ aes_enc_blk:
 	push    %esi
 	mov     nrnd(%ebp),%r3   // number of rounds
 	push    %edi
+#if ekey != 0
 	lea     ekey(%ebp),%ebp  // key pointer
+#endif
 
 // input four columns and xor in first round key
 
@@ -227,20 +264,20 @@ aes_enc_blk:
 	je      3f              // 12 rounds for 128-bit key
 	add     $32,%ebp
 
-2:	fwd_rnd( -64(%ebp) ,ft_tab)	// 14 rounds for 128-bit key
-	fwd_rnd( -48(%ebp) ,ft_tab)
-3:	fwd_rnd( -32(%ebp) ,ft_tab)	// 12 rounds for 128-bit key
-	fwd_rnd( -16(%ebp) ,ft_tab)
-4:	fwd_rnd(    (%ebp) ,ft_tab)	// 10 rounds for 128-bit key
-	fwd_rnd( +16(%ebp) ,ft_tab)
-	fwd_rnd( +32(%ebp) ,ft_tab)
-	fwd_rnd( +48(%ebp) ,ft_tab)
-	fwd_rnd( +64(%ebp) ,ft_tab)
-	fwd_rnd( +80(%ebp) ,ft_tab)
-	fwd_rnd( +96(%ebp) ,ft_tab)
-	fwd_rnd(+112(%ebp) ,ft_tab)
-	fwd_rnd(+128(%ebp) ,ft_tab)
-	fwd_rnd(+144(%ebp) ,fl_tab)	// last round uses a different table
+2:	fwd_rnd1( -64(%ebp) ,ft_tab)	// 14 rounds for 128-bit key
+	fwd_rnd2( -48(%ebp) ,ft_tab)
+3:	fwd_rnd1( -32(%ebp) ,ft_tab)	// 12 rounds for 128-bit key
+	fwd_rnd2( -16(%ebp) ,ft_tab)
+4:	fwd_rnd1(    (%ebp) ,ft_tab)	// 10 rounds for 128-bit key
+	fwd_rnd2( +16(%ebp) ,ft_tab)
+	fwd_rnd1( +32(%ebp) ,ft_tab)
+	fwd_rnd2( +48(%ebp) ,ft_tab)
+	fwd_rnd1( +64(%ebp) ,ft_tab)
+	fwd_rnd2( +80(%ebp) ,ft_tab)
+	fwd_rnd1( +96(%ebp) ,ft_tab)
+	fwd_rnd2(+112(%ebp) ,ft_tab)
+	fwd_rnd1(+128(%ebp) ,ft_tab)
+	fwd_rnd2(+144(%ebp) ,fl_tab)	// last round uses a different table
 
 // move final values to the output array.  CAUTION: the 
 // order of these assigns rely on the register mappings
@@ -270,7 +307,6 @@ aes_enc_blk:
 aes_dec_blk:
 	push    %ebp
 	mov     ctx(%esp),%ebp       // pointer to context
-	xor     %eax,%eax
 
 // CAUTION: the order and the values used in these assigns 
 // rely on the register mappings
@@ -280,7 +316,9 @@ aes_dec_blk:
 	push    %esi
 	mov     nrnd(%ebp),%r3   // number of rounds
 	push    %edi
+#if dkey != 0
 	lea     dkey(%ebp),%ebp  // key pointer
+#endif
 	mov     %r3,%r0
 	shl     $4,%r0
 	add     %r0,%ebp
@@ -305,20 +343,20 @@ aes_dec_blk:
 	je      3f              // 12 rounds for 128-bit key
 	sub     $32,%ebp
 
-2:	inv_rnd( +64(%ebp), it_tab)	// 14 rounds for 128-bit key
-	inv_rnd( +48(%ebp), it_tab)
-3:	inv_rnd( +32(%ebp), it_tab)	// 12 rounds for 128-bit key
-	inv_rnd( +16(%ebp), it_tab)
-4:	inv_rnd(    (%ebp), it_tab)	// 10 rounds for 128-bit key
-	inv_rnd( -16(%ebp), it_tab)
-	inv_rnd( -32(%ebp), it_tab)
-	inv_rnd( -48(%ebp), it_tab)
-	inv_rnd( -64(%ebp), it_tab)
-	inv_rnd( -80(%ebp), it_tab)
-	inv_rnd( -96(%ebp), it_tab)
-	inv_rnd(-112(%ebp), it_tab)
-	inv_rnd(-128(%ebp), it_tab)
-	inv_rnd(-144(%ebp), il_tab)	// last round uses a different table
+2:	inv_rnd1( +64(%ebp), it_tab)	// 14 rounds for 128-bit key
+	inv_rnd2( +48(%ebp), it_tab)
+3:	inv_rnd1( +32(%ebp), it_tab)	// 12 rounds for 128-bit key
+	inv_rnd2( +16(%ebp), it_tab)
+4:	inv_rnd1(    (%ebp), it_tab)	// 10 rounds for 128-bit key
+	inv_rnd2( -16(%ebp), it_tab)
+	inv_rnd1( -32(%ebp), it_tab)
+	inv_rnd2( -48(%ebp), it_tab)
+	inv_rnd1( -64(%ebp), it_tab)
+	inv_rnd2( -80(%ebp), it_tab)
+	inv_rnd1( -96(%ebp), it_tab)
+	inv_rnd2(-112(%ebp), it_tab)
+	inv_rnd1(-128(%ebp), it_tab)
+	inv_rnd2(-144(%ebp), il_tab)	// last round uses a different table
 
 // move final values to the output array.  CAUTION: the 
 // order of these assigns rely on the register mappings
_
