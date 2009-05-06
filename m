From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/3] igbvf: cleanup flags and allow for rx
	checksum to be disabled
Date: Wed, 06 May 2009 13:25:01 -0700
Message-ID: <20090506202450.17149.18959.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:53527
	"EHLO QMTA07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754637AbZEFUZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 16:25:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch cleans up a number of unused or unneeded feature flags.  As a
result of these changes the user should now be able to enable or disable rx
checksumming via ethtool.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igbvf/ethtool.c |   36 ++++++++++++++++++++----------------
 drivers/net/igbvf/igbvf.h   |    6 +-----
 drivers/net/igbvf/netdev.c  |   17 +++++------------
 3 files changed, 26 insertions(+), 33 deletions(-)

diff --git a/drivers/net/igbvf/ethtool.c b/drivers/net/igbvf/ethtool.c
index 1dcaa69..ee17a09 100644
--- a/drivers/net/igbvf/ethtool.c
+++ b/drivers/net/igbvf/ethtool.c
@@ -133,6 +133,24 @@ static int igbvf_set_pauseparam(struct net_device *netdev,
 	return -EOPNOTSUPP;
 }
 
+static u32 igbvf_get_rx_csum(struct net_device *netdev)
+{
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+	return !(adapter->flags & IGBVF_FLAG_RX_CSUM_DISABLED);
+}
+
+static int igbvf_set_rx_csum(struct net_device *netdev, u32 data)
+{
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+
+	if (data)
+		adapter->flags &= ~IGBVF_FLAG_RX_CSUM_DISABLED;
+	else
+		adapter->flags |= IGBVF_FLAG_RX_CSUM_DISABLED;
+
+	return 0;
+}
+
 static u32 igbvf_get_tx_csum(struct net_device *netdev)
 {
 	return ((netdev->features & NETIF_F_IP_CSUM) != 0);
@@ -150,8 +168,6 @@ static int igbvf_set_tx_csum(struct net_device *netdev, u32 data)
 static int igbvf_set_tso(struct net_device *netdev, u32 data)
 {
 	struct igbvf_adapter *adapter = netdev_priv(netdev);
-	int i;
-	struct net_device *v_netdev;
 
 	if (data) {
 		netdev->features |= NETIF_F_TSO;
@@ -159,24 +175,10 @@ static int igbvf_set_tso(struct net_device *netdev, u32 data)
 	} else {
 		netdev->features &= ~NETIF_F_TSO;
 		netdev->features &= ~NETIF_F_TSO6;
-		/* disable TSO on all VLANs if they're present */
-		if (!adapter->vlgrp)
-			goto tso_out;
-		for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
-			v_netdev = vlan_group_get_device(adapter->vlgrp, i);
-			if (!v_netdev)
-				continue;
-
-			v_netdev->features &= ~NETIF_F_TSO;
-			v_netdev->features &= ~NETIF_F_TSO6;
-			vlan_group_set_device(adapter->vlgrp, i, v_netdev);
-		}
 	}
 
-tso_out:
 	dev_info(&adapter->pdev->dev, "TSO is %s\n",
 	         data ? "Enabled" : "Disabled");
-	adapter->flags |= FLAG_TSO_FORCE;
 	return 0;
 }
 
@@ -517,6 +519,8 @@ static const struct ethtool_ops igbvf_ethtool_ops = {
 	.set_ringparam		= igbvf_set_ringparam,
 	.get_pauseparam		= igbvf_get_pauseparam,
 	.set_pauseparam		= igbvf_set_pauseparam,
+	.get_rx_csum            = igbvf_get_rx_csum,
+	.set_rx_csum            = igbvf_set_rx_csum,
 	.get_tx_csum		= igbvf_get_tx_csum,
 	.set_tx_csum		= igbvf_set_tx_csum,
 	.get_sg			= ethtool_op_get_sg,
diff --git a/drivers/net/igbvf/igbvf.h b/drivers/net/igbvf/igbvf.h
index 4bff35e..2ad6cd7 100644
--- a/drivers/net/igbvf/igbvf.h
+++ b/drivers/net/igbvf/igbvf.h
@@ -286,11 +286,7 @@ struct igbvf_info {
 };
 
 /* hardware capability, feature, and workaround flags */
-#define FLAG_HAS_HW_VLAN_FILTER           (1 << 0)
-#define FLAG_HAS_JUMBO_FRAMES             (1 << 1)
-#define FLAG_MSI_ENABLED                  (1 << 2)
-#define FLAG_RX_CSUM_ENABLED              (1 << 3)
-#define FLAG_TSO_FORCE                    (1 << 4)
+#define IGBVF_FLAG_RX_CSUM_DISABLED             (1 << 0)
 
 #define IGBVF_RX_DESC_ADV(R, i)     \
 	(&((((R).desc))[i].rx_desc))
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index b774666..44a8eef 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -58,8 +58,7 @@ static void igbvf_reset_interrupt_capability(struct igbvf_adapter *);
 
 static struct igbvf_info igbvf_vf_info = {
 	.mac                    = e1000_vfadapt,
-	.flags                  = FLAG_HAS_JUMBO_FRAMES
-	                          | FLAG_RX_CSUM_ENABLED,
+	.flags                  = 0,
 	.pba                    = 10,
 	.init_ops               = e1000_init_function_pointers_vf,
 };
@@ -107,8 +106,10 @@ static inline void igbvf_rx_checksum_adv(struct igbvf_adapter *adapter,
 	skb->ip_summed = CHECKSUM_NONE;
 
 	/* Ignore Checksum bit is set or checksum is disabled through ethtool */
-	if ((status_err & E1000_RXD_STAT_IXSM))
+	if ((status_err & E1000_RXD_STAT_IXSM) ||
+	    (adapter->flags & IGBVF_FLAG_RX_CSUM_DISABLED))
 		return;
+
 	/* TCP/UDP checksum error bit is set */
 	if (status_err &
 	    (E1000_RXDEXT_STATERR_TCPE | E1000_RXDEXT_STATERR_IPE)) {
@@ -116,6 +117,7 @@ static inline void igbvf_rx_checksum_adv(struct igbvf_adapter *adapter,
 		adapter->hw_csum_err++;
 		return;
 	}
+
 	/* It must be a TCP or UDP packet with a valid checksum */
 	if (status_err & (E1000_RXD_STAT_TCPCS | E1000_RXD_STAT_UDPCS))
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
@@ -2351,15 +2353,6 @@ static int igbvf_change_mtu(struct net_device *netdev, int new_mtu)
 		return -EINVAL;
 	}
 
-	/* Jumbo frame size limits */
-	if (max_frame > ETH_FRAME_LEN + ETH_FCS_LEN) {
-		if (!(adapter->flags & FLAG_HAS_JUMBO_FRAMES)) {
-			dev_err(&adapter->pdev->dev,
-			        "Jumbo Frames not supported.\n");
-			return -EINVAL;
-		}
-	}
-
 #define MAX_STD_JUMBO_FRAME_SIZE 9234
 	if (max_frame > MAX_STD_JUMBO_FRAME_SIZE) {
 		dev_err(&adapter->pdev->dev, "MTU > 9216 not supported.\n");

