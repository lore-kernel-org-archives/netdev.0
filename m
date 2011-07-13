From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 3/7] tg3: Check transitions to D0 power state
Date: Wed, 13 Jul 2011 12:27:29 -0700
Message-ID: <1310585253-4817-4-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3272 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750964Ab1GMT2D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2011 15:28:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently pci_set_power_state() does not return useful return codes for
transitions to the D0 power state.  If a device refuses to go into D0,
the PCI layer issues a warning but returns success.

Entering into D0 is a requirement for correct operation of tg3 devices
though.  If the PCI layer should be changed to return an error code for
this type of failure, the tg3 driver would be interested in catching it
and reacting to it.  This patch makes the necessary modifications.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |   27 +++++++++++++++++----------
 1 files changed, 17 insertions(+), 10 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index ecbc10f..5d4283e 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -2657,14 +2657,19 @@ static void tg3_enable_register_access(struct tg3 *tp)
 
 static int tg3_power_up(struct tg3 *tp)
 {
-	tg3_enable_register_access(tp);
+	int err;
 
-	pci_set_power_state(tp->pdev, PCI_D0);
+	tg3_enable_register_access(tp);
 
-	/* Switch out of Vaux if it is a NIC */
-	tg3_pwrsrc_switch_to_vmain(tp);
+	err = pci_set_power_state(tp->pdev, PCI_D0);
+	if (!err) {
+		/* Switch out of Vaux if it is a NIC */
+		tg3_pwrsrc_switch_to_vmain(tp);
+	} else {
+		netdev_err(tp->dev, "Transition to D0 failed\n");
+	}
 
-	return 0;
+	return err;
 }
 
 static int tg3_power_down_prepare(struct tg3 *tp)
@@ -11433,8 +11438,12 @@ static void tg3_self_test(struct net_device *dev, struct ethtool_test *etest,
 {
 	struct tg3 *tp = netdev_priv(dev);
 
-	if (tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER)
-		tg3_power_up(tp);
+	if ((tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER) &&
+	    tg3_power_up(tp)) {
+		etest->flags |= ETH_TEST_FL_FAILED;
+		memset(data, 1, sizeof(u64) * TG3_NUM_TEST);
+		return;
+	}
 
 	memset(data, 0, sizeof(u64) * TG3_NUM_TEST);
 
@@ -15571,10 +15580,8 @@ static pci_ers_result_t tg3_io_slot_reset(struct pci_dev *pdev)
 	}
 
 	err = tg3_power_up(tp);
-	if (err) {
-		netdev_err(netdev, "Failed to restore register access.\n");
+	if (err)
 		goto done;
-	}
 
 	rc = PCI_ERS_RESULT_RECOVERED;
 
-- 
1.7.3.4


