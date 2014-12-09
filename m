From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [RFC PATCH net-next 04/11] atl1c: remove disable_irq from netpoll controller, use netpoll_irq_lock
Date: Tue,  9 Dec 2014 15:37:15 +0100
Message-ID: <1418135842-21389-5-git-send-email-sd@queasysnail.net>
References: <1418135842-21389-1-git-send-email-sd@queasysnail.net>
Cc: netdev@vger.kernel.org, Sabrina Dubroca <sd@queasysnail.net>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:52958 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753294AbaLIOjP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 09:39:15 -0500
In-Reply-To: <1418135842-21389-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

disable_irq() may sleep, replace it with a spin_lock in the interrupt handler.

No actual testing done, only compiled.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Cc: Jay Cliburn <jcliburn@gmail.com>
Cc: Chris Snook <chris.snook@gmail.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c.h      |  3 +++
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c | 12 ++++++++----
 2 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c.h b/drivers/net/ethernet/atheros/atl1c/atl1c.h
index b9203d928938..8d97791e1516 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c.h
@@ -49,6 +49,7 @@
 #include <linux/workqueue.h>
 #include <net/checksum.h>
 #include <net/ip6_checksum.h>
+#include <linux/netpoll.h>
 
 #include "atl1c_hw.h"
 
@@ -555,6 +556,8 @@ struct atl1c_adapter {
 	struct atl1c_rfd_ring rfd_ring;
 	struct atl1c_rrd_ring rrd_ring;
 	u32 bd_number;     /* board number;*/
+
+	struct netpoll_irq_lock netpoll_lock;
 };
 
 #define AT_WRITE_REG(a, reg, value) ( \
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 72fb86b9aa24..7a1b11eb8e4e 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -826,6 +826,7 @@ static int atl1c_sw_init(struct atl1c_adapter *adapter)
 	atomic_set(&adapter->irq_sem, 1);
 	spin_lock_init(&adapter->mdio_lock);
 	spin_lock_init(&adapter->tx_lock);
+	netpoll_irq_lock_init(&adapter->netpoll_lock);
 	set_bit(__AT_DOWN, &adapter->flags);
 
 	return 0;
@@ -1584,10 +1585,11 @@ static irqreturn_t atl1c_intr(int irq, void *data)
 	struct pci_dev *pdev = adapter->pdev;
 	struct atl1c_hw *hw = &adapter->hw;
 	int max_ints = AT_MAX_INT_WORK;
-	int handled = IRQ_NONE;
+	irqreturn_t handled = IRQ_NONE;
 	u32 status;
 	u32 reg_data;
 
+	netpoll_irq_lock(&adapter->netpoll_lock);
 	do {
 		AT_READ_REG(hw, REG_ISR, &reg_data);
 		status = reg_data & hw->intr_mask;
@@ -1622,7 +1624,8 @@ static irqreturn_t atl1c_intr(int irq, void *data)
 			/* reset MAC */
 			set_bit(ATL1C_WORK_EVENT_RESET, &adapter->work_event);
 			schedule_work(&adapter->common_task);
-			return IRQ_HANDLED;
+			handled = IRQ_HANDLED;
+			goto out;
 		}
 
 		if (status & ISR_OVER)
@@ -1641,6 +1644,9 @@ static irqreturn_t atl1c_intr(int irq, void *data)
 	} while (--max_ints > 0);
 	/* re-enable Interrupt*/
 	AT_WRITE_REG(&adapter->hw, REG_ISR, 0);
+
+out:
+	netpoll_irq_unlock(&adapter->netpoll_lock);
 	return handled;
 }
 
@@ -1900,9 +1906,7 @@ static void atl1c_netpoll(struct net_device *netdev)
 {
 	struct atl1c_adapter *adapter = netdev_priv(netdev);
 
-	disable_irq(adapter->pdev->irq);
 	atl1c_intr(adapter->pdev->irq, netdev);
-	enable_irq(adapter->pdev->irq);
 }
 #endif
 
-- 
2.1.3
