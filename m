From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 06/13] netxen: advertise wake-on-lan support
Date: Mon, 12 Jan 2009 11:23:04 -0800
Message-ID: <1231788191-23794-7-git-send-email-dhananjay@netxen.com>
References: <1231788191-23794-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:56009 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753639AbZALTew (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jan 2009 14:34:52 -0500
In-Reply-To: <1231788191-23794-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Advertise support for wake up on magic packet. Add control to
enable/disable WoL for each port.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_ethtool.c |   49 +++++++++++++++++++++++++++++++
 drivers/net/netxen/netxen_nic_hdr.h     |    2 +
 2 files changed, 51 insertions(+), 0 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index 48b20f6..b403f82 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -807,6 +807,53 @@ static int netxen_nic_set_tso(struct net_device *dev, u32 data)
 	return 0;
 }
 
+static void
+netxen_nic_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	struct netxen_adapter *adapter = netdev_priv(dev);
+	u32 wol_cfg = 0;
+
+	wol->supported = 0;
+	wol->wolopts = 0;
+
+	if (NX_IS_REVISION_P2(adapter->ahw.revision_id))
+		return;
+
+	wol_cfg = netxen_nic_reg_read(adapter, NETXEN_WOL_CONFIG_NV);
+	if (wol_cfg & (1UL << adapter->portnum))
+		wol->supported |= WAKE_MAGIC;
+
+	wol_cfg = netxen_nic_reg_read(adapter, NETXEN_WOL_CONFIG);
+	if (wol_cfg & (1UL << adapter->portnum))
+		wol->wolopts |= WAKE_MAGIC;
+}
+
+static int
+netxen_nic_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	struct netxen_adapter *adapter = netdev_priv(dev);
+	u32 wol_cfg = 0;
+
+	if (NX_IS_REVISION_P2(adapter->ahw.revision_id))
+		return -EOPNOTSUPP;
+
+	if (wol->wolopts & ~WAKE_MAGIC)
+		return -EOPNOTSUPP;
+
+	wol_cfg = netxen_nic_reg_read(adapter, NETXEN_WOL_CONFIG_NV);
+	if (!(wol_cfg & (1 << adapter->portnum)))
+		return -EOPNOTSUPP;
+
+	wol_cfg = netxen_nic_reg_read(adapter, NETXEN_WOL_CONFIG);
+	if (wol->wolopts & WAKE_MAGIC)
+		wol_cfg |= 1UL << adapter->portnum;
+	else
+		wol_cfg &= ~(1UL << adapter->portnum);
+	netxen_nic_reg_write(adapter, NETXEN_WOL_CONFIG, wol_cfg);
+
+	return 0;
+}
+
 /*
  * Set the coalescing parameters. Currently only normal is supported.
  * If rx_coalesce_usecs == 0 or rx_max_coalesced_frames == 0 then set the
@@ -913,6 +960,8 @@ struct ethtool_ops netxen_nic_ethtool_ops = {
 	.set_sg = ethtool_op_set_sg,
 	.get_tso = netxen_nic_get_tso,
 	.set_tso = netxen_nic_set_tso,
+	.get_wol = netxen_nic_get_wol,
+	.set_wol = netxen_nic_set_wol,
 	.self_test = netxen_nic_diag_test,
 	.get_strings = netxen_nic_get_strings,
 	.get_ethtool_stats = netxen_nic_get_ethtool_stats,
diff --git a/drivers/net/netxen/netxen_nic_hdr.h b/drivers/net/netxen/netxen_nic_hdr.h
index 269a1f7..b9f6893 100644
--- a/drivers/net/netxen/netxen_nic_hdr.h
+++ b/drivers/net/netxen/netxen_nic_hdr.h
@@ -857,6 +857,8 @@ enum {
 #define NETXEN_PORT_MODE_AUTO_NEG_XG	6
 #define NETXEN_PORT_MODE_ADDR		(NETXEN_CAM_RAM(0x24))
 #define NETXEN_WOL_PORT_MODE		(NETXEN_CAM_RAM(0x198))
+#define NETXEN_WOL_CONFIG_NV		(NETXEN_CAM_RAM(0x184))
+#define NETXEN_WOL_CONFIG		(NETXEN_CAM_RAM(0x188))
 
 #define NX_PEG_TUNE_MN_PRESENT		0x1
 #define NX_PEG_TUNE_CAPABILITY		(NETXEN_CAM_RAM(0x02c))
-- 
1.6.0.2

