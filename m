From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: [PATCH] sky2: avoid pci write posting after disabling irqs
Date: Sun, 30 Nov 2014 12:56:51 +0100
Message-ID: <1417348611-1752-1-git-send-email-LinoSanfilippo@gmx.de>
Cc: mlindner@marvell.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Lino Sanfilippo <LinoSanfilippo@gmx.de>
To: stephen@networkplumber.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In sky2_change_mtu setting B0_IMSK to 0 may be delayed due to PCI write posting
which could result in irqs being still active when synchronize_irq is called.
Since we are not prepared to handle any further irqs after synchronize_irq
(our resources are freed after that) force the write by a consecutive read from
the same register.
Similar situation in sky2_all_down: Here we disabled irqs by a write to B0_IMSK
but did not ensure that this write took place before synchronize_irq. Fix that
too.

Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
 drivers/net/ethernet/marvell/sky2.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index bd33662..f14544c 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -2419,6 +2419,7 @@ static int sky2_change_mtu(struct net_device *dev, int new_mtu)
 
 	imask = sky2_read32(hw, B0_IMSK);
 	sky2_write32(hw, B0_IMSK, 0);
+	sky2_read32(hw, B0_IMSK);
 
 	dev->trans_start = jiffies;	/* prevent tx timeout */
 	napi_disable(&hw->napi);
@@ -3487,8 +3488,8 @@ static void sky2_all_down(struct sky2_hw *hw)
 	int i;
 
 	if (hw->flags & SKY2_HW_IRQ_SETUP) {
-		sky2_read32(hw, B0_IMSK);
 		sky2_write32(hw, B0_IMSK, 0);
+		sky2_read32(hw, B0_IMSK);
 
 		synchronize_irq(hw->pdev->irq);
 		napi_disable(&hw->napi);
-- 
1.9.1
