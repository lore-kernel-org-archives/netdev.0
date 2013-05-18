From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] x86: bpf_jit_comp: secure bpf jit against spraying
 attacks
Date: Fri, 17 May 2013 19:37:03 -0700
Message-ID: <1368844623.3301.142.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

hpa bringed into my attention some security related issues
with BPF JIT on x86.

This patch makes sure the bpf generated code is marked read only,
as other kernel text sections.

It also splits the unused space (we vmalloc() and only use a fraction of
the page) in two parts, so that the generated bpf code not starts at a
known offset in the page, but a pseudo random one.

Refs:
http://mainisusuallyafunction.blogspot.com/2012/11/attacking-hardened-linux-systems-with.html

Reported-by: H. Peter Anvin <hpa@zytor.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 arch/x86/net/bpf_jit_comp.c |   53 ++++++++++++++++++++++++++++++----
 1 file changed, 47 insertions(+), 6 deletions(-)

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index c0212db..79c216a 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -12,6 +12,7 @@
 #include <linux/netdevice.h>
 #include <linux/filter.h>
 #include <linux/if_vlan.h>
+#include <linux/random.h>
 
 /*
  * Conventions :
@@ -144,6 +145,39 @@ static int pkt_type_offset(void)
 	return -1;
 }
 
+struct bpf_binary_header {
+	unsigned int	pages;
+	/* Note : for security reasons, bpf code will follow a randomly
+	 * sized amount of int3 instructions
+	 */
+	u8		image[];
+};
+
+static struct bpf_binary_header *bpf_alloc_binary(unsigned int proglen,
+						  u8 **image_ptr)
+{
+	unsigned int sz, hole;
+	struct bpf_binary_header *header;
+
+	/* Most of BPF filters are really small,
+	 * but if some of them fill a page, allow at least
+	 * 128 extra bytes to insert a random section of int3
+	 */
+	sz = round_up(proglen + sizeof(*header) + 128, PAGE_SIZE);
+	header = module_alloc(sz);
+	if (!header)
+		return NULL;
+
+	memset(header, 0xcc, sz); /* fill whole space with int3 instructions */
+
+	header->pages = sz / PAGE_SIZE;
+	hole = sz - (proglen + sizeof(*header));
+
+	/* insert a random number of int3 instructions before BPF code */
+	*image_ptr = &header->image[prandom_u32() % hole];
+	return header;
+}
+
 void bpf_jit_compile(struct sk_filter *fp)
 {
 	u8 temp[64];
@@ -153,6 +187,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 	int t_offset, f_offset;
 	u8 t_op, f_op, seen = 0, pass;
 	u8 *image = NULL;
+	struct bpf_binary_header *header = NULL;
 	u8 *func;
 	int pc_ret0 = -1; /* bpf index of first RET #0 instruction (if any) */
 	unsigned int cleanup_addr; /* epilogue code offset */
@@ -693,7 +728,7 @@ cond_branch:			f_offset = addrs[i + filter[i].jf] - addrs[i];
 				if (unlikely(proglen + ilen > oldproglen)) {
 					pr_err("bpb_jit_compile fatal error\n");
 					kfree(addrs);
-					module_free(NULL, image);
+					module_free(NULL, header);
 					return;
 				}
 				memcpy(image + proglen, temp, ilen);
@@ -717,8 +752,8 @@ cond_branch:			f_offset = addrs[i + filter[i].jf] - addrs[i];
 			break;
 		}
 		if (proglen == oldproglen) {
-			image = module_alloc(proglen);
-			if (!image)
+			header = bpf_alloc_binary(proglen, &image);
+			if (!header)
 				goto out;
 		}
 		oldproglen = proglen;
@@ -728,7 +763,8 @@ cond_branch:			f_offset = addrs[i + filter[i].jf] - addrs[i];
 		bpf_jit_dump(flen, proglen, pass, image);
 
 	if (image) {
-		bpf_flush_icache(image, image + proglen);
+		bpf_flush_icache(header, image + proglen);
+		set_memory_ro((unsigned long)header, header->pages);
 		fp->bpf_func = (void *)image;
 	}
 out:
@@ -738,6 +774,11 @@ out:
 
 void bpf_jit_free(struct sk_filter *fp)
 {
-	if (fp->bpf_func != sk_run_filter)
-		module_free(NULL, fp->bpf_func);
+	if (fp->bpf_func != sk_run_filter) {
+		unsigned long addr = (unsigned long)fp->bpf_func & PAGE_MASK;
+		struct bpf_binary_header *header = (void *)addr;
+
+		set_memory_rw(addr, header->pages);
+		module_free(NULL, header);
+	}
 }
