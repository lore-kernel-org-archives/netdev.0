From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 5/6 net-next] bnx2: Add pci shutdown handler.
Date: Tue, 6 Aug 2013 15:50:11 -0700
Message-ID: <1375829412-26425-6-git-send-email-mchan@broadcom.com>
References: <1375829412-26425-1-git-send-email-mchan@broadcom.com>
 <1375829412-26425-2-git-send-email-mchan@broadcom.com>
 <1375829412-26425-3-git-send-email-mchan@broadcom.com>
 <1375829412-26425-4-git-send-email-mchan@broadcom.com>
 <1375829412-26425-5-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4006 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756556Ab3HFW2J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 18:28:09 -0400
In-Reply-To: <1375829412-26425-5-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

WoL and power state changes will now be done in the shutdown handler.
open/close/ethtool will no longer change the power state.  NVRAM
operations can now be permitted whether the device is up or down.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |   47 ++++++++++++++++++----------------
 1 files changed, 25 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 27a128c..88f5ab1 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -6302,7 +6302,6 @@ bnx2_open(struct net_device *dev)
 
 	netif_carrier_off(dev);
 
-	bnx2_set_power_state(bp, PCI_D0);
 	bnx2_disable_int(bp);
 
 	rc = bnx2_setup_int_mode(bp, disable_msi);
@@ -6709,7 +6708,6 @@ bnx2_close(struct net_device *dev)
 	bnx2_del_napi(bp);
 	bp->link_up = 0;
 	netif_carrier_off(bp->dev);
-	bnx2_set_power_state(bp, PCI_D3hot);
 	return 0;
 }
 
@@ -7144,9 +7142,6 @@ bnx2_get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 	struct bnx2 *bp = netdev_priv(dev);
 	int rc;
 
-	if (!netif_running(dev))
-		return -EAGAIN;
-
 	/* parameters already validated in ethtool_get_eeprom */
 
 	rc = bnx2_nvram_read(bp, eeprom->offset, eebuf, eeprom->len);
@@ -7161,9 +7156,6 @@ bnx2_set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 	struct bnx2 *bp = netdev_priv(dev);
 	int rc;
 
-	if (!netif_running(dev))
-		return -EAGAIN;
-
 	/* parameters already validated in ethtool_set_eeprom */
 
 	rc = bnx2_nvram_write(bp, eeprom->offset, eebuf, eeprom->len);
@@ -7523,8 +7515,6 @@ bnx2_self_test(struct net_device *dev, struct ethtool_test *etest, u64 *buf)
 {
 	struct bnx2 *bp = netdev_priv(dev);
 
-	bnx2_set_power_state(bp, PCI_D0);
-
 	memset(buf, 0, sizeof(u64) * BNX2_NUM_TESTS);
 	if (etest->flags & ETH_TEST_FL_OFFLINE) {
 		int i;
@@ -7573,8 +7563,6 @@ bnx2_self_test(struct net_device *dev, struct ethtool_test *etest, u64 *buf)
 		etest->flags |= ETH_TEST_FL_FAILED;
 
 	}
-	if (!netif_running(bp->dev))
-		bnx2_set_power_state(bp, PCI_D3hot);
 }
 
 static void
@@ -7646,8 +7634,6 @@ bnx2_set_phys_id(struct net_device *dev, enum ethtool_phys_id_state state)
 
 	switch (state) {
 	case ETHTOOL_ID_ACTIVE:
-		bnx2_set_power_state(bp, PCI_D0);
-
 		bp->leds_save = BNX2_RD(bp, BNX2_MISC_CFG);
 		BNX2_WR(bp, BNX2_MISC_CFG, BNX2_MISC_CFG_LEDMODE_MAC);
 		return 1;	/* cycle on/off once per second */
@@ -7668,9 +7654,6 @@ bnx2_set_phys_id(struct net_device *dev, enum ethtool_phys_id_state state)
 	case ETHTOOL_ID_INACTIVE:
 		BNX2_WR(bp, BNX2_EMAC_LED, 0);
 		BNX2_WR(bp, BNX2_MISC_CFG, bp->leds_save);
-
-		if (!netif_running(dev))
-			bnx2_set_power_state(bp, PCI_D3hot);
 		break;
 	}
 
@@ -8118,8 +8101,6 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 		goto err_out_release;
 	}
 
-	bnx2_set_power_state(bp, PCI_D0);
-
 	/* Configure byte swap and enable write to the reg_window registers.
 	 * Rely on CPU to do target byte swapping on big endian systems
 	 * The chip's target access swapping will not swap all accesses
@@ -8705,10 +8686,9 @@ static pci_ers_result_t bnx2_io_slot_reset(struct pci_dev *pdev)
 		pci_restore_state(pdev);
 		pci_save_state(pdev);
 
-		if (netif_running(dev)) {
-			bnx2_set_power_state(bp, PCI_D0);
+		if (netif_running(dev))
 			err = bnx2_init_nic(bp, 1);
-		}
+
 		if (!err)
 			result = PCI_ERS_RESULT_RECOVERED;
 	}
@@ -8752,6 +8732,28 @@ static void bnx2_io_resume(struct pci_dev *pdev)
 	rtnl_unlock();
 }
 
+static void bnx2_shutdown(struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct bnx2 *bp;
+
+	if (!dev)
+		return;
+
+	bp = netdev_priv(dev);
+	if (!bp)
+		return;
+
+	rtnl_lock();
+	if (netif_running(dev))
+		dev_close(bp->dev);
+
+	if (system_state == SYSTEM_POWER_OFF)
+		bnx2_set_power_state(bp, PCI_D3hot);
+
+	rtnl_unlock();
+}
+
 static const struct pci_error_handlers bnx2_err_handler = {
 	.error_detected	= bnx2_io_error_detected,
 	.slot_reset	= bnx2_io_slot_reset,
@@ -8765,6 +8767,7 @@ static struct pci_driver bnx2_pci_driver = {
 	.remove		= bnx2_remove_one,
 	.driver.pm	= BNX2_PM_OPS,
 	.err_handler	= &bnx2_err_handler,
+	.shutdown	= bnx2_shutdown,
 };
 
 module_pci_driver(bnx2_pci_driver);
-- 
1.7.1
