From: Sebastian Huber <sebastian.huber@embedded-brains.de>
Subject: [PATCH] soc/qbman: Simplify bman_release()
Date: Mon, 10 Jul 2017 09:28:59 +0200
Message-ID: <20170710072859.2616-1-sebastian.huber@embedded-brains.de>
Cc: linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org,
 Madalin Bucur <madalin.bucur@nxp.com>
To: netdev@vger.kernel.org
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

Get the affine portal only once for the complete transaction.

Signed-off-by: Sebastian Huber <sebastian.huber@embedded-brains.de>
---
 drivers/soc/fsl/qbman/bman.c | 15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/drivers/soc/fsl/qbman/bman.c b/drivers/soc/fsl/qbman/bman.c
index a3d6d7cfa929..0af2069a6b7e 100644
--- a/drivers/soc/fsl/qbman/bman.c
+++ b/drivers/soc/fsl/qbman/bman.c
@@ -723,26 +723,23 @@ int bman_release(struct bman_pool *pool, const struct bm_buffer *bufs, u8 num)
 
 	DPAA_ASSERT(num > 0 && num <= 8);
 
-	do {
+	while (1) {
 		p = get_affine_portal();
 		local_irq_save(irqflags);
 		avail = bm_rcr_get_avail(&p->p);
 		if (avail < 2)
 			update_rcr_ci(p, avail);
 		r = bm_rcr_start(&p->p);
-		local_irq_restore(irqflags);
-		put_affine_portal();
 		if (likely(r))
 			break;
 
+		local_irq_restore(irqflags);
+		put_affine_portal();
+		if (unlikely(--timeout == 0))
+			return -ETIMEDOUT;
 		udelay(1);
-	} while (--timeout);
-
-	if (unlikely(!timeout))
-		return -ETIMEDOUT;
+	}
 
-	p = get_affine_portal();
-	local_irq_save(irqflags);
 	/*
 	 * we can copy all but the first entry, as this can trigger badness
 	 * with the valid-bit
-- 
2.12.3
