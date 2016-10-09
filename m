From: VENKAT PRASHANTH B U <venkat.prashanth2498@gmail.com>
Subject: [PATCH v2] Add support for ethtool operations to  RDC R6040.
Date: Sun,  9 Oct 2016 00:39:42 -0700
Message-ID: <1475998782-10593-1-git-send-email-venkat.prashanth2498@gmail.com>
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com,
        VENKAT PRASHANTH B U <venkat.prashanth2498@gmail.com>
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:33322 "EHLO
        mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751975AbcJIH63 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2016 03:58:29 -0400
Received: by mail-pa0-f65.google.com with SMTP id hh10so5074154pac.0
        for <netdev@vger.kernel.org>; Sun, 09 Oct 2016 00:58:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Venkat Prashanth B U <venkat.prashanth2498@gmail.com>

Changes since v1:
1. Made the commit message more clear
2. Add enumeration data type RTL_FLAG_MAX
3. Modified the locking interface used in r6040_get_regs()
   
4. Initialized mutex dynamically in a function r6040_get_regs()
   
5. Declared u32 msg_enable in struct r6040_private
---
 drivers/net/ethernet/rdc/r6040.c | 95 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 95 insertions(+)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index cb29ee2..167ff59 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -183,6 +183,10 @@ struct r6040_descriptor {
 	u32	rev2;			/* 1C-1F */
 } __aligned(32);
 
+enum rtl_flag {
+	RTL_FLAG_MAX
+};
+
 struct r6040_private {
 	spinlock_t lock;		/* driver lock */
 	struct pci_dev *pdev;
@@ -196,12 +200,18 @@ struct r6040_private {
 	dma_addr_t tx_ring_dma;
 	u16	tx_free_desc;
 	u16	mcr0;
+	u32 msg_enable;
 	struct net_device *dev;
 	struct mii_bus *mii_bus;
 	struct napi_struct napi;
 	void __iomem *base;
 	int old_link;
 	int old_duplex;
+	struct {
+		DECLARE_BITMAP(flags, RTL_FLAG_MAX);
+		struct mutex mutex;
+		struct work_struct work;
+	} wk;
 };
 
 static char version[] = DRV_NAME
@@ -955,12 +965,97 @@ static void netdev_get_drvinfo(struct net_device *dev,
 	strlcpy(info->bus_info, pci_name(rp->pdev), sizeof(info->bus_info));
 }
 
+static void r6040_lock_work(struct r6040_private *tp)
+{
+	mutex_lock(&tp->wk.mutex);
+}
+
+static void r6040_unlock_work(struct r6040_private *tp)
+{
+	mutex_unlock(&tp->wk.mutex);
+}
+
+static int r6040_get_regs_len (struct net_device *dev)
+{
+  return R6040_IO_SIZE;
+}
+
+static void r6040_get_regs (struct net_device *dev, struct ethtool_regs *regs, void *p)
+{
+  struct r6040_private *tp = netdev_priv (dev);
+  u32 __iomem *data = tp->base;
+  u32 *dw = p;
+  int i;
+
+  r6040_lock_work (tp);
+  for (i = 0; i < R6040_IO_SIZE; i += 4)
+    memcpy_fromio (dw++, data++, 4);
+  r6040_unlock_work (tp);
+}
+
+static u32 r6040_get_msglevel (struct net_device *dev)
+{
+  struct r6040_private *tp = netdev_priv (dev);
+
+  return tp->msg_enable;
+}
+
+static void r6040_set_msglevel (struct net_device *dev, u32 value)
+{
+  struct r6040_private *tp = netdev_priv (dev);
+
+  tp->msg_enable = value;
+}
+
+static const char r6040_gstrings[][ETH_GSTRING_LEN] = {
+  "tx_packets",
+  "rx_packets",
+  "tx_errors",
+  "rx_errors",
+  "rx_missed",
+  "align_errors",
+  "tx_single_collisions",
+  "tx_multi_collisions",
+  "unicast",
+  "broadcast",
+  "multicast",
+  "tx_aborted",
+  "tx_underrun",
+};
+
+static int r6040_get_sset_count (struct net_device *dev, int sset)
+{
+  switch (sset)
+    {
+    case ETH_SS_STATS:
+      return ARRAY_SIZE (r6040_gstrings);
+    default:
+      return -EOPNOTSUPP;
+    }
+}
+
+static void r6040_get_strings (struct net_device *dev, u32 stringset, u8 * data)
+{
+  switch (stringset)
+    {
+    case ETH_SS_STATS:
+      memcpy (data, *r6040_gstrings, sizeof (r6040_gstrings));
+      break;
+    }
+}
+
 static const struct ethtool_ops netdev_ethtool_ops = {
 	.get_drvinfo		= netdev_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
 	.get_ts_info		= ethtool_op_get_ts_info,
 	.get_link_ksettings     = phy_ethtool_get_link_ksettings,
 	.set_link_ksettings     = phy_ethtool_set_link_ksettings,
+	.get_regs_len = r6040_get_regs_len,
+	.get_msglevel = r6040_get_msglevel,
+	.set_msglevel = r6040_set_msglevel,
+	.get_regs = r6040_get_regs,
+	.get_strings = r6040_get_strings,
+	.get_sset_count = r6040_get_sset_count,
 };
 
 static const struct net_device_ops r6040_netdev_ops = {
-- 
1.9.2
