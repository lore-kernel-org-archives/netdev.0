From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/2] net: phy: broadcom: Add support code for reading PHY counters
Date: Mon, 28 Nov 2016 13:06:13 -0800
Message-ID: <20161128210614.12621-2-f.fainelli@gmail.com>
References: <20161128210614.12621-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        bcm-kernel-feedback-list@broadcom.com, allan.nielsen@microsemi.com,
        raju.lakkaraju@microsemi.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34869 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754243AbcK1VGS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 16:06:18 -0500
Received: by mail-pf0-f195.google.com with SMTP id i88so6959836pfk.2
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 13:06:18 -0800 (PST)
In-Reply-To: <20161128210614.12621-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Broadcom PHYs expose a number of PHY error counters: receive errors,
false carrier sense, SerDes BER count, local and remote receive errors.
Add support code to allow retrieving these error counters. Since the
Broadcom PHY library code is used by several drivers, make it possible
for them to specify the storage for the software copy of the statistics.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm-phy-lib.c | 67 +++++++++++++++++++++++++++++++++++++++++++
 drivers/net/phy/bcm-phy-lib.h |  5 ++++
 include/linux/brcmphy.h       |  3 ++
 3 files changed, 75 insertions(+)

diff --git a/drivers/net/phy/bcm-phy-lib.c b/drivers/net/phy/bcm-phy-lib.c
index 3156ce6d5861..afaa747979f2 100644
--- a/drivers/net/phy/bcm-phy-lib.c
+++ b/drivers/net/phy/bcm-phy-lib.c
@@ -17,6 +17,7 @@
 #include <linux/mdio.h>
 #include <linux/module.h>
 #include <linux/phy.h>
+#include <linux/ethtool.h>
 
 #define MII_BCM_CHANNEL_WIDTH     0x2000
 #define BCM_CL45VEN_EEE_ADV       0x3c
@@ -317,6 +318,72 @@ int bcm_phy_downshift_set(struct phy_device *phydev, u8 count)
 }
 EXPORT_SYMBOL_GPL(bcm_phy_downshift_set);
 
+struct bcm_phy_hw_stat {
+	const char *string;
+	u8 reg;
+	u8 shift;
+	u8 bits;
+};
+
+/* Counters freeze at either 0xffff or 0xff, better than nothing */
+static struct bcm_phy_hw_stat bcm_phy_hw_stats[] = {
+	{ "phy_receive_errors", MII_BRCM_CORE_BASE12, 0, 16 },
+	{ "phy_serdes_ber_errors", MII_BRCM_CORE_BASE13, 8, 8 },
+	{ "phy_false_carrier_sense_errors", MII_BRCM_CORE_BASE13, 0, 8 },
+	{ "phy_local_rcvr_nok", MII_BRCM_CORE_BASE14, 8, 8 },
+	{ "phy_remote_rcv_nok", MII_BRCM_CORE_BASE14, 0, 8 },
+};
+
+int bcm_phy_get_sset_count(struct phy_device *phydev)
+{
+	return ARRAY_SIZE(bcm_phy_hw_stats);
+}
+
+void bcm_phy_get_strings(struct phy_device *phydev, u8 *data)
+{
+	unsigned int i;
+
+	for (i = 0; i < ARRAY_SIZE(bcm_phy_hw_stats); i++)
+		memcpy(data + i * ETH_GSTRING_LEN,
+		       bcm_phy_hw_stats[i].string, ETH_GSTRING_LEN);
+}
+
+#ifndef UINT64_MAX
+#define UINT64_MAX              (u64)(~((u64)0))
+#endif
+
+/* Caller is supposed to provide appropriate storage for the library code to
+ * access the shadow copy
+ */
+static u64 bcm_phy_get_stat(struct phy_device *phydev, u64 *shadow,
+			    unsigned int i)
+{
+	struct bcm_phy_hw_stat stat = bcm_phy_hw_stats[i];
+	int val;
+	u64 ret;
+
+	val = phy_read(phydev, stat.reg);
+	if (val < 0) {
+		ret = UINT64_MAX;
+	} else {
+		val >>= stat.shift;
+		val = val & ((1 << stat.bits) - 1);
+		shadow[i] += val;
+		ret = shadow[i];
+	}
+
+	return ret;
+}
+
+void bcm_phy_get_stats(struct phy_device *phydev, u64 *shadow,
+		       struct ethtool_stats *stats, u64 *data)
+{
+	unsigned int i;
+
+	for (i = 0; i < ARRAY_SIZE(bcm_phy_hw_stats); i++)
+		data[i] = bcm_phy_get_stat(phydev, shadow, i);
+}
+
 MODULE_DESCRIPTION("Broadcom PHY Library");
 MODULE_LICENSE("GPL v2");
 MODULE_AUTHOR("Broadcom Corporation");
diff --git a/drivers/net/phy/bcm-phy-lib.h b/drivers/net/phy/bcm-phy-lib.h
index a117f657c6d7..7c73808cbbde 100644
--- a/drivers/net/phy/bcm-phy-lib.h
+++ b/drivers/net/phy/bcm-phy-lib.h
@@ -42,4 +42,9 @@ int bcm_phy_downshift_get(struct phy_device *phydev, u8 *count);
 
 int bcm_phy_downshift_set(struct phy_device *phydev, u8 count);
 
+int bcm_phy_get_sset_count(struct phy_device *phydev);
+void bcm_phy_get_strings(struct phy_device *phydev, u8 *data);
+void bcm_phy_get_stats(struct phy_device *phydev, u64 *shadow,
+		       struct ethtool_stats *stats, u64 *data);
+
 #endif /* _LINUX_BCM_PHY_LIB_H */
diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index f9f8aaf9c943..4f7d8be9ddbf 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -244,6 +244,9 @@
 #define LPI_FEATURE_EN_DIG1000X		0x4000
 
 /* Core register definitions*/
+#define MII_BRCM_CORE_BASE12	0x12
+#define MII_BRCM_CORE_BASE13	0x13
+#define MII_BRCM_CORE_BASE14	0x14
 #define MII_BRCM_CORE_BASE1E	0x1E
 #define MII_BRCM_CORE_EXPB0	0xB0
 #define MII_BRCM_CORE_EXPB1	0xB1
-- 
2.9.3
