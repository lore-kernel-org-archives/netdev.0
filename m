From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next] nfp: add VLAN filtering support
Date: Wed, 14 Jun 2017 23:23:07 -0700
Message-ID: <20170615062307.10153-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: oss-drivers@netronome.com,
        =?UTF-8?q?Pablo=20Casc=C3=B3n?= <pablo.cascon@netronome.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:34733 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750936AbdFOGYY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 02:24:24 -0400
Received: by mail-pg0-f42.google.com with SMTP id v18so3077894pgb.1
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 23:24:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Cascón <pablo.cascon@netronome.com>

Add general use per-vNIC mailbox area and use it for VLAN filtering
support.  Initially proto is hardcoded to 802.1q.

Signed-off-by: Pablo Cascón <pablo.cascon@netronome.com>
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 74 +++++++++++++++++++++-
 drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h  | 27 ++++++++
 2 files changed, 100 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 97c4e53e1e7a..08446465c054 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -280,6 +280,30 @@ int nfp_net_reconfig(struct nfp_net *nn, u32 update)
 	return ret;
 }
 
+/**
+ * nfp_net_reconfig_mbox() - Reconfigure the firmware via the mailbox
+ * @nn:        NFP Net device to reconfigure
+ * @mbox_cmd:  The value for the mailbox command
+ *
+ * Helper function for mailbox updates
+ *
+ * Return: Negative errno on error, 0 on success
+ */
+static int nfp_net_reconfig_mbox(struct nfp_net *nn, u32 mbox_cmd)
+{
+	int ret;
+
+	nn_writeq(nn, NFP_NET_CFG_MBOX_CMD, mbox_cmd);
+
+	ret = nfp_net_reconfig(nn, NFP_NET_CFG_UPDATE_MBOX);
+	if (ret) {
+		nn_err(nn, "Mailbox update error\n");
+		return ret;
+	}
+
+	return -nn_readl(nn, NFP_NET_CFG_MBOX_RET);
+}
+
 /* Interrupt configuration and handling
  */
 
@@ -2960,6 +2984,40 @@ static int nfp_net_change_mtu(struct net_device *netdev, int new_mtu)
 	return nfp_net_ring_reconfig(nn, dp, NULL);
 }
 
