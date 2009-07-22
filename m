From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH] sky2: Avoid transmitting during sky2_restart()
Date: Wed, 22 Jul 2009 21:39:22 +0900
Message-ID: <392fb48f0907220539p79641245gefb725f49fafab4b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f213.google.com ([209.85.217.213]:34207 "EHLO
	mail-gx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754205AbZGVMjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2009 08:39:23 -0400
Received: by gxk9 with SMTP id 9so258581gxk.13
        for <netdev@vger.kernel.org>; Wed, 22 Jul 2009 05:39:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

I've improved this patch a little to stop the transmit queue before
starting to return NETDEV_TX_BUSY in sky2_xmit_frame().

If you have any suggestions for how to get rid of the
SKY2_HW_RESTARTING state please let me know.  As far as I can tell,
the queue cannot be stopped during a restart using netif_stop_queue
and netif_tx_lock, as those functions are used elsewhere in the code.

thanks,

Mike

---

Block the transmit queue during sky2_restart().
Don't free transmit packets in sky2_status_intr() during restart,
 as they'll be free'd in sky2_tx_clean()

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |   19 ++++++++++++++++++-
 drivers/net/sky2.h |    1 +
 2 files changed, 19 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 661abd0..826d764 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1533,6 +1533,8 @@ static inline int tx_dist(unsigned tail, unsigned head)
 /* Number of list elements available for next tx */
 static inline int tx_avail(const struct sky2_port *sky2)
 {
+	if (unlikely(sky2->hw->flags & SKY2_HW_RESTARTING))
+		return 0;
 	return sky2->tx_pending - tx_dist(sky2->tx_cons, sky2->tx_prod);
 }

@@ -2359,7 +2361,8 @@ static inline void sky2_tx_done(struct
net_device *dev, u16 last)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);

-	if (netif_running(dev)) {
+	if (netif_running(dev) &&
+	    !(sky2->hw->flags & SKY2_HW_RESTARTING)) {
 		netif_tx_lock(dev);
 		sky2_tx_complete(sky2, last);
 		netif_tx_unlock(dev);
@@ -3074,6 +3077,17 @@ static void sky2_restart(struct work_struct *work)
 	int i, err;

 	rtnl_lock();
+
+	/* stop transmit queues */
+	napi_disable(&hw->napi);
+	for (i = 0; i < hw->ports; i++) {
+		dev = hw->dev[i];
+		if (netif_running(dev))
+			netif_stop_queue(dev);
+	}
+	hw->flags |= SKY2_HW_RESTARTING;
+	napi_enable (&hw->napi);
+
 	for (i = 0; i < hw->ports; i++) {
 		dev = hw->dev[i];
 		if (netif_running(dev))
@@ -3085,6 +3099,7 @@ static void sky2_restart(struct work_struct *work)
 	sky2_reset(hw);
 	sky2_write32(hw, B0_IMSK, Y2_IS_BASE);
 	napi_enable(&hw->napi);
+	hw->flags &= ~SKY2_HW_RESTARTING;

 	for (i = 0; i < hw->ports; i++) {
 		dev = hw->dev[i];
@@ -3095,6 +3110,8 @@ static void sky2_restart(struct work_struct *work)
 				       dev->name, err);
 				dev_close(dev);
 			}
+			else
+				netif_wake_queue(dev);
 		}
 	}

diff --git a/drivers/net/sky2.h b/drivers/net/sky2.h
index b5549c9..e71c161 100644
--- a/drivers/net/sky2.h
+++ b/drivers/net/sky2.h
@@ -2073,6 +2073,7 @@ struct sky2_hw {
 #define SKY2_HW_NEW_LE		0x00000020	/* new LSOv2 format */
 #define SKY2_HW_AUTO_TX_SUM	0x00000040	/* new IP decode for Tx */
 #define SKY2_HW_ADV_POWER_CTL	0x00000080	/* additional PHY power regs */
+#define SKY2_HW_RESTARTING	0x00000100	/* true while restarting */

 	u8	     	     chip_id;
 	u8		     chip_rev;
-- 
1.5.6.5
