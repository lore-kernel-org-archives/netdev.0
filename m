From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 2/3] net: bpf: arm: address randomize and write protect JIT code
Date: Sat,  6 Sep 2014 11:42:46 +0200
Message-ID: <1409996567-2170-3-git-send-email-dborkman@redhat.com>
References: <1409996567-2170-1-git-send-email-dborkman@redhat.com>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Mircea Gherzan <mgherzan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33731 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751138AbaIFJm5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Sep 2014 05:42:57 -0400
In-Reply-To: <1409996567-2170-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the ARM variant for 314beb9bcab ("x86: bpf_jit_comp: secure bpf
jit against spraying attacks").

It is now possible to implement it due to commits 75374ad47c64 ("ARM: mm:
Define set_memory_* functions for ARM") and dca9aa92fc7c ("ARM: add
DEBUG_SET_MODULE_RONX option to Kconfig") which added infrastructure for
this facility.

Thus, this patch makes sure the BPF generated JIT code is marked RO, as
other kernel text sections, and also lets the generated JIT code start
at a pseudo random offset instead on a page boundary. The holes are filled
with illegal instructions.

JIT tested on armv7hl with BPF test suite.

Reference: http://mainisusuallyafunction.blogspot.com/2012/11/attacking-hardened-linux-systems-with.html
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
Cc: Mircea Gherzan <mgherzan@gmail.com>
---
 arch/arm/net/bpf_jit_32.c | 32 ++++++++++++++++++++++++++------
 1 file changed, 26 insertions(+), 6 deletions(-)

diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
index a76623b..2d1a5b9 100644
--- a/arch/arm/net/bpf_jit_32.c
+++ b/arch/arm/net/bpf_jit_32.c
@@ -12,7 +12,6 @@
 #include <linux/compiler.h>
 #include <linux/errno.h>
 #include <linux/filter.h>
-#include <linux/moduleloader.h>
 #include <linux/netdevice.h>
 #include <linux/string.h>
 #include <linux/slab.h>
@@ -174,6 +173,15 @@ static inline bool is_load_to_a(u16 inst)
 	}
 }
 
+static void jit_fill_hole(void *area, unsigned int size)
+{
+	/* Insert illegal UND instructions. */
+	u32 *ptr, fill_ins = 0xe7ffffff;
+	/* We are guaranteed to have aligned memory. */
+	for (ptr = area; size >= sizeof(u32); size -= sizeof(u32))
+		*ptr++ = fill_ins;
+}
+
 static void build_prologue(struct jit_ctx *ctx)
 {
 	u16 reg_set = saved_regs(ctx);
@@ -859,9 +867,11 @@ b_epilogue:
 
 void bpf_jit_compile(struct bpf_prog *fp)
 {
+	struct bpf_binary_header *header;
 	struct jit_ctx ctx;
 	unsigned tmp_idx;
 	unsigned alloc_size;
+	u8 *target_ptr;
 
 	if (!bpf_jit_enable)
 		return;
@@ -897,13 +907,15 @@ void bpf_jit_compile(struct bpf_prog *fp)
 	/* there's nothing after the epilogue on ARMv7 */
 	build_epilogue(&ctx);
 #endif
-
 	alloc_size = 4 * ctx.idx;
-	ctx.target = module_alloc(alloc_size);
-	if (unlikely(ctx.target == NULL))
+	header = bpf_jit_binary_alloc(alloc_size, &target_ptr,
+				      4, jit_fill_hole);
+	if (header == NULL)
 		goto out;
 
+	ctx.target = (u32 *) target_ptr;
 	ctx.idx = 0;
+
 	build_prologue(&ctx);
 	build_body(&ctx);
 	build_epilogue(&ctx);
@@ -919,6 +931,7 @@ void bpf_jit_compile(struct bpf_prog *fp)
 		/* there are 2 passes here */
 		bpf_jit_dump(fp->len, alloc_size, 2, ctx.target);
 
+	set_memory_ro((unsigned long)header, header->pages);
 	fp->bpf_func = (void *)ctx.target;
 	fp->jited = 1;
 out:
@@ -928,8 +941,15 @@ out:
 
 void bpf_jit_free(struct bpf_prog *fp)
 {
-	if (fp->jited)
-		module_free(NULL, fp->bpf_func);
+	unsigned long addr = (unsigned long)fp->bpf_func & PAGE_MASK;
+	struct bpf_binary_header *header = (void *)addr;
+
+	if (!fp->jited)
+		goto free_filter;
+
+	set_memory_rw(addr, header->pages);
+	bpf_jit_binary_free(header);
 
+free_filter:
 	bpf_prog_unlock_free(fp);
 }
-- 
1.7.11.7
