From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 1/3] net: bpf: consolidate JIT binary allocator
Date: Sat,  6 Sep 2014 11:42:45 +0200
Message-ID: <1409996567-2170-2-git-send-email-dborkman@redhat.com>
References: <1409996567-2170-1-git-send-email-dborkman@redhat.com>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20065 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751165AbaIFJm6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Sep 2014 05:42:58 -0400
In-Reply-To: <1409996567-2170-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduced in commit 314beb9bcabf ("x86: bpf_jit_comp: secure bpf jit
against spraying attacks") and later on replicated in aa2d2c73c21f
("s390/bpf,jit: address randomize and write protect jit code") for
s390 architecture, write protection for BPF JIT images got added and
a random start address of the JIT code, so that it's not on a page
boundary anymore.

Since both use a very similar allocator for the BPF binary header,
we can consolidate this code into the BPF core as it's mostly JIT
independant anyway.

This will also allow for future archs that support DEBUG_SET_MODULE_RONX
to just reuse instead of reimplementing it.

While reviewing the code, I think on s390, the alignment masking
seems not to be correct in it's current form, that is, we make sure
the first instruction starts at an even address as stated by commit
aa2d2c73c21f but masks the start with '& -2' while 2 byte-alignment
should rather be '& ~1'.

JIT tested on x86_64 and s390x with BPF test suite.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
---
 arch/s390/net/bpf_jit_comp.c | 45 ++++++++-------------------------------
 arch/x86/net/bpf_jit_comp.c  | 50 ++++++++++----------------------------------
 include/linux/filter.h       | 13 ++++++++++++
 kernel/bpf/core.c            | 39 ++++++++++++++++++++++++++++++++++
 4 files changed, 72 insertions(+), 75 deletions(-)

diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
index f2833c5..b734f97 100644
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@ -5,11 +5,9 @@
  *
  * Author(s): Martin Schwidefsky <schwidefsky@de.ibm.com>
  */
-#include <linux/moduleloader.h>
 #include <linux/netdevice.h>
 #include <linux/if_vlan.h>
 #include <linux/filter.h>
-#include <linux/random.h>
 #include <linux/init.h>
 #include <asm/cacheflush.h>
 #include <asm/facility.h>
@@ -148,6 +146,12 @@ struct bpf_jit {
 	ret;						\
 })
 
+static void bpf_jit_fill_hole(void *area, unsigned int size)
+{
+	/* Fill whole space with illegal instructions */
+	memset(area, 0, size);
+}
+
 static void bpf_jit_prologue(struct bpf_jit *jit)
 {
 	/* Save registers and create stack frame if necessary */
@@ -780,38 +784,6 @@ out:
 	return -1;
 }
 
