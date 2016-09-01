From: Jeremy Linton <jeremy.linton@arm.com>
Subject: [PATCH 3/4] net: smsc911x: Move interrupt handler before open
Date: Thu,  1 Sep 2016 15:15:08 -0500
Message-ID: <1472760909-19688-4-git-send-email-jeremy.linton@arm.com>
References: <1472760909-19688-1-git-send-email-jeremy.linton@arm.com>
Cc: steve.glendinning@shawell.net, sergei.shtylyov@cogentembedded.com,
        andrew@lunn.ch, will.deacon@arm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:39380 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934411AbcIAVdx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Sep 2016 17:33:53 -0400
In-Reply-To: <1472760909-19688-1-git-send-email-jeremy.linton@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for the allocating/enabling interrupts
in the ndo_open routine move the irq handler before it.

Signed-off-by: Jeremy Linton <jeremy.linton@arm.com>
---
 drivers/net/ethernet/smsc/smsc911x.c | 122 +++++++++++++++++------------------
 1 file changed, 61 insertions(+), 61 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 823ad3f..c2e56f0 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -1507,6 +1507,67 @@ static void smsc911x_disable_irq_chip(struct net_device *dev)
 	smsc911x_reg_write(pdata, INT_STS, 0xFFFFFFFF);
 }
 
+static irqreturn_t smsc911x_irqhandler(int irq, void *dev_id)
+{
+	struct net_device *dev = dev_id;
+	struct smsc911x_data *pdata = netdev_priv(dev);
+	u32 intsts = smsc911x_reg_read(pdata, INT_STS);
+	u32 inten = smsc911x_reg_read(pdata, INT_EN);
+	int serviced = IRQ_NONE;
+	u32 temp;
+
+	if (unlikely(intsts & inten & INT_STS_SW_INT_)) {
+		temp = smsc911x_reg_read(pdata, INT_EN);
+		temp &= (~INT_EN_SW_INT_EN_);
+		smsc911x_reg_write(pdata, INT_EN, temp);
+		smsc911x_reg_write(pdata, INT_STS, INT_STS_SW_INT_);
+		pdata->software_irq_signal = 1;
+		smp_wmb();
+		serviced = IRQ_HANDLED;
+	}
+
+	if (unlikely(intsts & inten & INT_STS_RXSTOP_INT_)) {
+		/* Called when there is a multicast update scheduled and
+		 * it is now safe to complete the update */
+		SMSC_TRACE(pdata, intr, "RX Stop interrupt");
+		smsc911x_reg_write(pdata, INT_STS, INT_STS_RXSTOP_INT_);
+		if (pdata->multicast_update_pending)
+			smsc911x_rx_multicast_update_workaround(pdata);
+		serviced = IRQ_HANDLED;
+	}
+
+	if (intsts & inten & INT_STS_TDFA_) {
+		temp = smsc911x_reg_read(pdata, FIFO_INT);
+		temp |= FIFO_INT_TX_AVAIL_LEVEL_;
+		smsc911x_reg_write(pdata, FIFO_INT, temp);
+		smsc911x_reg_write(pdata, INT_STS, INT_STS_TDFA_);
+		netif_wake_queue(dev);
+		serviced = IRQ_HANDLED;
+	}
+
+	if (unlikely(intsts & inten & INT_STS_RXE_)) {
+		SMSC_TRACE(pdata, intr, "RX Error interrupt");
+		smsc911x_reg_write(pdata, INT_STS, INT_STS_RXE_);
+		serviced = IRQ_HANDLED;
+	}
+
+	if (likely(intsts & inten & INT_STS_RSFL_)) {
+		if (likely(napi_schedule_prep(&pdata->napi))) {
+			/* Disable Rx interrupts */
+			temp = smsc911x_reg_read(pdata, INT_EN);
+			temp &= (~INT_EN_RSFL_EN_);
+			smsc911x_reg_write(pdata, INT_EN, temp);
+			/* Schedule a NAPI poll */
+			__napi_schedule(&pdata->napi);
+		} else {
+			SMSC_WARN(pdata, rx_err, "napi_schedule_prep failed");
+		}
+		serviced = IRQ_HANDLED;
+	}
+
+	return serviced;
+}
+
 static int smsc911x_open(struct net_device *dev)
 {
 	struct smsc911x_data *pdata = netdev_priv(dev);
@@ -1820,67 +1881,6 @@ static void smsc911x_set_multicast_list(struct net_device *dev)
 	spin_unlock_irqrestore(&pdata->mac_lock, flags);
 }
 
-static irqreturn_t smsc911x_irqhandler(int irq, void *dev_id)
-{
-	struct net_device *dev = dev_id;
-	struct smsc911x_data *pdata = netdev_priv(dev);
-	u32 intsts = smsc911x_reg_read(pdata, INT_STS);
-	u32 inten = smsc911x_reg_read(pdata, INT_EN);
-	int serviced = IRQ_NONE;
-	u32 temp;
-
-	if (unlikely(intsts & inten & INT_STS_SW_INT_)) {
-		temp = smsc911x_reg_read(pdata, INT_EN);
-		temp &= (~INT_EN_SW_INT_EN_);
-		smsc911x_reg_write(pdata, INT_EN, temp);
-		smsc911x_reg_write(pdata, INT_STS, INT_STS_SW_INT_);
-		pdata->software_irq_signal = 1;
-		smp_wmb();
-		serviced = IRQ_HANDLED;
-	}
-
-	if (unlikely(intsts & inten & INT_STS_RXSTOP_INT_)) {
-		/* Called when there is a multicast update scheduled and
-		 * it is now safe to complete the update */
-		SMSC_TRACE(pdata, intr, "RX Stop interrupt");
-		smsc911x_reg_write(pdata, INT_STS, INT_STS_RXSTOP_INT_);
-		if (pdata->multicast_update_pending)
-			smsc911x_rx_multicast_update_workaround(pdata);
-		serviced = IRQ_HANDLED;
-	}
-
-	if (intsts & inten & INT_STS_TDFA_) {
-		temp = smsc911x_reg_read(pdata, FIFO_INT);
-		temp |= FIFO_INT_TX_AVAIL_LEVEL_;
-		smsc911x_reg_write(pdata, FIFO_INT, temp);
-		smsc911x_reg_write(pdata, INT_STS, INT_STS_TDFA_);
-		netif_wake_queue(dev);
-		serviced = IRQ_HANDLED;
-	}
-
-	if (unlikely(intsts & inten & INT_STS_RXE_)) {
-		SMSC_TRACE(pdata, intr, "RX Error interrupt");
-		smsc911x_reg_write(pdata, INT_STS, INT_STS_RXE_);
-		serviced = IRQ_HANDLED;
-	}
-
-	if (likely(intsts & inten & INT_STS_RSFL_)) {
-		if (likely(napi_schedule_prep(&pdata->napi))) {
-			/* Disable Rx interrupts */
-			temp = smsc911x_reg_read(pdata, INT_EN);
-			temp &= (~INT_EN_RSFL_EN_);
-			smsc911x_reg_write(pdata, INT_EN, temp);
-			/* Schedule a NAPI poll */
-			__napi_schedule(&pdata->napi);
-		} else {
-			SMSC_WARN(pdata, rx_err, "napi_schedule_prep failed");
-		}
-		serviced = IRQ_HANDLED;
-	}
-
-	return serviced;
-}
-
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void smsc911x_poll_controller(struct net_device *dev)
 {
-- 
2.5.5
