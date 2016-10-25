From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
Subject: [RFC PATCH net-next] net: ethtool: add support for forward error correction modes
Date: Mon, 24 Oct 2016 19:50:49 -0700
Message-ID: <1477363849-36517-1-git-send-email-vidya@cumulusnetworks.com>
Cc: roees@mellanox.com, aviadr@mellanox.com,
        dustin@cumulusnetworks.com, roopa@cumulusnetworks.com
To: davem@davemloft.net, linville@tuxdriver.com, saeedm@mellanox.com,
        galp@mellanox.com, netdev@vger.kernel.org, odedw@mellanox.com,
        ariela@mellanox.com, Yuval.Mintz@qlogic.com, tzahio@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35270 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933798AbcJYCu7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2016 22:50:59 -0400
Received: by mail-pf0-f170.google.com with SMTP id s8so109771382pfj.2
        for <netdev@vger.kernel.org>; Mon, 24 Oct 2016 19:50:59 -0700 (PDT)
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
root@tor: ethtool --set-fec  swp1 encoding [off | RS | BaseR | auto] autoneg [off | on]

Encoding: Types of encoding
Off    :  Turning off any encoding
RS     :  enforcing RS-FEC encoding on supported speeds
BaseR  :  enforcing Base R encoding on supported speeds
Auto   :  Default FEC settings  for  divers , and would represent
          asking the hardware to essentially go into a best effort mode.

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
Autonegotiate:  off
FEC encodings:  RS

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
---
 include/linux/ethtool.h      |  4 ++++
 include/uapi/linux/ethtool.h | 53 ++++++++++++++++++++++++++++++++++++++++++--
 net/core/ethtool.c           | 34 ++++++++++++++++++++++++++++
 3 files changed, 89 insertions(+), 2 deletions(-)

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
index 099a420..28ea382 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -1224,6 +1224,51 @@ struct ethtool_per_queue_op {
 	char	data[];
 };
 
+/**
+ * struct ethtool_fecparam - Ethernet forward error correction(fec) parameters
+ * @cmd: Command number = %ETHTOOL_GFECPARAM or %ETHTOOL_SFECPARAM
+ * @autoneg: Flag to enable autonegotiation of fec modes(rs,baser)
+ *          (D44:47 of base link code word)
+ * @fec: Bitmask of supported FEC modes
+ * @rsvd: Reserved for future extensions. i.e FEC bypass feature.
+ *
+ * Drivers should reject a non-zero setting of @autoneg when
+ * autoneogotiation is disabled (or not supported) for the link.
+ *
+ * If @autoneg is non-zero, the MAC is configured to enable one of
+ * the supported FEC modes according to the result of autonegotiation.
+ * Otherwise, it is configured directly based on the @fec parameter
+ */
+struct ethtool_fecparam {
+	__u32   cmd;
+	__u32   autoneg;
+	/* bitmask of FEC modes */
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
@@ -1315,6 +1360,8 @@ struct ethtool_per_queue_op {
 #define ETHTOOL_GLINKSETTINGS	0x0000004c /* Get ethtool_link_settings */
 #define ETHTOOL_SLINKSETTINGS	0x0000004d /* Set ethtool_link_settings */
 
+#define ETHTOOL_GFECPARAM	0x0000004e /* Get FEC settings */
+#define ETHTOOL_SFECPARAM	0x0000004f /* Set FEC settings */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
@@ -1369,7 +1416,9 @@ enum ethtool_link_mode_bit_indices {
 	ETHTOOL_LINK_MODE_10000baseLR_Full_BIT	= 44,
 	ETHTOOL_LINK_MODE_10000baseLRM_Full_BIT	= 45,
 	ETHTOOL_LINK_MODE_10000baseER_Full_BIT	= 46,
-
+	ETHTOOL_LINK_MODE_FEC_NONE_BIT		= 47,
+	ETHTOOL_LINK_MODE_FEC_RS_BIT		= 48,
+	ETHTOOL_LINK_MODE_FEC_BASER_BIT		= 49,
 
 	/* Last allowed bit for __ETHTOOL_LINK_MODE_LEGACY_MASK is bit
 	 * 31. Please do NOT define any SUPPORTED_* or ADVERTISED_*
@@ -1378,7 +1427,7 @@ enum ethtool_link_mode_bit_indices {
 	 */
 
 	__ETHTOOL_LINK_MODE_LAST
-	  = ETHTOOL_LINK_MODE_10000baseER_Full_BIT,
+	  = ETHTOOL_LINK_MODE_FEC_BASER_BIT,
 };
 
 #define __ETHTOOL_LINK_MODE_LEGACY_MASK(base_name)	\
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 9774898..be8a917 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -2422,6 +2422,33 @@ static int ethtool_set_per_queue(struct net_device *dev, void __user *useraddr)
 	};
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
@@ -2479,6 +2506,7 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GET_TS_INFO:
 	case ETHTOOL_GEEE:
 	case ETHTOOL_GTUNABLE:
+	case ETHTOOL_GFECPARAM:
 		break;
 	default:
 		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
@@ -2684,6 +2712,12 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_SLINKSETTINGS:
 		rc = ethtool_set_link_ksettings(dev, useraddr);
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
