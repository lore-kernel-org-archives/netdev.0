From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream-fixes' branch of wireless-2.6.git
Date: Tue, 31 Oct 2006 22:47:21 -0500
Message-ID: <20061101034715.GB9309@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:64777 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1423939AbWKAEAX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2006 23:00:23 -0500
To: jeff@garzik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've got the right URL this time... :-)

---

The following changes since commit 16b7b2ac0148e839da86af8747b6fa4aad43a9b7:
  Atsushi Nemoto:
        [MIPS] Fixup migration to GENERIC_TIME

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-fixes

Jiri Benc:
      ieee80211: don't flood log with errors

Larry Finger:
      bcm43xx: fix unexpected LED control values in BCM4303 sprom

Michael Buesch:
      bcm43xx: Fix low-traffic netdev watchdog TX timeouts

Pavel Roskin:
      hostap_plx: fix CIS verification

 drivers/net/wireless/bcm43xx/bcm43xx_leds.c |    7 ++++++-
 drivers/net/wireless/bcm43xx/bcm43xx_leds.h |    6 ++++++
 drivers/net/wireless/bcm43xx/bcm43xx_main.c |   16 +++++++++++++++-
 drivers/net/wireless/hostap/hostap_plx.c    |    4 ++--
 net/ieee80211/ieee80211_rx.c                |   12 ++++++------
 5 files changed, 35 insertions(+), 10 deletions(-)

diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_leds.c b/drivers/net/wireless/bcm43xx/bcm43xx_leds.c
index 2ddbec6..7d383a2 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_leds.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_leds.c
@@ -189,20 +189,24 @@ void bcm43xx_leds_update(struct bcm43xx_
 		case BCM43xx_LED_INACTIVE:
 			continue;
 		case BCM43xx_LED_OFF:
+		case BCM43xx_LED_BCM4303_3:
 			break;
 		case BCM43xx_LED_ON:
 			turn_on = 1;
 			break;
 		case BCM43xx_LED_ACTIVITY:
+		case BCM43xx_LED_BCM4303_0:
 			turn_on = activity;
 			break;
 		case BCM43xx_LED_RADIO_ALL:
 			turn_on = radio->enabled;
 			break;
 		case BCM43xx_LED_RADIO_A:
+		case BCM43xx_LED_BCM4303_2:
 			turn_on = (radio->enabled && phy->type == BCM43xx_PHYTYPE_A);
 			break;
 		case BCM43xx_LED_RADIO_B:
+		case BCM43xx_LED_BCM4303_1:
 			turn_on = (radio->enabled &&
 				   (phy->type == BCM43xx_PHYTYPE_B ||
 				    phy->type == BCM43xx_PHYTYPE_G));
@@ -257,7 +261,8 @@ #ifdef CONFIG_BCM43XX_DEBUG
 			continue;
 #endif /* CONFIG_BCM43XX_DEBUG */
 		default:
-			assert(0);
+			dprintkl(KERN_INFO PFX "Bad value in leds_update,"
+				" led->behaviour: 0x%x\n", led->behaviour);
 		};
 
 		if (led->activelow)
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_leds.h b/drivers/net/wireless/bcm43xx/bcm43xx_leds.h
index d3716cf..811e14a 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_leds.h
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_leds.h
@@ -46,6 +46,12 @@ enum { /* LED behaviour values */
 	BCM43xx_LED_TEST_BLINKSLOW,
 	BCM43xx_LED_TEST_BLINKMEDIUM,
 	BCM43xx_LED_TEST_BLINKFAST,
+
+	/* Misc values for BCM4303 */
+	BCM43xx_LED_BCM4303_0 = 0x2B,
+	BCM43xx_LED_BCM4303_1 = 0x78,
+	BCM43xx_LED_BCM4303_2 = 0x2E,
+	BCM43xx_LED_BCM4303_3 = 0x19,
 };
 
 int bcm43xx_leds_init(struct bcm43xx_private *bcm);
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
index a94c6d8..65edb56 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -3163,9 +3163,11 @@ #define BADNESS_LIMIT	4
 static void bcm43xx_periodic_work_handler(void *d)
 {
 	struct bcm43xx_private *bcm = d;
+	struct net_device *net_dev = bcm->net_dev;
 	unsigned long flags;
 	u32 savedirqs = 0;
 	int badness;
+	unsigned long orig_trans_start = 0;
 
 	mutex_lock(&bcm->mutex);
 	badness = estimate_periodic_work_badness(bcm->periodic_state);
@@ -3173,7 +3175,18 @@ static void bcm43xx_periodic_work_handle
 		/* Periodic work will take a long time, so we want it to
 		 * be preemtible.
 		 */
-		netif_tx_disable(bcm->net_dev);
+
+		netif_tx_lock_bh(net_dev);
+		/* We must fake a started transmission here, as we are going to
+		 * disable TX. If we wouldn't fake a TX, it would be possible to
+		 * trigger the netdev watchdog, if the last real TX is already
+		 * some time on the past (slightly less than 5secs)
+		 */
+		orig_trans_start = net_dev->trans_start;
+		net_dev->trans_start = jiffies;
+		netif_stop_queue(net_dev);
+		netif_tx_unlock_bh(net_dev);
+
 		spin_lock_irqsave(&bcm->irq_lock, flags);
 		bcm43xx_mac_suspend(bcm);
 		if (bcm43xx_using_pio(bcm))
@@ -3198,6 +3211,7 @@ static void bcm43xx_periodic_work_handle
 			bcm43xx_pio_thaw_txqueues(bcm);
 		bcm43xx_mac_enable(bcm);
 		netif_wake_queue(bcm->net_dev);
+		net_dev->trans_start = orig_trans_start;
 	}
 	mmiowb();
 	spin_unlock_irqrestore(&bcm->irq_lock, flags);
