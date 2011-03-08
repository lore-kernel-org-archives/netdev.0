From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 02/14] igb: Add stats output for OS2BMC feature on i350 devices
Date: Mon,  7 Mar 2011 18:24:56 -0800
Message-ID: <1299551108-23663-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299551108-23663-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:37667 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755895Ab1CHC0F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 21:26:05 -0500
In-Reply-To: <1299551108-23663-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch adds statistics output for OS2BMC feature which is configured
by eeprom on capable devices.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/igb/e1000_defines.h |    1 +
 drivers/net/igb/e1000_hw.h      |    4 ++++
 drivers/net/igb/e1000_regs.h    |    7 +++++++
 drivers/net/igb/igb_ethtool.c   |    9 ++++++++-
 drivers/net/igb/igb_main.c      |    9 +++++++++
 5 files changed, 29 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igb/e1000_defines.h b/drivers/net/igb/e1000_defines.h
index ff46c91..92e11da 100644
--- a/drivers/net/igb/e1000_defines.h
+++ b/drivers/net/igb/e1000_defines.h
@@ -110,6 +110,7 @@
 /* Management Control */
 #define E1000_MANC_SMBUS_EN      0x00000001 /* SMBus Enabled - RO */
 #define E1000_MANC_ASF_EN        0x00000002 /* ASF Enabled - RO */
+#define E1000_MANC_EN_BMC2OS     0x10000000 /* OSBMC is Enabled or not */
 /* Enable Neighbor Discovery Filtering */
 #define E1000_MANC_RCV_TCO_EN    0x00020000 /* Receive TCO Packets Enabled */
 #define E1000_MANC_BLK_PHY_RST_ON_IDE   0x00040000 /* Block phy resets */
diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
index 281324e..eec9ed7 100644
--- a/drivers/net/igb/e1000_hw.h
+++ b/drivers/net/igb/e1000_hw.h
@@ -248,6 +248,10 @@ struct e1000_hw_stats {
 	u64 scvpc;
 	u64 hrmpc;
 	u64 doosync;
+	u64 o2bgptc;
+	u64 o2bspc;
+	u64 b2ospc;
+	u64 b2ogprc;
 };
 
 struct e1000_phy_stats {
diff --git a/drivers/net/igb/e1000_regs.h b/drivers/net/igb/e1000_regs.h
index 3a6f847..6171354 100644
--- a/drivers/net/igb/e1000_regs.h
+++ b/drivers/net/igb/e1000_regs.h
@@ -328,4 +328,11 @@
 
 /* DMA Coalescing registers */
 #define E1000_PCIEMISC          0x05BB8 /* PCIE misc config register */
+
+/* OS2BMC Registers */
+#define E1000_B2OSPC    0x08FE0 /* BMC2OS packets sent by BMC */
+#define E1000_B2OGPRC   0x04158 /* BMC2OS packets received by host */
+#define E1000_O2BGPTC   0x08FE4 /* OS2BMC packets received by BMC */
+#define E1000_O2BSPC    0x0415C /* OS2BMC packets transmitted by host */
+
 #endif
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index 61f7849..78d420b 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -86,6 +86,10 @@ static const struct igb_stats igb_gstrings_stats[] = {
 	IGB_STAT("tx_smbus", stats.mgptc),
 	IGB_STAT("rx_smbus", stats.mgprc),
 	IGB_STAT("dropped_smbus", stats.mgpdc),
+	IGB_STAT("os2bmc_rx_by_bmc", stats.o2bgptc),
+	IGB_STAT("os2bmc_tx_by_bmc", stats.b2ospc),
+	IGB_STAT("os2bmc_tx_by_host", stats.o2bspc),
+	IGB_STAT("os2bmc_rx_by_host", stats.b2ogprc),
 };
 
 #define IGB_NETDEV_STAT(_net_stat) { \
@@ -603,7 +607,10 @@ static void igb_get_regs(struct net_device *netdev,
 	regs_buff[548] = rd32(E1000_TDFT);
 	regs_buff[549] = rd32(E1000_TDFHS);
 	regs_buff[550] = rd32(E1000_TDFPC);
-
+	regs_buff[551] = adapter->stats.o2bgptc;
+	regs_buff[552] = adapter->stats.b2ospc;
+	regs_buff[553] = adapter->stats.o2bspc;
+	regs_buff[554] = adapter->stats.b2ogprc;
 }
 
 static int igb_get_eeprom_len(struct net_device *netdev)
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index eef380a..3666b96 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -4560,6 +4560,15 @@ void igb_update_stats(struct igb_adapter *adapter,
 	adapter->stats.mgptc += rd32(E1000_MGTPTC);
 	adapter->stats.mgprc += rd32(E1000_MGTPRC);
 	adapter->stats.mgpdc += rd32(E1000_MGTPDC);
+
+	/* OS2BMC Stats */
+	reg = rd32(E1000_MANC);
+	if (reg & E1000_MANC_EN_BMC2OS) {
+		adapter->stats.o2bgptc += rd32(E1000_O2BGPTC);
+		adapter->stats.o2bspc += rd32(E1000_O2BSPC);
+		adapter->stats.b2ospc += rd32(E1000_B2OSPC);
+		adapter->stats.b2ogprc += rd32(E1000_B2OGPRC);
+	}
 }
 
 static irqreturn_t igb_msix_other(int irq, void *data)
-- 
1.7.4

