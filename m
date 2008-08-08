From: Suresh Siddha <suresh.b.siddha@intel.com>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem with fpu state changes
Date: Fri, 8 Aug 2008 16:11:21 -0700
Message-ID: <20080808231121.GA13158@linux-os.sc.intel.com>
References: <200807171653.59177.wolfgang.walter@stwm.de> <20080806201401.GA607@linux-os.sc.intel.com> <200808071823.02364.wolfgang.walter@stwm.de> <200808081236.55172.wolfgang.walter@stwm.de> <20080808185356.GC607@linux-os.sc.intel.com> <489C97FB.2030408@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Siddha, Suresh B" <suresh.b.siddha@intel.com>,
	Wolfgang Walter <wolfgang.walter@stwm.de>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>,
	"viro@ZenIV.linux.org.uk" <viro@ZenIV.linux.org.uk>,
	"vegard.nossum@gmail.com" <vegard.nossum@gmail.com>
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:61147 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760917AbYHHXLX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Aug 2008 19:11:23 -0400
Content-Disposition: inline
In-Reply-To: <489C97FB.2030408@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Walter, Viro,

As I can't test, can you please test this and Ack.

thanks,
suresh
---
[patch] fix via padlock instruction usage with kernel_fpu_begin/end()

Wolfgang Walter reported this oops on his via C3 using padlock for
AES-encryption:

##################################################################

BUG: unable to handle kernel NULL pointer dereference at 000001f0
IP: [<c01028c5>] __switch_to+0x30/0x117
*pde = 00000000
Oops: 0002 [#1] PREEMPT
Modules linked in:

Pid: 2071, comm: sleep Not tainted (2.6.26 #11)
EIP: 0060:[<c01028c5>] EFLAGS: 00010002 CPU: 0
EIP is at __switch_to+0x30/0x117
EAX: 00000000 EBX: c0493300 ECX: dc48dd00 EDX: c0493300
ESI: dc48dd00 EDI: c0493530 EBP: c04cff8c ESP: c04cff7c
 DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
Process sleep (pid: 2071, ti=c04ce000 task=dc48dd00 task.ti=d2fe6000)
Stack: dc48df30 c0493300 00000000 00000000 d2fe7f44 c03b5b43 c04cffc8 00000046
       c0131856 0000005a dc472d3c c0493300 c0493470 d983ae00 00002696 00000000
       c0239f54 00000000 c04c4000 c04cffd8 c01025fe c04f3740 00049800 c04cffe0
Call Trace:
 [<c03b5b43>] ? schedule+0x285/0x2ff
 [<c0131856>] ? pm_qos_requirement+0x3c/0x53
 [<c0239f54>] ? acpi_processor_idle+0x0/0x434
 [<c01025fe>] ? cpu_idle+0x73/0x7f
 [<c03a4dcd>] ? rest_init+0x61/0x63
 =======================

Wolfgang also found out that adding kernel_fpu_begin() and kernel_fpu_end()
around the padlock instructions fix the oops.

Suresh wrote:

These padlock instructions though don't use/touch SSE registers, but it behaves
similar to other SSE instructions. For example, it might cause DNA faults
when cr0.ts is set. While this is a spurious DNA trap, it might cause
oops with the recent fpu code changes.

This is the code sequence  that is probably causing this problem:

a) new app is getting exec'd and it is somewhere in between
   start_thread() and flush_old_exec() in the load_xyz_binary()

b) At pont "a", task's fpu state (like TS_USEDFPU, used_math() etc) is
   cleared.

c) Now we get an interrupt/softirq which starts using these encrypt/decrypt
   routines in the network stack. This generates a math fault (as
   cr0.ts is '1') which sets TS_USEDFPU and restores the math that is
   in the task's xstate.

d) Return to exec code path, which does start_thread() which does
   free_thread_xstate() and sets xstate pointer to NULL while
   the TS_USEDFPU is still set.

e) At the next context switch from the new exec'd task to another task,
   we have a scenarios where TS_USEDFPU is set but xstate pointer is null.
   This can cause an oops during unlazy_fpu() in __switch_to()

Now:

1) This should happen with or with out pre-emption. Viro also encountered
   similar problem with out CONFIG_PREEMPT.

2) kernel_fpu_begin() and kernel_fpu_end() will fix this problem, because
   kernel_fpu_begin() will manually do a clts() and won't run in to the
   situation of setting TS_USEDFPU in step "c" above.

3) This was working before the fpu changes, because its a spurious
   math fault  which doesn't corrupt any fpu/sse registers and the task's
   math state was always in an allocated state.

