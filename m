From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 4/6] tg3: Add reset_phy parameter to chip reset
 functions
Date: Fri, 28 Apr 2006 16:36:08 -0700
Message-ID: <1146267368.4780.17.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:43019 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1030270AbWD2BRA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 21:17:00 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a reset_phy parameter to tg3_reset_hw() and tg3_init_hw(). With
the full chip reset during MAC address change, the automatic PHY reset
during chip reset will cause a link down and bonding will not work
properly as a result. With this reset_phy parameter, we can do a chip
reset without link down when changing MAC address or MTU.

Signed-off-by: Gary Zambrano <zambrano@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 0ccfb63..97e27d8 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -3544,7 +3544,7 @@ static irqreturn_t tg3_test_isr(int irq,
 	return IRQ_RETVAL(0);
 }
 
-static int tg3_init_hw(struct tg3 *);
+static int tg3_init_hw(struct tg3 *, int);
 static int tg3_halt(struct tg3 *, int, int);
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -3580,7 +3580,7 @@ static void tg3_reset_task(void *_data)
 	tp->tg3_flags2 &= ~TG3_FLG2_RESTART_TIMER;
 
 	tg3_halt(tp, RESET_KIND_SHUTDOWN, 0);
-	tg3_init_hw(tp);
+	tg3_init_hw(tp, 1);
 
 	tg3_netif_start(tp);
 
@@ -4055,7 +4055,7 @@ static int tg3_change_mtu(struct net_dev
 
 	tg3_set_mtu(dev, tp, new_mtu);
 
-	tg3_init_hw(tp);
+	tg3_init_hw(tp, 0);
 
 	tg3_netif_start(tp);
 
@@ -5740,7 +5740,7 @@ static int tg3_set_mac_addr(struct net_d
 		tg3_full_lock(tp, 1);
 
 		tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
-		tg3_init_hw(tp);
+		tg3_init_hw(tp, 0);
 
 		tg3_netif_start(tp);
 		tg3_full_unlock(tp);
@@ -5798,7 +5798,7 @@ static void __tg3_set_coalesce(struct tg
 }
 
 /* tp->lock is held. */
-static int tg3_reset_hw(struct tg3 *tp)
+static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 {
 	u32 val, rdmac_mode;
 	int i, err, limit;
@@ -5813,7 +5813,7 @@ static int tg3_reset_hw(struct tg3 *tp)
 		tg3_abort_hw(tp, 1);
 	}
 
-	if (tp->tg3_flags2 & TG3_FLG2_MII_SERDES)
+	if ((tp->tg3_flags2 & TG3_FLG2_MII_SERDES) && reset_phy)
 		tg3_phy_reset(tp);
 
 	err = tg3_chip_reset(tp);
@@ -6354,7 +6354,7 @@ static int tg3_reset_hw(struct tg3 *tp)
 		tw32(GRC_LOCAL_CTRL, tp->grc_local_ctrl);
 	}
 
-	err = tg3_setup_phy(tp, 1);
+	err = tg3_setup_phy(tp, reset_phy);
 	if (err)
 		return err;
 
@@ -6427,7 +6427,7 @@ static int tg3_reset_hw(struct tg3 *tp)
 /* Called at device open time to get the chip ready for
  * packet processing.  Invoked with tp->lock held.
  */
-static int tg3_init_hw(struct tg3 *tp)
+static int tg3_init_hw(struct tg3 *tp, int reset_phy)
 {
 	int err;
 
@@ -6440,7 +6440,7 @@ static int tg3_init_hw(struct tg3 *tp)
 
 	tw32(TG3PCI_MEM_WIN_BASE_ADDR, 0);
 
-	err = tg3_reset_hw(tp);
+	err = tg3_reset_hw(tp, reset_phy);
 
 out:
 	return err;
@@ -6710,7 +6710,7 @@ static int tg3_test_msi(struct tg3 *tp)
 	tg3_full_lock(tp, 1);
 
 	tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
-	err = tg3_init_hw(tp);
+	err = tg3_init_hw(tp, 1);
 
 	tg3_full_unlock(tp);
 
@@ -6775,7 +6775,7 @@ static int tg3_open(struct net_device *d
 
 	tg3_full_lock(tp, 0);
 
-	err = tg3_init_hw(tp);
+	err = tg3_init_hw(tp, 1);
 	if (err) {
 		tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
 		tg3_free_rings(tp);
@@ -7866,7 +7866,7 @@ static int tg3_set_ringparam(struct net_
 
 	if (netif_running(dev)) {
 		tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
-		tg3_init_hw(tp);
+		tg3_init_hw(tp, 1);
 		tg3_netif_start(tp);
 	}
 
@@ -7911,7 +7911,7 @@ static int tg3_set_pauseparam(struct net
 
 	if (netif_running(dev)) {
 		tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
-		tg3_init_hw(tp);
+		tg3_init_hw(tp, 1);
 		tg3_netif_start(tp);
 	}
 
@@ -8549,7 +8549,7 @@ static int tg3_test_loopback(struct tg3 
 	if (!netif_running(tp->dev))
 		return TG3_LOOPBACK_FAILED;
 
-	tg3_reset_hw(tp);
+	tg3_reset_hw(tp, 1);
 
 	if (tg3_run_loopback(tp, TG3_MAC_LOOPBACK))
 		err |= TG3_MAC_LOOPBACK_FAILED;
@@ -8623,7 +8623,7 @@ static void tg3_self_test(struct net_dev
 		tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
 		if (netif_running(dev)) {
 			tp->tg3_flags |= TG3_FLAG_INIT_COMPLETE;
-			tg3_init_hw(tp);
+			tg3_init_hw(tp, 1);
 			tg3_netif_start(tp);
 		}
 
@@ -11599,7 +11599,7 @@ static int tg3_suspend(struct pci_dev *p
 		tg3_full_lock(tp, 0);
 
 		tp->tg3_flags |= TG3_FLAG_INIT_COMPLETE;
-		tg3_init_hw(tp);
+		tg3_init_hw(tp, 1);
 
 		tp->timer.expires = jiffies + tp->timer_offset;
 		add_timer(&tp->timer);
@@ -11633,7 +11633,7 @@ static int tg3_resume(struct pci_dev *pd
 	tg3_full_lock(tp, 0);
 
 	tp->tg3_flags |= TG3_FLAG_INIT_COMPLETE;
-	tg3_init_hw(tp);
+	tg3_init_hw(tp, 1);
 
 	tp->timer.expires = jiffies + tp->timer_offset;
 	add_timer(&tp->timer);


