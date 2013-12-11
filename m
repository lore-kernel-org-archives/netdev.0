From: Stefan Raspl <raspl@linux.vnet.ibm.com>
Subject: [PATCH 1/2] ethtool: Add callback to indicate adjacent switch port attributes
Date: Wed, 11 Dec 2013 14:28:59 +0100
Message-ID: <1386768540-48188-2-git-send-email-raspl@linux.vnet.ibm.com>
References: <1386768540-48188-1-git-send-email-raspl@linux.vnet.ibm.com>
Cc: bhutchings@solarflare.com, blaschka@linux.vnet.ibm.com,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Stefan Raspl <raspl@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp13.uk.ibm.com ([195.75.94.109]:37848 "EHLO
	e06smtp13.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751827Ab3LKN3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 08:29:43 -0500
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <raspl@linux.vnet.ibm.com>;
	Wed, 11 Dec 2013 13:29:41 -0000
In-Reply-To: <1386768540-48188-1-git-send-email-raspl@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switches supporting LLDP can communicate port attributes to connected devices.
Device drivers capable of accessing this information from the devices can use
the new callback get_switch_port_attrs() to report supported and enabled
settings in the card's adjacent switch port for display in ethtool.
Implementors have to use the respective SUPPORTED_SP_* and ENABLED_SP_* defines
to indicate the current settings.

Signed-off-by: Stefan Raspl <raspl@linux.vnet.ibm.com>
---
 include/linux/ethtool.h      |  3 +++
 include/uapi/linux/ethtool.h | 35 +++++++++++++++++++++++++++++++++++
 net/core/ethtool.c           | 22 ++++++++++++++++++++++
 3 files changed, 60 insertions(+)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index c8e3e7e3..940c7b1 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -177,6 +177,7 @@ static inline u32 ethtool_rxfh_indir_default(u32 index, u32 n_rx_rings)
  * @get_module_eeprom: Get the eeprom information from the plug-in module
  * @get_eee: Get Energy-Efficient (EEE) supported and status.
  * @set_eee: Set EEE status (enable/disable) as well as LPI timers.
+ * @get_switch_port_attrs: Get adjacent switch port attributes.
  *
  * All operations are optional (i.e. the function pointer may be set
  * to %NULL) and callers must take this into account.  Callers must
@@ -245,6 +246,8 @@ struct ethtool_ops {
 				     struct ethtool_eeprom *, u8 *);
 	int	(*get_eee)(struct net_device *, struct ethtool_eee *);
 	int	(*set_eee)(struct net_device *, struct ethtool_eee *);
+	int     (*get_switch_port_attrs)(struct net_device *,
+					 struct ethtool_swport_attrs *);
 
 
 };
diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 38dbafa..f5843ac 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -136,6 +136,22 @@ struct ethtool_eeprom {
 };
 
 /**
+ * struct ethtool_swport_attrs - query adjacent switch port attributes
+ * @cmd: ETHTOOL_GPORT
+ * @port_rc: Use GPORT_RC_* as appropriate.
+ * @supported: Forwarding modes and capabilities supported by the switch port,
+ *	see SUPPORTED_SP_* flags.
+ * @enabled: Forwarding modes and capabilities currently activated at the
+ *	adjacent switch port, see ENABLED_SP_* flags.
+ */
+struct ethtool_swport_attrs {
+	__u32	cmd;
+	__u32	port_rc;
+	__u32	supported;
+	__u32	enabled;
+};
+
+/**
  * struct ethtool_eee - Energy Efficient Ethernet information
  * @cmd: ETHTOOL_{G,S}EEE
  * @supported: Mask of %SUPPORTED_* flags for the speed/duplex combinations
@@ -900,6 +916,7 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_GMODULEEEPROM	0x00000043 /* Get plug-in module eeprom */
 #define ETHTOOL_GEEE		0x00000044 /* Get EEE settings */
 #define ETHTOOL_SEEE		0x00000045 /* Set EEE settings */
+#define ETHTOOL_GPORT		0x00000046 /* Get switch port attributes */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
@@ -1067,6 +1084,24 @@ enum ethtool_sfeatures_retval_bits {
 #define ETH_MODULE_SFF_8472		0x2
 #define ETH_MODULE_SFF_8472_LEN		512
 
+/* Bad return codes for switch ports */
+#define GPORT_RC_LLDP_UNSUP	1	/* switch port doesn't support */
+					/* required LLDP EVB TLV       */
+
+/* Indicates what features the adjacent switch port supports. */
+#define SUPPORTED_SP_FWD_802_1	(1 << 0)
+#define SUPPORTED_SP_FWD_RR	(1 << 1)
+#define SUPPORTED_SP_CAP_RTE	(1 << 9)
+#define SUPPORTED_SP_CAP_ECP	(1 << 10)
+#define SUPPORTED_SP_CAP_VDP	(1 << 11)
+
+/* Indicates what features the adjacent switch port has enabled. */
+#define ENABLED_SP_FWD_802_1	(1 << 0)
+#define ENABLED_SP_FWD_RR	(1 << 1)
+#define ENABLED_SP_CAP_RTE	(1 << 9)
+#define ENABLED_SP_CAP_ECP	(1 << 10)
+#define ENABLED_SP_CAP_VDP	(1 << 11)
+
 /* Reset flags */
 /* The reset() operation must clear the flags for the components which
  * were actually reset.  On successful return, the flags indicate the
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 30071de..84f69f1 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1446,6 +1446,25 @@ static int ethtool_get_module_eeprom(struct net_device *dev,
 				      modinfo.eeprom_len);
 }
 
+static int ethtool_get_switch_port_attrs(struct net_device *dev,
+							void __user *useraddr)
+{
+	struct ethtool_swport_attrs attrs = { ETHTOOL_GPORT };
+	int rc;
+
+	if (!dev->ethtool_ops->get_switch_port_attrs)
+		return -EOPNOTSUPP;
+
+	rc = dev->ethtool_ops->get_switch_port_attrs(dev, &attrs);
+	if (rc)
+		return rc;
+
+	if (copy_to_user(useraddr, &attrs, sizeof(attrs)))
+		return -EFAULT;
+
+	return 0;
+}
+
 /* The main entry point in this file.  Called from net/core/dev_ioctl.c */
 
 int dev_ethtool(struct net *net, struct ifreq *ifr)
@@ -1675,6 +1694,9 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GMODULEEEPROM:
 		rc = ethtool_get_module_eeprom(dev, useraddr);
 		break;
+	case ETHTOOL_GPORT:
+		rc = ethtool_get_switch_port_attrs(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
-- 
1.8.3.4
