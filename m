From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 01/14] nfp: add support for .get_link_ksettings()
Date: Tue,  4 Apr 2017 16:12:22 -0700
Message-ID: <20170404231235.32027-2-jakub.kicinski@netronome.com>
References: <20170404231235.32027-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:32921 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753804AbdDDXMz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 19:12:55 -0400
Received: by mail-pf0-f179.google.com with SMTP id s16so25015640pfs.0
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 16:12:55 -0700 (PDT)
In-Reply-To: <20170404231235.32027-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Read link speed from the BAR.  This provides very basic information
and works for both PFs and VFs.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h  | 13 ++++++
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   | 49 ++++++++++++++++++++++
 2 files changed, 62 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h b/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
index 71d86171b4ee..d04ccc9f6116 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
@@ -177,6 +177,19 @@
 #define   NFP_NET_CFG_VERSION_MINOR(x)    (((x) & 0xff) <<  0)
 #define NFP_NET_CFG_STS                 0x0034
 #define   NFP_NET_CFG_STS_LINK            (0x1 << 0) /* Link up or down */
+/* Link rate */
+#define   NFP_NET_CFG_STS_LINK_RATE_SHIFT 1
+#define   NFP_NET_CFG_STS_LINK_RATE_MASK  0xF
+#define   NFP_NET_CFG_STS_LINK_RATE       \
+	(NFP_NET_CFG_STS_LINK_RATE_MASK << NFP_NET_CFG_STS_LINK_RATE_SHIFT)
+#define   NFP_NET_CFG_STS_LINK_RATE_UNSUPPORTED   0
+#define   NFP_NET_CFG_STS_LINK_RATE_UNKNOWN       1
+#define   NFP_NET_CFG_STS_LINK_RATE_1G            2
+#define   NFP_NET_CFG_STS_LINK_RATE_10G           3
+#define   NFP_NET_CFG_STS_LINK_RATE_25G           4
+#define   NFP_NET_CFG_STS_LINK_RATE_40G           5
+#define   NFP_NET_CFG_STS_LINK_RATE_50G           6
+#define   NFP_NET_CFG_STS_LINK_RATE_100G          7
 #define NFP_NET_CFG_CAP                 0x0038
 #define NFP_NET_CFG_MAX_TXRINGS         0x003c
 #define NFP_NET_CFG_MAX_RXRINGS         0x0040
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index ed22a813e579..d3cec0d4a978 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -173,6 +173,54 @@ static void nfp_net_get_drvinfo(struct net_device *netdev,
 	drvinfo->regdump_len = NFP_NET_CFG_BAR_SZ;
 }
 
+/**
+ * nfp_net_get_link_ksettings - Get Link Speed settings
+ * @netdev:	network interface device structure
+ * @cmd:	ethtool command
+ *
+ * Reports speed settings based on info in the BAR provided by the fw.
+ */
+static int
+nfp_net_get_link_ksettings(struct net_device *netdev,
+			   struct ethtool_link_ksettings *cmd)
+{
+	static const u32 ls_to_ethtool[] = {
+		[NFP_NET_CFG_STS_LINK_RATE_UNSUPPORTED]	= 0,
+		[NFP_NET_CFG_STS_LINK_RATE_UNKNOWN]	= SPEED_UNKNOWN,
+		[NFP_NET_CFG_STS_LINK_RATE_1G]		= SPEED_1000,
+		[NFP_NET_CFG_STS_LINK_RATE_10G]		= SPEED_10000,
+		[NFP_NET_CFG_STS_LINK_RATE_25G]		= SPEED_25000,
+		[NFP_NET_CFG_STS_LINK_RATE_40G]		= SPEED_40000,
+		[NFP_NET_CFG_STS_LINK_RATE_50G]		= SPEED_50000,
+		[NFP_NET_CFG_STS_LINK_RATE_100G]	= SPEED_100000,
+	};
+	struct nfp_net *nn = netdev_priv(netdev);
+	u32 sts, ls;
+
+	ethtool_link_ksettings_add_link_mode(cmd, supported, FIBRE);
+	cmd->base.port = PORT_OTHER;
+	cmd->base.speed = SPEED_UNKNOWN;
+	cmd->base.duplex = DUPLEX_UNKNOWN;
+
+	if (!netif_carrier_ok(netdev))
+		return 0;
+
+	sts = nn_readl(nn, NFP_NET_CFG_STS);
+
+	ls = FIELD_GET(NFP_NET_CFG_STS_LINK_RATE, sts);
+	if (ls == NFP_NET_CFG_STS_LINK_RATE_UNSUPPORTED)
+		return -EOPNOTSUPP;
+
+	if (ls == NFP_NET_CFG_STS_LINK_RATE_UNKNOWN ||
+	    ls >= ARRAY_SIZE(ls_to_ethtool))
+		return 0;
+
+	cmd->base.speed = ls_to_ethtool[sts];
+	cmd->base.duplex = DUPLEX_FULL;
+
+	return 0;
+}
+
 static void nfp_net_get_ringparam(struct net_device *netdev,
 				  struct ethtool_ringparam *ring)
 {
@@ -814,6 +862,7 @@ static const struct ethtool_ops nfp_net_ethtool_ops = {
 	.set_coalesce           = nfp_net_set_coalesce,
 	.get_channels		= nfp_net_get_channels,
 	.set_channels		= nfp_net_set_channels,
+	.get_link_ksettings	= nfp_net_get_link_ksettings,
 };
 
 void nfp_net_set_ethtool_ops(struct net_device *netdev)
-- 
2.11.0
