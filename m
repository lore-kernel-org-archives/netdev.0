From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
Subject: [PATCH net-next] net: ethtool: add support for forward error correction modes
Date: Fri, 10 Feb 2017 10:28:31 -0800
Message-ID: <1486751311-42019-1-git-send-email-vidya@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, dustin@cumulusnetworks.com,
        odedw@mellanox.com, ariela@mellanox.com, Yuval.Mintz@qlogic.com,
        galp@mellanox.com, vidya.chowdary@gmail.com
To: netdev@vger.kernel.org, leedom@chelsio.com, linville@tuxdriver.com,
        jeffrey.t.kirsher@intel.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:34579 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753663AbdBJS2g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 13:28:36 -0500
Received: by mail-pf0-f180.google.com with SMTP id e4so11009118pfg.1
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2017 10:28:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>

Forward Error Correction (FEC) modes i.e Base-R
and Reed-Solomon modes are introduced in 25G/40G/100G standards
for providing good BER at high speeds.
Various networking devices which support 25G/40G/100G provides ability
to manage supported FEC modes and the lack of FEC encoding control and
reporting today is a source for itneroperability issues for many vendors.
FEC capability as well as specific FEC mode i.e. Base-R
or RS modes can be requested or advertised through bits D44:47 of base link
codeword.

This patch set intends to provide option under ethtool to manage and report
FEC encoding settings for networking devices as per IEEE 802.3 bj, bm and by
specs.

set-fec/show-fec option(s) are  designed to provide  control and report
the FEC encoding on the link.

SET FEC option:
root@tor: ethtool --set-fec  swp1 encoding [off | RS | BaseR | auto]

Encoding: Types of encoding
Off    :  Turning off any encoding
RS     :  enforcing RS-FEC encoding on supported speeds
BaseR  :  enforcing Base R encoding on supported speeds
Auto   :  IEEE defaults for the speed/medium combination

Here are a few examples of what we would expect if encoding=auto:
- if autoneg is on, we are  expecting FEC to be negotiated as on or off
  as long as protocol supports it
- if the hardware is capable of detecting the FEC encoding on it's
      receiver it will reconfigure its encoder to match
- in absence of the above, the configuration would be set to IEEE
  defaults.

>From our  understanding , this is essentially what most hardware/driver
combinations are doing today in the absence of a way for users to
control the behavior.

SHOW FEC option:
root@tor: ethtool --show-fec  swp1
FEC parameters for swp1:
Active FEC encodings: RS
Configured FEC encodings:  RS | BaseR

ETHTOOL DEVNAME output modification:

ethtool devname output:
root@tor:~# ethtool swp1
Settings for swp1:
root@hpe-7712-03:~# ethtool swp18
Settings for swp18:
    Supported ports: [ FIBRE ]
    Supported link modes:   40000baseCR4/Full
                            40000baseSR4/Full
                            40000baseLR4/Full
                            100000baseSR4/Full
                            100000baseCR4/Full
                            100000baseLR4_ER4/Full
    Supported pause frame use: No
    Supports auto-negotiation: Yes
    Supported FEC modes: [RS | BaseR | None | Not reported]
    Advertised link modes:  Not reported
    Advertised pause frame use: No
    Advertised auto-negotiation: No
    Advertised FEC modes: [RS | BaseR | None | Not reported]
<<<< One or more FEC modes
    Speed: 100000Mb/s
    Duplex: Full
    Port: FIBRE
    PHYAD: 106
    Transceiver: internal
    Auto-negotiation: off
    Link detected: yes

This patch includes following changes
a) New ETHTOOL_SFECPARAM/SFECPARAM API, handled by
  the new get_fecparam/set_fecparam callbacks, provides support
  for configuration of forward error correction modes.
b) Link mode bits for FEC modes i.e. None (No FEC mode), RS, BaseR/FC
  are defined so that users can configure these fec modes for supported
  and advertising fields as part of link autonegotiation.

Signed-off-by: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>

Changes in RFC PATCH v2:
- Implement Gal Pressman and Casey Leedom feedback
- Removing autonegotiation field in fecparam structure
  and included active_fec to provide mechanism to indicate
  the configured and active FEC modes on port
---
 include/linux/ethtool.h      |  4 ++++
 include/uapi/linux/ethtool.h | 48 +++++++++++++++++++++++++++++++++++++++++++-
 net/core/ethtool.c           | 34 +++++++++++++++++++++++++++++++
 3 files changed, 85 insertions(+), 1 deletion(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 9ded8c6..79a0bab 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -372,5 +372,9 @@ struct ethtool_ops {
 				      struct ethtool_link_ksettings *);
 	int	(*set_link_ksettings)(struct net_device *,
 				      const struct ethtool_link_ksettings *);
+	int	(*get_fecparam)(struct net_device *,
+				      struct ethtool_fecparam *);
+	int	(*set_fecparam)(struct net_device *,
+				      struct ethtool_fecparam *);
 };
 #endif /* _LINUX_ETHTOOL_H */
diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 3dc91a4..38dbfeb 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -1238,6 +1238,47 @@ struct ethtool_per_queue_op {
 	char	data[];
 };
 
