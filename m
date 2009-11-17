From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/2] ixgbe: Display currently attached PHY
	through ethtool get_drvinfo
Date: Tue, 17 Nov 2009 08:14:01 -0800
Message-ID: <20091117161400.11341.14502.stgit@localhost.localdomain>
References: <20091117161309.11341.9165.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.emeryville.ca.mail.comcast.net ([76.96.30.80]:56224 "EHLO
	QMTA08.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752345AbZKQQPN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 11:15:13 -0500
In-Reply-To: <20091117161309.11341.9165.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

This patch uses the new ethtool interface to display what PHY
is currently connected to a NIC.  The results can be viewed in
ethtool -i ethX output.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_ethtool.c |   61 +++++++++++++++++++++++++++++++++++++
 1 files changed, 61 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 9d2cc83..0012c65 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -782,6 +782,67 @@ static void ixgbe_get_drvinfo(struct net_device *netdev,
 	drvinfo->n_stats = IXGBE_STATS_LEN;
 	drvinfo->testinfo_len = IXGBE_TEST_LEN;
 	drvinfo->regdump_len = ixgbe_get_regs_len(netdev);
+
+	/* Get PHY type */
+
+	/*
+	 * If the adapter is not up, we should re-identify the PHY type.
+	 * It might be stale otherwise.
+	 */
+	if (test_bit(__IXGBE_DOWN, &adapter->state)) {
+		/* clear the PHY type to ensure we do a full scan */
+		adapter->hw.phy.type = ixgbe_phy_unknown;
+		adapter->hw.phy.ops.identify(&adapter->hw);
+	}
+
+	switch (adapter->hw.phy.type) {
+	case ixgbe_phy_tn:
+	case ixgbe_phy_cu_unknown:
+		/* Copper 10G-BASET */
+		drvinfo->phy_type = ETH_PHY_BASE_T;
+		break;
+	case ixgbe_phy_qt:
+		drvinfo->phy_type = ETH_PHY_XFP_FIBER;
+		break;
+	case ixgbe_phy_nl:
+	case ixgbe_phy_tw_tyco:
+	case ixgbe_phy_tw_unknown:
+	case ixgbe_phy_sfp_ftl:
+	case ixgbe_phy_sfp_avago:
+	case ixgbe_phy_sfp_intel:
+	case ixgbe_phy_sfp_unknown:
+	case ixgbe_phy_unknown:
+		switch (adapter->hw.phy.sfp_type) {
+		/* SFP+ devices, further checking needed */
+		case ixgbe_sfp_type_da_cu:
+		case ixgbe_sfp_type_da_cu_core0:
+		case ixgbe_sfp_type_da_cu_core1:
+			drvinfo->phy_type = ETH_PHY_DA_TWINAX;
+			break;
+		case ixgbe_sfp_type_sr:
+		case ixgbe_sfp_type_lr:
+		case ixgbe_sfp_type_srlr_core0:
+		case ixgbe_sfp_type_srlr_core1:
+			drvinfo->phy_type = ETH_PHY_SFP_FIBER;
+			break;
+		case ixgbe_sfp_type_not_present:
+			drvinfo->phy_type = ETH_PHY_NOT_PRESENT;
+			break;
+		case ixgbe_sfp_type_unknown:
+		default:
+			ETH_PHY_UNSPECIFIED;
+			break;
+		}
+		break;
+	case ixgbe_phy_xaui:
+		drvinfo->phy_type = ETH_PHY_NOT_PRESENT;
+		break;
+	case ixgbe_phy_generic:
+	case ixgbe_phy_sfp_unsupported:
+	default:
+		drvinfo->phy_type = ETH_PHY_UNSPECIFIED;
+		break;
+	}
 }
 
 static void ixgbe_get_ringparam(struct net_device *netdev,