+static int
+nfp_net_vlan_rx_add_vid(struct net_device *netdev, __be16 proto, u16 vid)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+
+	/* Priority tagged packets with vlan id 0 are processed by the
+	 * NFP as untagged packets
+	 */
+	if (!vid)
+		return 0;
+
+	nn_writew(nn, NFP_NET_CFG_VLAN_FILTER_VID, vid);
+	nn_writew(nn, NFP_NET_CFG_VLAN_FILTER_PROTO, ETH_P_8021Q);
+
+	return nfp_net_reconfig_mbox(nn, NFP_NET_CFG_MBOX_CMD_CTAG_FILTER_ADD);
+}
+
+static int
+nfp_net_vlan_rx_kill_vid(struct net_device *netdev, __be16 proto, u16 vid)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+
+	/* Priority tagged packets with vlan id 0 are processed by the
+	 * NFP as untagged packets
+	 */
+	if (!vid)
+		return 0;
+
+	nn_writew(nn, NFP_NET_CFG_VLAN_FILTER_VID, vid);
+	nn_writew(nn, NFP_NET_CFG_VLAN_FILTER_PROTO, ETH_P_8021Q);
+
+	return nfp_net_reconfig_mbox(nn, NFP_NET_CFG_MBOX_CMD_CTAG_FILTER_KILL);
+}
+
 static void nfp_net_stat64(struct net_device *netdev,
 			   struct rtnl_link_stats64 *stats)
 {
@@ -3053,6 +3111,13 @@ static int nfp_net_set_features(struct net_device *netdev,
 			new_ctrl &= ~NFP_NET_CFG_CTRL_TXVLAN;
 	}
 
+	if (changed & NETIF_F_HW_VLAN_CTAG_FILTER) {
+		if (features & NETIF_F_HW_VLAN_CTAG_FILTER)
+			new_ctrl |= NFP_NET_CFG_CTRL_CTAG_FILTER;
+		else
+			new_ctrl &= ~NFP_NET_CFG_CTRL_CTAG_FILTER;
+	}
+
 	if (changed & NETIF_F_SG) {
 		if (features & NETIF_F_SG)
 			new_ctrl |= NFP_NET_CFG_CTRL_GATHER;
@@ -3295,6 +3360,8 @@ const struct net_device_ops nfp_net_netdev_ops = {
 	.ndo_stop		= nfp_net_netdev_close,
 	.ndo_start_xmit		= nfp_net_tx,
 	.ndo_get_stats64	= nfp_net_stat64,
+	.ndo_vlan_rx_add_vid	= nfp_net_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid	= nfp_net_vlan_rx_kill_vid,
 	.ndo_setup_tc		= nfp_net_setup_tc,
 	.ndo_tx_timeout		= nfp_net_tx_timeout,
 	.ndo_set_rx_mode	= nfp_net_set_rx_mode,
@@ -3322,7 +3389,7 @@ void nfp_net_info(struct nfp_net *nn)
 		nn->fw_ver.resv, nn->fw_ver.class,
 		nn->fw_ver.major, nn->fw_ver.minor,
 		nn->max_mtu);
-	nn_info(nn, "CAP: %#x %s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s\n",
+	nn_info(nn, "CAP: %#x %s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s\n",
 		nn->cap,
 		nn->cap & NFP_NET_CFG_CTRL_PROMISC  ? "PROMISC "  : "",
 		nn->cap & NFP_NET_CFG_CTRL_L2BC     ? "L2BCFILT " : "",
@@ -3337,6 +3404,7 @@ void nfp_net_info(struct nfp_net *nn)
 		nn->cap & NFP_NET_CFG_CTRL_LSO2     ? "TSO2 "     : "",
 		nn->cap & NFP_NET_CFG_CTRL_RSS      ? "RSS1 "     : "",
 		nn->cap & NFP_NET_CFG_CTRL_RSS2     ? "RSS2 "     : "",
+		nn->cap & NFP_NET_CFG_CTRL_CTAG_FILTER ? "CTAG_FILTER " : "",
 		nn->cap & NFP_NET_CFG_CTRL_L2SWITCH ? "L2SWITCH " : "",
 		nn->cap & NFP_NET_CFG_CTRL_MSIXAUTO ? "AUTOMASK " : "",
 		nn->cap & NFP_NET_CFG_CTRL_IRQMOD   ? "IRQMOD "   : "",
@@ -3553,6 +3621,10 @@ static void nfp_net_netdev_init(struct nfp_net *nn)
 			nn->dp.ctrl |= NFP_NET_CFG_CTRL_TXVLAN;
 		}
 	}
+	if (nn->cap & NFP_NET_CFG_CTRL_CTAG_FILTER) {
+		netdev->hw_features |= NETIF_F_HW_VLAN_CTAG_FILTER;
+		nn->dp.ctrl |= NFP_NET_CFG_CTRL_CTAG_FILTER;
+	}
 
 	netdev->features = netdev->hw_features;
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h b/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
index 6a67ddd7cc8e..159d0298ff14 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
@@ -124,6 +124,7 @@
 #define   NFP_NET_CFG_CTRL_SCATTER        (0x1 <<  8) /* Scatter DMA */
 #define   NFP_NET_CFG_CTRL_GATHER         (0x1 <<  9) /* Gather DMA */
 #define   NFP_NET_CFG_CTRL_LSO            (0x1 << 10) /* LSO/TSO (version 1) */
+#define   NFP_NET_CFG_CTRL_CTAG_FILTER	  (0x1 << 11) /* VLAN CTAG filtering */
 #define   NFP_NET_CFG_CTRL_RINGCFG        (0x1 << 16) /* Ring runtime changes */
 #define   NFP_NET_CFG_CTRL_RSS		  (0x1 << 17) /* RSS (version 1) */
 #define   NFP_NET_CFG_CTRL_IRQMOD         (0x1 << 18) /* Interrupt moderation */
@@ -162,6 +163,7 @@
 #define   NFP_NET_CFG_UPDATE_VXLAN	  (0x1 <<  9) /* VXLAN port change */
 #define   NFP_NET_CFG_UPDATE_BPF	  (0x1 << 10) /* BPF program load */
 #define   NFP_NET_CFG_UPDATE_MACADDR	  (0x1 << 11) /* MAC address change */
+#define   NFP_NET_CFG_UPDATE_MBOX	  (0x1 << 12) /* Mailbox update */
 #define   NFP_NET_CFG_UPDATE_ERR          (0x1 << 31) /* A error occurred */
 #define NFP_NET_CFG_TXRS_ENABLE         0x0008
 #define NFP_NET_CFG_RXRS_ENABLE         0x0010
@@ -400,4 +402,29 @@
 #define NFP_NET_CFG_RXR_STATS(_x)       (NFP_NET_CFG_RXR_STATS_BASE + \
 					 ((_x) * 0x10))
 
+/**
+ * General use mailbox area (0x1800 - 0x19ff)
+ * 4B used for update command and 4B return code
+ * followed by a max of 504B of variable length value
+ */
+#define NFP_NET_CFG_MBOX_CMD		0x1800
+#define NFP_NET_CFG_MBOX_RET		0x1804
+#define NFP_NET_CFG_MBOX_VAL		0x1808
+#define NFP_NET_CFG_MBOX_VAL_MAX_SZ	0x1F8
+
+#define NFP_NET_CFG_MBOX_CMD_CTAG_FILTER_ADD 1
+#define NFP_NET_CFG_MBOX_CMD_CTAG_FILTER_KILL 2
+
+/**
+ * VLAN filtering using general use mailbox
+ * @NFP_NET_CFG_VLAN_FILTER:		Base address of VLAN filter mailbox
+ * @NFP_NET_CFG_VLAN_FILTER_VID:	VLAN ID to filter
+ * @NFP_NET_CFG_VLAN_FILTER_PROTO:	VLAN proto to filter
+ * @NFP_NET_CFG_VXLAN_SZ:		Size of the VLAN filter mailbox in bytes
+ */
+#define NFP_NET_CFG_VLAN_FILTER		NFP_NET_CFG_MBOX_VAL
+#define  NFP_NET_CFG_VLAN_FILTER_VID	NFP_NET_CFG_VLAN_FILTER
+#define  NFP_NET_CFG_VLAN_FILTER_PROTO	 (NFP_NET_CFG_VLAN_FILTER + 2)
+#define NFP_NET_CFG_VLAN_FILTER_SZ	 0x0004
+
 #endif /* _NFP_NET_CTRL_H_ */
-- 
2.11.0
