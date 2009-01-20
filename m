From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [RFC PATCH] smsc911x: protect INT_EN read-modify-write with spinlock
Date: Tue, 20 Jan 2009 14:01:54 +0000
Message-ID: <1232460114-13469-1-git-send-email-steve.glendinning@smsc.com>
Cc: David Miller <davem@davemloft.net>,
	Ian Saturley <ian.saturley@smsc.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sandgatehouse.force9.co.uk ([84.92.144.20]:38624 "EHLO
	kensington.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750825AbZATOBB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 09:01:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a new spinlock to protect read-modify-writes to the
INT_EN register when enabling and disabling interrupt sources.

I haven't actually seen any devices lock up, but I think there's a
possibility and I'd like to eliminate it.

Should I add this new spinlock, or should I extend the mac_lock
to also cover these sections (renaming it to simply "lock")?

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/smsc911x.c |   22 ++++++++++++++++++++++
 1 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index f513bdf..3f52d23 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -88,6 +88,9 @@ struct smsc911x_data {
 	 * unused with a 32-bit bus */
 	spinlock_t dev_lock;
 
+	/* spinlock to protect INT_EN read-modify-writes */
+	spinlock_t int_lock;
+
 	struct phy_device *phy_dev;
 	struct mii_bus *mii_bus;
 	int phy_irq[PHY_MAX_ADDR];
@@ -981,13 +984,16 @@ static int smsc911x_poll(struct napi_struct *napi, int budget)
 
 		if (!rxstat) {
 			unsigned int temp;
+			unsigned long flags;
 			/* We processed all packets available.  Tell NAPI it can
 			 * stop polling then re-enable rx interrupts */
 			smsc911x_reg_write(pdata, INT_STS, INT_STS_RSFL_);
 			netif_rx_complete(napi);
+			spin_lock_irqsave(&pdata->int_lock, flags);
 			temp = smsc911x_reg_read(pdata, INT_EN);
 			temp |= INT_EN_RSFL_EN_;
 			smsc911x_reg_write(pdata, INT_EN, temp);
+			spin_unlock_irqrestore(&pdata->int_lock, flags);
 			break;
 		}
 
@@ -1178,7 +1184,9 @@ static int smsc911x_open(struct net_device *dev)
 	spin_unlock_irq(&pdata->mac_lock);
 
 	/* Initialise irqs, but leave all sources disabled */
+	spin_lock_irq(&pdata->int_lock);
 	smsc911x_reg_write(pdata, INT_EN, 0);
+	spin_unlock_irq(&pdata->int_lock);
 	smsc911x_reg_write(pdata, INT_STS, 0xFFFFFFFF);
 
 	/* Set interrupt deassertion to 100uS */
@@ -1204,9 +1212,11 @@ static int smsc911x_open(struct net_device *dev)
 	pdata->software_irq_signal = 0;
 	smp_wmb();
 
+	spin_lock_irq(&pdata->int_lock);
 	temp = smsc911x_reg_read(pdata, INT_EN);
 	temp |= INT_EN_SW_INT_EN_;
 	smsc911x_reg_write(pdata, INT_EN, temp);
+	spin_unlock_irq(&pdata->int_lock);
 
 	timeout = 1000;
 	while (timeout--) {
@@ -1245,9 +1255,11 @@ static int smsc911x_open(struct net_device *dev)
 	/* enable NAPI polling before enabling RX interrupts */
 	napi_enable(&pdata->napi);
 
+	spin_lock_irq(&pdata->int_lock);
 	temp = smsc911x_reg_read(pdata, INT_EN);
 	temp |= (INT_EN_TDFA_EN_ | INT_EN_RSFL_EN_);
 	smsc911x_reg_write(pdata, INT_EN, temp);
+	spin_unlock_irq(&pdata->int_lock);
 
 	spin_lock_irq(&pdata->mac_lock);
 	temp = smsc911x_mac_read(pdata, MAC_CR);
@@ -1419,9 +1431,11 @@ static void smsc911x_set_multicast_list(struct net_device *dev)
 			/* Request the hardware to stop, then perform the
 			 * update when we get an RX_STOP interrupt */
 			smsc911x_reg_write(pdata, INT_STS, INT_STS_RXSTOP_INT_);
+			spin_lock(&pdata->int_lock);
 			temp = smsc911x_reg_read(pdata, INT_EN);
 			temp |= INT_EN_RXSTOP_INT_EN_;
 			smsc911x_reg_write(pdata, INT_EN, temp);
+			spin_unlock(&pdata->int_lock);
 
 			temp = smsc911x_mac_read(pdata, MAC_CR);
 			temp &= ~(MAC_CR_RXEN_);
@@ -1445,12 +1459,15 @@ static irqreturn_t smsc911x_irqhandler(int irq, void *dev_id)
 	u32 intsts = smsc911x_reg_read(pdata, INT_STS);
 	u32 inten = smsc911x_reg_read(pdata, INT_EN);
 	int serviced = IRQ_NONE;
+	unsigned long flags;
 	u32 temp;
 
 	if (unlikely(intsts & inten & INT_STS_SW_INT_)) {
+		spin_lock_irqsave(&pdata->int_lock, flags);
 		temp = smsc911x_reg_read(pdata, INT_EN);
 		temp &= (~INT_EN_SW_INT_EN_);
 		smsc911x_reg_write(pdata, INT_EN, temp);
+		spin_unlock_irqrestore(&pdata->int_lock, flags);
 		smsc911x_reg_write(pdata, INT_STS, INT_STS_SW_INT_);
 		pdata->software_irq_signal = 1;
 		smp_wmb();
@@ -1461,9 +1478,11 @@ static irqreturn_t smsc911x_irqhandler(int irq, void *dev_id)
 		/* Called when there is a multicast update scheduled and
 		 * it is now safe to complete the update */
 		SMSC_TRACE(INTR, "RX Stop interrupt");
+		spin_lock_irqsave(&pdata->int_lock, flags);
 		temp = smsc911x_reg_read(pdata, INT_EN);
 		temp &= (~INT_EN_RXSTOP_INT_EN_);
 		smsc911x_reg_write(pdata, INT_EN, temp);
+		spin_unlock_irqrestore(&pdata->int_lock, flags);
 		smsc911x_reg_write(pdata, INT_STS, INT_STS_RXSTOP_INT_);
 		smsc911x_rx_multicast_update_workaround(pdata);
 		serviced = IRQ_HANDLED;
@@ -1487,9 +1506,11 @@ static irqreturn_t smsc911x_irqhandler(int irq, void *dev_id)
 	if (likely(intsts & inten & INT_STS_RSFL_)) {
 		if (likely(netif_rx_schedule_prep(&pdata->napi))) {
 			/* Disable Rx interrupts */
+			spin_lock_irqsave(&pdata->int_lock, flags);
 			temp = smsc911x_reg_read(pdata, INT_EN);
 			temp &= (~INT_EN_RSFL_EN_);
 			smsc911x_reg_write(pdata, INT_EN, temp);
+			spin_unlock_irqrestore(&pdata->int_lock, flags);
 			/* Schedule a NAPI poll */
 			__netif_rx_schedule(&pdata->napi);
 		} else {
@@ -1760,6 +1781,7 @@ static int __devinit smsc911x_init(struct net_device *dev)
 	SMSC_TRACE(PROBE, "PHY will be autodetected.");
 
 	spin_lock_init(&pdata->dev_lock);
+	spin_lock_init(&pdata->int_lock);
 
 	if (pdata->ioaddr == 0) {
 		SMSC_WARNING(PROBE, "pdata->ioaddr: 0x00000000");
-- 
1.6.0.6

