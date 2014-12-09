From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [RFC PATCH net-next 06/11] s2io: remove disable_irq from netpoll controller, use netpoll_irq_lock
Date: Tue,  9 Dec 2014 15:37:17 +0100
Message-ID: <1418135842-21389-7-git-send-email-sd@queasysnail.net>
References: <1418135842-21389-1-git-send-email-sd@queasysnail.net>
Cc: netdev@vger.kernel.org, Sabrina Dubroca <sd@queasysnail.net>,
	Jon Mason <jdmason@kudzu.us>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:53306 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756892AbaLIOjX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 09:39:23 -0500
In-Reply-To: <1418135842-21389-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

disable_irq() may sleep, replace it with a spin_lock in the interrupt
handler and netpoll controller.

No actual testing done, only compiled.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Cc: Jon Mason <jdmason@kudzu.us>
---
 drivers/net/ethernet/neterion/s2io.c | 27 ++++++++++++++++-----------
 drivers/net/ethernet/neterion/s2io.h |  4 ++++
 2 files changed, 20 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index f5e4b820128b..6730630b7181 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -2838,7 +2838,6 @@ static int s2io_poll_inta(struct napi_struct *napi, int budget)
 static void s2io_netpoll(struct net_device *dev)
 {
 	struct s2io_nic *nic = netdev_priv(dev);
-	const int irq = nic->pdev->irq;
 	struct XENA_dev_config __iomem *bar0 = nic->bar0;
 	u64 val64 = 0xFFFFFFFFFFFFFFFFULL;
 	int i;
@@ -2848,7 +2847,8 @@ static void s2io_netpoll(struct net_device *dev)
 	if (pci_channel_offline(nic->pdev))
 		return;
 
-	disable_irq(irq);
+	/* protects against interrupts from the device */
+	netpoll_irq_lock(&nic->netpoll_lock);
 
 	writeq(val64, &bar0->rx_traffic_int);
 	writeq(val64, &bar0->tx_traffic_int);
@@ -2877,7 +2877,7 @@ static void s2io_netpoll(struct net_device *dev)
 			break;
 		}
 	}
-	enable_irq(irq);
+	netpoll_irq_unlock(&nic->netpoll_lock);
 }
 #endif
 
@@ -4717,13 +4717,16 @@ static irqreturn_t s2io_isr(int irq, void *dev_id)
 	u64 reason = 0;
 	struct mac_info *mac_control;
 	struct config_param *config;
+	irqreturn_t handled = IRQ_NONE;
+
+	netpoll_irq_lock(&sp->netpoll_lock);
 
 	/* Pretend we handled any irq's from a disconnected card */
 	if (pci_channel_offline(sp->pdev))
-		return IRQ_NONE;
+		goto out;
 
 	if (!is_s2io_card_up(sp))
-		return IRQ_NONE;
+		goto out;
 
 	config = &sp->config;
 	mac_control = &sp->mac_control;
@@ -4737,8 +4740,9 @@ static irqreturn_t s2io_isr(int irq, void *dev_id)
 	 */
 	reason = readq(&bar0->general_int_status);
 
+	handled = IRQ_HANDLED;
 	if (unlikely(reason == S2IO_MINUS_ONE))
-		return IRQ_HANDLED;	/* Nothing much can be done. Get out */
+		goto out;	/* Nothing much can be done. Get out */
 
 	if (reason &
 	    (GEN_INTR_RXTRAFFIC | GEN_INTR_TXTRAFFIC | GEN_INTR_TXPIC)) {
@@ -4793,15 +4797,14 @@ static irqreturn_t s2io_isr(int irq, void *dev_id)
 		}
 		writeq(sp->general_int_mask, &bar0->general_int_mask);
 		readl(&bar0->general_int_status);
-
-		return IRQ_HANDLED;
-
 	} else if (!reason) {
 		/* The interrupt was not raised by us */
-		return IRQ_NONE;
+		handled = IRQ_NONE;
 	}
 
-	return IRQ_HANDLED;
+out:
+	netpoll_irq_unlock(&sp->netpoll_lock);
+	return handled;
 }
 
 /**
@@ -7040,6 +7043,7 @@ static int s2io_add_isr(struct s2io_nic *sp)
 				  "MSI-X-TX entries enabled through alarm vector\n");
 		}
 	}
+
 	if (sp->config.intr_type == INTA) {
 		err = request_irq(sp->pdev->irq, s2io_isr, IRQF_SHARED,
 				  sp->name, dev);
@@ -8047,6 +8051,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 
 		spin_lock_init(&fifo->tx_lock);
 	}
+	netpoll_irq_lock_init(&sp->netpoll_lock);
 
 	/*
 	 * SXE-002: Configure link and activity LED to init state
diff --git a/drivers/net/ethernet/neterion/s2io.h b/drivers/net/ethernet/neterion/s2io.h
index d89b6ed82c51..bcfc5e91b926 100644
--- a/drivers/net/ethernet/neterion/s2io.h
+++ b/drivers/net/ethernet/neterion/s2io.h
@@ -13,6 +13,8 @@
 #ifndef _S2IO_H
 #define _S2IO_H
 
+#include <linux/netpoll.h>
+
 #define TBD 0
 #define s2BIT(loc)		(0x8000000000000000ULL >> (loc))
 #define vBIT(val, loc, sz)	(((u64)val) << (64-loc-sz))
@@ -965,6 +967,8 @@ struct s2io_nic {
 #define VPD_STRING_LEN 80
 	u8  product_name[VPD_STRING_LEN];
 	u8  serial_num[VPD_STRING_LEN];
+
+	struct netpoll_irq_lock netpoll_lock;
 };
 
 #define RESET_ERROR 1
-- 
2.1.3
