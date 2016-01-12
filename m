From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net: bnxt: always return values from _bnxt_get_max_rings
Date: Tue, 12 Jan 2016 16:05:08 +0100
Message-ID: <4309490.qRrvvx0n1Q@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>,
	Jeffrey Huang <huangjw@broadcom.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.75]:63038 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751112AbcALPF3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 10:05:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Newly added code in the bnxt driver uses a couple of variables that
are never initialized when CONFIG_BNXT_SRIOV is not set, and gcc
correctly warns about that:

In file included from include/linux/list.h:8:0,
                 from include/linux/module.h:9,
                 from drivers/net/ethernet/broadcom/bnxt/bnxt.c:10:
drivers/net/ethernet/broadcom/bnxt/bnxt.c: In function 'bnxt_get_max_rings':
include/linux/kernel.h:794:26: warning: 'cp' may be used uninitialized in this function [-Wmaybe-uninitialized]
include/linux/kernel.h:794:26: warning: 'tx' may be used uninitialized in this function [-Wmaybe-uninitialized]
drivers/net/ethernet/broadcom/bnxt/bnxt.c:5730:11: warning: 'rx' may be used uninitialized in this function [-Wmaybe-uninitialized]
drivers/net/ethernet/broadcom/bnxt/bnxt.c:5736:6: note: 'rx' was declared here

This changes the condition so that we fall back to using the PF
data if VF is not available, and always initialize the variables
to something useful.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 6e6c5a57fbe1 ("bnxt_en: Modify bnxt_get_max_rings() to support shared or non shared rings.")
---
This is the fix that made most sense to me, but that doesn't mean it's
the right thing to do for this driver, so please check carefully
whether falling back to PF is actually the correct behavior.

I'm assuming that BNXT_PF(bp) is meant to always be true if CONFIG_BNXT_SRIOV
is disabled, but I have not verified if this is guaranteed.

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 287bfb79ea2d..df835f5e46d8 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -5711,21 +5711,23 @@ static void _bnxt_get_max_rings(struct bnxt *bp, int *max_rx, int *max_tx,
 {
 	int max_ring_grps = 0;
 
-	if (BNXT_PF(bp)) {
-		*max_tx = bp->pf.max_tx_rings;
-		*max_rx = bp->pf.max_rx_rings;
-		*max_cp = min_t(int, bp->pf.max_irqs, bp->pf.max_cp_rings);
-		*max_cp = min_t(int, *max_cp, bp->pf.max_stat_ctxs);
-		max_ring_grps = bp->pf.max_hw_ring_grps;
-	} else {
 #ifdef CONFIG_BNXT_SRIOV
+	if (!BNXT_PF(bp)) {
 		*max_tx = bp->vf.max_tx_rings;
 		*max_rx = bp->vf.max_rx_rings;
 		*max_cp = min_t(int, bp->vf.max_irqs, bp->vf.max_cp_rings);
 		*max_cp = min_t(int, *max_cp, bp->vf.max_stat_ctxs);
 		max_ring_grps = bp->vf.max_hw_ring_grps;
+	} else
 #endif
+	{
+		*max_tx = bp->pf.max_tx_rings;
+		*max_rx = bp->pf.max_rx_rings;
+		*max_cp = min_t(int, bp->pf.max_irqs, bp->pf.max_cp_rings);
+		*max_cp = min_t(int, *max_cp, bp->pf.max_stat_ctxs);
+		max_ring_grps = bp->pf.max_hw_ring_grps;
 	}
+
 	if (bp->flags & BNXT_FLAG_AGG_RINGS)
 		*max_rx >>= 1;
 	*max_rx = min_t(int, *max_rx, max_ring_grps);
