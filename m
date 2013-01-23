From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 10/12] cnic, bnx2x: Add
 CNIC_DRV_STATE_HANDLES_IRQ to ethdev->drv_state
Date: Wed, 23 Jan 2013 15:21:52 +0200
Message-ID: <1358947314-3851-11-git-send-email-yuvalmin@broadcom.com>
References: <1358947314-3851-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1448 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755799Ab3AWOXR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 09:23:17 -0500
In-Reply-To: <1358947314-3851-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <mchan@broadcom.com>

In INTA mode, cnic and bnx2x share the same IRQ.  During chip reset,
for example, cnic will stop servicing IRQs after it has shutdown the
cnic hardware resources.  However, the shared IRQ is still active as
bnx2x needs to finish the reset.  There is a window when bnx2x does
not know that cnic is no longer handling IRQ and things don't always
work properly.

Add a flag to tell bnx2x that cnic is handling IRQ.  The flag is set
before the first cnic IRQ is expected and cleared when no more cnic
IRQs are expected, so there should be no race conditions.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 14 ++++++--------
 drivers/net/ethernet/broadcom/cnic.c             |  4 ++++
 drivers/net/ethernet/broadcom/cnic_if.h          |  1 +
 3 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index ac00ddc..c4daee1 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -1875,14 +1875,12 @@ irqreturn_t bnx2x_interrupt(int irq, void *dev_instance)
 		if (status & (mask | 0x1)) {
 			struct cnic_ops *c_ops = NULL;
 
-			if (likely(bp->state == BNX2X_STATE_OPEN)) {
-				rcu_read_lock();
-				c_ops = rcu_dereference(bp->cnic_ops);
-				if (c_ops)
-					c_ops->cnic_handler(bp->cnic_data,
-							    NULL);
-				rcu_read_unlock();
-			}
+			rcu_read_lock();
+			c_ops = rcu_dereference(bp->cnic_ops);
+			if (c_ops && (bp->cnic_eth_dev.drv_state &
+				      CNIC_DRV_STATE_HANDLES_IRQ))
+				c_ops->cnic_handler(bp->cnic_data, NULL);
+			rcu_read_unlock();
 
 			status &= ~mask;
 		}
diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index df8c30d..1c4dadc 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -4816,6 +4816,8 @@ static int cnic_start_bnx2_hw(struct cnic_dev *dev)
 		return err;
 	}
 
+	ethdev->drv_state |= CNIC_DRV_STATE_HANDLES_IRQ;
+
 	return 0;
 }
 
@@ -5136,6 +5138,7 @@ static int cnic_start_bnx2x_hw(struct cnic_dev *dev)
 	if (ret)
 		return ret;
 
+	ethdev->drv_state |= CNIC_DRV_STATE_HANDLES_IRQ;
 	return 0;
 }
 
@@ -5387,6 +5390,7 @@ static void cnic_stop_hw(struct cnic_dev *dev)
 		}
 		cnic_shutdown_rings(dev);
 		cp->stop_cm(dev);
+		cp->ethdev->drv_state &= ~CNIC_DRV_STATE_HANDLES_IRQ;
 		clear_bit(CNIC_F_CNIC_UP, &dev->flags);
 		RCU_INIT_POINTER(cp->ulp_ops[CNIC_ULP_L4], NULL);
 		synchronize_rcu();
diff --git a/drivers/net/ethernet/broadcom/cnic_if.h b/drivers/net/ethernet/broadcom/cnic_if.h
index 2a35436..0c9367a 100644
--- a/drivers/net/ethernet/broadcom/cnic_if.h
+++ b/drivers/net/ethernet/broadcom/cnic_if.h
@@ -179,6 +179,7 @@ struct cnic_eth_dev {
 #define CNIC_DRV_STATE_NO_ISCSI_OOO	0x00000004
 #define CNIC_DRV_STATE_NO_ISCSI		0x00000008
 #define CNIC_DRV_STATE_NO_FCOE		0x00000010
+#define CNIC_DRV_STATE_HANDLES_IRQ	0x00000020
 	u32		chip_id;
 	u32		max_kwqe_pending;
 	struct pci_dev	*pdev;
-- 
1.8.1.227.g44fe835