+/**
+ * struct ethtool_fecparam - Ethernet forward error correction(fec) parameters
+ * @cmd: Command number = %ETHTOOL_GFECPARAM or %ETHTOOL_SFECPARAM
+ * @active_fec: FEC mode which is active on porte
+ * @fec: Bitmask of supported/configured FEC modes
+ * @rsvd: Reserved for future extensions. i.e FEC bypass feature.
+ *
+ * Drivers should reject a non-zero setting of @autoneg when
+ * autoneogotiation is disabled (or not supported) for the link.
+ *
+ */
+struct ethtool_fecparam {
+	__u32   cmd;
+	/* bitmask of FEC modes */
+	__u32   active_fec;
+	__u32   fec;
+	__u32   reserved;
+};
+
+/**
+ * enum ethtool_fec_config_bits - flags definition of ethtool_fec_configuration
+ * @ETHTOOL_FEC_NONE: FEC mode configuration is not supported
+ * @ETHTOOL_FEC_AUTO: Default/Best FEC mode provided by driver
+ * @ETHTOOL_FEC_OFF: No FEC Mode
+ * @ETHTOOL_FEC_RS: Reed-Solomon Forward Error Detection mode
+ * @ETHTOOL_FEC_BASER: Base-R/Reed-Solomon Forward Error Detection mode
+ */
+enum ethtool_fec_config_bits {
+	ETHTOOL_FEC_NONE_BIT,
+	ETHTOOL_FEC_AUTO_BIT,
+	ETHTOOL_FEC_OFF_BIT,
+	ETHTOOL_FEC_RS_BIT,
+	ETHTOOL_FEC_BASER_BIT,
+};
+
+#define ETHTOOL_FEC_NONE		(1 << ETHTOOL_FEC_NONE_BIT)
+#define ETHTOOL_FEC_AUTO		(1 << ETHTOOL_FEC_AUTO_BIT)
+#define ETHTOOL_FEC_OFF			(1 << ETHTOOL_FEC_OFF_BIT)
+#define ETHTOOL_FEC_RS			(1 << ETHTOOL_FEC_RS_BIT)
+#define ETHTOOL_FEC_BASER		(1 << ETHTOOL_FEC_BASER_BIT)
+
 /* CMDs currently supported */
 #define ETHTOOL_GSET		0x00000001 /* DEPRECATED, Get settings.
 					    * Please use ETHTOOL_GLINKSETTINGS
@@ -1330,6 +1371,8 @@ struct ethtool_per_queue_op {
 #define ETHTOOL_SLINKSETTINGS	0x0000004d /* Set ethtool_link_settings */
 #define ETHTOOL_PHY_GTUNABLE	0x0000004e /* Get PHY tunable configuration */
 #define ETHTOOL_PHY_STUNABLE	0x0000004f /* Set PHY tunable configuration */
+#define ETHTOOL_GFECPARAM	0x00000050 /* Get FEC settings */
+#define ETHTOOL_SFECPARAM	0x00000051 /* Set FEC settings */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
@@ -1387,6 +1430,9 @@ enum ethtool_link_mode_bit_indices {
 	ETHTOOL_LINK_MODE_2500baseT_Full_BIT	= 47,
 	ETHTOOL_LINK_MODE_5000baseT_Full_BIT	= 48,
 
+	ETHTOOL_LINK_MODE_FEC_NONE_BIT	= 49,
+	ETHTOOL_LINK_MODE_FEC_RS_BIT	= 50,
+	ETHTOOL_LINK_MODE_FEC_BASER_BIT	= 51,
 
 	/* Last allowed bit for __ETHTOOL_LINK_MODE_LEGACY_MASK is bit
 	 * 31. Please do NOT define any SUPPORTED_* or ADVERTISED_*
@@ -1395,7 +1441,7 @@ enum ethtool_link_mode_bit_indices {
 	 */
 
 	__ETHTOOL_LINK_MODE_LAST
-	  = ETHTOOL_LINK_MODE_5000baseT_Full_BIT,
+	  = ETHTOOL_LINK_MODE_FEC_BASER_BIT,
 };
 
 #define __ETHTOOL_LINK_MODE_LEGACY_MASK(base_name)	\
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index be7bab1..98fd78c 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -2519,6 +2519,33 @@ static int set_phy_tunable(struct net_device *dev, void __user *useraddr)
 	return ret;
 }
 
+static int ethtool_get_fecparam(struct net_device *dev, void __user *useraddr)
+{
+	struct ethtool_fecparam fecparam = { ETHTOOL_GFECPARAM };
+
+	if (!dev->ethtool_ops->get_fecparam)
+		return -EOPNOTSUPP;
+
+	dev->ethtool_ops->get_fecparam(dev, &fecparam);
+
+	if (copy_to_user(useraddr, &fecparam, sizeof(fecparam)))
+		return -EFAULT;
+	return 0;
+}
+
+static int ethtool_set_fecparam(struct net_device *dev, void __user *useraddr)
+{
+	struct ethtool_fecparam fecparam;
+
+	if (!dev->ethtool_ops->set_fecparam)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&fecparam, useraddr, sizeof(fecparam)))
+		return -EFAULT;
+
+	return dev->ethtool_ops->set_fecparam(dev, &fecparam);
+}
+
 /* The main entry point in this file.  Called from net/core/dev_ioctl.c */
 
 int dev_ethtool(struct net *net, struct ifreq *ifr)
@@ -2578,6 +2605,7 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GTUNABLE:
 	case ETHTOOL_PHY_GTUNABLE:
 	case ETHTOOL_GLINKSETTINGS:
+	case ETHTOOL_GFECPARAM:
 		break;
 	default:
 		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
@@ -2789,6 +2817,12 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_PHY_STUNABLE:
 		rc = set_phy_tunable(dev, useraddr);
 		break;
+	case ETHTOOL_GFECPARAM:
+		rc = ethtool_get_fecparam(dev, useraddr);
+		break;
+	case ETHTOOL_SFECPARAM:
+		rc = ethtool_set_fecparam(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
-- 
2.1.4
