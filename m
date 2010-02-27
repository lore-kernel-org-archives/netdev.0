From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH] e1000e: export some settings using ethtool private flags
Date: Sat, 27 Feb 2010 03:23:05 -0500
Message-ID: <20100227082305.GA18194@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:41509 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967944Ab0B0IXI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Feb 2010 03:23:08 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The ethtool private flags interface exists to get/set driver-specific
settings at runtime, in a flexible manner.

Use this facility to export a couple e1000e features, that were
previously only set at module initialization time.

Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
---
 drivers/net/e1000e/ethtool.c |   27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index b33e3cb..4bda27f 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -112,6 +112,30 @@ static const char e1000_gstrings_test[][ETH_GSTRING_LEN] = {
 };
 #define E1000_TEST_LEN ARRAY_SIZE(e1000_gstrings_test)
 
+enum e1000_pflags {
+	E1000_PF_SMART_POWERDOWN	= (1 << 0),
+	E1000_PF_RO_NVM			= (1 << 1),
+};
+
+#define E1000_N_PFLAGS ARRAY_SIZE(e1000_gstrings_pflags)
+static const char e1000_gstrings_pflags[][ETH_GSTRING_LEN] = {
+	"smart_power_down",
+	"read_only_nvm",
+};
+
+u32 e1000_get_priv_flags(struct net_device *netdev)
+{
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	u32 ret = 0;
+
+	if (adapter->flags & FLAG_SMART_POWER_DOWN)
+		ret |= E1000_PF_SMART_POWERDOWN;
+	if (adapter->flags & FLAG_READ_ONLY_NVM)
+		ret |= E1000_PF_RO_NVM;
+
+	return ret;
+}
+
 static int e1000_get_settings(struct net_device *netdev,
 			      struct ethtool_cmd *ecmd)
 {
@@ -1666,6 +1690,8 @@ static int e1000e_get_sset_count(struct net_device *netdev, int sset)
 		return E1000_TEST_LEN;
 	case ETH_SS_STATS:
 		return E1000_STATS_LEN;
+	case ETH_SS_PRIV_FLAGS:
+		return E1000_N_PFLAGS;
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -2014,6 +2040,7 @@ static const struct ethtool_ops e1000_ethtool_ops = {
 	.set_coalesce		= e1000_set_coalesce,
 	.get_flags		= ethtool_op_get_flags,
 	.set_flags		= ethtool_op_set_flags,
+	.get_priv_flags		= e1000_get_priv_flags,
 };
 
 void e1000e_set_ethtool_ops(struct net_device *netdev)
