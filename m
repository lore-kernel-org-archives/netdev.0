From: Santwona.Behera@Sun.COM
Subject: [PATCH 2/3] [kernel] Add support for RX packet classification in a
 network device
Date: Mon, 16 Feb 2009 09:17:23 -0800
Message-ID: <49999FA3.7040300@Sun.COM>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary_(ID_CZtwfrlCc7b4eD3YpIYYuQ)"
Cc: gkernel-commit@lists.sourceforge.net,
	Matheos Worku <Matheos.Worku@Sun.COM>,
	Mehdi Bonyadi <Mehdi.Bonyadi@Sun.COM>,
	Santwona Behera <Santwona.Behera@Sun.COM>
To: netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-1.Sun.COM ([192.18.43.132]:34117 "EHLO
	sca-es-mail-1.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104AbZBPRRn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2009 12:17:43 -0500
Received: from fe-sfbay-10.sun.com ([192.18.43.129])
	by sca-es-mail-1.sun.com (8.13.7+Sun/8.12.9) with ESMTP id n1GHHUpf022481
	for <netdev@vger.kernel.org>; Mon, 16 Feb 2009 09:17:38 -0800 (PST)
Received: from conversion-daemon.fe-sfbay-10.sun.com by fe-sfbay-10.sun.com
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec 23 2008))
 id <0KF600F0051TJJ00@fe-sfbay-10.sun.com> for netdev@vger.kernel.org; Mon,
 16 Feb 2009 09:17:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.

--Boundary_(ID_CZtwfrlCc7b4eD3YpIYYuQ)
Content-type: text/plain; format=flowed; charset=ISO-8859-1
Content-transfer-encoding: 7BIT


--Boundary_(ID_CZtwfrlCc7b4eD3YpIYYuQ)
Content-type: text/x-patch;
 name=ethtool-kernel-add-rx-pkt-classification-interface.patch
Content-transfer-encoding: 7BIT
Content-disposition: inline;
 filename=ethtool-kernel-add-rx-pkt-classification-interface.patch;
 filename*0=ethtool-kernel-add-rx-pkt-classification-interface.patch

From: Santwona Behera <santwona.behera@sun.com>
Subject: [PATCH 2/3] [Ethtool] Add RX pkt classification interface


Signed-off-by: Santwona Behera <santwona.behera@sun.com>
---
 include/linux/ethtool.h |   90 +++++++++++++++++++++++++++++++++++++++++++---
 net/core/ethtool.c      |   58 +++++++++++++++++++++++++-----
 2 files changed, 132 insertions(+), 16 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 27c67a5..cb0e1c5 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -7,6 +7,7 @@
  * Portions Copyright 2002 Intel (eli.kupermann@intel.com,
  *                                christopher.leech@intel.com,
  *                                scott.feldman@intel.com)
+ * Portions Copyright (C) Sun Microsystems 2008
  */
 
 #ifndef _LINUX_ETHTOOL_H
@@ -287,10 +288,76 @@ enum ethtool_flags {
 	ETH_FLAG_LRO		= (1 << 15),	/* LRO is enabled */
 };
 
