From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 3/5] ethtool: Introduce n-tuple filter
	programming support
Date: Wed, 06 Jan 2010 20:49:06 -0800
Message-ID: <20100107044905.28605.54076.stgit@localhost.localdomain>
References: <20100107044741.28605.31414.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Luca Deri <deri@ntop.org>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.emeryville.ca.mail.comcast.net ([76.96.30.24]:42030 "EHLO
	QMTA02.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932437Ab0AGEt2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 23:49:28 -0500
In-Reply-To: <20100107044741.28605.31414.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

This patchset enables the ethtool layer to program n-tuple
filters to an underlying device.  The idea is to allow capable
hardware to have static rules applied that can assist steering
flows into appropriate queues.

Hardware that is known to support these types of filters today
are ixgbe and niu.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: Luca Deri <deri@ntop.org>
CC: Joseph Gasparakis <joseph.gasparakis@intel.com>
---

 include/linux/ethtool.h |   34 ++++++++++++++++++++++++++++++++++
 net/core/ethtool.c      |   16 ++++++++++++++++
 2 files changed, 50 insertions(+), 0 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index ef4a2d8..dd65192 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -363,6 +363,35 @@ struct ethtool_rxnfc {
 	__u32				rule_locs[0];
 };
 
+struct ethtool_rx_ntuple_flow_spec {
+	__u32		flow_type;
+	union {
+		struct ethtool_tcpip4_spec		tcp_ip4_spec;
+		struct ethtool_tcpip4_spec		udp_ip4_spec;
+		struct ethtool_tcpip4_spec		sctp_ip4_spec;
+		struct ethtool_ah_espip4_spec		ah_ip4_spec;
+		struct ethtool_ah_espip4_spec		esp_ip4_spec;
+		struct ethtool_rawip4_spec		raw_ip4_spec;
+		struct ethtool_ether_spec		ether_spec;
+		struct ethtool_usrip4_spec		usr_ip4_spec;
+		__u8					hdata[64];
+	} h_u, m_u; /* entry, mask */
+
+	__u16	        vlan_tag;
+	__u16	        vlan_tag_mask;
+	__u64		data;      /* user-defined flow spec data */
+	__u64		data_mask; /* user-defined flow spec mask */
+
+	/* signed to distinguish between queue and actions (DROP) */
+	__s32		action;
+#define ETHTOOL_RXNTUPLE_ACTION_DROP -1
+};
+
+struct ethtool_rx_ntuple {
+	__u32					cmd;
+	struct ethtool_rx_ntuple_flow_spec	fs;
+};
+
 #define ETHTOOL_FLASH_MAX_FILENAME	128
 enum ethtool_flash_op_type {
 	ETHTOOL_FLASH_ALL_REGIONS	= 0,
@@ -500,6 +529,8 @@ struct ethtool_ops {
 	int	(*set_rxnfc)(struct net_device *, struct ethtool_rxnfc *);
 	int     (*flash_device)(struct net_device *, struct ethtool_flash *);
 	int	(*reset)(struct net_device *, u32 *);
+	int	(*set_rx_ntuple)(struct net_device *, struct ethtool_rx_ntuple *);
+	int	(*get_rx_ntuple)(struct net_device *, struct ethtool_rx_ntuple *, void *);
 };
 #endif /* __KERNEL__ */
 
@@ -559,6 +590,9 @@ struct ethtool_ops {
 #define	ETHTOOL_FLASHDEV	0x00000033 /* Flash firmware to device */
 #define	ETHTOOL_RESET		0x00000034 /* Reset hardware */
 
+#define ETHTOOL_SRXNTUPLE	0x00000035 /* Add an n-tuple filter to device */
+#define ETHTOOL_GRXNTUPLE	0x00000036 /* Get n-tuple filters from device */
+
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
 #define SPARC_ETH_SSET		ETHTOOL_SSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index d8aee58..96b3144 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -266,6 +266,19 @@ err_out:
 	return ret;
 }
 
+static int ethtool_set_rx_ntuple(struct net_device *dev, void __user *useraddr)
+{
+	struct ethtool_rx_ntuple cmd;
+
+	if (!dev->ethtool_ops->set_rx_ntuple)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&cmd, useraddr, sizeof(cmd)))
+		return -EFAULT;
+
+	return dev->ethtool_ops->set_rx_ntuple(dev, &cmd);
+}
+
 static int ethtool_get_regs(struct net_device *dev, char __user *useraddr)
 {
 	struct ethtool_regs regs;
@@ -1112,6 +1125,9 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_RESET:
 		rc = ethtool_reset(dev, useraddr);
 		break;
+	case ETHTOOL_SRXNTUPLE:
+		rc = ethtool_set_rx_ntuple(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}

