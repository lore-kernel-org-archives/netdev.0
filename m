From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [net-2.6] tg3: Fix firmware loading
Date: Mon, 19 Jan 2009 05:17:32 -0800
Message-ID: <1232397814.31530@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4379 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752249AbZASUnr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jan 2009 15:43:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch modifies how the tg3 driver handles device firmware.

The patch starts by consolidating David Woodhouse's earlier patch under
the same name.  Specifically, the patch moves the request_firmware call
into a separate tg3_request_firmware() function and calls that function
from tg3_open() rather than tg3_init_one().

The patch then goes on to limit the number of devices that will make
request_firmware calls.  The original firmware patch unnecessarily
requested TSO firmware for devices that did not need it.  This patch
reduces the set of devices making TSO firmware patches to approximately
the following device set : 5703, 5704, and 5705.

Finally, the patch reduces the effects of a request_firmware() failure.
For those devices that are requesting TSO firmware, the driver will turn
off the TSO capability.  If TSO firmware becomes available at a later
time, the device can be closed and then opened again to reacquire the
TSO capability.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   81 ++++++++++++++++++++++++++++++++--------------------
 drivers/net/tg3.h |    1 +
 2 files changed, 51 insertions(+), 31 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 5e2dbae..8b3f846 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -7535,11 +7535,58 @@ static int tg3_test_msi(struct tg3 *tp)
 	return err;
 }
 
+static int tg3_request_firmware(struct tg3 *tp)
+{
+	const __be32 *fw_data;
+
+	if (request_firmware(&tp->fw, tp->fw_needed, &tp->pdev->dev)) {
+		printk(KERN_ERR "%s: Failed to load firmware \"%s\"\n",
+		       tp->dev->name, tp->fw_needed);
+		return -ENOENT;
+	}
+
+	fw_data = (void *)tp->fw->data;
+
+	/* Firmware blob starts with version numbers, followed by
+	 * start address and _full_ length including BSS sections
+	 * (which must be longer than the actual data, of course
+	 */
+
+	tp->fw_len = be32_to_cpu(fw_data[2]);	/* includes bss */
+	if (tp->fw_len < (tp->fw->size - 12)) {
+		printk(KERN_ERR "%s: bogus length %d in \"%s\"\n",
+		       tp->dev->name, tp->fw_len, tp->fw_needed);
+		release_firmware(tp->fw);
+		tp->fw = NULL;
+		return -EINVAL;
+	}
+
+	/* We no longer need firmware; we have it. */
+	tp->fw_needed = NULL;
+	return 0;
+}
+
 static int tg3_open(struct net_device *dev)
 {
 	struct tg3 *tp = netdev_priv(dev);
 	int err;
 
+	if (tp->fw_needed) {
+		err = tg3_request_firmware(tp);
+		if (tp->pci_chip_rev_id == CHIPREV_ID_5701_A0) {
+			if (err)
+				return err;
+		} else if (err) {
+			printk(KERN_WARNING "%s: TSO capability disabled.\n",
+			       tp->dev->name);
+			tp->tg3_flags2 &= ~TG3_FLG2_TSO_CAPABLE;
+		} else if (!(tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE)) {
+			printk(KERN_NOTICE "%s: TSO capability restored.\n",
+			       tp->dev->name);
+			tp->tg3_flags2 |= TG3_FLG2_TSO_CAPABLE;
+		}
+	}
+
 	netif_carrier_off(tp->dev);
 
 	err = tg3_set_power_state(tp, PCI_D0);
@@ -12934,7 +12981,6 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	struct net_device *dev;
 	struct tg3 *tp;
 	int err, pm_cap;
-	const char *fw_name = NULL;
 	char str[40];
 	u64 dma_mask, persist_dma_mask;
 
@@ -13091,7 +13137,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	tg3_init_bufmgr_config(tp);
 
 	if (tp->pci_chip_rev_id == CHIPREV_ID_5701_A0)
-		fw_name = FIRMWARE_TG3;
+		tp->fw_needed = FIRMWARE_TG3;
 
 	if (tp->tg3_flags2 & TG3_FLG2_HW_TSO) {
 		tp->tg3_flags2 |= TG3_FLG2_TSO_CAPABLE;
@@ -13104,37 +13150,10 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		tp->tg3_flags2 &= ~TG3_FLG2_TSO_CAPABLE;
 	} else {
 		tp->tg3_flags2 |= TG3_FLG2_TSO_CAPABLE | TG3_FLG2_TSO_BUG;
-	}
-	if (tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE) {
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705)
-			fw_name = FIRMWARE_TG3TSO5;
+			tp->fw_needed = FIRMWARE_TG3TSO5;
 		else
-			fw_name = FIRMWARE_TG3TSO;
-	}
-
-	if (fw_name) {
-		const __be32 *fw_data;
-
-		err = request_firmware(&tp->fw, fw_name, &tp->pdev->dev);
-		if (err) {
-			printk(KERN_ERR "tg3: Failed to load firmware \"%s\"\n",
-			       fw_name);
-			goto err_out_iounmap;
-		}
-
-		fw_data = (void *)tp->fw->data;
-
-		/* Firmware blob starts with version numbers, followed by
-		   start address and _full_ length including BSS sections
-		   (which must be longer than the actual data, of course */
-
-		tp->fw_len = be32_to_cpu(fw_data[2]);	/* includes bss */
-		if (tp->fw_len < (tp->fw->size - 12)) {
-			printk(KERN_ERR "tg3: bogus length %d in \"%s\"\n",
-			       tp->fw_len, fw_name);
-			err = -EINVAL;
-			goto err_out_fw;
-		}
+			tp->fw_needed = FIRMWARE_TG3TSO;
 	}
 
 	/* TSO is on by default on chips that support hardware TSO.
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index ae5da60..508def3 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2764,6 +2764,7 @@ struct tg3 {
 	struct ethtool_coalesce		coal;
 
 	/* firmware info */
+	const char			*fw_needed;
 	const struct firmware		*fw;
 	u32				fw_len; /* includes BSS */
 };
-- 
1.5.6.4


