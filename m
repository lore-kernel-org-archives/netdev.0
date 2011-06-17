From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 0/4] Pull request for 'davem-next.r8169' branch
Date: Fri, 17 Jun 2011 21:28:26 +0200
Message-ID: <20110617192826.GA2277@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>,
	Ben Hutchings <ben@decadent.org.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:55787 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752339Ab1FQTlX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 15:41:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please pull from branch 'davem-next.r8169' in repository

git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git davem-next.r8169

to get the changes below.

Distance from 'davem-next' (c4dc4d108ace27cc0c594b67bd6bd945deaac8c2)
---------------------------------------------------------------------

1e79a76080ef7685d58fb977308b0854f2913818
40e4c935d4a74c03911654027a81f3a924022ccb
3883c49dadb94083d57436d0ed7348cbeaaa4bef
f5410a55194f7556bbc77f5e37009866c0c98673

Diffstat
--------

 drivers/net/r8169.c |  216 +++++++++++++++++++++++++++++++++++++++------------
 1 files changed, 166 insertions(+), 50 deletions(-)

Shortlog
--------

Francois Romieu (3):
      r8169: move the firmware down into the device private data.
      r8169: explicit firmware format check.
      r8169: check firmware content sooner.

Hayes Wang (1):
      r8169: support new firmware format.

Patch
-----

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 7310824..e16929d 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -667,7 +667,18 @@ struct rtl8169_private {
 	struct rtl8169_counters counters;
 	u32 saved_wolopts;
 
-	const struct firmware *fw;
+	struct rtl_fw {
+		const struct firmware *fw;
+
+#define RTL_VER_SIZE		32
+
+		char version[RTL_VER_SIZE];
+
+		struct rtl_fw_phy_action {
+			__le32 *code;
+			size_t size;
+		} phy_action;
+	} *rtl_fw;
 #define RTL_FIRMWARE_UNKNOWN	ERR_PTR(-EAGAIN);
 };
 
@@ -1222,12 +1233,13 @@ static void rtl8169_get_drvinfo(struct net_device *dev,
 				struct ethtool_drvinfo *info)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
+	struct rtl_fw *rtl_fw = tp->rtl_fw;
 
 	strcpy(info->driver, MODULENAME);
 	strcpy(info->version, RTL8169_VERSION);
 	strcpy(info->bus_info, pci_name(tp->pci_dev));
-	strncpy(info->fw_version, IS_ERR_OR_NULL(tp->fw) ? "N/A" :
-		rtl_lookup_firmware_name(tp), sizeof(info->fw_version) - 1);
+	strncpy(info->fw_version, IS_ERR_OR_NULL(rtl_fw) ? "N/A" :
+		rtl_fw->version, RTL_VER_SIZE);
 }
 
 static int rtl8169_get_regs_len(struct net_device *dev)