-struct ethtool_rxnfc {
-	__u32		cmd;
+/* The following structures are for supporting RX network flow
+ * classification configuration. Note, all multibyte fields, e.g.,
+ * ip4src, ip4dst, psrc, pdst, spi, etc. are expected to be in network
+ * byte order.
+ */
+struct ethtool_tcpip4_spec {
+	__u32	ip4src;
+	__u32	ip4dst;
+	__u16	psrc;
+	__u16	pdst;
+	__u8    tos;
+};
+
+struct ethtool_ah_espip4_spec {
+	__u32	ip4src;
+	__u32	ip4dst;
+	__u32	spi;
+	__u8    tos;
+};
+
+struct ethtool_rawip4_spec {
+	__u32	ip4src;
+	__u32	ip4dst;
+	__u8	hdata[64];
+};
+
+struct ethtool_ether_spec {
+	__u16	ether_type;
+	__u8	frame_size;
+	__u8	eframe[16];
+};
+
+#define	ETH_RX_NFC_IP4	1
+#define	ETH_RX_NFC_IP6	2
+
+struct ethtool_usrip4_spec {
+	__u32	ip4src;
+	__u32	ip4dst;
+	__u32	l4_4_bytes;
+	__u8    tos;
+	__u8    ip_ver;
+	__u8    proto;
+};
+
+struct ethtool_rx_flow_spec {
 	__u32		flow_type;
-	__u64		data;
+	union
+	{
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
+	__u64		ring_cookie;
+	__u32		location;
+};
+
+struct ethtool_rxnfc {
+	__u32				cmd;
+	__u32				flow_type;
+	/* The rx flow hash value or the rule DB size */
+	__u64				data;
+	struct ethtool_rx_flow_spec	fs;
+	__u32				rule_cnt;
+	__u32				rule_locs[0];
 };
 
 #ifdef __KERNEL__
@@ -417,8 +484,8 @@ struct ethtool_ops {
 	/* the following hooks are obsolete */
 	int	(*self_test_count)(struct net_device *);/* use get_sset_count */
 	int	(*get_stats_count)(struct net_device *);/* use get_sset_count */
-	int	(*get_rxhash)(struct net_device *, struct ethtool_rxnfc *);
-	int	(*set_rxhash)(struct net_device *, struct ethtool_rxnfc *);
+	int	(*get_rxnfc)(struct net_device *, struct ethtool_rxnfc *, void *);
+	int	(*set_rxnfc)(struct net_device *, struct ethtool_rxnfc *);
 };
 #endif /* __KERNEL__ */
 
@@ -469,6 +536,12 @@ struct ethtool_ops {
 #define	ETHTOOL_SRXFH		0x0000002a /* Set RX flow hash configuration */
 #define ETHTOOL_GGRO		0x0000002b /* Get GRO enable (ethtool_value) */
 #define ETHTOOL_SGRO		0x0000002c /* Set GRO enable (ethtool_value) */
+#define	ETHTOOL_GRXRINGS	0x0000002d /* Get RX rings available for LB */
+#define	ETHTOOL_GRXCLSRLCNT	0x0000002e /* Get RX class rule count */
+#define	ETHTOOL_GRXCLSRULE	0x0000002f /* Get RX classification rule */
+#define	ETHTOOL_GRXCLSRLALL	0x00000030 /* Get all RX classification rule */
+#define	ETHTOOL_SRXCLSRLDEL	0x00000031 /* Delete RX classification rule */
+#define	ETHTOOL_SRXCLSRLINS	0x00000032 /* Insert RX classification rule */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
@@ -565,9 +638,13 @@ struct ethtool_ops {
 #define	UDP_V6_FLOW	0x06
 #define	SCTP_V6_FLOW	0x07
 #define	AH_ESP_V6_FLOW	0x08
+#define	AH_V4_FLOW	0x09
+#define	ESP_V4_FLOW	0x0a
+#define	AH_V6_FLOW	0x0b
+#define	ESP_V6_FLOW	0x0c
+#define	IP_USER_FLOW	0x0d
 
 /* L3-L4 network traffic flow hash options */
-#define	RXH_DEV_PORT	(1 << 0)
 #define	RXH_L2DA	(1 << 1)
 #define	RXH_VLAN	(1 << 2)
 #define	RXH_L3_PROTO	(1 << 3)
@@ -577,5 +654,6 @@ struct ethtool_ops {
 #define	RXH_L4_B_2_3	(1 << 7) /* dst port in case of TCP/UDP/SCTP */
 #define	RXH_DISCARD	(1 << 31)
 
+#define	RX_CLS_FLOW_DISC	0xffffffffffffffffULL
 
 #endif /* _LINUX_ETHTOOL_H */
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 947710a..244ca56 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -209,34 +209,62 @@ static int ethtool_get_drvinfo(struct net_device *dev, void __user *useraddr)
 	return 0;
 }
 
-static int ethtool_set_rxhash(struct net_device *dev, void __user *useraddr)
+static int ethtool_set_rxnfc(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_rxnfc cmd;
 
-	if (!dev->ethtool_ops->set_rxhash)
+	if (!dev->ethtool_ops->set_rxnfc)
 		return -EOPNOTSUPP;
 
 	if (copy_from_user(&cmd, useraddr, sizeof(cmd)))
 		return -EFAULT;
 
-	return dev->ethtool_ops->set_rxhash(dev, &cmd);
+	return dev->ethtool_ops->set_rxnfc(dev, &cmd);
 }
 
-static int ethtool_get_rxhash(struct net_device *dev, void __user *useraddr)
+static int ethtool_get_rxnfc(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_rxnfc info;
+	const struct ethtool_ops *ops = dev->ethtool_ops;
+	int ret;
+	void *rule_buf = NULL;
 
-	if (!dev->ethtool_ops->get_rxhash)
+	if (!ops->get_rxnfc)
 		return -EOPNOTSUPP;
 
 	if (copy_from_user(&info, useraddr, sizeof(info)))
 		return -EFAULT;
 
-	dev->ethtool_ops->get_rxhash(dev, &info);
+	if (info.cmd == ETHTOOL_GRXCLSRLALL) {
+		if (info.rule_cnt > 0) {
+			rule_buf = kmalloc(info.rule_cnt * sizeof(u32),
+					   GFP_USER);
+			if (!rule_buf)
+				return -ENOMEM;
+		}
+	}
 
+	ret = ops->get_rxnfc(dev, &info, rule_buf);
+	if (ret < 0)
+		goto err_out;
+
+	ret = -EFAULT;
 	if (copy_to_user(useraddr, &info, sizeof(info)))
-		return -EFAULT;
-	return 0;
+		goto err_out;
+
+	if (rule_buf) {
+		useraddr += offsetof(struct ethtool_rxnfc, rule_locs);
+		if (copy_to_user(useraddr, rule_buf,
+				 info.rule_cnt * sizeof(u32)))
+			goto err_out;
+	}
+	ret = 0;
+
+err_out:
+	if (rule_buf)
+		kfree(rule_buf);
+
+	return ret;
 }
 
 static int ethtool_get_regs(struct net_device *dev, char __user *useraddr)
@@ -901,6 +929,10 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GFLAGS:
 	case ETHTOOL_GPFLAGS:
 	case ETHTOOL_GRXFH:
+	case ETHTOOL_GRXRINGS:
+	case ETHTOOL_GRXCLSRLCNT:
+	case ETHTOOL_GRXCLSRULE:
+	case ETHTOOL_GRXCLSRLALL:
 		break;
 	default:
 		if (!capable(CAP_NET_ADMIN))
@@ -1052,10 +1084,16 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 				       dev->ethtool_ops->set_priv_flags);
 		break;
 	case ETHTOOL_GRXFH:
-		rc = ethtool_get_rxhash(dev, useraddr);
+	case ETHTOOL_GRXRINGS:
+	case ETHTOOL_GRXCLSRLCNT:
+	case ETHTOOL_GRXCLSRULE:
+	case ETHTOOL_GRXCLSRLALL:
+		rc = ethtool_get_rxnfc(dev, useraddr);
 		break;
 	case ETHTOOL_SRXFH:
-		rc = ethtool_set_rxhash(dev, useraddr);
+	case ETHTOOL_SRXCLSRLDEL:
+	case ETHTOOL_SRXCLSRLINS:
+		rc = ethtool_set_rxnfc(dev, useraddr);
 		break;
 	case ETHTOOL_GGRO:
 		rc = ethtool_get_gro(dev, useraddr);
-- 
1.5.2


--Boundary_(ID_CZtwfrlCc7b4eD3YpIYYuQ)--