With out the recent dynamic fpu allocation changes, while we don't see oops,
there is a possible race still present in older kernels(for example,
while kernel is using kernel_fpu_begin() in some optimized clear/copy
page and an interrupt/softirq happens which uses these padlock
instructions generating DNA fault).

For now, fix the padlock instruction usage by calling them inside the
context of kernel_fpu_begin() and kernel_fpu_end()

Next steps:

a) Based on the need, possible introduction of light weight kernel_fpu_*
   routines which will optimize the padlock usage case, where they don't
   touch SSE/FPU registers, but generate DNA.

b) Looking deeper, do we need to disable interrupts in the kernel_fpu_begin()?
   Is there a recursive case, where interrupt context also touches FPU/SSE
   registers?

Reported-and-bisected-by: Wolfgang Walter <wolfgang.walter@stwm.de>
Signed-off-by: Wolfgang Walter <wolfgang.walter@stwm.de>
Signed-off-by: Suresh Siddha <suresh.b.siddha@intel.com>
---

diff --git a/drivers/char/hw_random/via-rng.c b/drivers/char/hw_random/via-rng.c
index f7feae4..3dee9e5 100644
--- a/drivers/char/hw_random/via-rng.c
+++ b/drivers/char/hw_random/via-rng.c
@@ -31,6 +31,7 @@
 #include <asm/io.h>
 #include <asm/msr.h>
 #include <asm/cpufeature.h>
+#include <asm/i387.h>
 
 
 #define PFX	KBUILD_MODNAME ": "
@@ -67,16 +68,22 @@ enum {
  * Another possible performance boost may come from simply buffering
  * until we have 4 bytes, thus returning a u32 at a time,
  * instead of the current u8-at-a-time.
+ *
+ * Padlock instructions can generate a spurious DNA fault, so
+ * we will call them in the context of kernel_fpu_[begin,end].
  */
 
 static inline u32 xstore(u32 *addr, u32 edx_in)
 {
 	u32 eax_out;
 
+	kernel_fpu_begin();
+
 	asm(".byte 0x0F,0xA7,0xC0 /* xstore %%edi (addr=%0) */"
 		:"=m"(*addr), "=a"(eax_out)
 		:"D"(addr), "d"(edx_in));
 
+	kernel_fpu_end();
 	return eax_out;
 }
 
diff --git a/drivers/crypto/padlock-aes.c b/drivers/crypto/padlock-aes.c
index 54a2a16..2c96d85 100644
--- a/drivers/crypto/padlock-aes.c
+++ b/drivers/crypto/padlock-aes.c
@@ -16,6 +16,7 @@
 #include <linux/interrupt.h>
 #include <linux/kernel.h>
 #include <asm/byteorder.h>
+#include <asm/i387.h>
 #include "padlock.h"
 
 /* Control word. */
@@ -141,6 +142,12 @@ static inline void padlock_reset_key(void)
 	asm volatile ("pushfl; popfl");
 }
 
