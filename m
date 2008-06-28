From: Santwona Behera <Santwona.Behera@Sun.COM>
Subject: [PATCH 2/3] Add support for rx flow hash configuration in a network
 device - [ethtool kernel]
Date: Fri, 27 Jun 2008 17:06:24 -0700
Message-ID: <48658080.3010102@Sun.COM>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary_(ID_2j5tN4/y7uTq+Lhitxpc8w)"
Cc: Matheos.Worku@Sun.COM, Michael.Speer@Sun.COM,
	gkernel-commit@lists.sourceforge.net, Santwona.Behera@Sun.COM
To: netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-1.Sun.COM ([192.18.43.132]:54138 "EHLO
	sca-es-mail-1.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754829AbYF1AG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2008 20:06:26 -0400
Received: from fe-sfbay-10.sun.com ([192.18.43.129])
	by sca-es-mail-1.sun.com (8.13.7+Sun/8.12.9) with ESMTP id m5S06QqG022024
	for <netdev@vger.kernel.org>; Fri, 27 Jun 2008 17:06:26 -0700 (PDT)
Received: from conversion-daemon.fe-sfbay-10.sun.com by fe-sfbay-10.sun.com
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 id <0K3500E01CAB0V00@fe-sfbay-10.sun.com>
 (original mail from Santwona.Behera@Sun.COM) for netdev@vger.kernel.org; Fri,
 27 Jun 2008 17:06:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.

--Boundary_(ID_2j5tN4/y7uTq+Lhitxpc8w)
Content-type: text/plain; format=flowed; charset=ISO-8859-1
Content-transfer-encoding: 7BIT



--Boundary_(ID_2j5tN4/y7uTq+Lhitxpc8w)
Content-type: text/x-patch; name=ethtool_kernel_rx_flow_hash_cfg.patch
Content-transfer-encoding: 7BIT
Content-disposition: inline; filename=ethtool_kernel_rx_flow_hash_cfg.patch

From: Santwona Behera <santwona.behera@sun.com>

Added new interfaces to ethtool to configure receive network flow distribution across multiple rx rings using hashing.

Signed-off-by: Santwona Behera <santwona.behera@sun.com>
---
 include/linux/ethtool.h |   33 +++++++++++++++++++++++++++++++++
 net/core/ethtool.c      |   37 +++++++++++++++++++++++++++++++++++++
 2 files changed, 70 insertions(+), 0 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index c8d2163..8bb5e87 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -272,6 +272,12 @@ enum ethtool_flags {
 	ETH_FLAG_LRO		= (1 << 15),	/* LRO is enabled */
 };
 
+struct ethtool_rxnfc {
+	__u32		cmd;
+	__u32		flow_type;
+	__u64		data;
+};
+
 #ifdef __KERNEL__
 
 struct net_device;
@@ -396,6 +402,8 @@ struct ethtool_ops {
 	/* the following hooks are obsolete */
 	int	(*self_test_count)(struct net_device *);/* use get_sset_count */
 	int	(*get_stats_count)(struct net_device *);/* use get_sset_count */
+	int	(*get_rxhash)(struct net_device *, struct ethtool_rxnfc *);
+	int	(*set_rxhash)(struct net_device *, struct ethtool_rxnfc *);
 };
 #endif /* __KERNEL__ */
 
@@ -442,6 +450,9 @@ struct ethtool_ops {
 #define ETHTOOL_GPFLAGS		0x00000027 /* Get driver-private flags bitmap */
 #define ETHTOOL_SPFLAGS		0x00000028 /* Set driver-private flags bitmap */
 
+#define	ETHTOOL_GRXFH		0x00000029 /* Get RX flow hash configuration */
+#define	ETHTOOL_SRXFH		0x0000002a /* Set RX flow hash configuration */
+
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
 #define SPARC_ETH_SSET		ETHTOOL_SSET
@@ -528,4 +539,26 @@ struct ethtool_ops {
 #define WAKE_MAGIC		(1 << 5)
 #define WAKE_MAGICSECURE	(1 << 6) /* only meaningful if WAKE_MAGIC */
 
+/* L3-L4 network traffic flow types */
+#define	TCP_V4_FLOW	0x01
+#define	UDP_V4_FLOW	0x02
+#define	SCTP_V4_FLOW	0x03
+#define	AH_ESP_V4_FLOW	0x04
+#define	TCP_V6_FLOW	0x05
+#define	UDP_V6_FLOW	0x06
+#define	SCTP_V6_FLOW	0x07
+#define	AH_ESP_V6_FLOW	0x08
+
+/* L3-L4 network traffic flow hash options */
+#define	RXH_DEV_PORT	(1 << 0)
+#define	RXH_L2DA	(1 << 1)
+#define	RXH_VLAN	(1 << 2)
+#define	RXH_L3_PROTO	(1 << 3)
+#define	RXH_IP_SRC	(1 << 4)
+#define	RXH_IP_DST	(1 << 5)
+#define	RXH_L4_B_0_1	(1 << 6) /* src port in case of TCP/UDP/SCTP */
+#define	RXH_L4_B_2_3	(1 << 7) /* dst port in case of TCP/UDP/SCTP */
+#define	RXH_DISCARD	(1 << 31)
+
+
 #endif /* _LINUX_ETHTOOL_H */
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 0133b5e..14ada53 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -209,6 +209,36 @@ static int ethtool_get_drvinfo(struct net_device *dev, void __user *useraddr)
 	return 0;
 }
 
+static int ethtool_set_rxhash(struct net_device *dev, void __user *useraddr)
+{
+	struct ethtool_rxnfc cmd;
+
+	if (!dev->ethtool_ops->set_rxhash)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&cmd, useraddr, sizeof(cmd)))
+		return -EFAULT;
+
+	return dev->ethtool_ops->set_rxhash(dev, &cmd);
+}
+
+static int ethtool_get_rxhash(struct net_device *dev, void __user *useraddr)
+{
+	struct ethtool_rxnfc info;
+
+	if (!dev->ethtool_ops->get_rxhash)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&info, useraddr, sizeof(info)))
+		return -EFAULT;
+
+	dev->ethtool_ops->get_rxhash(dev, &info);
+
+	if (copy_to_user(useraddr, &info, sizeof(info)))
+		return -EFAULT;
+	return 0;
+}
+
 static int ethtool_get_regs(struct net_device *dev, char __user *useraddr)
 {
 	struct ethtool_regs regs;
@@ -826,6 +856,7 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GGSO:
 	case ETHTOOL_GFLAGS:
 	case ETHTOOL_GPFLAGS:
+	case ETHTOOL_GRXFH:
 		break;
 	default:
 		if (!capable(CAP_NET_ADMIN))
@@ -977,6 +1008,12 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 		rc = ethtool_set_value(dev, useraddr,
 				       dev->ethtool_ops->set_priv_flags);
 		break;
+	case ETHTOOL_GRXFH:
+		rc = ethtool_get_rxhash(dev, useraddr);
+		break;
+	case ETHTOOL_SRXFH:
+		rc = ethtool_set_rxhash(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
-- 
1.5.2


--Boundary_(ID_2j5tN4/y7uTq+Lhitxpc8w)--