@@ -1741,21 +1753,75 @@ static void rtl_writephy_batch(struct rtl8169_private *tp,
 #define PHY_DELAY_MS		0xe0000000
 #define PHY_WRITE_ERI_WORD	0xf0000000
 
-static void
-rtl_phy_write_fw(struct rtl8169_private *tp, const struct firmware *fw)
+struct fw_info {
+	u32	magic;
+	char	version[RTL_VER_SIZE];
+	__le32	fw_start;
+	__le32	fw_len;
+	u8	chksum;
+} __packed;
+
+#define FW_OPCODE_SIZE	sizeof(typeof(*((struct rtl_fw_phy_action *)0)->code))
+
+static bool rtl_fw_format_ok(struct rtl8169_private *tp, struct rtl_fw *rtl_fw)
 {
-	__le32 *phytable = (__le32 *)fw->data;
-	struct net_device *dev = tp->dev;
-	size_t index, fw_size = fw->size / sizeof(*phytable);
-	u32 predata, count;
+	const struct firmware *fw = rtl_fw->fw;
+	struct fw_info *fw_info = (struct fw_info *)fw->data;
+	struct rtl_fw_phy_action *pa = &rtl_fw->phy_action;
+	bool rc = false;
 
-	if (fw->size % sizeof(*phytable)) {
-		netif_err(tp, probe, dev, "odd sized firmware %zd\n", fw->size);
-		return;
+	if (fw->size < FW_OPCODE_SIZE)
+		goto out;
+
+	if (!fw_info->magic) {
+		size_t i, size, start;
+		u8 checksum = 0;
+
+		if (fw->size < sizeof(*fw_info))
+			goto out;
+
+		for (i = 0; i < fw->size; i++)
+			checksum += fw->data[i];
+		if (checksum != 0)
+			goto out;
+
+		start = le32_to_cpu(fw_info->fw_start);
+		if (start > fw->size)
+			goto out;
+
+		size = le32_to_cpu(fw_info->fw_len);
+		if (size > (fw->size - start) / FW_OPCODE_SIZE)
+			goto out;
+
+		memcpy(rtl_fw->version, fw_info->version, RTL_VER_SIZE);
+
+		pa->code = (__le32 *)(fw->data + start);
+		pa->size = size;
+	} else {
+		if (fw->size % FW_OPCODE_SIZE)
+			goto out;
+
+		snprintf(rtl_fw->version, RTL_VER_SIZE, "%s",
+			 rtl_lookup_firmware_name(tp));
+
+		pa->code = (__le32 *)fw->data;
+		pa->size = fw->size / FW_OPCODE_SIZE;
 	}
+	rtl_fw->version[RTL_VER_SIZE - 1] = 0;
 
-	for (index = 0; index < fw_size; index++) {
-		u32 action = le32_to_cpu(phytable[index]);
+	rc = true;
+out:
+	return rc;
+}
+
+static bool rtl_fw_data_ok(struct rtl8169_private *tp, struct net_device *dev,
+			   struct rtl_fw_phy_action *pa)
+{
+	bool rc = false;
+	size_t index;
+
+	for (index = 0; index < pa->size; index++) {
+		u32 action = le32_to_cpu(pa->code[index]);
 		u32 regno = (action & 0x0fff0000) >> 16;
 
 		switch(action & 0xf0000000) {
@@ -1771,25 +1837,25 @@ rtl_phy_write_fw(struct rtl8169_private *tp, const struct firmware *fw)
 
 		case PHY_BJMPN:
 			if (regno > index) {
-				netif_err(tp, probe, tp->dev,
+				netif_err(tp, ifup, tp->dev,
 					  "Out of range of firmware\n");
-				return;
+				goto out;
 			}
 			break;
 		case PHY_READCOUNT_EQ_SKIP:
-			if (index + 2 >= fw_size) {
-				netif_err(tp, probe, tp->dev,
+			if (index + 2 >= pa->size) {
+				netif_err(tp, ifup, tp->dev,
 					  "Out of range of firmware\n");
-				return;
+				goto out;
 			}
 			break;
 		case PHY_COMP_EQ_SKIPN:
 		case PHY_COMP_NEQ_SKIPN:
 		case PHY_SKIPN:
-			if (index + 1 + regno >= fw_size) {
-				netif_err(tp, probe, tp->dev,
+			if (index + 1 + regno >= pa->size) {
+				netif_err(tp, ifup, tp->dev,
 					  "Out of range of firmware\n");
-				return;
+				goto out;
 			}
 			break;
 
@@ -1797,17 +1863,42 @@ rtl_phy_write_fw(struct rtl8169_private *tp, const struct firmware *fw)
 		case PHY_WRITE_MAC_BYTE:
 		case PHY_WRITE_ERI_WORD:
 		default:
-			netif_err(tp, probe, tp->dev,
+			netif_err(tp, ifup, tp->dev,
 				  "Invalid action 0x%08x\n", action);
-			return;
+			goto out;
 		}
 	}
+	rc = true;
+out:
+	return rc;
+}
+
+static int rtl_check_firmware(struct rtl8169_private *tp, struct rtl_fw *rtl_fw)
+{
+	struct net_device *dev = tp->dev;
+	int rc = -EINVAL;
+
+	if (!rtl_fw_format_ok(tp, rtl_fw)) {
+		netif_err(tp, ifup, dev, "invalid firwmare\n");
+		goto out;
+	}
+
+	if (rtl_fw_data_ok(tp, dev, &rtl_fw->phy_action))
+		rc = 0;
+out:
+	return rc;
+}
+
+static void rtl_phy_write_fw(struct rtl8169_private *tp, struct rtl_fw *rtl_fw)
+{
+	struct rtl_fw_phy_action *pa = &rtl_fw->phy_action;
+	u32 predata, count;
+	size_t index;
 
-	predata = 0;
-	count = 0;
+	predata = count = 0;
 
-	for (index = 0; index < fw_size; ) {
-		u32 action = le32_to_cpu(phytable[index]);
+	for (index = 0; index < pa->size; ) {
+		u32 action = le32_to_cpu(pa->code[index]);
 		u32 data = action & 0x0000ffff;
 		u32 regno = (action & 0x0fff0000) >> 16;
 
@@ -1879,18 +1970,20 @@ rtl_phy_write_fw(struct rtl8169_private *tp, const struct firmware *fw)
 
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
@@ -3443,7 +3536,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	tp->timer.data = (unsigned long) dev;
 	tp->timer.function = rtl8169_phy_timer;
 
-	tp->fw = RTL_FIRMWARE_UNKNOWN;
+	tp->rtl_fw = RTL_FIRMWARE_UNKNOWN;
 
 	rc = register_netdev(dev);
 	if (rc < 0)
@@ -3512,25 +3605,48 @@ static void __devexit rtl8169_remove_one(struct pci_dev *pdev)
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
+	rc = rtl_check_firmware(tp, rtl_fw);
+	if (rc < 0)
+		goto err_release_firmware;
+
+	tp->rtl_fw = rtl_fw;
+out:
+	return;
+
+err_release_firmware:
+	release_firmware(rtl_fw->fw);
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
Ueimor
