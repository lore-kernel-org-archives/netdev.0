From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH 7/9] powerpc32: optimise csum_partial() loop
Date: Tue, 22 Sep 2015 16:34:32 +0200 (CEST)
Message-ID: <321c562c2320371ac39abd64959c160f8e2f5db7.1442876807.git.christophe.leroy@c-s.fr>
References: <cover.1442876807.git.christophe.leroy@c-s.fr>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>, scottwood@freescale.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1442876807.git.christophe.leroy@c-s.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On the 8xx, load latency is 2 cycles and taking branches also takes
2 cycles. So let's unroll the loop.

This patch improves csum_partial() speed by around 10% on both:
* 8xx (single issue processor with parallele execution)
* 83xx (superscalar 6xx processor with dual instruction fetch
and parallele execution)

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/lib/checksum_32.S | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/arch/powerpc/lib/checksum_32.S b/arch/powerpc/lib/checksum_32.S
index 9c12602..0d34f47 100644
--- a/arch/powerpc/lib/checksum_32.S
+++ b/arch/powerpc/lib/checksum_32.S
@@ -38,10 +38,24 @@ _GLOBAL(csum_partial)
 	srwi.	r6,r4,2		/* # words to do */
 	adde	r5,r5,r0
 	beq	3f
-1:	mtctr	r6
+1:	andi.	r6,r6,3		/* Prepare to handle words 4 by 4 */
+	beq	21f
+	mtctr	r6
 2:	lwzu	r0,4(r3)
 	adde	r5,r5,r0
 	bdnz	2b
+21:	srwi.	r6,r4,4		/* # blocks of 4 words to do */
+	beq	3f
+	mtctr	r6
+22:	lwz	r0,4(r3)
+	lwz	r6,8(r3)
+	lwz	r7,12(r3)
+	lwzu	r8,16(r3)
+	adde	r5,r5,r0
+	adde	r5,r5,r6
+	adde	r5,r5,r7
+	adde	r5,r5,r8
+	bdnz	22b
 3:	andi.	r0,r4,2
 	beq+	4f
 	lhz	r0,4(r3)
-- 
2.1.0
