From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next-2.6 PATCH 07/10] [RFC] ixgbe: add basic support for
	settting and getting nfc controls
Date: Fri, 25 Feb 2011 15:33:15 -0800
Message-ID: <20110225233315.7920.99717.stgit@gitlad.jf.intel.com>
References: <20110225232357.7920.58559.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:40299 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933047Ab1BYXdi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Feb 2011 18:33:38 -0500
In-Reply-To: <20110225232357.7920.58559.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change adds basic suppport for the obtaining of RSS ring counts and
setting of RSS hash options.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 drivers/net/ixgbe/ixgbe_ethtool.c |   60 +++++++++++++++++++++++++++++++++++++
 1 files changed, 60 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 1b40c02..6c17e45 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -2299,6 +2299,65 @@ static int ixgbe_set_flags(struct net_device *netdev, u32 data)
 	return 0;
 }
 
+static int ixgbe_get_rss_hash_opts(struct ixgbe_adapter *adapter,
+				   struct ethtool_rxnfc *cmd)
+{
+	cmd->data = 0;
+
+	/* if RSS is disabled then report no hashing */
+	if (!(adapter->flags & IXGBE_FLAG_RSS_ENABLED))
+		return 0;
+
+	/* Report default options for RSS on ixgbe */
+	switch (cmd->flow_type) {
+	case TCP_V4_FLOW:
+		cmd->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+	case UDP_V4_FLOW:
+	case SCTP_V4_FLOW:
+	case AH_ESP_V4_FLOW:
+	case AH_V4_FLOW:
+	case ESP_V4_FLOW:
+	case IPV4_FLOW:
+		cmd->data |= RXH_IP_SRC | RXH_IP_DST;
+		break;
+	case TCP_V6_FLOW:
+		cmd->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+	case UDP_V6_FLOW:
+	case SCTP_V6_FLOW:
+	case AH_ESP_V6_FLOW:
+	case AH_V6_FLOW:
+	case ESP_V6_FLOW:
+	case IPV6_FLOW:
+		cmd->data |= RXH_IP_SRC | RXH_IP_DST;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int ixgbe_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd,
+			   void *rule_locs)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	int ret = -EOPNOTSUPP;
+
+	switch (cmd->cmd) {
+	case ETHTOOL_GRXFH:
+		ret = ixgbe_get_rss_hash_opts(adapter, cmd);
+		break;
+	case ETHTOOL_GRXRINGS:
+		cmd->data = adapter->num_rx_queues;
+		ret = 0;
+		break;
+	default:
+		break;
+	}
+
+	return ret;
+}
+
 static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.get_settings           = ixgbe_get_settings,
 	.set_settings           = ixgbe_set_settings,
@@ -2334,6 +2393,7 @@ static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.set_coalesce           = ixgbe_set_coalesce,
 	.get_flags              = ethtool_op_get_flags,
 	.set_flags              = ixgbe_set_flags,
+	.get_rxnfc		= ixgbe_get_rxnfc,
 };
 
 void ixgbe_set_ethtool_ops(struct net_device *netdev)

