From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 4/7 net-next] tg3: Refactor tg3_open()
Date: Wed, 26 Sep 2012 15:32:46 -0700
Message-ID: <1348698769-760-4-git-send-email-mchan@broadcom.com>
References: <1348698769-760-1-git-send-email-mchan@broadcom.com>
 <1348698769-760-2-git-send-email-mchan@broadcom.com>
 <1348698769-760-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4424 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752487Ab2IZWTh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2012 18:19:37 -0400
In-Reply-To: <1348698769-760-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

by introducing tg3_start() that handles all initialization steps from
IRQ allocation.  This function will be needed when adding support for
changing the number of rx and tx rings.

Reviewed-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   78 ++++++++++++++++++++---------------
 1 files changed, 45 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index ddf260c..9bd99ce 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -10339,38 +10339,11 @@ static void tg3_ints_fini(struct tg3 *tp)
 	tg3_flag_clear(tp, ENABLE_TSS);
 }
 
-static int tg3_open(struct net_device *dev)
+static int tg3_start(struct tg3 *tp, bool reset_phy, bool test_irq)
 {
-	struct tg3 *tp = netdev_priv(dev);
+	struct net_device *dev = tp->dev;
 	int i, err;
 
-	if (tp->fw_needed) {
-		err = tg3_request_firmware(tp);
-		if (tp->pci_chip_rev_id == CHIPREV_ID_5701_A0) {
-			if (err)
-				return err;
-		} else if (err) {
-			netdev_warn(tp->dev, "TSO capability disabled\n");
-			tg3_flag_clear(tp, TSO_CAPABLE);
-		} else if (!tg3_flag(tp, TSO_CAPABLE)) {
-			netdev_notice(tp->dev, "TSO capability restored\n");
-			tg3_flag_set(tp, TSO_CAPABLE);
-		}
-	}
-
-	netif_carrier_off(tp->dev);
-
-	err = tg3_power_up(tp);
-	if (err)
-		return err;
-
-	tg3_full_lock(tp, 0);
-
-	tg3_disable_ints(tp);
-	tg3_flag_clear(tp, INIT_COMPLETE);
-
-	tg3_full_unlock(tp);
-
 	/*
 	 * Setup interrupts first so we know how
 	 * many NAPI resources to allocate
@@ -10404,7 +10377,7 @@ static int tg3_open(struct net_device *dev)
 
 	tg3_full_lock(tp, 0);
 
-	err = tg3_init_hw(tp, 1);
+	err = tg3_init_hw(tp, reset_phy);
 	if (err) {
 		tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
 		tg3_free_rings(tp);
@@ -10415,7 +10388,7 @@ static int tg3_open(struct net_device *dev)
 	if (err)
 		goto err_out3;
 
-	if (tg3_flag(tp, USING_MSI)) {
+	if (test_irq && tg3_flag(tp, USING_MSI)) {
 		err = tg3_test_msi(tp);
 
 		if (err) {
@@ -10471,8 +10444,47 @@ err_out2:
 
 err_out1:
 	tg3_ints_fini(tp);
-	tg3_frob_aux_power(tp, false);
-	pci_set_power_state(tp->pdev, PCI_D3hot);
+
+	return err;
+}
+
+static int tg3_open(struct net_device *dev)
+{
+	struct tg3 *tp = netdev_priv(dev);
+	int err;
+
+	if (tp->fw_needed) {
+		err = tg3_request_firmware(tp);
+		if (tp->pci_chip_rev_id == CHIPREV_ID_5701_A0) {
+			if (err)
+				return err;
+		} else if (err) {
+			netdev_warn(tp->dev, "TSO capability disabled\n");
+			tg3_flag_clear(tp, TSO_CAPABLE);
+		} else if (!tg3_flag(tp, TSO_CAPABLE)) {
+			netdev_notice(tp->dev, "TSO capability restored\n");
+			tg3_flag_set(tp, TSO_CAPABLE);
+		}
+	}
+
+	netif_carrier_off(tp->dev);
+
+	err = tg3_power_up(tp);
+	if (err)
+		return err;
+
+	tg3_full_lock(tp, 0);
+
+	tg3_disable_ints(tp);
+	tg3_flag_clear(tp, INIT_COMPLETE);
+
+	tg3_full_unlock(tp);
+
+	err = tg3_start(tp, true, true);
+	if (err) {
+		tg3_frob_aux_power(tp, false);
+		pci_set_power_state(tp->pdev, PCI_D3hot);
+	}
 	return err;
 }
 
-- 
1.7.1
