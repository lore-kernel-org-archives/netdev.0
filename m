From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: filter: Just In Time compiler for sparc
Date: Tue, 17 Apr 2012 16:15:52 -0400 (EDT)
Message-ID: <20120417.161552.1668680824683053555.davem@davemloft.net>
References: <20120416.225823.1395194623649559124.davem@davemloft.net>
	<4F8DBDAD.50507@oldelvet.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sparclinux@vger.kernel.org
To: richm@oldelvet.org.uk
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <4F8DBDAD.50507@oldelvet.org.uk>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Richard Mortimer <richm@oldelvet.org.uk>
Date: Tue, 17 Apr 2012 19:59:57 +0100

> A few points below. Mainly a couple of comments that do not match the
> code itself. I didn't spot any errors in the assembler generation
> itself.

Thanks Richard, I've committed (after testing) the following based
upon your feedback.

--------------------
net: filter: Fix some minor issues in sparc JIT.

Correct conventions comments.  %o4 and %o5 were swapped,
%g3 was not documented.

Use r_TMP instead of r_SKB_DATA + r_OFF where possible in
assembler stubs.

Correct discussion of %o4 and %o5 in one of bpf_jit_compile()'s
comments.

Based upon feedback from Richard Mortimer.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 arch/sparc/net/bpf_jit.h      |    5 +++--
 arch/sparc/net/bpf_jit_asm.S  |    4 ++--
 arch/sparc/net/bpf_jit_comp.c |    2 +-
 3 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/arch/sparc/net/bpf_jit.h b/arch/sparc/net/bpf_jit.h
index 74f048b..05175be 100644
--- a/arch/sparc/net/bpf_jit.h
+++ b/arch/sparc/net/bpf_jit.h
@@ -4,13 +4,14 @@
 /* Conventions:
  *  %g1 : temporary
  *  %g2 : Secondary temporary used by SKB data helper stubs.
+ *  %g3 : packet offset passed into SKB data helper stubs.
  *  %o0 : pointer to skb (first argument given to JIT function)
  *  %o1 : BPF A accumulator
  *  %o2 : BPF X accumulator
  *  %o3 : Holds saved %o7 so we can call helper functions without needing
  *        to allocate a register window.
- *  %o4 : skb->data
- *  %o5 : skb->len - skb->data_len
+ *  %o4 : skb->len - skb->data_len
+ *  %o5 : skb->data
  */
 
 #ifndef __ASSEMBLER__
diff --git a/arch/sparc/net/bpf_jit_asm.S b/arch/sparc/net/bpf_jit_asm.S
index fdc6932..46d8f59 100644
--- a/arch/sparc/net/bpf_jit_asm.S
+++ b/arch/sparc/net/bpf_jit_asm.S
@@ -30,7 +30,7 @@ bpf_jit_load_word_positive_offset:
 	bne	load_word_unaligned
 	 nop
 	retl
-	 ld	[r_SKB_DATA + r_OFF], r_A
+	 ld	[r_TMP], r_A
 load_word_unaligned:
 	ldub	[r_TMP + 0x0], r_OFF
 	ldub	[r_TMP + 0x1], r_TMP2
@@ -59,7 +59,7 @@ bpf_jit_load_half_positive_offset:
 	bne	load_half_unaligned
 	 nop
 	retl
-	 lduh	[r_SKB_DATA + r_OFF], r_A
+	 lduh	[r_TMP], r_A
 load_half_unaligned:
 	ldub	[r_TMP + 0x0], r_OFF
 	ldub	[r_TMP + 0x1], r_TMP2
diff --git a/arch/sparc/net/bpf_jit_comp.c b/arch/sparc/net/bpf_jit_comp.c
index 86349ca..ebc8980 100644
--- a/arch/sparc/net/bpf_jit_comp.c
+++ b/arch/sparc/net/bpf_jit_comp.c
@@ -378,7 +378,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 				emit_clear(r_X);
 
 			/* If this filter needs to access skb data,
-			 * load %o4 and %o4 with:
+			 * load %o4 and %o5 with:
 			 *  %o4 = skb->len - skb->data_len
 			 *  %o5 = skb->data
 			 * And also back up %o7 into r_saved_O7 so we can
-- 
1.7.10