+/*
+ * While the padlock instructions don't use FP/SSE registers, they
+ * generate a spurious DNA fault when cr0.ts is '1'. These instructions
+ * should be used only inside the kernel_fpu_[begin, end] context.
+ */
+
 static inline void padlock_xcrypt(const u8 *input, u8 *output, void *key,
 				  void *control_word)
 {
@@ -206,14 +213,20 @@ static void aes_encrypt(struct crypto_tfm *tfm, u8 *out, const u8 *in)
 {
 	struct aes_ctx *ctx = aes_ctx(tfm);
 	padlock_reset_key();
+
+	kernel_fpu_begin();
 	aes_crypt(in, out, ctx->E, &ctx->cword.encrypt);
+	kernel_fpu_end();
 }
 
 static void aes_decrypt(struct crypto_tfm *tfm, u8 *out, const u8 *in)
 {
 	struct aes_ctx *ctx = aes_ctx(tfm);
 	padlock_reset_key();
+
+	kernel_fpu_begin();
 	aes_crypt(in, out, ctx->D, &ctx->cword.decrypt);
+	kernel_fpu_end();
 }
 
 static struct crypto_alg aes_alg = {
@@ -250,6 +263,7 @@ static int ecb_aes_encrypt(struct blkcipher_desc *desc,
 	blkcipher_walk_init(&walk, dst, src, nbytes);
 	err = blkcipher_walk_virt(desc, &walk);
 
+	kernel_fpu_begin();
 	while ((nbytes = walk.nbytes)) {
 		padlock_xcrypt_ecb(walk.src.virt.addr, walk.dst.virt.addr,
 				   ctx->E, &ctx->cword.encrypt,
@@ -257,6 +271,7 @@ static int ecb_aes_encrypt(struct blkcipher_desc *desc,
 		nbytes &= AES_BLOCK_SIZE - 1;
 		err = blkcipher_walk_done(desc, &walk, nbytes);
 	}
+	kernel_fpu_end();
 
 	return err;
 }
@@ -274,6 +289,7 @@ static int ecb_aes_decrypt(struct blkcipher_desc *desc,
 	blkcipher_walk_init(&walk, dst, src, nbytes);
 	err = blkcipher_walk_virt(desc, &walk);
 
+	kernel_fpu_begin();
 	while ((nbytes = walk.nbytes)) {
 		padlock_xcrypt_ecb(walk.src.virt.addr, walk.dst.virt.addr,
 				   ctx->D, &ctx->cword.decrypt,
@@ -281,6 +297,7 @@ static int ecb_aes_decrypt(struct blkcipher_desc *desc,
 		nbytes &= AES_BLOCK_SIZE - 1;
 		err = blkcipher_walk_done(desc, &walk, nbytes);
 	}
+	kernel_fpu_end();
 
 	return err;
 }
@@ -320,6 +337,7 @@ static int cbc_aes_encrypt(struct blkcipher_desc *desc,
 	blkcipher_walk_init(&walk, dst, src, nbytes);
 	err = blkcipher_walk_virt(desc, &walk);
 
+	kernel_fpu_begin();
 	while ((nbytes = walk.nbytes)) {
 		u8 *iv = padlock_xcrypt_cbc(walk.src.virt.addr,
 					    walk.dst.virt.addr, ctx->E,
@@ -329,6 +347,7 @@ static int cbc_aes_encrypt(struct blkcipher_desc *desc,
 		nbytes &= AES_BLOCK_SIZE - 1;
 		err = blkcipher_walk_done(desc, &walk, nbytes);
 	}
+	kernel_fpu_end();
 
 	return err;
 }
@@ -346,6 +365,7 @@ static int cbc_aes_decrypt(struct blkcipher_desc *desc,
 	blkcipher_walk_init(&walk, dst, src, nbytes);
 	err = blkcipher_walk_virt(desc, &walk);
 
+	kernel_fpu_begin();
 	while ((nbytes = walk.nbytes)) {
 		padlock_xcrypt_cbc(walk.src.virt.addr, walk.dst.virt.addr,
 				   ctx->D, walk.iv, &ctx->cword.decrypt,
@@ -353,6 +373,7 @@ static int cbc_aes_decrypt(struct blkcipher_desc *desc,
 		nbytes &= AES_BLOCK_SIZE - 1;
 		err = blkcipher_walk_done(desc, &walk, nbytes);
 	}
+	kernel_fpu_end();
 
 	return err;
 }
diff --git a/drivers/crypto/padlock-sha.c b/drivers/crypto/padlock-sha.c
index 40d5680..cea8830 100644
--- a/drivers/crypto/padlock-sha.c
+++ b/drivers/crypto/padlock-sha.c
@@ -22,6 +22,7 @@
 #include <linux/interrupt.h>
 #include <linux/kernel.h>
 #include <linux/scatterlist.h>
+#include <asm/i387.h>
 #include "padlock.h"
 
 #define SHA1_DEFAULT_FALLBACK	"sha1-generic"
@@ -109,9 +110,12 @@ static void padlock_do_sha1(const char *in, char *out, int count)
 	((uint32_t *)result)[3] = SHA1_H3;
 	((uint32_t *)result)[4] = SHA1_H4;
  
+	/* prevent taking the spurious DNA fault with padlock. */
+	kernel_fpu_begin();
 	asm volatile (".byte 0xf3,0x0f,0xa6,0xc8" /* rep xsha1 */
 		      : "+S"(in), "+D"(result)
 		      : "c"(count), "a"(0));
+	kernel_fpu_end();
 
 	padlock_output_block((uint32_t *)result, (uint32_t *)out, 5);
 }
@@ -133,9 +137,12 @@ static void padlock_do_sha256(const char *in, char *out, int count)
 	((uint32_t *)result)[6] = SHA256_H6;
 	((uint32_t *)result)[7] = SHA256_H7;
 
+	/* prevent taking the spurious DNA fault with padlock. */
+	kernel_fpu_begin();
 	asm volatile (".byte 0xf3,0x0f,0xa6,0xd0" /* rep xsha256 */
 		      : "+S"(in), "+D"(result)
 		      : "c"(count), "a"(0));
+	kernel_fpu_end();
 
 	padlock_output_block((uint32_t *)result, (uint32_t *)out, 8);
 }
