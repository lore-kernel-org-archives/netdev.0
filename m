From: Kyle Moffett <Kyle.D.Moffett@boeing.com>
Subject: [RFC PATCH 1/2] powerpc: Remove duplicate cacheable_memcpy/memzero functions
Date: Mon, 14 Nov 2011 21:32:10 -0500
Message-ID: <1321324332-22964-2-git-send-email-Kyle.D.Moffett@boeing.com>
References: <1320986410.21206.48.camel@pasglop>
Cc: <linux-kernel@vger.kernel.org>, <benh@kernel.crashing.org>,
	<galak@kernel.crashing.org>, <scottwood@freescale.com>,
	<B04825@freescale.com>, <paul.gortmaker@windriver.com>,
	Kyle Moffett <Kyle.D.Moffett@boeing.com>,
	Paul Mackerras <paulus@samba.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Milton Miller <miltonm@bga.com>,
	Mike Frysinger <vapier@gentoo.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Anton Blanchard <anton@samba.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jpirko@redhat.com>, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org
To: <linuxppc-dev@lists.ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 26.241.167.70.in-addr.border.exmeritus.com ([70.167.241.26]:45581
	"EHLO border.exmeritus.com" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755059Ab1KOCdG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 21:33:06 -0500
In-Reply-To: <1320986410.21206.48.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These functions are only used from one place each.  If the cacheable_*
versions really are more efficient, then those changes should be
migrated into the common code instead.

NOTE: The old routines are just flat buggy on kernels that support
      hardware with different cacheline sizes.

Signed-off-by: Kyle Moffett <Kyle.D.Moffett@boeing.com>
---
 arch/powerpc/include/asm/system.h    |    2 -
 arch/powerpc/kernel/ppc_ksyms.c      |    2 -
 arch/powerpc/lib/copy_32.S           |  127 ----------------------------------
 arch/powerpc/mm/ppc_mmu_32.c         |    2 +-
 drivers/net/ethernet/ibm/emac/core.c |   12 +---
 5 files changed, 3 insertions(+), 142 deletions(-)

diff --git a/arch/powerpc/include/asm/system.h b/arch/powerpc/include/asm/system.h
index e30a13d..25389d1 100644
--- a/arch/powerpc/include/asm/system.h
+++ b/arch/powerpc/include/asm/system.h
@@ -189,8 +189,6 @@ static inline void flush_spe_to_thread(struct task_struct *t)
 #endif
 
 extern int call_rtas(const char *, int, int, unsigned long *, ...);
-extern void cacheable_memzero(void *p, unsigned int nb);
-extern void *cacheable_memcpy(void *, const void *, unsigned int);
 extern int do_page_fault(struct pt_regs *, unsigned long, unsigned long);
 extern void bad_page_fault(struct pt_regs *, unsigned long, int);
 extern int die(const char *, struct pt_regs *, long);
diff --git a/arch/powerpc/kernel/ppc_ksyms.c b/arch/powerpc/kernel/ppc_ksyms.c
index d3114a7..acba8ce 100644
--- a/arch/powerpc/kernel/ppc_ksyms.c
+++ b/arch/powerpc/kernel/ppc_ksyms.c
@@ -159,8 +159,6 @@ EXPORT_SYMBOL(screen_info);
 #ifdef CONFIG_PPC32
 EXPORT_SYMBOL(timer_interrupt);
 EXPORT_SYMBOL(tb_ticks_per_jiffy);
-EXPORT_SYMBOL(cacheable_memcpy);
-EXPORT_SYMBOL(cacheable_memzero);
 #endif
 
 #ifdef CONFIG_PPC32
diff --git a/arch/powerpc/lib/copy_32.S b/arch/powerpc/lib/copy_32.S
index 55f19f9..6813f80 100644
--- a/arch/powerpc/lib/copy_32.S
+++ b/arch/powerpc/lib/copy_32.S
@@ -69,54 +69,6 @@ CACHELINE_BYTES = L1_CACHE_BYTES
 LG_CACHELINE_BYTES = L1_CACHE_SHIFT
 CACHELINE_MASK = (L1_CACHE_BYTES-1)
 
-/*
- * Use dcbz on the complete cache lines in the destination
- * to set them to zero.  This requires that the destination
- * area is cacheable.  -- paulus
- */
-_GLOBAL(cacheable_memzero)
-	mr	r5,r4
-	li	r4,0
-	addi	r6,r3,-4
-	cmplwi	0,r5,4
-	blt	7f
-	stwu	r4,4(r6)
-	beqlr
-	andi.	r0,r6,3
-	add	r5,r0,r5
-	subf	r6,r0,r6
-	clrlwi	r7,r6,32-LG_CACHELINE_BYTES
-	add	r8,r7,r5
-	srwi	r9,r8,LG_CACHELINE_BYTES
-	addic.	r9,r9,-1	/* total number of complete cachelines */
-	ble	2f
-	xori	r0,r7,CACHELINE_MASK & ~3
-	srwi.	r0,r0,2
-	beq	3f
-	mtctr	r0
-4:	stwu	r4,4(r6)
-	bdnz	4b
-3:	mtctr	r9
-	li	r7,4
-10:	dcbz	r7,r6
-	addi	r6,r6,CACHELINE_BYTES
-	bdnz	10b
-	clrlwi	r5,r8,32-LG_CACHELINE_BYTES
-	addi	r5,r5,4
-2:	srwi	r0,r5,2
-	mtctr	r0
-	bdz	6f
-1:	stwu	r4,4(r6)
-	bdnz	1b
-6:	andi.	r5,r5,3
-7:	cmpwi	0,r5,0
-	beqlr
-	mtctr	r5
-	addi	r6,r6,3
-8:	stbu	r4,1(r6)
-	bdnz	8b
-	blr
-
 _GLOBAL(memset)
 	rlwimi	r4,r4,8,16,23
 	rlwimi	r4,r4,16,0,15
@@ -142,85 +94,6 @@ _GLOBAL(memset)
 	bdnz	8b
 	blr
 
-/*
- * This version uses dcbz on the complete cache lines in the
- * destination area to reduce memory traffic.  This requires that
- * the destination area is cacheable.
- * We only use this version if the source and dest don't overlap.
- * -- paulus.
- */
-_GLOBAL(cacheable_memcpy)
-	add	r7,r3,r5		/* test if the src & dst overlap */
-	add	r8,r4,r5
-	cmplw	0,r4,r7
-	cmplw	1,r3,r8
-	crand	0,0,4			/* cr0.lt &= cr1.lt */
-	blt	memcpy			/* if regions overlap */
-
-	addi	r4,r4,-4
-	addi	r6,r3,-4
-	neg	r0,r3
-	andi.	r0,r0,CACHELINE_MASK	/* # bytes to start of cache line */
-	beq	58f
-
-	cmplw	0,r5,r0			/* is this more than total to do? */
-	blt	63f			/* if not much to do */
-	andi.	r8,r0,3			/* get it word-aligned first */
-	subf	r5,r0,r5
-	mtctr	r8
-	beq+	61f
-70:	lbz	r9,4(r4)		/* do some bytes */
-	stb	r9,4(r6)
-	addi	r4,r4,1
-	addi	r6,r6,1
-	bdnz	70b
-61:	srwi.	r0,r0,2
-	mtctr	r0
-	beq	58f
-72:	lwzu	r9,4(r4)		/* do some words */
-	stwu	r9,4(r6)
-	bdnz	72b
-
-58:	srwi.	r0,r5,LG_CACHELINE_BYTES /* # complete cachelines */
-	clrlwi	r5,r5,32-LG_CACHELINE_BYTES
-	li	r11,4
-	mtctr	r0
-	beq	63f
-53:
-	dcbz	r11,r6
-	COPY_16_BYTES
-#if L1_CACHE_BYTES >= 32
-	COPY_16_BYTES
-#if L1_CACHE_BYTES >= 64
-	COPY_16_BYTES
-	COPY_16_BYTES
-#if L1_CACHE_BYTES >= 128
-	COPY_16_BYTES
-	COPY_16_BYTES
-	COPY_16_BYTES
-	COPY_16_BYTES
-#endif
-#endif
-#endif
-	bdnz	53b
-
-63:	srwi.	r0,r5,2
-	mtctr	r0
-	beq	64f
-30:	lwzu	r0,4(r4)
-	stwu	r0,4(r6)
-	bdnz	30b
-
-64:	andi.	r0,r5,3
-	mtctr	r0
-	beq+	65f
-40:	lbz	r0,4(r4)
-	stb	r0,4(r6)
-	addi	r4,r4,1
-	addi	r6,r6,1
-	bdnz	40b
-65:	blr
-
 _GLOBAL(memmove)
 	cmplw	0,r3,r4
 	bgt	backwards_memcpy
diff --git a/arch/powerpc/mm/ppc_mmu_32.c b/arch/powerpc/mm/ppc_mmu_32.c
index 11571e1..9f16b9f 100644
--- a/arch/powerpc/mm/ppc_mmu_32.c
+++ b/arch/powerpc/mm/ppc_mmu_32.c
@@ -224,7 +224,7 @@ void __init MMU_init_hw(void)
 	 */
 	if ( ppc_md.progress ) ppc_md.progress("hash:find piece", 0x322);
 	Hash = __va(memblock_alloc(Hash_size, Hash_size));
-	cacheable_memzero(Hash, Hash_size);
+	memset(Hash, 0, Hash_size);
 	_SDR1 = __pa(Hash) | SDR1_LOW_BITS;
 
 	Hash_end = (struct hash_pte *) ((unsigned long)Hash + Hash_size);
diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
index ed79b2d..be214ad 100644
--- a/drivers/net/ethernet/ibm/emac/core.c
+++ b/drivers/net/ethernet/ibm/emac/core.c
@@ -77,13 +77,6 @@ MODULE_AUTHOR
     ("Eugene Surovegin <eugene.surovegin@zultys.com> or <ebs@ebshome.net>");
 MODULE_LICENSE("GPL");
 
-/*
- * PPC64 doesn't (yet) have a cacheable_memcpy
- */
-#ifdef CONFIG_PPC64
-#define cacheable_memcpy(d,s,n) memcpy((d),(s),(n))
-#endif
-
 /* minimum number of free TX descriptors required to wake up TX process */
 #define EMAC_TX_WAKEUP_THRESH		(NUM_TX_BUFF / 4)
 
@@ -1637,7 +1630,7 @@ static inline int emac_rx_sg_append(struct emac_instance *dev, int slot)
 			dev_kfree_skb(dev->rx_sg_skb);
 			dev->rx_sg_skb = NULL;
 		} else {
-			cacheable_memcpy(skb_tail_pointer(dev->rx_sg_skb),
+			memcpy(skb_tail_pointer(dev->rx_sg_skb),
 					 dev->rx_skb[slot]->data, len);
 			skb_put(dev->rx_sg_skb, len);
 			emac_recycle_rx_skb(dev, slot, len);
@@ -1694,8 +1687,7 @@ static int emac_poll_rx(void *param, int budget)
 				goto oom;
 
 			skb_reserve(copy_skb, EMAC_RX_SKB_HEADROOM + 2);
-			cacheable_memcpy(copy_skb->data - 2, skb->data - 2,
-					 len + 2);
+			memcpy(copy_skb->data - 2, skb->data - 2, len + 2);
 			emac_recycle_rx_skb(dev, slot, len);
 			skb = copy_skb;
 		} else if (unlikely(emac_alloc_rx_skb(dev, slot, GFP_ATOMIC)))
-- 
1.7.2.5
