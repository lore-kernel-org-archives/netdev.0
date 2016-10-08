From: VENKAT PRASHANTH B U <venkat.prashanth2498@gmail.com>
Subject: [PATCH] Add support for ethtool operations such as get_regs_len(),
Date: Sat,  8 Oct 2016 06:48:54 -0700
Message-ID: <1475934534-26984-1-git-send-email-venkat.prashanth2498@gmail.com>
Cc: Venkat Prashanth B U <venkat.prashanth2498@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36098 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753222AbcJHNty (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Oct 2016 09:49:54 -0400
Received: by mail-pf0-f196.google.com with SMTP id 128so2880265pfz.3
        for <netdev@vger.kernel.org>; Sat, 08 Oct 2016 06:49:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Venkat Prashanth B U <venkat.prashanth2498@gmail.com>

Signed-off-by: Venkat Prashanth B U <venkat.prashanth2498@gmail.com>
---
 drivers/net/ethernet/rdc/r6040.c | 75 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 75 insertions(+)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index cb29ee2..eb7667a 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -954,6 +954,74 @@ static void netdev_get_drvinfo(struct net_device *dev,
 	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
 	strlcpy(info->bus_info, pci_name(rp->pdev), sizeof(info->bus_info));
 }
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
+  spin_lock (tp);
+  for (i = 0; i < R6040_IO_SIZE; i += 4)
+    memcpy_fromio (dw++, data++, 4);
+  spin_unlock (tp);
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
 
 static const struct ethtool_ops netdev_ethtool_ops = {
 	.get_drvinfo		= netdev_get_drvinfo,
@@ -961,6 +1029,13 @@ static const struct ethtool_ops netdev_ethtool_ops = {
 	.get_ts_info		= ethtool_op_get_ts_info,
 	.get_link_ksettings     = phy_ethtool_get_link_ksettings,
 	.set_link_ksettings     = phy_ethtool_set_link_ksettings,
+	.get_regs_len = r6040_get_regs_len,
+	.get_msglevel = r6040_get_msglevel,
+	.set_msglevel = r6040_set_msglevel,
+	.get_regs = r6040_get_regs,
+	.get_strings = r6040_get_strings,
+	.get_sset_count = r6040_get_sset_count,
+	.get_regs_len = r6040_get_regs_len,
 };
 
 static const struct net_device_ops r6040_netdev_ops = {
-- 
1.9.2