diff --git a/drivers/net/wireless/hostap/hostap_plx.c b/drivers/net/wireless/hostap/hostap_plx.c
index 6dfa041..bc81b13 100644
--- a/drivers/net/wireless/hostap/hostap_plx.c
+++ b/drivers/net/wireless/hostap/hostap_plx.c
@@ -364,7 +364,7 @@ #define CIS_MAX_LEN 256
 
 	pos = 0;
 	while (pos < CIS_MAX_LEN - 1 && cis[pos] != CISTPL_END) {
-		if (pos + cis[pos + 1] >= CIS_MAX_LEN)
+		if (pos + 2 + cis[pos + 1] > CIS_MAX_LEN)
 			goto cis_error;
 
 		switch (cis[pos]) {
@@ -391,7 +391,7 @@ #define CIS_MAX_LEN 256
 			break;
 
 		case CISTPL_MANFID:
-			if (cis[pos + 1] < 5)
+			if (cis[pos + 1] < 4)
 				goto cis_error;
 			manfid1 = cis[pos + 2] + (cis[pos + 3] << 8);
 			manfid2 = cis[pos + 4] + (cis[pos + 5] << 8);
diff --git a/net/ieee80211/ieee80211_rx.c b/net/ieee80211/ieee80211_rx.c
index 7707041..2759312 100644
--- a/net/ieee80211/ieee80211_rx.c
+++ b/net/ieee80211/ieee80211_rx.c
@@ -1078,12 +1078,12 @@ #endif
 
 	while (length >= sizeof(*info_element)) {
 		if (sizeof(*info_element) + info_element->len > length) {
-			IEEE80211_ERROR("Info elem: parse failed: "
-					"info_element->len + 2 > left : "
-					"info_element->len+2=%zd left=%d, id=%d.\n",
-					info_element->len +
-					sizeof(*info_element),
-					length, info_element->id);
+			IEEE80211_DEBUG_MGMT("Info elem: parse failed: "
+					     "info_element->len + 2 > left : "
+					     "info_element->len+2=%zd left=%d, id=%d.\n",
+					     info_element->len +
+					     sizeof(*info_element),
+					     length, info_element->id);
 			/* We stop processing but don't return an error here
 			 * because some misbehaviour APs break this rule. ie.
 			 * Orinoco AP1000. */
-- 
John W. Linville
linville@tuxdriver.com
