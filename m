From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH #2 1/4] r8169: move the firmware down into the device private data.
Date: Sat, 18 Jun 2011 00:41:15 +0200
Message-ID: <20110617224115.GB2483@electric-eye.fr.zoreil.com>
References: <20110617224001.GA2483@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>,
	Ben Hutchings <ben@decadent.org.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:55759 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756976Ab1FQWx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 18:53:59 -0400
Content-Disposition: inline
In-Reply-To: <20110617224001.GA2483@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No functional difference.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |   74 +++++++++++++++++++++++++++++++++------------------
 1 files changed, 48 insertions(+), 26 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 7310824..3eeefe4 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -667,7 +667,9 @@ struct rtl8169_private {
 	struct rtl8169_counters counters;
 	u32 saved_wolopts;
 
-	const struct firmware *fw;
+	struct rtl_fw {
+		const struct firmware *fw;
+	} *rtl_fw;
 #define RTL_FIRMWARE_UNKNOWN	ERR_PTR(-EAGAIN);
 };
 
@@ -1222,11 +1224,12 @@ static void rtl8169_get_drvinfo(struct net_device *dev,
 				struct ethtool_drvinfo *info)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
+	struct rtl_fw *rtl_fw = tp->rtl_fw;
 
 	strcpy(info->driver, MODULENAME);
 	strcpy(info->version, RTL8169_VERSION);
 	strcpy(info->bus_info, pci_name(tp->pci_dev));
-	strncpy(info->fw_version, IS_ERR_OR_NULL(tp->fw) ? "N/A" :
+	strncpy(info->fw_version, IS_ERR_OR_NULL(rtl_fw) ? "N/A" :
 		rtl_lookup_firmware_name(tp), sizeof(info->fw_version) - 1);
 }
 
@@ -1741,9 +1744,9 @@ static void rtl_writephy_batch(struct rtl8169_private *tp,
 #define PHY_DELAY_MS		0xe0000000
 #define PHY_WRITE_ERI_WORD	0xf0000000
 
-static void
-rtl_phy_write_fw(struct rtl8169_private *tp, const struct firmware *fw)
+static void rtl_phy_write_fw(struct rtl8169_private *tp, struct rtl_fw *rtl_fw)
 {
+	const struct firmware *fw = rtl_fw->fw;
 	__le32 *phytable = (__le32 *)fw->data;
 	struct net_device *dev = tp->dev;
 	size_t index, fw_size = fw->size / sizeof(*phytable);
@@ -1879,18 +1882,20 @@ rtl_phy_write_fw(struct rtl8169_private *tp, const struct firmware *fw)
 
 static void rtl_release_firmware(struct rtl8169_private *tp)
 {
-	if (!IS_ERR_OR_NULL(tp->fw))
-		release_firmware(tp->fw);
-	tp->fw = RTL_FIRMWARE_UNKNOWN;
+	if (!IS_ERR_OR_NULL(tp->rtl_fw)) {
+		release_firmware(tp->rtl_fw->fw);
+		kfree(tp->rtl_fw);
+	}
+	tp->rtl_fw = RTL_FIRMWARE_UNKNOWN;
 }
 
 static void rtl_apply_firmware(struct rtl8169_private *tp)
 {
-	const struct firmware *fw = tp->fw;
+	struct rtl_fw *rtl_fw = tp->rtl_fw;
 
 	/* TODO: release firmware once rtl_phy_write_fw signals failures. */
-	if (!IS_ERR_OR_NULL(fw))
-		rtl_phy_write_fw(tp, fw);
+	if (!IS_ERR_OR_NULL(rtl_fw))
+		rtl_phy_write_fw(tp, rtl_fw);
 }
 
 static void rtl_apply_firmware_cond(struct rtl8169_private *tp, u8 reg, u16 val)
@@ -3443,7 +3448,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	tp->timer.data = (unsigned long) dev;
 	tp->timer.function = rtl8169_phy_timer;
 
-	tp->fw = RTL_FIRMWARE_UNKNOWN;
+	tp->rtl_fw = RTL_FIRMWARE_UNKNOWN;
 
 	rc = register_netdev(dev);
 	if (rc < 0)
@@ -3512,25 +3517,42 @@ static void __devexit rtl8169_remove_one(struct pci_dev *pdev)
 	pci_set_drvdata(pdev, NULL);
 }
 
-static void rtl_request_firmware(struct rtl8169_private *tp)
+static void rtl_request_uncached_firmware(struct rtl8169_private *tp)
 {
-	/* Return early if the firmware is already loaded / cached. */
-	if (IS_ERR(tp->fw)) {
-		const char *name;
+	struct rtl_fw *rtl_fw;
+	const char *name;
+	int rc = -ENOMEM;
 
-		name = rtl_lookup_firmware_name(tp);
-		if (name) {
-			int rc;
+	name = rtl_lookup_firmware_name(tp);
+	if (!name)
+		goto out_no_firmware;
 
-			rc = request_firmware(&tp->fw, name, &tp->pci_dev->dev);
-			if (rc >= 0)
-				return;
+	rtl_fw = kzalloc(sizeof(*rtl_fw), GFP_KERNEL);
+	if (!rtl_fw)
+		goto err_warn;
 
-			netif_warn(tp, ifup, tp->dev, "unable to load "
-				"firmware patch %s (%d)\n", name, rc);
-		}
-		tp->fw = NULL;
-	}
+	rc = request_firmware(&rtl_fw->fw, name, &tp->pci_dev->dev);
+	if (rc < 0)
+		goto err_free;
+
+	tp->rtl_fw = rtl_fw;
+out:
+	return;
+
+err_free:
+	kfree(rtl_fw);
+err_warn:
+	netif_warn(tp, ifup, tp->dev, "unable to load firmware patch %s (%d)\n",
+		   name, rc);
+out_no_firmware:
+	tp->rtl_fw = NULL;
+	goto out;
+}
+
+static void rtl_request_firmware(struct rtl8169_private *tp)
+{
+	if (IS_ERR(tp->rtl_fw))
+		rtl_request_uncached_firmware(tp);
 }
 
 static int rtl8169_open(struct net_device *dev)
-- 
1.7.4.4

