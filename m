From: Prashant Sreedharan <prashant@broadcom.com>
Subject: [PATCH net 3/3 v2]tg3: Release tp->lock before invoking synchronize_irq()
Date: Wed, 14 Jan 2015 11:34:44 -0800
Message-ID: <1421264084-24015-1-git-send-email-prashant@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <peter@hurleysoftware.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:56653 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752229AbbANTwm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 14:52:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

synchronize_irq() can sleep waiting, for pending IRQ handlers so driver
should release the tp->lock spin lock before invoking synchronize_irq()

Reported-by: Peter Hurley <peter@hurleysoftware.com>
Tested-by: Peter Hurley <peter@hurleysoftware.com>
Signed-off-by: Prashant Sreedharan <prashant@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 9247ae1..96bf01b 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -7413,6 +7413,8 @@ static inline void tg3_netif_start(struct tg3 *tp)
 }
 
 static void tg3_irq_quiesce(struct tg3 *tp)
+	__releases(tp->lock)
+	__acquires(tp->lock)
 {
 	int i;
 
@@ -7421,8 +7423,12 @@ static void tg3_irq_quiesce(struct tg3 *tp)
 	tp->irq_sync = 1;
 	smp_mb();
 
+	spin_unlock_bh(&tp->lock);
+
 	for (i = 0; i < tp->irq_cnt; i++)
 		synchronize_irq(tp->napi[i].irq_vec);
+
+	spin_lock_bh(&tp->lock);
 }
 
 /* Fully shutdown all tg3 driver activity elsewhere in the system.
@@ -9018,6 +9024,8 @@ static void tg3_restore_clk(struct tg3 *tp)
 
 /* tp->lock is held. */
 static int tg3_chip_reset(struct tg3 *tp)
+	__releases(tp->lock)
+	__acquires(tp->lock)
 {
 	u32 val;
 	void (*write_op)(struct tg3 *, u32, u32);
@@ -9073,9 +9081,13 @@ static int tg3_chip_reset(struct tg3 *tp)
 	}
 	smp_mb();
 
+	tg3_full_unlock(tp);
+
 	for (i = 0; i < tp->irq_cnt; i++)
 		synchronize_irq(tp->napi[i].irq_vec);
 
+	tg3_full_lock(tp, 0);
+
 	if (tg3_asic_rev(tp) == ASIC_REV_57780) {
 		val = tr32(TG3_PCIE_LNKCTL) & ~TG3_PCIE_LNKCTL_L1_PLL_PD_EN;
 		tw32(TG3_PCIE_LNKCTL, val | TG3_PCIE_LNKCTL_L1_PLL_PD_DIS);
-- 
1.7.1