-/*
- * Note: for security reasons, bpf code will follow a randomly
- *	 sized amount of illegal instructions.
- */
-struct bpf_binary_header {
-	unsigned int pages;
-	u8 image[];
-};
-
-static struct bpf_binary_header *bpf_alloc_binary(unsigned int bpfsize,
-						  u8 **image_ptr)
-{
-	struct bpf_binary_header *header;
-	unsigned int sz, hole;
-
-	/* Most BPF filters are really small, but if some of them fill a page,
-	 * allow at least 128 extra bytes for illegal instructions.
-	 */
-	sz = round_up(bpfsize + sizeof(*header) + 128, PAGE_SIZE);
-	header = module_alloc(sz);
-	if (!header)
-		return NULL;
-	memset(header, 0, sz);
-	header->pages = sz / PAGE_SIZE;
-	hole = min(sz - (bpfsize + sizeof(*header)), PAGE_SIZE - sizeof(*header));
-	/* Insert random number of illegal instructions before BPF code
-	 * and make sure the first instruction starts at an even address.
-	 */
-	*image_ptr = &header->image[(prandom_u32() % hole) & -2];
-	return header;
-}
-
 void bpf_jit_compile(struct bpf_prog *fp)
 {
 	struct bpf_binary_header *header = NULL;
@@ -850,7 +822,8 @@ void bpf_jit_compile(struct bpf_prog *fp)
 			size = prg_len + lit_len;
 			if (size >= BPF_SIZE_MAX)
 				goto out;
-			header = bpf_alloc_binary(size, &jit.start);
+			header = bpf_jit_binary_alloc(size, &jit.start,
+						      2, bpf_jit_fill_hole);
 			if (!header)
 				goto out;
 			jit.prg = jit.mid = jit.start + prg_len;
@@ -884,7 +857,7 @@ void bpf_jit_free(struct bpf_prog *fp)
 		goto free_filter;
 
 	set_memory_rw(addr, header->pages);
-	module_free(NULL, header);
+	bpf_jit_binary_free(header);
 
 free_filter:
 	bpf_prog_unlock_free(fp);
diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 06f8c17..9de0b54 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -8,12 +8,10 @@
  * as published by the Free Software Foundation; version 2
  * of the License.
  */
-#include <linux/moduleloader.h>
-#include <asm/cacheflush.h>
 #include <linux/netdevice.h>
 #include <linux/filter.h>
 #include <linux/if_vlan.h>
-#include <linux/random.h>
+#include <asm/cacheflush.h>
 
 int bpf_jit_enable __read_mostly;
 
@@ -109,39 +107,6 @@ static inline void bpf_flush_icache(void *start, void *end)
 #define CHOOSE_LOAD_FUNC(K, func) \
 	((int)K < 0 ? ((int)K >= SKF_LL_OFF ? func##_negative_offset : func) : func##_positive_offset)
 
-struct bpf_binary_header {
-	unsigned int	pages;
-	/* Note : for security reasons, bpf code will follow a randomly
-	 * sized amount of int3 instructions
-	 */
-	u8		image[];
-};
-
-static struct bpf_binary_header *bpf_alloc_binary(unsigned int proglen,
-						  u8 **image_ptr)
-{
-	unsigned int sz, hole;
-	struct bpf_binary_header *header;
-
-	/* Most of BPF filters are really small,
-	 * but if some of them fill a page, allow at least
-	 * 128 extra bytes to insert a random section of int3
-	 */
-	sz = round_up(proglen + sizeof(*header) + 128, PAGE_SIZE);
-	header = module_alloc(sz);
-	if (!header)
-		return NULL;
-
-	memset(header, 0xcc, sz); /* fill whole space with int3 instructions */
-
-	header->pages = sz / PAGE_SIZE;
-	hole = min(sz - (proglen + sizeof(*header)), PAGE_SIZE - sizeof(*header));
-
-	/* insert a random number of int3 instructions before BPF code */
-	*image_ptr = &header->image[prandom_u32() % hole];
-	return header;
-}
-
 /* pick a register outside of BPF range for JIT internal work */
 #define AUX_REG (MAX_BPF_REG + 1)
 
@@ -206,6 +171,12 @@ static inline u8 add_2reg(u8 byte, u32 dst_reg, u32 src_reg)
 	return byte + reg2hex[dst_reg] + (reg2hex[src_reg] << 3);
 }
 
+static void jit_fill_hole(void *area, unsigned int size)
+{
+	/* fill whole space with int3 instructions */
+	memset(area, 0xcc, size);
+}
+
 struct jit_context {
 	unsigned int cleanup_addr; /* epilogue code offset */
 	bool seen_ld_abs;
@@ -959,7 +930,7 @@ void bpf_int_jit_compile(struct bpf_prog *prog)
 		if (proglen <= 0) {
 			image = NULL;
 			if (header)
-				module_free(NULL, header);
+				bpf_jit_binary_free(header);
 			goto out;
 		}
 		if (image) {
@@ -969,7 +940,8 @@ void bpf_int_jit_compile(struct bpf_prog *prog)
 			break;
 		}
 		if (proglen == oldproglen) {
-			header = bpf_alloc_binary(proglen, &image);
+			header = bpf_jit_binary_alloc(proglen, &image,
+						      1, jit_fill_hole);
 			if (!header)
 				goto out;
 		}
@@ -998,7 +970,7 @@ void bpf_jit_free(struct bpf_prog *fp)
 		goto free_filter;
 
 	set_memory_rw(addr, header->pages);
-	module_free(NULL, header);
+	bpf_jit_binary_free(header);
 
 free_filter:
 	bpf_prog_unlock_free(fp);
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 8f82ef3..868764f 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -289,6 +289,11 @@ struct sock_fprog_kern {
 	struct sock_filter	*filter;
 };
 
+struct bpf_binary_header {
+	unsigned int pages;
+	u8 image[];
+};
+
 struct bpf_work_struct {
 	struct bpf_prog *prog;
 	struct work_struct work;
@@ -358,6 +363,14 @@ struct bpf_prog *bpf_prog_realloc(struct bpf_prog *fp_old, unsigned int size,
 				  gfp_t gfp_extra_flags);
 void __bpf_prog_free(struct bpf_prog *fp);
 
+typedef void (*bpf_jit_fill_hole_t)(void *area, unsigned int size);
+
+struct bpf_binary_header *
+bpf_jit_binary_alloc(unsigned int proglen, u8 **image_ptr,
+		     unsigned int alignment,
+		     bpf_jit_fill_hole_t bpf_fill_ill_insns);
+void bpf_jit_binary_free(struct bpf_binary_header *hdr);
+
 static inline void bpf_prog_unlock_free(struct bpf_prog *fp)
 {
 	bpf_prog_unlock_ro(fp);
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 2c2bfaa..8ee520f 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -20,9 +20,12 @@
  * Andi Kleen - Fix a few bad bugs and races.
  * Kris Katterjohn - Added many additional checks in bpf_check_classic()
  */
+
 #include <linux/filter.h>
 #include <linux/skbuff.h>
 #include <linux/vmalloc.h>
+#include <linux/random.h>
+#include <linux/moduleloader.h>
 #include <asm/unaligned.h>
 
 /* Registers */
@@ -125,6 +128,42 @@ void __bpf_prog_free(struct bpf_prog *fp)
 }
 EXPORT_SYMBOL_GPL(__bpf_prog_free);
 
+struct bpf_binary_header *
+bpf_jit_binary_alloc(unsigned int proglen, u8 **image_ptr,
+		     unsigned int alignment,
+		     bpf_jit_fill_hole_t bpf_fill_ill_insns)
+{
+	struct bpf_binary_header *hdr;
+	unsigned int size, hole, start;
+
+	/* Most of BPF filters are really small, but if some of them
+	 * fill a page, allow at least 128 extra bytes to insert a
+	 * random section of illegal instructions.
+	 */
+	size = round_up(proglen + sizeof(*hdr) + 128, PAGE_SIZE);
+	hdr = module_alloc(size);
+	if (hdr == NULL)
+		return NULL;
+
+	/* Fill space with illegal/arch-dep instructions. */
+	bpf_fill_ill_insns(hdr, size);
+
+	hdr->pages = size / PAGE_SIZE;
+	hole = min_t(unsigned int, size - (proglen + sizeof(*hdr)),
+		     PAGE_SIZE - sizeof(*hdr));
+	start = (prandom_u32() % hole) & ~(alignment - 1);
+
+	/* Leave a random number of instructions before BPF code. */
+	*image_ptr = &hdr->image[start];
+
+	return hdr;
+}
+
+void bpf_jit_binary_free(struct bpf_binary_header *hdr)
+{
+	module_free(NULL, hdr);
+}
+
 /* Base function for offset calculation. Needs to go into .text section,
  * therefore keeping it non-static as well; will also be used by JITs
  * anyway later on, so do not let the compiler omit it.
-- 
1.7.11.7
