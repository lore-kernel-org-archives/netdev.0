From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH] sky2: Avoid transmitting during sky2_restart()
Date: Sun, 12 Jul 2009 14:39:29 +0900
Message-ID: <392fb48f0907112239j4c85932cj3f5f180bb8507143@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f215.google.com ([209.85.217.215]:62535 "EHLO
	mail-gx0-f215.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751169AbZGLFja (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jul 2009 01:39:30 -0400
Received: by gxk11 with SMTP id 11so1375791gxk.13
        for <netdev@vger.kernel.org>; Sat, 11 Jul 2009 22:39:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

"ifconfig eth1 up; pktget eth1" will crashed my machine within 10
seconds. (eth1 is sky2)
It appears that sky2_tx_timeout causes a restart, and packets in the
tx queue are free'd twice (once in sky2_status_intr and once in
sky2_down).
Furthermore, if sky2_xmit_frame is called during sky2_restart, bad
things will happen.

This patch fixes both problems and was tested on top of my previous
sky2_down fix.

thanks,

Mike

---

Block the transmit queue during sky2_restart().
Don't free transmit packets in sky2_status_intr() during restart,
 as they'll be free'd in sky2_tx_clean()

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |    9 ++++++++-
 drivers/net/sky2.h |    1 +
 2 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 21ec0ca..77fd1b9 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1540,6 +1540,8 @@ static inline int tx_dist(unsigned tail, unsigned head)
 /* Number of list elements available for next tx */
 static inline int tx_avail(const struct sky2_port *sky2)
 {
+	if (unlikely(sky2->hw->flags & SKY2_HW_RESTARTING))
+		return 0;
 	return sky2->tx_pending - tx_dist(sky2->tx_cons, sky2->tx_prod);
 }

@@ -2366,7 +2368,8 @@ static inline void sky2_tx_done(struct
net_device *dev, u16 last)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);

-	if (netif_running(dev)) {
+	if (netif_running(dev) &&
+	    !(sky2->hw->flags & SKY2_HW_RESTARTING)) {
 		netif_tx_lock(dev);
 		sky2_tx_complete(sky2, last);
 		netif_tx_unlock(dev);
@@ -3081,6 +3084,7 @@ static void sky2_restart(struct work_struct *work)
 	int i, err;

 	rtnl_lock();
+	hw->flags |= SKY2_HW_RESTARTING;
 	for (i = 0; i < hw->ports; i++) {
 		dev = hw->dev[i];
 		if (netif_running(dev))
@@ -3092,6 +3096,7 @@ static void sky2_restart(struct work_struct *work)
 	sky2_reset(hw);
 	sky2_write32(hw, B0_IMSK, Y2_IS_BASE);
 	napi_enable(&hw->napi);
+	hw->flags &= ~SKY2_HW_RESTARTING;

 	for (i = 0; i < hw->ports; i++) {
 		dev = hw->dev[i];
@@ -3102,6 +3107,8 @@ static void sky2_restart(struct work_struct *work)
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
