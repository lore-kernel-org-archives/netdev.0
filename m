From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 1/6] tg3: Split APE driver state change out of
 boot reset signature update
Date: Thu, 23 May 2013 14:11:22 -0700
Message-ID: <1369343487-6453-2-git-send-email-nsujir@broadcom.com>
References: <1369343487-6453-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1189 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758982Ab3EWVLn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 May 2013 17:11:43 -0400
In-Reply-To: <1369343487-6453-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unlike the boot signature that needs to be set before every reset, the
ape state only needs to be updated to tell the firmware that the driver
is now taking/releasing control of the hardware. Move the calls to
tg3_ape_driver_state_change() to better, more appropriate places.

Also, the firmware does not distinguish between SUSPEND and START states
anymore. Remove the SUSPEND case in the switch.

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 30 +++++++++++++++---------------
 1 file changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 4f0e3fe..77b51c2 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -965,9 +965,6 @@ static void tg3_ape_driver_state_change(struct tg3 *tp, int kind)
 
 		event = APE_EVENT_STATUS_STATE_UNLOAD;
 		break;
-	case RESET_KIND_SUSPEND:
-		event = APE_EVENT_STATUS_STATE_SUSPEND;
-		break;
 	default:
 		return;
 	}
@@ -1739,10 +1736,6 @@ static void tg3_write_sig_pre_reset(struct tg3 *tp, int kind)
 			break;
 		}
 	}
-
-	if (kind == RESET_KIND_INIT ||
-	    kind == RESET_KIND_SUSPEND)
-		tg3_ape_driver_state_change(tp, kind);
 }
 
 /* tp->lock is held. */
@@ -1764,9 +1757,6 @@ static void tg3_write_sig_post_reset(struct tg3 *tp, int kind)
 			break;
 		}
 	}
-
-	if (kind == RESET_KIND_SHUTDOWN)
-		tg3_ape_driver_state_change(tp, kind);
 }
 
 /* tp->lock is held. */
@@ -4186,6 +4176,8 @@ static int tg3_power_down_prepare(struct tg3 *tp)
 
 	tg3_write_sig_post_reset(tp, RESET_KIND_SHUTDOWN);
 
+	tg3_ape_driver_state_change(tp, RESET_KIND_SHUTDOWN);
+
 	return 0;
 }
 
@@ -11207,6 +11199,9 @@ static int tg3_start(struct tg3 *tp, bool reset_phy, bool test_irq,
 
 	tg3_full_lock(tp, 0);
 
+	if (init)
+		tg3_ape_driver_state_change(tp, RESET_KIND_INIT);
+
 	err = tg3_init_hw(tp, reset_phy);
 	if (err) {
 		tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
@@ -13323,11 +13318,13 @@ static void tg3_self_test(struct net_device *dev, struct ethtool_test *etest,
 	struct tg3 *tp = netdev_priv(dev);
 	bool doextlpbk = etest->flags & ETH_TEST_FL_EXTERNAL_LB;
 
-	if ((tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER) &&
-	    tg3_power_up(tp)) {
-		etest->flags |= ETH_TEST_FL_FAILED;
-		memset(data, 1, sizeof(u64) * TG3_NUM_TEST);
-		return;
+	if (tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER) {
+		if (tg3_power_up(tp)) {
+			etest->flags |= ETH_TEST_FL_FAILED;
+			memset(data, 1, sizeof(u64) * TG3_NUM_TEST);
+			return;
+		}
+		tg3_ape_driver_state_change(tp, RESET_KIND_INIT);
 	}
 
 	memset(data, 0, sizeof(u64) * TG3_NUM_TEST);
@@ -17633,6 +17630,8 @@ static int tg3_resume(struct device *device)
 
 	tg3_full_lock(tp, 0);
 
+	tg3_ape_driver_state_change(tp, RESET_KIND_INIT);
+
 	tg3_flag_set(tp, INIT_COMPLETE);
 	err = tg3_restart_hw(tp,
 			     !(tp->phy_flags & TG3_PHYFLG_KEEP_LINK_ON_PWRDN));
@@ -17767,6 +17766,7 @@ static void tg3_io_resume(struct pci_dev *pdev)
 		goto done;
 
 	tg3_full_lock(tp, 0);
+	tg3_ape_driver_state_change(tp, RESET_KIND_INIT);
 	tg3_flag_set(tp, INIT_COMPLETE);
 	err = tg3_restart_hw(tp, true);
 	if (err) {
-- 
1.8.1.4
